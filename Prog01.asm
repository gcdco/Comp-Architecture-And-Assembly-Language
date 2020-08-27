 TITLE Program 01     (Prog01.asm)

; Last Modified: July 4, 2020
; Course number/section: 
; Assignment Number: Assignment 01        
; Due Date: July 5, 2020
; Description: 
	;Write and test a MASM program to perform the following tasks:
	;1. Display your name and program title on the output screen.
	;2. Display instructions for the user.
	;3. Prompt the user to enter two numbers.
	;4. Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
	;5. Display a terminating message.

INCLUDE Irvine32.inc

.data

nameTitle		BYTE	"Assignment #1: Elementary Arithmetic	by George Duensing", 0
instructions	BYTE	"Enter two integers to calculate the sum, difference, product, quotient and remainder.", 0
prompt_1		BYTE	"Enter number one: ", 0
prompt_2		BYTE	"Enter number two: ", 0
numOne			DWORD	? ; integer 1 to be entered by user
numTwo			DWORD	? ; integer 2 to be entered by user
sum				DWORD	? ; variable to hold the sum
difference		DWORD	? ; variable to hold the difference
product			DWORD	? ; variable to hold the product
quotient		DWORD	? ; variable to hold the quotient
remainder		DWORD	? ; variable to hold the remainder
sumLabel		BYTE	" + ", 0
diffLabel		BYTE	" - ", 0
productLabel	BYTE	" * ", 0
quotientLabel	BYTE	" / ", 0
equalLabel		BYTE	" = ", 0
remainderLabel	BYTE	" remainder ", 0
goodbye			BYTE	"Thank you and goodbye!", 0
;EC Variables
ecLabelOne		BYTE	"**EC: Program asks user if they want to repeat calculations.", 0
ecLabelTwo		BYTE	"**EC: Program verifies second number less than first.", 0
prompt_again	BYTE	"Do you want to continue? 1 for Yes, 0 for no: ", 0
prompt_ecTwo	BYTE	"The second number must be less than the first!", 0
rpt 			DWORD	? ; if =1 repeat, else stop


.code
main PROC
;Introduction
	;Display name and program title on the screen
	mov		edx, OFFSET nameTitle
	call 	WriteString
	Call 	CrLf

	;Display Extra Credit Notice
	call	CrLf
	mov		edx, OFFSET ecLabelOne
	call	WriteString
	Call	CrLf
	mov		edx, OFFSET ecLabelTwo
	call	WriteString
	Call	CrLf

	;Display Instructions
	call	CrLf
	mov		edx, OFFSET instructions
	call	WriteString
	call	CrLf

;Label for looping	
Start:

;Prompt the user for two numbers and store in variables
	call	CrLf
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		numOne, eax
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	mov		numTwo, eax
	call	CrLf

;Verify the second number is less than the first
	mov		eax, numTwo
	cmp		eax, numOne
	jg		EC2	;jump to EC2 if numTwo > numOne

;Calculate the sum
	mov		eax, numOne
	add 	eax, numTwo
	mov		sum, eax
	 
;Calculate the difference
	mov		eax, numOne
	sub		eax, numTwo
	mov		difference, eax
	
;Calculate the product
	mov		eax, numOne
	mov		ebx, numTwo
	mul		ebx
	mov		product, eax
	
;Calculate the quotient and remainder
	mov		edx, 0		;From lecture
	mov		ebx, numTwo	;divisor
	mov		eax, numOne ;dividend
	div		ebx
	mov		quotient, eax
	mov		remainder, edx

	
;Display the results
	;Display sum
	mov		eax, numOne
	call	WriteDec
	mov		edx, OFFSET sumLabel
	call	WriteString
	mov		eax, numTwo
	call	WriteDec
	mov		edx, OFFSET equalLabel
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf
	
	;Display difference
	mov		eax, numOne
	call	WriteDec
	mov		edx, OFFSET diffLabel
	call	WriteString
	mov		eax, numTwo
	call	WriteDec
	mov		edx, OFFSET equalLabel
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf
	
	;Display product
	mov		eax, numOne
	call	WriteDec
	mov		edx, OFFSET productLabel
	call	WriteString
	mov		eax, numTwo
	call	WriteDec
	mov		edx, OFFSET equalLabel
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf
	
	;Display quotient & remainder
	mov		eax, numOne
	call	WriteDec
	mov		edx, OFFSET quotientLabel
	call	WriteString
	mov		eax, numTwo
	call	WriteDec
	mov		edx, OFFSET equalLabel
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET	remainderLabel
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

;Ask if the user wants to go again and repeat
	call	CrLf
	mov		edx, OFFSET prompt_again
	call 	WriteString
	call	ReadInt
	mov		rpt, eax
	cmp		rpt, 1
	je		Start	;yes? jump to Start
	jne		byebye	;no? jump to byebye

;Jump to EC2 if numTwo > numOne
EC2:
	mov		edx, OFFSET prompt_ecTwo
	call	WriteString
	call	CrLf

;Display a goodbye message
byebye:
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
