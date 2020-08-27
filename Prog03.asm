TITLE Composite Numbers    (Prog03.asm)

; Last Modified: July 26, 2020
; Assignment Number: Assignment 03         Due Date: July 27, 2020
; Description:
;  Write a program to calculate composite numbers. First, the user is instructed to enter the number of 
;  composites to be displayed, and is prompted to enter an integer in the range [1 .. 400]. The user 
;  enters a number, n, and the program verifies that 1 ≤ n ≤ 400. If n is out of range, the user is reprompted until s/he enters a value in the specified range. The program then calculates and displays 
;  all of the composite numbers up to and including the nth composite. The results should be displayed 
;  10 composites per line with at least 3 spaces between the numbers.


INCLUDE Irvine32.inc

UPPER_LIMIT = 400
LOWER_LIMIT = 1

.data

programTitle		BYTE	"Composite Numbers",0
programmerName		BYTE	"Programmed by George Duensing",0
instruction_1		BYTE	"Enter the number of composite numbers you would like to see.",0
instruction_2		BYTE	"The range is from 1 to 400 composites",0
prompt_1			BYTE	"Enter the number of composites to display [1 .. 400]: ",0
prompt_2			BYTE	"Out of range. Try again.",0
goodbye_1			BYTE	"Thank you, Goodbye!",0
n					DWORD	?			;number of composites to display
spaces				BYTE	"   ",0
ec_1				BYTE	"**EC: Align the output columns.",0
ec_2				BYTE	"**EC: Display more composites one page at a time.",0
ec_2_prompt_1		BYTE	"Would you like to display more numbers? (y/n): ",0
ec_2_prompt_2		BYTE	"Press enter key to continue...",0
row					BYTE	10				;Extra credit row counter - takes into account line breaks up to getting integers which may need to be reprompted for invalid input
cursorX				BYTE	0			;Extra credit column counter


.code
main PROC

	;Introduction
	call	introduction

showMore:
	;Get user data > validate
	call	getUserData	
	;Show Composites > isComposite
	push	eax						;number of composites to find
	push	n						;number to start search from/ last composite found
	call	showComposites		
	mov		n, esi					;last composite number found
	call	showMoreComposites
	cmp		al, 'y'
	jne		sayGoodbye
	call	Clrscr
	mov		row, 3					;reset row for cursor positioning
	mov		cursorX, 0
	jmp		showMore
	
sayGoodbye:
	;Goodbye
	call	goodBye

	exit							;exit to operating system

main ENDP

;----------------------------------------------------------------------------------------------------------
introduction PROC USES edx
;
; Display the introductory text messages
;
; preconditions: none
;
; postconditions: none
;
; Receives: nothing
;
; Returns: nothing
;----------------------------------------------------------------------------------------------------------
	mov		edx, OFFSET programTitle
	call	WriteString
	call 	CrLf
	mov		edx, OFFSET programmerName
	call	WriteString
	call 	CrLf
	call 	CrLf
	mov		edx, OFFSET instruction_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instruction_2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_2
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP

;----------------------------------------------------------------------------------------------------------
showComposites PROC
;
; Main loop for showing desired number of composite numbers. Calls procedure isComposite and passes an 
; integer to check for primeness. If the number is not prime, then it is composite. showComposites then
; prints the integer if it is a composite number. Returns the last composite number found in esi to show
; additional composite numbers.
;
; preconditions:	
;	1. push a positive integer onto the stack to find that many composite numbers
;	2. push a positve integer onto the stack to start the search from that number for composite numbers
;
; postconditions:	Uses ecx, ebx, edx, esi and leaves them changed. Returns esi.
;
; Receives: 
;	n_param - [ebp + 8]: number of composites to show
;	starting_number - [ebp +12]: number to start searching from
;
; Returns: esi: last composite number found
;----------------------------------------------------------------------------------------------------------
	n_param	EQU [ebp + 12] 							;number of composites to find
	starting_number EQU [ebp + 8]					;where to start looking
	push	ebp										
	mov		ebp, esp								
	sub		esp, 8									
	numbOfComposites_local 	EQU DWORD PTR [ebp - 4]	;number of composites found
	counter_local			EQU DWORD PTR [ebp - 8]	;current number to check if it is a composite
	
	mov		numbOfComposites_local, 0
	mov		edi, starting_number
	mov		counter_local, edi
	mov		ecx, n_param							
	mov		ebx, counter_local						
