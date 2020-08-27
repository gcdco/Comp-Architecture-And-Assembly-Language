TITLE Designing Low-level I/O Procedures (Prog05.asm)

; Last Modified: August 10, 2020
; Assignment Number: Assignment 05         Due Date: August 10, 2020
; Description:
;	- Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
;	- Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from
;   	the user, and WriteString to display output.
;		-- getString should display a prompt, then get the user’s keyboard input into a memory location
;		-- displayString should the string stored in a specified memory location.
;		-- readVal should invoke the getString macro to get the user’s string of digits. It should then convert the
;			digit string to numeric, while validating the user’s input.
;		-- writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to
;			produce the output.
;	- Write a small test program that gets 10 valid integers from the user and stores the numeric values in an
;		array. The program then displays the integers, their sum, and their average.


INCLUDE Irvine32.inc

;Globals
ZERO_ASCII		= 48
NINE_ASCII		= 57
NULL_ASCII		= 00
STRING_SIZE_MAX	= 18	;Larger size to test error checking (with much larger values) in conversion procedure
MULTIPLIER		= 10
DIVISOR			= 10



;;----------------------------------------------------------------------------------------------------------
getString MACRO mPrompt, mInput, mInputSize, mCount 
;;
;; Display a prompt, then get the user’s keyboard input into a memory location
;;
;; preconditions: Pass arguments to macro
;;
;; postconditions: 
;;	1. Store user inputted string into address at mInput. 
;;	2. Store length of string in address held in mCount
;;	3. No registers changed.
;;
;; Receives: 
;;	mPrompt - Address of prompt to display to the user
;;	mInput	- Address of BYTE array to hold user inputted string
;;	mInputSize - Allowed number of characters for readString to read
;;	mCount	- Address of Variable to hold length of user string input
;;----------------------------------------------------------------------------------------------------------
	;Save Registers
	pushad
	
	;Display prompt to user
	mov		edx, mPrompt
	call	WriteString
	
	mov		esi, mInput
	mov		edi, mCount
	
	mov		edx, esi
	mov		ecx, mInputSize
	call	ReadString
	mov		[edi], eax
	
	;Restore Registers
	popad
ENDM

;;----------------------------------------------------------------------------------------------------------
displayString MACRO mStringIn
;; 
;; Display the string stored in a specified memory location.
;;
;; preconditions: Pass argument OFFSET of string to display
;;
;; postconditions: Registers left unchanged.
;;
;; Receives: 
;;	mStringIn - Address of string to display
;;----------------------------------------------------------------------------------------------------------
	pushad
		mov		edx, mStringIn
		call	WriteString
	popad
ENDM


.data
introduction_1		BYTE 	"Assignment 5: Designing low-level I/O procedures",0
introduction_2		BYTE 	"Programmed by George Duensing",0
instructions_1		BYTE 	"Please provide 10 unsigned decimal integers.",0
instructions_2		BYTE 	"Each number needs to be small enough to fit inside a 32 bit register.",0
instructions_3		BYTE 	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",0
prompt_1			BYTE	"Please enter an unsigned number: ",0
prompt_2			BYTE	"Please try again: ",0
prompt_error		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.",0
prompt_3			BYTE	"You entered the following numbers: ",0
goodbye_1			BYTE	"Thank you and Goodbye!",0
prompt_sum			BYTE	"The sum of these numbers is: ",0
prompt_average		BYTE	"The average is: ",0
comma_space			BYTE 	2Ch, 20h,0	
enteredNums			DWORD	10 DUP(0)	;Holds numbers entered by user
sum					DWORD	0
average				DWORD	0


