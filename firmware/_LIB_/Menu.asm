

bankNumberStrBuf DEFM "000", 0

menuPageOffset	DEFB 0
menuLineAux		DEFB 0

;TODO:  Move to RAM file

TitleAttrRLE
; Line 1
	DEFB	BRIGHT+BG_BLACK
	DEFB 	BRIGHT+BG_RED,		BRIGHT+BG_RED
	DEFB	BRIGHT+BG_GREEN,	BRIGHT+BG_GREEN
	DEFB	BRIGHT+BG_CYAN,		BRIGHT+BG_CYAN
	DEFB	BRIGHT+BG_YELLOW,	BRIGHT+BG_YELLOW
	DEFB    -14, BRIGHT+BG_WHITE
	DEFB	BRIGHT+BG_YELLOW,	BRIGHT+BG_YELLOW
	DEFB	BRIGHT+BG_CYAN,		BRIGHT+BG_CYAN
	DEFB	BRIGHT+BG_GREEN,	BRIGHT+BG_GREEN
	DEFB	BRIGHT+BG_RED,		BRIGHT+BG_RED
	DEFB	BRIGHT+BG_BLACK
; Line 2
	DEFB	BG_BLACK
	DEFB	BG_RED,		BG_RED
	DEFB	BG_GREEN,	BG_GREEN
	DEFB	BG_CYAN,	BG_CYAN
	DEFB	BG_YELLOW,	BG_YELLOW
	DEFB    -14, BG_WHITE
	DEFB	BG_YELLOW,	BG_YELLOW
	DEFB	BG_CYAN,	BG_CYAN
	DEFB	BG_GREEN,	BG_GREEN
	DEFB	BG_RED,		BG_RED
	DEFB	BG_BLACK
	DEFB	0xFF	; = -1

MenuItemAttrRLE
; Line 1
	DEFB	-5, BRIGHT+WHITE,                BRIGHT+RED, -23, BRIGHT+WHITE, -3, YELLOW
; Line 2
	DEFB	-4, BRIGHT+WHITE, BRIGHT+YELLOW, BRIGHT+RED, -23, BRIGHT+CYAN,  -3, GREEN
	DEFB	0xFF	; = -1

PaintTitleAux
		PUSH DE
			LD	BC, #0A0A	;	10,10
			CALL DrawToggleHorizLine
			
			LD	L, A

			LD	A, 12
			ADD	A, E
			LD	E, A

			LD	A, L
			EX AF, AF'
			LD	B, C
			CALL DrawToggleHorizLine
			
		POP DE
		INC D
	RET
	
PaintTitle
		LD	DE, SCRN + #0040

		LD  A, #7F	;Using colored Background With Black Ink
		EX AF, AF'
		LD	A, #01	;Using colored Background With Black Ink

		CALL PaintTitleTop
		
		LD	DE, SCRN + #0060
		
		LD  A, #00	;Using colored Background With Black Ink
		EX AF, AF'
		LD	A, #FF	;Using colored Background With Black Ink

		;CALL PaintTitleBop
			
PaintTitleBot
		CALL PaintTitleAux
		
		; SLL A
		; EX AF, AF'
		; SRA A
		LD  A, #01	;Using colored Background With Black Ink
		EX AF, AF'
		LD	A, #7F	;Using colored Background With Black Ink
		
		CALL PaintTitleAux

		SLL A
		EX AF, AF'
		SRA A
		CALL PaintTitleAux

		SLL A
		EX AF, AF'
		SRA A
		CALL PaintTitleAux

		SLL A
		EX AF, AF'
		SRA A
		CALL PaintTitleAux

		SLL A
		EX AF, AF'
		SRA A
		CALL PaintTitleAux

		SLL A
		EX AF, AF'
		SRA A
		CALL PaintTitleAux

		SLL A
		EX AF, AF'
		SRA A
		CALL PaintTitleAux

