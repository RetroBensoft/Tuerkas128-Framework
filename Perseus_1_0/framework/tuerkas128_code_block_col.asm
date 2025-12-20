;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; B L O C K   C O L L I S I O N   D E T E C T I O N  
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_BLOCK_COL
_BEGIN_CODE_BLOCK_COL:



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SpriteAreaCol
;
; Check if a sprite collides with a rectangular area on screen
;
; Input: 
;  ix = sprite adddres
;  iy = Area definition
;       Byte 0 = not used in this routine
;	    Byte 1 = X MIN of rectangle
;	    Byte 2 = X MAX of rectangle
;	    Byte 3 = Y MIN of rectangle
;	    Byte 4 = Y MAX of rectangle
;
; Output:
;  NC = The sprite collides with rectangle
;  C  = The sprite does not collides with rectangle
;					

T128_SpriteAreaCol:	ld		a, (ix+6)					; x Sprite
					rrca
					rrca
					rrca
					and		%00011111
					ld		b, a						; X Sprite
					ld		a, (iy+1)					; XMIN Breath Area
					cp		b
					jr		nc, SpAC_Label_01			; Breath Area is on the right
					ld		a, (iy+2)					; a = XMAX Breath Area
					cp		b
					jr		nc, SpAC_Label_02			; Breath Area and Sprite collide horzontally ==> check vertically
					ret									; Breath Area and Sprite do not collide horizontally ==> ret C
SpAC_Label_01:		ld		d, a						; d = XMIN
					ld		a, (ix+10)
					rrca
					rrca
					rrca
					and		%00011111
					add		a, b						; a = X + width Sprite
					dec		a
					cp		d
					jr		nc, SpAC_Label_02			; Breath Area and Sprite collide horzontally ==> check vertically
					ret									; Breath Area and Sprite do not collide horizontally ==> rec C
SpAC_Label_02:	 	ld		b, (ix+8)					; y Sprite
					ld		a, (iy+3)					; YMIN Breath Area
					add		a, a
					add		a, a
					add		a, a						; ymin Breath Area
					cp		b
					jr		nc, SpAC_Label_03			; Breath Area is under Sprite
					ld		a, (iy+4)					; YMAX Breath Area
					add		a, a
					add		a, a
					add		a, a						
					add		a, 7						; ymax Breath Area
					cp		b
					ret		nc							; Breat Area and Sprite collide vertically ==> Total collision ==> ret NC
					ret									; Breath Area and Sprite do not collide vertically ==> ret C
SpAC_Label_03:		ld		d, a						; d = ymin Breath Area
					ld		a, (ix+11)					; Height Sprite
					add		a, b						; a = y + height Sprite
					dec		a
					cp		d							; Breath Area and Sprite collide vertically ==> Total collision ==> NC
					ret									; Breath Area and Sprite do not collide vertically ==> ret C



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlkxRgh
;
; Get X Right-most position of the sprite + 1. It is used in Ladder functions
;
; X = (x / 8) + (width in pixels)
;
; Input: 
;  ix = sprite adddres
;
; Output:
;  c = X
;					
T128_BlkxRgh:		call	T128_BlkxLft
					ld		a, (ix+10)
					rrca
					rrca
					rrca
					and		%00011111
					add		a, c
					ld		c, a
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlkxLft
;
; Get left-most X position of the sprite. It is used in Ladder functions

; X = x / 8
;
; Input: 
;  ix = sprite adddres
;
; Output:
;  c = X
;					
T128_BlkxLft:		ld		a, (ix+6)					; a = x
					rrca
					rrca
					rrca
					and		%00011111
					ld		c, a						; c = X
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLaddDwnComm
;
; Common routine for T128_BlockLadderLftDwn and T128_BlockLadderRghDwn
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_EMPTY
;    carry set if Y >= T128_MAX_Y   ==> No ladder					
;

