;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; B A N K S   A N D   M E M O R Y   M A N A G E M E N T 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_MEMORY
_BEGIN_CODE_MEMORY:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SetBank
;
; Select RAM Bank
;
; Input:
;	a = bank (0-7)
;

T128_SetBank:		ld		b, a
					ld 		a, (T128_LastValue7ffd)		; Previous value of port
					and		$f8							
					or		b						
					ld 		bc, $7ffd
					di
					ld 		(T128_LastValue7ffd), a
					out 	(c), a
					ei
					ret
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_ToggleScreen
;
; Toggle betwwen RAM 5 screen and RAM 7 shadow screen
;					

T128_ToggleScreen:	ld 		a, (T128_LastValue7ffd)		; Previous value of port
					xor		%00001000
					ld 		bc, $7ffd
					di
					ld 		(T128_LastValue7ffd), a
					out 	(c), a
					ei
					ret
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SetRAM5Screen
;
; Set visible RAM 5 screen and RAM 7 shadow screen
;					

T128_SetRAM5Screen:	ld 		a, (T128_LastValue7ffd)		; Previous value of port
					and		%11110111
					ld 		bc, $7ffd
					di
					ld 		(T128_LastValue7ffd), a
					out 	(c), a
					ei
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_SetRAM7Screen
;
; Set visible RAM 7 shadow screen
;					

T128_SetRAM7Screen:	ld 		a, (T128_LastValue7ffd)		; Previous value of port
					or		%00001000
					ld 		bc, $7ffd
					di
					ld 		(T128_LastValue7ffd), a
					out 	(c), a
					ei
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrRAM5ToRAM7
;
; Copy screen to shadow screen (RAM 5 to RAM 7)
;					
					
T128_TrRAM5ToRAM7:	ld		hl, $4000
					ld		de, $c000
TRTR_Label_01:		ld		a, 7
					call	T128_SetBank
					ld 		bc, 6912
					ldir
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrRAM7ToRAM5
;
; Copy shadow screen to screen (RAM 7 to RAM 5)
;					
					
T128_TrRAM7ToRAM5:	ld		hl, $c000
					ld		de, $4000
					jr		TRTR_Label_01
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrScreenData
;
; Transfer current screen data from RAM BF2 to RAM 2
; Bank memory selection is done in this routine, but it is not undone
; Calculate Up, Down, Left and Right screens 
;
; Input:
;   l = Screen number (0-255)
;
; Map game is rectagular
; Screen number format: RRRRCCCC, or RRRCCCCC, or RRRRRCCC, etc where R=Row and C=Column
;
;                 +--------------+
;                 |  ROW-1 : COL |
;  +--------------+--------------+----------------+
;  |  ROW : COL-1 |  ROW  : COL  |  ROW  : COL+1  |
;  +--------------+--------------+----------------+
;                 |  ROW+1 : COL |
;                 +--------------+
;
; T128_SCREEN_ROW_1 = 00000001 if the format is RRRRRRRR (256 rows x   1 columns)
; T128_SCREEN_ROW_1 = 00000010 if the format is RRRRRRRC (128 rows x   2 columns)
; T128_SCREEN_ROW_1 = 00000100 if the format is RRRRRRCC ( 64 rows x   4 columns)
; T128_SCREEN_ROW_1 = 00001000 if the format is RRRRRCCC ( 32 rows x   8 columns)
; T128_SCREEN_ROW_1 = 00010000 if the format is RRRRCCCC ( 16 rows x  16 columns)
; T128_SCREEN_ROW_1 = 00100000 if the format is RRRCCCCC (  8 rows x  32 columns)
; T128_SCREEN_ROW_1 = 01000000 if the format is RRCCCCCC (  4 rows x  64 columns)
; T128_SCREEN_ROW_1 = 10000000 if the format is RCCCCCCC (  2 rows x 128 columns)
; T128_SCREEN_ROW_1 = 00000000 if the format is CCCCCCCC (  1 rows x 256 columns)
;
; Screen number $ff is reserved for non valid screen ==> OBSOLETE. $ff is a valid screen number
;

T128_TrScreenData:	ld		a, (T128_FastBank2)			; Screen data is in RAM BF2
					call	T128_SetBank
;
; Calculate Up, Down, Left and Right screens 
;					
					ld		a, l
					sub		T128_SCREEN_ROW_1
;					jr		nc, TSD_Label_01
;					ld		a, $ff
TSD_Label_01:		ld		(T128_ScreenUp), a		
					ld		a, l
					add		a, T128_SCREEN_ROW_1
					ld		(T128_ScreenDown), a
					ld		a, l
					dec		a
					ld		(T128_ScreenLeft), a
					ld		a, l
					inc		a
					ld		(T128_ScreenRight), a
;
; Set bc, de, and hl registers with the appropiate values
; 
TSD_SMC_01:			ld		bc, T128_ScrPtrs_BF2			
					ld 		h, 0						
					add		hl,	hl
					push	hl
					add		hl, bc             			; hl = Screen descriptor pointer
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = Screen address (*)
					inc		hl
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = Next screen address
					pop		hl
					push	de
