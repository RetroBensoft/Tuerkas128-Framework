;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; E N G I N E   M A C R O S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Block management
;
; These macros are used in tuerkas128_scr_blocks.asm to define screen blocks
;
; M_SINGLEBLOCK_BEGIN and M_SINGLEBLOCK_END must be used to define a block properties
;
; For example, asuming BLOCK_COUNTER=0:
;    M_SINGLEBLOCK_BEGIN "VacioBlanco1x1", T128_BLOCK_WIDTH_1 + T128_BLOCK_HEIGHT_1
;	    				 defb	0, 0, 0, 0, 0, 0, 0, 0
;					     defb	T128_BLACK_WHITE
;	M_SINGLEBLOCK_END	 "VacioBlanco1x1"
;
; will be expanded to:
; 	BLK_VacioBlanco1x1: defb T128_BLOCK_WIDTH_1 + T128_BLOCK_HEIGHT_1
;	   				    defb 0, 0, 0, 0, 0, 0, 0, 0
;					    defb T128_BLACK_WHITE
;   T128_B_VacioBlanco1x1 EQU 0
;   PUBLIC T128_B_VacioBlanco1x1
;
; T128_B_VacioBlanco1x1 can be used as an index to reference the block at tuerkas128_scr_superblocks.asm and tuerkas128_screen_main.asm
; 
; BLK_VacioBlanco1x1 must be referred at the end of this file, in the lookup table for block pointers using the M_BLOCK_TABLE macro
; For example:
;   M_BLOCK_TABLE "VacioBlanco1x1"
; will be expanded to:
;   defw VacioBlanco1x1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

M_SINGLEBLOCK_BEGIN MACRO MSB_NAME, MSB_PROPERTIES
					BLK_##MSB_NAME 	EQU 	$
					defb MSB_PROPERTIES
ENDM

M_SINGLEBLOCK_END MACRO MSB_NAME
				  T128_B_##MSB_NAME	EQU		BLOCK_COUNTER
				  PUBLIC T128_B_##MSB_NAME
				  BLOCK_COUNTER 	DEFL 	BLOCK_COUNTER + 1
ENDM

M_BLOCK_TABLE MACRO MSB_NAME
			  defw BLK_##MSB_NAME
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Superblock management
;
; M_SUPERBLOCK_BEGIN and M_SUPERBLOCK_END must be used to define a superblock properties
;
; For example, asuming SUPERBLOCK_COUNTER=0:
; 	M_SUPERBLOCK_BEGIN	"TroncoArbol1", 16, 1
;						M_SCREEN_ITEM 2 , 0 , T128_BLOCK_GROWTH_D, 6 , T128_BLOCK_B, T128_B_TroncoArbolL
;						M_SCREEN_ITEM 3 , 0 , T128_BLOCK_GROWTH_D, 6 , T128_BLOCK_B, T128_B_TroncoArbolR
;						M_SCREEN_ITEM 3 , 4 , T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolDer
;						M_SCREEN_ITEM 2 , 9 , T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolIzq
;						M_SCREEN_ITEM 3 , 13, T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolDer
;						M_SCREEN_ITEM 2 , 16, T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolCent
;	M_SUPERBLOCK_END	"TroncoArbol1"	
;
; will be expanded to (look tuerkas128_screen_main.asm or tuerkas128_screen_aux.asm to see how M_SCREEN_ITEM is expanded):
;
; 	SUPERBLK_TroncoArbol1:  defb	(16 -1) SHL 4 + 1 -1
;							M_SCREEN_ITEM 2 , 0 , T128_BLOCK_GROWTH_D, 6 , T128_BLOCK_B, T128_B_TroncoArbolL
;							M_SCREEN_ITEM 3 , 0 , T128_BLOCK_GROWTH_D, 6 , T128_BLOCK_B, T128_B_TroncoArbolR
;							M_SCREEN_ITEM 3 , 4 , T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolDer
;							M_SCREEN_ITEM 2 , 9 , T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolIzq
;							M_SCREEN_ITEM 3 , 13, T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolDer
;							M_SCREEN_ITEM 2 , 16, T128_BLOCK_GROWTH_D, 1 , T128_BLOCK_B, T128_B_AgujeroArbolCent
;							defb	$ff														
;   T128_SB_TroncoArbol1 EQU 0
;   PUBLIC T128_SB_TroncoArbol1
;
; T128_SB_TroncoArbol1 can be used as an index to reference the block at tuerkas128_screen_main.asm
;
; SUPERBLK_TroncoArbol1 must be referred at the end of this file, in the lookup table for superblock pointers using the M_SUPERBLOCK_TABLE macro
; For example,
;   M_SUPERBLOCK_TABLE "Superblock_1"
; will be expanded to:
;   defw SUPERBLK_Superblock_1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

