;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P E R S E U S 
;
; RAM 2
;
; - Memory management
; - General rendering routines
; - Render screens
; - Redender sprites
; - Interrupt management
; - Screen processing
; - Input routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org	$8005												; Memory bank 2
														; First 5 bytes are reserved for hardware detection variables

PUBLIC _BEGIN_BK2_CODE_2, _END_BK2_CODE_2
PUBLIC _END_BK2_CODE
PUBLIC _END_BK2											; _END_BK2 must be lower than $beff


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S Y M B O L S ,   C O N S T A N T S   A N D   M A C R O S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\bank_0.sym"									; Symbols for RAM 0
include ".\bank_5.sym"									; Symbols for RAM 5
include ".\bank_7.sym"									; Symbols for RAM 7
include ".\bank_S1.sym"									; Symbols for Slow RAM number 2
include ".\bank_S2.sym"									; Symbols for Slow RAM number 2
include ".\bank_F1.sym"									; Symbols for Fast RAM number 1
include ".\bank_F2.sym"									; Symbols for Fast RAM number 2
;include ".\framework\tuerkas128_constants.asm"			; Framework constants are loaded at the end of the file, in the RAM 2 DATA section
include ".\framework\tuerkas128_global.asm"				; Global code control


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M A I N   C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:				di
					ld		hl, T128_ISR
					ld		($beff), hl					; Save at ($beff) T128_ISR routine address
					ld		a, $be						; to handle interrupts 50 times per second
					ld		i, a
					im		2							; Set up interruption mode 2
					ei
;
; Set up dynamic links
;
					call	T128_DynamicLinks			; Slow Bank RAM 1 is set in T128_DynamicLinks
;
; INTRO / MENU
;
					call	KeyPressedWait
					jp		T128_IntroBS1		


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Game setup. The game starts here
;			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GameSetup:						

;
; Select bitmap for Mainchar [AD HOC]
;					
					ld		hl, T128_PerseusBitmap
					call	T128_TrBitmap				; Bank 7 is set in T128_TrBitmap
;
; Setup variables for sprite rendering algorithm
;					
					call	T128_InitSpriteVars			; Bank 0 is set in T128_InitSpriteVars
;
; Setup Main Char
;					
					xor		a
					ld		(T128_ProcessDeath), a		; Mainchar is not dead
					call	FSM_INITMAINCHAR_B0
;
; Setup sound
;
					ld		a, T128_AY_CTRL_ENDFX
					ld		(T128_AY_FXAction), a		; Stop FX and
					halt								; wait for next AY Player
					ld		a, (T128_FastBank1)			
					call	T128_SetBank	
					ld		a, T128_AY_MUSIC_INGAME		; Song number
					call	T128_AY_InitSongBF1			; Init song
					ld		a, (T128_GameFXMusic)		; T128_GameFXMusic is tipically set from menu
					ld		(T128_AY_Control), a		; Set up sound for game
;
; Reset Entities' activity flag, set T128_Check_Portal, reset 1bitFlags and set GameVars initial value
;
					ld		a, (T128_FastBank2)
					call	T128_SetBank		
					call	T128_ResetActivBF2
					xor		a
					call	T128_SetBank
					ld		a, 1
					ld		(T128_CheckPortal), a
					call	T128_Set1bitFlagsB0
					call	T128_SetGameVarsB0
;
; Render first screen 
;					
					ld		l, T128_FIRST_SCREEN		; Screen number
					call	T128_ScreenRender
					xor		a
					call	T128_SetBank
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Game loop BEGIN (Before reaching this point, Bank 0 must be selected)
;			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GameLoop:
;
; Spawn sprites
;
					call	T128_SPR_SpawnB0			
;
; Set up sprite rendering algortihm
;
					call	T128_ClearSpritesAttr		; Clear sprites attribute of current frame in hidden screen
					call	T128_ClearSprites			; Clear sprites of current frame in hidden screen
					call	T128_RenderSMC				; Set up Self Modifying Code in sprite rendering routines
;
; Render all (animated blocks & sprites & main char)
;
					call	T128_RenderAll
;
; Do the "no-flickering" magic
; 					
					call	T128_SychroFPS				; Synchronize frame rate
					call	T128_ToggleScreen			; Show frame
;
; Check if Main Char's death must be processed 
;
					ld		a, (T128_ProcessDeath)
					or		a
					jr		nz, MainCharIsKilled
;
; Enter into the RAM 0 code
;					
					xor		a
					call	T128_SetBank
;
; Is this THE END?
;
					call	IsThisTheEnd				; In some cases, Bank 7 is set in T128_TrBitmap
				