TSD_SMC_02:			ld		de, T128_ScrEntPtrs_BF2
					add		hl, de						; hl = Screen entities descriptor pointer
					ld		e, (hl)
					inc		hl
					ld		d, (hl)						; de = Screen entities address  (*)
					ld		(T128_SDRAMBF2_EntSource), de ; Save current screen entity data address
					pop		hl							; hl = Next screen address (*)
;
; Calculate ending address of screen entities data
;
					push	hl
					push	de
					and		a
					sbc		hl, bc						
					ld		de, T128_ScreenDataRAM2			
					add		hl, de						; hl = ScreenDataRAM2 + Next Screen - Screen
					ld		(T128_SDRAM2_End2), hl
;
; Calculate ending address of screen data
; 
					pop		hl							; hl = Screen entities address
					pop		de							; de = Next screen address
					and		a
					sbc		hl, bc						
					ld		de, T128_ScreenDataRAM2			
					add		hl, de						; hl = ScreenDataRAM2 + Screen entities - Screen
					ld		(T128_SDRAM2_End1), hl					
;
; Transfer screen data to T128_ScreenDataRAM2	
;
					push	bc
					ld		hl, (T128_SDRAM2_End2)
					ld		de, T128_ScreenDataRAM2
					and		a
					sbc		hl, de
					ld		c, l
					ld		b, h						; bc = screen length
					pop		hl							; hl = screen source
					ld		de, T128_ScreenDataRAM2		
					ldir
;
; Save Current screen entity data length					
;
					ld		hl, (T128_SDRAM2_End2)
					ld		bc, (T128_SDRAM2_End1)
					and		a
					sbc		hl, bc
					ld		(T128_SDRAMBF2_EntLength), hl
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrEntityInfo
;
; Update entity info in screen definition before moving to a new screen
; 
; Sprites and animated blocks info might have been changed in current screen. This routine updates this info in bank BF2
;

T128_TrEntityInfo:	ld		de, (T128_SDRAMBF2_EntLength)
					ld		a, d
					or		e
					ret		z							; If there is no entities, then return
					ld		a, (T128_FastBank2)			; Screen data is in RAM BF2
					call	T128_SetBank
					ld		b, d
					ld		c, e				
					ld		hl, (T128_SDRAM2_End1)
					ld		de, (T128_SDRAMBF2_EntSource)
					ldir
					xor		a
					call	T128_SetBank				; Return to Bank 0
					ret
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrGraphData
;
; If the type of animated block / sprite is already in the Graphic Pool, then use it
;
; In other case, transfer graphic data from BS2 to T128_GraphicPool in B2. T128_GraphicPoolABPtr or T128_GraphicPoolSPRPtr area are updated
; Bank memory switching is done in this case. B0 is selected at the end.
; Buffer overflow is checked to avoid exceeding T128_GraphicPoolEnd. In this case, tranfer from BS2 to B2 is not done,
; and graphic address is returned in the bc registar as well, though it will not make sense. A random graphic will be used
; 
; Input:
;   hl  = T128_GraphicPoolABPtr for Animated Blocks
;       = T128_GraphicPoolSPRPtr for Sprites
;   hl' = T128_GraphicsAB for Animated Blocks
;       = T128_GraphicsSpr for Sprites
;   e   = type of animated block / sprite
;
; Output
;   bc = graphic address in B2
;

T128_TrGraphData:	ld		a, e
					add		a, a
					ld		c, a
					ld		b, 0
					add		hl, bc
					ld		c, (hl)
					inc		hl
					ld		b, (hl)
					xor		a
					cp		c
					ret		nz
					cp		b
					ret		nz							; If this type of animated block / sprite is already in the Graphic Pool, then bc = graphic address in B2
;					
					push	hl							; T128_GraphicPoolABPtr / T128_GraphicPoolSPRPtr pointer will be updated at the end of the routine
					ld		a, (T128_SlowBank2)			; Animated block / sprite data is in RAM BS2
					call	T128_SetBank
;					
					exx
					push	hl
					exx
					pop		hl							; hl = hl'
					ld		a, e
					add		a, a
					ld		e, a
					ld		d, 0
					add		hl, de
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					ex		de, hl
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = length of animated block / sprite data
					inc		hl							; hl = source address
					ld 		de, (T128_GraphicPoolNext)	; de = destination address
;
; Check buffer overflow in T128_GraphicPool					
;
					ex		de, hl
					push	hl
					push	bc
					add		hl, bc
					ld		bc, T128_GraphicPoolEnd
					ld		a, h
					cp		b
					jr		c, TGF_Label_01
					ld		a, l
					cp		c
					jr		c, TGF_Label_01
					pop		bc
					pop		hl
					ex		de, hl
					push	de
					jr		TGF_Label_02
TGF_Label_01:		pop		bc
					pop		hl
					ex		de, hl					
;					
					push	de
					ldir
					ld 		(T128_GraphicPoolNext), de
;					
TGF_Label_02:		xor		a
					call	T128_SetBank				; Back to bank 0
					pop		bc							; bc = graphic address in B2
