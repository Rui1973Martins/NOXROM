; NOXROM TEST

include "_REF_/REF.asm"
include "_REF_/COLORS.asm"
include "_REF_/KEYS.asm"

ORG #8000

MAIN_ENTRY		; Required For TESTING over BASIC
	PUSH IY
	PUSH BC
	
		CALL TEST

	POP BC
	POP IY		; To allow clean exit do BASIC
RET

; TODO, Move to RAM file
;	SST39SF010A	Device ID = 0xB5
;	SST39SF020A	Device ID = 0xB6
;	SST39SF040	Device ID = 0xB7
FLASH_ID	DEFW	0x0000	; Should become B5BF, B6BF r B7BF 	
			DEFB	0x00; Zero String terminator

include "_LIB_/Keyboard.asm"
include "_LIB_/KeyTable.asm"

PaintAttrInfoRow
	LD DE, #AC00		; PIxel Coords YX
	CALL	ColorADA
	EX DE, HL

		LD 	A, BRIGHT + ( BLACK<<3 + WHITE )
		CALL	PaintAttrRow

		LD 	A, BRIGHT + ( BLACK<<3 + GREEN )
		;CALL	PaintAttrRow	; Fall through
;RET

; A = Attr color
; HL = AttrAddr
PaintAttrRow
		LD B, 32
PaintAttr
		LD (HL), A
		INC HL
		DJNZ PaintAttr
RET

AnimateGateClose	
	LD A, GATE_LINES

AnimateGateCloseLoop
	HALT

	DEC A
	PUSH AF
		CAll PaintGate
	POP AF
	
	;Calc DE, based on A
	;CALL DrawDangerRow
	
	JR NZ, AnimateGateCloseLoop
RET
	
AnimateGateOpen	
	LD A, -1

AnimateGateOpenLoop
	HALT

	INC A
	PUSH AF
		CAll PaintGate
	POP AF

	;Calc DE, based on A
	;CALL DrawDangerRow

	CP GATE_LINES
	JR NZ, AnimateGateOpenLoop

RET

TRANSITION
	CALL AnimateGateClose
	CALL AnimateGateOpen

	LD DE, SCRN
	CALL DrawDangerRow
	
	LD HL, 184*256 + 0	; Linha 184	// TODO Optimize value
	CALL PixelAD
	CALL DrawDangerRow

RET

; Inputs:
;	A = ID
; Output:
;	BC = String Addr
GetFlashIdStr
	CP FLASH_ID_512
	JR Z, flashId512
	CP FLASH_ID_256
	JR Z, flashId256
	CP FLASH_ID_128
	JR Z, flashId128

flashId000	LD BC, MSG_000
	RET

flashId512	LD BC, MSG_512
	RET
	
flashId256	LD BC, MSG_256
	RET
	
flashId128	LD BC, MSG_128
	RET



InitMenu
	LD DE, 11*8 + (2*8 + 4) << 8	; Third line, plus 4 pixels in Y, and 2 Chars in X
	LD BC, MSG_NOXROM
	CALL PrintZStrAt

	CALL ReadFlashID
	LD	(FLASH_ID), BC	; Keep ID in RAM as CONSTANT
	
	LD A,(FLASH_ID+1)	; +0 = Manufacturer ID, +1 = Device ID
	CALL GetFlashIdStr
	;LD BC, FLASH_ID	; DEBUG
	CALL PrintZStr
	
	;CALL DrawHeader
	;CALL DrawTitle

	CALL PaintTitle
	CAll PaintMenu
	CALL DrawMenu
	
	CALL PaintAttrInfoRow
RET

TEST
	XOR A		; 0 = BLACK Border
	OUT (ULA), A
	
	HALT
	
	CALL ReadFlashID
	
	LD	(FLASH_ID), BC	; Keep ID in RAM as CONSTANT

	CALL TRANSITION
	
	; LD DE, SCRN
	; LD HL, FData
	; CALL	CharDataBlit

	; LD	A, #00 
	; CALL GenHexChar
	; LD	DE, SCRN + 1
	; CALL CharDataBlit

	; LD	A, #11 
	; CALL GenHexChar
	; LD	DE, SCRN + 2
	; CALL CharDataBlit

	; LD	A, #22 
	; CALL GenHexChar
	; LD	DE, SCRN + 3
	; CALL CharDataBlit
	
	; LD	A, #33 
	; CALL GenHexChar
	; LD	DE, SCRN + 4
	; CALL CharDataBlit

	; LD	A, #FE 
	; CALL GenHexChar
	; LD	DE, SCRN + 5
	; CALL CharDataBlit

	; LD DE, 1*8 + (2*8 + 4) << 8	; Third line, plus 4 pixels in Y, and 2 Chars in X
	; LD BC, TEST_MSG1
	; CALL PrintZStrAt

	; LD BC, TEST_MSG2
	; CALL PrintZStr

	CALL InitMenu
	
