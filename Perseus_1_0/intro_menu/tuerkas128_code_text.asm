;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T E X T   R O U T I N E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_TEXT
_BEGIN_CODE_TEXT



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DATA
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TextFont:			defb	0, 0, 0, 0, 0, 0, 0, 0					; SPC (ASCII 32)
					defs	6*8										; 6 not used smybols
					defb	48, 48, 96, 0, 0, 0, 0, 0				; ' (ASCII 39)
					defb	0, 0, 0, 0, 0, 0, 0, 0					; (ASCII 40)
					defb	0, 0, 0, 0, 0, 0, 0, 0					; (ASCII 41)
					defb	64, 32, 0, 48, 72, 132, 132, 0			; * (ASCII 42) ==> à
					defb	0, 0, 0, 0, 0, 0, 0, 0					; (ASCII 43)
					defb	0, 0, 0, 0, 0, 48, 48, 96				; , (ASCII 44)
					defb	0, 0, 0, 0, 252, 0, 0, 0				; - ASCII 45
					defb	0, 0, 0, 0, 0, 48, 48, 0				; . (ASCII 46)
					defb	0, 0, 4, 8, 16, 32, 64, 0				; / (ASCII 47)
					defb	48, 72, 132, 132, 132, 72, 48, 0		; 0 (ASCII 48)
					defb	16, 48, 80, 16, 16, 16, 16, 0			; 1
					defb	56, 68, 4, 24, 96, 128, 252, 0			; 2
					defb	224, 24, 4, 124, 4, 24, 224, 0			; 3
					defb	132, 132, 132, 156, 228, 4, 4, 0		; 4
					defb	252, 128, 128, 112, 8, 68, 56, 0		; 5
					defb	8, 16, 48, 72, 132, 72, 48, 0			; 6
					defb	252, 4, 8, 8, 16, 16, 32, 0				; 7
					defb	120, 132, 72, 48, 72, 132, 120, 0		; 8
					defb	48, 72, 132, 72, 48, 32, 64, 0			; 9
					defb	0, 0, 48, 48, 0, 48, 48, 0				; : (ASCII 58)
					defb	0, 0, 0, 0, 0, 0, 0, 0					; ASCII 59
					defb	0, 120, 0, 224, 156, 132, 132, 0		; < (ASCII 60) ==> ñ
					defb	0, 0, 28, 96, 128, 104, 28, 32			; = (ASCII 61) ==> ç
					defb	100, 152, 0, 48, 72, 132, 132, 0		; > (ASCII 62) ==> ã
					defb	0, 0, 0, 0, 0, 0, 0, 0					; ASCII 63
					defb	16, 40, 28, 96, 248, 96, 28, 0			; @ (ASCII 64) ==> ê
					defb	48, 72, 72, 72, 228, 156, 132, 0		; A (ASCII 65)
					defb	224, 152, 132, 248, 132, 152, 224, 0	; B
					defb	12, 48, 64, 128, 64, 48, 12, 0			; C
					defb	224, 144, 136, 132, 136, 144, 224, 0	; D
					defb	12, 48, 64, 248, 64, 48, 12, 0			; E
					defb	48, 204, 128, 224, 128, 128, 128, 0		; F
					defb	24, 32, 64, 140, 68, 36, 24, 0			; G
					defb	132, 132, 132, 252, 132, 132, 132, 0	; H
					defb	16, 16, 16, 16, 16, 16, 16, 0			; I
					defb	8, 8, 8, 8, 8, 40, 24, 0				; J
					defb	140, 144, 160, 192, 160, 144, 140, 0	; K
					defb	128, 128, 128, 128, 128, 128, 248, 0	; L
					defb	132, 204, 180, 132, 132, 132, 132, 0	; M
					defb	132, 196, 164, 148, 140, 132, 132, 0	; N
					defb	48, 72, 132, 132, 132, 72, 48, 0		; O
					defb	224, 152, 132, 152, 224, 128, 128, 0	; P
					defb	48, 72, 132, 132, 148, 88, 40, 0		; Q
					defb	224, 152, 132, 152, 224, 152, 132, 0	; R
					defb	24, 32, 64, 252, 8, 16, 96, 0			; S
					defb	56, 84, 16, 16, 16, 16, 16, 0			; T
					defb	132, 132, 132, 132, 132, 136, 244, 0	; U
					defb	132, 132, 132, 72, 72, 72, 48, 0		; V
					defb	132, 132, 132, 132, 180, 204, 132, 0	; W
					defb	132, 132, 72, 48, 72, 132, 132, 0		; X
					defb	132, 68, 40, 16, 32, 32, 64, 0			; Y
					defb	252, 8, 16, 16, 32, 64, 252, 0			; Z
					defb	16, 32, 0, 48, 72, 132, 132, 0			; [ ASCII 91 ==> á
					defb	16, 32, 28, 96, 248, 96, 28, 0			; \ ASCII 92 ==> é
					defb	8, 16, 0, 16, 16, 16, 16, 0				; ] ASCII 93 ==> í
					defb	16, 32, 48, 72, 132, 72, 48, 0			; ^ ASCII 94 ==> ó
					defb	16, 32, 132, 132, 132, 136, 244, 0		; _ ASCII 95 ==> ú
					defb	0, 0, 0, 0, 0, 0, 0, 0					; ASCII 96
					defb	0, 0, 48, 72, 104, 156, 132, 0			; a (ASCII 97)
					defb	128, 128, 224, 152, 132, 152, 224, 0	; b
					defb	0, 0, 28, 96, 128, 96, 28, 0			; c
					defb	4, 4, 28, 100, 132, 100, 28, 0			; d
					defb	0, 0, 28, 96, 248, 96, 28, 0			; e
					defb	24, 32, 64, 112, 64, 64, 64, 0			; f
					defb	0, 0, 28, 100, 132, 124, 4, 60			; g
					defb	64, 64, 64, 96, 144, 136, 132, 0		; h
					defb	0, 16, 0, 16, 16, 16, 16, 0				; i
					defb	0, 8, 0, 8, 8, 8, 40, 24				; j
					defb	128, 128, 144, 160, 224, 152, 132, 0	; k
					defb	16, 16, 16, 16, 16, 16, 16, 0			; l
					defb	0, 0, 204, 180, 148, 132, 132, 0		; m
					defb	0, 0, 224, 152, 132, 132, 132, 0		; n
					defb	0, 0, 48, 72, 132, 72, 48, 0			; o
					defb	0, 0, 224, 152, 132, 152, 224, 128		; p
					defb	0, 0, 28, 100, 132, 100, 28, 4			; q
					defb	0, 0, 136, 176, 192, 128, 128, 0		; r
					defb	0, 0, 24, 96, 252, 24, 96, 0			; s
					defb	16, 16, 56, 16, 16, 16, 16, 0			; t
					defb	0, 0, 132, 132, 132, 136, 244, 0		; u
					defb	0, 0, 132, 132, 72, 72, 48, 0			; v
					defb	0, 0, 132, 132, 148, 180, 204, 0		; w
					defb	0, 0, 132, 72, 48, 72, 132, 0			; x
					defb	0, 0, 4, 136, 80, 32, 64, 128			; y
					defb	0, 0, 252, 8, 48, 64, 252, 0			; z


