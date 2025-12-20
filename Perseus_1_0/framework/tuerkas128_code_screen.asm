;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S C R E E N   P R O C E S S I N G
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _BEGIN_CODE_SCREEN
_BEGIN_CODE_SCREEN:



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ScrEntities
;
; Create entities from Bank 2 screen buffer
;
; Input:
;   ix = Screen entities data
;   hl = T128_SDRAM2_End2		Ending address of screen entities data
;

T128_ScrEntities:	ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = Ending address of screen entities data
SE_Loop_01:			ld		a, e
					cp		ixl
					jr		nz, SE_Label_01
					ld		a, d
					cp		ixh
					ret		z							; If ix (current address) = de (Screen end), then return
SE_Label_01:		push	de
					ld		a, (ix)
					and		%01111111					; Skip inactivity entity bit
					inc		ix
					push	ix
;
; Screen Areas
;					
					cp		T128_ENTITY_SCR_AREA
					jr		nz, SE_Label_02
					call	T128_SA_CreateB0
					jr		SE_Label_07
;
; Animated blocks
;
SE_Label_02:		cp		T128_ENTITY_ANIM_BLK
					jr		nz, SE_Label_03
					call	T128_AB_CreateB0
					jr		SE_Label_07
;
; Breath right
;
SE_Label_03:		cp		T128_ENTITY_BREATHR
					jr		nz, SE_Label_04
					ld		e, %10000000
					call	T128_BA_CreateB0
					jr		SE_Label_07
;
; Breath left
;
SE_Label_04:		cp		T128_ENTITY_BREATHL
					jr		nz, SE_Label_05
					ld		e, %00000000
					call	T128_BA_CreateB0
					jr		SE_Label_07
;
; Sprite
;
SE_Label_05:		cp		T128_ENTITY_SPRITE
					jr		nz, SE_Label_06
					call	T128_SPR_CreateB0
					jr		SE_Label_07
;
; Portal
;
SE_Label_06:		cp		T128_ENTITY_PORTAL
					jr		nz, SE_Label_07
					call	T128_PRTL_CreateB0
;					
SE_Label_07:		pop		ix
					ld		bc, 5
					add		ix, bc
					pop		de
					jp		SE_Loop_01
					
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ScrDraw
;
; Draw current screen on RAM 5 
;
; Screen data are in Bank 2. Block definitions are in Bank 5 ($5b00 and higher)
; 
; Input:
;   hl = T128_SDRAM2_End1		Ending address of screen data
;   ix = T128_ScreenDataRAM2	Screen data and screen entities data
;
; Ourput:
;   ix = Screen entities data
;
; Every screen element has a 3-byte entry in T128_ScreenDataRAM2: XXXXXYYY YYSDCCCC BBBBBBBB  
; Where:
;		XXXXX    = X position (column)
;		YYYYY    = Y position (row)
;		S        = 1 - Superblock
;			     = 0 - Block
;		D        = 0 - Down growth
;			     = 1 - Right growth
;		CCCC     = Copies (minus 1): range 1 to 16
;       BBBBBBBB = Block (or superblock) number
;

T128_ScrDraw:		ld		a, (ix)						; a = screen info
					ld		(T128_ScreenInfo), a
					inc		ix
					
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = Ending address of screen data
SD_Loop_01:			ld		a, e
					cp		ixl
					jr		nz, SD_Label_01
					ld		a, d
					cp		ixh
					ret		z							; If ix (current address) = de (Screen entities descriptor address), then return
SD_Label_01:		push	de
					push	ix
					ld		a, (ix)
					ld		l, a						; l = a = XXXXXYYY
					srl		l
					srl		l
					srl		l							; l = 000XXXXX
					and		%00000111
					ld		h, a						; h = 00000YYY
					ld		a, (ix+1)
					ld		e, a						; e = a = YYSDCCCC
					sla		e
					rl		h
					sla		e							; e = SDCCCC00
					rl		h							; h = 000YYYYY
					srl		e
					srl		e							; e = 00SDCCCC
					ld		a, e
					and		%00011111		
					ld		e, a						; e = 000DCCCC
					ld		d, (ix+2)					; d = BBBBBBBB
					ld		a, (ix+1)					
					and		%00100000					; a = block type
					jr		z, SD_Label_02				
					call	DrawSuperBlock
					jr		SD_Label_03
