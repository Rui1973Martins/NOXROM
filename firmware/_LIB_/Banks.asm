
; Make SURE that CMDADDR address is a match to b(??xx xx00 1111 1110)
ORG #8400 + #EE	;#ED ; NOTE: Removed LD A,D	; Save data

; Valid Bank Commands
; NOTE: A15 and A14 Must be != 0
; specially when WRITING since to issue FLASH commands, requires consecutive writes,
; without spurious accesses to ROM ADDRESSES, including I/R REFRESH address
BANKSET EQU #C0		;Set Bank (defined in I)
BANKWR	EQU #C1		;Write Bank (defined in I) at Address BC, data = AF


SendCMD
; Inputs:
;	I  = Command,
;	A' = Bank Number,
;	A  = [data], required for WRITE
;	BC = Addr
; Outputs:
; 	A = data, returned on READ
; TRASH: AF, AF', DE, HL

;	LD A,D		; Save Data

	LD HL, CMDADDR
	LD E,L
	LD D,H

SendCMD_DEHL		; ALTERNATE ENTRY POINT, for repeatable WRITES OR READS
        INC BC		; Compensate for LDI Decrement

	EX AF,AF'		; Recover Bank Number

		;SUB 4		; Compensate for EX (1), LDI (2) and CMDADDR (1) instruction R increments
		ADD A, #7D	; #7F-4+1 = #7D ; R register only counts with 7 bits, hence roll over is at #7F
		AND #7F		; Clear Bit 7, to cover overflow case.
		LD R,A		; Setup command Param

        EX AF,AF'
		LDI			; Critical set of instructions to force required bus addr pattern
CMDADDR	LD A,(BC)	; WARNING: Self modifying MEM position

	; NOTE: LD A, (BC) => #0A
	; NOTE: LD (BC), A => #02
RET


;SaveI	DEFB #00
;SaveR	DEFB #00


SetBankRead
;------------------------
; Inputs:
;	A  = Bank Number
;	BC = Addr
; Outputs:
;	A = data

; TRASH: AF, AF', DE, HL
	DI
		EX AF, AF'	; Save Bank Number	

		LD A, 0x0A		; LD A,(BC) = 0x0A
		LD (CMDADDR), A
		
		LD A,I		; Save I
		PUSH AF		; LD (SaveI),A
		
		LD A,R		; Save R
		PUSH AF		; LD (SaveR),A

			LD A,B		; Make Sure a READ Bank address (BC), always is INSIDE ROM address range, to read from Set Bank
			AND #3F
			LD B,A

			LD A, BANKSET	; Set Bank Command
			LD I,A

			;XOR A			; Read requires no INPUT DATA	

			CALL SendCMD

			EX AF,AF'	; Save result
		
		POP AF		; LD A, (SaveR)
		LD R,A

		POP AF		; LD A, (SaveI)
		LD I,A
				
		EX AF,AF'	; Restore result
	EI
RET


SetBankWrite
; InputParams:
;	A  = Bank Number,
;	D  = [data]
;	BC = Addr

; TRASH: AF, AF', DE, HL
	DI
		EX AF, AF'	; Save Bank Number

		LD A, 0x02		; LD (BC),A = 0x02
		LD (CMDADDR), A
		
		LD A,I		; Save I
		PUSH AF		; LD (SaveI),A
		
		LD A,R		; Save R
		PUSH AF		; LD (SaveR),A

				LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
				AND #3F
				LD B,A
		
				LD A, BANKWR	; Set Bank Command
				LD I,A

				LD A,D			; WRITE requires INPUT DATA
				
				CALL SendCMD

		;EX AF,AF'	; Save result
		
		POP AF		; LD A, (SaveR)
		LD R,A

		POP AF		; LD A, (SaveI)
		LD I,A
				
		;EX AF,AF'	; Restore result
	EI
RET



	; ; TRASH: AF, AF', DE, HL
	; CmdBank
		; ;EX AF,AF'	; Save Bank Number

			; LD A,I		; Save I
			; PUSH AF		; LD (SaveI),A
		
			; LD A,R		; Save R
			; PUSH AF		; LD (SaveR),A

		; ;EX AF,AF'	; Restore Bank Number

		; DI

			; LD I, A		; Set command

			; CALL SendCMD

			; POP AF		; LD A, (SaveR)
			; LD R,A

			; POP AF		; LD A, (SaveI)
			; LD I,A
		; EI
	; RET


; Outputs:
;	C = Manufacturer ID
;	B = Device ID
; TRASHES: All registers
ReadFlashID

