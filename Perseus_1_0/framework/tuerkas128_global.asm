;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; G L O B A L   C O N S T A N T S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;
; Language:
;   0 = Spanish
;   1 = English
;   2 = Portuguese
;
T128_LANGUAGE			EQU		1


;
; MASKED / NON MASKED SPRITES
;
; T128_MASKED_SPRITES=2 if masked sprites are used
; T128_MASKED_SPRITES=1 if NON masked sprites are used
;
; T128_MASKED_SPRITES=1 has not been tested (28/02/2024)
;
T128_MASKED_SPRITES		EQU		2


; 
; Last value of port 7ffd
;
; This variable must be set in the loader before loading blocks from tape into memory
; It is used all over the framework to properly do bank switching and toggle screen 5 / screen 7
;
T128_LastValue7ffd	EQU			$8000

;
; Slow and fast banks
;
; These variables must be set before loading blocks from tape into memory, in order to select which block is loaded into which bank
; Crtical code and data structures must be located on not contended memory to optimize performance
;
; On 128k/+2 models banks 1 & 3 are contended memory, and banks 4 & 6 are not contended memory
; On +2A /+3 models banks 4 & 6 are contended memory, and banks 1 & 3 are not contended memory
;
T128_SlowBank1		EQU			$8001					; Contended memory bank 1
T128_SlowBank2		EQU			$8002					; Contended memory bank 2
T128_FastBank1		EQU			$8003					; Not contended memory bank 1
T128_FastBank2		EQU			$8004					; Not contended memory bank 2

;
; Game entry point
; It is used in loader.asm to start the game after loading from tape
; Game entry point is in bank_2.asm
;
T128_MAIN			EQU			$8005					