displayComposites:
	;check if the number is composite
	push	ecx										;save ecx as isComposite modifies it
	inc		counter_local							;Increment next number to check
	mov		ebx, counter_local
	push	ebx
	call	isComposite
	pop		ecx										;restore ecx
	cmp		esi, 1									;check if composite
	jne		notComposite
	inc		numbOfComposites_local					;update count for linebreak procedure
	mov		eax, counter_local
	call	positionCursor							
	call	WriteDec
	push	numbOfComposites_local
	call	lineBreak
	jmp		composite
	
notComposite:										
	inc		ecx										;increment ecx to adjust for not finding a composite

composite:
	loop	displayComposites
	
	mov		esi, counter_local						;return last number displayed
	mov		esp, ebp								
	pop		ebp										
	ret		8										;clean up stack from callee pushing parameter on stack
showComposites ENDP


;----------------------------------------------------------------------------------------------------------
isComposite PROC
;
; The procedure initially checks whether the passed integer is <= three which makes it
; a prime number. It then checks if the number is divisible by 2 or 3 and if so returns 1 for composite. 

; This procedure uses the 6k +/- 1 method to check for primality by computing the prime numbers
; from 7 on. The loop starts with i_local = 5,checking for divisibility by 5's and then
; procedes to add 6 to i_local each iteration while also checking i_local + 2 each iteration.
; This then allows it to check divisibility against prime numbers. The loop ends when i_local * i_local
; is greater than the number we are checking for compositeness 
; (after square root of the number we are checking, the factors are mirrored and no need to check them). 

;reference:
;	https://en.wikipedia.org/wiki/Composite_number
;	https://en.wikipedia.org/wiki/Primality_test
; 
; preconditions:	push positive integer onto stack to check for compositeness
;
; postconditions:	Uses: eax, ebx, edx, ecx and changes them
;
; Receives: 
;	n_local - [ebp + 8]: number to check for compositeness
;
; Returns: esi: composite number = 1; prime = 0
;----------------------------------------------------------------------------------------------------------
	n_local	EQU	[ebp + 8]
	push	ebp					
	mov		ebp, esp
	
	;declare locals
	sub		esp, 4								;reserve space for locals
	i_local		EQU	DWORD PTR	[ebp - 4]
	
	;check if <=3 or divisible by 2 or 3
	mov		eax, n_local
	cmp		eax, 3								;if n <= 3 it is prime
	jle		notComposite
	cdq							
	mov		ebx, 2
	div		ebx
	cmp		edx, 0								;if n is divisible by 2 it is composite
	je		itIsComposite
	mov		eax, n_local
	cdq
	mov		ebx, 3
	div		ebx									
	cmp		edx, 0								;if n is divisible by 3 it is composite
	je		itIsComposite

	;Set-up for primalityCheck
	mov		i_local, 5
	mov		ecx, n_local

primalityCheck:
	mov		eax, i_local
	mul		i_local
	cmp		eax, n_local 						;check if we have reached the end condition for loop
	jg		notComposite
	mov		eax, n_local
	cdq
	div		i_local								;check against prime divisor
	cmp		edx, 0
	je		itIsComposite
	mov		eax, n_local
	mov		ebx, i_local
	add		ebx, 2								;set-up next prime divisor
	cdq
	div		ebx
	cmp		edx, 0								;check next prime divisor
	je		itIsComposite
	add		i_local, 6							;set-up next prime divisor
	loop	primalityCheck

itIsComposite:
	mov		esi, 1								;it is composite
	jmp		theEnd
	
notComposite:
	mov		esi, 0								;it is not composite

theEnd:
	
	mov		esp, ebp				
	pop		ebp						
	ret		4									;clean up stack from calling procedure passed paramater
isComposite ENDP


;----------------------------------------------------------------------------------------------------------
getUserData PROC 
;
; Get the user input and call validate procedure to check if input is in range 
;
; preconditions:	none
;
; postconditions:	uses edx, ebx and changes them
;
; Receives: nothing
;
; Returns:  eax: the number within a specified range
;----------------------------------------------------------------------------------------------------------
	;Local Varibles
	inRange_local	EQU	DWORD PTR [ebp - 4]
	
	push	ebp
	mov		ebp, esp
	sub		esp, 4
	
;Get input and validate input
getInput:
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	call	CrLf
	push	eax							;pass n as paramater: clean up stack in sub-procedure
	call	validate					
	mov		inRange_local, ebx			;return value from validate									
	cmp		inRange_local, 1			; 1 = in range
	je		endGetInput
	jmp		errorMsg							
	

