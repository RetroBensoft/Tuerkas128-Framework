;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; E V E N T S   F U N C T I O N S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _BEGIN_CODE_EVENTS
_BEGIN_CODE_EVENTS

PUBLIC T128_SetGameVarsB0, T128_Set1bitFlagsB0, T128_UpdateTimersB0, T128_Check1bFlagB0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_Check1bFlagB0
;
; Check bit 
;
; Input:
;   a = Number of 1bitFlag
;
; Output:
;   Z  = 1biftFlag is unset
;   NZ = 1bitflag is set
;   b  = opcode  for set [bit within 1bitFlag], (hl)
;   hl = address of 1bitFlag
;
T128_Check1bFlagB0:	ld		b, a
					and		%11111000
					rrca
					rrca
					rrca								
					ld		c, a						; c = byte of 1bitFlag (0-31)
					ld		a, b
					and		%00000111					; a = bit within 1bitFlag (0-7)
					rlca	
					rlca
					rlca
					or		BIT_N_HL					; opcode for bit [bit within 1bitFlag], (hl)
					ld		(C1F_SMC_01+1), a			
					or		$80							; set instruction opcode = BIT_N_HL + $80
					ld		b, 0
					ld		hl, T128_1bitFlags
					add		hl, bc
					ld		b, a						
C1F_SMC_01:			bit		0, (hl)						; bit [bit within 1bitFlag], (hl)
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SetSolidColB0
;
; Update FSM_SolidColFlags
; Update FSM_SolidCol_x, FSM_SolidCol_y with Main Char position
;
; Input:
;   a  = Collision Flag (FSM_SOLID_LEFT, FSM_SOLID_RIGHT, FSM_SOLID_UP, FSM_SOLID_DOWN)
;   ix = Main Char sprite data
;
T128_SetSolidColB0:	ld		(FSM_SolidColFlags), a
					ld		a, (ix+6)
					ld		(FSM_SolidCol_x), a
					ld		a, (ix+8)
					ld		(FSM_SolidCol_y), a					
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_UpdateGameVar
;
; Update GameVar
;
; Input:
;   hl = GameVar info address
;     0 - Address of GameVar	[WORD]
;     2 - Operation				[BYTE]
;			T128_GAMEVAR_INC8   = Increment 8 bit value
;			T128_GAMEVAR_DEC8   = Decrement 8 bit value
;			T128_GAMEVAR_SET8   = Set 8 bit value. If new value != 0 then Init Timer
;			T128_GAMEVAR_TOGG   = Toggle (New value = Old value XOR $ff). If new value != 0 then Init Timer
;           T128_GAMEVAR_ADDDEC = Add a number (0 to 9) at a given position of decimal display
;           T128_GAMEVAR_SUBDEC = Substract a number (0 to 9) at a given position of decimal display
;
;           T128_GAMEVAR_SETDEC = Set a decimal display value. If VALUE=0 then set decimal display to 0.
;                                 Otherwise set decimal display to the default value of the decimal display
;			T128_GAMEVAR_SETDEC is useless)
;
;     3 - Parameter				[BYTE] 
;           HIGH LIMIT for operation T128_GAMEVAR_INC8
;           VALUE for operation T128_GAMEVAR_SET8, T128_GAMEVAR_SETDEC
;           PPPPNNNN for operation T128_GAMEVAR_ADDDEC, T128_GAMEVAR_SUBDEC
;               where PPPP = Position (0=units 1=tens 2=hundreds 3=thousands, etc.)
;                     NNNN = Number (0 to 9)
;
; Output
;   hl = GameVar info address + 4
;   de = Address of GameVar
;   Registers ix and iy must keep the same value. Don't forget to push/pop
;
T128_UpdateGameVar:	ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = Address of GameVar 
					inc		hl
					ld		a, (hl)						; a = operation
					inc		hl
					ld		b, (hl)						; b = parameter
					inc		hl


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_UpdateGameVar2
;
; Update GameVar
;
; Input: 
;   de = Address of GameVar
;   a  = Operation (same as T128_UpdateGameVar)
;   b  = Parameter (same as T128_UpdateGameVar)
;
; Output
;   de = Address of GameVar
;   Registers ix and iy must not be modified. Don't forget to push/pop
;
T128_UpdateGameVar2:
;
; T128_GAMEVAR_INC8
;					
					cp		T128_GAMEVAR_INC8
					jr		nz, UGV_Label_02
					ld		a, (de)
					cp		b
					jp		z, UGV_Label_99
					inc		a
					jp		UGV_Label_99
