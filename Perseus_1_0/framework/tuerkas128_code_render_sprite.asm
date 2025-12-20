;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; S P R I T E   R E N D E R I N G 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_RENDER_SPRITE
_BEGIN_CODE_RENDER_SPRITE:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_InitSpriteVars
;
; Init variables used in sprite rendering algorithm
;

T128_InitSpriteVars: xor	a								
					ld		(T128_OccupiedCellsRAM7), a
					ld		hl, T128_CellsBufferRAM7
					ld		(T128_OccCellsStackRAM7), hl
					ld		(T128_OccCellsAttribRAM7), a
					ld		hl, T128_CellsAttrRAM7
					ld		(T128_OccCellsAttrStRAM7), hl
					xor		a
					call	T128_SetBank				; Set RAM 0 before init RAM 5 variables
					xor		a								
					ld		(T128_OccupiedCellsRAM5), a
					ld		hl, T128_CellsBufferRAM5
					ld		(T128_OccCellsStackRAM5), hl
					ld		(T128_OccCellsAttribRAM5), a
					ld		hl, T128_CellsAttrRAM5
					ld		(T128_OccCellsAttrStRAM5), hl					
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ClearSprites
;
; Clear all sprites in HIDDEN screen using cells buffer
;
T128_ClearSprites:		ld		a, (T128_LastValue7ffd)
						and		%00001000					; equal to 0 if hidden screen = RAM 7
						jr		nz, CS_Label_01
;						
						ld		a, 7					
						call	T128_SetBank			
						ld		hl, T128_OccupiedCellsRAM7	; hidden screen = RAM 7 (Occupied cells are in RAM 2)
						ld		ix, T128_OccCellsStackRAM7							
						jr		CS_Label_02
;						
CS_Label_01:			xor		a						
						call	T128_SetBank			
						ld		hl, T128_OccupiedCellsRAM5	; hidden screen = RAM 5 (Occupied cells are in RAM 0)
						ld		ix, T128_OccCellsStackRAM5							
;						
CS_Label_02:			ld		a, (hl)						; a = occupied cells
						or		a
						ret		z							; Return if there is no occupied cells
						ld		l, (ix)
						ld		h, (ix+1)					; get occupied cells stack
						ld		de, T128_BYTES_CELL
						add		hl, de						; Fake occupied cells stack
						ld		b, a						; Number of occupied cells
CS_Loop_01:				ld		de, T128_BYTES_CELL*2
						and		a
						sbc		hl, de						; Cells must be restored backwards
						ld		e, (hl)
						inc		hl
						ld		d, (hl)						; de = screen address
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 0
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 1
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 2
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 3
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 4
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 5
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 6
						inc		d
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore scanline 7
						inc		hl
						djnz	CS_Loop_01
;
; Reset variables 
;
						ld		a, (T128_LastValue7ffd)	
						and		%00001000					; equal to 0 if hidden screen = RAM 7
						jr		nz, CS_Label_03
						ld		de, T128_OccupiedCellsRAM7	; hidden screen = RAM 7
						ld		hl, T128_OccCellsStackRAM7
						jr		CS_Label_04
CS_Label_03:			ld		de, T128_OccupiedCellsRAM5	; hidden screen = RAM 5
						ld		hl, T128_OccCellsStackRAM5				
CS_Label_04:			xor		a							
						ld		(de), a						; Occupied cells = 0
						inc		de
						ld		(hl), e				
						inc		hl
						ld		(hl), d						; Occupied Cells Stack = T128_CellsBufferRAM5 or T128_CellsBufferRAM7 
						ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ClearSpritesAttr
;
; Clear all sprites attributes in HIDDEN screen using cells attribute buffer
;

T128_ClearSpritesAttr:	ld		a, (T128_LastValue7ffd)
						and		%00001000					; equal to 0 if hidden screen = RAM 7
						jr		nz, CSA_Label_01
;						
						ld		a, 7					
						call	T128_SetBank			
						ld		hl, T128_OccCellsAttribRAM7	; hidden screen = RAM 7 (Occupied cells are in RAM 2)
						ld		ix, T128_OccCellsAttrStRAM7
						jr		CSA_Label_02
;
CSA_Label_01:			xor		a						
						call	T128_SetBank			
						ld		hl, T128_OccCellsAttribRAM5	; hidden screen = RAM 5 (Occupied cells are in RAM 0)
						ld		ix, T128_OccCellsAttrStRAM5
;						
CSA_Label_02:			ld		a, (hl)						; a = occupied cells for attributes
						or		a
						ret		z							; Return if there is no occupied cells
						ld		l, (ix)
						ld		h, (ix+1)					; get occupied cells stack
						ld		de, T128_BYTES_CELLATTR
						add		hl, de						; Fake occupied cells stack
						ld		b, a						; Number of occupied cells
CSA_Loop_01:			ld		de, T128_BYTES_CELLATTR*2
						and		a
						sbc		hl, de						; Cells must be restores backwards
						ld		e, (hl)
						inc		hl
						ld		d, (hl)						; de = screen attribute address
						inc		hl
						ld		a, (hl)
						ld		(de), a						; Restore attribute
						inc		hl
						djnz	CSA_Loop_01
;
; Reset variables 
;
						ld		a, (T128_LastValue7ffd)	
						and		%00001000					; equal to 0 if hidden screen = RAM 7
						jr		nz, CSA_Label_03
						ld		de, T128_OccCellsAttribRAM7	; hidden screen = RAM 7
						ld		hl, T128_OccCellsAttrStRAM7						
						jr		CSA_Label_04
CSA_Label_03:			ld		de, T128_OccCellsAttribRAM5	; hidden screen = RAM 5
						ld		hl, T128_OccCellsAttrStRAM5				
CSA_Label_04:			xor		a							
						ld		(de), a						; Occupied cells atribute = 0
						inc		de
						ld		(hl), e				
						inc		hl
						ld		(hl), d						; Occupied Cells Stack = T128_CellsAttrRAM5 or T128_CellsAttrRAM7
						ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_RenderSMC
;
; Set up self modifying code in Sprite rendering routine
;
; Check T128_LastValue7ffd to find which screen is hidden (RAM 5 or RAM 7)
;

T128_RenderSMC:		ld		a, (T128_LastValue7ffd)
					and		%00001000					; equal to 0 if hidden screen = RAM 7
					jr		nz, RSMC_Label_00
;					
					ld		a, 7
					call	T128_SetBank
					ld		b, $c0						; hidden screen = RAM 7 (Occupied cells are in RAM 2)
					ld		c, $d8
					ld		hl, T128_OccupiedCellsRAM7
					ld		de, T128_OccCellsStackRAM7
					exx
					ld		hl, T128_OccCellsAttribRAM7
					ld		de, T128_OccCellsAttrStRAM7
					exx
					jr		RSMC_Label_01
;				
RSMC_Label_00:		xor		a
					call	T128_SetBank
					ld		b, $40						; hidden screen = RAM 5 (Occupied cells are in RAM 0)
					ld		c, $58
					ld		hl, T128_OccupiedCellsRAM5
					ld		de, T128_OccCellsStackRAM5
					exx
					ld		hl, T128_OccCellsAttribRAM5
					ld		de, T128_OccCellsAttrStRAM5
					exx					
;
; set up values acording to which screen is hidden
;					
RSMC_Label_01:		ld		a, b						
					ld		(RS_SMC_01+1), a
					ld		a, c
					ld		(RS_SMC_02+1), a
					ld		(RS_SMC_05+1), a
					ld		(RS_SMC_03+1), hl
					ld		(RS_SMC_04+1), hl
					exx
					ld		(RS_SMC_06+2), de
					ld		(RS_SMC_07+2), de
					ld		(RS_SMC_08+1), hl
					exx
					ld		(RS_SMC_09+1), de
					ld		(RS_SMC_11+1), de
