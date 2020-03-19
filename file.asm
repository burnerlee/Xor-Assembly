section .data
	message db "Enter the character",0xa	;initialising 4 variables in the data section, 2 are messages and 2 are messages' lengths
	len equ $ - message
	message2 db "Enter the string",0xa
	len2 equ $ - message2
section .bss
	xor_char resb 100			;initialising 2 variables in bss section - The character and the input string which would be provided by the user
    	input resb 100
section .text
    	global _start				;declaring the entry point for the linker to identify
main:						;declaring the function as main
	_start:					;declaring the start function
	mov eax,4				;using system call api to call SYS_write
	mov ebx,1				;using the STDout argument for the system call
	mov ecx,message				;passing the message as the argument for the system call
	mov edx,len				;passing the message length as the argument for the system call
	int 0x80				;interrupt command

	mov eax,3				;system call SYS_read
	mov ebx,2				;using the STDin argument for the system call
	mov ecx,xor_char			;storing the data in xor_char and storing its address in ecx
	mov edx,100				;declaring the max length of the input
	int 0x80				;interrupt command
	mov esi,ecx				;store address of this variable in some free register as ecx would come in further use

	mov eax,4				;code to display the next message
	mov ebx,1
	mov ecx,message2
	mov edx,len2
	int 0x80

	mov eax,3				;code to take String input and store it in the variable 'input'
	mov ebx,2
	mov ecx ,input
	mov edx,100
	int 0x80

	mov esp,ecx				;storing the address of 'input' variable in esp register
	mov ecx,eax				;storing the value of eax in ecx, eax stores the length of input given by the user, i am trying to store it in the ecx to run a loop
	sub ecx,1				;subtracting 1 from this ecx value as it stores the string length which is actually the string length plus one terminating byte so subtracting to get the actual string length
	mov al,[esi]				;storing the value stored at address of esi in al, esi stores the address of xor_char, so now al stores the value of xor_char, al is a one byte register 

	l1:					;defining a loop using l1 label, this would be governed by ecx which will run the loop eax-1 times, which is equal to actual length of string
	xor byte [esp+ecx-1],al			;esp stores address of the string, which is also the address of first character of the string, which means esp+1 would give address of second
						;character and esp+2 would give address of third and so on... to access these characters we can use [address] so using the loop variable ecx
						;loop takes all values from esp to esp+stringlength-1 and for each character it takes the xor with al, which stores the xor_char and stores it
						;back in esp itself
	loop l1					;calling loop l1, the execute goes back to l1 until ecx becomes 0

	mov ecx,esp				;mov value of esp in ecx, which is the address of the XORed value
	mov edx,100				;defining address of the string to pass as argument in the syscall
	mov eax,4				;calling syscall SYS_write
	mov ebx,1				;calling STDout
	int 0x80				;interrupt call

	mov eax,1				;SYS_exit syscall
    	int 0x80				;interrupt call
						
						;Thanks for reading

