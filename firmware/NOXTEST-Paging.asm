; NOXROM TEST

include "_REF_/REF.asm"
include "_REF_/COLORS.asm"
include "_REF_/KEYS.asm"

ORG #6000

MAIN_ENTRY
	PUSH IY
	PUSH BC
	
		CALL TEST

	POP BC
	POP IY
RET

include "_LIB_/Keyboard.asm"


TEST

ANYKEY1
	; Press AnyKey
	XOR A
	IN A,(ULA)	; Read All Keys - Check for nay Key pressed
	AND #1F; Test only 5 Keys
	CP #1F
	JP Z, ANYKEY1

	CALL ReadKeyboard

	CALL KBHAND
	
	JP ANYKEY1	; debug
RET


KBHAND
KBROW3 LD A,(KEYBUF+3)
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
       RET NZ
       CALL ACKEY0
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
RET

ACKEY9	NOP
	NOP
RET

ACKEY0	NOP
	NOP
	LD A, BLACK
	CALL MenuOption
RET

MenuOption
	HALT

	OUT (ULA), A	; Set Background Color

	PUSH AF
	
		CALL CLSC	; A = Color

		HALT
		HALT
		HALT
		HALT
		HALT

ANYKEY2
	; Press AnyKey
	XOR A
	IN A,(ULA)	; Read All Keys - Check for nay Key pressed
	AND #1F; Test only 5 Keys
	CP #1F
	JP Z, ANYKEY2

	
	POP AF;	Bank Number (AKA Color)
	LD BC, #0000	; First Bank Address
	CALL	SetBankRead

	; Show Bank Contents
	OUT (ULA), A	; Set Background Color

RET

include "_LIB_/Banks.asm"
include "_LIB_/ClearScreen.asm"

DUMPSCR
	
RET