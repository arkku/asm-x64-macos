; C function arguments: RDI, RSI, RDX, RCX, R8, R9
; Return value in RAX, second in RDX

; Caller saves: RAX, RCX, RDX, RSI, RDI, R8-11
; Callee saves: RSP, RBX, RBP, R12-15

; System calls with `syscall`, number in RAX
; Overwrites RAX (return value), RCX and R11

; Align stack to 16 and restore without using additional registers
%macro align16_prologue 0
    push    rsp
    push    [rsp]
    and     rsp, -16
%endmacro

%macro align16_epilogue 0
    mov     rsp, [rsp+8]
%endmacro
