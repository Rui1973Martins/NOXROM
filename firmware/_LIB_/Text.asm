; Text output Functions

TextPos
TextXPos	DEFB	0
TextYPos	DEFB	0

hexHigh		DEFB	0
hexLow		DEFB	0

fontAddr	DEFW	FData

GenCharData	DEFB 	#FF,#81,#81,#99,#99,#81,#81,#FF

; TODO: MOve previous code to RAM file

TEST_MSG1	DEFB	"A0B1C2D3E4F5G6H7I8J9KLMNOPQRSTUVWXYZ",0
TEST_MSG2	DEFB	'A','a',0x01,0x10,'B',0x02,0x20,'C',0x03,0x30,'D',0x04,0x40,'Z','z',0

FLASH_ID_512	EQU 0xB7
FLASH_ID_256	EQU 0xB6
FLASH_ID_128	EQU 0xB5

MSG_NOXDUMP	DEFB	" NOX DUMP ",0
MSG_MEMDUMP	DEFB	" MEM DUMP ",0
MSG_NOXROM	DEFB	"NOXROM ", 0
MSG_512		DEFB	        "512", 0
MSG_256		DEFB	        "256", 0
MSG_128		DEFB	        "128", 0
MSG_000		DEFB	        "???", 0


; Inputs:
;	DE = YX
SetTextPos	; Could be changed to a MACRO
		LD (TextPos), DE
	RET

	
; Inputs:
;	DE = YX	
; 	BC = Text Addr
;; 	IY = Font Addr
PrintZStrAt
	;CALL SetTextPos		; Could be a MACRO
	LD (TextPos), DE
	
; Inputs:
; 	BC = Text Addr
;; 	IY = Font Addr
PrintZStr
		LD	A, (BC)
		AND A
		RET Z
		
		PUSH BC
			CALL PrintChar
		POP BC

		INC BC
		
		JR PrintZStr
		
; Inputs:
; 	A = Char Addr
;; 	IY = Font Addr
; TRASH: A, A', BC, DE, HL
PrintChar
		EX	AF, AF'		; Store Char
		
			; Load Character Text Pos, determine pixel byte addr, and increment position

			LD	HL, (TextPos)	; BC = YX	(Row;Col)
			CALL	PixelAD		; Output DE = pixelAd, HL = YX	
		
		PrintCharIncScrnPos
		
			LD	A, 8
			ADD A, L			; Next Horizontal Position (8 pixels for next char position)
			LD	L, A			
			JR	NC, PrintCharSavePos	; Last Screen Char Position + 8 = 0 (rolls over)
			
			LD	A, H			; Increment Row (8 pixel lines)
			ADD A, 8
			LD	H, A
			LD 	L, 0			; Reset Column

		PrintCharSavePos
			LD (TextPos), HL

		EX	AF, AF'		; Restore Char
		
			PUSH	DE
				CALL GetFontCharAddr	; A = Char Index
			POP		DE

;			CALL	CharDataBlit
;	RET
;;			JP 		CharDataBlit

	
; Inputs:
;	DE = Screen Pixel Addr
;	HL = Char Bitmap Addr
; Outputs: Updates Screen
; TRASH: A, BC, DE = last addr written, HL = last addr read
CharDataBlit
		LD	B, 8
		JP	ColumnDataBlitLoopEntry

ColumnDataBlitLoop
		; Advance HL
		INC HL

		; Advance DE
		;EX AF,AF'
			;PART INLINE
			LD A,D;INCSY
			OR #F8
			INC A
			JP NZ,ColumnDataBlit_X1
				CALL INCSY543
				JP ColumnDataBlit_X2
			ColumnDataBlit_X1
				INC D
			ColumnDataBlit_X2
		;EX AF,AF'

ColumnDataBlitLoopEntry
		LD	A, (HL)		; Copy Byte
		LD	(DE), A
		
        DJNZ ColumnDataBlitLoop
	RET



			