SD_Label_02:		call	DrawBlock
SD_Label_03:		pop		ix
					pop		de
					inc		ix
					inc		ix
					inc		ix
					jr		SD_Loop_01					; Next screen element


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DrawSuperBlock
;
; Draw CCCC copies of a superblock
; 
; Input:
;   l = X coordinate (0-31)
;	h = Y coordinate (0-23)
;	e = Growth direction for repetitions and number of copies minus 1 (format DCCCC)
;	d = Superblock number (0 - 255)
; 
DrawSuperBlock:		push	de
					push	hl
					ld		hl, T128_SuperBlockPtrs
					ld		a, d
					pop		de							; e = X coordinate       d = Y coordinate
					ld 		b, 0
					ld		c, a
					sla		c
					jr 		nc, DSB_Label_01
					inc		b
DSB_Label_01:		add		hl, bc              	
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = superblock definition
;
; Get number of copies and growth direction
;
					pop		hl							; l = Growth direction for repetitions and number of copies minus 1 (format DCCCC)
					ld		a, l
					ld		h, a
					and		T128_BLOCK_GROWTH_R		
					ld		l, a						; l = Groth direction 000D0000
					ld		a, h
					and		%00001111
					inc		a							; a = NUmber of copies
;
; Get DeltaX and DeltaY
; 
					ex		af, af'
					ld		a, l
					and		T128_BLOCK_GROWTH_R
					ld		a, (bc)						; a' = DeltaX minus 1 and DeltaY minus 1 (format XXXXYYYY)
					jr		z, DSB_Label_02
					rrca							
					rrca							
					rrca							
					rrca							
DSB_Label_02:		and		%00001111									
					inc		a							; a' = DeltaX or DeltaY. Range 1 to 16
					ex		af, af'
					inc		bc							; Superblock definition
;
; Superblock loop
;
; a  = number of copies
; l  = growth address  000D0000
; bc = superblock definition
; e  = X coordinate (0-31)
; d  = Y coordinate (0-23)
; a' = DeltaX or DeltaY
;
DSB_Loop_01:		push	af							
					push	bc	
					push	de
					push	hl
					ex		af, af'
					push	af
					ex		af, af'
;
; Render superblock elements
;					
DSB_Loop_02:		ld		a, (bc)
					inc		a
					jr		z, DSB_Label_05				; if equal to $ff, no more elements. XXXXXYYY will never be equal to $ff
					dec		a
					push	de							; save superblock coordinates
					ld		l, a						; l = a = XXXXXYYY
					srl		l
					srl		l
					srl		l							; l = 000XXXXX
					and		%00000111
					ld		h, a						; h = 00000YYY
					ld		a, l
					add		a, e					
					ld		l, a						; l = 000XXXXX + superblock X coordinate
					inc 	bc
					ld		a, (bc)
					ld		e, a						; e = a = YYSDCCCC
					sla		e
					rl		h
					sla		e							; e = SDCCCC00
					rl		h							; h = 000YYYYY
					ld		a, h
					add		a, d
					ld		h, a						; h = 000YYYYY + superblock Y coordinate
					srl		e
					srl		e							; e = 00SDCCCC
					ld		a, e
					push	af
					and		%00011111		
					ld		e, a						; e = 000DCCCC					
					inc		bc
					ld		a, (bc)
					ld		d, a						; d = subblock or subsuperblock number
					inc		bc
					pop		af							; a = 00SDCCCC
					push	bc
					and		%00100000					; a = block type
					jr		z, DSB_Label_03
					call	DrawSuperBlock				; Here goes another superblock. Recursive call
					jr		DSB_Label_04
DSB_Label_03:		call	DrawBlock					; Here goes a block.
DSB_Label_04:		pop		bc
					pop		de							; Restore superblock coordinates
					jr		DSB_Loop_02
;
DSB_Label_05:		ex		af, af'
					pop		af
					ex		af, af'
					pop		hl
					pop		de
					pop		bc
					pop		af
					dec		a							; Decrement number of copies
					ret		z							
					push	af						
					ld		a, l
					and		T128_BLOCK_GROWTH_R
					jr		z, DSB_Label_06
					ex		af, af'					
					push	af
					add		a, e
					ld		e, a						; Add DeltaX
					pop		af
					jr		DSB_Label_07
