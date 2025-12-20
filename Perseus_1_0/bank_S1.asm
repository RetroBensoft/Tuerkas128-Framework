;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; P E R S E U S 
;
; RAM SlowBank1
;
; - Intro
; - Menu
; - Game over
; - End of Game
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org $c000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O N S T A N T S   A N D   M A C R O S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\tuerkas128_constants.asm"			; Framework constants
include ".\framework\tuerkas128_global.asm"				; Global code control
include ".\bank_2_data.sym"								; Symbols for RAM 2 variables


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; D A T A
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\intro_menu\tuerkas128_data_strips.asm"		; Intro strips
include ".\intro_menu\tuerkas128_data_intro_title.asm"	; Intro title
include ".\intro_menu\tuerkas128_data_SB.asm"			; Scoreboard
include ".\intro_menu\tuerkas128_data_notAI.asm"		; Written by human, not AI (message in menu)
include ".\intro_menu\tuerkas128_data_RB2025.asm"		; RetroBensoft 2025 (message in menu)
include ".\intro_menu\tuerkas128_data_tuerkas.asm"		; Tuerkas simple sprite


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\AY\tuerkas128_AY_interfaceBS1.asm"	; Interface for music & FX with Bank Slow 1
include ".\intro_menu\tuerkas128_code_intro.asm"		; Intro code
include ".\intro_menu\tuerkas128_code_text.asm"			; Text functions
include ".\intro_menu\tuerkas128_code_menu.asm"			; Menu functions


PUBLIC _END_BS1
_END_BS1:
