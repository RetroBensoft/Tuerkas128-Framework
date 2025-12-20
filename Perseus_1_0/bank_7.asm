;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P E R S E U S 
;
; RAM 7
;
; - Perseus sprites
; - Medusa sprites
; - RAM 7 multi-purpose buffer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC T128_RAM7_Buffer
PUBLIC T128_PerseusBitmap, T128_MedusaBitmap


org $db00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O N S T A N T S   A N D   M A C R O S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\tuerkas128_constants.asm"			; Engine constants
include ".\framework\tuerkas128_macros.asm"				; Engine macros


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; D A T A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


T128_RAM7_Buffer:	defs	768							; Attribute buffer

T128_PerseusBitmap:										; Bitmap for Perseus (except SLIDE)
include ".\graphics\MAINCHAR\tuerkas128_spr_PERSEUS.asm"			

T128_MedusaBitmap										; Bitmap for Perseus (except SLIDE)
include ".\graphics\MAINCHAR\tuerkas128_spr_MEDUSA.asm"			
				