; TRASH: AF, AF', DE, HL
	DI		
		LD A,I		; Save I
		PUSH AF		; LD (SaveI),A
		
		LD A,R		; Save R
		PUSH AF		; LD (SaveR),A

			; ===================================
			; REQUEST PRODUCT IDENTIFICATION MODE
			; ===================================
	
			LD A, BANKWR	; Set WRITE Bank Command	
			LD I,A

			LD A, 0x02		; LD (BC),A = 0x02
			LD (CMDADDR), A

				; 1st WriteCycle	
				LD	A,	0x01	; 01 = Bank Number, [A15, A14] = [0,1]
				LD	BC,  0x5555 & 0x3FFF	; Addr && MASK

				EX AF, AF'	; Save Bank Number

					; LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
					; AND #3F
					; LD B,A

				LD	A,  0xAA	; Required INPUT DATA

					; Inputs:
					;	I  = Command,
					;	A' = Bank Number,
					;	A  = [data], required for WRITE
					;	BC = Addr
					CALL	SendCMD


				; 2nd Write Cycle
				LD	A,	0x00	; 00 = Bank Number, [A15, A14] = [0,0]
				LD	BC,  0x2AAA & 0x3FFF	; Addr && MASK

				EX AF, AF'	; Save Bank Number

					; LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
					; AND #3F
					; LD B,A

				LD	A,  0x55	; Required INPUT DATA
				
				; If using SendCMD_DEHL, uncomment next 2 lines
					;DEC DE
					;DEC HL

					; Inputs:
					;	I  = Command,
					;	A' = Bank Number,
					;	A  = [data], required for WRITE
					;	BC = Addr
					CALL	SendCMD
				
				; 3rd Write Cycle
				LD	A,	0x01	; 01 = Bank Number, due to last 2 bits of 0x5555
				LD	BC,  0x5555 & 0x3FFF	; Addr && MASK

				EX AF, AF'	; Save Bank Number

					; LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
					; AND #3F
					; LD B,A

				LD	A,  0x90	; Required INPUT DATA

				; If using SendCMD_DEHL, uncomment next 2 lines
					;DEC DE
					;DEC HL
				
					; Inputs:
					;	I  = Command,
					;	A' = Bank Number,
					;	A  = [data], required for WRITE
					;	BC = Addr
					CALL	SendCMD
				
				; NO Require WAIT. for TimeIDA = 150ns

				; ===================================
				; ENTERED PRODUCT IDENTIFICATION MODE
				; ===================================

				; Read Addr 0x000000 contains Manufacturer ID = SST Manufacturer’s ID = 0xBF

				LD A, BANKSET	; Set Bank Command
				LD I,A

				LD A, 0x0A		; LD A,(BC) = 0x0A
				LD (CMDADDR), A

					; 1st Read Cycle
					XOR	A			; 00 = Bank Number
					LD	BC, 0x0000	; Addr

					EX AF, AF'	; Save Bank Number

						; LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
						; AND #3F
						; LD B,A

					
					;LD	A,  0x00	; Read DOES NOT Require INPUT DATA
				
					; If using SendCMD_DEHL, uncomment next 2 lines
						;DEC DE
						;DEC HL

						; Inputs:
						;	I  = Command,
						;	A' = Bank Number,
						;	A  = [data], required for WRITE
						;	BC = Addr
						CALL	SendCMD

					;=============================
					LD	A,(0x0000)	; HACK for NOW, Since first READ after WRITE is wrong (WR is still enabled)
					;=============================					
					LD	C,A		; Keep Manufacturer ID

				; Addr 0x000001 contains Device ID
				;	SST39SF010A	Device ID = 0xB5
				;	SST39SF020A	Device ID = 0xB6
				;	SST39SF040	Device ID = 0xB7

					; NOTE: Same Bank number and read mode, hence no need to setBank
					LD	A,(0x0001)
					LD	B, A
				
				; Keep for later
				PUSH BC
				
				; ===================================
				; REQUEST EXIT PRODUCT IDENTIFICATION
				; ===================================

				LD A, BANKWR	; Set WRITE Bank Command	
				LD I,A

				LD A, 0x02		; LD (BC),A = 0x02
				LD (CMDADDR), A

					; 1st WriteCycle	
					XOR	A			; 00 = Bank Number
					LD	BC, 0x0000 & 0x3FFF	; Addr && MASK	; NOTE: Any Address will do

					EX AF, AF'	; Save Bank Number

						; LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
						; AND #3F
						; LD B,A

					LD	A,  0xF0	; Required INPUT DATA
					
					; If using SendCMD_DEHL, uncomment next 2 lines
						;DEC DE
						;DEC HL

						; Inputs:
						;	I  = Command,
						;	A' = Bank Number,
						;	A  = [data], required for WRITE
						;	BC = Addr
						CALL	SendCMD
				
				; NO Require WAIT. for TimeIDA = 150ns
				
				; ==================================
				; EXITED PRODUCT IDENTIFICATION MODE
				; ==================================

				
				; ===================
				; Return to Read Mode
				; ===================

				LD A, BANKSET	; Set READ Bank Command	
				LD I,A

				LD A, 0x0A		; LD A,(BC) = 0x0A
				LD (CMDADDR), A
				
					; ReadCycle	
					XOR	A			; 00 = Bank Number
					LD	BC, 0x0000 & 0x3FFF	; Addr && MASK	; NOTE: Any Address will do

					EX AF, AF'	; Save Bank Number

						; LD A,B		; Make Sure a WRITE Bank address (BC), always outputs INSIDE ROM address range, to prevent writing RAM
						; AND #3F
						; LD B,A

					;LD	A,  0x00	; Read DOES NOT Require INPUT DATA
					
					CALL	SendCMD
				
				POP BC

			;EX AF,AF'	; Save result
		
		POP AF		; LD A, (SaveR)
		LD R,A

		POP AF		; LD A, (SaveI)
		LD I,A
				
		;EX AF,AF'	; Restore result
	EI
