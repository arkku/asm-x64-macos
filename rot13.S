BITS 64

SECTION .data
SECTALIGN 16

alphalen equ ('z' - 'a') + 1

SECTION .text
SECTALIGN 16

global _main
extern getchar, putchar, atoi

; Rotates alpha (a-z) characters from stdin by 13, or custom amount
; specified on command-line, outputs to stdout.
;
; int main(int argc, char *argv[])
_main:  push    rbp                     ; (align stack to 16 bytes)
        mov     ebx, -13                ; rotation amount (always non-positive)

; read custom rotation amount from command-line, if given
        cmp     edi, 2                  ; argc >= 2
        jl      .read
        mov     rdi, [rsi+8]            ; first command-line argument
        call    atoi                    ; parse integer from argument
.scaleup:
        add     eax, alphalen
        js      .scaleup                ; scale negative amounts to positive
.scaledown:
        sub     eax, alphalen
        jg      .scaledown              ; scale to max 26
        mov     bx, ax                  ; the rotation amount is now -26...0

; read and rotate character-by-character until EOF
.read:  call    getchar
        test    eax, eax                ; check for EOF
        js      .end
        mov     edi, eax                ; copy original character

; check the type of character
        or      al, 20h                 ; convert to lowercase (if alpha)
        sub     al, 'a'                 ; convert to index in alphabet (if alpha)
        cmp     al, alphalen            ; check if the character is alpha
        jae     .print                  ; non-alpha, print original (in edi)
; rotate
        add     dil, bl                 ; rotate the original
        add     al, bl                  ; rotate the copy to detect wrap-around
        jns     .print                  ; detect wrap-around from negative sign
        add     dil, alphalen           ; correct wrap-around

.print: call    putchar
        jmp     .read

.end:   xor     eax, eax
        pop     rbp
        ret

;%include "mac64io.asm"
