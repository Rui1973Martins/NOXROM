MENU_ITEM_BANK	EQU 0
MENU_ITEM_DATA	EQU 2
MENU_ITEM_NAME	EQU	4

MENU_TAB
	DEFW	MENU_ITEM_A
	DEFW	MENU_ITEM_B
	DEFW	MENU_ITEM_C
	DEFW	MENU_ITEM_D
	DEFW	MENU_ITEM_E
	DEFW	MENU_ITEM_F
	DEFW	MENU_ITEM_G
	DEFW	MENU_ITEM_H
	DEFW	MENU_ITEM_I
	DEFW	MENU_ITEM_J
	DEFW	MENU_ITEM_K
	DEFW	MENU_ITEM_L
	DEFW	MENU_ITEM_M
	DEFW 	#0000


MENU_ITEM_SIZE EQU	4

MENU_ITEM_A
	DEFB	#01, #00
	DEFW	#0000
	DEFM	"CARTRIDGE A", 0x00	; NULL Terminated String
	

MENU_ITEM_B
	DEFB	#02, #00
	DEFW	#0000
	DEFM	"CARTRIDGE B", 0x00	; NULL Terminated String

MENU_ITEM_C
	DEFB	#03, #00
	DEFW	#0000
	DEFM	"CARTRIDGE C", 0x00	; NULL Terminated String

MENU_ITEM_D
	DEFB	#04, #00
	DEFW	#0000
	DEFM	"COMMANDO", 0x00	; NULL Terminated String

MENU_ITEM_E
	DEFB	#05, #00
	DEFW	#0000
	DEFM	"RENEGADE", 0x00	; NULL Terminated String

MENU_ITEM_F
	DEFB	#06, #00
	DEFW	#0000
	DEFM	"PING-PONG", 0x00	; NULL Terminated String
	
MENU_ITEM_G
	DEFB	#07, #00
	DEFW	#0000
	DEFM	"GREEN Beret", 0x00	; NULL Terminated String
	
MENU_ITEM_H
	DEFB	#08, #00
	DEFW	#0000
	DEFM	"IKARI WARRIORS", 0x00	; NULL Terminated String
	
MENU_ITEM_I
	DEFB	#09, #00
	DEFW	#0000
	DEFM	"RAMBO", 0x00		; NULL Terminated String
	
MENU_ITEM_J
	DEFB	#0A, #00
	DEFW	#0000
	DEFM	"CARTRIDGE J", 0x00	; NULL Terminated String

MENU_ITEM_K
	DEFB	#0B, #00
	DEFW	#0000
	DEFM	"CARTRIDGE K", 0x00	; NULL Terminated String

MENU_ITEM_L
	DEFB	#0C, #00
	DEFW	#0000
	DEFM	"CARTRIDGE L", 0x00	; NULL Terminated String

MENU_ITEM_M
	DEFB	#0D, #00
	DEFW	#0000
	DEFM	"CARTRIDGE M", 0x00	; NULL Terminated String




