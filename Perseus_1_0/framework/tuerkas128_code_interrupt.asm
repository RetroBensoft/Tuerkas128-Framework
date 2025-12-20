;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; I N T E R R U P T   F U N T I O N S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_INTERRUPT
_BEGIN_CODE_INTERRUPT:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ISR
;
; Interrupt Service Routine
;
; Count clock ticks for FPS sychronization
; Count iddle clock ticks for main character behaviour
; Call sound driver: P E N D I E N T E
;

T128_ISR: 			push	af
					push	bc
					push	de
					push	hl
					ex		af, af'
					push	af
					exx
					push	bc
					push	de
					push	hl
					push	ix
					push	iy
;
; Increment iddle clock ticks
;
					ld		hl, (T128_ClockTicksIddle)
					inc		hl
					ld		(T128_ClockTicksIddle), hl	
;
; Increment clock ticks
;					
					ld		a, (T128_ClockTicks)
					inc		a
					ld		(T128_ClockTicks), a		
;
; Call sound player
;
					ld		a, (T128_FastBank1)
					ld		b, a		
					ld 		a, (T128_LastValue7ffd)
					and		$f8				
					or		b
					ld 		bc, $7ffd
					out 	(c), a						; Set Fast Bank 1
					call	T128_AY_PlayerBF1			; AY player
					ld 		a, (T128_LastValue7ffd)
					ld 		bc, $7ffd
					out 	(c), a						; Set previous bank
;
					pop		iy
					pop		ix
					pop		hl
					pop		de
					pop		bc
					exx
					pop		af
					ex		af, af'
					pop		hl
					pop		de
					pop		bc
					pop		af
					ei
					reti
;					ret
				
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SychroFPS
;
; Wait for a certain number of interrupts to synchronize frames per second
;

T128_SychroFPS:		ld		b, T128_FPS					; 1 = 50 fps   2 = 25 fps   3 = 16,66 fps   4 = 12,5 fps				
;					
; Wait until b interrupts have occurred 
;
					ld		hl, T128_ClockTicksPrevious
SFPS_Loop_01:		ld		a, (T128_ClockTicks)
					sub		(hl)
					cp		b
					jr		c, SFPS_Loop_01
;
; Reset previous clock ticks			
;
					ld		a, (T128_ClockTicks)
					ld		(hl), a
					ret