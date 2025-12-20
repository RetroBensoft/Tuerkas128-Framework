;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S P R I T E S   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_ENTITY_SPR
_BEGIN_CODE_ENTITY_SPR

PUBLIC T128_SPR_XB0, T128_SPR_YB0
PUBLIC T128_SPR_SpawnB0, T128_SPR_CreateB0, T128_SPR_FSMB0
PUBLIC SPRCB0_SMC_01_B0, SPRS_SMC_01_B0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprites definition tables
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\fsm\tuerkas128_SPR_def_tables.asm"


;;;;;;;;;;;;;;;;;;;
;
; Parameters
;
;;;;;;;;;;;;;;;;;;;

;
; Spawn parameters
;
SPR_LOOK_LEFT		EQU		1
SPR_LOOK_RIGHT		EQU		2
SPR_LOOK_UP			EQU		4
SPR_LOOK_DOWN		EQU		8

;
; Classes of sprites (0-127)
;
SPR_Class_CHILD_	EQU		0						; _CHILD_ sprites must not have child sprites

include ".\fsm\tuerkas128_SPR_classes.asm"			; Specific sprite classes


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Auxiliar data to create a sprite from another sprite
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPR_CurrentSprAddr	defw	0						; Address of last created sprite
SPR_FSMWaitNextLoop	defb	0						; 00010000 if FSM rotuine must wait to next loop (Wait-next-loop bit)
													; This variable must be set to 00010000 before calling SPR_CreateSprite
													; in SPR_Spawn and set to 00000000 after calling SPR_CreateSprite
SPR_ScreenSprPool	defs	T128_SPR_POOL_SIZE		; Content:
													;   Type of sprite		[byte]
													;   Inital x			[byte]
													;   Inital y			[byte]
													;   FREE				[byte]
													;   FREE				[byte]
													;   FREE				[byte]														
													;   Address of graphic  [word]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SPR_XB0
;
; Correct X coordinate using x coordinate and sprite distribution
;
; Input:
;   ix = sprite address
;   c  = T128_SPR_X_ON 		when sprite x coordinate is NOT left-aligned to the leftmost sprite cell
;        T128_SPR_X_OFF		when sprite x coordinate is left-aligned to the leftmost sprite cell
;

T128_SPR_XB0:		ld		a, (ix+6)
					ld		b, a
					srl 	a		
					srl 	a
					srl 	a
					ld		(ix+5), a
					ld		a, b
					and		%00000111
					ret		nz
					ld		a, (ix+5)
					add		a, c
					ld		(ix+5), a
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SPR_YB0
;
; Correct Y coordinate using y coordinate
;
; Input:
;   ix = sprite address
;
T128_SPR_YB0:		ex		af, af'
;					push	af
					ld		a, (ix+8)
					srl 	a		
					srl 	a
					srl 	a
					ld		(ix+7), a