.code
main PROC

	;Introduction
	displayString	OFFSET introduction_1
	call	CrLf
	displayString	OFFSET introduction_2
	call	CrLf
	call	CrLf
	
	;Instructions
	displayString	OFFSET instructions_1
	call	CrLf
	displayString	OFFSET instructions_2
	call	CrLf
	displayString	OFFSET instructions_3
	call	CrLf
	call	CrLf
	
	;Get user numbers - ReadVal
	push	OFFSET enteredNums								;Array to hold numbers entered by user
	push	OFFSET prompt_1
	push	OFFSET prompt_2
	push	OFFSET prompt_error
	call	ReadVal
	
	;Display user numbers - WriteVal
	call	CrLf
	push	OFFSET enteredNums
	push	LENGTHOF enteredNums
	push	OFFSET comma_space
	push	OFFSET prompt_3
	call	printValues
		
	;Display user sum - WriteVal
	call	CrLf
	displayString OFFSET prompt_sum
	push	OFFSET enteredNums
	push	LENGTHOF enteredNums
	push	OFFSET sum
	call	calcSum
	push	sum
	call	WriteVal
	call	CrLf
	call	CrLf
	
	;Display user average
	displayString	OFFSET prompt_average
	push	sum
	push	LENGTHOF enteredNums
	push	OFFSET average
	call	calcAverage
	push	average
	call	WriteVal
	call	CrLf
	call	CrLf
	
	;Goodbye
	displayString	OFFSET goodbye_1
	call	CrLf
	
	exit	; exit to operating system
main ENDP

;----------------------------------------------------------------------------------------------------------
ReadVal PROC 
;
; Invokes the getString macro to get the user’s string of digits. Then convert the digit string to numeric,
; while validating the user’s input.
;
; preconditions: Push variables onto stack by reference.
;
; postconditions: Array filled with unsigned integers. Registers left unchanged.
;
; Receives:
;	EnteredNums_param	- Reference - [ebp + 20]: Array to hold 10 numbers	
;	prompt_1_param		- Reference - [ebp + 16]: Prompt to display
;	prompt_2_param		- Reference - [ebp + 12]: Prompt to display
;	prompt_error_param	- Reference - [ebp + 8] : Prompt to display
;
; Returns: 
;	EnteredNums_param	- Reference - [ebp + 20]: Array to hold 10 numbers
;----------------------------------------------------------------------------------------------------------
	;Parameters
	EnteredNums_param		EQU [ebp + 20]
	prompt_1_param			EQU [ebp + 16]
	prompt_2_param			EQU [ebp + 12]
	prompt_error_param		EQU [ebp + 8]

	push	ebp
	mov		ebp, esp
	
	;local variables
	sub		esp, 28
	inputBuffer			EQU BYTE  PTR [ebp - 20]				;Hold current string to process
	inputBufferLength	EQU DWORD PTR [ebp - 24]				;Length of string entered
	counter_local		EQU	DWORD PTR [ebp - 28]				;Counter for loop to enter 10 numbers
	error_local			EQU	DWORD PTR [ebp - 32]				;Variable to hold if there was an error entering number(0=no error, 1=error)
	numberFromString	EQU	DWORD PTR [ebp - 36]				;Hold converted number from string
	mov		counter_local, 0
	
	pushad														;Save registers

startReadingValues:
	;loop to get numbers
	cmp		counter_local, 10
	jae		finishedReadingValues
	
	;Set-up Registers for address passing
	lea		esi, inputBuffer
	lea		ecx, inputBufferLength
	lea		edi, numberFromString
	lea		ebx, error_local 

	;Prompt for numbers
	getString prompt_1_param, esi, STRING_SIZE_MAX, ecx

convertStringToInt:
	;Convert String to unsigned integer
	push	esi													;inputBuffer
	push	ecx													;inputBufferLength
	push	edi													;numberFromString
	push	ebx													;error_local
	call	strToUnsignedInt
	
	;Check for errors - validate number is w/i range and no non-digit chars
	cmp		error_local, 1
	jne		noErrorReadingValue
	;Display error message
	displayString	prompt_error_param
	call	CrLf
	;Prompt for numbers w/ error prompt
	getString prompt_2_param, esi, STRING_SIZE_MAX, ecx
	jmp		convertStringToInt
	
noErrorReadingValue:
	;Store number in array
	push	edi
	push	eax
	push	ebx
	;Calculate current index to store the number
	mov		eax, counter_local
	mov		ebx, 4
	mul		ebx
	mov		edi, EnteredNums_param
	mov		ebx, numberFromString
	mov		[edi + eax], ebx
	pop		ebx
	pop		eax
	pop		edi
	
	add		counter_local, 1
	jmp		startReadingValues
	
finishedReadingValues:		
	popad														;Restore registers
	mov		esp, ebp											;Clean locals from stack
	pop		ebp
	ret 36														;Clean-up stack
ReadVal ENDP

