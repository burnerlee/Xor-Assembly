
section .data
	message1 db "Enter the message to be encoded",0xa
	length1 equ $ - message1
	message2 db "Enter the xor key",0xa
	length2 equ $ - message2
	message3 db "The encoded message is",0xa
	length3 equ $ - message3
section .bss					;section for declaring the dynamic variables which will be initialised by the user
	string resb 100
	xor_string resb 100
section .text					
main:
	global _start
_start:
	mov eax,4				;display message
	mov ebx,1
	mov ecx,message1
	mov edx,length1
	int 0x80
	mov eax,3				;taking input of the string the user wants to decode
	mov ebx,0
	mov ecx,string
	mov edx,100
	int 0x80
	mov esi,ecx				;storing the address of this input -> 'string' in the esi register for further use
	sub ax,1				;the eax stores the value of the length of the string, which has size of less than 1 byte, so value of ax also gives me the value of string 
						;length in a register of just 16 bits. And then i subtract 1 from this ax -> 16 bit register to get the actutal string length and remove the
						;extra count due to the string terminating character
	mov bp,ax				;now i store this value of ax in another 16 bit register bp for further use as eax will be manipulated in further processes

	mov eax,4				;display message
	mov ebx,1
	mov ecx,message2
	mov edx,length2
	int 0x80 
	
	mov eax,3				;taking the second input from the user which is actually the xor key
	mov ebx,0
	mov ecx,xor_string
	mov edx,100
	int 0x80

	mov edi,ecx				;storing the address of xor_string from ecx to edi for further use as ecx will be manipulated
	sub eax,1				;subtracting 1 from eax to get the actual string length again. note here that the it could also have been subtracted from ax or al as the size
						;of data stored in eax is less than 1 byte
	mov bl,al				;storing the data from the al register which is a 8 bit register in another 8 bit register-> bl for further use.I am storing data in registers
						;of these specific sizes for now because i'll need to use registers of specific sizes with this data for operations ahead, we'll see
	mov ax,bp				;moving value of bp in ax, we had stored length of message string in it which now is also stored in 16 bit ax register
	div bl					;diving by bl, here value in ax is divided by value in bl and quotient is stored in al and remainder in ah, hence i divide the total length of
						;message by the length of the xor key hence i get the number of groups totally covered by the xor key in the message and remainder gives the
						;number of characters which would be left in the message string
	sub ecx,ecx				;clearing the value in ecx register to 0
	cmp ah,0x00				;compare if the remainder value was 0
	je work					;if it was jump to skip label otherwise continue
	mov cl,ah				;move value of ah in cl, to run a loop number of times equal to the remainder
	add esi,ebp				;add ebp which is the message string length to esi that is address of the string message, this takes us to next address of last character of
						;the message string 
	l1:					;label l1
	sub esi,ecx				;subtracting value of counter register from esi which corressponds to address of all the remainder elements, as loop cycles value of ecx 
						;decreases and thus the value of esi decreases and we move from left to right in the string
	mov dl,byte[edi]			;move the character at address of esi into dl
	xor byte [esi],dl			;taking xor of character present at the address esi with the character stored in dl
	add esi,ecx				;revert back value of esi to one at the starting of loop l1 after the process to correspond to each character in order
	add edi,1				;adding 1 to edi to move ahead in xor_string and correspond to the next character each times the loop runs
	loop l1					;call l1 if the value of ecx is >1
	sub esi,ebp				;revert esi to the initial value by reversing the changes we had made so that now it once again corresponds to the first character of the 
						;message string
	work:					;work label
	mov esp,esi				;mov value of esi in esp as backup as we would need this address in the end to print the result
	mov cl,al				;move the value of al into cl, al stores the value of quotient, so now cl stores it, or i can say ecx stores it
	sub al,al				;clearing the value of al to 0
	mov al,ah				;moving value of ah to al
	sub ah,ah				;clearing value of ah to 0
	sub edi,eax				;now this along with the above 3 lines is something I should elaborate.When I came out the loop l1 the edi address was pointing at some 
						;further element of xor_string depending on the number of remainder elements. I need to bring it back to the first character. So i would sub
						;the value of remainder from current value of edi and store it back in edi. The value of remainder is stored in ah register, but its a 8 bit 
						;register. To have operations with edi i need to define a 32 bit register as the second operand. so i use the eax register. but the value 
						;should be equal to the value in ah register. so to make a kind of right shift of values in such a way that in eax only al stores value equal
						;remainder and rest all bits are 0, which will make eax value equal to remainder.8 right shift bits would have also worked
	l2:					;label l2
	mov dl,cl				;dl stores value of cl, cl had the value of quotient
	mov cl,bl				;cl stores value of bl, bl had the length of xor_string
	l3:					;label l3
	mov dh,byte[edi]			;mov value of character at edi into dh
	xor byte[esi],dh			;taking xor of character at esi with value in dh
	add edi,1				;increasing the address of edi
	add esi,1				;increasing the address of esi
	loop l3					;run loop3, loop3 is a loop inside loop2 , these 2 loops work together to xor each character of each group with each corresponding xor_string
						;character
	mov cl,dl				;resetting the value of cl it achieved during the starting of loop 2 as it is manipulated by loop 3 and set to 0
	sub edi,ebx				;resetting the value of edi to point to first character of xor_string everytime the execution comes out of loop 3 as loop 2 corresponds to
						;each group and loop 3 corresponds to each character in each group
	loop l2					;call loop 2
	
	mov eax,4				;display message3
	mov ebx,1
	mov ecx,message3
	mov edx,length3
	int 0x80
	
	mov eax,4				;print the final string encoded 
	mov ebx,1
	mov ecx,esp				;we had stored address the message string in esp earlier and i told you i will use it in the end to print the final output, so here is the 
						;fulfilled promise
	mov edx,ebp				;ebp passed as parameter as length of the string
	int 0x80				;interrupt
	
	mov eax,1				;exit sys_call
	int 0x80