;
; T128_GAMEVAR_DEC8
;					
UGV_Label_02:		cp		T128_GAMEVAR_DEC8
					jr		nz, UGV_Label_04
					ld		a, (de)
					or		a
					jp		z, UGV_Label_99
					dec		a
					jp		UGV_Label_99
;
; T128_GAMEVAR_SET8
;					
UGV_Label_04:		cp		T128_GAMEVAR_SET8
					jr		nz, UGV_Label_05
					ld		a, b
					or		a
					call	nz, UGV_Label_80			; If GameVar is On then init Timer					
					jp		UGV_Label_99
;
; T128_GAMEVAR_TOGG
;					
UGV_Label_05:		cp		T128_GAMEVAR_TOGG
					jr		nz, UGV_Label_06
					ld		a, (de)
					xor		$ff
					or		a
					call	nz, UGV_Label_80			; If GameVar is On then init Timer
					jp		UGV_Label_99
;
; T128_GAMEVAR_ADDDEC
;					
UGV_Label_06:		cp		T128_GAMEVAR_ADDDEC
					jr		nz, UGV_Label_10
					push	ix
					ld		ixl, e
					ld		ixh, d						; ix = GameVar address
					; CHECK FOR ASSOCIATED DIGITAL DISPLAY
					exx
					ld		a, (ix+7)
					ld		l, a
					ld		h, (ix+8)
					or		h
					jr		z, UGV_Label_09				; Associated digital display?
					; SET UP DECIMAL ADDITION
					call	UGV_Label_70
					ld		c, 10
					; DECIMAL ADDITION
					ld		b, a					
UGV_Loop_01:		ld		a, (hl)					
					add		a, b
					ld		(hl), a
					cp		c
					jr		c, UGV_Label_08
					ld		a, e
					cp		d
					jr		nz, UGV_Label_07
					; SET ALL DIGITS = 9
					ld		b, e
					ld		a, 9
UGV_Loop_02:		ld		(hl), a
					inc		hl
					djnz	UGV_Loop_02
					jr 		UGV_Label_08
					; DECIMAL CARRY
UGV_Label_07:		ld		a, (hl)
					sub		c
					ld		(hl), a
					dec		hl
					inc		d
					ld		b, 1
					jr		UGV_Loop_01
UGV_Label_08:		exx
					ld		a, $ff			
					ld		(de), a						; Set GameVar = $ff
					exx
UGV_Label_09:		exx
					pop		ix
					jp		UGV_Label_99b
;
; T128_GAMEVAR_SUBDEC
;					
UGV_Label_10:		cp		T128_GAMEVAR_SUBDEC
					ret		nz
					push	ix
					ld		ixl, e
					ld		ixh, d						; ix = GameVar address
					; CHECK FOR ASSOCIATED DIGITAL DISPLAY
					exx
					ld		a, (ix+7)
					ld		l, a
					ld		h, (ix+8)
					or		h
					jr		z, UGV_Label_13				; Associated digital display?
					; SET UP DECIMAL SUBSTRACTION
					call	UGV_Label_70
					; DECIMAL SUBSTRACTION
					ld		b, a					
UGV_Loop_03:		ld		a, (hl)					
					sub		b
					ld		(hl), a
					jr		z, UGV_Loop_05
					jp		p, UGV_Label_13
					ld		a, e
					cp		d
					jr		nz, UGV_Label_11
					; SET ALL DIGITS = 0
					ld		b, e
					xor		a