M_SUPERBLOCK_BEGIN MACRO MSB_NAME, MSB_DX, MSB_DY
				   SUPERBLK_##MSB_NAME EQU $
				   defb	(MSB_DX-1) SHL 4 + MSB_DY-1
ENDM

M_SUPERBLOCK_END MACRO MSB_NAME
				 defb	$ff
				 T128_SB_##MSB_NAME	EQU		SUPERBLOCK_COUNTER
				 PUBLIC T128_SB_##MSB_NAME
				 SUPERBLOCK_COUNTER DEFL 	SUPERBLOCK_COUNTER + 1
ENDM

M_SUPERBLOCK_TABLE MACRO MSB_NAME
				   defw SUPERBLK_##MSB_NAME
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Screen management
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; M_SCREEN_INFO
;
; Used at tuerkas128_scr_map.asm to define screen type
;
; MSI_INFO = LFFFFFFF
; Where:
;   L       = 1 for back-lighted screens  /  0 for normal-lighted screens
;   FFFFFFF = Free (not used yet)
;
;	L value can be set using:
;      T128_SCREEN_FRONTLIGHT for normal-lighted screens 
;      T128_SCREEN_BACKLIGHT for back-lighted screens
;
M_SCREEN_INFO MACRO MSI_INFO
			  defb 	MSI_INFO
ENDM

;
; M_SCREEN_ITEM
;
; Used at tuerkas128_scr_map.asm to include a block or a superblock in a screen
;
; MSI_X      = horizontal position (0-31)
; MSI_Y      = vertical position (0-23)
; MSI_GROWTH = T128_BLOCK_GROWTH_D for Down-growing blocks (or superblocks)
;            = T128_BLOCK_GROWTH_R for Right-growing blocks (or superblocks)
; MSI_COPIES = number of copies of the block (or superblock) ranging from 1 to 16
; MSI_TYPE   = T128_BLOCK_B for blocks
;            = T128_BLOCK_S for superblocks
; MSI_NUMBER = number of block (or superblock)
;
M_SCREEN_ITEM MACRO MSI_X, MSI_Y, MSI_GROWTH, MSI_COPIES, MSI_TYPE, MSI_NUMBER
			  defb 	MSI_X SHL 3 + MSI_Y SHR 2, MSI_Y SHL 6 + MSI_TYPE + MSI_GROWTH + MSI_COPIES-1, MSI_NUMBER
ENDM

;
; M_SCREEN_AREA
;
; Used at tuerkas128_scr_map.asm to define a screen area to toggle between normal or backlighted rendering
;
; MSA_MIN_X = left border coordinate (0-31)
; MSA_MAX_X = right border coordinate (0-31)
; MSA_MIN_Y = top border coordinate (0-23)
; MSA_MAX_Y = bottom border coordinate (0-23)
;
M_SCREEN_AREA MACRO MSA_MIN_X, MSA_MAX_X, MSA_MIN_Y, MSA_MAX_Y
			  defb 	T128_ENTITY_SCR_AREA, MSA_MIN_X, MSA_MAX_X, MSA_MIN_Y, MSA_MAX_Y, 0
ENDM

;
; M_SCREEN_ANIM_BLK
;
; Used at tuerkas128_scr_map.asm to define an animated block
;
; MSAB_TYPE  = Type of AB 
; MSAB_X     = Horizontal position (0-31)
; MSAB_Y     = Vertical position (0-23)
; MSAB_PHASE = Initial phase (0-3). This parameter allows out-of-phase animation for the same type of AB within the screen
;              This parameter is not used in classes BUTTON and GATE
; MSAB_PARAM = SIMPLE:         Number of game loops before starting first animation (delay)
;              BUTTON, BUBBLE: Number of 1bitFlag to activate when Main Char collides with the AB (1bitFlag).
;                              Do not use the same 1bitFlag with two different BUTTONs or BUBBLEs within the same screen
;              GATE:           Number of 1bitFlag to be checked to change state of the AB (1bitFlag)
;              OBJECT:         Not used
; MSAB_FLAG  = 1bitFlag to control AB rendering and FSM processing:
;                * $ff 	         = Render AB and process FSM always
;                * 1bitFlag number = Render AB and process FSM only if 1bitFlag is set
;
M_SCREEN_ANIM_BLK MACRO MSAB_TYPE, MSAB_X, MSAB_Y, MSAB_PHASE, MSAB_PARAM, MSAB_FLAG
 			  defb 	T128_ENTITY_ANIM_BLK, (MSAB_PHASE SHL 6) + MSAB_TYPE, ((MSAB_Y AND %00000111) SHL 5) + MSAB_X, %01000000 + (MSAB_Y AND %11111000), MSAB_FLAG, MSAB_PARAM
