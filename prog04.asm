TITLE Sorting Random Integers    (Prog04.asm)

; Last Modified: August 02, 2020
; Course number/section: 
; Assignment Number: Assignment 04         Due Date: August 03, 2020
; Description:
; Write and test a MASM program to perform the following tasks:
;	1. Introduce the program.
;	2. Get a user request in the range [min = 10 .. max = 200].
;	3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements
;		of an array.
;	4. Display the list of integers before sorting, 10 numbers per line.
;	5. Sort the list in descending order (i.e., largest first).
;	6. Calculate and display the median value, rounded to the nearest integer.
;	7. Display the sorted list, 10 numbers per line.


INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 1000					;adjusted for n-1

.data

introduction_1		BYTE 	"Sorting Random Integers",0
introduction_2		BYTE 	"Programmed by George Duensing",0
instructions_1		BYTE 	"This program generates random numbers in the range [100 .. 999],",0
instructions_2		BYTE 	"displays the original list, sorts the list, and calculates the median value.",0
instructions_3		BYTE 	"Finally, it displays the list sorted in descending order.",0
prompt_1			BYTE 	"How many numbers should be generated? [10 .. 200]: ",0
prompt_2			BYTE 	"Invalid input.",0
title_1				BYTE 	"The unsorted random numbers: ",0
title_2				BYTE 	"The sorted list:",0
output_2			BYTE 	"The median is ",0
request				DWORD	?						;how many integers to fill the array with
array				DWORD	MAX DUP(50)				;array to hold random integers
median				DWORD	?
spaces				BYTE	"   ",0					


.code
main PROC
	;seed random number generator
	call	Randomize

	;introduction
	call	introduction
	
	;get data - ask user for array capacity
	push	OFFSET request						
	call	getData							;clean up stack in procedure
	
	;fill array
	push	OFFSET array
	push	request
	call	fillArray
	
	;display unsorted list
	push	OFFSET array
	push	OFFSET title_1
	push	request
	call	displayList							;clean up stack in procedure
	
	;sort list 
	push	OFFSET array
	push	request
	call	sortList
	
	;display median
	push	OFFSET array
	push	OFFSET output_2
	push	request
	call	displayMedian
	
	;display sorted list
	push	OFFSET array
	push	OFFSET title_2
	push	request
	call	displayList							;clean up stack in procedure

	exit	; exit to operating system
main ENDP

;----------------------------------------------------------------------------------------------------------
introduction PROC USES edx
;
; Display the introductory text messages
;
; preconditions: none
;
; postconditions: none. Does not change Registers
;
; Receives: nothing
;
; Returns: nothing
;----------------------------------------------------------------------------------------------------------
	mov		edx, OFFSET introduction_1
	call	WriteString
	call 	CrLf
	mov		edx, OFFSET introduction_2
	call	WriteString
	call 	CrLf
	call 	CrLf
	mov		edx, OFFSET instructions_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions_2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instructions_3
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP

;----------------------------------------------------------------------------------------------------------
getData PROC 
;
; Get the user input and call validate procedure to check if input is in range 
;
; preconditions:	Push OFFSET of request parameter onto stack
;
; postconditions:	Value placed in reference parameter. Registers (except esi) unchanged.
;
; Receives: 
;	request	- [ebp + 8] - reference: Number of integers to fill array with
;
; Returns:  nothing - parameter passed by reference
;----------------------------------------------------------------------------------------------------------
	push	ebp
	mov		ebp, esp
	
	mov		esi, [ebp + 8]				;store address of parameter in esi
	pushad								;save registers
	
	
;Get input and validate input
getInput:
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	call	CrLf
	;push	eax							;pass n as paramater: clean up stack in sub-procedure
	call	validate					
	cmp		ebx, 1						;1 = in range
	je		endGetInput
	jmp		errorMsg							
	

errorMsg:
	mov		edx, OFFSET prompt_2		
	call	WriteString
	call	CrLf
	jmp		getInput					

endGetInput:
	mov		[esi], eax					;save user input in reference parameter
	popad								;restore registers
	pop		ebp							
	ret	4								;clean stack from reference parameter
getData ENDP

;----------------------------------------------------------------------------------------------------------
validate PROC 
;
; Check whether user input is within range of >= LOWER_LIMIT AND <= UPPER_LIMIT
; [LOWER_LIMIT, UPPER_LIMIT]
;
; preconditions:	Move number to validate into eax
;
; postconditions:	Returns true(valid)/false(invalid) in ebx.
;
; Receives: 
;	eax: number to validate
;
; Returns: ebx: 1 = in range; 0 = out of range
;----------------------------------------------------------------------------------------------------------
	push	ebp							
	mov		ebp, esp	
	
	cmp		eax, MIN					;check number >= MIN
	jl		outOfRange						
	cmp		eax, MAX					;check number <= MAX		
	jg		outOfRange
	mov		ebx, 1						;Value is in range
	jmp		theEnd

outOfRange:
	mov		ebx, 0						;Value is not in range

theEnd:
	pop		ebp							
	ret									
validate ENDP

