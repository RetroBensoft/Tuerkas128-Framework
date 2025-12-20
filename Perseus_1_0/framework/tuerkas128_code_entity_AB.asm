;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; A N I M A T E D   B L O C K S   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_ENTITY_AB
_BEGIN_CODE_ENTITY_AB

PUBLIC	T128_AB_CreateB0, T128_AB_FSMB0

PUBLIC	ABC_SMC_01_B0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Animated Blocks definition tables
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\fsm\tuerkas128_AB_def_tables.asm"


;;;;;;;;;;;;;;;;;;;
;
; Parameters
;
;;;;;;;;;;;;;;;;;;;

;
; Classes of animated blocks
;
AB_ClassSimple		EQU		0							; Simple animated block
AB_ClassButton		EQU		1							; Button animated block
AB_ClassGate		EQU		2							; Gate animated block
AB_ClassBubble		EQU		3							; Bubble animated block
AB_ClassObject		EQU		4							; Object animated block


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FSM routines for every animated block class
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AB_FSM_Routines:	defw	AB_FSM_Simple, AB_FSM_Button, AB_FSM_Gate, AB_FSM_Bubble, AB_FSM_Object


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; InitState routines for every animated class
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AB_FSM_ISRoutines	defw	AB_FSM_SimpleIS, AB_FSM_ButtonIS, AB_FSM_GateIS, AB_FSM_BubbleIS, AB_FSM_ObjectIS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_CreateB0
;
; Create an entry in T128_ScreenAnimBlk for current Animated Block:
;
; ANIMATED BLOCK (15 bytes)
; 	SCREEN ADDRESS					[word]
;   ATTRIBUTE ADDRESS (MSB)			[byte]
; 	CURRENT PHASE					[byte]
; 	STATE							[byte]
;   DELAY / 1BITFLAG / GAMEVAR		[byte]
; 	ANIMATED BLOCK TABLE POINTER	[word]
;	CURRENT DURATION				[byte]
; 	GRAPHIC ADDRESS					[word]
; 	CURRENT PHASE GRAPHIC ADDRESS 	[word]
;   ADDRESS OF SCREEN ENTITY DATA   [word]
;   CONTROL FLAG (1bitFlag)			[byte]
;
; Input:
;   ix = Address of screen entity data (5 bytes):
;        byte 0      = PPTTTTTT where
;                      PP = Initial phase (0-3). This parameter allows out-of-phase animation for the same type of AB within the screen
;                             This parameter is not used in classes BUTTON and GATE
;                      TTTTTT = Type of AB
;        byte 1 & 2  = Screen address
;        byte 3      = 1bitFlag to control AB rendering and FSM processing:
;                        * T128_1BITFLAG_ff	= Render AB and process FSM always
;                        * 1bitFlag number 	= Render AB and process FSM only if 1bitFlag is set
;        byte 4      = SIMPLE:         Number of game loops before starting first animation (Delay)
;                      BUTTON, BUBBLE: Number of 1bitFlag to activate when Main Char collides with the AB (1bitFlag)
;                                      Do not use the same 1bitFlag with two different BUTTONs or BUBBLEs within the same screen
;                      GATE:           Number of 1bitFlag to be checked to change state of the AB (1bitFlag)
;                      OBJECT:         Not used
;

T128_AB_CreateB0:	ld		a, (T128_ScreenAnimBlkNum)
					cp		T128_SCREEN_MAX_ANIM		; Check max number of Animated Blocks
					ret		z
					inc		a
					ld		(T128_ScreenAnimBlkNum), a
					dec		a
;					ld		b, a
					add		a, a
					add		a, a
					add		a, a						
					add		a, a						; a = a * 16   Max 15 ABs per screen
;					sub		b							; a = a * 15
					ld		c, a
					ld		b, 0
					ld		iy, T128_ScreenAnimBlk
					add		iy, bc
					ld		a, (ix+1)					
					ld		(iy), a
					ld		a, (ix+2)					
					ld		(iy+1), a					; SCREEN ADDRESS
					rrca								
					rrca								
					rrca								
					and		3							
					or		$58							
					ld		(iy+2), a					; ATTRIBUTE ADDRESS (MSB)					
					ld		a, (ix+3)
					ld		(iy+15), a					; CONTROL FLAG
					ld		a, (ix+4)
					ld		(iy+5), a					; DELAY / 1BITFLAG / GAMEVAR
					ld		hl, AB_Pointers
;					ld		b, 0
					ld		a, (ix)						; PPTTTTTT: Phase and Type
					ld		e, a
					and		%11000000					; PP000000
					rlca
					rlca
					ld		(iy+3), a					; CURRENT (INITIAL) PHASE
					ld		a, e
					and		%00111111					; 00TTTTTT
					add		a, a
					ld		c, a
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = animated block definition table
;					ex		de, hl						
					ld		(iy+6), e
					ld		(iy+7), d					; ANIMATED BLOCK DEFINITION TABLE
