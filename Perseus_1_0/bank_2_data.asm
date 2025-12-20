;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P E R S E U S 
;
; RAM 2 data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_BK2_DATA_1, _END_BK2_DATA_1, _BEGIN_BK2_DATA_2, _END_BK2_DATA_2

PUBLIC T128_MapHD, T128_MapHD_PAGE
PUBLIC T128_ClockTicksIddle
PUBLIC T128_GameFXMusic
PUBLIC T128_EventControl, T128_InputSource, T128_KeyBase, T128_KeyLeft, T128_SinclairLeft
PUBLIC T128_GameLoops

PUBLIC T128_ScreenCurrent

PUBLIC T128_MainChar, T128_MainCharAux

PUBLIC T128_DeathBlkCol, T128_ProcessDeath

PUBLIC T128_ScreenInfo
PUBLIC T128_ScreenAnimBlkNum, T128_ScreenAnimBlk
PUBLIC T128_ScreenSpritesNum, T128_ScreenSprites

PUBLIC T128_GraphicPoolNext

PUBLIC T128_AB_RenderSize

PUBLIC T128_BackupByte1, T128_BackupByte2, T128_BackupByte3

PUBLIC T128_BlockGraphicSize

PUBLIC T128_AY_Control, T128_AY_SongAction, T128_AY_FXAction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O N S T A N T S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


include ".\framework\tuerkas128_constants.asm"				


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; V A R I A B L E S   A N D   D A T A   S T R U C T U R E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $8ecd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             ;
; D A T A   S E C T I O N   1 ;
;                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_BEGIN_BK2_DATA_1:

;
; Main char data
;

include ".\graphics\MAINCHAR\tuerkas128_spr_bitmap.asm"	; Sprites for Perseus

;
;
; Data structures for current screen
;
T128_ScreenInfo			defb	%00000000				; Screen info: LFFFFFFF
														; L       = 1 for back-lighted screens  /  0 for normal-lighted screens
														; FFFFFFF = Free (not used yet)
T128_ScreenAnimBlkNum	defb	0						; Number of animated blocks in current screen
T128_ScreenAnimBlk		defs	T128_AB_TABLE_SIZE*T128_SCREEN_MAX_ANIM 
														; Every animated block is defined by:
														; 	SCREEN ADDRESS					[word]
														;   ATTRIBUTE ADDRESS (MSB)			[byte]
														; 	CURRENT PHASE					[byte]
														; 	STATE							[byte]
														;   DELAY / 1BITFLAG / GAMEVAR		[byte]														
														; 	ANIMATED BLOCK DEFINITION TABLE	[word]
														;	CURRENT DURATION				[byte]
														; 	GRAPHIC ADDRESS					[word]
														; 	CURRENT PHASE GRAPHIC ADDRESS 	[word]
														;   ADDRESS OF SCREEN ENTITY DATA   [word]
														;   CONTROL FLAG (1bitFlag)			[byte]
;
T128_ScreenSpritesNum	defb	0						; Number of sprites in current screen
T128_ScreenSprites		defs	T128_SPR_TABLE_SIZE*T128_SCREEN_MAX_SPRS
														; Every sprite is defined by:
														;	SPRITE ADDRESS						[word]
														;	IABWCZZR							[byte]
														;	  I  = 0 - normal        /  1 - invisible
														;	  A  = 0 - inactive      /  1 - active
														;     B  = 1 if sprite is affected by Breath Areas														
														;     W  = Wait-next-loop in FSM routine
														;     C  = child sprite
														;     ZZ = 00 - background 1 / 01 - background 2 / 10 - foreground 1 / 11 - foreground 2
														;	  R  = 0 - normal        /  1 - rotated
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
														;	SPRITE HEIGHT in scanlines)			[byte]
														;	SPRITE ATTRIBUTE					[byte]
														;	STATE								[byte]
														; 	PHASE COUNTER						[byte]
														;	SPRITE BASE ADDRESS					[word]
														;	POINTER TO SPRITE DEFINITION TABLE	[word]
														;	MOVEMENT CONTROL					[byte]
														;      Boundaries (WALKERS)
														;      Movement table (CYCLES)
														;      Initial delay (PROJECTILE)
														;	COUNTER 1							[byte]
														;   FLAGS: BFFFFFFH						[byte]
														;     B = Mainchar's bullet
														;     F = Free to use in FSMs
														;     H = Hidden sprite: do not render
														;   CHILD SPRITE #1						[word]
														;   CHILD SPRITE #2						[word]		
														;   COUNTER 2							[byte]
														;	ADDRESS OF SCREEN ENTITY DATA   	[word]