;----------------------------------------------------------------------------------------------------------
WriteVal PROC 
; 
; Converts a numeric value to a string of digits, and invokes the displayString macro to produce the output
; 
; preconditions: Push value to display onto stack
;
; postconditions: Integer value displayed on screen. Registers left unchanged.
;
; Receives: 
;	numOut - value - [ebp + 8]: Number to convert
;
; Returns: nothing
;----------------------------------------------------------------------------------------------------------
	;Parameters
	numOut			EQU [ebp + 8]		;Number to convert

	push	ebp
	mov		ebp, esp
	;Local variables
	sub		esp, 24
	tempStr EQU BYTE PTR [ebp - 12]		;hold converted number in string in reverse order
	strOut	EQU BYTE PTR [ebp - 24]		;destination string to print
	pushad								;save registers
	
	cld									;set direction flag forwards
	;Set-up stosb
	lea		edi, tempStr				;load array address at runtime
		
	;set-up eax/ebx for division
	mov		eax, 0
	mov		eax, numOut
	mov		ebx, DIVISOR

	
convertUnsgndToStr:
	;Get current digit (i.e. begin w/ ones place)
	mov		edx, 0				
	div		ebx
		
	;Convert digit to ASCII
	push	eax
	add		edx, ZERO_ASCII
	mov		al, dl
	;Add char to string
	stosb										;Store contents of al
	pop 	eax
	cmp		eax, 0
	je		endConvertToString					;Base case - quotient is zero
	jmp		convertUnsgndToStr

endConvertToString:
;Set-up lodsb and stosb
	mov		esi, edi							;source - where the conversion left off from tempStr location
	sub		esi, 1								;adjust for previous increment
	lea		edi, strOut							;destination address
	mov		ecx, 11
ExchangeString:
	std											;load in reverse order
	lodsb
	cld											;store in forward order
	stosb
	loop	ExchangeString
	mov		eax, 00h
	stosb										;append NULL terminating string

	;Display the converted number
	lea		edi, strOut							;destination 
	displayString edi
	
	popad										;restore registers
	mov		esp, ebp							;Clean-up up stack
	pop		ebp
	ret 4
WriteVal ENDP

;----------------------------------------------------------------------------------------------------------
strToUnsignedInt PROC 
;
; Non-Recursive procedure to convert a string of chars to integers
;
; preconditions: Push parameter variables one of which is a string of numbers.
;
; postconditions: numFromString contains integer from string. Registers left unchanged.
;
; Receives:
;	strIn 				- Reference - [ebp + 20]: Address of string
;	strLen 				- Value 	- [ebp + 16]: Length of passed String
;	numFromString		- Reference - [ebp + 12]: Address of converted string to return
;	errorInConversion 	- Reference - [ebp + 8] : Address of error checking variable 
;
; Returns: 
;	numFromString		- Reference - [ebp + 12]: Address of converted string to return
;----------------------------------------------------------------------------------------------------------
	;Parameters
	strIn				EQU [ebp + 20]				;address of string
	strLen				EQU [ebp + 16]
	numFromString		EQU [ebp + 12]				;address of converted string to return
	errorInConversion	EQU [ebp + 8]				;address of error checking variable
	
	push	ebp
	mov		ebp, esp
	;Set-up Locals
	sub		esp, 4
	numIn	EQU DWORD PTR [ebp - 4]			;Holds converted number
	mov		numIn, 0
	
	pushad						 			;Save registers
	
	;Set-up lodsb
	mov		esi, strIn
	mov		edi, strLen
	mov		ecx, [edi]
	
	
convertDigit:
	;multiplication
	mov		edx, 0
	mov		eax, numIn
	mov		ebx, MULTIPLIER
	mul		ebx
	jc		errorNotADigit					;Check for carry flag indicating overflow in multiplication
	mov		numIn, eax
	mov		eax, 0							;Clear eax
	lodsb									;Get first char into eax
	;Check if char is a digit 
	cmp		eax, ZERO_ASCII
	jb		errorNotADigit					;eax < ZERO_ASCII?
	cmp		eax, NINE_ASCII
	ja		errorNotADigit					;eax < NINE_ASCII?
	;Get digit and add to total
	sub		eax, ZERO_ASCII
	add		numIn, eax
	jc		errorNotADigit					;Check if number is w/i 32 bits
	loop	convertDigit

	;Return value
	mov		eax, numIn
	mov		esi, numFromString
	mov		[esi], eax
	;Set error checking variable to no error = 0
	mov		esi, errorInConversion
	mov		eax, 0
	mov		[esi], eax
	jmp		noError