ENDM

;
; M_SCREEN_BREATHR
; 
; Used at tuerkas128_scr_map.asm to define a right-pushing breath area 
; 
; MSB_X      = Horizontal position (0-31)
; MSB_Y      = Vertical position (0-23)
; MSB_WIDTH  = Width of breath area (0-7)
; MSB_HEIGHT = Height of breath area (0-7)
; MSB_OFF    = Number of game loops while the breath area is hidden
; MSB_ON     = Number of game loops while the breath area is active
; MSB_DELAY  = Number of game loops before starting first animation
;
M_SCREEN_BREATHR MACRO MSB_X, MSB_Y, MSB_WIDTH, MSB_HEIGHT, MSB_OFF, MSB_ON, MSB_DELAY
 			  defb 	T128_ENTITY_BREATHR, MSB_WIDTH SHL 5 + MSB_X, MSB_HEIGHT SHL 5 + MSB_Y, MSB_OFF, MSB_ON, MSB_DELAY
ENDM

;
; M_SCREEN_BREATHL
; 
; Used at tuerkas128_scr_map.asm to define a left-pushing breath area 
; 
; MSB_X      = Horizontal position (0-31)
; MSB_Y      = Vertical position (0-23)
; MSB_WIDTH  = Width of breath area (0-7)
; MSB_HEIGHT = Height of breath area (0-7)
; MSB_OFF    = Number of game loops while the breath area is hidden
; MSB_ON     = Number of game loops while the breath area is active
; MSB_DELAY  = Number of game loops before starting first animation
;
M_SCREEN_BREATHL MACRO MSB_X, MSB_Y, MSB_WIDTH, MSB_HEIGHT, MSB_OFF, MSB_ON, MSB_DELAY
 			  defb 	T128_ENTITY_BREATHL, MSB_WIDTH SHL 5 + MSB_X, MSB_HEIGHT SHL 5 + MSB_Y, MSB_OFF, MSB_ON, MSB_DELAY
ENDM