; 
; call T128_TrGraphData
;
					ld		hl, T128_GraphicPoolABPtr
					exx	
					ld		hl, T128_GraphicsAB
					exx
					ld		a, (ix)
					and		%00111111
					ld		e, a						; Type
ABC_SMC_01_B0:		call	0000						; Transfer animated block data from BS2 to T128_GraphicPool in B2
;
					ld		(iy+9), c
					ld		(iy+10), b					; GRAPHIC ADDRESS
					ld		c, ixl
					ld		b, ixh
					dec		bc
					ld		(iy+13), c
					ld		(iy+14), b					; ADDRESS OF SCREEN ENTITY DATA
;
; Initial state & parameters
;
					ld		l, (iy+6)
					ld		h, (iy+7)
					inc		hl
					inc		hl
					inc		hl
					inc		hl
					ld		a, (hl)						; Class of AB
					ld		hl, AB_FSM_ISRoutines
					add		a, a
					ld		e, a
					ld		d, 0
					add		hl, de
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = address of InitialState routine
					ex		de, hl
					ld		de, T128_AB_PhaseParam
					push	de							; return to T128_AB_PhaseParam
					jp		(hl)						; call InitialState routine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_FSMB0
;
; Animated Blocks Finite State Machine
;
; Call appropiate routine according to animated block class
;
; AB's CONTROL FLAG is used to check whether FSM is to be processed:
;
;   If CONTROL FLAG (1bitFlag) = T128_1BITFLAG_ff then
;      Process FSM
;   else
;     if (1bitFlag) is set then
;       Process FSM
;     end if
;   end if
;

T128_AB_FSMB0:		ld		a, (T128_ScreenAnimBlkNum)
					or		a
					ret		z							; No animated blocks
					ld		ix, T128_ScreenAnimBlk
					ld		b, a
ABF_Loop_01:		push	bc
					ld		a, (ix+15)					; a = CONOTROL FLAG (1bitFlag)
					cp		T128_1BITFLAG_ff
					jr		z, ABF_Label_01
					call	T128_Check1bFlagB0
					jr		z, ABF_Label_02
ABF_Label_01:		ld		l, (ix+6)
					ld		h, (ix+7)
					push	hl
					pop		iy							; iy = Animated Block definition table
					ld		c, (iy+4)					; animated block class
					sla		c							; Attribute Flag (bit 7) is moved to carry. It is useless here
					ld		b, 0
					ld		hl, AB_FSM_Routines
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					ex		de, hl
					ld		de, ABF_Label_02
					push	de
					jp		(hl)						; Call FSM routine
ABF_Label_02:		ld		de, T128_AB_TABLE_SIZE
					add		ix, de						; Next animated block
					pop		bc
					dec		b
					jp		nz,	ABF_Loop_01
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_PhaseParam
;
; Update duration and graphic address of current phase
;
; Input:
;    iy = animated block info
;
; Output:
;    iy+8         = duration for current phase
;    iy+11 (word) = graphic address for current phase
; 
T128_AB_PhaseParam:	ld		l, (iy+6)
					ld		h, (iy+7)
					ld		e, (hl)
					inc		e							; N phases + 1 stop phase
					inc		hl
					inc		hl
					ld 		a, (hl)
					ld		(ABPP_SMC_01+1), a			; SIZE OF GRAPHIC
					inc		hl
					inc		hl
					inc		hl
					ld		c, (iy+3)					; c = current phase
					ld		b, 0
					add		hl, bc
					ld		d, b
					add		hl,	de
					add		hl, de
					ld		a, (hl)
					ld		(iy+8), a					; DURATION
					add		hl, de
					ld		a, (hl)						; Current graphic phase
					ld		l, (iy+9)
					ld		h, (iy+10)					; hl = graphic address					
					or		a
					jr		z, ABPP_Label_02			; if a = 0, then no multiplication is needed
ABPP_SMC_01:		ld		e, 0
					ld		d, 0						; de = size of graphic (a single phase), in bytes					
					ld		b, a						; b = current phase
ABPP_Loop_01:		add		hl, de
					djnz 	ABPP_Loop_01
