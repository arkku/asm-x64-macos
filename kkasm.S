BITS 64

SECTION .data
SECTALIGN 16

STDIN   equ 0
STDOUT  equ 1
STDERR  equ 2

; syscall number in RAX
; Arguments in RDI, RSI, RDX

%define unixsys(num) ((2<<24)|(num))

SYS_write   equ unixsys(4)
SYS_read    equ unixsys(3)
SYS_exit    equ unixsys(1)

randseed    equ 17044589709537312451
randmult    equ 2685821657736338717

RAND_MAX    equ 0x3fffffff

randstate:  dq randseed

;; IO

SECTION .text

%macro export_function 1
global %1, _%1
_%1:
%endmacro

; Read a character from stdin, return it in EAX.
; On error/EOF, returns negative.
export_function getchar
getchar:
        sub     rsp, 8                  ; align stack
        mov     eax, SYS_read           ; syscall
        mov     edi, STDIN              ; file
        mov     rsi, rsp                ; buffer
        mov     edx, 1                  ; length
        syscall
        add     rsp, 8                  ; restore rsp
        cmp     eax, 0                  ; check for error/eof
        je      .eof
        jl      .error
        movzx   eax, byte [rsp-8]       ; move from buffer to return value
        ret
.eof:   dec     rax
.error: ret

; Output the byte from DIL to stdout.
export_function putchar
putchar:
        sub     rsp, 8
        mov     eax, SYS_write          ; syscall
        mov     [rsp], dil              ; load argument into buffer
        mov     edx, 1                  ; length
        mov     rsi, rsp                ; buffer
        mov     edi, STDOUT             ; file
        syscall
        add     rsp, 8
        ret

; Print string [RDI].
export_function print
print:
        push    rdi                     ; save argument
        call    strlen                  ; determine length
        mov     rdx, rax                ; move length into argument
        pop     rdi                     ; restore original argument
        mov     rsi, rdi                ; string
        mov     edi, STDOUT             ; file
.write: push    rdx                     ; save length
        mov     eax, SYS_write          ; syscall
        syscall
        pop     rdx                     ; restore length
        sub     rdx, rax                ; calculate unwritten length
        jz      .done                   ; no more bytes to write
        add     rsi, rax                ; increment pointer for next write
        cmp     eax, 0                  ; check for error/EOF
        jg      .write                  ; write more (FWIW, not sure if needed)
        mov     eax, -1                 ; error
.done:  ret

; Print the integer in RDI to stdout in decimal.
export_function printi
printi:
        push    rbp                     ; save rbp + align stack
        mov     rbp, rsp                ; save rsp
        call    itodecs
        mov     rsi, rax                ; move return value to argument
        dec     edx                     ; subtract NUL terminator from length
        and     rax, -16                ; align the stack
        mov     edi, STDOUT             ; output file
        mov     rsp, rax                ; grow stack to preserve string
        mov     eax, SYS_write
        syscall
        mov     rsp, rbp                ; restore rsp
        pop     rbp                     ; restore rbp
        ret

; Print string [RDI], followed by a newline.
export_function puts
puts:
        push    rbp
        call    print
        test    eax, eax
        js      .done
        mov     edi, 0Ah
        call    putchar
        pop     rbp
.done:  ret

; Read at most EDI - 1 bytes from stdin into [RSI], but at most up to
; the first newline character. Returns a pointer to the start of the
; NUL-terminated string, or NULL if nothing was read, in RAX, and a
; a pointer to the terminating NUL byte in RDX.
export_function getln
getln:
        mov     ebx, edi                ; buffer size
        push    rsi                     ; save start position
        dec     ebx                     ; leave room for NUL terminator
        mov     edi, STDIN              ; file
.getch: dec     ebx                     ; decrement remaining buffer size
        js      .done
        mov     edx, 1                  ; length
        mov     eax, SYS_read           ; syscall
        syscall
        cmp     eax, 0                  ; check read success
        jle     .done
        movzx   eax, byte [rsi]          ; the byte just read
        inc     rsi                     ; increment buffer
        cmp     al, 0Ah                 ; test for newline
        jne     .getch
.done:  mov     [rsi], byte 0           ; NUL terminator
        mov     rdx, rsi                ; return end pointer
        pop     rax                     ; return ptr to start
        cmp     rax, rsi                ; check if anything was read
        jne     .end
        xor     eax, eax                ; return NULL if nothing was read
 .end:  ret

;; STRING