;
; set up invisible mask initial value acording to T128_GameLoops
;					
					ld		a, (T128_GameLoops)
;					
;					and		%00000011					; Shift mask every 1 game cycle
;					rlca
;					
;					and		%00000110					; Shift mask every 2 game cycles
;					
					and		%00001100					; Shift mask every 4 game cycles
					rrca								
;					
;					and		%00011000					; Shift mask every 8 game cycles
;					rrca								
;					rrca								
;					
					ld		hl, RSMC_Table_01
					ld		c, a
					ld		b, 0
					add		hl, bc
					ld		a, (hl)
					ld		(RS_SMC_15+1), a
					inc		hl
					ld		a, (hl)
					ld		(RS_SMC_16+1), a
					ret
;
; Invisible mask lookup table
;
RSMC_Table_01:		defb	%00000011, %11000000
					defb	%00001100, %00110000
					defb	%00110000, %00001100
					defb	%11000000, %00000011


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_RenderSprite
;
; Render a sprite in HIDDEN screen.
; It uses preshifted masked sprites (T128_MASKED_SPRITES=2)
; But it also can be used with preshifted NON masked sprites (T128_MASKED_SPRITES=1)
; It can be used with prerotated sprites to save memory, depending on the value of bit 0 of (ix+2)
;
; T128_RenderSMC must be called once before rendering all sprites
;
; Use Hardness / Depth map to check if a sprite cell is behind some screen element
;
; Screen values before rendering the sprite are stored in T128_CellsBufferRAM5 or T128_CellsBufferRAM5
;
; Constraints:
;    * T128_OccupiedCellsRAM5 or T128_OccupiedCellsRAM7 must be equal or less than T128_MAX_CELLS
; 
; Input:
;    a  = 1 only mask rendering  /  0 mask+graphic rendering
;	 ix = Sprite parameters:
;				(ix+ 0) = sprite address
;				(ix+ 2) = IABWCZZR
;						    I  = 0 - normal        /  1 - invisible
;						    A  = 0 - inactive      /  1 - active
;					        B  = 1 if sprite is affected by Breath Areas
;       					W  = Wait-next-loop in FSM routine
;       					C  = child sprite
;       				    ZZ = 00 - background 1 / 01 - background 2 / 10 - foreground 1 / 11 - foreground 2
;						    R  = 0 - normal        /  1 - rotated
;				(ix+ 3) = Initial relative address for rotated mode 	= (columns-1)*scanlines*2
;				(ix+ 4) = Relative address decrement for rotated mode 	= scanlines*2*2
;				(ix+ 5) = X (0-31)
;				(ix+ 6) = x (0-255) 
;				(ix+ 7) = Y (0-23)
;				(ix+ 8) = y (0-191)
;				(ix+ 9) = sprite width (in columns)
;				(ix+10) = sprite width (in pixels) not used in this routine
;				(ix+11) = sprite height (in scanlines)
;				(ix+12) = sprite attribute
;				(ix+13) = not used in this routine
;				(ix+14) = not used in this routine
;				(ix+15) = not used in this routine
;               (ix+16) = not used in this routine
;				(ix+17) = not used in this routine
;				(ix+18) = not used in this routine
;				(ix+19) = not used in this routine
;               (ix+20) = not used in this routine
;               (ix+21) = not used in this routine
;               (ix+22) = not used in this routine
;               (ix+23) = not used in this routine
;               (ix+24) = not used in this routine
;               (ix+25) = not used in this routine
;               (ix+26) = not used in this routine
;               (ix+27) = not used in this routine
;               (ix+28) = not used in this routine
;
; Output:
;   (T128_OccupiedCellsRAM5) or (T128_OccupiedCellsRAM7)	= Number of occupied cells in current frame
;   (T128_CellsBufferRAM5) or (T128_CellsBufferRAM7) 		= Content of screen before rendering the sprite. Used in T128_ClearSprites to delete the sprite
;   (T128_OccCellsStackRAM5) or (T128_OccCellsStackRAM7)	= Next address available for other sprites in in T128_CellsBufferRAM5 or in T128_CellsBufferRAM7
;