;
; Keyboard & joystick
;					
					call 	T128_KeyJoystick			; Read keayboard/joystick
					call	T128_KeyPauseQuit			; Check Pause/Quit keys
;
; Process Portals FSM
; It must be done right after Keyboard & joystick processing and before Main Char FSM
; in order to avoid jamming with Main Char's fire processing, specialy when source
; and destination portals are on the same screen
;					
					call	T128_PRTL_FSMB0				
					
;
; Main Char's Finite State Machine
;
					call	FSM_MainCharB0				; Process Main Char FSM
					call	T128_ScreenLimits			; Check screen boundaries		
;
; Entities Finite State Machines
;
					call	T128_SPR_FSMB0				; Process Sprites FSM	
					call	T128_AB_FSMB0				; Process Animated Blocks FSM
					call	T128_BA_FSMB0				; Process Breath Areas FSM
;
; Update Timers
;
GameLoopClose:		call	T128_UpdateTimersB0
;
; Update Scoreboard
;
					call	T128_UpdateScrBrdB0
;					
; Increment number of game loops
;
					ld		hl, T128_GameLoops
					inc 	(hl)						; Close game loop
					jr		GameLoop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Game loop END
;			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Process death by jumping to (hl)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainCharIsKilled:	ld		hl, T128_GameOverBS1		; Run GAME OVER code in bank BS1
FinishGame:			ld		a, (T128_LastValue7ffd)
					and		%00001000
					jr		z, MCIK_Label_01			; RAM 5 screen is already visible
					push	hl
					call	T128_TrRAM7ToRAM5			; Copy RAM 7 to RAM 5
					pop		hl
					call	T128_SetRAM5Screen			; Set visible RAM 5 screen
MCIK_Label_01:		ld		a, (T128_SlowBank1)
					call	T128_SetBank
					jp		(hl)						; Jump
					


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Process THE END  [AD HOC]
;
; 1bitflag used:
;
;   * T128_1BITFLAG_fe = Perseus got 6 pieces of parchment
;   * T128_1BITFLAG_fd = Perseus is sacrified
;   * T128_1BITFLAG_fc = Perseus has turned into Medusa, right after he is sacrified
;   * T128_1BITFLAG_fb = Perseus touches (kills) Medusa ==> END OF GAME (1)
;   * T128_1BITFLAG_fa = Medusa touches (kills) Polydectes ==> END OF GAME (2)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IsThisTheEnd:		; TURN PERSEUS INTO MEDUSA
					ld		a, T128_1BITFLAG_fd
					call	T128_Check1bFlagB0			
					jr		z, ITTE_Label_01
					ld		a, T128_1BITFLAG_fc
					call	T128_Check1bFlagB0			; hl = T128_1BITFLAG_fc address   b = set N, (hl)
					jr		nz, ITTE_Label_01
					ld		a, b
					ld		(ITTE_SMC_01+1), a
ITTE_SMC_01:		set		0, (hl)						; Set 1 bitFlag number T128_1BITFLAG_fc (lock)
					ld		hl, T128_MedusaBitmap
					call	T128_TrBitmap				; Bank 7 is set in T128_TrBitmap
					xor		a
					jp		T128_SetBank
					; MEDUSA IS DEAD
ITTE_Label_01:		ld		a, T128_1BITFLAG_fb
					call	T128_Check1bFlagB0			; hl = T128_1BITFLAG_fb address   b = set N, a
					jr		z, ITTE_Label_02
					pop		hl							; clear stack
					ld		hl, T128_TheEnd1BS1			; Run THE END 1 code in bank BS1
					jr		FinishGame
					; POLYDECTES IS DEAD
ITTE_Label_02:		ld		a, T128_1BITFLAG_fa
					call	T128_Check1bFlagB0			; hl = T128_1BITFLAG_fb address   b = set N, a
					ret		z
					pop		hl							; clear stack
					ld		hl, T128_TheEnd1BS2			; Run THE END 2 code in bank BS1
					jr		FinishGame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\tuerkas128_code_input.asm"			; Keyboard & joystick routines  
include ".\framework\tuerkas128_code_interrupt.asm"		; Interupt service
include ".\framework\tuerkas128_code_memory.asm"		; Banks and memory management
include ".\framework\tuerkas128_code_render.asm"		; General rendering routines
include ".\framework\tuerkas128_code_render_screen.asm"	; Screen rendering
include ".\framework\tuerkas128_code_render_sprite.asm"	; Sprite rendering
include ".\framework\tuerkas128_code_screen.asm"		; Screen processing

_END_BK2_CODE:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; R A M   2   D A T A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\bank_2_data.asm"							; Data

end	Main