ANYKEY1
	HALT
	CALL ScrollInfoRow	; Animate
	
	; Press AnyKey
	XOR A
	IN A,(ULA)	; Read All Keys - Check for any Key pressed
	AND #1F		; Only 5 Keys valid in a ROW
	CP #1F
	JP Z, ANYKEY1

	CALL ReadKeyboard

	CALL ReadAlphaKey
	CP 0
	JP	Z, ANYKEY1
	
	; CHECK if Key is within bounds (A .. last entry =< Z)
	;if key >= 'A' AND KEY >= 'Z', THEN ROM SELECTION
	
	CP 'A'
	JP M, TestOtherKeys
	
	CP 'Z'+1
	JP P, TestOtherKeys
	
		SUB 'A'		; Extract  Index from Alpha Key Order
		;LD A, WHITE
		CALL MenuOption


TestOtherKeys
	CALL KBHAND

	JP ANYKEY1	; debug
RET


KBHAND
KBROW3 LD A,(KEYBUF+3)	; Probably wrong, since ReadKeyboard was CHANGED from #FEFE to #7FFE
KBKEY1 CP KEY1
       JR NZ,KBKEY2
       CALL ACKEY1
       LD A,(KEYBUF+3)

KBKEY2 CP KEY2
       JR NZ,KBKEY3
       CALL ACKEY2
       LD A,(KEYBUF+3)

KBKEY3 CP KEY3
       JR NZ,KBKEY4
       CALL ACKEY3
       LD A,(KEYBUF+3)

KBKEY4 CP KEY4
       JR NZ,KBKEY5
       CALL ACKEY4
       LD A,(KEYBUF+3)

KBKEY5 CP KEY5
       JR NZ, KBROW4	;KBKEY6
       CALL ACKEY5

KBROW4 LD A,(KEYBUF+4)
KBKEY6 CP KEY6
       JR NZ,KBKEY7
       CALL ACKEY6
       LD A,(KEYBUF+4)

KBKEY7 CP KEY7
       JR NZ,KBKEY8
       CALL ACKEY7
       LD A,(KEYBUF+4)

KBKEY8 CP KEY8
       JR NZ,KBKEY9
       CALL ACKEY8
       LD A,(KEYBUF+4)

KBKEY9 CP KEY9
       JR NZ,KBKEY0
       CALL ACKEY9
       LD A,(KEYBUF+4)

KBKEY0 CP KEY0
       JR NZ,KBROW7
       CALL ACKEY0
	   
KBROW7	LD A,(KEYBUF+7)
KBKEYSP CP KEYSP
       RET NZ
       CALL ACKEYSP
RET


ACKEY1	NOP
	NOP
	LD A, BLUE
	CALL MenuOption
RET


ACKEY2	NOP
	NOP
	LD A, RED
	CALL MenuOption
RET


ACKEY3	NOP
	NOP
	LD A, MAGENTA
	CALL MenuOption
RET

ACKEY4	NOP
	NOP
	LD A, GREEN
	CALL MenuOption
RET

ACKEY5	NOP
	NOP
	LD A, CYAN
	CALL MenuOption
RET

ACKEY6	NOP
	NOP
	LD A, YELLOW
	CALL MenuOption
RET

ACKEY7	NOP
	NOP
	LD A, WHITE
	CALL MenuOption
RET

ACKEY8	NOP
	NOP
	LD A, 8
	CALL MenuOption
RET

ACKEY9	NOP
	NOP
	LD A, 9
	CALL MenuOption
RET

ACKEY0	NOP
	NOP
	LD A, BLACK
	CALL MenuOption
RET

ACKEYSP NOP
	NOP
	CALL TRANSITION
	CALL InitMenu
RET

MenuOption
	HALT

	OUT (ULA), A	; Set Background Color

	PUSH AF
	
	; HIGHLIGHT SELECTION
	
	
		CALL CLSC	; A = Color