T128_RenderSprite:	ld		(RS_SMC_MASK+1), a			; This parameter is used when processing sprite attribute
					ld		a, (ix+2)
					bit		6, a
					ret		z							; Return if sprite is not active
					and		%10000000
					jr		z, RS_Label_00				; ¿Invisible?
					ld		de, RS_NormalInvisble
					ld		hl, RS_RotatedInvisble
					jr 		RS_Label_01
;
RS_Label_00:		ld		a, (RS_SMC_MASK+1)
					ld		de, RS_Normal
					ld		hl, RS_Rotated
					or		a
					jr		z, RS_Label_01				; ¿Only mask rendering?
					ld		de, RS_NormalMask
					ld		hl, RS_RotatedMask
RS_Label_01:		ld		(RS_SMC_RenderN+1), de
					ld		(RS_SMC_RenderR+1), hl
;					
; Set proper bank
;
					ld		a, (T128_LastValue7ffd)
					and		%00001000					; equal to 0 if hidden screen = RAM 7
					jr		z, RS_Label_02
					xor		a
					call	T128_SetBank
					jr		RS_Label_03
RS_Label_02:		ld		a, 7
					call	T128_SetBank
;
RS_Label_03:		ld		a, (ix+11)					; [ 4]
					ld		(T128_BackupByte2), a		; [13] 		T128_BackupByte2 = height in scanlines (to be decreased)
					ld		(T128_BackupByte3), a		; [13] 		T128_BackupByte3 = height in scanlines (to check for firsr scanline)
					ld		b, (ix+9)					; [19]		b = number of columns
					ld		c, a						; [19]		c = number of scanlines
					push	bc							; 			Save for column and scnaline loop control
					ld		h, (ix+5)					; [19]
					ld		l, (ix+7)					; [19]
					ld		a, l						; [ 4]
					and		%11111000					; [ 7]
RS_SMC_01:			add		a, $40						; [ 7] 		$40 RAM 5 / $c0 RAM 7
					ld		b, a						; [ 4]
					ld		a, l						; [ 4]
					and		7							; [ 7]
					rrca								; [ 4]
					rrca								; [ 4]
					rrca								; [ 4]
					add		a, h						; [ 4]
					ld		c, a						; [ 4]
					ld		a, (ix+8)					; [19]
					and		7							; [ 7]
					ld		(T128_BackupByte1), a		; [13] 		T128_BackupByte1 = y mod 8. It is equal to 0 when y is a multiple of 8
					push	bc							; [11]
					pop		de							; [10] 		de = initial screen address
					push	de							; [11] 		Save to compute next column address
;
; Calculate sprite address and redndering subroutine
;
					exx								
					ld		l, (ix)
					ld		h, (ix+1)					; hl' = sprite address
RS_SMC_RenderN:		ld		de, RS_Normal				; Normal Sprite subroutine
					ld		a, (ix+2)
					and		%00000001
					jr		z, RS_Label_04				; Rotated sprite?
					ld		e, (ix+3)
					ld		d, 0
					add		hl, de						; hl' = rotated sprite address
RS_SMC_RenderR:		ld		de, RS_Rotated				; Rotated Sprite subroutine
					ld		a, (ix+4)
RS_Label_04:		ld		(RS_SMC_14+1), a			; Next column correction: 0 (Normal sprite)  /  (ix+4) (Rotated sprite)
					ld		(RS_SMC_10+1), de			; Rendering subroutine
					ld		de, T128_RotateTable		
					exx