; Inputs:
;	A = char Idx
;	
; Returns:
;	HL = Font Char Addr (might be a generated Addr)
; Trashes: resets C to zero (0)
GetFontCharAddr
			CP 'A'
			JP M, IsNumericChar	;	NotAlphaChar

			CP 'Z'+1
			JP P, GenHexChar
						
		AlphaChar
			SUB	'A'		; Set index relative to Start of Alphanumeric Data
			
			LD	L, A
			LD	BC, FData
			LD	(fontAddr), BC
			
			JP	GetFontTabCharAddr
			
		IsNumericChar
			CP '0'
			JP M, GenHexChar
			
			CP '9'+1
			JP P, GenHexChar
		
		NumericChar
			SUB	'0'		; Set index relative to Start of Alphanumeric Data
		
			LD	L, A
			LD	BC, FNData
			LD	(fontAddr), BC
			
			JP	GetFontTabCharAddr

; Inputs:
; 	 L = Index
;;;	BC = Font Data Addr
; Returns:
;	HL = Char Addr
; Trashes: resets C to zero (0)
GetFontTabCharAddr
		LD	H,0
		ADD HL, HL	; x8
		ADD HL, HL
		ADD HL, HL
		
		LD BC, (fontAddr)
		ADD HL, BC		
	RET	

; Inputs:
;	A = char Idx/Number
; Outputs:
;	HL = Addr of generated Hex Char (GenCharData)
; Trashes: A, BC, DE, IX, IY
GenHexChar
		LD	B, A	; Keep original value
		AND	#0F		; Mask Low Nible
		LD (hexLow), A	; Save Nibble for later reference
		RRA			; Divide by 2 into Carry
		
		EX	AF, AF'	; Save Low Nible

		LD	A, B	; Recover original value
		AND	#F0		; Mask High Nible
		RRCA		; Move to Low Nible area (Shift 4x)
		RRCA
		RRCA
		RRCA		; Higher Nible, is now in Lower Nible area
		LD (hexHigh), A	; Save Nibble for later reference
		RRA			; Divide by 2 into Carry
				
					; Setup High Nible
		LD	C, A
		LD	B, 0
		LD	IX, HexCompact
		ADD	IX, BC	; Index position

	
					; Setup Lower Nible
		EX	AF, AF'

		LD	C, A
		LD	B, 0
		LD	IY, HexCompact
		ADD	IY, BC	; Index position

		LD HL, GenCharData
		LD A,	#08	; Line Counter
		
GenHexCharL
		
		EX AF, AF'

			LD BC, #08	; BC = Line Increment

			LD D, (IX)	; Hex Compact High char byte
			ADD IX, BC	; Next Line
			
			;LD E, (IY)	; Hex Compact Low char byte
			LD A, (IY)	; Hex Compact Low char byte
			ADD IY, BC

						; Extract High or low, depending on odd/even
			;LD A, E	; Low Nible
			;AND	#0F		; (extract Low)
			CALL ExtractHexLow
			
			LD  E, A	; Save Low Nible
			
			LD A, D		; High Nible
			;AND	#F0		; (extract High)
			CALL ExtractHexHigh
			;LD D, A	

			OR E	; Merge parts together
					
			LD (HL),A	; Resulting Gen char byte
			INC HL		; Point to Next output buffer byte

		EX AF, AF'
		DEC	A

		JR NZ, GenHexCharL
		
		LD HL, GenCharData
	RET

; Inputs:
;	A = Data Byte
; 	VAR hexLow
; Outputs:
;	A = Data Byte Low Nible
ExtractHexLow
		PUSH HL
			LD HL, hexLow
			Bit 0, (HL)
			JR NZ, MaskHexLow
			
			; Needs Shift
			RRCA
			RRCA
			RRCA
			RRCA
			
		MaskHexLow
			AND #0F
		POP HL
	RET

; Inputs:
;	A = Data Byte
; 	VAR hexHigh
; Outputs:
;	A = Data Byte High Nible
ExtractHexHigh
		PUSH HL
			LD HL, hexHigh
			Bit 0, (HL)
			JR Z, MaskHexHigh
			
			; Needs Shift Left
			RLCA
			RLCA
			RLCA
			RLCA
			
		MaskHexHigh
			AND #F0
		POP HL
	RET