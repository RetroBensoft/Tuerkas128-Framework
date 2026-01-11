;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S C R E E N   R E N D E R I N G 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _BEGIN_CODE_RENDER_SCREEN
_BEGIN_CODE_RENDER_SCREEN:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ScreenRender
;
; Set up current screen data and render
;
; Input:
;   l = screen number
;
T128_ScreenRender:	ld		a, l
					ld		(T128_ScreenCurrent), a
					push	hl
					xor		a
					ld		(T128_ScreenPortalsNum), a	; Delete screen portals
					ld		(T128_ScreenAreasNum), a	; Delete screen areas
					ld		(T128_ScreenBreathsNum), a	; Delete breath areas
					ld		(T128_ScreenAnimBlkNum), a	; Delete animated blocks
					ld		(T128_ScreenSpritesNum), a	; Delete sprites
					ld		(T128_ScreenSprPoolNum), a	; Delete sprite pool
					ld		(T128_ScreenSprGaps), a		; Delete sprite gaps
					ld		(T128_ScreenSprLast), a		; Delete last free sprite
					ld		hl, T128_ScreenSprites
					ld		(T128_ScreenSprLastPtr), hl	; Init T128_ScreenSprLastPtr
					ld		hl, T128_GraphicPoolABPtr
					ld		(hl), a
					ld		de, T128_GraphicPoolABPtr+1
					ld		bc, T128_ANIMBLK_LAST*2+1
					ldir								; Delete animated block pointers
					ld		hl, T128_GraphicPoolSPRPtr
					ld		(hl), a
					ld		de, T128_GraphicPoolSPRPtr+1
					ld		bc, T128_SPRITE_LAST*2+1
					ldir								; Delete sprite pointers
					ld		hl, T128_GraphicPoolNext
					ld		de, T128_GraphicPool
					ld		(hl), e
					inc		hl
					ld		(hl), d						; Init Graphic Pool next pointer
					ld		a, (T128_LastValue7ffd)
					and		%00001000
					jr		nz, SDS_Label_01			; RAM 7 screen is already visible
					call	T128_TrRAM5ToRAM7			; Copy RAM 5 to RAM 7
;					halt								; [NOTE] Flickering is not remarkable, so this instruction
														; can be bypassed and the new screen is rendered faster
					call	T128_SetRAM7Screen			; Set visible RAM 7 screen
SDS_Label_01:		pop		hl
					call	T128_TrScreenData			; Load screen data on bank 2
					xor		a
					call	T128_SetBank				; Set RAM 0
					ld		ix, T128_ScreenDataRAM2		; Screen data address
					ld		hl, T128_SDRAM2_End1		; Ending address of screen data
					call	T128_ScrDraw				; Render screen on RAM 5
					ld		hl, T128_SDRAM2_End2		; Ending address of screen entities data
					call	T128_ScrEntities			; Setup screen entities
					call	T128_RenderAniBlcks			; Animated blocks must be rendered here because they are part of the screen
;					halt								; [NOTE] Flickering is not remarkable, so this instruction
														; can be bypassed and the new screen is rendered faster
					call	T128_SetRAM5Screen			; Set visible RAM 5 screen
					call	FSM_WHENNEWSCREEN_B0		; Call Main Chars' WHENNEWSCREEN routine
					jp		T128_TrRAM5ToRAM7			; Copy RAM 5 to RAM 7


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ScreenLimits
;
; Check screen limits
; Bank 0 must be selected befor calling this function
;
; It is assumed that Main Char's even states are LEFT states and Main Char's odd states are RIGHT states
; It is assumed that Main Char can move out of the left border of the screen ONLY when it is in a LEFT state and
; Main Char can move out of the right border of the screen ONLY when it is in a RIGHT state
; These could be some strict constraints for certain type of games. To avoid these constraints, checking screen limits could be
; done in FSM_MainCharB0. Or T128_ScreenLimits should be adapted ad-hoc (for instance using a global variable set to 0 for
; LEFT states and set to 1 for RIGHT states). Or an extra parameter could be added to M_FSM_PARAM (for instance check LEFT/RIGTH limit)
; Another solution could be checking rotation bit; this could be done by using ld (ix+2) instead of (ix+13)
;
; Input:
; 	ix = main character sprite address
;

T128_ScreenLimits: 	bit		6, (ix+SPR_PARAM.FLAGS)		; If Main char sprite is inactive, then no need to check screen limits; this avoids
					ret		z							; bug reported by Thealfest if Main Char is killed when moving to another screen
;
					ld		a, (ix+13)
					and		%00000001
					jr		nz, CL_Label_02				; If RIGHT state, then no need to check left border
					ld		a, (ix+10)
					rrca
					rrca
					rrca
					and		%00011111
					cp		(ix+9)
					ld		a, (ix+5)
					jr		nz, CL_Label_01
					dec		a
;					
CL_Label_01:		cp		T128_MIN_X-1				; Check left border
					jr		nz, CL_Label_02
					ld		a, T128_MAX_X*8
					ld		(ix+6), a
					ld		a, (T128_ScreenLeft)
					jr		CL_Label_05
CL_Label_02:		ld		a, (ix+13)
					and		%00000001
					jr		z, CL_Label_03				; If LEFT state, then no need to check right border
					ld		a, (ix+5)					
;					
					cp		T128_MAX_X					; Check right border
					jr		nz, CL_Label_03
					ld		a, T128_MIN_X*8
					ld		(ix+6), a
					ld		a, (T128_ScreenRight)
					jr		CL_Label_05
;					
CL_Label_03:		ld		a, (ix+7)
					cp		T128_MIN_Y-1				; Check top border
					jr		nz, CL_Label_04
					ld		a, (ix+8)
					add		a, (T128_MAX_Y-T128_MIN_Y)*8
					ld		(ix+8), a
					ld		a, (T128_ScreenUp)
					jr		CL_Label_05
;					
CL_Label_04:		cp		T128_MAX_Y					; Check bottom border
					ret		nz
					ld		a, (ix+8)
					sub		 (T128_MAX_Y-T128_MIN_Y)*8
					ld		(ix+8), a
					ld		a, (T128_ScreenDown)
;					
; New screen
;
CL_Label_05:		push	af
					call	FSM_MainCharXAnchorB0		; c = T128_SPR_X_ON / T128_SPR_X_OFF
					call	T128_SPR_XB0				; X correction for Main char
					call	T128_SPR_YB0				; Y correction for Main char
;
; Render new screen. CL_NewScreen is invoked also from PORTAL's processing routine (T128_PRTL_FSMB0)
; 					
CL_NewScreen:		call	T128_TrEntityInfo			; Update Entity Info in Bank BF2
					pop		af
					ld		l, a
					call	T128_ScreenRender			; Render new screen
;					
					pop		hl							; Delete returning point from the top of the stack
					ld		hl, GameLoopClose			; Set returning point at the top of the stack
					push	hl
					jp		T128_InitSpriteVars			; Init Sprite Vars to reset rendering algorithm