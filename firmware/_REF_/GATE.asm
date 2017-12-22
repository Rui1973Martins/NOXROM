GATE_LINES EQU 11

TopGateTabIdx	DEFB	0,0,0,0,0,0,0,1,3,3,3,4, #FF
BotGateTabIdx	DEFB	4,3,3,3,2,0,0,0,0,0,0,0, #FF

GateTypeTab:
	DEFW GateLineT0
	DEFW GateLineT1
	DEFW GateLineT2
	DEFW GateLineT3
	DEFW GateLineT4

; Gate Colors with BLACK Ink
; GateLineT0	DEFB	#78,-3,#68,#28,-4,#68,#78,-3,#68,#28,-4,#68,#78,-3,#68,#28,-4,#68,#78,-3,#68,#28,-1
; GateLineT1	DEFB	#78,-3,#68,#20,-4,#30,#70,-3,#68,#20,-4,#30,#70,-3,#68,#20,-4,#30,#70,-3,#68,#28,-1
; GateLineT2	DEFB	#78,-3,#68,#20,-4,#28,#38,-3,#68,#20,-4,#28,#38,-3,#68,#20,-4,#28,#38,-3,#68,#28,-1
; GateLineT3	DEFB	#78,-30,#68,#28,-1
; GateLineT4	DEFB	-32,#46,-1

; Gate colors
GateLineT0	DEFB	#7F,-3,#6D,#2D,-4,#6D,#7F,-3,#6D,#2D,-4,#6D,#7F,-3,#6D,#2D,-4,#6D,#7F,-3,#6D,#2D,-1
GateLineT1	DEFB	#7F,-3,#6D,#24,-4,#36,#76,-3,#6D,#24,-4,#36,#76,-3,#6D,#24,-4,#36,#76,-3,#6D,#2D,-1
GateLineT2	DEFB	#7F,-3,#6D,#24,-4,#2D,#3F,-3,#6D,#24,-4,#2D,#3F,-3,#6D,#24,-4,#2D,#3F,-3,#6D,#2D,-1
GateLineT3	DEFB	#7F,-30,#6D,#2D,-1
GateLineT4	DEFB	-32,#46,-1

; Inputs:
;	DE = Screen Row Synch Start Addr (First Column)
ClearPixelRow0
		XOR A
ClearPixelRow	; ClearDangerRow
		LD BC, #2020	;	32,32
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		INC D

		LD	B, C
		PUSH DE
			CALL DrawHorizLine
		POP DE
		;INC D
	RET
		
; Inputs:
;	DE = Screen Row Synch Start Addr (First Column)
DrawDangerRow
		LD A, #FF
		LD BC, #2020	;	32,32
		PUSH DE
			CALL DrawHorizLine
		POP DE
		;LD E, 0
		INC D
		
		DEC	A	; A = #FE
		LD B, C
		PUSH DE
			CALL DrawToggleHorizLine
		POP DE
		;LD E, 0
		INC D

		SLA A
		LD B, C
		PUSH DE
			CALL DrawToggleHorizLine
		POP DE
		;LD E, 0
		INC D

		SLA A
		LD B, C
		PUSH DE
			CALL DrawToggleHorizLine
		POP DE
		;LD E, 0
		INC D

		SLA A
		LD B, C
		PUSH DE
			CALL DrawToggleHorizLine
		POP DE
		;LD E, 0
		INC D

		SLA A
		LD B, C
		PUSH DE
			CALL DrawToggleHorizLine
		POP DE
		;LD E, 0
		INC D

		SLA A
		LD B, C
		PUSH DE
			CALL DrawToggleHorizLine
		POP DE
		;LD E, 0
		INC D
		
		LD A, #FF
		LD B, C
		CALL DrawHorizLine
	 RET
 
; Inputs:
;	A = Byte (pattern) used to Fill Line
;	B = Number of Bytes to Fill
;	DE = Screen Addr
; TRASH: DE = DE+B, B = 0
DrawHorizLine
		LD (DE),A
		INC DE
		DJNZ DrawHorizLine	; $-2
	RET

; Inputs:
;	A = Byte (pattern) used to Fill Line
;	B = Number of Bytes to fill
;	DE = Screen Addr
; TRASH: DE = DE+B, B = 0, A = A or !A, depending on Even or Odd count
DrawToggleHorizLine
		LD (DE),A
		INC DE
		CPL
		DJNZ DrawToggleHorizLine
	RET

HLFUNC
	JP (HL)

IXFUNC
	JP (IX)
	
IYFUNC
	JP (IY)

; IXFuncBlit
			; ADD A,A		; SLA A	;*2 IDX
			; LD C,A		; BC = 2*A, an Index to a table of Pointers (Words)
			; LD B,0		
		; RLEIndexTab EQU $+1
			; LD HL,#0000;(RLEIndexTab); Pointer to Run Length Encoding Table
			; ADD HL,BC
			; LD B,(HL)
			; INC HL
			; LD H,(HL)
			; LD L,B
		
		; RLEBlitFunc equ $+1
			; JP Blit0
			; ;CALL Blit0
; ;RET

; IYFuncBlit
		; LD A,E
		; ADD A,8
		; LD E,A
		; RET NC	; Continue
		; LD A,D
		; ADD A,8
		; LD D,A
	; RET

	
IXFuncAttrBlit
		LD	(DE),A
	RET
	
IYFuncAttrInc
		INC	DE
	RET
	

; Common code between Menu and Play Game
ChangeRLEIXFunc	; HL points to parameters (function to set)
	LD C,(HL)		; Read Func addr (Word) from stream
	INC HL
	LD B,(HL)
	INC HL 
	LD IXl,C		; Load RLE IXFunc with new value
	LD IXh,B
;	JR RLETabFunc	; TODO optimize this by comment if possible, to flow through

; Run Length Encoding Table Blit
; inputs:
;	HL = RLE stream
;	DE = (external input) Ex: YX pixel position
; 	IX = IXFUNC Output Function ADDR (Can be loaded/changed from Data Stream)
; 	IY = IYFUNC Update/Increment Function ADDR
RLETabFunc
	LD B,1				; Default Length = 1
RLETabFuncLen
    LD A,(HL)			; read Stream byte
	INC HL
    AND A
    JP P,RLEFuncLoop0	; If byte is positive, than it's just a simple value
	CP -2
	JR Z,ChangeRLEIXFunc		; -2 = b11111110, implies Change Func
    CP -1				; -1 = b11111111, implies exit
   RET Z				; Function Exit 
    NEG					; Reverse Count into a positive value
    LD B,A				; CNT
    JR RLETabFuncLen	; Read next stream byte, to check what to repeat CNT times
RLEFuncLoop0
    PUSH HL
RLEFuncLoop				; Repeat Loop to call Func N times with index parameter
		LD C,A			; Save Tab Index
		;AND A			
		;JR Z,RLEFuncNxt	; Zero Index is Valid,, hence no Skip
		PUSH DE
		PUSH BC
		
		; Inputs:
		;	A = Stream Byte
		;	HL = Next stream position
		;   DE = (external input) Ex: YX pixel position
		CALL IXFUNC 
					
		POP BC
		POP DE
RLEFuncNxt
		; Update/increment DE
		;	BC <=> B = count, C = copy of Stream Byte
		;   DE = (external input) Ex: YX pixel position
		CALL IYFUNC

RLEFuncContinue
		LD A,C
		DJNZ RLEFuncLoop
	POP HL
    JR RLETabFunc