DSB_Label_06:		ex		af, af'
					push	af
					add		a, d
					ld		d, a						; Add DeltaY
					pop		af		
DSB_Label_07:		ex		af, af'
					pop		af
					jr		DSB_Loop_01

					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DrawBlock
;
; Draw CCCC copies of a block
; 
; Input:
;   l = X coordinate (0-31)
;	h = Y coordinate (0-23)
;	e = Growth direction for repetitions and number of copies minus 1 (format DCCCC)
;	d = Block number (0 - 255)
; 
DrawBlock:			push	hl
					ld		hl, T128_BlockPtrs			; Calcular la dirección de definición del bloque
					ld 		b, 0
					ld		c, d
					sla		c
					jr 		nc, DB_Label_01
					inc		b
DB_Label_01:		add		hl, bc              		; hl = block pointer addres
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = block address
					push	bc
					ld		a, e					
					and		%00001111				
					inc		a
					ld		b, a						; b = number of copies
					ld		a, e
					and		T128_BLOCK_GROWTH_R
					ld		(T128_BackupByte2), a		; T128_BackupByte2 = Growth direction
					pop		ix							; ix = block address
					pop		hl							; h = Y		l = X
					ld		a, h					
					cp		T128_MAX_Y
					ret		nc							; Finish if Y is out of the bottom border of the screen area
					ld		a, l
					cp		T128_MAX_X+1
					ret		nc							; Finish if X is out of the right border of the screen area
DB_Loop_01:			push	bc
					ld		b, (ix)						; b = block properties
					ld		a, (T128_BackupByte2)		; a = growth direction
					or		a		
					jr		nz, DB_Label_03
					ld		a, h						; Block grows downwards
					cp		T128_MAX_Y
					jr		c, DB_Label_02				 
					pop		bc
					ret									; Finish if Y is out of the bottom border of the screen area
DB_Label_02:		push	hl						
					push	bc
					call	DrawSingleBlock
					pop		bc
					pop		hl
					ld		a, b
					and		%00110000
					rrca							
					rrca							
					rrca							
					rrca												
					inc		a
					ld		e, a						; e = block height
					ld		a, h
					add		a, e
					ld		h, a						; h = new Y
					pop		bc							
					djnz	DB_Loop_01
					ret
DB_Label_03:		ld		a, l						; Block grows rightwards
					cp		T128_MAX_X+1
					jr		c, DB_Label_04				
					pop		bc
					ret									; Finish if X is out of the right border of the screen area
DB_Label_04:		push	hl						
					push	bc
					call	DrawSingleBlock
					pop		bc
					pop		hl
					ld		a, b
					and		%11000000
					rlca
					rlca
					inc		a
					ld		d, a						; d = block width
					ld		a, l
					add		a, d
					ld		l, a						; l = new X
					pop		bc							
					djnz	DB_Loop_01			
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DrawSingleBlock
;
; Draw a single block on sceen (RAM 5)
; Update Hardness map and Depth map
; 0000...
; Input:
; 	l  =  X (0-31)
;	h  =  Y (0-23)
;   b = block properties in the format WWHHSSSZ
;		WW 	= Width - 1 (columns). Range 1 to 4
;       HH 	= Height - 1 (rows). Range 1 to 4
;		SSS = Hardness: 111 - Merged block   100 - Ladder   011 - Death   010 - Floor/Solid   001 - Platform   000 - Empty
;       Z 	= Depth: 1 Foreground / 0 Background
;	ix = dirección de definición del bloque
;
; If SSS = 111 (merged block), block data is merged with screen by ANDind both values. It can be used to blend blocks in backlighted screens
; If SSS = 111 (merged block), hardness and depth data is no modified.
;
DrawSingleBlock:	ld		a, b
					and		%00001111
					ld		(T128_BackupByte1), a		; Save Hardness / Depth bits 
					ld		a, b
					and		%11110000
					rrca
					rrca
					rrca
					rrca
					exx
					ld		hl, T128_BlockGraphicSize
					ld		e, a
					ld		d, 0
					add		hl, de					
					ld		e, (hl)
					push	ix
					pop		hl
					inc		hl
					add		hl, de						; hl' = Block attributes
					exx
					ld		a, h
					and		%11111000
					add		a, $40
					ld		d, a
					ld		a, h
					and		7
					rrca
					rrca
					rrca
					add		a, l
					ld		e, a						; de = screen address
