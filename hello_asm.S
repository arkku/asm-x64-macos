BITS 64

SECTION .data
SECTALIGN 16

msg: db      "Hello, world!", 0Ah, 00h
.len: equ    $ - msg - 1            ; $ is the current position

printf_int: db    "%ld", 0Ah, 00h

SECTION .text
SECTALIGN 16

global _main
extern print, putchar, getln, memcpy, strcpy, strcmp, printi, strlen
extern _printf

_main:
        push    rbp
        mov     rbp, rsp

.loop:  lea     rdi, [rel msg]
        call    print

        lea     rdi, [rel msg]
        call    strlen
        mov     esi, eax
        lea     rdi, [rel printf_int]
        call    _printf
        mov     esi, msg.len
        lea     rdi, [rel printf_int]
        call    _printf

        mov     rdi, -9223372036854775808
        call    printi
        mov     edi, 0Ah
        call    putchar

        sub     rsp, 128
.read:  mov     edi, 64
        lea     rsi, [rbp-64]
        call    getln
        test    rax, rax
        jz      .done
        mov     rsi, rax
        lea     rdi, [rbp-128]
        sub     rdx, rax
        inc     rdx
        call    memcpy
        lea     rsi, [rbp-128]
        lea     rdi, [rbp-64]
        call    strcpy
        lea     rdi, [rbp-64]
        call    print
        lea     rdi, [rbp-64]
        lea     rsi, [rel msg]
        call    strcmp
        movsx   rdi, eax
        call    printi
        mov     edi, 0Ah
        call    putchar
        jmp     .read

.done:
        mov     rsp, rbp
        pop     rbp
        xor     eax, eax                ; return value
        ret