;
; Graphic Pool
;
T128_GraphicPoolNext	defw	T128_GraphicPool		; Pointer to next available address in Graphic Pool on current screen
T128_GraphicPool		defs	4096					; 4 KBs for sprites and animated blocks on currente screen
T128_GraphicPoolEnd:

;
; Data structures for sprite rendering algorithm (RAM 7) [BITMAP]
;
T128_OccupiedCellsRAM7	defb	0									; Number of cells occupied by sprites
T128_CellsBufferRAM7	defs	T128_BYTES_CELL*T128_MAX_CELLS		; Occupied cells buffer 
T128_OccCellsStackRAM7	defw	T128_CellsBufferRAM7				; Stack


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                     ;
; M U S I C   %   F X   C O N T R O L ;
;                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Control: 000000MF
;
;   M = 0 Enable music  /  1 Mute music
;   F = 0 Enable FX     /  1 Mute FX
;
T128_AY_Control		defb	%00000000

;
; Action when end of song is reached
;
;   0 						= Play song
;   T128_AY_CTRL_ENDSONG  	= Stop song ($80)
;   T128_AY_CTRL_LOOPSONG 	= Loop song ($FF)
;
T128_AY_SongAction	defb	T128_AY_CTRL_ENDSONG

;
; Action when end of FX is reached
;
;   0 						= Play FX
;   T128_AY_CTRL_ENDFX 		= Stop FX ($c0)
;
T128_AY_FXAction	defb	T128_AY_CTRL_ENDFX


_END_BK2_DATA_1:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             ;
; D A T A   S E C T I O N   2 ;
;                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Hardness and depth map
;
T128_MapHD_PAGE			EQU		$b8						; T128_MapHD_PAGE must be in the form $x8, being $8 <= x <= $b
org T128_MapHD_PAGE*256
_BEGIN_BK2_DATA_2:
T128_MapHD				defs	768						

