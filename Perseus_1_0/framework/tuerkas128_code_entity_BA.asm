;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; B R E A T H   A R E A S   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					

PUBLIC _BEGIN_CODE_ENTITY_BA
_BEGIN_CODE_ENTITY_BA

PUBLIC T128_BA_CheckB0, T128_BA_CreateB0, T128_BA_FSMB0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BA_CreateB0
;
; Create an entry in T128_ScreenBreaths for current Screen Area:
;
; BREATH AREA (9 bytes)
;   T000000S				[byte]
;     T = 1 Right / 0 Left 
;	  S = 1 On / 0 Off
;	X MIN 					[byte]
; 	X MAX 					[byte]
; 	Y MIN 					[byte]
; 	Y MAX 					[byte]
;   OFF TIME 				[byte]
;   ON TIME  				[byte]														
;   COUNTER					[byte]
;   INITIAL DELAY 			[byte]
;
; Input:
;   ix = Address of screen entity data
;   e  = T0000000  whte T=1 for right breath / T=0 for left breath
;

T128_BA_CreateB0:	ld		a, (T128_ScreenBreathsNum)
					cp		T128_SCREEN_MAX_BREATHS		; Chechk max number of Breath Areas
					ret		z
					inc		a
					ld		(T128_ScreenBreathsNum), a
					dec		a
					ld		b, a
					add		a, a
					add		a, a
					add		a, a						; a = a * 8
					add		a, b						; a = a * 9
					ld		c, a
					ld		b, 0
					ld		hl, T128_ScreenBreaths
					add		hl, bc
					ld		(hl), e						; T000000S
					inc		hl
					ld		a, (ix)						; X MIN
					
					ld		b, a
					and		%00011111
					ld		(hl), a
					inc		hl
					ld		c, a
					ld		a, b
					and		%11100000
					rlca
					rlca
					rlca
					dec 	a
					add		a, c						; X MAX
					ld		(hl), a
					inc		hl
					ld		a, (ix+1)					; Y MIN
					ld		b, a
					and		%00011111					
					ld		(hl), a
					inc		hl
					ld		c, a
					ld		a, b
					and		%11100000					
					rlca
					rlca
					rlca
					dec 	a
					add		a, c						; Y MAX
					
					ld		(hl), a
					inc		hl
					ld		a, (ix+2)					; OFF TIME
					ld		(hl), a
					inc		hl
					ld		b, (ix+3)					; ON TIME
					ld 		(hl), b
					inc		hl
					ld		(hl), a						; COUNTER (initially equal to OFF TIME)
					inc		hl
					ld		a, (ix+4)					; INITIAL DELAY
					ld		(hl), a
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BA_CheckB0
;
; Check if a sprite is reached by a breath area
; In that case, the sprite is moved 8 pixels left or right, according to the type of breath, unless there is an obstacle ahead
;
; Input:
;   ix = sprite address
;
					
T128_BA_CheckB0:	ld		a, (T128_ScreenBreathsNum)
					or		a
					ret		z
					ld		b, a
					ld		a, (ix+6)
					and		%00000111
					ret		nz							; x non exact ==> No interaction. This avoids artefacts when checking colissions
					ld		iy, T128_ScreenBreaths
BAC_Loop_01:		push	bc
					ld		a, (iy)
					and		%00000001
					jr		z,  BAC_Label_01			; Breath is off
;
; Check collision
;					
					call	T128_SpriteAreaCol			; NC = Collision
					jr		nc, BAC_Label_02
;
; Next Breath Area
; 					
BAC_Label_01:		ld		bc, T128_BA_TABLE_SIZE
					add		iy, bc
					pop		bc
					djnz	BAC_Loop_01
					ret									; Breath areas not found
; 
; Process breath collision
;					
BAC_Label_02:		pop		bc
					ld		a, (iy)
					and		%10000000
					jr		nz, BAC_Label_05
;
; Breath Left
; 
BAC_Label_03:		call	T128_BlockColLeft			; Check collision left (sprite looking left)
BAC_Label_04:		cp		T128_BLOCK_SOLID
					ret		z
					cp		T128_BLOCK_STEP
					ret		z
					ld		a, (ix+6)
					sub		8
					ld		(ix+6), a
					dec		(ix+5)
					ret
;
; Breath right
; 
BAC_Label_05:		call	T128_BlockColRight			; Check collision right (sprite looking right)
					cp		T128_BLOCK_SOLID
					ret		z
					cp		T128_BLOCK_STEP
					ret		z
					ld		a, (ix+6)
					add		a, 8
					ld		(ix+6), a
					inc		(ix+5)
					ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BA_FSMB0
;
; Breath areas Finite State Machine
;

T128_BA_FSMB0:		ld		a, (T128_ScreenBreathsNum)
					or		a
					ret		z							; No breath areas
					ld		ix, T128_ScreenBreaths
					ld		b, a
					ld		c, %00000001
BAF_Loop_01:		
;
; Check initial delay
;					
					ld		a, (ix+8)
					or		a
					jr		z, BAF_Label_01
					dec		(ix+8)
					jr		BAF_Label_03
;
; Check phase duration 
;					
BAF_Label_01:		dec		(ix+7)
					jr		nz, BAF_Label_03			; Next breath area if current duration is not 0
;
; Toggle phase
;					
					ld 		a, (ix)
					xor		c
					ld		(ix), a						; toggle state on/off
;
; New counter
;
					and		c
					ld		a, (ix+6)
					jr		nz, BAF_Label_02
					ld		a, (ix+5)
BAF_Label_02:		ld		(ix+7), a
;
BAF_Label_03:		ld		de, T128_BA_TABLE_SIZE
					add		ix, de						; Next animated block
					djnz 	BAF_Loop_01
					ret