;----------------------------------------------------------------------------------------------------------
fillArray PROC USES esi ecx eax ebx 
;
; Fill an array with random numbers between >= 100 and <= 999.
;
; preconditions:	
;	1. Push OFFSET of array to be filled onto the stack.
;	2. Push number of integers to fill array with onto the stack
;
; postconditions:	Array passed by reference will be filled with desired number of integers. 
;					Registers are not changed.
;
; Receives:	
;	array_fillArray - [ebp + 28]: Holds random integer values
;	request_fillAray - [ebp + 24]: Number of random integers
;
; Returns:	nothing
;----------------------------------------------------------------------------------------------------------
	;parameters +16 for USES adjust
	request_fillAray	EQU [ebp + 24]
	array_fillArray		EQU [ebp + 28]
	
	push	ebp							
	mov		ebp, esp
	pushad										;save registers
	
	mov		esi, array_fillArray
	mov		ecx, request_fillAray
fill:
	;initialize RandomRange
	mov		eax, HI
	call	RandomRange							;returns integer in eax
	;check lower bounds (LO)
	mov		ebx, LO
	cmp		eax, ebx							;is eax > ebx(LO)
	jge		doNotAdjust
adjustRandomNumber:
	add		eax, 100
doNotAdjust:
	;fill array with random number
	mov		[esi], eax
	add		esi, TYPE DWORD						;next memory location in array
	loop	fill
	
	popad										;restore registers
	pop		ebp
	ret		8									;clean up stack
fillArray ENDP

;----------------------------------------------------------------------------------------------------------
displayList PROC USES eax ebx ecx esi edx
;
; Print the array title and array of integers to the screen in row-major order.
;
; preconditions:	
;	1. Push OFFSET of array to be filled onto the stack.
;	2. Push OFFSET of title to be displayed
;	3. Push number of integers to fill array with onto the stack
;
; postconditions:	none. Registers unchanged.
;
; Receives:	
;	array_displayList - [ebp + 36]: array of integers
;	title_displayList - [ebp + 32]: title of array
;	request_displayList - [ebp + 28]: length of the array
;
; Returns:	nothing
;----------------------------------------------------------------------------------------------------------
	;parameters +20 to adjust for USES
	array_displayList		EQU [ebp + 36]	
	title_displayList		EQU	[ebp + 32]
	request_displayList		EQU [ebp + 28]
	
	push	ebp							
	mov		ebp, esp
	;local variables
	sub		esp, 4
	counter	EQU DWORD PTR [ebp - 4]
	mov		counter, 0						;initialize
	
	;Identify array
	mov		edx, title_displayList
	call	WriteString
	call	CrLf
	call	CrLf
	
	;set up loop
	mov		esi, array_displayList			;offset of array
	mov		edx, OFFSET spaces
	mov		ecx, request_displayList
	mov		ebx, 10
	
displayArray:
	;print array element
	mov		eax, [esi]
	call	WriteDec
	call	WriteString
	add		counter, 1
	add		esi, TYPE DWORD					;address of next array value
	
	;check if new line is necessary
	push 	edx
	mov		edx, 0
	mov		eax, counter
	div		ebx
	cmp		edx, 0
	pop 	edx
	jne		sameLine
	call	CrLf
sameLine:
	loop	displayArray

	call	CrLf
	call	CrLf
	
	mov		esp, ebp
	pop		ebp							
	ret		12
displayList ENDP

;----------------------------------------------------------------------------------------------------------
sortList PROC USES ebx eax esi ecx
;
; Sort list from greatest to least using selection sort algorithm.
;
; preconditions:
;	Push onto stack:
;		1. OFFSET of array filled with integers
;		2. integer length of array to be sorted
;
; postconditions:	
;	Array sorted by value from greatest to least. Registers left unchanged.
;
; Receives:	
;	array_sort - reference - [ebp + 28]: array to be sorted
;	request_sort - value - [ebp + 24]: length of array
;
; Returns:	nothing
;----------------------------------------------------------------------------------------------------------
	;parameters
	array_sort		EQU [ebp + 28]			;+16 to adjust for USES
	request_sort	EQU	[ebp + 24]			;+16 to adjust for USES
	
	push	ebp
	mov		ebp, esp
	
	;set up locals
	sub		esp, 12
	k_index		EQU DWORD PTR [ebp - 4]
	i_index		EQU DWORD PTR [ebp - 8]
	j_index		EQU DWORD PTR [ebp - 12]

	mov		esi, array_sort
	mov		k_index, 0						;initialize
	mov		j_index, 0						;initialize
	mov		ecx, request_sort				;outer for loop
	sub		ecx, 1

;k_index is the number we are checking proceeding numbers against
outerForLoop:
	mov	eax, k_index
	mov	i_index, eax						;check i_index against j_index in nested loop

	push	ecx								;save to resume outer loop
	;set up innerLoop ecx
	;set-up j_index = k + 1
	mov		ecx, request_sort				
	mov		j_index, eax
	add		j_index, 1
	sub		ecx, j_index