;
; Calculate attribute
; 
;					ld		b, (ix+12)
;					ld		a, (T128_ScreenInfo)
;					and		%01111000
;					or		a
;					jr		z, RS_Label_ATTR			; If Screen PAPER = 0, then use Sprite Attribute
;					ex		af, af'						; Otherwise, use Screen PAPER
;					ld		a, b
;					and		%10000111
;					ld		b, a
;					ex		af, af'
;					or		b
;					ld		b, a
;RS_Label_ATTR:		ld		a, b
;					ld		(RS_SMC_ATTR+1), a
;
; Bottom border clipping
; Top left corner of the sprite must be inside screen area ==> FSM of the sprite must control that X>=0 and Y>=0
;
RS_Loop_01:			ld		a, d						; [ 4]		[NOTE] This 3 lines can be used only if T128_MAX_Y=24, saving 38 T-states
RS_SMC_02:			cp		$58							; [ 7]		$58 RAM 5 / $d8 RAM 7
					jp		nc, RS_Label_09				; [10/1]	
;					ld		a, e						; [ 4]
;					and		%11100000					; [ 7]
;					rlca								; [ 4]		
;					rlca								; [ 4] 		
;					rlca								; [ 4] 		
;					ld		c, a						; [ 4]
;					ld		a, d						; [ 4]
;					and		%00011000					; [ 7]
;					or		c							; [ 4]
;					cp		T128_MAX_Y					; [ 7]
;					jp		nc, RS_Label_09				; [10/1] 	Exclude current cell
;
; Get hardness and deptch data
;
					ld		a, d						; [ 4]
					rrca								; [ 4]
					rrca								; [ 4]
					rrca								; [ 4]
					and		3							; [ 7]
					or		T128_MapHD_PAGE				; [ 7]
					ld		h, a						; [ 4]
					ld		l, e						; [ 4] 		hl = hardness/depth address
					ld		a, (hl)						; [ 7]
					and		T128_BLOCK_DEPTH_F			; [ 7]
					jp		nz, RS_Label_09				; [10/1] 	If depth bit is set, then current cell is behind some screen element
;
; Increase number of occupied cells
;
RS_SMC_03:			ld		a, (T128_OccupiedCellsRAM5)	; T128_OccupiedCellsRAM5 (RAM 5) / T128_OccupiedCellsRAM7 (RAM 7)
					cp 		T128_MAX_CELLS
					jp		z, RS_Label_09				; Control buffer overflow
					inc		a
RS_SMC_04:			ld		(T128_OccupiedCellsRAM5), a	; T128_OccupiedCellsRAM5 (RAM 5) / T128_OccupiedCellsRAM7 (RAM 7)
;
; Process attribute
;
RS_SMC_MASK:		ld		a, 0
					or		a
					jr		nz, RS_SMC_09				; If ONLY MASK rendering is active, then attribute is not processed
					ld		a, (ix+12)
					or		a
					jr		z, RS_SMC_09				; If sprite attribute = 0 then attribute is not processed
					and		%01000111					; Only BRIGHT + INK from sprite attribute
RS_SMC_ATTR:		ld		b, a
					ld		a, h
					xor		T128_MapHD_PAGE
RS_SMC_05:			or		$58
					ld		h, a
					ld		a, (hl)						; get attribute
					ld		c, a

					and		%00111000
					jr		z, kk1						; Screen PAPER = 0?
					ld		a, b
					and		%00000111					
					ld		b, a
					ld		a, c
					and		%11111000					; if PAPER != 0 then Mix screen FLASH + BRIGTH + PAPER + sprite INK
					or		b
kk1:				ld		a, c
					and		%10111000					; if PAPER = 0 then Mix screen FLASH + PAPER + sprite BRIGHT + INK
					or		b
					
					
					ld		(hl), a						; write sprite attribute on screen
					ld		a, c
RS_SMC_06:			ld		iy, (T128_OccCellsAttrStRAM5)	; T128_OccCellsAttrStRAM5 (RAM 5) / T128_OccCellsAttrStRAM7 (RAM 7)
					ld		(iy), l
					inc		iy
					ld		(iy), h
					inc		iy
					ld		(iy), a						; save attribute
					inc		iy
RS_SMC_07:			ld		(T128_OccCellsAttrStRAM5), iy
RS_SMC_08:			ld		hl, T128_OccCellsAttribRAM5
					inc		(hl)						; increase number of occupied cells (attributes)
