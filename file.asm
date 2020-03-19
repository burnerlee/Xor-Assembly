section .data
section .bss
    input resb 32
    xor_char resb 1
section .text
    global _start
_start:
    mov eax,3
    mov ebx,2
    mov ecx,input
    mov edx,32
    int 0x80
    mov eax,3
    mov ebx,2
    mov ecx,xor_char
    mov edx,1
    int 0x80   
    mov eax,4
    mov ebx,1
    mov ecx,input
    mov esp,ecx
    mov ecx,32
    l1:
    xor byte [esp+ecx-1],
    loop l1
   end:
    mov ecx,esp
    mov edx,32
    int 0x80
    mov eax,1
    int 0x80


