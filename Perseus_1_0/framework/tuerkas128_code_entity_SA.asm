;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S C R E E N   A R E A S   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_ENTITY_SA
_BEGIN_CODE_ENTITY_SA

PUBLIC T128_SA_CheckB0, T128_SA_CreateB0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SA_CreateB0
;
; Create an entry in T128_ScreenAreas for current Screen Area:
;
; SCREEN AREA (4 bytes)
;	X MIN 	[byte]
; 	X MAX 	[byte]
; 	Y MIN 	[byte]
; 	Y MAX 	[byte]
;
; Input:
;   ix = Address of screen entity data
;

T128_SA_CreateB0:	ld		a, (T128_ScreenAreasNum)
					cp		T128_SCREEN_MAX_AREAS		; Check max number of Screen Areas
					ret		z
					inc		a
					ld		(T128_ScreenAreasNum), a
					dec		a
					add		a, a
					add		a, a						; a = a * 4
					ld		c, a
					ld		b, 0
					ld		hl, T128_ScreenAreas
					add		hl, bc
					ld		a, (ix)						; X MIN
					ld		(hl), a
					inc		hl
					ld		a, (ix+1)					; X MAX
					ld		(hl), a
					inc		hl
					ld		a, (ix+2)					; Y MIN
					ld		(hl), a
					inc		hl
					ld		a, (ix+3)					; Y MAX
					ld		(hl), a
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SA_CheckB0
;
; Check if a sprite is inside a back-lighted or a normal-lighted area
;
; Input:
;   ix = sprite address
;   (T128_ScreenInfo) = %LFFFFFFF
;             L       = 1 for back-lighted screens  /  0 for normal-lighted screens
;             FFFFFFF = Free (not used yet)
; Output:
;   a = not 0 for back-lighted screens  /  0 for normal-lighted screens
;
					
T128_SA_CheckB0:	ld		a, (T128_ScreenInfo)
					and		T128_SCREEN_BACKLIGHT
					ld		c, a
					ld		a, (T128_ScreenAreasNum)
					or		a
					jr		z, SAC_Label_05				; There's no screen areas
					ld		b, a
					ld		hl, T128_ScreenAreas
SAC_Loop_01:		ld		a, (hl)
					ld		d, (ix+5)
					inc		d
					cp		d
					jr		nc, SAC_Label_01
					inc		hl
					ld		a, (hl)
					cp		d
					jr		c, SAC_Label_02
					inc		hl
					ld		a, (hl)
					ld		d, (ix+7)
					inc		d
					cp		d
					jr		nc, SAC_Label_03
					inc		hl
					ld		a, (hl)
					cp		d
					jr		c, SAC_Label_04
					ld		a, T128_SCREEN_BACKLIGHT	; Screen areas found
					jr		SAC_Label_05
SAC_Label_01:		inc		hl
SAC_Label_02:		inc		hl
SAC_Label_03:		inc		hl
SAC_Label_04:		inc		hl
					djnz	SAC_Loop_01
					xor		a							; Screen areas not found
SAC_Label_05:		xor		c
					ret