;
; Save address of the first scanline of current cell
;
RS_SMC_09:			ld		hl, (T128_OccCellsStackRAM5); [20]		T128_OccCellsStackRAM5 (RAM 5) / T128_OccCellsStackRAM5 (RAM 7)
					ld		(hl), e						; [ 7]
					inc		hl							; [ 6]
					ld		(hl), d						; [ 7]
					inc		hl							; [ 6]      hl = cell buffer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                           ;
; BEGIN RENDERING ALGORITHM ;
;                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
;
; If y is multiple of 8, then render full cell
;
					
					ld		a, (T128_BackupByte1)		; [13]
					or		a							; [ 4]
					jr		z, RS_Label_06				; [12/7]	C A S E   3   =  Full cell (same case as middle cell)
;
; If y is not multiple of 8, then check subcases
;
					ld		a, (T128_BackupByte3)		; [13]
					ld		c, a						; [ 4]
					ld		a, (T128_BackupByte2)		; [13] 		a = number of scanlines left to render
					cp 		8							; [ 7]
					jr		c, RS_Label_05				; [12/7] 	C A S E   2  =  Last cell
					cp		c							; [ 4]
					jr		nz, RS_Label_06				; [12/7] 	C A S E   3  =  Middle cell (same case as full cell)
														;           C A S E   1  =  Fisrt cell

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C A S E   1 
;
; y is not multiple of 8 and current cell is first cell. Examples:
;   y mod 8 = 2 then do 2 loops saving background, plus 6 normal loops
;   y mod 8 = 4 then do 4 loops saving background, plus 4 normal loops
;   y mod 8 = 6 then do 6 loops saving background, plus 2 normal loops
;
					ld		a, (T128_BackupByte1)		; [13] 		a = y mod 8
					ld		c, a						; [ 4] 		c = y mod 8
					ld		b, a						; [ 4] 		b = y mod 8. Loops saving background
;
; Move throught fisrt scanlines saving backgorund
;
RS_Loop_02:			ld		a, (de)
					ld		(hl), a
					inc		d
					inc		hl
					djnz	RS_Loop_02
;
; Render first scanlines of the sprite, using same routine as in full cells ( C A S E   3 )
;
					ld		a, 8
					sub		c
					ld		b, a
					ld		c, 0						; c = 0 only render sprite
					jr		RS_Label_07

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C A S E   2
;
; y is not multiple of 8 and current cell is last cell. Examples:
;   y mod 8 = 2 then do 2 normal loops, plus 6 loops saving background
;   y mod 8 = 2 then do 4 normal loops, plus 4 loops saving background
;   y mod 8 = 2 then do 6 normal loops, plus 2 loops saving background
;
RS_Label_05:		ld		b, a						; [ 4] 	b = number of scanlines left to render. Normal loops
					ld		c, 1						;		c = 1 render sprite and save background
					jr		RS_Label_07					; 		And do C A S E   3
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C A S E   3
;
; y is multiple of 8: render full cells (and middle cells)
;

RS_Label_06:		ld		b, 8					; [ 7] 		b = number of scanlines to render
					ld		c, 0					;			c = 0 only render sprite
RS_Label_07:		ld		a, (T128_BackupByte2)	; [13] 		Decrement number of scanlines to be rendered
					sub		b						; [ 4]
					ld 		(T128_BackupByte2), a	; [13]
RS_SMC_10:			call	RS_Normal				; RS_Normal / RS_Rotated
;
; C A S E S  1 and 3: saving background is not needed
;
					ld		a, c
					or		a
					jr		z, RS_Label_08
;
; Save backgorund for the rest of the scanlines in the cell
;
					ld		a, (T128_BackupByte1)
					ld		b, a
					ld		a, 8
					sub		b
					ld		b, a
RS_Loop_03:			ld		a, (de)
					ld		(hl), a
					inc		d
					inc		hl
					djnz	RS_Loop_03
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                         ;
; END RENDERING ALGORITHM ;
;                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Save next cell in buffer
;
RS_Label_08:
RS_SMC_11:			ld		(T128_OccCellsStackRAM5), hl	; T128_OccCellsStackRAM5 (RAM 5) / T128_OccCellsStackRAM7 (RAM 7)
					jr		RS_Label_12					; [12]
;
; Jump here when depth=1 or cell is outside screen area
;			
RS_Label_09:		ld		a, 8*T128_MASKED_SPRITES	; [ 7] 		Self modifying code: next sprite cell (full cell)
					ld 		(RS_SMC_12+1), a			; [13]
					rrca								; [ 4] 		Self modifying code: decrease scanlines (full cell)
					ld 		(RS_SMC_13+1), a			; [13]
; 
; Check for full cell case
;
					ld		a, (T128_BackupByte1)		; [13]
					or		a							; [ 4]
					jr		z, RS_Label_11				; [12/7]	
; 
; Check for other cases
;
					ld		a, (T128_BackupByte3)		; [13]
					ld		c, a						; [ 4]
					ld		a, (T128_BackupByte2)		; [13] 		a = number of scanlines left to render
					cp 		8							; [ 7]
					jr		c, RS_Label_10				; [12/7] 	if a < 8, then last cell
					cp		c							; [ 4]
					jr		nz, RS_Label_11				; [12/7] 	if a != number of scanlines of the sprite,  then middle cell (same as full cell)
					ld		a, (T128_BackupByte1)		; [13] 		a = y mod 8
					ld		b, a						; [ 4] 		d = y mod 8
					ld		a, 8						; [ 7]
					sub		b							; [ 4] 		a = 8 - (y mod 8). Loops not done
RS_Label_10:		ld		(RS_SMC_13+1), a			; [13] 		Self modifying code: decrease scanlines
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2
					add		a, a						; [ 4]
ENDIF					
					ld		(RS_SMC_12+1), a			; [13] 		Self modifying code: next sprite cell
RS_Label_11:		exx									; [ 4] 		de = screen address     hl' = sprite address
RS_SMC_12:			ld		bc, 8*T128_MASKED_SPRITES	; [10]
					add		hl, bc						; [15] 		Next sprite cell
					exx									; [10] 		
					ld		a, d						; [ 4]
					add		a, 8						; [ 7]
					ld		d, a						; [ 4] 		de = next cell address on screen
RS_SMC_13:			ld		b, 8						; [ 7] 		
					ld		a, (T128_BackupByte2)		; [13] 		
					sub		b							; [ 4]
					ld 		(T128_BackupByte2), a		; [13]		Save scanelines left to render
;
; de = next cell address on screen / hl' = Next sprite cell
;
RS_Label_12:		ld		a, (T128_BackupByte2)		; [13]
					or		a							; [ 4]
					jr		z, RS_Label_13				; [12/7] 	Next column if no scanlines are left
;
; Next screen address, keeping column
;				
					ld		a, e						; [ 4]
					add		a, $20						; [ 7]
					ld		e, a						; [ 4]
					jp		c, RS_Loop_01				; [12/7]
					ld		a, d						; [ 4]
					sub		$08							; [ 7]
					ld		d, a						; [ 4]
					jp		RS_Loop_01					; [10]
; 
; Get next column address on screen. Do right border clipping
;
RS_Label_13:		exx
RS_SMC_14:			ld		bc, 0						; 0 (Normal sprite)   /  (ix+4) (Rotated sprite)
					and		a	
					sbc		hl, bc						; Next sprite address
					exx	
					pop		de							; [10] 		
					pop		bc							; [10] 		
					dec		b							; [ 4]
					ret		z							; [11/5] 	
					ld		a, c						; [ 4]
					ld		(T128_BackupByte2), a		; [13] 		
					ld		a, e						; [ 4] 		
					and		%00011111					; [ 7] 		
					cp		T128_MAX_X					; [ 7] 		
					ret		z							; [11/5] 	
					inc		e							; [ 4] 		
					push	bc							; [11] 		
					push	de							; [11] 		
					jp		RS_Loop_01					; [10]


