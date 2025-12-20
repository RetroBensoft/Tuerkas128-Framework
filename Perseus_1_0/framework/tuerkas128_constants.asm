;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; E N G I N E   C O N S T A N T S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Frames Per Second
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_FPS				EQU		2						; 1 = 50 fps   2 = 25 fps   3 = 16,66 fps   4 = 12,5 fps				


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Input control
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Values for input events
; These values are equal to Kempston joystick input codes in port 0x1f (000FUDLR)  
; 
T128_EVENT_NULL			EQU 	0
T128_EVENT_LEFT			EQU 	2
T128_EVENT_RIGHT		EQU 	1
T128_EVENT_UP			EQU 	8
T128_EVENT_UP2			EQU		T128_EVENT_UP + T128_EVENT_LEFT + T128_EVENT_RIGHT
T128_EVENT_DOWN			EQU		4
T128_EVENT_UPLEFT		EQU		T128_EVENT_UP + T128_EVENT_LEFT
T128_EVENT_UPRIGHT		EQU 	T128_EVENT_UP + T128_EVENT_RIGHT
T128_EVENT_DOWNLEFT		EQU		T128_EVENT_DOWN + T128_EVENT_LEFT
T128_EVENT_DOWNRIGHT 	EQU		T128_EVENT_DOWN + T128_EVENT_RIGHT
T128_EVENT_FIRE			EQU		16
T128_NOT_EVENT_FIRE		EQU		255 - T128_EVENT_FIRE
T128_EVENT_NULL_3S		EQU 	128
;
; Clock ticks before changing to iddle state
; 2 = 0 s     32 = 0.75 s      64 = 1.25 s     128 = 2.5 s     255 = 5 s
;
T128_TICKS_IDDLE		EQU		150					; 3 seconds


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite rendering algorithm
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Maximun number of occupied cells by sprites
;
T128_MAX_CELLS			EQU		120						; Must be equal or less than 126?
;
; Size in bytes for an individual cell saved in cells buffer
;	2 bytes = screen address of the cell
; 	8 bytes = screen scanlines backup for the cell
;
T128_BYTES_CELL			EQU		10
;
; Size in bytes for an individual cell saved in cells attribute buffer
;	2 bytes = attribute address of the cell
; 	1 byte  = attribute of the cell
;
T128_BYTES_CELLATTR		EQU		3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Screen rendering algorithm
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Map format
;
T128_SCREEN_ROW_1		EQU		%00010000
; T128_SCREEN_ROW_1 = 00000001 if the format is RRRRRRRR (256 rows x   1 columns)
; T128_SCREEN_ROW_1 = 00000010 if the format is RRRRRRRC (128 rows x   2 columns)
; T128_SCREEN_ROW_1 = 00000100 if the format is RRRRRRCC ( 64 rows x   4 columns)
; T128_SCREEN_ROW_1 = 00001000 if the format is RRRRRCCC ( 32 rows x   8 columns)
; T128_SCREEN_ROW_1 = 00010000 if the format is RRRRCCCC ( 16 rows x  16 columns)
; T128_SCREEN_ROW_1 = 00100000 if the format is RRRCCCCC (  8 rows x  32 columns)
; T128_SCREEN_ROW_1 = 01000000 if the format is RRCCCCCC (  4 rows x  64 columns)
; T128_SCREEN_ROW_1 = 10000000 if the format is RCCCCCCC (  2 rows x 128 columns)
; T128_SCREEN_ROW_1 = 00000000 if the format is CCCCCCCC (  1 rows x 256 columns)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Game area limits
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_MIN_Y				EQU		2					; First screen row (top border) 
T128_MAX_Y				EQU		24					; Last screen row (bottom border) +1
T128_MIN_X				EQU		0					; First screen column (left border
T128_MAX_X				EQU		31					; Last screen column (right border)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite properties
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_SPR_VISIBLE		EQU		%00000000				
T128_SPR_INVISIBLE		EQU		%10000000				; Special rendering efect (only in mask mode)

T128_SPR_ACTIVE			EQU		%01000000				
T128_SPR_INACTIVE		EQU		%00000000				; Inactive. Sprite is not processed or rendered

T128_SPR_NORMAL			EQU		%00000000				; Render normal sprite
T128_SPR_ROTATE			EQU		%00000001				; Rotate sprite before rendering
;
T128_SPR_WIDTH_1		EQU		1						; Sprite width (in columns)
T128_SPR_WIDTH_2		EQU		2						; Sprite width (in columns)
T128_SPR_WIDTH_3		EQU		3						; Sprite width (in columns)
T128_SPR_WIDTH_4		EQU		4						; Sprite width (in columns)
T128_SPR_WIDTH_8 		EQU		8						; Sprite width for colisions (in pixels)
T128_SPR_WIDTH_16		EQU		16						; Sprite width for colisions (in pixels)
T128_SPR_WIDTH_32		EQU		32						; Sprite width for colisions (in pixels)
T128_SPR_WIDTH_24		EQU		24						; Sprite width for colisions (in pixels)
T128_SPR_HEIGHT_8		EQU		8 						; Sprite height (in scanlines)
T128_SPR_HEIGHT_16		EQU		16						; Sprite height (in scanlines)
T128_SPR_HEIGHT_24		EQU		24						; Sprite height (in scanlines)
T128_SPR_HEIGHT_32		EQU		32						; Sprite height (in scanlines)
;
T128_SPR_X_ON			EQU		255						; X correction is needed
T128_SPR_X_OFF			EQU		0						; X correction is not needed
;
T128_SPR_BACKGROUND1	EQU		%00000000
T128_SPR_BACKGROUND2	EQU		%00000010
T128_SPR_FOREGROUND1	EQU		%00000100
T128_SPR_FOREGROUND2	EQU		%00000110

;
; Sprite structure
;
SPR_PARAM.ADDRESS		EQU		0						; Word
SPR_PARAM.FLAGS			EQU		2						; Byte
SPR_PARAM.INIT_ADDR_ROT	EQU		3						; Byte
SPR_PARAM.DEC_ADDR_ROT	EQU		4						; Byte
SPR_PARAM.XX			EQU		5						; Byte
SPR_PARAM.x				EQU		6						; Byte
SPR_PARAM.YY			EQU		7						; Byte
SPR_PARAM.y				EQU		8						; Byte
SPR_PARAM.WIDTH_COLUMNS	EQU		9						; Byte
SPR_PARAM.WIDTH_PIXELS	EQU		10						; Byte
SPR_PARAM.HEIGHT_PIXELS	EQU		11						; Byte
SPR_PARAM.ATTRIBUTE		EQU		12						; Byte
SPR_PARAM.STATE			EQU		13						; Byte
SPR_PARAM.PHASE			EQU		14						; Byte
SPR_PARAM.BASE_ADDRESS	EQU		15						; Byte
SPR_PARAM.SPR_DEF_TABLE	EQU		17						; Word
SPR_PARAM.CONTROL		EQU		19						; Byte
SPR_PARAM.COUNTER1		EQU		20						; Byte
SPR_PARAM.FLAX_AUX		EQU		21						; Byte
SPR_PARAM.CHILD_SPR1	EQU		22						; Word
SPR_PARAM.CHILD_SPR2	EQU		24						; Word
SPR_PARAM.COUNTER2		EQU		26						; Byte
SPR_PARAM.SCR_ENT_DATA	EQU		27						; Word


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Screen colors
; Label format: PAPER_INK
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_BLACK_WHITE_DK		EQU		0*8+7
T128_BLACK_WHITE		EQU		0*8+7+64
T128_BLACK_YELLOW_DK	EQU		0*8+6
T128_BLACK_YELLOW		EQU		0*8+6+64
T128_BLACK_CYAN_DK		EQU		0*8+5
T128_BLACK_CYAN			EQU		0*8+5+64
T128_BLACK_GREEN_DK		EQU		0*8+4
T128_BLACK_GREEN		EQU		0*8+4+64
T128_BLACK_MAGENTA_DK	EQU		0*8+3
T128_BLACK_MAGENTA		EQU		0*8+3+64
T128_BLACK_RED_DK		EQU		0*8+2
T128_BLACK_RED			EQU		0*8+2+64
T128_BLACK_BLUE_DK		EQU		0*8+1
T128_BLACK_BLUE			EQU		0*8+1+64
T128_BLACK_BLACK		EQU		0*8+0
T128_BLUE_WHITE_DK		EQU		1*8+7
T128_BLUE_WHITE			EQU		1*8+7+64
T128_BLUE_YELLOW_DK		EQU		1*8+6
T128_BLUE_YELLOW		EQU		1*8+6+64
T128_BLUE_CYAN_DK		EQU		1*8+5
T128_BLUE_CYAN			EQU		1*8+5+64
T128_BLUE_GREEN_DK		EQU		1*8+4
T128_BLUE_GREEN			EQU		1*8+4+64
T128_BLUE_MAGENTA_DK	EQU		1*8+3
T128_BLUE_MAGENTA		EQU		1*8+3+64
T128_BLUE_RED_DK		EQU		1*8+2
T128_BLUE_RED			EQU		1*8+2+64
T128_BLUE_BLUE_DK		EQU		1*8+1
T128_RED_WHITE_DK		EQU		2*8+7
T128_RED_WHITE			EQU		2*8+7+64
T128_RED_YELLOW_DK		EQU		2*8+6
T128_RED_YELLOW			EQU		2*8+6+64
T128_RED_GREEN_DK		EQU		2*8+4
T128_RED_GREEN			EQU		2*8+4+64
T128_RED_MAGENTA_DK		EQU		2*8+3
T128_RED_MAGENTA		EQU		2*8+3+64
T128_RED_RED_DK			EQU		2*8+2
T128_RED_BLUE_DK		EQU		2*8+1
T128_RED_BLACK_DK		EQU		2*8+0
T128_MAGENTA_YELLOW_DK	EQU		3*8+6
T128_MAGENTA_YELLOW		EQU		3*8+6+64
T128_MAGENTA_CYAN_DK	EQU		3*8+5
T128_MAGENTA_CYAN		EQU		3*8+5+64
T128_MAGENTA_GREEN_DK	EQU		3*8+4
T128_MAGENTA_RED		EQU		3*8+2+64
T128_MAGENTA_RED_DK		EQU		3*8+2
T128_GREEN_WHITE		EQU		4*8+7+64
T128_GREEN_YELLOW_DK	EQU		4*8+6
T128_GREEN_YELLOW		EQU		4*8+6+64
T128_GREEN_CYAN_DK		EQU		4*8+5
T128_GREEN_GREEN_DK		EQU		4*8+4
T128_GREEN_GREEN		EQU		4*8+4+64
T128_GREEN_MAGENTA_DK	EQU		4*8+3
T128_GREEN_RED_DK		EQU		4*8+2
T128_GREEN_BLUE_DK		EQU		4*8+1
T128_GREEN_BLACK_DK		EQU		4*8+0
T128_GREEN_BLACK		EQU		4*8+0+64
T128_CYAN_WHITE_DK		EQU		5*8+7
T128_CYAN_WHITE			EQU		5*8+7+64
T128_CYAN_YELLOW_DK		EQU		5*8+6
T128_CYAN_YELLOW		EQU		5*8+6+64
T128_CYAN_CYAN_DK		EQU		5*8+5
T128_CYAN_CYAN			EQU		5*8+5+64
T128_CYAN_GREEN_DK		EQU		5*8+4
T128_CYAN_GREEN			EQU		5*8+4+64
T128_CYAN_MAGENTA_DK	EQU		5*8+3
T128_CYAN_MAGENTA		EQU		5*8+3+64
T128_CYAN_RED_DK		EQU		5*8+2
T128_CYAN_RED			EQU		5*8+2+64
T128_CYAN_BLUE_DK		EQU		5*8+1
T128_CYAN_BLUE			EQU		5*8+1+64
T128_CYAN_BLACK_DK		EQU		5*8+0
T128_CYAN_BLACK			EQU		5*8+0+64
T128_YELLOW_WHITE_DK	EQU		6*8+7
T128_YELLOW_YELLOW_DK	EQU		6*8+6
T128_YELLOW_GREEN_DK	EQU		6*8+4
T128_YELLOW_GREEN		EQU		6*8+4+64
T128_YELLOW_MAGENTA_DK	EQU		6*8+3
T128_YELLOW_MAGENTA		EQU		6*8+3+64
T128_YELLOW_RED_DK		EQU		6*8+2
T128_YELLOW_RED			EQU		6*8+2+64
T128_YELLOW_BLUE_DK		EQU		6*8+1
T128_YELLOW_BLUE		EQU		6*8+1+64
T128_YELLOW_BLACK_DK	EQU		6*8+0
T128_YELLOW_BLACK		EQU		6*8+0+64
T128_WHITE_YELLOW_DK	EQU		7*8+6
T128_WHITE_YELLOW		EQU		7*8+6+64
T128_WHITE_CYAN_DK		EQU		7*8+5
T128_WHITE_CYAN			EQU		7*8+5+64
T128_WHITE_GREEN_DK		EQU		7*8+4
T128_WHITE_GREEN		EQU		7*8+4+64
T128_WHITE_RED_DK		EQU		7*8+2
T128_WHITE_RED			EQU		7*8+2+64
T128_WHITE_BLUE_DK		EQU		7*8+1
T128_WHITE_BLUE			EQU		7*8+1+64
T128_WHITE_BLACK_DK		EQU		7*8+0
T128_WHITE_BLACK		EQU		7*8+0+64


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Screen parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_FIRST_SCREEN		EQU		0*T128_SCREEN_ROW_1+13	; Initial screen
T128_SCREEN_FRONTLIGHT	EQU		%00000000	
T128_SCREEN_BACKLIGHT	EQU		%10000000
T128_SCREEN_MAX_BREATHS	EQU		4
T128_SCREEN_MAX_AREAS	EQU		4		
T128_SCREEN_MAX_ANIM	EQU		13						; Must be <= 15
T128_SCREEN_MAX_SPRS	EQU		20
T128_SCREEN_MAX_SPRPOOL	EQU		10						; Must be <= 31
T128_SCREEN_MAX_PRTL	EQU		2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Block parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Size (max. 4x4)
;
T128_BLOCK_WIDTH_1		EQU		%00000000
T128_BLOCK_WIDTH_2		EQU		%01000000
T128_BLOCK_WIDTH_3		EQU		%10000000
T128_BLOCK_WIDTH_4		EQU		%11000000
T128_BLOCK_HEIGHT_1		EQU		%00000000
T128_BLOCK_HEIGHT_2		EQU		%00010000
T128_BLOCK_HEIGHT_3		EQU		%00100000
T128_BLOCK_HEIGHT_4		EQU		%00110000
;
; Hardness
;
T128_BLOCK_STEP			EQU		%11111111
T128_BLOCK_MERGED		EQU		%00001110	
T128_BLOCK_LADDER		EQU		%00001000	
T128_BLOCK_DEATH		EQU		%00000110	
T128_BLOCK_SOLID		EQU		%00000100	
T128_BLOCK_PLATFORM		EQU		%00000010	
T128_BLOCK_EMPTY		EQU		%00000000	
;
; Depth
;
T128_BLOCK_DEPTH_F		EQU		%00000001				; Foreground
T128_BLOCK_DEPTH_B		EQU		%00000000				; Background
;
; Growth direction
;
T128_BLOCK_GROWTH_R		EQU		%00010000				; Right
T128_BLOCK_GROWTH_D		EQU		%00000000				; Down
;
; Type
;
T128_BLOCK_S			EQU		%00100000				; Superblock
T128_BLOCK_B			EQU		%00000000				; Block


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Entity types
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_ENTITY_SCR_AREA	EQU		1
T128_ENTITY_ANIM_BLK	EQU		2
T128_ENTITY_BREATHR		EQU		3
T128_ENTITY_BREATHL		EQU		4
T128_ENTITY_SPRITE		EQU		5
T128_ENTITY_PORTAL		EQU		6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Screen areas parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_SA_TABLE_SIZE		EQU 	4						; Size of screen areas table entries


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Animated block parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\fsm\tuerkas128_AB_types.asm"					; Animated Block Types

T128_AB_TABLE_SIZE		EQU 	16						; Size of animated blocks table entries
T128_AB_KEEPATTR		EQU		128						; If Attribute Flag = T128_AB_KEEPATTR then AB's attribute is used,
														; whether current screen has customized PAPER or not.
;
; States
;
T128_ANIMBLK_ST_UP		EQU		0						; Increasing phase
T128_ANIMBLK_ST_DOWN	EQU		1						; Decreasing phase
;
; Cycle
;
T128_ANIMBLK_UPDOWN		EQU		0						; Cycle Up, then Down: 1, 2, 3, 4, 3, 2, 1, 2, ....
T128_ANIMBLK_UPFIRST	EQU		1						; Cycle Up, then First: 1 , 2, 3, 4, 1, 2, 3, 4, 1, ...
; 
; Rendering routines
;
T128_AnimatedBlock_2x1	EQU		0
T128_AnimatedBlock_2x2	EQU		1
T128_AnimatedBlock_1x2	EQU		2
T128_AnimatedBlock_1x1	EQU		3
T128_AnimatedBlock_1x4	EQU		4
T128_AnimatedBlock_4x1	EQU		5
T128_AnimatedBlock_3x1	EQU		6
T128_AnimatedBlock_1x3	EQU		7


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Breath area parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_BA_TABLE_SIZE		EQU 	9						; Size of breath areas table entries


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\fsm\tuerkas128_SPR_types.asm"				; Animated Block Types

T128_SPR_TABLE_SIZE		EQU 	29						; Size of sprite table entries
T128_SPR_POOL_SIZE		EQU		10						; Size of spirte pool entries


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Portal parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_PRTL_TABLE_SIZE	EQU 	7						; Size of portals table entries
T128_PRTL_FX			EQU 	3						; FX number when a Portal is used


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Generic enum
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_ENUM_00			EQU		0
T128_ENUM_01			EQU		1
T128_ENUM_02			EQU		2
T128_ENUM_03			EQU		3
T128_ENUM_04			EQU		4
T128_ENUM_05			EQU		5
T128_ENUM_06			EQU		6
T128_ENUM_07			EQU		7
T128_ENUM_08			EQU		8
T128_ENUM_15			EQU		15


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Opcodes for Self Modifying Code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NEG_1ST				EQU		$ed
NEG_2ND				EQU		$44
BIT_N_A				EQU		$47
BIT_N_HL			EQU		$46
SET_N_A				EQU		$c7
SET_N_HL			EQU		$c6
RES_N_A				EQU		$87
LD_A_HL				EQU		$7e
LD_DE_A				EQU		$12
LD_A_DE				EQU		$1a
LD_HL_A				EQU		$77


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                     
; Music & FX control parameters
;                                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\sound\tuerkas128_AY_constants.asm"			; FX & music numbers

T128_AY_CTRL_EOP	EQU		$ff							; End Of Pattern
T128_AY_CTRL_EOS	EQU		$80							; End Of Song
T128_AY_CTRL_ENDSONG  EQU	$80							; Stop song
T128_AY_CTRL_LOOPSONG EQU	$FF							; Loop song
T128_AY_CTRL_ENDFX  EQU		$C0							; Stop FX


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GameVars parameters
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_GV_TABLE_SIZE	EQU 	9							; Size of GameVars record
T128_GAMEVARS		EQU		20							; Number of GameVars
T128_GAMEVARSSCRBRD	EQU		13							; Number of GameVars on scoreboard

T128_GAMEVAR_INC8	EQU		1							; Increment 8 bit value
T128_GAMEVAR_DEC8	EQU		2							; Decrement 8 bit value
T128_GAMEVAR_SET8	EQU		3							; Set 8 bit value
T128_GAMEVAR_TOGG	EQU		4							; Toggle (New value = Old value XOR $ff)
T128_GAMEVAR_ADDDEC	EQU		5							; Add a number (0 to 9) at a given position of decimal display
T128_GAMEVAR_SUBDEC	EQU		6							; Substract a number (0 to 9) at a given position of decimal display

;T128_GAMEVAR_SETDEC	EQU		7						; Set a decimal display value. If value=0, then set decimal display to 0.
; 128_GAMEVAR_SETDEC is useless)

