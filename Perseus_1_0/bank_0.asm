;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P E R S E U S 
;
; RAM 0
;
; - Entity managment for Animated Blocks
; - Entity managment for Breath Areas
; - Entity managment for Portals
; - Entity managment for Screen Areas
; - Entity managment for Sprites (including Main Char)
; - Scoreboard routines
; - Event management and interaction
; - Block collision routines
; - Interface for Music & FX with Bank 0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC T128_OccupiedCellsRAM5, T128_CellsBufferRAM5, T128_OccCellsStackRAM5
PUBLIC T128_OccCellsAttribRAM5, T128_CellsAttrRAM5, T128_OccCellsAttrStRAM5

PUBLIC T128_ScreenSprPoolNum, T128_ScreenSprPool
PUBLIC T128_GraphicPoolABPtr, T128_GraphicPoolSPRPtr
PUBLIC T128_ScreenSprGaps, T128_ScreenSprGapsPtr, T128_ScreenSprLast, T128_ScreenSprLastPtr	
PUBLIC T128_ScreenPortalsNum, T128_CheckPortal
PUBLIC T128_ScreenAreasNum
PUBLIC T128_ScreenBreathsNum
;PUBLIC T128_ScreenAreasNum  , T128_ScreenAreas
;PUBLIC T128_ScreenBreathsNum, T128_ScreenBreaths


org $c000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S Y M B O L S ,   C O N S T A N T S   &   M A C R O S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\bank_2_data.sym"								; Symbols for RAM 2 variables
include ".\bank_5.sym"									; Symbols for RAM 5 variables
include ".\bank_S2.sym"									; Symbols for Slow RAM number 2
include ".\framework\tuerkas128_constants.asm"			; Framework constants
include ".\framework\tuerkas128_global.asm"				; Global code control
include ".\framework\tuerkas128_macros.asm"				; Framewwork macros


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; V A R I A B L E S   &   D A T A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Data structures for sprite rendering algorithm (RAM 5)
;
T128_OccupiedCellsRAM5	defb	0									; Number of cells occupied by sprites
T128_CellsBufferRAM5	defs	T128_BYTES_CELL*T128_MAX_CELLS		; Occupied cells buffer 
T128_OccCellsStackRAM5	defw	T128_CellsBufferRAM5				; Stack
;
T128_OccCellsAttribRAM5	defb	0									; Number of cells occupied by sprites attributes
T128_CellsAttrRAM5		defs	T128_BYTES_CELLATTR*T128_MAX_CELLS	; Occupied cells attribute buffer 
T128_OccCellsAttrStRAM5	defw	T128_CellsAttrRAM5					; Stack

;
; Data structures for sprite management
;
T128_ScreenSprLast		defb	0						; Number of last sprite vailable in T128_ScreenSprites
T128_ScreenSprLastPtr	defw	T128_ScreenSprites		; Address of last available sprite in T128_ScreenSprites
T128_ScreenSprGaps		defb	0						; Number of free gaps in T128_ScreenSprites
T128_ScreenSprGapsPtr	defs	T128_SCREEN_MAX_SPRS*2 	; Pointers to free gaps in T128_ScreenSprites
;
; Data structures for sprite spawning
; 
T128_ScreenSprPoolNum	defb	0						; Number of screen sprites in T128_ScreenSprPool
T128_ScreenSprPool		defs	T128_SPR_POOL_SIZE*T128_SCREEN_MAX_SPRPOOL
														; Every sprite pool is defined by:
														;   Type of sprite					[byte]
														;   Inital x						[byte]
														;   Inital y						[byte]
														;   Coordinate limits				[byte]
														;   Instances counter				[byte]
														;   Respawn counter					[byte]														
														;   Address of graphic  			[word]
														;   Address of screen entity data  	[word]
;
; Pointers to T128_GraphicPool for Animated Blocks and Sprites
; 
T128_GraphicPoolABPtr	defs	(T128_ANIMBLK_LAST+1)*2	; Pointers to graphic pool for Animated Blocks
T128_GraphicPoolSPRPtr	defs	(T128_SPRITE_LAST+1)*2 	; Pointers to graphic pool for Sprites

;
; Data structures for screen breaths management
;
T128_ScreenBreathsNum	defb	0						; Number of breath areas in current screen
T128_ScreenBreaths		defs	T128_BA_TABLE_SIZE*T128_SCREEN_MAX_BREATHS
														; Every breath area is defined by:
														;   T000000S				[byte]
														;     T = 1 Right / 0 Left 
														;	  S = 1 On / 0 Off
														;   X						[byte]
														;   Y						[byte]
														;   OFF TIME 				[byte]
														;   ON TIME  				[byte]														
														;   COUNTER					[byte]
														;   INITIAL DELAY 			[byte]
;
; Data structures for screen areas management
;
T128_ScreenAreasNum		defb	0						; Number of front-lighted or back-lighted areas in current screen
T128_ScreenAreas		defs	T128_SA_TABLE_SIZE*T128_SCREEN_MAX_AREAS
														; Every area is defined by:
														;   X MIN = Left column 	[byte]
														;   X MAX = Right column	[byte]
														;   Y MIN = Top row			[byte]
														;   Y MAX = Bottom row		[byte]

;
; Data structures for portals management 
;
T128_CheckPortal		defb	1						; 1 = fire must be released before Portal is checked again
T128_ScreenPortalsNum	defb	0	
T128_ScreenPortals		defs	T128_PRTL_TABLE_SIZE*T128_SCREEN_MAX_PRTL
														; Every portal is defined by:
														;   NEW_SCREEN	[byte]														
														;	X MIN 		[byte]
														; 	X MAX 		[byte]
														; 	Y MIN 		[byte]
														; 	Y MAX 		[byte]
														;   NEW_X	 	[byte]
														;   NEW_Y	 	[byte]														


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\AY\tuerkas128_AY_interfaceB0.asm"	; Interface for music & FX with Bank 0
include ".\framework\tuerkas128_code_scoreboard.asm"	; Scoreboard
;include ".\framework\tuerkas128_code_input.asm"		; Keyboard & joystick routines  
include ".\framework\tuerkas128_code_block_col.asm"		; Block collisions
include ".\framework\tuerkas128_code_events.asm"		; Event management and interaction
;include ".\framework\tuerkas128_code_screen.asm"		; Screen processing
include ".\framework\tuerkas128_code_entity_AB.asm"		; Entity management: Animated Blocks
include ".\framework\tuerkas128_code_entity_BA.asm"		; Entity management: Breath Areas
include ".\framework\tuerkas128_code_entity_PRTL.asm"	; Entity management: Portals
include ".\framework\tuerkas128_code_entity_SA.asm"		; Entity management: Screen Areas
include ".\framework\tuerkas128_code_entity_SPR.asm"	; Entity management: Sprites

PUBLIC _END_BK0
_END_BK0: