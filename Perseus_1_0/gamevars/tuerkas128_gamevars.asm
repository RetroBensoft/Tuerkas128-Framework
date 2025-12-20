;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; G A M E V A R S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Game variables
; 
; Use M_GAME_VAR to define a GameVar
;
; The number of GameVars must be set in tuerkas128_constants.asm: constant T128_GAMEVARS
; The number of GameVars rendered on the scoreboard must be set in tuerkas128_constants.asm: constant T128_GAMEVARSSCRBRD
; GameVars displayed on scoreboard must be the first T128_GAMEVARSSCRBRD Gamevars
;
; MGV_DEFAULT	= Initial value
; MGV_TYPE		= Type of GameVar. It is used to call the appropriate GameVar Rendering Routine
; MGV_X			= Horizontal position on scoreboard
; MGV_Y			= Vertical position on scoreboard
; MGV_COLS		= Width on scoreboard (in columns)
; MGV_ROWS		= Height on scoreboard (in rows)
; MGV_TIMER		= Associated timer ($ff if none)
; MGV_DISPLAY	= Address of the associated decimal display ($0000 if none)
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_GameVar00:		M_GAME_VAR 0  , T128_SB_ICON , 6 , 0, 2, 2, $00, $0000				; Invisibility 0=Off 255=On	(initial 0)
T128_GameVar01:		M_GAME_VAR 0  , T128_SB_ICON , 12, 0, 2, 2, $01, $0000				; Speed up 0=Off 255=On 	(initial 0)
T128_GameVar02:		M_GAME_VAR 0  , T128_SB_ICON , 26, 0, 1, 2, $ff, $0000				; Keyword 1 0=Off 255=On 	(initial 0)
T128_GameVar03:		M_GAME_VAR 0  , T128_SB_ICON , 27, 0, 1, 2, $ff, $0000				; Keyword 2 0=Off 255=On 	(initial 0)
T128_GameVar04:		M_GAME_VAR 0  , T128_SB_ICON , 28, 0, 1, 2, $ff, $0000				; Keyword 3 0=Off 255=On	(initial 0)
T128_GameVar05:		M_GAME_VAR 0  , T128_SB_ICON , 29, 0, 1, 2, $ff, $0000				; Keyword 4 0=Off 255=On	(initial 0)
T128_GameVar06:		M_GAME_VAR 0  , T128_SB_ICON , 30, 0, 1, 2, $ff, $0000				; Keyword 5 0=Off 255=On	(initial 0)
T128_GameVar07:		M_GAME_VAR 0  , T128_SB_ICON , 31, 0, 1, 2, $ff, $0000				; Keyword 6 0=Off 255=On 	(initial 0)
T128_GameVar08:		M_GAME_VAR 32 , T128_SB_BAR  , 2 , 0, 4, 1, $ff, $0000				; Energy 0-32				(initial 32)
T128_GameVar09:		M_GAME_VAR 0  , T128_SB_BAR  , 8 , 0, 4, 1, $ff, $0000				; Invisivility timer 0-32	(initial 0)
T128_GameVar10:		M_GAME_VAR 0  , T128_SB_BAR  , 14, 0, 4, 1, $ff, $0000				; Speed timer 0-32			(initial 0)
T128_GameVar11:		M_GAME_VAR 0  , T128_SB_DIGIT, 19, 0, 2, 1, $ff, T128_Display00		; Knives					(initial 0)
T128_GameVar12:		M_GAME_VAR 0  , T128_SB_DIGIT, 22, 0, 3, 1, $ff, T128_Display01		; Coins						(initial 0)	
T128_GameVar13:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000				; # of activated keywords 	(initial 0)
T128_GameVar14:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000	
T128_GameVar15:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000	
T128_GameVar16:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000	
T128_GameVar17:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000	
T128_GameVar18:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000	
T128_GameVar19:		M_GAME_VAR 0  , 0            , 0 , 0, 1, 1, $ff, $0000	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Timers
; 
; Use M_TIMER to define a Timer
;
; The number of Timers must be set in tuerkas128_constants.asm using the constant T128_TIMERS
; 
; When the GameVar defined in MT_TRIGGER_GV is set to a value different from 0, then MT_TIMER_GV is initialized with the value MT_TIMER_GV_VALUE
; From that moment on, MT_TIMER_GV is decremented every MT_SPEED GameLoops.
; For instance, if the GameLoop runs at 25 fps (T128_FPS=2) then MT_SPEED can be set to 25 to decrement MT_TIMER_GV at a rate of one unit per second.
; In this version of Tukeras128 Framewaork, if MT_TIMER_GV has an associated digital display it is ignored
; When MT_TIMER_GV reaches 0, then GameVar defined in MT_TRIGGER_GV is set to 0
;
; MT_SPEED			= number of Game Loops before decrementing Timer GameVar
; MT_TRIGGER_GV		= Trigger GameVar (address)
; MT_TIMER_GV		= Timer GameVar (Address). 
; MT_TIMER_GV_VALUE	= Timer GameVar initial value
; MT_FX_NUMBER		= Number of FX to be produced when timer reaches 0. $ff if no FX is to be produced
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_Timers:		M_TIMER 25, T128_GameVar00, T128_GameVar09, 32, T128_AY_FX_TIMEROFF	; Timer 00: Invisibility
					M_TIMER 25, T128_GameVar01, T128_GameVar10, 32, T128_AY_FX_TIMEROFF	; Timer 01: Speed up


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Decimal displays associated to GameVars
;
; A decimal display is defined by:
;   - Number of digits
;   - Value
;   - Default value
;
; If all digits of a decimal display are equal to 0, then the default value of the associated Gamevar must be 0
; Otherwise, the default value of the associated Gamevar must be non equal to 0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_Display00:		defb	2							; Number of digits		KNIVES
					defb	0, 0						; Value
					defb	0, 0						; Default value
T128_Display01:		defb	3							; Number of digits		COINS
					defb	0, 0, 0                     ; Value
					defb	0, 0, 0				        ; Default value