;Set error checking variable to error = 1
errorNotADigit:
	mov		esi, errorInConversion
	mov		eax, 1
	mov		[esi], eax

noError:
	popad									;Restore registers
	mov		esp, ebp						;Clean-up local variables
	pop		ebp
	ret	16									;Clean-up stack
strToUnsignedInt ENDP

;----------------------------------------------------------------------------------------------------------
printValues PROC 
;
; Print the list of values entered by the user
;
; preconditions: Push variables onto stack.
;
; postconditions: List of numbers printed. Registers left unchanged.
;
; Receives: 
;	array_print 		- Reference - [ebp + 12]: Array of numbers
;	array_length 		- Value 	- [ebp + 16]: Length of passed array
;	comma_space_local 	- Reference - [ebp + 12]: ", " for printing
;	prompt_3_local 		- Reference - [ebp + 8]:  Prompt string to display
;
; Returns: nothing
;----------------------------------------------------------------------------------------------------------
	;Parameters
	array_print			EQU [ebp + 20]
	array_length		EQU [ebp + 16]
	comma_space_local	EQU [ebp + 12]
	prompt_3_local		EQU [ebp + 8]
	
	push	ebp
	mov		ebp, esp
	pushad									;save registers
	
	displayString prompt_3_local
	call	CrLf
	mov		esi, array_print
	mov		ecx, array_length
displayArray:
	lodsd
	push	eax
	call	WriteVal
	cmp		ecx, 1
	je		noComma
	displayString comma_space_local
noComma:
	loop	displayArray
	
	call	CrLf
	
	popad									;restore registers	
	pop		ebp
	ret 16
printValues ENDP

;----------------------------------------------------------------------------------------------------------
calcSum PROC
; 
; Calculate the sum of the array and return sum
;
; preconditions: push OFFSET of string to display, Length of string
;
; postconditions: sum_param contains sum of integers. Registers left unchanged.
;
; Receives: 
;	StringIn_calc 		- reference - [ebp + 16]: Address of array to calculate
;	StringLength_calc 	- value 	- [ebp + 12]: Length of string
;	sum_param 			- reference - [ebp + 8] : Variable to hold a sum of numbers
;
; Returns:
;	sum_param 			- reference - [ebp + 8]:  sum of numbers
;----------------------------------------------------------------------------------------------------------
	;Parameters
	StringIn_calc		EQU [ebp + 16]
	StringLength_calc	EQU [ebp + 12]
	sum_param			EQU [ebp + 8]
	
	push 	ebp
	mov		ebp, esp
	pushad											;Save Registers
	
	mov		esi, StringIn_calc
	mov		ecx, StringLength_calc
	mov		ebx, 0
calculateSum:
	lodsd
	add		ebx, eax
	loop	calculateSum
	
	;Save sum in return variable
	mov		edi, sum_param
	mov		[edi], ebx
	
	popad											;Restore Registers
	pop ebp
	ret 12											;Clean-up Stack
calcSum ENDP

;----------------------------------------------------------------------------------------------------------
calcAverage PROC
; 
; Calculate the average of a sum of numbers
;
; preconditions: push parameters onto stack. average_param passed by reference.
;
; postconditions: average_param contains the average of the sum. Registers left unchanged.
;
; Receives: 
;	sum_forAvgCalc 		- value		- [ebp + 16]: Sum to find average from
;	length_forAvgCalc 	- value 	- [ebp + 12]: Number of integers for average calculation
;	average_param		- reference - [ebp + 8] : Variable to hold a sum of numbers
;
; Returns:
;	average_param		- reference - [ebp + 8] : average value of sum
;----------------------------------------------------------------------------------------------------------
	;Parameters
	sum_forAvgCalc			EQU [ebp + 16]
	length_forAvgCalc		EQU [ebp + 12]
	average_param			EQU [ebp + 8]
	
	push 	ebp
	mov		ebp, esp
	pushad											;Save Registers
	
	;Calculation
	mov		edx, 0
	mov		eax, sum_forAvgCalc
	mov		ebx, length_forAvgCalc
	div		ebx										;Calculate average from sum found earlier
	
	;Save return value
	mov		esi, average_param
	mov		[esi], eax
	
	popad											;Restore Registers
	pop ebp
	ret 12											;Clean-up Stack
calcAverage ENDP

END main
