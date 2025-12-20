;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; L O A D E R 
;
; Load game blocks and jump to the game entry point
; It uses the "OVER USR 7 ($5ccb)" method to embed machine code into a BASIC program
; It is a 9-byte version using an interger value instead of the original 7-byte which uses an
; exponent/mantissa value, just for the sake of showing another point of view ;-)
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org $5ccb

PUBLIC L_Loader, LoaderEnd									; LoaderEnd - L_Loader must be less than 256


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; G L O B A L   C O N S T A N T S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\framework\tuerkas128_global.asm"					; Global constants


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RAM0_LENGTH			EQU		<Size0>							; Size of bank0.bin file 	(FSMs for game etities) [CUSTOM]
RAM2_LENGTH			EQU		<Size2>							; Size of bank2.bin file 	(game loop and rendering routines) [FRAMEWORK CORE]
RAM5_LENGTH			EQU		<Size5>							; Size of bank5.bin file 	(blocks and superblocks; gamevars) [CUSTOM]
RAM7_LENGTH			EQU		<Size7>							; Size of bank7.bin file 	(free to use)
RAMFB1_LENGTH		EQU		<SizeFB1>						; Size of bankFB1.bin file 	(sound tracker) (music & FX) [CUSTOM]
RAMFB2_LENGTH		EQU		<SizeFB2>						; Size of bankFB2.bin file 	(game map) [CUSTOM]
RAMSB1_LENGTH		EQU		<SizeSB1>						; Size of bankSB1.bin file 	(intro, menu, game over) [CUSTOM]
RAMSB2_LENGTH		EQU		<SizeSB2>						; Size of bankSB2.bin file	(bitmaps for sprites an aminated blocks) [CUSTOM]

Loader:				ld      sp, 0  
					di
					db      $de, $c0, $37, $0e, $00, $00, $cb, $5c, $00
;
; Clear screen					
;
					ld      hl, $5800
					ld      de, $5801
					ld      bc, $2ff
					ld      (hl), l
					ldir
;
; Hardware detection
;
					ld		a, %11100111
					ld		($c000), a						; Write 11100111 in bank 0
;
					ld		a, ($5b5c)					
					ld		e, a							; Save last value of port 7ffd in register e
					ld		a, ($5b67)				
					ld		d, a							; Save last value of port 1ffd in register d
;
					and		%11111000
					or		%00000011					
					ld		bc, $1ffD
					out		(c), a							; Select special paging mode (+2A/+3) RAM 4 / RAM 5 / RAM 6 / RAM 7
;
					ld		a, e
					and		%11111000
					ld      b, $7f
					out		(c), a							; Select Bank 0 (128/+2)
;
					ld		a, ($c000)						; This will read from Bank 0 in a 128/+2, or from Bank 7 in +2A/+3
					cpl										; 11100111 ==> 00011000 (128/+2) or 00000000 ==>11111111 (+2A/+3)
					ld		($c000), a						; This will write on Bank 0 in a 128/+2, or on Bank 7 in a +2A/+3
;
					ld		a, d
					ld      b, $1f					
					out		(c), a							; Reset paging
					ld		a, e
					ld      b, $7f					
					out		(c), a							; Reset paging
					ld		(T128_LastValue7ffd), a			; Save last value of port 7ffd in a variable of the framework
;
					ld		a, ($c000)						; Read test value
            		ld		hl, $0604						; Contended banks
					ld		de, $0301						; and not contended banks
					cp		%11100111						; for +2A/+3 models
					jr		z, L_Label_01
					ex		de, hl							; exchange banks for 128/+2 models
L_Label_01			ld		(T128_SlowBank1), hl
					ld      (T128_SlowBank1+2), de					
;
; Show hardware detection on screen
;
;					ld      hl, $4000
;					ld      de, $4001
;					ld      bc, 6143
;					ld      (hl), a
;					ldir
;
; Move loader to high memory 
;					
L_Label_02:			ld		hl, L_Loader
					ld		de, $bf00 						; Loader must be in bank 2 (>=$8000 and <$c000)
					ld		bc, LoaderEnd - L_Loader
					ldir									; Transfer loader code to high memory,
					jp		$bf00							; so that the game code can be loaded on the lowest address available
;
; loader core
;
L_Loader:			ld      sp, $c000  						; sp must be <= $c000
;
					ld      ix, $4000						; Loading address
					ld      de, 6912
					call    L_LoadBlock-L_Loader+$bf00		; Load screen
					
					ld      ix, $5b00						; Loading address
					ld      de, RAM5_LENGTH				
					call    L_LoadBlock-L_Loader+$bf00		; Load bank 5
;
					ld      ix, T128_MAIN					; Loading address
					ld      de, RAM2_LENGTH				
					call    L_LoadBlock-L_Loader+$bf00		; Load bank 2
;
					ld      ix, $c000						; Loading address
					ld      de, RAM0_LENGTH				
					call    L_LoadBlock-L_Loader+$bf00		; Load bank 0
;					
					ld		a, 7
					ld      ix, $db00						; Loading address
					ld      de, RAM7_LENGTH				
					call	L_SetBank-L_Loader+$bf00		; Load bank 7
;
					ld		a, (T128_SlowBank1)
					ld      ix, $c000						; Loading address
					ld      de, RAMSB1_LENGTH			
					call	L_SetBank-L_Loader+$bf00		; Load Slow Bank 1
;
					ld		a, (T128_SlowBank2)			
					ld      ix, $c000						; Loading address
					ld      de, RAMSB2_LENGTH			
					call	L_SetBank-L_Loader+$bf00		; Load Slow Bank 2
;
					ld		a, (T128_FastBank1)			
					ld      ix, $c000						; Loading address
					ld      de, RAMFB1_LENGTH			
					call	L_SetBank-L_Loader+$bf00		; Load Fast Bank 1
;
					ld		a, (T128_FastBank2)			
					ld      ix, $c000						; Loading address
					ld      de, RAMFB2_LENGTH			
					call	L_SetBank-L_Loader+$bf00		; Load Fast Bank 2
;
; Set border and run game
;
					ld		a, 1
					out		(254), a					
					jp      T128_MAIN						
;
; Load memory banks
;
L_SetBank:			ld		b, a							; b = mamory bank
					ld 		a, (T128_LastValue7ffd)			; Previous value of port
					and		$f8							
					or		b						
					ld 		bc, $7ffd
					ld 		(T128_LastValue7ffd), a
					out 	(c), a							; Select memory bank
L_LoadBlock:		scf
					sbc     a, a
					call	$0556							; Load block using ROM					
					di
					ret
LoaderEnd:
end Loader		