;
; Rotation table: T128_RotateTable address must be in the form XX00 ==> 8b00 / 9b00 / ab00 / etc
;
T128_RotateTable:		defb	%00000000, %10000000, %01000000, %11000000, %00100000, %10100000, %01100000, %11100000, %00010000, %10010000, %01010000, %11010000, %00110000, %10110000, %01110000, %11110000
						defb	%00001000, %10001000, %01001000, %11001000, %00101000, %10101000, %01101000, %11101000, %00011000, %10011000, %01011000, %11011000, %00111000, %10111000, %01111000, %11111000
						defb	%00000100, %10000100, %01000100, %11000100, %00100100, %10100100, %01100100, %11100100, %00010100, %10010100, %01010100, %11010100, %00110100, %10110100, %01110100, %11110100
						defb	%00001100, %10001100, %01001100, %11001100, %00101100, %10101100, %01101100, %11101100, %00011100, %10011100, %01011100, %11011100, %00111100, %10111100, %01111100, %11111100
						defb	%00000010, %10000010, %01000010, %11000010, %00100010, %10100010, %01100010, %11100010, %00010010, %10010010, %01010010, %11010010, %00110010, %10110010, %01110010, %11110010
						defb	%00001010, %10001010, %01001010, %11001010, %00101010, %10101010, %01101010, %11101010, %00011010, %10011010, %01011010, %11011010, %00111010, %10111010, %01111010, %11111010
						defb	%00000110, %10000110, %01000110, %11000110, %00100110, %10100110, %01100110, %11100110, %00010110, %10010110, %01010110, %11010110, %00110110, %10110110, %01110110, %11110110
						defb	%00001110, %10001110, %01001110, %11001110, %00101110, %10101110, %01101110, %11101110, %00011110, %10011110, %01011110, %11011110, %00111110, %10111110, %01111110, %11111110
						defb	%00000001, %10000001, %01000001, %11000001, %00100001, %10100001, %01100001, %11100001, %00010001, %10010001, %01010001, %11010001, %00110001, %10110001, %01110001, %11110001
						defb	%00001001, %10001001, %01001001, %11001001, %00101001, %10101001, %01101001, %11101001, %00011001, %10011001, %01011001, %11011001, %00111001, %10111001, %01111001, %11111001
						defb	%00000101, %10000101, %01000101, %11000101, %00100101, %10100101, %01100101, %11100101, %00010101, %10010101, %01010101, %11010101, %00110101, %10110101, %01110101, %11110101
						defb	%00001101, %10001101, %01001101, %11001101, %00101101, %10101101, %01101101, %11101101, %00011101, %10011101, %01011101, %11011101, %00111101, %10111101, %01111101, %11111101
						defb	%00000011, %10000011, %01000011, %11000011, %00100011, %10100011, %01100011, %11100011, %00010011, %10010011, %01010011, %11010011, %00110011, %10110011, %01110011, %11110011
						defb	%00001011, %10001011, %01001011, %11001011, %00101011, %10101011, %01101011, %11101011, %00011011, %10011011, %01011011, %11011011, %00111011, %10111011, %01111011, %11111011
						defb	%00000111, %10000111, %01000111, %11000111, %00100111, %10100111, %01100111, %11100111, %00010111, %10010111, %01010111, %11010111, %00110111, %10110111, %01110111, %11110111
						defb	%00001111, %10001111, %01001111, %11001111, %00101111, %10101111, %01101111, %11101111, %00011111, %10011111, %01011111, %11011111, %00111111, %10111111, %01111111, %11111111

;
; FX & Music during gameplay. This value is copied to T128_AY_Control when a new game is started
; 
;
; Values: 000000MF
;
;   M = 0 Enable music  /  1 Mute music
;   F = 0 Enable FX     /  1 Mute FX
;
T128_GameFXMusic		defb	%00000000

;
; Keyboard and joystick events
;
T128_EventControl		defb	0

;
; Input source = 0 Keyboard/sinclair     1 = Kempston
; 
T128_InputSource:	defb	0

;
; T128_KeyBase = T128_KeyLeft for Keyboard.
;              = T128_SinclairLeft for Sinclair Joystick
; 
T128_KeyBase:		defw	T128_KeyLeft

;
; Sinclair 1 joystick keys
;
T128_SinclairLeft	defb	$03
T128_SinclairRight	defb	$0b
T128_SinclairUp		defb	$1b
T128_SinclairDown	defb	$13
T128_SinclairFire	defb	$23

;
; Sinclair 2 joystick keys
;
;T128_SinclairLeft	defb	$24
;T128_SinclairRight	defb	$1c
;T128_SinclairUp	defb	$0c
;T128_SinclairDown	defb	$14
;T128_SinclairFire	defb	$04		

;
; Default keys
;
T128_KeyLeft		defb	$1a
T128_KeyRight		defb	$22
T128_KeyUp			defb	$25
T128_KeyDown		defb	$26
T128_KeyFire		defb	$20		
T128_KeyPause		defb	$01
T128_KeyQuit		defb	$02

;
; Clock ticks and game loop counter
;
T128_ClockTicksIddle	defw	0						; Clock ticks counter before entering iddle state
T128_ClockTicks			defb	0						; Clock ticks counter
T128_ClockTicksPrevious	defb	0
T128_GameLoops			defb	0						; +1 every game loop

;
; Backup variables
;
T128_BackupStack		defw	0						; Backup for sp
T128_BackupByte1		defb	0						; Backup for a byte value 
T128_BackupByte2		defb	0						; Backup for a byte value
T128_BackupByte3		defb	0						; Backup for a byte value

