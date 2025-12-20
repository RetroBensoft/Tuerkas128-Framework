;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P E R S E U S 
;
; RAM FastBank2
;
; - Game Map
; - Code: Reset entities' inactivity bit in game map
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org $c000

PUBLIC	T128_ResetActivBF2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S Y M B O L S ,   C O N S T A N T S   A N D   M A C R O S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\tuerkas128_constants.asm"			; Framework constants
include ".\framework\tuerkas128_macros.asm"				; Framework macros
include ".\bank_5.sym"									; Symbols for RAM 5 variables


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; D A T A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\screens\tuerkas128_scr_map.asm"				; Screen data. Main map


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_BF2_CODE, _END_BF2_CODE

_BEGIN_BF2_CODE:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ResetActivBF2
;
; Reset activity bit in every entity of every screen
;
T128_ResetActivBF2:	ld		de, (T128_ScrEntPtrs_BF2)	; de = entity address of first screen
					exx
					ld		hl, T128_ScrEntPtrs_BF2+2	; Next screen pointer to entity address
					exx
					ld		hl, T128_ScrPtrs_BF2+2		; Next screen pointer to screen definition
;					
RA_Loop_01:			ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = end of current screen entities
					inc		hl
					push	hl
					ld		hl, ScreenEnd
					ld		a, l
					cp		e
					jr		nz, RA_Label_01
					ld		a, h
					cp		d
					jr		z, RA_Label_04				; If last screen, then finish
RA_Label_01:		ex		de, hl
;
RA_Loop_02:			ld		a, l
					cp		c
					jr		nz, RA_Label_02
					ld		a, h
					cp		b
					jr		z, RA_Label_03				; If end of current screen entities is reached, then next screen
RA_Label_02:		res		7, (hl)						; Reset activity bit of current entity
					ld		de, 6
					add		hl, de
					jr		RA_Loop_02					; Next entity
;				
RA_Label_03:		pop		hl
RA_SMC_01:			exx
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = entity address of next screen
					inc		hl
					push	de
					exx	
					pop		de
					jr		RA_Loop_01
;
RA_Label_04:		pop		hl
					ret
					
_END_BF2_CODE:					