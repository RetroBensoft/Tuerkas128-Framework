;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S C O R E B O A R D   F U N C T I O N S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _BEGIN_CODE_SCOREBOARD
_BEGIN_CODE_SCOREBOARD

PUBLIC T128_UpdateScrBrdB0

PUBLIC USB_SMC_01_B0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Rendering routines for every scoreboard type
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\scoreboard\tuerkas128_SB_routines.asm"		; Include code

					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_UpdateScrBrdB0
;
; Update scoreboard
;
; For every GameVar on the scoreboard do:
;
; if Rendering Flag = 2 and hidden screen = Bank 5 then
;    set Rendering Flag = 1
;    call rendering routine
; elsif Rendering Flag = 1 and hidden screen = Bank 7 then
;    set Rendering Flag = 0
;    transfer data from bank 5 to bank 7
; end if
;
T128_UpdateScrBrdB0	ld		ix, T128_GameVar00			; First GameVar
					ld		b, T128_GAMEVARSSCRBRD		; Number of GameVars on scoreboard
USB_Loop_01:		push	bc
					ld		a, (ix+2)
					ld		b, a
					bit		1, a
					jr		z, USB_Label_01				; Rendering Flag = 2?
					ld		a, (T128_LastValue7ffd)	
					and		%00001000
					ld		a, b
					jr		z, USB_Label_01				; NZ if hidden screen = RAM 5
;
; Rendering Flag = 2 and hidden screen = Bank 5 then
;					
					and		%11111100
					or		%00000001
					ld 		(ix+2), a					; Set Rendering Flag = 1
					and		%11111100
					rrca								; a = (Type of GameVar)*2
					ld		hl, SB_RenderRoutines
					ld		c, a
					ld		b, 0
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = Rendering routine address
					ld		hl, USB_Label_02			; hl = returning address
					ex		de, hl
					pop		af							; a = loop counter
					push	af							; Backup b on stack
					ld		c, a
					ld		a, T128_GAMEVARSSCRBRD
					sub		c							; a = number of GameBar
					push	de
					jp		(hl)
;					
USB_Label_01:		bit		0, a
					jr		z, USB_Label_02				; Rendering Flag = 1?
					ld		a, (T128_LastValue7ffd)	
					and		%00001000					
					jr		nz, USB_Label_02			; Z if hidden screen = RAM 7
;
; Rendering Flag = 1 and hidden screen = Bank 7 then
;					
					ld		a, b
					and		%11111110
					ld 		(ix+2), a					; Set Rendering Flag = 0
USB_SMC_01_B0:		call	$0000

;					
USB_Label_02:		ld		de, T128_GV_TABLE_SIZE
					add		ix, de
					pop		bc
					djnz	USB_Loop_01
					ret
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; G A M E V A R   R E N D E R I N G   R O U T I N E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include ".\scoreboard\tuerkas128_digit.asm"				; Render digit
include ".\scoreboard\tuerkas128_bar.asm"				; Render bar
include ".\scoreboard\tuerkas128_icon.asm"				; Render icon
					