;check numbers after k_index to see if they are greater than
;j_index is the index of the number we are checking k_index against
innerForLoop:
	;compare array elements
	push	i_index
	call	adjustIndex
	mov		ebx, eax						;adjusted index for memory access
	mov		eax, [esi + ebx]				;value at i_index location
	push	eax
	push	j_index
	call	adjustIndex
	mov		ebx, eax						;adjusted index for memory access
	pop		eax
	cmp		[esi + ebx], eax				;check if j_index > i_index
	jle		doNotSwap
	;replace indices if j_index > i_index
	mov		eax, j_index
	mov		i_index, eax
doNotSwap:
	;add 1 to j_index
	add		j_index, 1
	loop	innerForLoop
	
	;swap values at pushed indices
	push	array_sort						;contains starting address of array
	push	k_index
	push	i_index
	call	exchange
	
	add		k_index, 1						;set next number in array to check proceeding numbers against
	pop		ecx								;restore for main loop
	loop	outerForLoop
	
	mov		esp, ebp
	pop		ebp
	ret 8
sortList ENDP

;----------------------------------------------------------------------------------------------------------
exchange PROC USES eax esi ebx edx edi
;
; Swap values at two different array index locations
;
; preconditions: push onto stack in order:
;	1. array to be swapped
;	2. first index value
;	3. second index value
;
; postconditions: none. Registers left unchanged.
;
; Receives:	
;	array_exchange - reference - [ebp + 36]:
;	k_exchange - value - [ebp + 32]:
;	i_exchange - value - [ebp + 28]:
;
; Returns:	nothing.
;----------------------------------------------------------------------------------------------------------
;parameters +20 for USES adjustment
	array_exchange	EQU [ebp + 36]
	k_exchange		EQU [ebp + 32]
	i_exchange		EQU	[ebp + 28]
	
	push	ebp
	mov		ebp, esp
	
	;adjust parameters for memory size
	push	k_exchange
	call	adjustIndex
	mov		k_exchange, eax
	push	i_exchange
	call	adjustIndex
	mov		i_exchange, eax
	
	;set up array for access
	mov		esi, array_exchange
	;hold value @ index i in eax
	mov		ebx, k_exchange
	mov		eax, [esi + ebx]
	;swap index i value for index j value
	mov		edi, i_exchange
	mov		edx, [esi + edi]
	mov		[esi + ebx], edx
	;swap index j value for index i value stored in eax
	mov		[esi + edi], eax
	
	pop		ebp
	ret 12							;clean stack
exchange ENDP

;----------------------------------------------------------------------------------------------------------
adjustIndex PROC USES ebx
;
; Adjusts an index value for array access based on DWORD memory size
;	i.e. index 1 * 4 = location in array
;
; preconditions:	push index value onto stack
;
; postconditions:	returns adjusted index in eax. Other registers unchanged.
;
; Receives:	
;	index_adjust - [ebp + 12]: value to adjust for array access
;
; Returns:	eax - adjusted index
;----------------------------------------------------------------------------------------------------------
	;parameters +4 adjust for USES
	index_adjust		EQU	[ebp + 12]

	push	ebp
	mov		ebp, esp
	
	mov		ebx, 4					;DWORD size
	mov		eax, index_adjust
	mul		ebx
	
	pop		ebp
	ret 4					
adjustIndex ENDP

;----------------------------------------------------------------------------------------------------------
displayMedian PROC USES esi eax ebx edx ecx
;
; Calculate and display the median of an array of integers.
;	even array size:	((length of array / 2) + previouse integer in array) / 2
;	odd array size:		length of array / 2
;
; preconditions:
;	1. Push OFFSET of array onto stack
;	2. Push OFFSET of title to display onto stack
;	3. Push length of array onto stack
;
; postconditions:	Displays the median onto the screen. Does not change registers.
;
; Receives:	
;	array_median - reference - [ebp + 16]:	array of integers	
;	title_median - reference - [ebp + 12]:	title to display
;	request_median - value - [ebp + 8]:		length of array
;
; Returns:	nothing
;----------------------------------------------------------------------------------------------------------
	;parameters +20 for USES adjustment
	array_median	EQU	[ebp + 36]
	title_median	EQU	[ebp + 32]
	request_median	EQU	[ebp + 28]
	
	push	ebp
	mov		ebp, esp
	
	mov		esi,	array_median
	
	;determine if size of array is even or odd
	cdq
	mov		eax, request_median
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	jne		odd
	;if even
	push	eax
	call	adjustIndex
	mov		ecx, [esi + eax]				;get first value for calculation
	sub		eax, 4							
	add		ecx, [esi + eax]				;add previous value in memory to first value				
	xchg	ecx, eax
	cdq
	div		ebx								;calculate median stored in eax
	jmp		printMedian

	;if odd
odd:
	push	eax
	call	adjustIndex						;adjusted index returned in eax
	mov		ecx, [esi + eax]
	xchg	eax, ecx						;set up WriteDec
	;display median
printMedian:
	mov		edx, title_median
	call	WriteString
	call	WriteDec
	call	CrLf
	call	CrLf
	
	pop		ebp
	ret 8
displayMedian ENDP

END main
