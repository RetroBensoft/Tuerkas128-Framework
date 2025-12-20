;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 1   B I T   F L A G S   &   G A M E   V A R S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _BEGIN_FLAGS_GAMEVARS
_BEGIN_FLAGS_GAMEVARS

PUBLIC T128_1bitFlags

PUBLIC T128_GameVar00, T128_GameVar01, T128_GameVar02, T128_GameVar03, T128_GameVar04
PUBLIC T128_GameVar05, T128_GameVar06, T128_GameVar07, T128_GameVar08, T128_GameVar09 
PUBLIC T128_GameVar10, T128_GameVar11, T128_GameVar12, T128_GameVar13, T128_GameVar14
PUBLIC T128_GameVar15, T128_GameVar16, T128_GameVar17, T128_GameVar18, T128_GameVar19 

PUBLIC T128_Timers


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 256 1-bit flags
;
; Format: BBBBBFFF
;   BBBBB = Byte number (0-31)
;   FFF   = 1-bit flag number within BBBBB
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_1bitFlags:		defs	32


include ".\gamevars\tuerkas128_gamevars.asm"				; Game variables
					

PUBLIC _END_FLAGS_GAMEVARS
_END_FLAGS_GAMEVARS