NOKEY1
		; DO NOT Press AnyKey
		XOR A
		IN A,(ULA)	; Read All Keys - Check for NO Key pressed
		AND #1F; Test only 5 Keys
		CP #1F
		JP NZ, NOKEY1

	
		HALT
			; COPY SECTION	(8K)
		HALT
			; COPY SECTION	(8K) = 16K
		HALT
			; COPY SECTION	(8K)
		HALT
			; COPY SECTION	(8K) = 32K
		HALT
			; COPY SECTION	(8K)
		HALT
			; COPY SECTION	(8K) = 48K

; WARNING: MUST USE SPECIAL CASE of BANK READ, SO THAT INTERRUPTS ARE NEVER ENABLED BETWEEN
; BANK CHANGE and FAKE BOOT

	POP AF;	Bank Number (AKA Color)
	LD BC, #0003	; Fourth Bank Address, usually changes meaningfully
	CALL	SetBankRead

DI	; HACK FIX

	; Show Bank Contents
;	OUT (ULA), A	; Set Background Color

; CAN NOT HALT HERE, since There is no guarantee that ROM file has support for INTERRUPT Handler at 38h
	; HALT
	; HALT
	; HALT
	; HALT
	
	JP FakeBoot	; DEBUG
RET

include "_LIB_/Banks.asm"
include "_LIB_/ClearScreen.asm"

; Inputs
; HL = Screen Data Addr
DUMPSCR
	LD BC, 6192	; Screen Data Length
	LD DE, SCRN

	LDIR
RET


; Inputs:
;	A = Byte being scrolled to enter (from right)
;	HL = Pixel Position Y,X = H,L
; Outputs:
;	A = Byte being scrolled to enter, updated
ScrollRow
	EX AF, AF'
		CALL PixelAD	; Calc Pixel Address
	EX AF, AF'

	EX DE, HL		; Pixel Addr into HL
	LD BC, 32		; Number of bytes in 1 screen line

; Inputs:
;	A = Byte being scrolled to enter (from right)
;	HL= Line buffer start address
;	BC = Line Byte count, B MUST be Zero (0)
; Outputs:
;	A = Byte being scrolled to enter, updated
ScrollLine
	ADD	HL, BC		; Find Right most position
	LD	B, C		; Prepare for DJNZ

	RLA				; Rotate First Byte on the right most position, to fill Carry
	PUSH AF			; Save scrolled byte	
	
ScrollLineL0
	DEC HL			; Process one less than width
	LD	A, (HL)		; Load first byte to scroll
	RLA				; Rotate Carry in, and update carry with left most bit
	LD	(HL), A		; Save Changed byte
	DJNZ ScrollLineL0

	POP AF			; Restore scrolled byte	
RET

lineByteBuf0 DEFB #18
lineByteBuf1 DEFB #18
lineByteBuf2 DEFB #00
lineByteBuf3 DEFB #81
lineByteBuf4 DEFB #81
lineByteBuf5 DEFB #00
lineByteBuf6 DEFB #18
lineByteBuf7 DEFB #18

; Inputs:
;;;;	HL = Pixel Position of line 1 of 8, Y,X = H,L
; Outputs:
ScrollRowChar
	; process 1st line
	LD A, (lineByteBuf0)
	LD HL, #AC00	; Y = 21*8+4+0 = 168+4 = 172 <=> AC
	CALL ScrollRow
	LD (lineByteBuf0), A

	; process 2nd line
	LD A, (lineByteBuf1)
	LD HL, #AD00	; Y = 21*8+4+1 = 168+5 = 173 <=> AD
	CALL ScrollRow
	LD (lineByteBuf1), A
		
	; process 3rd line
	LD A, (lineByteBuf2)
	LD HL, #AE00	; Y = 21*8+4+2 = 168+6 = 174 <=> AE
	CALL ScrollRow
	LD (lineByteBuf2), A
		
	; process 4th line
	LD A, (lineByteBuf3)
	LD HL, #AF00	; Y = 21*8+4+3 = 168+7 = 175 <=> AF
	CALL ScrollRow
	LD (lineByteBuf3), A
		
	; process 5th line
	LD A, (lineByteBuf4)
	LD HL, #B000	; Y = 21*8+4+4 = 168+8 = 176 <=> B0
	CALL ScrollRow
	LD (lineByteBuf4), A
		
	; process 6th line
	LD A, (lineByteBuf5)
	LD HL, #B100	; Y = 21*8+4+5 = 168+9 = 177 <=> B1
	CALL ScrollRow
	LD (lineByteBuf5), A
		
	; process 7th line
	LD A, (lineByteBuf6)
	LD HL, #B200	; Y = 21*8+4+6 = 168+10 = 178 <=> B2
	CALL ScrollRow
	LD (lineByteBuf6), A
		
	; process 8th line
	LD A, (lineByteBuf7)
	LD HL, #B300	; Y = 21*8+4+7 = 168+11 = 179 <=> B3
	CALL ScrollRow
	LD (lineByteBuf7), A