T128_DISPLAY_000001	EQU		0*16						; Digital display: units
T128_DISPLAY_000010 EQU		1*16						; Digital display: tens
T128_DISPLAY_000100	EQU		2*16						; Digital display: hundreds
T128_DISPLAY_001000	EQU		3*16						; Digital display: thousands
T128_DISPLAY_010000	EQU		4*16						; Digital display: tens of thousands
T128_DISPLAY_100000	EQU		5*16						; Digital display: hundred of thousands
														

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                     
; Timers parameters
;                                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_TM_TABLE_SIZE	EQU		8							; Size of Timers record
T128_TIMERS			EQU		2							; Number of Timers


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                     
; Types of scoreboard items
;                                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_SB_DIGIT		EQU		0
T128_SB_BAR			EQU		1
T128_SB_ICON		EQU		2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                     
; 1 bit flags: rangin from $00 to $fe
; $ff is reserved
;                                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_1BITFLAG_00	EQU		$00
T128_1BITFLAG_01	EQU		$01
T128_1BITFLAG_02	EQU		$02
T128_1BITFLAG_03	EQU		$03
T128_1BITFLAG_04	EQU		$04
T128_1BITFLAG_05	EQU		$05
T128_1BITFLAG_06	EQU		$06
T128_1BITFLAG_07	EQU		$07
T128_1BITFLAG_08	EQU		$08
T128_1BITFLAG_09	EQU		$09
T128_1BITFLAG_0a	EQU		$0a
T128_1BITFLAG_0b	EQU		$0b
T128_1BITFLAG_0c	EQU		$0c
T128_1BITFLAG_0d	EQU		$0d
T128_1BITFLAG_0e	EQU		$0e
T128_1BITFLAG_0f	EQU		$0f
T128_1BITFLAG_10	EQU		$10
T128_1BITFLAG_11	EQU		$11
T128_1BITFLAG_12	EQU		$12
T128_1BITFLAG_13	EQU		$13
T128_1BITFLAG_14	EQU		$14
T128_1BITFLAG_15	EQU		$15
T128_1BITFLAG_16	EQU		$16
T128_1BITFLAG_17	EQU		$17
T128_1BITFLAG_18	EQU		$18
T128_1BITFLAG_19	EQU		$19
T128_1BITFLAG_1a	EQU		$1a
T128_1BITFLAG_1b	EQU		$1b
T128_1BITFLAG_1c	EQU		$1c
T128_1BITFLAG_1d	EQU		$1d
T128_1BITFLAG_1e	EQU		$1e
T128_1BITFLAG_1f	EQU		$1f
T128_1BITFLAG_20	EQU		$20
T128_1BITFLAG_21	EQU		$21
T128_1BITFLAG_22	EQU		$22
T128_1BITFLAG_23	EQU		$23
T128_1BITFLAG_24	EQU		$24
T128_1BITFLAG_25	EQU		$25
T128_1BITFLAG_26	EQU		$26
T128_1BITFLAG_27	EQU		$27
T128_1BITFLAG_28	EQU		$28
T128_1BITFLAG_29	EQU		$29
T128_1BITFLAG_2a	EQU		$2a
T128_1BITFLAG_2b	EQU		$2b
T128_1BITFLAG_2c	EQU		$2c
T128_1BITFLAG_2d	EQU		$2d
T128_1BITFLAG_2e	EQU		$2e
T128_1BITFLAG_2f	EQU		$2f
T128_1BITFLAG_30	EQU		$30
T128_1BITFLAG_31	EQU		$31
T128_1BITFLAG_32	EQU		$32
T128_1BITFLAG_33	EQU		$33
T128_1BITFLAG_34	EQU		$34
T128_1BITFLAG_35	EQU		$35
T128_1BITFLAG_36	EQU		$36
T128_1BITFLAG_37	EQU		$37
T128_1BITFLAG_38	EQU		$38
T128_1BITFLAG_39	EQU		$39
T128_1BITFLAG_3a	EQU		$3a
T128_1BITFLAG_3b	EQU		$3b
T128_1BITFLAG_3c	EQU		$3c
T128_1BITFLAG_3d	EQU		$3d
T128_1BITFLAG_3e	EQU		$3e
T128_1BITFLAG_3f	EQU		$3f
T128_1BITFLAG_40	EQU		$40
T128_1BITFLAG_41	EQU		$41
T128_1BITFLAG_42	EQU		$42
T128_1BITFLAG_43	EQU		$43
T128_1BITFLAG_44	EQU		$44
T128_1BITFLAG_45	EQU		$45
T128_1BITFLAG_46	EQU		$46
T128_1BITFLAG_47	EQU		$47
T128_1BITFLAG_48	EQU		$48
T128_1BITFLAG_49	EQU		$49
T128_1BITFLAG_4a	EQU		$4a
T128_1BITFLAG_4b	EQU		$4b
T128_1BITFLAG_4c	EQU		$4c
T128_1BITFLAG_4d	EQU		$4d
T128_1BITFLAG_4e	EQU		$4e
T128_1BITFLAG_4f	EQU		$4f
T128_1BITFLAG_50	EQU		$50
T128_1BITFLAG_51	EQU		$51
T128_1BITFLAG_52	EQU		$52
T128_1BITFLAG_53	EQU		$53
T128_1BITFLAG_54	EQU		$54
T128_1BITFLAG_55	EQU		$55
T128_1BITFLAG_56	EQU		$56
T128_1BITFLAG_57	EQU		$57
T128_1BITFLAG_58	EQU		$58
T128_1BITFLAG_59	EQU		$59
T128_1BITFLAG_5a	EQU		$5a
T128_1BITFLAG_5b	EQU		$5b
T128_1BITFLAG_5c	EQU		$5c
T128_1BITFLAG_5d	EQU		$5d
T128_1BITFLAG_5e	EQU		$5e
T128_1BITFLAG_5f	EQU		$5f
T128_1BITFLAG_60	EQU		$60
T128_1BITFLAG_61	EQU		$61
T128_1BITFLAG_62	EQU		$62
T128_1BITFLAG_63	EQU		$63
T128_1BITFLAG_64	EQU		$64
T128_1BITFLAG_65	EQU		$65
T128_1BITFLAG_66	EQU		$66
T128_1BITFLAG_67	EQU		$67
T128_1BITFLAG_68	EQU		$68
T128_1BITFLAG_69	EQU		$69
T128_1BITFLAG_6a	EQU		$6a
T128_1BITFLAG_6b	EQU		$6b
T128_1BITFLAG_6c	EQU		$6c
T128_1BITFLAG_6d	EQU		$6d
T128_1BITFLAG_6e	EQU		$6e
T128_1BITFLAG_6f	EQU		$6f
T128_1BITFLAG_70	EQU		$70
T128_1BITFLAG_71	EQU		$71
T128_1BITFLAG_72	EQU		$72
T128_1BITFLAG_73	EQU		$73
T128_1BITFLAG_74	EQU		$74
T128_1BITFLAG_75	EQU		$75
T128_1BITFLAG_76	EQU		$76
T128_1BITFLAG_77	EQU		$77
T128_1BITFLAG_78	EQU		$78
T128_1BITFLAG_79	EQU		$79
T128_1BITFLAG_7a	EQU		$7a
T128_1BITFLAG_7b	EQU		$7b
T128_1BITFLAG_7c	EQU		$7c
T128_1BITFLAG_7d	EQU		$7d
T128_1BITFLAG_7e	EQU		$7e
T128_1BITFLAG_7f	EQU		$7f
T128_1BITFLAG_80	EQU		$80
T128_1BITFLAG_81	EQU		$81
T128_1BITFLAG_82	EQU		$82
T128_1BITFLAG_83	EQU		$83
T128_1BITFLAG_84	EQU		$84
T128_1BITFLAG_85	EQU		$85
T128_1BITFLAG_86	EQU		$86
T128_1BITFLAG_87	EQU		$87
T128_1BITFLAG_88	EQU		$88
T128_1BITFLAG_89	EQU		$89
T128_1BITFLAG_8a	EQU		$8a
T128_1BITFLAG_8b	EQU		$8b
T128_1BITFLAG_8c	EQU		$8c
T128_1BITFLAG_8d	EQU		$8d
T128_1BITFLAG_8e	EQU		$8e
T128_1BITFLAG_8f	EQU		$8f
T128_1BITFLAG_90	EQU		$90
T128_1BITFLAG_91	EQU		$91
T128_1BITFLAG_92	EQU		$92
T128_1BITFLAG_93	EQU		$93
T128_1BITFLAG_94	EQU		$94
T128_1BITFLAG_95	EQU		$95
T128_1BITFLAG_96	EQU		$96
T128_1BITFLAG_97	EQU		$97
T128_1BITFLAG_98	EQU		$98
T128_1BITFLAG_99	EQU		$99
T128_1BITFLAG_9a	EQU		$9a
T128_1BITFLAG_9b	EQU		$9b
T128_1BITFLAG_9c	EQU		$9c
T128_1BITFLAG_9d	EQU		$9d
T128_1BITFLAG_9e	EQU		$9e
T128_1BITFLAG_9f	EQU		$9f
T128_1BITFLAG_a0	EQU		$a0
T128_1BITFLAG_a1	EQU		$a1
T128_1BITFLAG_a2	EQU		$a2
T128_1BITFLAG_a3	EQU		$a3
T128_1BITFLAG_a4	EQU		$a4
T128_1BITFLAG_a5	EQU		$a5
T128_1BITFLAG_a6	EQU		$a6
T128_1BITFLAG_a7	EQU		$a7
T128_1BITFLAG_a8	EQU		$a8
T128_1BITFLAG_a9	EQU		$a9
T128_1BITFLAG_aa	EQU		$aa
T128_1BITFLAG_ab	EQU		$ab
T128_1BITFLAG_ac	EQU		$ac
T128_1BITFLAG_ad	EQU		$ad
T128_1BITFLAG_ae	EQU		$ae
T128_1BITFLAG_af	EQU		$af
T128_1BITFLAG_b0	EQU		$b0
T128_1BITFLAG_b1	EQU		$b1
T128_1BITFLAG_b2	EQU		$b2
T128_1BITFLAG_b3	EQU		$b3
T128_1BITFLAG_b4	EQU		$b4
T128_1BITFLAG_b5	EQU		$b5
T128_1BITFLAG_b6	EQU		$b6
T128_1BITFLAG_b7	EQU		$b7
T128_1BITFLAG_b8	EQU		$b8
T128_1BITFLAG_b9	EQU		$b9
T128_1BITFLAG_ba	EQU		$ba
T128_1BITFLAG_bb	EQU		$bb
T128_1BITFLAG_bc	EQU		$bc
T128_1BITFLAG_bd	EQU		$bd
T128_1BITFLAG_be	EQU		$be
T128_1BITFLAG_bf	EQU		$bf
T128_1BITFLAG_c0	EQU		$c0
T128_1BITFLAG_c1	EQU		$c1
T128_1BITFLAG_c2	EQU		$c2
T128_1BITFLAG_c3	EQU		$c3
T128_1BITFLAG_c4	EQU		$c4
T128_1BITFLAG_c5	EQU		$c5
T128_1BITFLAG_c6	EQU		$c6
T128_1BITFLAG_c7	EQU		$c7
T128_1BITFLAG_c8	EQU		$c8
T128_1BITFLAG_c9	EQU		$c9
T128_1BITFLAG_ca	EQU		$ca
T128_1BITFLAG_cb	EQU		$cb
T128_1BITFLAG_cc	EQU		$cc
T128_1BITFLAG_cd	EQU		$cd
T128_1BITFLAG_ce	EQU		$ce
T128_1BITFLAG_cf	EQU		$cf
T128_1BITFLAG_d0	EQU		$d0
T128_1BITFLAG_d1	EQU		$d1
T128_1BITFLAG_d2	EQU		$d2
T128_1BITFLAG_d3	EQU		$d3
T128_1BITFLAG_d4	EQU		$d4
T128_1BITFLAG_d5	EQU		$d5
T128_1BITFLAG_d6	EQU		$d6
T128_1BITFLAG_d7	EQU		$d7
T128_1BITFLAG_d8	EQU		$d8
T128_1BITFLAG_d9	EQU		$d9
T128_1BITFLAG_da	EQU		$da
T128_1BITFLAG_db	EQU		$db
T128_1BITFLAG_dc	EQU		$dc
T128_1BITFLAG_dd	EQU		$dd
T128_1BITFLAG_de	EQU		$de
T128_1BITFLAG_df	EQU		$df
T128_1BITFLAG_e0	EQU		$e0
T128_1BITFLAG_e1	EQU		$e1
T128_1BITFLAG_e2	EQU		$e2
T128_1BITFLAG_e3	EQU		$e3
T128_1BITFLAG_e4	EQU		$e4
T128_1BITFLAG_e5	EQU		$e5
T128_1BITFLAG_e6	EQU		$e6
T128_1BITFLAG_e7	EQU		$e7
T128_1BITFLAG_e8	EQU		$e8
T128_1BITFLAG_e9	EQU		$e9
T128_1BITFLAG_ea	EQU		$ea
T128_1BITFLAG_eb	EQU		$eb
T128_1BITFLAG_ec	EQU		$ec
T128_1BITFLAG_ed	EQU		$ed
T128_1BITFLAG_ee	EQU		$ee
T128_1BITFLAG_ef	EQU		$ef
T128_1BITFLAG_f0	EQU		$f0
T128_1BITFLAG_f1	EQU		$f1
T128_1BITFLAG_f2	EQU		$f2
T128_1BITFLAG_f3	EQU		$f3
T128_1BITFLAG_f4	EQU		$f4
T128_1BITFLAG_f5	EQU		$f5
T128_1BITFLAG_f6	EQU		$f6
T128_1BITFLAG_f7	EQU		$f7
T128_1BITFLAG_f8	EQU		$f8
T128_1BITFLAG_f9	EQU		$f9
T128_1BITFLAG_fa	EQU		$fa
T128_1BITFLAG_fb	EQU		$fb
T128_1BITFLAG_fc	EQU		$fc
T128_1BITFLAG_fd	EQU		$fd
T128_1BITFLAG_fe	EQU		$fe
T128_1BITFLAG_ff	EQU		$ff