ABPP_Label_02:		ld		(iy+11), l
					ld		(iy+12), h					; CURRENT PHASE GRAPHIC ADDRESS
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_GetABSize
;
; Get Animated Block width and Height
;
; Input:
;    iy = animated block definition table
;
; Output:
;    e = AB width in pixels
;    d = AB height in pixels
;
T128_AB_GetABSize:	push	hl
					ld		a, (iy+1)					; Rendering routine
					add		a, a
					ld		c, a
					ld		b, 0
					ld		hl, T128_AB_RenderSize
					add		hl, bc
					ld		e, (hl)						; AB width
					inc		hl
					ld		d, (hl)						; AB height
					pop		hl
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_CheckVert
;
; Check vertical collision with Main char
;
; Input:
;    ix = animated block info
;    d  = AB height in pixels
;
; Output:
;    Z and C if no vertical collision
;
T128_AB_CheckVert:	push	iy
					ld		iy, T128_MainChar
					ld		a, (ix)
					and		%11100000
					rrca
					rrca
					ld		b, a
					ld		a, (ix+1)
					and		%00011000
					rlca
					rlca
					rlca
					or		b							; a = y
					cp		(iy+8)
					jr		nc, ABCV_Label_01
					ld		b, (iy+8)
					ld		c, d
					jr		ABCV_Label_02
ABCV_Label_01:		ld		b, a
					ld		a, (iy+8)
					ld		c, (iy+11)
ABCV_Label_02:		add		a, c
					cp		b
					pop		iy
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_CheckHor
;
; Check horizontal collision with Main char
;
; Input:
;    ix = animated block info
;    e  = AB width in pixels
;
; Output:
;    Z and C if no vertical collision
;
T128_AB_CheckHor:	push	iy
					ld		iy, T128_MainChar
					ld		a, (ix)
					and		%00011111
					rlca
					rlca
					rlca								; a = x
					cp		(iy+6)
					jr		nc, ABCH_Label_01
					ld		b, (iy+6)
					ld		c, e
					jr		ABCH_Label_02
ABCH_Label_01:		ld		b, a
					ld		a, (iy+6)
					ld		c, (iy+10)
ABCH_Label_02:		add		a, c
					cp		b
					pop		iy
					ret					
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_Animation
;
; Do Animated Block cycle animation
;
; Input:
;   ix = animated block info
;   iy = animated block definition table
;

T128_AB_Animation:	dec		(ix+8)
					ret		nz							; check animation duration
					ld 		a, (ix+4)					
					ld		b, a						; b = a = current state
;
; Increasing phase
;					
					cp		T128_ANIMBLK_ST_UP
					jr		nz, ABA_Label_02
					ld		a, (ix+3)					
					inc		a							; increment current phase
					cp		(iy)						; Reached number of phases?
					jr		nz, ABA_Label_04
					ld		a, (iy+3)					; type of animation cycle
					cp		T128_ANIMBLK_UPDOWN
					jr		nz, ABA_Label_01
					ld		b, T128_ANIMBLK_ST_DOWN
					ld		a, (iy)
					dec		a
					dec		a
					jr		ABA_Label_04
ABA_Label_01:		cp		T128_ANIMBLK_UPFIRST
					jr		nz, ABA_Label_04
					xor		a							; reset if last phase is reached
					jr		ABA_Label_04
;
; Decreasing phase
;					
					
ABA_Label_02:		cp		T128_ANIMBLK_ST_DOWN
					ret		nz
					ld		a, (ix+3)					
					or		a
					jr		z, ABA_Label_03
					dec		a
					jr		ABA_Label_04
ABA_Label_03:		inc		a
					ld		b, T128_ANIMBLK_ST_UP
ABA_Label_04:		ld		(ix+3), a					; New phase
					ld		(ix+4), b					; New state
					push	iy
					push	ix
					pop		iy
					call	T128_AB_PhaseParam			; Update duration and graphic address for current phase
					pop		iy					
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AB_GetDepInfo
;
; Get AB dependant info address
;
; Input:
;   iy = animated block definition table
;
; Output:
;   hl = AB dependant info address
;

T128_AB_GetDepInfo:	ld		a, (iy)
					inc		a							; a = TOTAL number of phases
					push	iy
					pop		hl
					ld		b, 0
					ld		c, 5
					add		hl, bc
					ld		c, a
					add		hl, bc
					add		hl, bc
					add		hl, bc
					add		hl, bc
					ret									; hl = AB definition table + 5 + 4*(TOTAL number of phases)
					
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; F S M   R O U T I N E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\fsm\AB\tuerkas128_ab_SIMPLE_.asm"			; Finite State Machine for Simple ABs
include ".\fsm\AB\tuerkas128_ab_BUTTON_.asm"			; Finite State Machine for Button ABs
include ".\fsm\AB\tuerkas128_ab_GATE_.asm"				; Finite State Machine for Gate ABs
include ".\fsm\AB\tuerkas128_ab_BUBBLE_.asm"			; Finite State Machine for Bubble ABs
include ".\fsm\AB\tuerkas128_ab_OBJECT_.asm"			; Finite State Machine for Object ABs