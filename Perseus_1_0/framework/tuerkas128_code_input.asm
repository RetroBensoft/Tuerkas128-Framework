;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; K E Y B O A R D   A N D
;
; J O Y S T I C K   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_INPUT
_BEGIN_CODE_INPUT


;
; 40 encoded keys. Format is 000rrrppp where:
;   rrr = key row
;   ppp = key position within the row
;
;	$24, $1C, $14, $0C, $04, $03, $0B, $13, $1B, $23
;	$25, $1D, $15, $0D, $05, $02, $0A, $12, $1A, $22
;	$26, $1E, $16, $0E, $06, $01, $09, $11, $19, $21
;	$27, $1F, $17, $0F, $07, $00, $08, $10, $18, $20
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; KeyPressedWait
;
; Wait for a key press
;

KeyPressedWait:		xor		a
					in		a, ($fe)
					or		%11100000
					inc		a
					jr		z, KeyPressedWait
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; KeyReleasedWait
;
; Wait for key release
;

KeyReleasedWait 	xor		a
					in		a, ($fe)
					or		%11100000
					inc		a
					jr		nz, KeyReleasedWait
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; KeyCheck
;
; Check if a key is pressed
;
; Input:
;   a = scancode of the key to be checked
;
; Output:
;   carry = 0 if the key was pressed
;   carry = 1 if the key was not pressed
;

KeyCheck:			ld		c, a
					and		7
					inc		a
					ld		b, a
					srl		c
					srl		c
					srl		c
					ld		a, 5
					sub		c
					ld		c, a
					ld		a, $fe
KC_Loop_01:			rrca
					djnz	KC_Loop_01
					in		a, ($fe)
KC_Label_01:		rra
					dec		c
					jr		nz, KC_Label_01				; Copy key bit in the carry flag
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_KeyJoystick
;
; Read keyboard, Sinclair joystick or Kempston joystick
;

T128_KeyJoystick:	ld		a, (T128_InputSource)		; a = 0 Keyboard/sinclair     1 = Kempston
					or		a
					jr		nz, KempstonEvent
				
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; KeyEvent
;
; Trigger events after reading key/joystick status
;
; Input:
;   (T128_KeyBase) = Base address for keys codes or Sinclair joystick codes
;
; Output:
;   (T128_EventControl) -> Event byte, format I00FUDLR
;                      I = No key is pressed for T128_TICKS_IDDLE/50 seconds or more
;                      F = Fire
;                      U = Up
;                      D = Down
;                      L = Left
;                      R = Right
;

KeyEvent:			ld		ix, (T128_KeyBase)
					ld		d, T128_EVENT_NULL			; Init null event
					ld		a, (ix+4)					; Check fire
					call	KeyCheck
					jr		c, KE_Label_01
					ld		d, T128_EVENT_FIRE			; Update event register
					xor		a
					ld		(T128_ClockTicksIddle), a
					ld		(T128_ClockTicksIddle+1), a	; Reset counter since last key pressed
KE_Label_01:		ld		a, (ix)						; Check left
					call	KeyCheck
					jr		c, KE_Label_02
					ld		a, T128_EVENT_LEFT
					or		d
					ld		d, a						; Update event register
					xor		a
					ld		(T128_ClockTicksIddle), a
					ld		(T128_ClockTicksIddle+1), a	; Reset counter since last key pressed
KE_Label_02:		ld		a, (ix+1)					; Comprobar derecha
					call	KeyCheck
					jr		c, KE_Label_03
					ld		a, T128_EVENT_RIGHT
					or		d
					ld		d, a						; Update event register
					xor		a
					ld		(T128_ClockTicksIddle), a	
					ld		(T128_ClockTicksIddle+1), a	; Reset counter since last key pressed
KE_Label_03:		ld		a, (ix+2)					; Check up
					call	KeyCheck
					jr		c, KE_Label_04
					ld		a, T128_EVENT_UP
					or		d
					ld		d, a						; Update event register
					xor		a
					ld		(T128_ClockTicksIddle), a	
					ld		(T128_ClockTicksIddle+1), a	; Reset counter since last key pressed
KE_Label_04:		ld		a, (ix+3)					; Check down
					call	KeyCheck
					jr		c, KE_Label_06
					ld		a, T128_EVENT_DOWN
					or		d
					ld		d, a						; Update event register
KE_Label_05:		xor		a
					ld		(T128_ClockTicksIddle), a	
					ld		(T128_ClockTicksIddle+1), a	; Reset counter since last key pressed
KE_Label_06:		ld		a, (T128_ClockTicksIddle+1)	; Check time since last key pressed
					or		a							
					jr		z, KE_Label_07
					ld		d, T128_EVENT_NULL_3S		; Trigger event T128_EVENT_NULL_3S if it is greater than T128_TICKS_IDDLE/50 seconds
					jr		KE_Label_08
KE_Label_07:		ld		a, (T128_ClockTicksIddle)
					cp		T128_TICKS_IDDLE			
					jr		c, KE_Label_08			
					ld		d, T128_EVENT_NULL_3S		; Trigger event T128_EVENT_NULL_3S if it it greater than T128_TICKS_IDDLE/50 seconds