TextLastSpc			defb	0							; Last printed space

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_StrPrintMulti
;
; Print a multiline string. CR/LF is detected when a whole word exceeds right limit 
; String length must be 254 or less.
;
; Input:
;   b  = X position
;   c  = Y position
;   a' = right limit
;   hl = string address (zero-terminated string)
;
; Output:
;   hl = Next address (string terminator + 1)
;					
T128_StrPrintMulti:	ld		d, 0
					ld		e, b
					push	hl
SPM_Loop_02:		ld		a, (hl)
					inc		hl
					or		a
					jr		z, SPM_Label_03				; End of text
					cp		' '
					jr		nz, SPM_Label_01
					ld		a, d
					ld		(TextLastSpc), a			; Save length to last position of a ' '
SPM_Label_01:		inc		d							; Increment number of characters to print
					inc		b							; X = X + 1
					ex		af,af'
					cp		b
					jr		z, SPM_Label_02
					ex		af, af'
					jr		SPM_Loop_02
SPM_Label_02:		ex		af, af'						; Right border is reached
					ld		a, (TextLastSpc)
					ld		d, a						; Restore length to last position of a ' '
SPM_Label_03:		ld		b, e
					pop		hl
					push	bc
					call	T128_StrPrintLen
					pop		bc
					inc		c							; Y = Y + 1	(next line)	
					or		a
					ret		z							; End of text
					ld		a, (hl)
					cp		' '							; Delete ' ' at the begining of a new line
					jr		nz, T128_StrPrintMulti
					inc		hl
					jr		T128_StrPrintMulti


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_StrPrintLen
;
; Print a string 
; String length must be 254 or less
;
; Input:
;   b  = X position
;   c  = Y position
;   hl = string address (zero-terminated string)
;   d  = length of string. If string has a zero-terminator character, then d must be equal to $ff.
;
; Output:
;   hl = Next address to the last printed character (including string terminator, in case it exists)
;   a  = 0   if end of string is reached
;      = $ff if end of string is not reached (multiline)
;					
T128_StrPrintLen:	push	de
					ld		a, c
					and		$f8
					add		a, $40
					ld		d, a
					ld		a, c
					and		7
					rrca
					rrca
					rrca
					add		a, b
					ld		e, a						; de = screen address
					pop		bc							; b = length of string
;
; print string
;					
SPL_Loop_01:		ld		a, (hl)						; a = character to print
					inc		hl
					or		a
					ret		z							; End of string (zero-termiator character is reached)
;
; print char
;
					push	de
					exx
					pop		de
					ld		bc, TextFont				
					sub		' '							; First ASCII char in TextFont is ' '
					ld		l, a
					ld		h, 0
					add		hl, hl
					add		hl, hl
					add		hl, hl						; hl = a * 8
					add		hl, bc						; hl = byte inicial de definición del digito
					ld		b, 8
SPL_Loop_02:		ld		a, (hl)
					ld		(de), a
					inc		hl
					inc		d
					djnz	SPL_Loop_02
					exx
					inc		de							; Next column
					djnz	SPL_Loop_01
					or		$ff
					ret