;					pop		af
					ex		af, af'
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SPR_CreateB0
;
; Create an entry in T128_ScreenSprPool from screen data:
;
; SPRITE POOL (10 bytes)
;   Type of sprite					[byte]
;   Inital x						[byte]
;   Inital y						[byte]
;   Coordinate limits				[byte]
;   Instances counter				[byte]
;   Respawn counter					[byte]
;   Address of graphic				[word]
;   Address of screen entity data 	[word]
;
; Input:
;   ix = Address of screen entity data (5 bytes):
;        byte 0 = Type of sprite
;        byte 1 = Horizontal position (0-255)
;        byte 2 = Vertical position (0-191)
;        byte 3 = (MSS_PARAM1/2) SHL 4 + (MSS_PARAM2/2)
; 				MSS_PARAM1    = WALKERS:    Left boundary (even X between 0 and 31)
; 				                CYCLES:     2*T128_ENUM_00 = Initial movement forward
;				                            2*T128_ENUM_15 = Initial movement backward
;                               JUMPER:     Left boundary (even X between 0 and 31)
;                               PROJECTILE: 2*Initial Delay (high nibble)
; 				MSS_PARAM2    = WALKERS:    Right boundary (even X between 0 and 31)
;				                CYCLES:     2*(Movement table #)
;                               JUMPER:     Right boundary (even X between 0 and 31)
;                               PROJECTILE: 2*Initial Delay (low nibble)
;        byte 4  = Max number of instances to spawn (255 = infinite respawns)
;

T128_SPR_CreateB0:	bit		7, (ix-1)
					ret		nz							; Check inactivity bit of screen entity
;
					ld		a, (T128_ScreenSprPoolNum)
					cp		T128_SCREEN_MAX_SPRPOOL
					ret		z							; Check max number of screen sprites
;
					inc		a
					ld		(T128_ScreenSprPoolNum), a
					dec		a
					add		a, a
					ld		b, a
					add		a, a
					add		a, a						; a = a * 8
					add		a, b						; a = a * 10
					ld		c, a
					ld		b, 0
					ld		hl, T128_ScreenSprPool
					add		hl, bc
					push	ix
					pop		de
					ex		de, hl						; hl = from    de = to
					ld		bc, 5						; bc = size of sprite definition in screen data
					ldir
					xor		a
					ld		(de), a						; Respawn counter
					inc		de
;
; call T128_TrGraphData (dynamic link)
;
					push	de
					ld		hl, T128_GraphicPoolSPRPtr
					exx	
					ld		hl, T128_GraphicsSPR
					exx
					ld		e, (ix)
SPRCB0_SMC_01_B0:	call	0000						; Transfer sprite data from BS2 to T128_GraphicPool in B2
					pop		hl
;
					ld		(hl), c
					inc		hl
					ld		(hl), b						; Address of graphic data
					inc		hl
					dec		ix
					ld		a, ixl
					ld		(hl), a
					inc		hl
					ld		a, ixh
					ld		(hl), a						; Address of screen entity data
					ret
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SPR_SpawnB0
;
; Spawn sprites from screen data
;
; In case the sprite has child sprites, they are also spawned
;

T128_SPR_SpawnB0:	ld		a, (T128_ScreenSprPoolNum)
					or		a
					ret		z							; Sprite pool empty
					ld		ix, T128_ScreenSprPool
					ld		b, a
SPRSB0_Loop_01:		push	bc
;
; Number of instances filter
;
					ld		a, (ix+4)
					or		a
					jp		z, SPRSB0_Label_08			; No more instances to spawn
;
; Time between respawn filter
;
					ld		a, (ix+5)
					or		a
					jp		nz, SPRSB0_Label_07			; Mimimum time between respawn not reached
;
; Distance to Main Char filter
;					
					ld		a, (ix)						; Class of sprite
					add		a, a
					ld		c, a
					ld		b, 0
					ld		hl, SPR_Pointers
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						
					ld		iyl, e
					ld		iyh, d						; iy = sprite definition table
;					
					ld		a, (iy+6)
					ld		b, a
					and		%00001111
					add		a, a
					add		a, a
					add		a, a
					add		a, a
					ld		c, a						; c = min. vertical distance (delta y)
					ld		a, b
					and		%11110000
					ld		b ,a						; b = min. horizontal distance (delta x)
					push	iy
					ld		iy, T128_MainChar
;					
					ld		a, (iy+8)
					sub		(ix+2)
					exx
					ld		c, SPR_LOOK_DOWN			; Main char is under the sprite
					exx					
					jr		nc, SPRSB0_Label_01
					neg
					exx
					ld		c, SPR_LOOK_UP				; Main char is above the sprite
					exx										
SPRSB0_Label_01:	cp		c
					jr		nc, SPRSB0_Label_02			; Check vertical distance
					pop		iy
					jp		SPRSB0_Label_08
;					
SPRSB0_Label_02:	ld		a, (iy+6)
					sub		(ix+1)
					exx
					ld		b, SPR_LOOK_RIGHT			; Main char is on the right of the sprite
					exx
					jr		nc, SPRSB0_Label_03
					neg
					exx
					ld		b, SPR_LOOK_LEFT			; Main char is on the left of the sprite
					exx
SPRSB0_Label_03:	cp		b
					jr		nc, SPRSB0_Label_04			; Check horizontal distance
					pop		iy
					jp 		SPRSB0_Label_08
;
; Create sprite and decrement number of instances left to respawn
;
SPRSB0_Label_04:	pop		iy
					ld		a, (ix+4)
					cp		255			
					jr		z, SPRSB0_Label_05			; If max. instances = 255, then infinite instances
					dec		(ix+4)						; Decrement number of instances
SPRSB0_Label_05:	call	SPR_CreateSprite
;
; Child sprites and address of screen entity data
;
					jp		z, SPRSB0_Label_08			; If parent sprite was not created, then child sprites cannot be created
					ld		de, (SPR_CurrentSprAddr)
					ld		(SPRSB0_SMC_01+2), de
					ld		(SPRSB0_SMC_02+2), de
					ld		(SPRSB0_SMC_03+2), de		; Set parent sprite address		
;
; Child sprite #1
;
					ld		a, (iy+11)
					cp 		$ff							; Is there a child sprite #1?
					jr		z, SPRSB0_Label_06b
					ld		b, (iy+12)					; Delta x for child sprite #1
					ld		c, (iy+13)					; Delta y for child sprite #1
					push	ix
					push	iy
					exx
					push    bc							; b' and c' can be used in child sprites
					exx
					call	SPR_SpawnB0Child			; call SPR_Spawn with child type, x & y modified
					jr		z, SPRSB0_Label_06			; If child sprite #1 was not created, then finish
SPRSB0_SMC_01:		ld		ix, 0000					; Parent sprite address
					ld		de, (SPR_CurrentSprAddr)
					ld		(ix+22), e
					ld		(ix+23), d
					exx
					pop		bc
					exx
					pop		iy
					pop		ix
;
; Child sprite #2
;
					ld		a, (iy+14)
					cp 		$ff							; Is there a child sprite #2?
					jr		z, SPRSB0_Label_06b
					ld		b, (iy+15)					; Delta X for child sprite #2
					ld		c, (iy+16)					; Delta Y for child sprite #2
					push	ix
					push	iy
					exx
					push    bc							; b' and c' can be used in child sprites
					exx
					call	SPR_SpawnB0Child			; call SPR_Spawn with child type, x & y modified
					jr		z, SPRSB0_Label_06			; If child sprite #2 was not created, then finish
SPRSB0_SMC_02: 		ld		ix, 0000					; Parent sprite address
					ld		de, (SPR_CurrentSprAddr)
					ld		(ix+24), e
					ld		(ix+25), d
SPRSB0_Label_06:	exx
					pop		bc
					exx
					pop		iy
					pop		ix
;
; Address of screen entity data
; 
SPRSB0_Label_06b:	push	iy
SPRSB0_SMC_03:		ld		iy, 0000
					ld		a, (ix+8)
					ld		(iy+27), a
					ld		a, (ix+9)
					ld		(iy+28), a
					pop		iy
					jr		SPRSB0_Label_08
;
SPRSB0_Label_07:	dec		(ix+5)						; Decrement time between respawn
;
; Next sprite
;
SPRSB0_Label_08:	ld		bc, T128_SPR_POOL_SIZE
					add		ix, bc
					pop		bc
					dec		b
					jp		nz,	SPRSB0_Loop_01
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_SpawnB0Child
;
; Spawn a child sprite from a screen parent sprite
;
; Input:
;   ix = Pointer to basic info structure (as in T128_ScreenSprPool or in SPR_ScreenSprPool)
;   a = type of sprite
;   b = delta x
;   c = delta y
;
; Output (same as SPR_Spawn):
;   SUCCESS    ==> NZ / (SPR_CurrentSprAddr) = Address of sprite in T128_ScreenSprites 
;   NO SUCCESS ==> Z  / (SPR_CurrentSprAddr) = 0
;
SPR_SpawnB0Child:	ex		af, af'
					xor		a
					ld		(SPRS_SMC_01+1), a			; screen sprites must unset Wait-next-loop bit
					ld		a, (ix+1)					; x parent sprite
					add		a, b
					ld		b, a						; x parent sprite + delta x child sprite
					ld		a, (ix+2)					; y parent sprite
					add		a, c
					ld		c, a						; y parent sprite + delta y child sprite
					ex		af, af'					
					call	SPR_Spawn					
					ld		a, %00010000				
					ld		(SPRS_SMC_01+1), a			; restore value
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_Spawn
;
; Spawn a sprite from another sprite
;
; Preserves ix and iy
;
; In case the sprite has child sprites, they are also spawned.
; Child sprites must not have child sprites.
; I.e., recursion must not be used in sprite definition table; it could lead to unstable behavior.
;
; Input:
;  a = Type of sprite
;  b = Initial x
;  c = Initial y
;  d = FREE	(this value can be used in SPR_InitialState and SPR_InitialState2 to set a sprite parameter) 
;  e = FREE	(this value can be used in SPR_InitialState and SPR_InitialState2 to set a sprite parameter) 
;  h = FREE	(this value can be used in SPR_InitialState and SPR_InitialState2 to set a sprite parameter) 
;
; Output (same as SPR_CreateSprite):
;   SUCCESS    ==> NZ / (SPR_CurrentSprAddr) = Address of sprite in T128_ScreenSprites 
;   NO SUCCESS ==> Z  / (SPR_CurrentSprAddr) = 0


SPR_Spawn:			push	iy							; Critical in some cases
					push	ix							; Critical in some cases
					push	bc							; Critical in some cases
					ld		ix, SPR_ScreenSprPool		; Set up SPR_ScreenSprPool data structure
					ld		(ix), a
					ld		(ix+1), b
					ld		(ix+2), c
					ld		(ix+3), d
					ld		(ix+4), e
					ld		(ix+5), h
;
; call T128_TrGraphData (dynamic link)
;
					ld		hl, T128_GraphicPoolSPRPtr
					exx	
					ld		hl, T128_GraphicsSPR
					exx
					ld		e, (ix)
SPRS_SMC_01_B0:		call	0000						; Transfer sprite data from BS2 to T128_GraphicPool in B2
					ld		(ix+6), c
					ld		(ix+7), b					; Address of graphic data					
;
					ld		a, (ix)						; Type of sprite
					add		a, a
					ld		c, a
					ld		b, 0
					ld		hl, SPR_Pointers
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						
					ld		iyl, e
					ld		iyh, d						; iy = sprite definition table
SPRS_SMC_01:		ld		a, %00010000				; Set Wait-next-loop bit
					ld		(SPR_FSMWaitNextLoop), a
					call	SPR_CreateSprite			; create parent sprite
;
; Child sprites
;
					push	af							; Save result of SPR_CreateSprite for parent sprite
					jr		z, SPRS_Label_02			; If parent sprite was not created, then child sprites cannot be created				
;
; Child sprite #1
;
					ld		a, (iy+11)
					cp 		$ff							; Is there a child sprite #1?
					jr		z, SPRS_Label_02
					ld		de, (SPR_CurrentSprAddr)
					ld		(SPRS_SMC_02+2), de
					ld		(SPRS_SMC_03+2), de			; Set parent sprite address			
					ld		b, (iy+12)					; Delta x for child sprite #1
					ld		c, (iy+13)					; Delta y for child sprite #1
					push	ix
					push	iy
					call	SPRS_Label_03				; call SPR_Spawn with child type, x & y modified, and d copied from parent sprite
					jr		z, SPRS_Label_01			; If child sprite #1 was not created, then finish
SPRS_SMC_02:		ld		ix, 0000					; Parent sprite address
					ld		de, (SPR_CurrentSprAddr)
					ld		(ix+22), e
					ld		(ix+23), d
					pop		iy
					pop		ix
;
; Child sprite #2
;
					ld		a, (iy+14)
					cp 		$ff							; Is there a child sprite #2?
					jr		z, SPRS_Label_02
					ld		b, (iy+15)					; Delta x for child sprite #2
					ld		c, (iy+16)					; Delta y for child sprite #2
					push	ix
					push	iy
					call	SPRS_Label_03				; call SPR_Spawn with child type, x & y modified, and d copied from parent sprite
					jr		z, SPRS_Label_01			; If child sprite #2 was not created, then finish
SPRS_SMC_03:		ld		ix, 0000					; Parent sprite address
					ld		de, (SPR_CurrentSprAddr)
					ld		(ix+24), e
					ld		(ix+26), d
SPRS_Label_01:		pop		iy
					pop		ix					
SPRS_Label_02:		xor		a						
					ld		(SPR_FSMWaitNextLoop), a	; Unset Wait-next-loop bit
					pop		af							; restore result of SPR_CreateSprite for parent sprite
					pop		bc							; Critical in some cases
					pop		ix							; Critical in some cases
					pop		iy							; Critical in some cases
					ret
;
; Spawn child sprite
;
SPRS_Label_03:		ex		af, af'
					ld		a, (ix+1)					; x parent sprite
					add		a, b
					ld		b, a						; x parent sprite + delta x child sprite
					ld		a, (ix+2)					; y parent sprite
					add		a, c
					ld		c, a						; y parent sprite + delta y child sprite
					ex		af, af'					
					call	SPR_Spawn
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SPR_FSMB0
;
; Sprites Finite State Machine
;
; Bit 6 of byte 2 of sprite is used to check whether sprite has active data or not.
; A sprite has not active data when then sprite has been killed and its memory structura is saved as a gap for further use.
; This is managed by SPR_GetSprBuffer and SPR_FreeSprBuffer
; Bit 5 of byte 2 of sprite is used to check if sprite collides with breath areas
; Bit 4 of byte 2 of sprite is used to wait until next call to T128_SPR_FSMB0 to process sprite. This mechanism is used to avoid
; bad synchrony in sprites
; Bit 3 of byte 2 of sprite is used for _CHILD_ sprites. _CHILD_ sprites' FSM routines are called from parent srpites' FSM routines
;

T128_SPR_FSMB0:		ld		a, (T128_ScreenSprLast)
					or		a
					ret		z							; No sprites
					ld		ix, T128_ScreenSprites
					ld		b, a
SPRF_Loop_01:		push	bc
					ld		a, (ix+2)
					bit		6, a
					jr		z, SPRF_Label_02			; exec FSM routine only for active sprites
					bit		4, a
					jr		z, SPRF_Label_01			; exec FSM routine only if Wait-next-loop bit is not set
					and		%11101111
					ld		(ix+2), a					; unset Wait-next-loop bit
					jr		SPRF_Label_02
SPRF_Label_01:		bit		3, a
					jr		nz, SPRF_Label_02			; do not exec FSM routine for _CHILD_ sprites
					bit		5, a
					call	nz, T128_BA_CheckB0			; Check colision with Breath Areas
					call	SPRF_Label_05				; Parent sprite's FSM
					ld		e, (ix+22)
					ld		d, (ix+23)
					call 	SPR_SpriteDefTable			; iy = Sprite definition table for parent sprite
					ld		a, (iy+12)
					add		a, (ix+6)					; Child sprite #1 new x coordinate
					ld		b, a
					ld		a, (iy+13)
					add		a, (ix+8)					; Child sprite #1 new y coordinate
					ld		c, a
					call	SPRF_Label_03				; Child sprite #1's FSM
					ld		e, (ix+24)
					ld		d, (ix+25)
					call 	SPR_SpriteDefTable			; iy = Sprite definition table for parent sprite
					ld		a, (iy+15)					; Child sprite #2 new x coordinate
					add		a, (ix+6)
					ld		b, a
					ld		a, (iy+16)					; Child sprite #2 new y coordinate
					add		a, (ix+8)
					ld		c, a					
					call	SPRF_Label_03				; Child sprite #2's FSM
;
; Next sprite
;
SPRF_Label_02:		ld		bc, T128_SPR_TABLE_SIZE
					add		ix, bc
					pop		bc
					djnz	SPRF_Loop_01
					ret
;
; Child sprite's FSM
; 					
SPRF_Label_03:		xor		a							
					cp		d
					jr		nz, SPRF_Label_04
					cp		e
					ret		z							; there's no child sprite
SPRF_Label_04:		push	ix
					ld		ixl, e
					ld		ixh, d
					call	SPRF_Label_05				; child sprite's FSM
					pop		ix
					ret
;
; Call FSM
;
SPRF_Label_05:		call	SPR_SpriteDefTable			; iy = Sprite definition table
					ld		a, (iy+7)					; a = class of sprite
					add		a, a
					ld		e, a
					ld		d, 0
					ld		hl, SPR_FSM_Routines
					add		hl, de
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = address of FSM routine
					ld		hl, SPRF_Label_06			; returning address
					ex		de, hl
					push	de
					jp		(hl)						; call FSM routine
SPRF_Label_06:		ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_SpriteDefTable
;
; Get sprite definition table
;
; Input:
;   ix = sprite table in T128_ScreenSprites
;
; Output:
;   iy = sprite definition table
;

SPR_SpriteDefTable:	push	de
					ld		e, (ix+17)					
					ld		d, (ix+18)
					ld		iyl, e
					ld		iyh, d
					pop		de
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_CreateSprite
;
; Create entries in T128_ScreenSprites for current screen:
;
; SPRITE (29 bytes)
;	SPRITE ADDRESS						[word]
;	IABWCZZR							[byte]
;		I  = 0 - normal        /  1 - invisible
;		A  = 0 - inactive      /  1 - active
;       B  = 1 if sprite is affected by Breath Areas
;       W  = Wait-next-loop in FSM routine
;       C  = child sprite
;       ZZ = 00 - background 1 / 01 - background 2 / 10 - foreground 1 / 11 - foreground 2
;		R  = 0 - normal        /  1 - rotated
;	INITIAL RELATIVE ADDRESS FOR ROTATED
;	  MODE = (columns-1)*scanlines*2	[byte]
;	RELATIVE ADDRESS DECREMENT FOR		
;	  ROTATED MODE = scanlines*2*2		[byte]
;	X (0-31)							[byte]
;	x (0-255)							[byte]
;	Y (0-23)							[byte]
;	y (0-191)							[byte]
;	SPRITE WIDTH (in columns)			[byte]
;	SPRITE WIDTH (in pixels)			[byte]
;	SPRITE HEIGHT (in scanlines)		[byte]
;	SPRITE ATTRIBUTE					[byte]
;	STATE								[byte]
; 	PHASE COUNTER						[byte]
;	SPRITE BASE ADDRESS					[word]
;   POINTER TO SPRITE DEFINITION TABLE  [word]
;	MOVEMENT CONTROL					[byte]
;      Boundaries (WALKERS)
;      Movement table (CYCLES)
;      Initial delay (PROJECTILE)
;   COUNTER	1							[byte]
;   FLAGS: BFFFFFFH						[byte]
;     B = Mainchar's bullet
;     F = Free to use in FSMs
;     H = Hidden sprite: do not render
;   CHILD SPRITE #1						[word]
;   CHILD SPRITE #2						[word]
;   COUNTER 2							[byte]
;	ADDRESS OF SCREEN ENTITY DATA   	[word]
;
; Input:
;   ix = Pointer to basic info structure (as in T128_ScreenSprPool or in SPR_ScreenSprPool)
;   iy = sprite definition table
;   c' = SPR_LOOK_UP / SPR_LOOK_DOWN
;   b' = SPR_LOOK_RIGHT / SPR_LOOK_LEFT
;
; Output:
;   SUCCESS    ==> NZ / (SPR_CurrentSprAddr) = Address of sprite in T128_ScreenSprites 
;   NO SUCCESS ==> Z  / (SPR_CurrentSprAddr) = 0
;

SPR_CreateSprite:	ld		hl, 0
					ld		(SPR_CurrentSprAddr), hl	
					call	SPR_GetSprBuffer
					ret		z							; If no memory available, then return (set Z)
					ld		(SPR_CurrentSprAddr), hl
					push	hl
					ld		b, 0
					ld		a, (ix+6)
					ld		(hl), a
					inc		hl
					ld		a, (ix+7)
					ld		(hl), a
					inc		hl							; SPRITE ADDRESS
					ld		a, (iy+10)
					and		%00100000					; Affected by Breath Area bit
					or		%01000000
					ld		c, a
					ld		a, (SPR_FSMWaitNextLoop)	; Wait-next-loop bit
					or		c
					ld		(hl), a
					inc		hl							; IA000ZZR (visible / active / Breat Area / 00 / background 1 / not rotated)
					ld		a, (iy+8)
					ld		(hl), a
					inc		hl							; INITIAL RELATIVE ADDRESS FOR ROTATED MODE
					ld		a, (iy+9)
					ld		(hl), a
					inc		hl							; RELATIVE ADDRESS DECREMENT FOR ROTATED MODE
					ld		(hl), b
					inc		hl							; X=0 (will be calculated at the end)
					ld		a, (ix+1)
					ld		(hl), a
					inc		hl							; x
					ld		(hl), b
					inc		hl							; Y=0 (will be calculated at the end)
					ld		a, (ix+2)
					ld		(hl), a
					inc		hl							; y
					ld		a, (iy+2)
					ld		(hl), a
					inc		hl							; SPRITE WIDTH
					ld		a, (iy+3)
					ld		(hl), a
					inc		hl							; SPRITE WIDTH (in pixels)
					ld		a, (iy+4)
					ld		(hl), a
					inc		hl							; SPRITE HEIGHT
					push	hl
					call	SPR_InitialState			; Calculate initial state parameters
					pop		hl
					ld		b, (iy+1)
					ld		(hl), b
					inc		hl							; ATTRIBUTE
					ld		(hl), a
					inc		hl							; STATE
					ld		b, 0
					ld		(hl), b
					inc		hl							; PHASE COUNTER					
;					
					ld		a, (ix+6)
					ld		(hl), a
					inc		hl
					ld		a, (ix+7)
					ld		(hl), a
					inc		hl							; SPRITE BASE ADDRESS
;					
					ld		a, iyl
					ld		(hl), a
					inc		hl
					ld		a, iyh
					ld		(hl), a
					inc		hl							; POINTER TO SPRITE DEFINITION TABLE
;					
					ld		a, (ix+3)
					ld		(hl), a
					inc		hl							; COORDINATE BOUNDARIES
					ld		(hl), b
					inc		hl							; COUNTER 1 = 0
					ld		(hl), b
					inc		hl							; FLAGS = 0					
					ld		(hl), b
					inc		hl							
					ld		(hl), b
					inc		hl							; CHILD SPRITE #1
					ld		(hl), b
					inc		hl							
					ld		(hl), b
					inc		hl							; CHILD SPRITE #2
					ld		(hl), b						
					inc		hl							; COUNTER 2 = 0
					ld		(hl), b						
					inc		hl
					ld		(hl), b						; ADDRESS OF SCREEN ENTITY DATA 				
					pop		hl					
					push	iy
					push	ix
;
; Final touch
;
					push	hl
					pop		ix
					call	SPR_SpriteSetup				; X and Y correction. Normal / Rotated sprite
					ld		a, (iy+7)					; Class of sprite
					pop		iy
					push	iy
					call	SPR_InitialState2			; Initial state PHASE TWO
					ld		a, (ix+14)
					call	SPR_GraphicAddress			; Calculate sprite address after InitialState, phase TWO
					pop		ix
					pop		iy
;					
; Reset time to respawn
;
					ld		a, (iy+5)
					ld		(ix+5), a
					or		1							; set NZ
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_SpriteSetup
;
; Do the X and Y correction and set Normal/Rotated sprite
;
; Input:
;   ix = Sprite table in T128_ScreenSprites
;   de = State parameters table
;

SPR_SpriteSetup: 	ld		a, (ix+13)
					add		a, a
					ld		l, a
					ld		h, 0
					add		hl, de
					ld		c, (hl)
					call	T128_SPR_XB0				; X correction
					call	T128_SPR_YB0				; Y correction
					inc		hl
					ld		c, (hl)
					ld		a, (ix+2)
					and		%11111110
					or		c
					ld		(ix+2), a					; Normal / Rotated sprite
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_InitialState
;
; Calculate initial state of a sprite depending on sprite class: Phase ONE
;
; Input:
;   iy = sprite definition table
;   ix = Pointer to basic info structure (as in T128_ScreenSprPool or in SPR_ScreenSprPool)
;   c' = SPR_LOOK_UP / SPR_LOOK_DOWN
;   b' = SPR_LOOK_RIGHT / SPR_LOOK_LEFT
;
; Output:
;   a  = initial state
;   de = State parameters table
; 
SPR_InitialState:	ld		hl, SPR_FSM_ISRoutines
					ld		a, (iy+7)					; Class of sprite
SPR_IS_Label_01:	add		a, a
					ld		e, a
					ld		d, 0
					add		hl, de
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = address of InitialState routine
					ex		de, hl
					jp		(hl)						; call InitialState routine

					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_InitialState2
;
; Calculate initial state of a sprite: Phase TWO
;
; Input:
;   a  = Class of sprite
;   iy = Pointer to basic info structure (as in T128_ScreenSprPool or in SPR_ScreenSprPool) y usar (iy+0) en vez de (iy+7)
;   ix = Sprite table in T128_ScreenSprites
;
SPR_InitialState2:	ld		hl, SPR_FSM_IS2Routines
					jp		SPR_IS_Label_01


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_Collision
;
; Check collision between two sprites
;
; Input:
;   ix = sprite 1 data
;   iy = sprite 2 data
;
; Output:
;   a  = 0 / Z  - No collision
;   a != 0 / NZ - Collisión: value = 00AB00LR where
;       A = 1 if sprite 2 is above sprite 1
;       B = 1 if sprite 2 is bellow sprite 1
;       L = 1 if sprite 2 is on the leftside of sprite 1
;       R = 1 if sprite 2 is on the rightside of sprite 1 
;
SPR_Collision:		bit		6, (ix+2)
					jr		z, SPRC_Label_01			; Sprite 1 inactive
					bit		6, (iy+2)
					jr		z, SPRC_Label_01			; Sprite 1 inactive
;
					ld		b, (ix+6)					; x Sprite 1
					ld		a, (iy+6)					; x Sprite 2
					cp		b	
					jr		nc, SPRC_Label_02			; Sprite 2 is on the right
					add		a, (iy+10)					; a = x + width Sprite 2
					dec		a	
					cp		b
					ld		e, 2						; Sprite 2 is on the left
					jr		nc, SPRC_Label_03			; Sprite 2 and Sprite 1 collide horzontally ==> check vertically
SPRC_Label_01:		xor		a							; Sprite 2 and Sprite 1 do not collide horizontally ==> return 0 and Z
					ret									
SPRC_Label_02:		ld		d, a						; d = x Sprite 2
					ld		a, (ix+10)						
					add		a, b						; a = x + width Sprite 1
					dec		a	
					cp		d
					ld		e, 1						; Sprite 1 is on the right
					jr		nc, SPRC_Label_03			; Sprite 2 and Sprite 1 collide horzontally ==> check vertically
					xor		a							; Sprite 2 and Sprite 1 do not collide horizontally ==> return 0 and Z
					ret			
SPRC_Label_03:	 	ld		a, (ix+11)	
					ld		h, a						; Height Sprite 1
					ld		a, (iy+11)					; Height Sprite 2
					ld		l, a	
					ld		b, (ix+8)					; y Sprite 1
					ld		a, (iy+8)					; y Sprite 2
					cp		b	
					jr		nc, SPRC_Label_04			; Sprite 2 is bellow Sprite 1
					add		a, l						; a = y + height Sprite 2
					dec		a	
					cp		b
					ld		c, 2*16						; Sprite 2 is above sprite 1
					jr		nc, SPRC_Label_05			; Sprite 2 and Sprite 1 collide vertically ==> Total collision
					xor		a							; Sprite 2 and Sprite 1 do not collide vertically ==> return 0 and Z
					ret									
SPRC_Label_04:		ld		d, a						; d = y Sprite 2
					ld		a, h						
					add		a, b						; a = y + height Sprite 1
					dec		a	
					cp		d
					ld		c, 1*16						; Sprite 2 is bellow sprite 1					
					jr		nc, SPRC_Label_05			; Sprite 2 and Sprite 1 collide vertically ==> Total collision
					xor		a							; Sprite 2 and Sprite 1 do not collide vertically ==> return 0 and Z
					ret			
SPRC_Label_05: 		ld		a, c						
					add		a, e						; Return 00AB00LR and NZ
					ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_CollisionAll
;
; Check collision between two sprites. Sprite 1's children are also checked with Sprite 2
;
; Input:
;   ix = sprite 1 data
;   iy = sprite 2 data
;
; Output:
;   Same as SPR_Collision
;

SPR_CollisionAll:	call	SPR_Collision				; Check collision with paremt sprite
					ret		nz
;					
					ld		c, (ix+22)
					ld		b, (ix+23)					
					xor		a							
					cp		b
					jr		nz, SPRCA_Label_01
					cp		c
					ret		z							; there's no child sprite #1
SPRCA_Label_01:		push	ix
					ld		ixl, c
					ld		ixh, b
					call	SPR_Collision				; check collision with child sprite #1
					pop		ix
					ret		nz
;
					ld		c, (ix+24)
					ld		b, (ix+25)					
					xor		a							
					cp		b
					jr		nz, SPRCA_Label_02
					cp		c
					ret		z							; there's no child sprite #2
SPRCA_Label_02:		push	ix
					ld		ixl, c
					ld		ixh, b
					call	SPR_Collision				; check collision with child sprite #2
					pop		ix
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_BulletCollision
;
; Check collisions of a sprite with Mainchar bullets
;
; Bit 6 of byte 2 of sprite is used to check whether sprite has active data or not.
; A sprite has not active data when sprite has been killed and its memory structura is saved as a gap for further use.
; This is managed by SPR_GetSprBuffer and SPR_FreeSprBuffer 
;
; Input:
;   ix = Sprite data
;
; Output
;   Same as SPR_Collision
;   iy = Mainchar bullet sprite data (inc case of collision)
;

SPR_BulletCollision	ld		a, (T128_ScreenSprLast)
					or		a
					ret		z							; No sprites
					ld		iy, T128_ScreenSprites
					ld		b, a
SPRBC_Loop_01:		push	bc
					ld		a, (iy+21)
					bit		7, a
					jr		z, SPRBC_Label_01			; check colision only for bullets
					ld		a, (iy+2)
					bit		6, a
					jr		z, SPRBC_Label_01			; check collision only for active sprites
					call	SPR_CollisionAll
					jr		z, SPRBC_Label_01
					pop		bc							; collision
					ret
;
; Next sprite
;
SPRBC_Label_01:		ld		bc, T128_SPR_TABLE_SIZE
					add		iy, bc
					pop		bc
					djnz	SPRBC_Loop_01
					xor		a							; no colision
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_GraphicAddress
;
; Update graphic address and phase of sprites
;
; Input:
;   ix = sprite data
;   a  = phase
;
SPR_GraphicAddress:	push	bc
					ld		(ix+14), a
					ld		l, (ix+15)
					ld		h, (ix+16)
					or		a
					jr		z, SPRGA_Label_01
					call	SPR_SpriteDefTable
					ld		e, (iy+0)					; e = size of graphic (a single phase)
					
					ld		d, 0
					ld		b, a
SPRGA_Loop_01:		add		hl, de
					djnz	SPRGA_Loop_01
SPRGA_Label_01:		ld		(ix), l
					ld		(ix+1), h
					pop		bc					
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_GetSprBuffer
;
; Allocate memory for a new sprite
;
; if there is a free gap then
;    decrease (T128_ScreenSprGaps)
;    use last gap available and release
;    increase (T128_ScreenSpritesNum)
;    return  a = ff / NZ
; else
;    if (T128_ScreenSpritesNum)=T128_SCREEN_MAX_SPRS then
;       return a = 0 / Z
;    else
;       increase (T128_ScreenSprLast)
;       use (T128_ScreenSprLastPtr) and increase
;       increase (T128_ScreenSpritesNum)
;       return  a = ff / NZ
; end if
;
; Output:
;   hl  = Address for new sprite
;   a = 0  / Z  - No memory available
;   a = ff / NZ - Memory available
;

SPR_GetSprBuffer:	ld		a, (T128_ScreenSprGaps)
					or		a
					jr		nz, SPRGSB_Label_02
;
; There are no free gaps
;					
					ld		a, (T128_ScreenSpritesNum)
					cp		T128_SCREEN_MAX_SPRS
					jr		nz, SPRGSB_Label_01		; Max number of sprites on screen ==> No more sprites can be created!
					xor		a
					ret
SPRGSB_Label_01:	ld		hl, (T128_ScreenSprLastPtr)
					push	hl
					ld		bc, T128_SPR_TABLE_SIZE
					add		hl, bc
					ld		(T128_ScreenSprLastPtr), hl
					ld		a, (T128_ScreenSprLast)
					inc		a
					ld		(T128_ScreenSprLast), a
					jr		SPRGSB_Label_03
;
; There is at least one free gap
;					
SPRGSB_Label_02:	dec		a						
					ld		(T128_ScreenSprGaps), a	
					ld		c, a					
					ld		b, 0
					sla		c
					ld		hl, T128_ScreenSprGapsPtr 
					add		hl, bc					
					ld		c, (hl)
					inc		hl
					ld		b, (hl)
					push	bc						; Return last gap available
;
; Update 128_ScreenSpritesNum and finish
;
SPRGSB_Label_03:	ld		hl, T128_ScreenSpritesNum
					inc		(hl)
					pop		hl						; Address of new sprite
					ld		a, $ff					; Return ff
					or		a						; and NZ
					ret					


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_FreeSprBuffer
;
; Release memory when a sprite is deactivated
;
; Input
;   ix = current sprite info
;
; if (current is equal to last sprite) then
;    decrease (T128_ScreenSprLast)
;    decrease (T128_ScreenSprLastPtr)
; else
;    increase (T128_ScreenSprGaps)
;    create gap in (T128_ScreenSprGapsPtr)
; end if
; decrease T128_ScreenSpritesNum
; deactivate sprite (bit 6 of byte 2)
;

SPR_FreeSprBuffer:	ld		hl, (T128_ScreenSprLastPtr)
					ld		bc, T128_SPR_TABLE_SIZE					
					or		a							; Carry = 0
					sbc		hl, bc
					ld		d, h
					ld		e, l
					ld		b, ixh
					ld		c, ixl
					or		a
					sbc		hl, bc
					xor		a
					cp		l
					jr		nz, SPRFSB_Label_01
					cp		h
					jr		nz, SPRFSB_Label_01
;
; current sprite is the last one
;					
					ld		hl, T128_ScreenSprLast
					dec		(hl)
					ld		(T128_ScreenSprLastPtr), de
					jr		SPRFSB_Label_02
;
; Current sprite is not the last one ==> create gap
;
SPRFSB_Label_01:	ld		a, (T128_ScreenSprGaps)
					ld		c, a
					sla		c
					ld		b, 0
					ld		hl, T128_ScreenSprGapsPtr
					add		hl, bc						; Get address for gap
					ld		b, ixh
					ld		c, ixl
					ld		(hl), c						; Save lower byte of the pointer
					inc		hl
					ld		(hl), b						; Save lower byte of the pointer
					inc		a						
					ld		(T128_ScreenSprGaps), a		; Increment number of gaps
SPRFSB_Label_02:	ld		hl, T128_ScreenSpritesNum
					dec		(hl)						; Decrement number of sprites to process
					ld		a, (ix+2)
					and		%10111111					; Unset bit 6 of byte 2 of the sprite (INACTIVE)
					ld		(ix+2), a
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_KillSprite
;
; Release memory when a sprite is deactivated
; It kills child sprites as well
;
; Input
;   ix = current sprite info
;

SPR_KillSprite:		call	SPR_FreeSprBuffer			; kill parent sprite
					ld		c, (ix+22)
					ld		b, (ix+23)					
					call	SPRKS_Label_01				; kill child sprite #1
					ld		c, (ix+24)
					ld		b, (ix+25)					
SPRKS_Label_01:		xor		a							; kill child sprite #2
					cp		b
					jr		nz, SPRKS_Label_02
					cp		c
					ret		z							; there's no child sprite
SPRKS_Label_02:		push	ix
					ld		ixl, c
					ld		ixh, b
					call	SPR_FreeSprBuffer			; kill child sprite
					pop		ix
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SPR_SetInactive
;
; Set inactivity bit, so that sprite will not be spawned next time current screen is rendered
;
; Input
;   ix = current sprite info
;
SPR_SetInactive:	ld		l, (ix+27)
					ld		h, (ix+28)					; hl = address of sprite definition in map (screen entity definitio)
					set		7, (hl)						; Set inactivity bit, so that Statue will not be spawned next time Perseus goes back to current screen					
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; F S M   R O U T I N E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\fsm\SPR\tuerkas128_spr_CHILD_.asm"			; Finite State Machine for _CHILD_
include ".\fsm\SPR\tuerkas128_spr_MAINCHAR_.asm"		; Common functions for Main Char's FSM
include ".\fsm\MAINCHAR\tuerkas128_spr_FSM.asm"			; Finite State Machine of Perseus
include ".\fsm\tuerkas128_SPR_routines.asm"				; Finite State Machine for sprites