;;;;;;;;;;;;;;;;;;;;;;;;;
;                       ;
; RENDERING SUBROUTINES ;
;                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render sprite: Save background, apply mask and render sprite
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RS_Normal:			exx
					ld		c, (hl)						; graphic
					inc		hl
					ld		b, (hl)						; mask
					inc		hl
					exx
					ld		a, (de)
					ld		(hl), a
					exx
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2
					and		b						
ENDIF
					or		c
					exx
					ld		(de), a
					inc		d
					inc		hl
					djnz	RS_Normal
					ret
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render ROTATED sprite: Save background, apply mask and render sprite
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RS_Rotated:			exx
					ld		c, (hl)					; graphic
					inc		hl
					ld		e, c
					ld		a, (de)
					ld		c, a					; rotate graphic
					ld		b, (hl)					; mask
					inc		hl
					ld		e, b
					ld		a, (de)
					ld		b, a					; rotate mask
					exx
					ld		a, (de)
					ld		(hl), a
					exx
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2					
					and		b						
ENDIF										
					or		c
					exx
					ld		(de), a
					inc		d
					inc		hl
					djnz	RS_Rotated
					ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render sprite (INVISIBLE effect): Save background, apply mask and render sprite
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RS_NormalInvisble:	push	bc
RS_SMC_15:			ld		c, %00000011
RS_NI_Loop_01:		exx
					ld		a, (hl)						; graphic
					exx
					and		c
					exx
					ld		c, a
					inc		hl
					ld		b, (hl)						; mask
					inc		hl
					exx
					ld		a, (de)
					ld		(hl), a
					exx
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2
					and		b						
ENDIF
					or		c
					exx
					ld		(de), a
					inc		d
					inc		hl
					rrc		c
					djnz	RS_NI_Loop_01
					pop		bc
					ret
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render ROTATED sprite (INVISIBLE effect): Save background, apply mask and render sprite
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RS_RotatedInvisble:	push	bc
RS_SMC_16:			ld		c, %11000000
RS_RI_Loop_01:		exx
					ld		c, (hl)					; graphic
					inc		hl
					ld		e, c
					ld		a, (de)
					exx
					and		c
					exx
					ld		c, a					; rotate graphic
					ld		b, (hl)					; mask
					inc		hl
					ld		e, b
					ld		a, (de)
					ld		b, a					; rotate mask
					exx
					ld		a, (de)
					ld		(hl), a
					exx
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2					
					and		b						
ENDIF										
					or		c
					exx
					ld		(de), a
					inc		d
					inc		hl
					rlc		c
					djnz	RS_RI_Loop_01
					pop		bc
					ret
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render sprite (only MASK): Save background, apply mask. 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RS_NormalMask:		exx
					ld		c, (hl)						; graphic
					inc		hl
					ld		b, (hl)						; mask
					inc		hl
					exx
					ld		a, (de)
					ld		(hl), a
					exx
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2
					and		b						
ENDIF
					exx
					ld		(de), a
					inc		d
					inc		hl
					djnz	RS_NormalMask
					ret
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Render ROTATED sprite (only MASK): Save background, apply mask
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RS_RotatedMask:		exx
					ld		c, (hl)					; graphic
					inc		hl
					ld		e, c
					ld		a, (de)
					ld		c, a					; rotate graphic
					ld		b, (hl)					; mask
					inc		hl
					ld		e, b
					ld		a, (de)
					ld		b, a					; rotate mask
					exx
					ld		a, (de)
					ld		(hl), a
					exx
;
; T128_MASKED_SPRITES=2 if masked sprites are used
;
IF T128_MASKED_SPRITES=2					
					and		b						
ENDIF										
					exx
					ld		(de), a
					inc		d
					inc		hl
					djnz	RS_RotatedMask
					ret					