RET

INFO_RESET_COUNT EQU 8
INFO_BUFFER_SIZE EQU 1+26+1+10+1
InfoScrollPxCount	DEFB INFO_RESET_COUNT
InfoScrollIndex 	DEFB 0

InfoBuffer			DB " ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789;" ; TODO, use a ZERO terminated string.

ScrollInfoRow
	LD A, (InfoScrollPxCount)
	CP INFO_RESET_COUNT
	JR NZ, ScrollInfoRowChar
	
	LD HL, InfoBuffer
	LD	A, (InfoScrollIndex)
	LD	E, A
	LD	D, 0
	ADD HL, DE
	
	LD	A, (HL)		; Get Char ID

	; Load Font Char TODO (HACK for Now)
;	SUB 'A'			; Subtract Char 'A' Index
;	ADD A,A			;*2
;	ADD A,A			;*4
;	ADD A,A			;*8
;	LD	E,A
;	LD	D,0

;	LD  HL, FData
;	ADD	HL, DE

		CALL GetFontCharAddr

	LD DE, lineByteBuf0
	LD BC, 08
	LDIR

ScrollInfoRowChar

	CALL ScrollRowChar
	
	LD	HL, InfoScrollPxCount
	DEC (HL)
	RET NZ

	LD	A, INFO_RESET_COUNT		; RESET Counter
	LD	(HL), A					; Save Value
	
	LD	HL, InfoScrollIndex
	INC (HL)					; increment and Check Index	
	LD A, (HL)
	CP	INFO_BUFFER_SIZE		; Use a ZERO terminated String instead.
	RET NZ
	
	XOR	A						; RESET to start ; TODO use a call back instead.
	LD (HL), A
RET

PaintPosAddr DEFW ATTR	; TODO move to RAM file

; inputs:
;	A = Start line (from 0 to 9)
PaintGate
	; Setup Functions
	LD	IX, IXFuncAttrBlit
	LD	IY, IYFuncAttrInc

	LD	DE, ATTR
	LD	(PaintPosAddr), DE
	
	LD	L, A			; Start Line
	LD	H, 0
	LD	DE, TopGateTabIdx
	ADD	HL,DE
	EX	DE,HL
	
	PUSH AF	
		CALL PaintGateLoop0
		
;		LD	DE, SCRN
;		CALL DrawDangerRow

	POP AF

	LD	HL, ATTR+(12*32)	; Setup for multiply
	LD	E, 32
	LD	D, 0
	AND A
	JR Z, PaintGateSetupAddr	; NOTE: uses AF

	LD	B, A		; Count for multiply
	
PaintGateMul
	ADD HL,DE
	DJNZ PaintGateMul 
	
PaintGateSetupAddr
	LD (PaintPosAddr), HL	; Update Addr
	
	
;	LD L, A			; Start Line
;	LD H, 0
	LD DE, BotGateTabIdx
;	ADD HL,DE
;	EX DE,HL

	XOR A			; Always start at line zero
	; fall through
	
PaintGateLoop0

	LD A, (DE)	; Get TabIdx
	CP #FF		; FF defines the end of sequence
	RET Z
	
	INC	DE		; prepare for next byte

	PUSH DE

		ADD A,A		; *2, since Word Addr takes 2 bytes
		LD E, A
		LD D, 0
		
		LD HL, GateTypeTab
		ADD HL, DE	; Determine Table indexed addr

		LD A, (HL)	; Load Stream Addr in to HL
		INC HL
		LD H,(HL)
		LD L,A
		
		;LD HL, GateLineT0
		LD DE, (PaintPosAddr);

			CALL RLETabFunc

		LD (PaintPosAddr), DE
		
	POP DE
	
	JR PaintGateLoop0
;RET

include "_LIB_/Screen.asm"
include "_LIB_/Text.asm"
include "_LIB_/Menu.asm"

include "_REF_/GATE.asm"
include "_REF_/HEX-COMPACT.asm"
include "_REF_/FONT.asm"

Include "_REF_/MenuData.asm"