UGV_Loop_04:		ld		(hl), a
					inc		hl
					djnz	UGV_Loop_04
					jr 		UGV_Label_12
					; DECIMAL CARRY
UGV_Label_11:		ld		a, (hl)
					add		a, 10
					ld		(hl), a
					dec		hl
					inc		d
					ld		b, 1
					jr		UGV_Loop_03
					; CHECK ALL 0s
UGV_Loop_05:		dec		d
					jr		z, UGV_Loop_06
					inc		hl
					ld		a, (hl)
					or		a
					jr		nz, UGV_Label_13
					jr		UGV_Loop_05					; Check digits on the right
UGV_Loop_06:		inc		d
					ld		a, (hl)
					or		a
					jr		nz, UGV_Label_13
					dec		hl
					ld		a, e
					cp		d
					jr		nz, UGV_Loop_06				; Check digits on the left
					xor		a
					; IF DIGITAL DISPLAY REACHES 0, THEN SET GameVar = 0
UGV_Label_12:		exx
					ld		(de), a
					exx
UGV_Label_13:		exx
UGV_Label_14:		pop		ix
					jr		UGV_Label_99b


;
; Set up decimal addition / substraction / comparation
;
; Input:
;   hl = address of the digital display
;   b' = PPPPNNNN
;
; Output:
;   hl = address of position PPPP within the digital display
;   d = corrected position 
;   e = number of digits of the digital display
;   a = number to add/substract/compare
;
UGV_Label_70:		exx
					ld		a, b						; a = PPPPNNNN
					exx
					and		%11110000
					rrca
					rrca
					rrca
					rrca								 
					ld		c, a						; c = position
					ld		d, a
					inc		d							; d = corrected position
					ld		a, (hl)						; a = number of digits
					ld		e, a						; e = number of digits
					sub		c
					ld		c, a
					ld		b, 0						
					add		hl, bc						; hl = position (address)
					exx
					ld		a, b
					and		%00001111					; a = number to add / substract / compare
					exx
					ret
;
; Init Timer
;
UGV_Label_80:		push	af
					push	hl
					ld		hl, 6
					add		hl, de
					ld		a, (hl)
					cp		$ff
					jr		z, UGV_Label_89				; If GameVar has no timer, then return
					push	ix
					ld		ix, T128_Timers
					ld		c, a
					add		a, a
					add		a, a						
					add		a, a						; 8*a (T128_TM_TABLE_SIZE=8)
					ld		c, a
					ld		b, 0
					add		ix, bc						; ix = Timer address
					ld		a, (ix+1)					
					ld		(ix), a						; Init counter
					push	de					
					ld		e, (ix+4)
					ld		d, (ix+5)					; de = Timer GameVar address 
					ld		b, (ix+6)					; Initial value
					ld		a, T128_GAMEVAR_SET8		; Operation
					call	T128_UpdateGameVar2			; Set value
					pop		de
					pop		ix
UGV_Label_89		pop		hl
					pop		af
					ret
;
; Update GameVar value and set Update-Scoreboard Flag = 2
;
UGV_Label_99:		ld		(de), a
UGV_Label_99b:		inc		de
					inc		de
					ld		a, (de)
					or		%00000010					; 2 = Update scoreboard in RAM 5
					ld		(de), a
					dec		de
					dec		de
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_CompareDisplay
;
; Compare a decimal display asociated to a GameVar
;
; Input: 
;   de = Address of GameVar
;   b  = PPPPNNNN 
;        where PPPP = Position of the digit to compare (0=units 1=tens 2=hundreds 3=thousands, etc.)
;              NNNN = Value of the digit to comaere (0 to 9)
;
; Output
;   NC - if digit at position PPPP is greater or equal than NNNNN
;   C  - if digit at position PPPP is lower than NNNNN (or if GAmeVar has no associated digital display)
;