; Convert a signed integer into a decimal string allocated
; dynamically on the stack. The start address is returned in
; RAX, and the length of the output (including NUL terminator)
; is returned in RDX. Note that calling another function may
; overwrite the string on the stack, unless RSP is first
; advanced to at least `(RAX & -16)`.
global itodecs
itodecs:
        mov     rax, rdi                ; argument into rax
        push    rbp                     ; save rbp
        xor     edx, edx                ; limit to 64-bit (div uses 128-bit)
        mov     rbp, rsp                ; save rsp
        mov     esi, 10                 ; base (div needs a register as argument)

        dec     rsp                     ; place output on the stack
        mov     [rsp], byte 0           ; NUL terminator

        test    rax, rax                ; check for sign
        jns     .digit                  ; no sign
        neg     rax                     ; remove sign (add to output later)

.digit: dec     rsp                     ; "allocate" next byte
        div     rsi                     ; divide by base
        add     dl, '0'                 ; convert remainder to digit
        mov     [rsp], dl               ; append digit to output
        xor     edx, edx                ; clear remainder (for next division)
        test    eax, eax                ; check if there are more digits
        jnz     .digit

        test    rdi, rdi                ; check original for sign
        jns     .done                   ; no sign, done
        dec     rsp
        mov     [rsp], byte '-'         ; append sign to output

.done:  mov     rax, rsp                ; return string
        mov     rdx, rbp                ; start position
        mov     rsp, rbp                ; restore rsp
        sub     rdx, rax                ; end - start = length
        pop     rbp                     ; restore rbp
        ret

; Parse decimal unsigned integer from the prefix of string [RDI].
; Returns the integer in RAX and an end pointer in RDX.
export_function parseuint
parseuint:
        xor     eax, eax                ; result
.read:  movzx   edx, byte [rdi]          ; get next character
        sub     dl, '0'                 ; convert digit to its value
        cmp     dl, 9                   ; check range
        ja      .done                   ; not a digit
        imul    rax, 10                 ; multiply previous result
        inc     rdi                     ; advance pointer
        add     rax, rdx                ; add this digit to least significant position
        jmp     .read
        mov     rdx, rdi                ; return end pointer
.done:  ret

; Parse a decimal signed integer from the prefix of string [RDI].
; Returns the integer in RAX and an end pointer in RDX.
export_function parseint
parseint:
        xor     eax, eax                ; result
        xor     ecx, ecx                ; sign (non-zero = negative)
        movzx   edx, byte [rdi]         ; get the first character
        cmp     dl, '-'                 ; check for leading minus
        jne     .parse                  ; not a minus, parse as a digit
        inc     rdi                     ; next byte
        inc     cl                      ; save the negative sign for later
.read:  movzx   edx, byte [rdi]         ; get next character
.parse: sub     dl, '0'                 ; convert digit to its value
        cmp     dl, 9                   ; check range
        ja      .sign                   ; not a digit
        imul    rax, 10                 ; multiply previous result
        inc     rdi                     ; advance pointer
        add     rax, rdx                ; add digit to least significant position
        jmp     .read
.sign:  test    cl, cl                  ; check for negative sign
        jz      .done                   ; no sign
        neg     rax                     ; apply negative sign
.done:  mov     rdx, rdi                ; return end pointer
        ret

; Returns a pointer to the first non-space character in the string [RDI].
; Uses no other registers except RDI and RAX, which will both contain the
; return value on return.
global skipspace
skipspace:
        dec     rdi
.next:  inc     rdi
.read:  movzx   eax, byte [rdi]         ; read byte
        cmp     eax, ' '                ; check for space
        je      .next
        sub     eax, 0Ah                ; check for newline
        jz      .next
        inc     eax                     ; check for tab
        jz      .next
.done:  mov     rax, rdi                ; return position
        ret

; Like `parseint`, but also skips leading whitespace and + sign.
export_function atol
export_function atoi
atoi:
        push    rbp                     ; align stack
        call    skipspace               ; skip any leading whitespace
        movzx   eax, byte [rdi]
        cmp     eax, '+'                ; check for + sign
        jne     .parse
        inc     rdi                     ; skip + sign
.parse: call    parseint
        pop     rbp                     ; restore stack
        ret

; Like `parseuint`, but also skips leading whitespace.
export_function atoul
export_function atou
atou:
        push    rbp                     ; align stack
        call    skipspace               ; skip any leading whitespace
        call    parseuint
        pop     rbp                     ; restore stack