;
; M_SCREEN_SPRITE
;
; Used at tuerkas128_scr_map.asm to define a sprite
;
; MSS_TYPE      = Type of sprite
; MSS_X         = Horizontal position (0-31)
; MSS_Y         = Vertical position (0-23)
; MSS_PARAM1    = WALKERS:    Left boundary (even X between 0 and 31)
;                 CYCLES:     2*T128_ENUM_00 = Initial movement forward
;                             2*T128_ENUM_15 = Initial movement backward
;                 JUMPER:     Left boundary (even X between 0 and 31)
;                 PROJECTILE: 2*Initial Delay (high nibble)
; MSS_PARAM2    = WALKERS:    Right boundary (even X between 0 and 31)
;                 CYCLES:     2*(Movement table #)
;                 JUMPER:     Right boundary (even X between 0 and 31)
;                 PROJECTILE: 2*Initial Delay (low nibble)
; MSS_INSTANCES = Max number of instances to spawn (255 = infinite respawns)

M_SCREEN_SPRITE MACRO MSS_TYPE, MSS_X, MSS_Y, MSS_PARAM1, MSS_PARAM2, MSS_INSTANCES
 			  defb 	T128_ENTITY_SPRITE, MSS_TYPE, MSS_X*8, MSS_Y*8, (MSS_PARAM1/2) SHL 4 + (MSS_PARAM2/2), MSS_INSTANCES
ENDM


;
; M_SCREEN_PORTAL
; 
; Used at tuerkas128_scr_map.asm to define a portal to another screen
; 
; MSP_X          = Horizontal position (0-31)
; MSP_Y          = Vertical position (0-23)
; MSP_WIDTH      = Width of portal (0-7)
; MSP_HEIGHT     = Height of portal (0-7)
; MSP_NEW_X      = Horitontal position in new screen (0-31)
; MSP_NEW_Y      = Vertical position in new screen (0-23)
; MSP_NEW_SCREEN = New screen
;
M_SCREEN_PORTAL MACRO MSP_X, MSP_Y, MSP_WIDTH, MSP_HEIGHT, MSP_NEW_X, MSP_NEW_Y, MSP_NEW_SCREEN
 			  defb 	T128_ENTITY_PORTAL, MSP_WIDTH SHL 5 + MSP_X, MSP_HEIGHT SHL 5 + MSP_Y, MSP_NEW_X, MSP_NEW_Y, MSP_NEW_SCREEN
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Game variables
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; M_GAME_VAR
;
; Define a GameVar

; MGV_DEFAULT	= Initial value
; MGV_TYPE		= Type of GameVar. It is used to call the appropriate GameVar Rendering Routine
; MGV_X			= Horizontal position on scoreboard
; MGV_Y			= Vertical position on scoreboard
; MGV_COLS		= Width on scoreboard (in columns)
; MGV_ROWS		= Height on scoreboard (in rows)
; MGV_TIMER		= Associated timer ($ff if none)
; MGV_DISPLAY	= Address of the associated decimal display ($0000 if none)
;
M_GAME_VAR MACRO MGV_DEFAULT, MGV_TYPE, MGV_X, MGV_Y, MGV_COLS, MGV_ROWS, MGV_TIMER, MGV_DISPLAY
					defb	0																			; Value
					defb	MGV_DEFAULT																	; Default value
					defb	MGV_TYPE SHL 2																; TTTTTTFF
																										;  TTTTTT = Type of GameVar
																										;  FF     = Rendering flag:
																										;		 	 2: Render in banck 5
																										;			 1: Transfer to Bank 7
																										;			 0: GameVar not changed

					defb	((MGV_Y AND %00000111) SHL 5) + MGV_X, %01000000 + (MGV_Y AND %11111000)	; Screen Address
					defb	((MGV_COLS-1) SHL 4 )+ (MGV_ROWS-1)											; CCCCRRRR
																										;  CCCC = Width on scoreboard minus 1 
																										;  RRRR = Height on scoreboard minus 1
					defb	MGV_TIMER																	; Associated timer
					defw	MGV_DISPLAY																	; Associated decimal display
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Timers
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; M_TIMER
;
; Define a Timer

; MT_SPEED			= number of Game Loops before decrementing Timer GameVar
; MT_TRIGGER_GV		= Trigger GameVar (address)
; MT_TIMER_GV		= Timer GameVar (Address)
; MT_TIMER_GV_VALUE	= Timer GameVar initial value
; MT_FX_NUMBER		= Number of FX to be produced when timer reaches 0. $ff if no FX is to be produced
;
M_TIMER MACRO MT_SPEED, MT_TRIGGER_GV, MT_TIMER_GV, MT_TIMER_GV_VALUE, MT_FX_NUMBER
					defb	0							; Counter
					defb	MT_SPEED					; Timer speed
					defw	MT_TRIGGER_GV				; Trigger GameVar
					defw	MT_TIMER_GV					; Timer GameVar
					defb	MT_TIMER_GV_VALUE			; Timer GameVar initial value
					defb	MT_FX_NUMBER				; FX
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FSM parameters of main char
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; M_FSM_PARAM
;
; Used at tuerkas128_fsm_MAINCHAR.asm to define parameters for every state in Main Char's Finite State Machine
;
; MFP_SPRITE 		(word)	Pointer to phase 0 of sprite for current state
; MFP_RENDER		(byte)	T128_SPR_NORMAL / T128_SPR_ROTATE
; MFP_PHASES		(byte)	Number of phases for current state
; MFP_COLUMNS		(byte)  Sprite width in column for current state, including extra column for prerotated sprites (in case such a column is needed)
; MFP_SCANLINES 	(byte)	Sprite height in pixels for current state
; MFP_X_CORRECTION	(byte)	T128_SPR_X_ON, if current state has an extra column for prerotated sprites and sprite is looking left
;                           T128_SPR_X_OFF, if current state has not an extra column or if current state is looking right 
; MFP_SPEED			(byte)	Number of game loops before processing current state
; MSP_ATTRIBUTE		(byte)  Attribute of sprite for current state, or 0 for background attribute
; MSP_ROUTINE		(word)	Address of routine to process current state
;
; Constraints:
;
; (MFP_COLUMNS-1)*MFP_SCANLINES*T128_MASKED_SPRITES < 256
; MFP_SCANLINES*T128_MASKED_SPRITES*2 < 256
; MFP_COLUMNS*MFP_SCANLINES < 256
;

M_FSM_PARAM MACRO MFP_SPRITE, MFP_RENDER, MFP_PHASES, MFP_COLUMNS, MFP_SCANLINES, MFP_X_CORRECTION, MFP_SPEED, MSP_ATTRIBUTE, MSP_ROUTINE
				defw	MFP_SPRITE
				defb	MFP_RENDER
				defb	MFP_PHASES
				defb	MFP_COLUMNS
				defb	MFP_SCANLINES
				defb	(MFP_COLUMNS-1)*MFP_SCANLINES*T128_MASKED_SPRITES
				defb	MFP_SCANLINES*T128_MASKED_SPRITES*2
				defb	MFP_COLUMNS*MFP_SCANLINES
				defb	MFP_X_CORRECTION
				defb	MFP_SPEED
				defb	MSP_ATTRIBUTE
				defw	MSP_ROUTINE
ENDM					