;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P O R T A L S   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					

PUBLIC _BEGIN_CODE_ENTITY_PRTL
_BEGIN_CODE_ENTITY_PRTL

PUBLIC T128_PRTL_CreateB0, T128_PRTL_FSMB0

PUBLIC PF_SMC_01_B0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_PRTL_CreateB0
;
; Create an entry in T128_ScreenPortals for current Portal:
;
; PORTAL (7 bytes)
;   NEW_SCREEN	[byte]	New screen
;	X MIN 		[byte]
; 	X MAX 		[byte]
; 	Y MIN 		[byte]
; 	Y MAX 		[byte]
;   NEW_X	 	[byte]	Horitontal position in new screen (0-31)
;   NEW_Y	 	[byte]	Vertical position in new screen (0-23)													
;
; Input:
;   ix = Address of screen entity data
;

T128_PRTL_CreateB0:	ld		a, (T128_ScreenPortalsNum)
					cp		T128_SCREEN_MAX_PRTL		; Check max number of Portals
					ret		z
					inc		a
					ld		(T128_ScreenPortalsNum), a
					dec		a
					ld		b, a
					add		a, a
					add		a, a
					add		a, a
					sub		b							; a = a * 7
					ld		c, a
					ld		b, 0
					ld		hl, T128_ScreenPortals
					add		hl, bc
					ld		a, (ix+4)					; NEW_SCREEN
					ld		(hl), a
					inc		hl
					ld		a, (ix)						; X MIN
					ld		b, a
					and		%00011111
					ld		(hl), a
					inc		hl
					ld		c, a
					ld		a, b
					and		%11100000
					rlca
					rlca
					rlca
					dec 	a
					add		a, c						; X MAX
					ld		(hl), a
					inc		hl
					ld		a, (ix+1)					; Y MIN
					ld		b, a
					and		%00011111					
					ld		(hl), a
					inc		hl
					ld		c, a
					ld		a, b
					and		%11100000					
					rlca
					rlca
					rlca
					dec 	a
					add		a, c						; Y MAX
					ld		(hl), a
					inc		hl
					ld		a, (ix+2)					; NEW_X
					ld		(hl), a
					inc		hl
					ld		a, (ix+3)					; NEW_Y
					ld 		(hl), a
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_PRTL_FSMB0
;
; Portals Finite State Machine
;
; If fire is pressed, and Main Char is within the Portal, then teleport Main Char to destination Portal
; Destination portal can be in the same window
;
; If Fire is pressed then
;   if T128_Check_Portal = 1 then
;     For every Portal on Screen:
;        if Main Char is within the Portal then
;           produce sound (fx number = T128_PRTL_FX)
;           do FSM_KEYPRESSED
;           change Main Char's position
;              x = x_nuevo + (x_actual-x_min)
;              y = y_nuevo + (y_actual-y_min)
;           T128_Check_Portal = 0 (fire must be released before Portal is checked again)
;           if New window != Current Window then
;              Render New Screen using standard procedure by calling CL_NewScreen in tuerkas128_code_render_screen.asm
;           end if
;           return
;        end if
;     End for
;   end if
; else
;   T128_Check_Portal = 1 (fire must be released before Portal is checked again)
; end if
;

T128_PRTL_FSMB0:	ld		a, (T128_ScreenPortalsNum)
					or		a
					ret		z							; No portals
					ld		b, a
;
; Check if fire is pressed
; 					
					ld		a, (T128_EventControl)
					and		T128_EVENT_FIRE
					jr		nz, PF_Label_01
					inc		a							; a = 1
					ld		(T128_CheckPortal), a
					ret									; fire is not pressed ==> A new Portal can be checked again
;
; Check if fire was released after last teleporting
;
PF_Label_01:		ld		a, (T128_CheckPortal)
					or		a
					ret		z							; Fire was pressed to teleport, but not released yet 
;
; Process all Portals on screen
; 
					ld		iy, T128_ScreenPortals
					ld		ix, T128_MainChar
PF_Loop_01:			push	bc

;
; Check collision
;
					call	T128_SpriteAreaCol			; NC = Collision
					jr		nc, PF_Label_02
;
; Next Portals
;
					ld		de, T128_PRTL_TABLE_SIZE
					add		iy, de						; Next portal
					pop		bc
					djnz	PF_Loop_01
					ret
;
; Process Portal
;					
PF_Label_02:		pop		bc							; Collect garbage from stack
					xor		a
					ld		(T128_CheckPortal), a		; fire must be released before Portal is checked again
					; SOUND
					ld 		a, T128_AY_FX_GATE			; FX number
					call	T128_AY_InitFXB0
					; POSITION IN DESTINATION PORTAL
					ld		a, (ix+6)					; Old x Main Char
					ld		b, (iy+1)					; x_min
					ld		c, (iy+5)					; x_new
					call	PF_Label_03
					ld		(ix+6), a					; New x Main Char = x_new + (Old x Main Char - x_min)
					ld		a, (ix+8)					; Old y Main Char
					ld		b, (iy+3)					; y_min
					ld		c, (iy+6)					; y_new
					call	PF_Label_03
					ld		(ix+8), a					; New y Main Char = y_new + (Old y Main Char - y_min)
					call	FSM_MainCharXAnchorB0		; c = T128_SPR_X_ON / T128_SPR_X_OFF
					call	T128_SPR_XB0				; X correction for Main char
					call	T128_SPR_YB0				; Y correction for Main char
					; DO FSM_KEYPRESSED
					push	iy
					call	FSM_KEYPRESSED
					pop		iy
					; NEW SCREEN = CURRENT SCREEN
					ld		a, (T128_ScreenCurrent)
					cp		(iy)
					ret		z							; If new screen = current screen, then return
					; NEW SCREEN != CURRENT SCREEN
					ld		a, (iy)						; a = new screen
					push	af							; pop af is done in CL_NewScreen
PF_SMC_01_B0:		jp		0000						; jp CL_NewScreen (in tuerkas128_code_render_screen.asm to render new screen)
;
; Calculate new x or new y for Main char
;
; Input:
;   a = Old coordinate (x or y)
;   b = Current portal coordinate (x or y)
;   c = Destination portal coordinate (x or y)
; 
PF_Label_03			ex		af, af'
					ld		a, b
					add		a, a
					add		a, a
					add		a, a
					ld		b, a
					ld		a, c
					add		a, a
					add		a, a
					add		a, a
					ld		c, a
					ex		af, af'
					sub		b
					add		a, c						
					ret