KE_Label_08:		ld		a, d
					ld		(T128_EventControl), a
					ret
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; KempstonEvent
;
; Trigger movement events from Kempston joystick port
;
; Output:
;   (T128_EventControl) -> Event byte, format I00FUDLR
;                      I = No key is pressed for T128_TICKS_IDDLE/50 seconds or more
;                      F = Fire
;                      U = Up
;                      D = Down
;                      L = Left
;                      R = Right
;
KempstonEvent:		ld		bc, $1f
					in		a, (c)
					and		%00011111					; Read 5 lower bits
					ld		d, a						; Update event register
					jr		z, KE_Label_06				; Chech if joystick has not generated events for a long period. This code is shared with KeyEvent
					jr		KE_Label_05					; Process events. This code is shared with KeyEvent


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_KeyPauseQuit
;
; Process Pause and Quit keys
;
; If pause is pressed then
;   Do PauseQuit Screen
;   wait untill fire is pressed
;   Undo PauseQuit Screen
;   continue game
; else if quit is pressed
;   Do PauseQuit Screen
;   if fire is pressed then
;      Undo PauseQuit Screen
;      go to GAME OVER routine if Bank BS1
;   end if
;   if any other key is pressed then
;      Undo PauseQuit Screen
;      continue game
;   end if
; endif
;
; Input:
;   T128_KeyPause, T128_KeyQuit  = Key scancodes
;
T128_KeyPauseQuit:	ld		a, (T128_KeyPause)			; Check pause
					call	KeyCheck
					jr		c, KPQ_Label_03
;
; Pause		
;		
					ld		a, LD_A_HL
					ld		b, LD_DE_A
					call	PauseQuitScreen
					ld		a, (T128_InputSource)		; a = 0 Keyboard/sinclair     1 = Kempston
					or		a
					jr		nz, KPQ_Label_02			; Wait for Kempston fire to return game
KPQ_Loop_01:		call	KeyReleasedWait			
					call	KeyPressedWait			
					ld		ix, (T128_KeyBase)
					ld		a, (ix+4)
					call	KeyCheck
					jr		c, KPQ_Loop_01				; Wait for keyboard/sinclair fire to return game
KPQ_Label_01:		call	KeyReleasedWait	
					ld		a, LD_A_DE
					ld		b, LD_HL_A		
					jr		PauseQuitScreen
;
; Pause for Kempston joystick
;
KPQ_Label_02:		ld		bc, $1f
KFQ_Loop_02:		in		a, (c)
					and		%00010000
					jr		nz, KFQ_Loop_02
KFQ_Loop_03:		in		a, (c)
					and		%00010000
					jr		z, KFQ_Loop_03
					ld		a, LD_A_DE
					ld		b, LD_HL_A		
					jr		PauseQuitScreen
;					
KPQ_Label_03:		ld		a, (T128_KeyQuit)			; Check quit
					call	KeyCheck
					ret		c
;
; Quit
;			
					ld		a, LD_A_HL
					ld		b, LD_DE_A		
					call	PauseQuitScreen
					ld		a, (T128_InputSource)		; a = 0 Keyboard/sinclair     1 = Kempston
					or		a
					jr		nz, KPQ_Label_04			; Wait for Kempston to quit game or continue game
					call	KeyReleasedWait			
					call	KeyPressedWait				; Wait for keyboard/sinclair to quit game or continue game
					ld		ix, (T128_KeyBase)
					ld		a, (ix+4)
					call	KeyCheck
					jr		c, KPQ_Label_01				; Fire is not pressed: continue game
					call	KeyReleasedWait	
					jr		KPQ_Label_05				; Fire is pressed: go to Menu	
;
; Quit for kempston joystick
;					
KPQ_Label_04:		ld		bc, $1f
					in		a, (c)
					and		%00011111
					jr		z, KPQ_Label_04
					and		%00010000					; Read fire bit
					jr		z, KPQ_Label_01				; Fire is not pressed: continue game
KPQ_Label_05:		pop		hl							; Collect garbage from stack
					ld		a, LD_A_DE
					ld		b, LD_HL_A		
					call	PauseQuitScreen
					jp		MainCharIsKilled			; Fire is pressed: go to Menu	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PauseQuitScreen
;
; Special effect when pause/quit is pressed
; Do efect: 	Screen area attribute is set to T128_BLACK_BLUE_DK
; Undo effect: 	Screen area attribute is restored
;
; Input: 
;   Do effect:		a = LD_A_HL    b = LD_DE_A
;   Undo effect:	a = LD_A_DE    b = LD_HL_A
;
PauseQuitScreen:	ld		(PQS_Loop_02), a			; Self Modifying Code
					ld		a, b
					ld		(PQS_Loop_02+3), a			; Self Modifying Code
;					
					ld		de, $5800
					ld		a, (T128_LastValue7ffd)
					and		%00001000
					jr		z, PQS_Label_01				; RAM 5 screen is visible on screen
					ld		d, $d8						; RAM 7 is visible on screen
PQS_Label_01:		ld		a, 7						
					call	T128_SetBank				; set bank 7
					ld		b, e
					ld		c, T128_MIN_X
					ld		l, T128_MIN_Y
					ld		h, e
					add		hl, hl
					add		hl, hl
					add		hl, hl
					add		hl, hl
					add		hl, hl
					add		hl, bc
					add		hl, de						; hl = position on screen (ATTR)
					ld		a, T128_MAX_X
					sub		c
					inc		a
					ld		c, a						; c = width of screen
					ld		a, T128_MAX_Y
					sub		T128_MIN_Y
					ld		b, a						; b = height of screen
					ld		de, T128_RAM7_Buffer		; de = buffer on RAM 7
;
; Screen
;	
PQS_Loop_01:		push	bc
					push	hl
;
; Line
;					
PQS_Loop_02:		ld		a, (hl)						; ld a, (de)
					ld		(hl), T128_BLACK_BLUE_DK	; 
					ld		(de), a						; ld (hl), a
					inc		hl
					inc		de
					dec		c
					jr		nz, PQS_Loop_02
;
					pop		hl
					ld		bc, 32
					add		hl, bc
					pop		bc
					djnz	PQS_Loop_01
;
					xor		a
					jp		T128_SetBank				; Return to bank 0