RET


ReadID
	; REQUEST PRODUCT IDENTIFICATION MODE

	; 1st WriteCycle	
	LD	A,	0x01	; 01 = Bank Number, MUST be Out of ROM area and Chip requires either all Vl or Vh
	LD	BC,  0x5555	; Addr
	LD	D,  0xAA	; Data
	CALL	SetBankWrite
	
	; 2nd Write Cycle
	LD	A,	0x00	; 00 = Bank Number, MUST be Out of ROM area and Chip requires either all Vl or Vh
	LD	BC,  0x2AAA	; Addr
	LD	D,  0x55	; Data
	CALL	SetBankWrite
	
	; 3rd Write Cycle
	LD	A,	0x01	; 01 = Bank Number, due to last 2 bits of 0x5555
	LD	BC,  0x5555	; Addr
	LD	D,  0x90	; Data
	CALL	SetBankWrite
	
	; ENTERED PRODUCT IDENTIFICATION MODE

	; Addr 0x000000 contains Manufacturer ID = SST Manufacturer’s ID = 0xBF

		; 3rd Write Cycle
		XOR	A			; 00 = Bank Number
		LD	BC, 0x0000	; Addr
		CALL	SetBankRead
	
		LD	C,A

	; Addr 0x000001 contains Device
	;	SST39SF010A	Device ID = 0xB5
	;	SST39SF020A	Device ID = 0xB6
	;	SST39SF040	Device ID = 0xB7

		; NOTE: Same Bank number and read mode, hence no need to change
		LD	A,(0x0001)
		LD	B, A
	
	; Keep for later
	PUSH BC
	
	; REQUEST EXIT PRODUCT IDENTIFICATION

	; 1st WriteCycle	
	XOR	A			; 00 = Bank Number
	LD	BC, 0x0000	; Addr
	LD	D,  0xF0	; Data
	CALL	SetBankWrite
	
	; Require WAIT ? remaining time from T-IDA = 150ns
	
	; EXITED PRODUCT IDENTIFICATION MODE
	
	POP BC
RET

; InputParams:
;	A  = Bank Number,
;	D  = [data]
;	BC = Addr


FakeBoot
	DI			; Disable Interrupts
	IM 0		; Set interrupt mode 0
	LD SP,#0000	; Reset Stack Pointer
	XOR A
	LD I,A		; Reset I Register
	LD A,#7F	; Preset for overflow to Zero on boot (after JP)
	LD R,A		; RESET R Register
	JP #0000	; Reset Program Counter (PC) 

	
; WARNING: This code, must be correctly aligned so that RSTADDR = #00FE
; PagedBoot
	; LD	HL, #00FE	; PREPARE FOR RST bank paging instruction
	; LD	DE, #00FE	

	; DI			; Disable Interrupts
	; IM 0		; Set interrupt mode 0
	; LD SP,#0002	; Reset Stack Pointer, prepared for RST 00h
	; XOR A
	; LD I,A		; Reset I Register
	; LD A,#7E	; Preset for overflow to Zero on Reset, to provide 00 to Bank switching (on RST)
	; LD R,A		; RESET R Register

	; LDI			; Critical set of instructions to force required bus addr pattern
; RSTADDR	
	; RST 00h		; Reset Program Counter (PC) [This instruction MUST be at Addr #00FE]
				; ; NOTE: It will try to write previous (PC) to ROM address 1 and 0, but it will fail.