;					
					pop		hl							
					ld		(hl), b
					dec		hl
					ld		(hl), c						; Update T128_GraphicPoolABPtr / T128_GraphicPoolSPRPtr
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_DynamicLinks
;
; Set up dynamic links
; 
; Some routine addresses can not be resolved during compiling time due to engine memory configuration,
; so dynamic linking must be done
; 
					
T128_DynamicLinks:	xor		a
					call	T128_SetBank				; Set RAM 0
;
; Dynamic links to T128_TrGraphData in bank 0
;
					ld		hl, T128_TrGraphData
					ld		(SPRCB0_SMC_01_B0+1), hl
					ld		(SPRS_SMC_01_B0+1), hl
					ld		(ABC_SMC_01_B0+1), hl
;
; Dynamic links to T128_AY_InitFX in bank 0
;
					ld		hl, T128_AY_InitFX
					ld		(AYIFX_SMC_01_B0+1), hl
;
; Dynamic links to T128_AY_InitSong in bank 0
;
					ld		hl, T128_AY_InitSong
					ld		(AYIS_SMC_01_B0+1), hl
;
; Dynamic links to T128_TrScoreBoard in bank 0
;
					ld		hl, T128_TrScoreBoard
					ld		(USB_SMC_01_B0+1), hl
;
; Dynamic links to CL_NewScreen in bank 0
;
					ld		hl, CL_NewScreen
					ld		(PF_SMC_01_B0+1), hl
;
; RAM S1
;
					ld		a, (T128_SlowBank1)
					call	T128_SetBank				; Set RAM S1
;
; Dynamic links to T128_AY_InitFX in bank S1
;
					ld		hl, T128_AY_InitFX
					ld		(AYIFX_SMC_01_BS1+1), hl
;
; Dynamic links to T128_AY_InitSong in bank S1
;
					ld		hl, T128_AY_InitSong
					ld		(AYIS_SMC_01_BS1+1), hl
;
; Dynamic links to GameStartsHere in bank S1
;
					ld		hl, GameSetup
					ld		(M_SMC_01_BS1+1), hl
					ret
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitFX
;
; Call T128_AY_InitFXBF1 from banks other than bank 2
; 
; Input:
;   a = FX number
;   b = bank number
; 
T128_AY_InitFX:		push	bc
					push	af
					ld		a, (T128_FastBank1)
					call	T128_SetBank				; Set bank BF1
					pop		af
					call	T128_AY_InitFXBF1				
					pop		bc
					ld		a, b
					jp		T128_SetBank				; Restore bank


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitSong
;
; Call T128_AY_InitSongBF1 from banks other than bank 2
; 
; Input:
;   a = Song number
;   b = bank number
; 
T128_AY_InitSong:	push	bc
					push	af
					ld		a, (T128_FastBank1)
					call	T128_SetBank				; Set bank BF1
					pop		af
					call	T128_AY_InitSongBF1				
					pop		bc
					ld		a, b
					jp		T128_SetBank				; Restore bank



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrScoreBoard
;
; Transfer info from scoreboard in bank 5 to bank 7
; 
; Input:
;  ix = GameVar address
;
T128_TrScoreBoard:	ld		a, 7						; Screen data is in RAM BF2
					call	T128_SetBank
;
					ld		b, (ix+5)
					ld		a, b
					and		%00001111
					inc		a							; a = Rows
					ex		af, af'
					ld		a, b
					and		%11110000
					rrca
					rrca
					rrca
					rrca
					inc		a							
					ld		c, a
					ld		b, 0						; bc = columns
					ld		l, (ix+3)
					ld		h, (ix+4)					; hl = screen address
;
; Transfer one row
;					
TSB_Loop_01:		push	hl
					ld		a, h
					xor		$40
					or		$58
					ld		h, a
					or		$80
					ld		d, a
					ld		e, l
					push	bc
					ldir								; Trasnfer attribute
					pop		bc
					pop		hl
;					
					exx
					ld		b, 8						
TSB_Loop_02:		exx
					ld		a, h
					or		$80
					ld		d, a
					ld		e, l
					push	bc
					push	hl
					ldir	
					pop		hl
					pop		bc
					inc		h
					exx
					djnz	TSB_Loop_02					; Trasfer graphic
					exx
;					
					ex		af, af'
					dec		a
					jr		z, TSB_Label_01				; no more rows?
					ex		af, af'
;
; Next row address
; 					
					ld		a, l
					add		a, $20						
					ld		l, a						
					jr		c, TSB_Loop_01
					ld		a, h
					sub		$08							
					ld		h, a						
					jr		TSB_Loop_01
;					
TSB_Label_01:		xor		a
					jp		T128_SetBank				; Return to Bank 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TrBitmap
;
; Select Bitmap for MainChar
; 
; Input:
;  hl = T128_PerseusBitmap for Perseus Bitmap
;       T128_MedusaBitmap for Medusa Bitmap
;

T128_TrBitmap:		ld		a, 7
					call	T128_SetBank
					ld		bc, T128_MedusaBitmap-T128_PerseusBitmap
					ld		de, Spr_PerseusWalk
					ldir
					ret

					