PaintAttrTitle
		LD IX, IXFuncAttrBlit
		LD IY, IYFuncAttrInc

		LD	HL, TitleAttrRLE
		LD	DE, ATTR +32 +32	;Third Row	
		;CALL RLETabFunc
	; RET
		JP RLETabFunc;

PaintTitleTop
		CALL PaintTitleAux
		
		SRA A
		EX AF, AF'
		SLL A
		CALL PaintTitleAux

		SRA A
		EX AF, AF'
		SLL A
		CALL PaintTitleAux

		SRA A
		EX AF, AF'
		SLL A
		CALL PaintTitleAux

		SRA A
		EX AF, AF'
		SLL A
		CALL PaintTitleAux

		SRA A
		EX AF, AF'
		SLL A
		CALL PaintTitleAux

		SRA A
		EX AF, AF'
		SLL A
		CALL PaintTitleAux

		SRA A
		EX AF, AF'
		SLL A
		;CALL PaintTitleAux
	;RET
		JP PaintTitleAux
	
PaintMenu
		LD IX, IXFuncAttrBlit
		LD IY, IYFuncAttrInc

		LD	B, 8		; NUM_MENU_ITEMS
		LD	DE, ATTR +32 +32 +32 +32 +32	;Sixth Row

	PaintMenuL0

		LD	HL, MenuItemAttrRLE

		PUSH BC
			PUSH DE
				CALL RLETabFunc
			POP DE
			
			EX	DE, HL
				LD	BC, 64	; 64 = 2 Lines
				ADD HL, BC
			EX	DE, HL
		POP BC
		
		DJNZ PaintMenuL0
	RET


DrawMenu
		LD	BC, MENU_TAB

		LD A, 0
		LD (menuLineAux), A
		LD DE, 4*8 + (5*8 + 4)<<8	; 5th line, plus 4 pixels in Y, and 4 Chars in X

DrawMenuL0		
		LD	A, (BC)
		INC	BC
		LD	IXl, A
		
		LD	A, (BC)
		LD IXh, A

		; TEST if Zero
		OR IXl		
		RET Z
		
		INC BC
		
		PUSH BC
		PUSH DE
			CALL DrawMenuItem
		POP DE
		POP BC

		LD	HL, 0x1000	; 16 in Y
		ADD HL, DE
		EX DE, HL		; Save HL in DE = New Position 

		LD HL, menuLineAux

		;INC (HL)		
			LD A, (HL)
			INC A
			LD (HL), A
		
		CP 8	; MAX_MENU_ITEMS_ON_SCREEN
		JR NZ, DrawMenuL0
	RET

; Inputs
;	DE = Y,X
DrawMenuItem

	PUSH DE	
		LD E, 4*8	; 4th Column
		CALL SetTextPos

		;LD A, 'A'	; TODO user Actual KEY CHAR
		LD A, (menuPageOffset)
		LD C, A
		LD A, (menuLineAux)
		ADD A, C
		CALL GetMenuItemKey
		
		CALL PrintChar
	POP DE
	
	PUSH DE
		LD E, 6*8	; 6th Column

		; PUSH IX		; Determine String Addr -=> BC.
		; POP HL
		; LD BC, MENU_ITEM_NAME
		; ADD HL, BC
		; LD C, L
		; LD B, H
		
		; Determine String Addr -=> BC.
		LD BC, MENU_ITEM_NAME
		ADD IX, BC
		LD C, IXl
		LD B, IXh

		CALL PrintZStrAt
	POP DE
	
	LD E, #E8		; 30th Column
	LD BC, bankNumberStrBuf

;	CALL PrintZStrAt
;RET
	JP	PrintZStrAt
	

; Inputs:
;	A = Menu Index
GetMenuItemKey
		;TODO, make sure the Alphanumeric range is not exceeded (A..Z), ( 0 =< Register A =< 25 )
		LD C, 'A'
		ADD A, C
	RET