; Find the length of the NUL-terminated string [RDI].
export_function strlen
strlen:
        xor     ecx, ecx                ; ecx = 0
        xor     eax, eax                ; look for zero byte
        cld                             ; clear direction
        not     rcx                     ; rcx = (unsigned) -1
        repne scasb                     ; scan [edi] until zero (eax), count backwards in ecx
        mov     rax, rcx                ; rax = (-1 - len - 1)
        inc     rax                     ; -> -1 - len
        not     rax                     ; -> len
        ret

; Copy the NUL-terminated string from [RSI] to [RDI].
export_function strcpy
strcpy:
        cld
        push    rdi                     ; save destination pointer
.copy:  lodsb                           ; al = [rsi++]
        test    al, al                  ; check for end
        stosb                           ; [rdi++] = al
        jnz     .copy                   ; repeat until NUL
        pop     rax                     ; return destination pointer
        ret

; Copy RDX bytes from [RSI] to [RDI].
export_function memcpy
memcpy:
        push    rdi                     ; save destination pointer
        cld
        mov     rcx, rdx                ; move length argument
        rep movsd                       ; copy RCX bytes
        pop     rax                     ; return destination pointer
        ret

; Set RDX bytes in [RDI] to SIL.
export_function memset
memset:
        push    rdi                     ; save destination pointer
        cld
        mov     rcx, rdx                ; move length argument
        mov     eax, esi                ; move byte argument
        rep stosb
        pop     rax                     ; return destination pointer
        ret

; Compare the strings [RDI] and [RSI], return negative, zero, or
; positive when [RDI] is less than, equal, or greater than [RSI].
export_function strcmp
strcmp:
.next:  movzx   eax, byte [rdi]         ; load byte from 1st string
        movzx   ecx, byte [rsi]         ; load byte from 2nd string
        inc     rdi                     ; ++rdi
        inc     rsi                     ; ++rsi
        sub     eax, ecx                ; calculate difference at this point
        jnz     .done                   ; end if different
        test    cl, cl                  ; check for NUL terminator
        jnz     .next                   ; continue if the strings didn't end
.done:  movsx   rax, eax                ; sign-extend result for convenience
        ret

;; STDLIB

; Generate a 64-bit random number.
; This is a xorshift64* generator, which should be considerably faster
; and better than a typical C standard library PRNG, while not being
; super-sensitive to the quality of seeding.
export_function rand64
rand64:
        mov     rax, [rel randstate]            ; x = state
        mov     rdx, rax
        shr     rdx, 12
        xor     rax, rdx                        ; x ^= x >> 12
        shl     rax, 25
        xor     rdx, rax                        ; x ^= x << 25
        shr     rdx, 27
        xor     rax, rdx                        ; x ^= x >> 27
        mov     [rel randstate], rax            ; save state
        mov     rdx, randmult
        mul     rdx                             ; x * randmult
        ret

; Generate a 30-bit random number.
; This is done by discarding the lower bits of `rand64`,
; which should in fact improve the quality of randomness.
export_function rand
rand:
        call    rand64                  ; generate 64-bit random number
        shr     rax, 34                 ; truncate to 30 bits
        ret

; Generate a uniform random number in [0, RDI).
; This is done by "re-rolling" `rand64` until the result is in
; the maximal range divisible by the upper bound.
export_function randuniform
randuniform:
        mov     rax, rdi                ; rax = n (upper bound)
        xor     edx, edx                ; don't do 128-bit division
        push    rbp                     ; use rbp to save the min value
        cmp     rax, 1                  ; check for invalid values
        jbe     .done                   ; return 0 if n <= 1
        neg     rax                     ; rax = -n
        sub     rsp, 16                 ; allocate space + align
        div     rdi                     ; rdx = -n % n
        mov     [rsp+8], rdi            ; [rsp+8] = n
        mov     rbp, rdx                ; rbp = (MAX - n) % n
.rand:  call    rand64                  ; rax = rand64()
        cmp     rax, rbp                ; avoid modulo bias
        jb      .rand                   ; re-roll if rax < ((MAX - n) % n)
        mov     rcx, [rsp+8]            ; rcx = n
        xor     edx, edx                ; don't do 128-bit division
        div     rcx                     ; divide by n
        add     rsp, 16                 ; restore stack
 .done: mov     rax, rdx                ; return the remainder (% n)
        pop     rbp                     ; restore rbp
        ret

; Seed the random number generator.
export_function srand
srand:
        mov     rax, randmult           ; multiply seed to increase bit count
        mul     rdi
        mov     rdx, randseed
        xor     rax, rdx                ; xor with the default seed
        jnz     .done                   ; check for zero
        mov     rax, rdx                ; use default seed if zero
.done:  mov     [rel randstate], rax
        ret
