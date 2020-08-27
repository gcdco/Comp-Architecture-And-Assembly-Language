TITLE Fibonacci Numbers     (Prog02.asm)

; Last Modified: July 12, 2020
; Course number/section: 
; Assignment Number: Assignment 02         Due Date: July 13, 2020
; Description:
;- Write a program to calculate Fibonacci numbers.
;	- Display the program title and programmer’s name. Then get the user’s name, and greet the user.
;	- Prompt the user to enter the number of Fibonacci terms to be displayed. Advise the user to enter an integer
;		in the range [1 .. 46].
;	- Get and validate the user input (n).
;	- Calculate and display all of the Fibonacci numbers up to and including the nth term. The results should be
;		displayed 5 terms per line with at least 5 spaces between terms.
;	- Display a parting message that includes the user’s name, and terminate the program.


INCLUDE Irvine32.inc

;Constants
LOWER_LIMIT = 1		;min number of terms
UPPER_LIMIT = 46	;max number of terms

.data

progTitle		BYTE	"Assignment #2: Fibonacci Numbers",0
programmer		BYTE	"Programmed by George Duensing",0
userGreeting	BYTE	"Hello, ",0
userName		BYTE	29	DUP(0)	;input buffer
byteCount		DWORD	?			;holds counter
instructions_1	BYTE	"Enter the number of Fibonacci terms to be displayed",0
instructions_2	BYTE	"Give the number as an integer in the range [1 .. 46].",0
prompt_1		BYTE	"How many Fibonacci terms do you want? ",0
prompt_2		BYTE	"Out of range. Enter a number in [1 .. 46]",0
prompt_3		BYTE	"What's your name? ",0
goodbyeMSG		BYTE	"Goodbye, ",0
n				DWORD	?			;number of terms
count			DWORD 	0 			;number of terms printed, use for linespacing calculation
result			DWORD	?
ec_1			BYTE	"**EC: Display the numbers in aligned columns.", 0
column			BYTE	10			; Extra credit column counter - 10 takes into account line breaks up to getting integers which may need to be reprompted for invalid input
cursorX			BYTE	0			;Extra credit row counter


.code
main PROC

;Display Introduction
	mov		edx, OFFSET progTitle
	call	WriteString
	call	CrLf
	mov		edx, OFFSET programmer
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ec_1
	call	WriteString
	call	CrLf
	call	CrLf
	
;Get the User's Name
	mov		edx, OFFSET prompt_3
	call	WriteString
	mov		edx, OFFSET userName		;point to the buffer
	mov		ecx, SIZEOF userName		;specify max characters
	call	ReadString					;input the string
	mov		byteCount, eax				;number of characters

;Display Greeting
	mov		edx, OFFSET userGreeting
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf
	call	CrLf
	
;Display instructions
	mov		edx, OFFSET instructions_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions_2
	call	WriteString
	call	CrLf
	call	CrLf
	
;Get input and validate input
getN:
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	add		column, 1				;correct column for alignment calculations
	call	CrLf
	add		column, 1				;correct column for alignment calculations
	mov		n, eax					;n = number of terms to calculate
	cmp		n, LOWER_LIMIT			;check n >= 1
	jl		msg						;jump if n < 1, display error message and retry
	cmp		n, UPPER_LIMIT			;check n <= 46		
	jg		msg						;jump if n > 46, display error message and retry
	jmp		endN					;end loop if n is in range

msg:
	mov		edx, OFFSET prompt_2	;Out of Range message
	call	WriteString
	call	CrLf
	add		column, 1				;correct column for alignment calculations
	jmp		getN					;repeat n input

endN:

;Fibonacci calculation and output
	;Loop setup and register initialization
	mov		ecx, n
	mov		eax, 1					;leading value
	mov		ebp, 0					;preceding value
	
fibonacci:
	;Display Fibonacci number and spaces
	call	WriteDec
	call	positionCursor			;Set cursor for next output
	add		count, 1				;Update variable for linebreak calculation
	;Calculation
	mov		ebx, ebp				;Store preceding value for calculating new leading value
	mov		ebp, eax				;Set new preceding value
	add		eax, ebx				;Calculate next leading value
	call	lineBreak				;Determine if new line is needed
	loop	fibonacci
	call	CrLf

;Display goodbye
	call	CrLf
	mov		edx, OFFSET goodbyeMSG
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf


	exit	; exit to operating system
main ENDP


;-----------------------------------------------------
; lineBreak
; Determines if a line break is needed and does so
; Receives: ECX = the current loop count
; Returns: no return value
;-----------------------------------------------------
lineBreak PROC USES	eax edx ebx ecx
	;Check if new line is needed
	mov		edx, 0
	mov		ebx, 5		;divisor
	mov		eax, count	;dividend
	div		ebx
	cmp		edx, 0		;If remainder is 0, then 5 terms are on a line
	jne		notEqual	;Exit if new line not needed
	call	CrLf
	add		column, 1	;correct column for alignment calculations
notEqual:
	ret
lineBreak ENDP

;-----------------------------------------------------
; positionCursor
; Postions cursor for printing fibonacci numbers in aligned columns.
; Sets cursor to next x-/y-value
; Receives:	Uses cursorX and column variables
; Returns:	no return value
;-----------------------------------------------------
positionCursor PROC
	cmp		cursorX, 75			;5 numbers (max term 10 digits) w/ at least 5 spaces between
	jl		addTo
	mov		cursorX, 0			;New Column, reset cursorX
addTo:	
	add		cursorX, 15
	mov		dh, column			;Set y
	mov		dl, cursorX			;Set x
	call	Gotoxy
	ret
positionCursor ENDP


END main
