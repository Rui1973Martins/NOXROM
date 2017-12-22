; TOP ROW IS ROW 1
KEYBUF				; START @	#FEFE	#7FFE
		DEFB #FF	; ROW4,		LEFT	RIGHT
		DEFB #FF	; ROW3,		LEFT	RIGHT
		DEFB #FF	; ROW2,		LEFT	RIGHT
		DEFB #FF	; ROW1,		LEFT	RIGHT
		DEFB #FF	; ROW1,		RIGHT	LEFT
		DEFB #FF	; ROW2,		RIGHT	LEFT
		DEFB #FF	; ROW3,		RIGHT	LEFT
		DEFB #FF	; ROW4,		RIGHT	LEFT

ReadKeyboard
		LD DE,KEYBUF
		LD BC,#FEFE
		;	LD BC, #7FFE
KeyboardLoop
		IN A,(C)
		OR #E0			;Set Bits765
		LD (DE),A
		INC DE
		RLC B
		;	RRC B
		JP C,KeyboardLoop
RET


ReadAlphaKey
		LD	DE, KEYBUF
		LD	BC,	#08FF	; B = 8 rows, C = (Start Count -1), due to INC C below
	
CheckKeyPressed
		LD	A, (DE)
		CP	#FF			; When no key is pressed on a row buffer must contain #FF
		JR	NZ,	KeyPressed	; Leave with B count = Row Number +1
		INC	DE			; Go to Next Row
		DJNZ	CheckKeyPressed	;
		XOR A			; A = 00, mean no Key is pressed
	RET
	
KeyPressed
		;DEC B		; Optmized OUT
		LD D, B			; D = ROW Number
		LD BC,#05FF		; B = Row as 5 Keys	; C = (Start Count -1), due to INC C below

CheckRowKeyPressed
		INC C			; Count
		RRA				;
		JR	NC,	PressedKeyCode
		DJNZ CheckRowKeyPressed
		
		; Should NEVER REACH HERE, but just in case
		XOR	A			; A = 00, mean no Key is pressed
	RET
	
PressedKeyCode
		; Set input for KeyAlphaLookUp

;RET	; Falltrough

; Inputs:
;	D = ROW number	(1 to 8)
;	C = Key position
; Outputs:
;	A = KeyCode
; TRASHES: B = 0, HL = KeyTable + BC
KeyAlphaLookUp
	LD	HL, KEYTABLE_ALPHA
	; FallTrough
	
; Inputs:
;	D = ROW number	(1 to 8)
;	C = Key position
; Outputs:
;	A = KeyCode
; TRASHES: B = 0
KeyLookUp
		LD B, D		; B = D = Row number
		;INC B		; Optmized OUT	; Adjust for exit 
		LD A, -5	; will reset to A = 0

KeyLookUpMult
		ADD A, 5	; 5 keys per row
		DJNZ	KeyLookUpMult
		
		ADD A, C	; Final Offset = Base Offset + Key position
		LD	B, #00
		LD	C, A	; Final offset

		ADD	HL, BC	;Index the required table and fetch Key Code
		LD	A,(HL)
	RET