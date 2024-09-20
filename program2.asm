section .data
hello: db '.'
helloLen: equ $-hello

section .text
global _start

_start:
mov ecx, 500000
ll:
	mov ebx, ecx
	mov rdi, 1
	mov rsi, hello
	mov rdx, helloLen
	mov rax, 1
	syscall

	mov ecx, ebx

loop ll

mov rdi, 0
mov rax, 60
syscall