errorMsg:
	mov		edx, OFFSET prompt_2		
	call	WriteString
	call	CrLf
	add		row, 3						;correct row for alignment calculations
	jmp		getInput					

endGetInput:
	mov		esp, ebp					;remove locals from stack
	pop		ebp							
	ret
getUserData ENDP


;----------------------------------------------------------------------------------------------------------
validate PROC 
;
; Check whether user input is within range of >= LOWER_LIMIT AND <= UPPER_LIMIT
; [LOWER_LIMIT, UPPER_LIMIT]
;
; preconditions:	move number to validate into eax and push onto stack
;
; postconditions:	Uses eax and changes it. Returns true/false in ebx
;
; Receives: 
;	n_param - [ebp + 8]: number to validate
;
; Returns: ebx: 1 = in range; 0 = out of range
;----------------------------------------------------------------------------------------------------------
	n_param	EQU [ebp + 8]				
	push	ebp							
	mov		ebp, esp					
	
	mov		eax, n_param
	cmp		eax, LOWER_LIMIT			;check n >= LOWER_LIMIT
	jl		outOfRange						
	cmp		eax, UPPER_LIMIT			;check n <= UPPER_LIMIT		
	jg		outOfRange
	mov		ebx, 1						;Value is in range
	jmp		theEnd

outOfRange:
	mov		ebx, 0						;Value is not in range

theEnd:
	pop		ebp							
	ret		4							
validate ENDP

;----------------------------------------------------------------------------------------------------------
showMoreComposites PROC USES edx
;
; Ask the user if they want to show more composite numbers and read/ return a character
;
; preconditions:	none
;
; postconditions:	changes value in al
;
; Receives:	nothing 
;
; Returns: 	al: character
;----------------------------------------------------------------------------------------------------------
	call	CrLf
	call	CrLf
	mov		edx, OFFSET ec_2_prompt_1
	call	WriteString
	call	ReadChar
	call	CrLf
	push	eax
	mov		edx, OFFSET ec_2_prompt_2
	call	WriteString
	call	ReadInt
	pop		eax
	ret
showMoreComposites ENDP

;----------------------------------------------------------------------------------------------------------
goodBye PROC
;
; Displays goodbye message to user
;
; preconditions:	none
;
; postconditions:	changes edx
; 
; Receives:	nothing
;
; Returns: 	nothing
;----------------------------------------------------------------------------------------------------------
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye_1
	call	WriteString
	ret
goodBye ENDP

;----------------------------------------------------------------------------------------------------------
lineBreak PROC
;
; Determines if a line break is needed based on number of integers printed on a line and does so.
; Re-purposing procedure from Prog02
;
; preconditions:	push number of integers printed onto stack
;
; postconditions:	new line
;
; Receives: 
;	count - [ebp + 8]: 	The number of integers currently printed on a line
;	row - global:	The current y-value of the cursor
;	cursorX - global:	The current x-value of the cursor
;
; Returns: no return value
;----------------------------------------------------------------------------------------------------------
	count EQU	[ebp + 8]

	push	ebp
	mov		ebp, esp	

	;Check if new line is needed
	mov		edx, 0
	mov		ebx, 10			;divisor: number of integers to print on a line
	mov		eax, count		;dividend
	div		ebx
	cmp		edx, 0		
	jne		notEqual	
	call	CrLf
	add		row, 1		;correct row for alignment calculations
notEqual:
	pop		ebp
	ret		4				;clean stack from calling procedure
lineBreak ENDP

;----------------------------------------------------------------------------------------------------------
positionCursor PROC USES edx
;
; Positions cursor so that columns are aligned for printing. Sets cursor to next x-/y-value
; Using procedure from Prog02
;
; preconditions:	Update row variable when printing a new line or blank line
;
; postconditions:	Sets new position for cursor
;
; Receives:	
;	cursorX - global: cursor x-value
;	row - global: cursor y-value
;
; Returns:	no return value
;----------------------------------------------------------------------------------------------------------
	cmp		cursorX, 77			;Check if cursor x-position needs to be reset
	jl		addTo
	mov		cursorX, 0			;New row, reset cursorX
	
addTo:	
	add		cursorX, 8			;5 units for integer, and 3 units for space between integer
	mov		dh, row			;Set y
	mov		dl, cursorX			;Set x
	call	Gotoxy
	ret
positionCursor ENDP

END main