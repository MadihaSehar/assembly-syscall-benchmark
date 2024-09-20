section .data
hello: db '.'          ; Define the character to be printed
helloLen: equ 1        ; Length of the character

section .text
global _start

_start:
    mov ecx, 10    ; Initialize loop counter

ll:
    mov esi, ecx       ; Save loop counter in esi
    mov eax, 4         ; Syscall number for sys_write
    mov ebx, 1         ; File descriptor 1 (stdout)
    mov ecx, hello     ; Pointer to the string
    mov edx, helloLen  ; Length of the string
    int 80h            ; Make syscall

    mov ecx, esi       ; Restore loop counter

    loop ll            ; Decrement ecx and loop if not zero

    mov eax, 1         ; Syscall number for sys_exit
    mov ebx, 0         ; Exit code 0
    int 80h            ; Make syscall