T128_CompareDisplay push	ix
					ld		ixl, e
					ld		ixh, d						; ix = GameVar address
					; CHECK FOR ASSOCIATED DIGITAL DISPLAY
					exx
					ld		a, (ix+7)
					ld		l, a
					ld		h, (ix+8)
					or		h
					jr		z, CD_Label_01				; Associated digital display?
					; SET UP DECIMAL COMPARATION
					call	UGV_Label_70
					; DECIMAL COMPARATION
					ld		b, a
CD_Loop_01:			ld		a, (hl)
					cp		b
					jr		nc, CD_Label_02					
					ld		a, e
					cp		d
					jr		z, CD_Label_01
					dec		hl
					inc		d
					ld		b, 1
					jr		CD_Loop_01
CD_Label_01:		scf
CD_Label_02:		exx
					pop		ix
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SetGameVarsB0
;
; Set initial values for Game Vars
;
T128_SetGameVarsB0:	ld		ix, T128_GameVar00
					ld		de, T128_GV_TABLE_SIZE
					ld		b, T128_GAMEVARS
SGV_Loop_01:		ld		a, (ix+1)					; Default value
					ld		(ix), a						; set initial value
					ld		a, (ix+2)
					and		%11111100
					or		%00000010
					ld		(ix+2), a					; 2 = Update scoreboard
					exx
					ld		a, (ix+7)
					ld		l, a
					ld		h, (ix+8)
					or		h
					jr		z, SGV_Label_01				; Associated digital display?
					ld		c, (hl)						
					ld		b, 0						; bc = Number of digits
					inc		hl
					ld		e, l
					ld		d, h						; de = Value (address)
					add		hl, bc						; hl = Default value (address)
					ldir								; Init default value of digital display
;
; Next GameVar
; 					
SGV_Label_01:		exx
					add		ix, de
					djnz	SGV_Loop_01
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_Set1bitFlagsB0
;
; Reset initial values for 1 bit flags
;
T128_Set1bitFlagsB0	ld		hl, T128_1bitFlags
					ld		de, T128_1bitFlags+1
					ld		bc, 31
					xor		a
					ld		(hl), a
					ldir
					ret
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_UpdateTimersB0
;
; Update Timers
;
; if Trigger GameVar !=0 
;   dec Timer counter
;   if Timer counter = 0
;      reset Timer counter
;      dec Timer GameVar
;      if Timer GameVar = 0
;          Set Trigger GameVar = 0
;          Produce sound
;      end if
;   end if
; end if
;
T128_UpdateTimersB0	ld		ix, T128_Timers
					ld		b, T128_TIMERS				; Number of timers
UT_Loop_01:			push	bc
					ld		l, (ix+2)
					ld		h, (ix+3)					; hl = Trigger GameVar
					ld		a, (hl)
					or		a
					jr		z, UT_Label_02				; if Trigger GameVar = 0, next timer
					ld		a, (ix)
					or		a
					jr		z, UT_Label_01				
					dec		a							; if Timer counter != 0, dec counter
					ld		(ix), a
					jr		UT_Label_02
UT_Label_01:		ld		a, (ix+1)					
					ld		(ix), a						; Reset Timer counter
					ld		e, (ix+4)
					ld		d, (ix+5)					; de = Timer GameVar
					ld		a, T128_GAMEVAR_DEC8		
					call	T128_UpdateGameVar2			; Decrement Timer GameVar
					ld		a, (de)
					or		a							
					jr		nz, UT_Label_02				; If Timer GameVar != 0, process next timer
					ld		e, (ix+2)
					ld		d, (ix+3)					; de = Trigger GameVar
					ld		b, a						; a = 0
					ld		a, T128_GAMEVAR_SET8
;					ld		b, 0						
					call	T128_UpdateGameVar2			; Set Trigger GameVar = 0
					ld		a, (ix+7)
					cp		$ff
					call	nz, T128_AY_InitFXB0		; if FX!=$ff, then produce sound
UT_Label_02:		ld		de, T128_TM_TABLE_SIZE
					add		ix, de
					pop		bc
					djnz	UT_Loop_01
					ret