;
					ld		a, b
					and		%00110000
					rrca							
					rrca							
					rrca							
					rrca							
					inc 	a
					ld		c, a					
					exx
					ld		c, a						; c' = height in rows
					ld		e, c						; e' = c'
					add		a, a
					add		a, a
					add		a, a
					ld		b, a						; b' = height in scanlines
					ld		d, a						; d' = b'
					exx								
;
					ld		a, b
					and		%11000000
					rlca
					rlca
					inc		a
					ld		b, a						; b = width in columns
;
					push	ix
					pop		hl
					inc		hl							; hl = graphic data
;
DSiB_Loop_01:		push	de							; Save column address
DSiB_Loop_02:		ld		a, (T128_BackupByte1)
					and		%00001110
					cp		T128_BLOCK_MERGED
					jr		nz, DSiB_Label_01
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Merged block 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					push	bc
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld		(de), a						; draw scanline 0
					inc		hl			
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 1
					inc		hl				
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 2
					inc		hl				
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 3
					inc		hl				
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 4
					inc		hl				
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 5
					inc		hl				
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 6
					inc		hl				
					inc		d
					ld		c, (hl)
					ld		a, (de)
					and		c
					ld 		(de), a						; draw scanline 7
					inc		hl				
					inc		d
					pop		bc
					jr		DSiB_Label_02
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Non-merged block
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DSiB_Label_01:		ld		a, (hl)
					ld 		(de), a						; draw scanline 0
;
; At scanline 0, draw attribute
;
					ld		a, d
					rrca
					rrca
					rrca
					and		3
					or		$58
					push	de
					ld		d, a						; de = Attribute address
					exx
					ld		a, (hl)						; Get attribute from block attributes
					inc		hl
					exx
					ld		(de), a
;
; At scanline 0, save hardness and depth information
;
					ld		a, d
					xor		$58							; Quick way to get the hardness/depth map address,
					or		T128_MapHD_PAGE				; granted that T128_MapHD_PAGE has the form $x8
					ld		d, a						; de = hardness/depth map address
					ld		a, (T128_BackupByte1)
					ld		(de), a				
;
; Draw scanlines 1-7
;
					pop 	de						
					inc		hl			
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 1
					inc		hl				
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 2
					inc		hl				
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 3
					inc		hl				
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 4
					inc		hl				
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 5
					inc		hl				
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 6
					inc		hl				
					inc		d
					ld		a, (hl)
					ld 		(de), a						; draw scanline 7
					inc		hl				
					inc		d
;
DSiB_Label_02:		exx
					ld		a, d
					sub		8
					ld		d, a						; 8 scanlines have passed the way
					dec		e							; 1 row have passed the way
					exx
					dec		c
					jr		z, DSiB_Label_04			; If last row, go to next column
;
; Calculate next row screen address
;				
					ld		a, e
					add		a, $20
					ld		e, a
					jr		c, DSiB_Label_03
					ld		a, d
					sub		$08
					ld		d, a
DSiB_Label_03:		ld		a, d
					and		$18
					push	bc
					ld		c, e
					srl		c
					srl		c
					srl		c
					srl		c
					srl		c
					or		c
					pop		bc
					cp		T128_MAX_Y					
					jr		nc, DSiB_Label_04			; ¿Reached bottom border of the screen area?
					jp		DSiB_Loop_02				; Next row
DSiB_Label_04:		dec		b
					jr		z, DSiB_Label_06			; If last column, go to end
;
; Calculate next column screen address
;
					pop		de							; Restore address of current column
					inc		e
					ld		a, e
					dec		a					
					and		%00011111
					cp		T128_MAX_X
					ret		z							; ¿Reached right border of the screen area?
					ld		a, l
					exx
					push	de
					ld		d, 0
					add		hl, de						; Calculate next hl', by adding the number of rows not drawn
					pop		de						
					add		a, d						; Calculate next hl, by adding the number of scanlines not drawn
					exx	
					jr		nc, DSiB_Label_05
					inc		h
DSiB_Label_05:		ld		l, a
;
; Restore height in rows and in scanlines
;
					exx
					ld		a, c
					ld		e, c						; height in rows
					ld		d, b						; height in scanlines
					exx
					ld		c, a						; height in rows
					jp		DSiB_Loop_01				; Next column
DSiB_Label_06:		pop		de						
					ret