T128_BlockLaddDwnComm
					ld		b, (ix+7)					; b = Y
					ld		a, (ix+11)
					rrca	
					rrca	
					rrca
					and		%00011111					
					add		a, b
					ld		b, a						; b = Y + height
					cp		T128_MAX_Y
					ld		a, T128_BLOCK_EMPTY
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderLftDwn
;
; Check ladder down left to begin climbing down
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderLftDwn
					call	T128_BlockLaddDwnComm
					ret		nc							; Y >= T128_MAX_Y   ==> No ladder					
					call	T128_BlkxRgh
					dec		c							; c = X + width - 1
					cp		T128_MAX_X+1
					ld		a, T128_BLOCK_EMPTY
					ret		nc							; X > T128_MAX_X   ==> No ladder
					jp		T128_BlockLadder
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderRghDwn
;
; Check ladder down right to begin climbing down
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderRghDwn
					call	T128_BlockLaddDwnComm
					ret		nc							; Y >= T128_MAX_Y   ==> No ladder					
					call	T128_BlkxLft				; c = X
					jp		T128_BlockLadder					


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderLeft
;
; Check ladder left to begin climbing up
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderLeft		
					ld		b, (ix+7)					; b = Y
					call	T128_BlkxLft
					dec		c							; c = X-1
					jp		T128_BlockLadder
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderRight
;
; Check ladder right to begin climbing up
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderRight
					ld		b, (ix+7)					; b = Y
					call	T128_BlkxRgh				; c = X + width
					cp		T128_MAX_X+1
					ld		a, T128_BLOCK_EMPTY
					ret		nc							; X > T128_MAX_X   ==> No ladder
					jp		T128_BlockLadder
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderUpLeft
;
; Check ladder up left to stop climbing up
;
; Input:
;	 ix = Sprite parameters
;    e  = Vertical distance
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderUpLeft
					ld		a, (ix+8)
					and 	%00000111
					ld		a, T128_BLOCK_LADDER
					ret		nz							; Non exact y ==> Ladder
;
					call	T128_BlkxLft				; c = X
BLUL_Label_01:		ld		a, (ix+7)
					add		a, e						
					ld		b, a						; b = Y + e
					cp		T128_MAX_Y
					ld		a, T128_BLOCK_LADDER		
					ret		nc							; Y >= T128_MAX_Y   ==> Ladder
					jp		T128_BlockLadder	

					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderUpRight
;
; Check ladder up right to stop climbing up
;
; Input:
;	 ix = Sprite parameters
;    e  = Vertical distance
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderUpRight
					ld		a, (ix+8)
					and 	%00000111
					ld		a, T128_BLOCK_LADDER
					ret		nz							; Non exact y ==> Ladder
;
					call	T128_BlkxRgh
					dec		c							; c = X + width - 1					
					jr		BLUL_Label_01


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderDwnLeft
;
; Check ladder down left to stop climbing down
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderDwnLeft
					ld		a, (ix+8)
					and 	%00000111
					ld		a, T128_BLOCK_LADDER
					ret		nz							; Non exact y ==> Ladder
;
					call	T128_BlkxLft				; c = X
BLDL_Label_01:		ld		b, (ix+7)
					ld		a, (ix+11)
					rrca	
					rrca	
					rrca
					and		%00011111					
					add		a, b
					ld		b, a						; b = Y + height
					cp		T128_MAX_Y
					ld		a, T128_BLOCK_LADDER		
					ret		nc							; Y >= T128_MAX_Y   ==> Ladder
					jp		T128_BlockLadder	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadderDwnRight
;
; Check ladder down left to stop climbing down
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadderDwnRight
					ld		a, (ix+8)
					and 	%00000111
					ld		a, T128_BLOCK_LADDER
					ret		nz							; Non exact y ==> Ladder
;
					call	T128_BlkxRgh
					dec		c							; c = X + width - 1										
					jr		BLDL_Label_01


PUBLIC T128_BlockDeath

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockDeath
;
; Check if a sprite collides with any DEATH BLOCK
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_DEATH (collision)
;    a = T128_BLOCK_EMPTY (no collision)
;
;
T128_BlockDeath:	ld 		a, (ix+6)
					rrca
					rrca
					rrca
					and		%00011111					; X = x / 8
					ld		c, a						; c = X (real)
					ld 		a, (ix+7)					
					cp		T128_MAX_Y
					jr		z, BD_Label_05				; Chech bottom border
BD_Label_00:		ld		d, a						; d = Y
					call	T128_BlockColAddr			; hl = map address of (X,Y)
					ld		a, (ix+10)
					rrca
					rrca
					rrca
					ld		b, a						; b = sprite width in characters
					ld		a, (ix+6)
					and		%00000111
					jr		z, BD_Label_01
					inc		b							; increment width if sprite is not in exact X
BD_Label_01:		ld		a, (ix+11)
					rrca
					rrca
					rrca
					ld		e, a						; e = sprite height in characters
					ld		a, (ix+8)
					and		%00000111
					jr		z, BD_Loop_01
					inc		e							; increment height if sprite is not in exact X
;
; Collsiion loop
;					
BD_Loop_01:			push	de							; Save Y and height
					push	hl							; Save map address
BD_Loop_02:			ld		a, (hl)
					and		%00001110
					cp		T128_BLOCK_DEATH
					jr		z, BD_Label_06
					ld		a, l
					add		a, 32
					jr		nc, BD_Label_03
					inc		h
BD_Label_03:		ld		l, a						; Address for next row
					inc		d
					ld		a, T128_MAX_Y		
					cp		d
					jr		z, BD_Label_04
					dec		e
					jr		nz, BD_Loop_02				; Next row
BD_Label_04:		pop		hl							; Restore map address
					inc		hl							; Address for next row
					pop		de							; Restore Y and height
					inc		c
					ld		a, T128_MAX_X+1
					cp		c
					jr		z, BD_Label_05				; Sprite is beyond right border
					djnz	BD_Loop_01					; next column
BD_Label_05:		ld		a, T128_BLOCK_EMPTY			; No DEATH BLOCKS: a = T128_BLOCK_EMPTY
					ret
;
; DEATH BLOCK detected: a = T128_BLOCK_DEATH
; 					
BD_Label_06:		pop		hl
					pop		de
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockColAddr
;
; Common routine to calculate map address
;
; Input:
;   d = Y
;   c = X
;
; Output:
;   hl = map address
;

T128_BlockColAddr:	ld		a, d
					rrca							
					rrca							
					rrca							
					and		%00011111				
					add		a, T128_MapHD_PAGE
					ld		h, a
					ld		a, d
					and		7
					rrca
					rrca
					rrca
					add		a, c
					ld		l, a						; hl = Initial address of hardness/depth map
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockLadder
;
; Check ladder at a coordinate
;
; Input:
;    c  = X coordinate
;    b  = Y coordinate
;
; Output:
;    a = T128_BLOCK_LADDER if ladder is detected
;	     T128_BLOCK_EMPTY  if no ladder is detected
;

T128_BlockLadder:	ld		a, T128_MAX_Y-1
					cp		b
					ld		a, T128_BLOCK_LADDER
					ret		c							; Bottom border of screen area ==> Ladder
;
					ld		a, T128_MAX_X
					cp		c
					ld		a, T128_BLOCK_EMPTY
					ret		c							; Right border of screen area ==> No ladder
;					
					ld		a, b
					ld		d, a
					call	T128_BlockColAddr
;
; Check ladder
;					
					ld		a, (hl)
					and		%00001110
					cp		T128_BLOCK_LADDER
					ld		a, T128_BLOCK_LADDER
					ret		z
					ld		a, T128_BLOCK_EMPTY
					ret									


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockColLeft
;
; Input:
;	 ix = Sprite parameters
;

T128_BlockColLeft:	ld		a, (ix+6)
					rrca
					rrca
					rrca
					and		%00011111					; x / 8
					cp		T128_MIN_X		
					jr		nz, BCL_Label_01
					ld		a, T128_BLOCK_EMPTY			; if sprite is in the left border, then return T128_BLOCK_EMPTY
					ret
BCL_Label_01:		dec		a							
					ld		c, a						; (x / 8) - 1
					jr		T128_BlockColSides
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockColRight
;
; Input:
;	 ix = Sprite parameters
;

T128_BlockColRight:	ld		a, (ix+6)
					rrca
					rrca
					rrca
					and		%00011111					; x / 8
					ld		c, a
					ld		a, (ix+10)
					rrca
					rrca
					rrca
					and		%00011111					; width in pixels / 8
					add		a, c
					ld		c, a


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockColSides
;
; Check block collisions on one side of a sprite
;
; Input:
;	 ix = Sprite parameters
;    c  = X
;
; Output:
;    a = T128_BLOCK_EMPTY if no obstacles ahead
;	     T128_BLOCK_DEATH if sprite collides with death blocks (and T128_DeathBlkCol is set to T128_BLOCK_DEATH)
;        T128_BLOCK_SOLID if sprite collides with a solid block
;        T128_BLOCK_STEP  if sprite collides with a step
;

T128_BlockColSides:	ld		a, (ix+6)
					and 	%00000111
					ld		a, T128_BLOCK_EMPTY
					ret		nz							; Non exact x ==> No collision
;
					ld		a, T128_MAX_X
					cp		c
					ld		a, T128_BLOCK_EMPTY
					ret		c							; Right border of screen area ==> No collision
;					
					ld		a, (ix+11)
					rrca	
					rrca	
					rrca
					and		%00011111
					ld		b, a						; b = rows to scan
					ld		a, (ix+8)
					and		%00000111
					jr		z, BCS_Label_01
					inc		b							; rows = rows + 1, if non exact y
BCS_Label_01:		ld		a, (ix+7)					; a = Y
					ld		d, a
					call	T128_BlockColAddr
;
; Check collision loop
;					
					ld		e, 0						; death flag = 0
BCS_Loop_01:		ld		a, (hl)
					and		%00001110
					cp		T128_BLOCK_SOLID
					jr		nz, BCS_Label_02			; no SOLID is detected
					ld		a, 1
					cp		b
					ld		a, T128_BLOCK_STEP			
					ret		z							; return STEP if last row
					ld		a, T128_BLOCK_SOLID
					ret									; return SOLID, other cases
BCS_Label_02:		cp		T128_BLOCK_DEATH
					jr		nz, BCS_Label_03
					ld		e, 1						; death flag = 1
BCS_Label_03:		ld		a, l
					add		a, 32
					jr		nc, BCS_Label_04
					inc		h
BCS_Label_04:		ld		l, a						; Address for next row
					inc		d
					ld		a, T128_MAX_Y
					cp		d
					jr		z, BCS_Label_05				; Check bottom border of screen area
					djnz	BCS_Loop_01		
;					
BCS_Label_05:		xor		a							
;					ld		a, T128_BLOCK_EMPTY
					cp		e
					ret		z							; return EMPTY if no death blocks detected
					ld		a, T128_BLOCK_DEATH	
					ld		(T128_DeathBlkCol), a		; Set collision detection
					ret									; return DEATH if death blocks detected
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockColDown
;
; Check block collisions under a sprite
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_EMPTY if no obstacles ahead
;	     T128_BLOCK_DEATH if sprite crashes with death blocks (and T128_DeathBlkCol is set to T128_BLOCK_DEATH)
;        T128_BLOCK_SOLID if sprite collides with a solid block
;        T128_BLOCK_STEP  if sprite collides with a step
;

T128_BlockColDown:	ld		a, (ix+8)
					and 	%00000111
					ld		a, T128_BLOCK_EMPTY
					ret		nz							; Non exact y ==> No collision
;
					ld		c, (ix+7)
					ld		a, (ix+11)
					rrca
					rrca
					rrca
					and		%00011111
					add		a, c
					ld		d, a						; d = Y
					ld		(BCD_SMC_01+1), a
					cp		T128_MAX_Y
					ld		a, T128_BLOCK_EMPTY
					ret		nc							; Bottom border of screen area ==> No collision
;					
					ld		a, (ix+6)					; a = x
					rrca
					rrca
					rrca
					and		%00011111
					ld		c, a
					ld		(BCD_SMC_04+1), a			; X = x / 8
;					
					ld		a, (ix+10)					
					rrca	
					rrca
					rrca
					and		%00011111
					ld		b, a						; b = columns to scan
					ld		a, (ix+6)
					and		%00000111
					jr		z, BCD_Label_01
					inc		b							; if non exact x, then b = width + 1
BCD_Label_01:		ld		a, b
					ld		(BCD_SMC_03+1), a			
;					
					call	T128_BlockColAddr
					ld		(BCD_SMC_02+1), a
					ld		a, h
					ld		(BCD_SMC_02+2), a
;
; Check collision loop
;					
					ld		e, 0						; death flag = 0
BCD_Loop_01:		ld		a, (hl)
					and		%00001110
					cp		T128_BLOCK_SOLID
					jr		nz, BCD_Label_02			; no SOLID is detected
					ld		a, T128_BLOCK_SOLID
					ret									; return SOLID, other cases
BCD_Label_02		cp		T128_BLOCK_PLATFORM
					jr		nz, BCD_Label_03			; no PLATFORM is detected
					ld		a, T128_BLOCK_SOLID
					ret									; return SOLID, other cases
BCD_Label_03:		cp		T128_BLOCK_DEATH
					jr		nz, BCD_Label_04
					ld		e, 1						; death flag = 1
BCD_Label_04:		inc		hl
					inc		c
					ld		a, T128_MAX_X+1
					cp		c
					jr		z, BCD_Label_05				; Check right border of screen area
					djnz	BCD_Loop_01		
;					
BCD_Label_05:		xor		a							
					cp		e
					jr		z, BCD_SMC_01
					ld		a, T128_BLOCK_DEATH
					ld		(T128_DeathBlkCol), a		; Set collision detection					
					ret									; return DEATH if death blocks detected
;
; Check step
;		
BCD_SMC_01:			ld		a, 0						
					cp		T128_MAX_Y-1
					ld		a, T128_BLOCK_EMPTY
					ret		nc							; return EMPTY if last row of screen area
BCD_SMC_02:			ld		hl, 0
					ld		de, 32
					add		hl, de
BCD_SMC_03:			ld		b, 0
BCD_SMC_04:			ld		c, 0
BCD_Loop_02:		ld		a, (hl)
					and		%00001110
					cp		T128_BLOCK_PLATFORM
					jr		z, BCD_Label_06
					cp		T128_BLOCK_SOLID
					jr		nz, BCD_Label_07
BCD_Label_06:		ld		a, T128_BLOCK_STEP
					ret									; return STEP if step detected
BCD_Label_07:		inc		hl					
					inc		c
					ld		a, T128_MAX_X+1
					cp		c
					jr		z, BCD_Label_08				; Check right border of screen area					
					djnz	BCD_Loop_02
BCD_Label_08:		ld		a, T128_BLOCK_EMPTY			
					ret									; return EMPTY if no step detected
					
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_BlockColUp
;
; Check block collisions over a sprite
;
; Input:
;	 ix = Sprite parameters
;
; Output:
;    a = T128_BLOCK_EMPTY if no obstacles ahead
;	     T128_BLOCK_DEATH if sprite crashes with death blocks (and T128_DeathBlkCol is set to T128_BLOCK_DEATH)
;        T128_BLOCK_SOLID if sprite collides with a solid block
;

T128_BlockColUp:	ld		a, (ix+8)
					and 	%00000111
					ld		a, T128_BLOCK_EMPTY
					ret		nz							; Non exact y ==> No collision
;
					ld		d, (ix+7)
					ld		a, d
					cp		T128_MIN_Y
					ld		a, T128_BLOCK_EMPTY
					ret		z							; Upper border of screen area ==> No collision
					dec		d							; d = Y
;					
					ld		a, (ix+6)					; a = x
					rrca
					rrca
					rrca
					and		%00011111
					ld		c, a						; X = x / 8
;					
					ld		a, (ix+10)					
					rrca	
					rrca
					rrca
					and		%00011111
					ld		b, a						; b = columns to scan
					ld		a, (ix+6)
					and		%00000111
					jr		z, BCU_Label_01
					inc		b							; if non exact x, then b = width + 1
;					
BCU_Label_01:		call	T128_BlockColAddr
;
; Check collision loop
;					
					ld		e, 0						; death flag = 0
BCU_Loop_01:		ld		a, (hl)
					and		%00001110
					cp		T128_BLOCK_SOLID
					jr		nz, BCU_Label_02			; no SOLID is detected
					ld		a, T128_BLOCK_SOLID
					ret									; return SOLID, other cases
BCU_Label_02:		cp		T128_BLOCK_DEATH
					jr		nz, BCU_Label_03
					ld		e, 1						; death flag = 1
BCU_Label_03:		inc		hl
					inc		c
					ld		a, T128_MAX_X+1
					cp		c
					jr		z, BCU_Label_04				; Check right border of screen area
					djnz	BCU_Loop_01		
;					
BCU_Label_04:		xor		a							
					cp		e
					ld		a, T128_BLOCK_EMPTY			
					ret		z							; return EMPTY
					ld		a, T128_BLOCK_DEATH		
					ld		(T128_DeathBlkCol), a		; Set collision detection										
					ret									; return DEATH if death blocks detected