;
; Screen navigation
;
T128_ScreenCurrent		defb	0						; Current screen
T128_ScreenUp			defb	$ff						; Up screen
T128_ScreenDown			defb	$ff						; Down screen
T128_ScreenLeft			defb	$ff						; Left screen
T128_ScreenRight		defb	$ff						; Right screen

;
; Lookup table for screen rendering algortihm
; Size of block bitmap in bytes for every combination of block height x width, ranging from 1x1 to 4x4
; 
T128_BlockGraphicSize	defb	8, 16, 24, 32, 16, 32, 48, 64, 24, 48, 72, 96, 32, 64, 96, 128

;
; Animated Blocks rendering sizes (in pixels)
;
T128_AB_RenderSize:		defb	16, 8
						defb	16, 16
						defb	8 , 16
						defb	8 , 8
						defb	8, 32
						defb	32, 8
						defb	24, 8

;
; Main Char sprite parameters:
;
; 	0  = sprite address
;	2  = IABWCZZR
;		   I  = 0 - normal        /  1 - invisible
;		   A  = 0 - inactive      /  1 - active
;          B  = 1 if sprite is affected by Breath Areas
;          W  = Wait-next-loop in FSM routine
;          C  = child sprite
;          ZZ = 00 - background 1 / 01 - background 2 / 10 - foreground 1 / 11 - foreground 2
;		   R  = 0 - normal        /  1 - rotated
;    	 A, B, W and ZZ are not used in Main Char
;	3  = Initial relative address for rotated mode 	= (columns-1)*scanlines*2
;	4  = Relative address decrement for rotated mode 	= scanlines*2*2
;	5  = X (0-31)
;	6  = x (0-255) 
;	7  = Y (0-23)
;	8  = y (0-191)
;	9  = sprite width (in columns)
;	10 = sprite width (in pixels) 
;	11 = sprite height (in scanlines)
;	12 = sprite attribute
;	13 = state
;	14 = phase counter
;	15 = state speed 
;	16 = speed counter
;	17 = jump table pointer (word)
;	18 = slide counter / punch-knife subphase counter
;	19 = counter of steps before jumping / counter of steps before sliding
;   20 = not used
;   21 = not used
;   22 = not used (word)
;   24 = not used (word)
;   26 = not used (byte)
;	27 = not used (word)
;
T128_MainChar:		defw	Spr_PerseusIddle
					defb	T128_SPR_VISIBLE + T128_SPR_ACTIVE + T128_SPR_NORMAL
					defb	(3-1)*32*2, 32*2*2
					defb	18, 18*8, 18, 18*8, 3, 16, 32, 0, 0, 0, 0, 0, 0, 0, 0

T128_MainCharAux:	defw	Spr_PerseusTurnHead
					defb	T128_SPR_VISIBLE + T128_SPR_INACTIVE + T128_SPR_NORMAL
					defb	0, 16*2*2				
					defb	18, 18*8, 18, 18*8, 1, 8, 16, 0, 0, 0, 0, 0, 0, 0, 0

T128_DeathBlkCol:	defb	0							; !=0 if a collision is detected between a sprite and a DEATH block
T128_ProcessDeath:	defb	0							; !=0 if Main char is killed and death must be processed


;
; Data structures for sprite rendering algorithm (RAM 7) [ATTRIBUTE]
;
T128_OccCellsAttribRAM7	defb	0									; Number of cells occupied by sprites attributes
T128_CellsAttrRAM7		defs	T128_BYTES_CELLATTR*T128_MAX_CELLS	; Occupied  cells attribute buffer 
T128_OccCellsAttrStRAM7	defw	T128_CellsAttrRAM7					; Stack

;
; Copy of block entity data for current screen
; 
T128_SDRAM2_End1		defw	0						; Current screen ending address (block data)
T128_SDRAM2_End2		defw	0						; Current screen ending address (entity data)
T128_ScreenDataRAM2		defs	256						; Current screen data and entity data
T128_SDRAMBF2_EntSource	defw	0						; Current screen entity data address in RAM BF2
T128_SDRAMBF2_EntLength	defw	0						; Current screen entity data length in RAM BF2



_END_BK2_DATA_2: