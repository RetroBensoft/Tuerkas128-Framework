;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; R E N D E R I N G   F U N C T I O N S 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_RENDER
_BEGIN_CODE_RENDER


;
; Animated Blocks rendering routines
;
T128_AB_RenderTable	defw  AnimatedBlock_2x1, AnimatedBlock_2x2, AnimatedBlock_1x2, AnimatedBlock_1x1, AnimatedBlock_1x4, AnimatedBlock_4x1, AnimatedBlock_3x1, AnimatedBlock_1x3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AB_ProcessATTR
;
; Process AB attribute:
;
;  if bit 7 of byte 4 in AB definition table is 1 (T128_AB_KEEPATTR), then
;     use AB attribute
;  else
;     if PAPER on screen (bewloow AB) is black then
;        Mix screen FLASH + PAPER + AB BRIGHT + INK
;     else
;        Mix screen FLASH + BRIGHT + PAPER + AB INK
;     end if
;  end if
;
; Input:
;   c  = AB attribute
;   de = attribute address on screen 
;
; output
;   a  = processed attribute
;

AB_ProcessATTR:		ld		a, 0
					bit		7, a
					ld		a, c
					ret		nz							; If bit 7 of byte 4 in AB definition table is 1, then use AB attribute
					ld		a, (de)
					and		%00111000
					jr		z, ABPA_Label_01
					ld		a, c
					and		%00000111					; Only INK from AB attribute
					ld		c, a
					ld		a, (de)
					and		%11111000					; Mix screen FLASH + BRIGHT + PAPER + AB INK
					or		c
					ret
ABPA_Label_01:		ld		a, c
					and		%01000111					; Only INK from AB attribute
					ld		c, a
					ld		a, (de)
					and		%10111000					; Mix screen FLASH + PAPER + AB BRIGHT + INK
					or		c
					ret					


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AB_RenderNx1
;
; Render graphic of animated block N wide x 1 height
;
; Input:
;   c  = N
;   hl = Current phase graphic address
;   de = Screen address
;					

AB_RenderNx1:		ld		b, 4
ABRNx1_Loop_01:		push	bc
ABRNx1_Loop_02:		ld		a, (hl)						; Line 1
					ld		(de), a
					inc		hl
					inc		de
					dec		c
					jr		nz, ABRNx1_Loop_02
					dec		de
					inc		d
					pop		bc
					push	bc
ABRNx1_Loop_03:		ld		a, (hl)						; Line 2
					ld		(de), a
					inc		hl
					dec		de
					dec		c
					jr		nz, ABRNx1_Loop_03
					inc		de
					inc		d
					pop		bc					
					djnz	ABRNx1_Loop_01
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AB_Render1x1
;
; Render graphic of animated block 1 wide x 1 height
;
; Input:
;   hl = Current phase graphic address
;   de = Screen address
;					

AB_Render1x1:		ld		a, (hl)						; Column 1 line 1
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 2
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 3
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 4
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 5
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 6
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 7
					ld		(de), a
					inc		hl
					inc		d
					ld		a, (hl)						; Column 1 line 8
					ld		(de), a
					inc		hl
					inc		d
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_4x1
;
; Render animated block 4 wide x 1 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;

AnimatedBlock_4x1:	ld		b, 4
					jr		AnimatedBlock_Nx1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_3x1
;
; Render animated block 3 wide x 1 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;

AnimatedBlock_3x1:	ld		b, 3
					jr		AnimatedBlock_Nx1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_2x1
;
; Render animated block 2 wide x 1 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;

AnimatedBlock_2x1:	ld		b, 2
					jr		AnimatedBlock_Nx1

					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_Nx1
;
; Render animated block N wide x 1 height
;
; Input:
;   b   = N
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;

AnimatedBlock_Nx1:	ld		a, b
					exx
;
; Graphic
;
					push	bc
					push	de
					ld		c, a
					call	AB_RenderNx1
					pop		de
					pop		bc
;
; Attribute
;					
					exx
					ld		a, b
					exx
					ld		l, a
					ld		h, a
					ex		af, af'
					ld		d, a
					ex		af, af'					
					
					call	AB_ProcessATTR				; Procees attribute
					
ABNx1_Loop_01:		ld		(de), a
					inc		de
					dec		l
					jr		nz, ABNx1_Loop_01
					dec		de
;
; Hardness and depth
;					
					ld		a, d
					xor		$58							; Quick way to get the hardness/depth map address,
					or		T128_MapHD_PAGE				; granted that T128_MapHD_PAGE has the form $x8
					ld		d, a						; de = hardness/depth map address
					ld		a, b
ABNx1_Loop_02:		ld		(de), a
					dec		de
					dec		h
					jr		nz, ABNx1_Loop_02
					exx
					ret
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_2x2
;
; Render animated block 2 wide x 2 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;

AnimatedBlock_2x2:	exx
;
; Graphic
;
					push	bc
					push	de
					ld		c, 2
					call	AB_RenderNx1				; Render first row
					ld		a, e						; Get second row address
					add		a, $20						
					ld		e, a						
					jr		c, AB2x2_Label_01			
					ld		a, d						
					sub		$08							
					ld		d, a									
AB2x2_Label_01:		ld		c, 2
					call	AB_RenderNx1				; Render second row
					pop		de
					pop		bc
;
; Attribute
;					
					ex		af, af'
					ld		d, a
					ex		af, af'
					push	de
					call	AB_ProcessATTR				; Procees attribute					
					ld		c, a
AB2x2_Label_02		ld		(de), a
					inc		de
					ld		(de), a
					ld		a, 32
					add		a, e
					jr		nc, AB2x2_Label_03
					inc		d
AB2x2_Label_03:		ld		e, a
					ld		a, c
					ld		(de), a
					dec		de
					ld		(de), a
					pop		de					
;
; Hardness and depth
;
					ld		a, d
					xor		$58							; Quick way to get the hardness/depth map address,
					or		T128_MapHD_PAGE				; granted that T128_MapHD_PAGE has the form $x8
					ld		d, a						; de = hardness/depth map address
					ld		a, b
					ld		(de), a
					inc		de
					ld		(de), a
					ld		a, 32
					add		a, e
					jr		nc, AB2x2_Label_04
					inc		d
AB2x2_Label_04:		ld		e, a
					ld		a, b
					ld		(de), a
					dec		de
					ld		(de), a					
					exx
					ret					
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_1x4
;
; Render animated block 1 wide x 4 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;
AnimatedBlock_1x4:	ld		b, 4
					jr		AnimatedBlock_1xN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_1x3
;
; Render animated block 1 wide x 3 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;
AnimatedBlock_1x3:	ld		b, 3
					jr		AnimatedBlock_1xN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_1x2
;
; Render animated block 1 wide x 2 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;
AnimatedBlock_1x2:	ld		b, 2
					jr		AnimatedBlock_1xN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_1x1
;
; Render animated block 1 wide x 1 height
;
; Input:
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;

AnimatedBlock_1x1:	ld		b, 1
					jr		AnimatedBlock_1xN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AnimatedBlock_1xN
;
; Render animated block 1 wide x N height
;
; Input:
;   b   = N
;   hl' = Current phase graphic address
;   de' = Screen address
;   a'  = Attribute address (high byte)
;   c'  = Attribute
;   b'  = Hardness & Depth
;
AnimatedBlock_1xN:	exx
					push	de
					exx
;
; Graphic
;
					push	bc
AB1xN_Loop_01:		exx
					call	AB_Render1x1				; Render first row
					ld		a, e						; Get second row address
					add		a, $20						
					ld		e, a						
					jr		c, AB1xN_Label_01			
					ld		a, d						
					sub		$08							
					ld		d, a
AB1xN_Label_01:		exx
					djnz	AB1xN_Loop_01
					pop		bc
					exx
					pop		de
;
; Attribute
;					
					ex		af, af'
					ld		d, a
					ex		af, af'	
					push	de
					call	AB_ProcessATTR				; Procees attribute					
					ld		c, a
AB1xN_Label_02:		exx
					push	bc
AB1xN_Loop_02:		exx
					ld		a, c
					ld		(de), a
					ld		a, 32
					add		a, e
					jr		nc, AB1xN_Label_03
					inc		d
AB1xN_Label_03:		ld		e, a
					exx
					djnz	AB1xN_Loop_02
					pop		bc
					exx
					pop		de
;
; Hardness and depth
;					
					ld		a, d
					xor		$58							; Quick way to get the hardness/depth map address,
					or		T128_MapHD_PAGE				; granted that T128_MapHD_PAGE has the form $x8
					ld		d, a						; de = hardness/depth map address
					exx
AB1xN_Loop_03:		exx
					ld		a, b
					ld		(de), a
					ld		a, 32
					add		a, e
					jr		nc, AB1xN_Label_04
					inc		d
AB1xN_Label_04:		ld		e, a
					exx	
					djnz	AB1xN_Loop_03
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_RenderAniBlcks
;
; Render animated blocks in current screen
;
; AB's CONTROL FLAG is used to check whether AB is to be rendered:
;
;   If CONTROL FLAG (1bitFlag) = T128_1BITFLAG_ff then
;      Render 
;   else
;     if (1bitFlag) is set then
;       Render
;     end if
;   end if
;

T128_RenderAniBlcks ld		a, (T128_ScreenAnimBlkNum)
					or		a
					ret		z							; No animated blocks
					ld		d, a
					xor		a
					call	T128_SetBank				; Animated Block definition table is in Bank 0
					ld		ix, T128_ScreenAnimBlk
					ld		b, d
RAB_Loop_01:		push	bc
					ld		a, (ix+15)					; a = CONOTROL FLAG (1bitFlag)
					cp		T128_1BITFLAG_ff
					jr		z, RAB_Label_00
					call	T128_Check1bFlagB0
					jr		z, RAB_Label_04
RAB_Label_00:		ld		l, (ix+6)
					ld		h, (ix+7)
					push	hl
					pop		iy							; iy = Animated Block definition table
					ld		a, (iy+1)					; Rendering routine					
					add		a, a
					ld		e, a
					ld		d, 0
					ld		hl, T128_AB_RenderTable
					add		hl, de
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						
					ex		de, hl						; hl = animated block rendering routine
					exx
					push	iy
					pop		hl							; Animated block table pointer
					ld		e, (hl)
					inc		e							; N phases + 1 stop phase					
					inc		hl							; number of phases
					inc		hl							; rendering routine
					inc		hl							; size of graphic
					inc		hl							; type of animation cycle
					inc		hl							; class of animated block
;					ld		e, (iy)
;					inc		e							; N phases + 1 stop phase
					ld		c, (ix+3)					; current phase
					ld		b, 0
					add		hl, bc
;
; Calculate attribute
; 
					ld		c, (hl)						; c' = PHASE ATTRIBUTE
					ld		a, (iy+4)					; a = Byte 4 in AB definition table
					ld		(AB_ProcessATTR+1), a			; SMC for attribute processing
					
;					bit		7, (iy+4)
;					jr		nz, RAB_Label_01			; If bit 7 of byte 4 in AB definition table is 0, then use AB attribute
;					ld		a, (T128_ScreenInfo)
;					and		%01111000
;					or		a
;					jr		z, RAB_Label_01				; If Screen PAPER = 0, then use AB Attribute
;					ex		af, af'						; Otherwise, use Screen PAPER
;					ld		a, c
;					and		%10000111
;					ld		c, a
;					ex		af, af'
;					or		c
;					ld		c, a
;					
RAB_Label_01:		ld		d, b
					add		hl, de
					ld		b, (hl)						; b' = PHASE HARDNESS & DEPTH
					ld		l, (ix+11)
					ld		h, (ix+12)					; hl' = CURRENT PHASE GRAPHIC ADDRESS
					ld		e, (ix+0)
					ld		d, (ix+1)					; de' = SCREEN ADDRESS
					exx
					ex		af, af'
					ld		a, (ix+2)					; a' = ATTRIBUTE ADDRESS (higher value)
					ex		af, af'
					ld		a, (T128_LastValue7ffd)
					and		%00001000					; equal to 0 if hidden screen = RAM 7
					jr		nz, RAB_Label_02
					ld		a, 7
					call	T128_SetBank				; select bank 7 in case hidden screen = RAM 7
RAB_Label_02:		ld		de, RAB_Label_03
					push	de
					jp		(hl)						; call (hl)
RAB_Label_03:		ld		a, (T128_LastValue7ffd)
					and		%00001000					; equal to 0 if hidden screen = RAM 7
					jr		nz, RAB_Label_04
					xor		a
					call	T128_SetBank				; select bank 0 again in case hidden screen = RAM 7
RAB_Label_04:		ld		a, (ix+1)
					xor		%10000000					; Alternate graphic RAM 5 address ($4000) / RAM 7 addrees ($c000) 
					ld		(ix+1), a
					ld		a, (ix+2)
					xor		%10000000					; Alternate attribute RAM 5 address ($5b00) / RAM 7 addrees ($db00)
					ld		(ix+2), a
RAB_Label_05:		ld		bc, T128_AB_TABLE_SIZE
					add		ix, bc						; Next animated block
					pop		bc
					dec		b
					jp		nz,	RAB_Loop_01
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_RenderSprites
;
; Render sprites
;
; Bit 6 of byte 2 of sprite is used to check whether sprite has active data or not.
; A sprite has not active data when sprite has been killed and its memory structura is saved as a gap for further use.
; This is managed by SPR_GetSprBuffer and SPR_FreeSprBuffer
; 
; Input:
;   c = background / foreground
;		T128_SPR_BACKGROUND1		"Backmost"
;		T128_SPR_BACKGROUND2
;		T128_SPR_FOREGROUND1
;		T128_SPR_FOREGROUND2		"Foremost"
;

T128_RenderSprites:	xor		a
					ld		e, c
					call	T128_SetBank				; Set RAM 0 (to access T128_ScreenSprLast)
					ld		c, e
					ld		a, (T128_ScreenSprLast)
					or		a
					ret		z
					ld		b, a
					ld		ix, T128_ScreenSprites
RSS_Loop_01:		push	bc
					bit		0, (ix+21)
					jr		nz, RSS_Label_01			; Do not render hidden sprites
					ld		a, (ix+2)
					bit		6, a
					jr		z, RSS_Label_01				; Render only active sprites
					bit		3, a
					jr		nz, RSS_Label_01			; Do not render _CHILD_ sprites
					and		%00000110					; Background / Foreground		
					pop		bc
					push	bc
					cp		c
					jr		nz, RSS_Label_01			; Render only sprites of current background / foreground
					call	RSS_Label_04				; Render parent sprite
					ld		e, (ix+22)
					ld		d, (ix+23)
					call	RSS_Label_02				; Render child sprite #1
					ld		e, (ix+24)
					ld		d, (ix+25)
					call	RSS_Label_02				; Render child sprite #2
;
; Next sprite
;
					
RSS_Label_01:		ld		bc, T128_SPR_TABLE_SIZE
					add		ix, bc
					pop		bc
					djnz	RSS_Loop_01
					ret
;
; Render child sprite
; 					
RSS_Label_02:		xor		a							
					cp		d
					jr		nz, RSS_Label_03
					cp		e
					ret		z							; there's no child sprite
RSS_Label_03:		push	ix
					ld		ixl, e
					ld		ixh, d
					call	RSS_Label_04				; Render child sprite
					pop		ix
					ret
;
; Render sprite
;
RSS_Label_04:		xor		a
					call	T128_SetBank				; Set RAM 0
					call	T128_SA_CheckB0				; Check screen areas
					jp		T128_RenderSprite			; Render sprite for next frame in hidden screen
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_RenderMainChar
;
; Render main character
;

T128_RenderMainChar	xor		a
					call	T128_SetBank				; Set RAM 0
					ld		ix, T128_MainChar
					call	T128_SA_CheckB0
					call	T128_RenderSprite			; Render Main Char for next frame in hidden screen
					xor		a
					call	T128_SetBank				; Set RAM 0					
					ld		ix, T128_MainCharAux
					call	T128_SA_CheckB0
					call	T128_RenderSprite			; Render Main Char Aux for next frame in hidden screen
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_RenderAll
;
; Render animated blocks & sprites & main char
;

T128_RenderAll:		call	T128_RenderAniBlcks			; Render animated blocks
;
					ld		c, T128_SPR_BACKGROUND1
					call	T128_RenderSprites			; Render background 1 sprites
;					
					ld		c, T128_SPR_BACKGROUND2
					call	T128_RenderSprites			; Render background 2 sprites		
;					
					call	T128_RenderMainChar			; Render main character
;					
					ld		c, T128_SPR_FOREGROUND1
					call	T128_RenderSprites			; Render foreground 1 sprites
;					
					ld		c, T128_SPR_FOREGROUND2					
					jp		T128_RenderSprites			; Render foreground 2 sprites