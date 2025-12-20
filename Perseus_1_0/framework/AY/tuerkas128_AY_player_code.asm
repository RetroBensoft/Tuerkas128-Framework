;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; A Y   P L A Y E R
;
; Enable music:
;	ld		a, (T128_AY_Control)
;	and		%11111101
;	ld		(T128_AY_Control), a
;
; Disable music:
;	ld		a, (T128_AY_Control)
;	or		%00000010
;	ld		(T128_AY_Control), a
;
; Enable FX:
;	ld		a, (T128_AY_Control)
;	and		%11111110
;	ld		(T128_AY_Control), a
;
; Disable FX:
;	ld		a, (T128_AY_Control)
;	or		%00000001
;	ld		(T128_AY_Control), a
;
; Init a Song from Bank 2:
;	ld		a, (T128_FastBank1)
;	call	T128_SetBank	
;	xor		a							; Song number
;	call	T128_AY_InitSongBF1
;
; Init a Song from other bank (for instance, bank 0):
;	xor		a							; Song number
;	call	T128_AY_InitSongB0
;
; Init a Song from other bank (for instance, bank BS1):
;	xor		a							; Song number
;	call	T128_AY_InitSongBS1
;
; Init an FX from Bank 2:
;	ld		a, (T128_FastBank1)
;	call	T128_SetBank	
;	xor		a							; FX number
;	call	T128_AY_InitFXBF1
;
; Init an FX from other bank (for instance, bank 0):
;	xor		a							; FX number
;	call	T128_AY_InitFXB0
;
; Init an FX from other bank (for instance, bank BS1):
;	xor		a							; FX number
;	call	T128_AY_InitFXBS1
;
; Stop Music:
;	ld		a, T128_AY_CTRL_ENDSONG
;	ld		(T128_AY_SongAction), a
;
; Play music:
;	xor		a
;	ld		(T128_AY_SongAction), a
;
; Stop FX
;	ld		a, T128_AY_CTRL_ENDFX
;	ld		(T128_AY_FXAction), a
;
; Play FX
;	xor		a
;	ld		(T128_AY_FXAction), a
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_AY_PLAYER
_BEGIN_CODE_AY_PLAYER:


PUBLIC T128_AY_PlayerBF1
PUBLIC T128_AY_InitSongBF1, T128_AY_InitFXBF1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; V A R I A B L E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Current song 
;
AY_CurrentSong		defw	0

;
; Current FX priority
;
AY_CurrFXPriority	defb	0

;
; Envelop control
;  1 = envelop type must be sent to AY
;  0 = envelope type must not be sent to AY
;
AY_EnvelopControl	defb	0

;
; AY registers
;
AY_REG_A_Pitch		defw	0							; 0 & 1
AY_REG_B_Pitch		defw	0							; 2 & 3
AY_REG_C_Pitch		defw	0							; 4 & 5
AY_REG_Noise		defb	0							; 6
AY_REG_Mixer		defb	%00111111					; 7
AY_REG_A_Volume		defb	0							; 8
AY_REG_B_Volume		defb	0							; 9
AY_REG_C_Volume		defb	0							; 10
AY_REG_EnvDurL		defb	$ff							; 11
AY_REG_EnvDurH		defb	$ff							; 12
AY_REG_Envelope		defb	0							; 13

;
; Music & FX structure
;
AY_PARAM.BASE_NOTE	EQU		0
AY_PARAM.BASE_PITCH	EQU		1
AY_PARAM.DURATION	EQU		3
AY_PARAM.CURR_PITCH	EQU		4
AY_PARAM.CURR_AMOP	EQU		6
AY_PARAM.CURR_VOL	EQU		7
AY_PARAM.CURR_NOISE	EQU		8
AY_PARAM.INST_LEN	EQU		9 
AY_PARAM.INST_COUNT	EQU		10
AY_PARAM.INST_POS	EQU		11
AY_PARAM.INST_LOOPI	EQU		13
AY_PARAM.INST_LOOP	EQU		14
AY_PARAM.CURR_PATT	EQU		16
AY_PARAM.CURR_NOTE	EQU		18
AY_PARAM.ARP_ORN	EQU		20
AY_PARAM.FADE_TYPE	EQU		22
AY_PARAM.FADE_SPEED	EQU		23
AY_PARAM.FADE_CURR	EQU		24
AY_PARAM.FADE_COUNT	EQU		25
AY_PARAM.ENV_TYPE	EQU		26
AY_PARAM.ENV_MULT   EQU		27
AY_PARAM.ENV_DUR	EQU		28
AY_PARAM.ENV_PREV	EQU		30

;
; Channel A structure (music)
; 
AY_MusicParametersA	defb	0							; Base note index
					defw	0							; Base pitch
					defb	0							; Note duration					
					defw	0							; Current pitch
					defb	0							; Current AM operation
					defb	0							; Current volume
					defb	0							; Current noise					
					defb	0							; Instrument length
					defb	0							; Current instrument counter
					defw	0							; Current instrument position (address)
					defb	0							; Current instrument loop (index)
					defw	0							; Current instrument loop (address)
					defw	0							; Current pattern pointer
					defw	0							; Current note pointer
					defw	0							; Current arpeggio/ornament (address)
					defb	0							; Fade type
					defb	0							; Fade speed
					defb	0							; Fade current volume
					defb	0							; Fade counter
					defb	0							; Envelope type
					defb	0							; Envelope multiplier
					defw	0							; Envelope duration
					defb	0							; Envelope type (previous value)
					
;
; Channel B structure (music)
; 
AY_MusicParametersB	defb	0							; Base note index
					defw	0							; Base pitch
					defb	0							; Note duration					
					defw	0							; Current pitch
					defb	0							; Current AM operation
					defb	0							; Current volume
					defb	0							; Current noise
					defb	0							; Current instrument length
					defb	0							; Current instrument counter
					defw	0							; Current instrument position (address)
					defb	0							; Current instrument loop (index)					
					defw	0							; Current instrument loop (address)
					defw	0							; Current pattern pointer					
					defw	0							; Current note pointer	
					defw	0							; Current arpeggio/ornament (address)	
					defb	0							; Fade type
					defb	0							; Fade speed
					defb	0							; Fade current volume
					defb	0							; Fade counter					
					defb	0							; Envelope type
					defb	0							; Envelope multiplier
					defw	0							; Envelope duration
					defb	0							; Envelope type (previous value)

;
; Channel C structure (music)
; 
AY_MusicParametersC	defb	0							; Base note index
					defw	0							; Base pitch
					defb	0							; Note duration					
					defw	0							; Current pitch
					defb	0							; Current AM operation
					defb	0							; Current volume
					defb	0							; Current noise
					defb	0							; Current instrument length
					defb	0							; Current instrument counter
					defw	0							; Current instrument position (address)
					defb	0							; Current instrument loop (index)					
					defw	0							; Current instrument loop (address)
					defw	0							; Current pattern pointer					
					defw	0							; Current note pointer	
					defw	0							; Current arpeggio/ornament (address)
					defb	0							; Fade type
					defb	0							; Fade speed
					defb	0							; Fade current volume
					defb	0							; Fade counter					
					defb	0							; Envelope type
					defb	0							; Envelope multiplier
					defw	0							; Envelope duration
					defb	0							; Envelope type (previous value)					

;
; Channel B structure (FX)
; 
AY_FX_Parameters	defb	0							; Base note index
					defw	0							; Base pitch
					defb	0							; Note duration					
					defw	0							; Current pitch
					defb	0							; Current AM operation
					defb	0							; Current volume
					defb	0							; Current noise
					defb	0							; Current instrument length
					defb	0							; Current instrument counter
					defw	0							; Current instrument position (address)
					defb	0							; Current instrument loop (index)					
					defw	0							; Current instrument loop (address)
					defw	0							; Current pattern pointer					
					defw	0							; Current note pointer	
					defw	0							; Current arpeggio/ornament (address)					
					defb	0							; Fade type
					defb	0							; Fade speed
					defb	0							; Fade current volume
					defb	0							; Fade counter					
					defb	0							; Envelope type
					defb	0							; Envelope multiplier
					defw	0							; Envelope duration
					defb	0							; Envelope type (previous value)					
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C O D E
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitSongBF1
;
; Setup a song
;
; Input:
;   a = Song number
;
T128_AY_InitSongBF1	di
					ld		hl, T128_AY_Songs
					add		a, a
					ld		c, a
					ld		b, 0
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					ex		de, hl
					ld		(AY_CurrentSong), hl
					ld		a, 1						; Do execute ei at the end of AYIS_Label_01
AYIS_Label_01:		push	af
					xor		a
					ld		(T128_AY_SongAction), a		; Play music
					ld		ix, AY_MusicParametersA
					call	AYIS_Label_02
					ld		ix, AY_MusicParametersB
					call	AYIS_Label_02
					ld		ix, AY_MusicParametersC
					call	AYIS_Label_02
					pop		af
					or		a
					ret		z
					ei
					ret
;					
AYIS_Label_02:		ld		a, T128_AY_FADEOFF
					ld		(ix+AY_PARAM.FADE_TYPE), a	; Disable fade
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					inc		hl
					jp		AY_InitPattern


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitFXBF1
;
; Setup an FX
;
; Input:
;   a = FX number
;
T128_AY_InitFXBF1:	di
					push	ix
					push	iy
					ld		hl, T128_AY_FXs
					add		a, a
					ld		c, a
					ld		b, 0
					add		hl, bc
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					ld		a, (de)
					ld		hl, AY_CurrFXPriority
					cp		(hl)
					jr		c, AYIF_Label_01			; If FX priority is lower than current FX priority then return
					ld		(hl), a						; Set new priority
					inc		de							; de = FX address
					xor		a
					ld		(T128_AY_FXAction), a		; Play FX
					ld		ix, AY_FX_Parameters
					ld		a, T128_AY_FADEOFF
					ld		(ix+AY_PARAM.FADE_TYPE), a	; Disable fade
					call	AY_InitPattern					
AYIF_Label_01:		pop		iy
					pop		ix
					ei
					ret
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_PlayerBF1
;
; Execute player. This function must be called reguraly 50 times per second
;
; Pseudocode:
;
;       if Music is enabled then
;         if T128_AY_SongAction = T128_AY_CTRL_ENDSONG then
;            mute all chanels
;            goto [FX]
;         elsif T128_AY_SongAction = T128_AY_CTRL_LOOPSONG then
;            reset current song
;         end if
;         Play Channel A
;         Play Channel B
;         Play Channel C
;       end if
; [FX]  if FX is enabled then
;         if T128_AY_FXAction = T128_AY_CTRL_ENDFX then
;            Reset priority
;            if (T128_AY_SongAction = T128_AY_CTRL_ENDSONG or Music is not enabled)
;               Mute FX Channel
;            end if
;         else
;            Play FX Channel
;         End if
;       end if
;       update AY Registers
;
T128_AY_PlayerBF1:	ld		a, (T128_AY_Control)
					bit		1, a						; Muted Music?
					jr		nz, AYP_Label_04
					push	af
;
; End Of Song
;
					ld		a, (T128_AY_SongAction)
					cp		T128_AY_CTRL_ENDSONG
					jr		nz, AYP_Label_01
					ld		a, (AY_REG_Mixer)
					or		%00111111					; If End of Song is reached, then mute all channels
					ld		(AY_REG_Mixer), a
					jr		AYP_Label_03
AYP_Label_01:		cp		T128_AY_CTRL_LOOPSONG
					jr		nz, AYP_Label_02
					ld		hl, (AY_CurrentSong)
					xor		a							; Do not execute ei at the end of AYIS_Label_01
					call	AYIS_Label_01
;
; Play channels A, B & C for music
;					
AYP_Label_02:		
					ld		hl, $0018					; hl = 0   l = 24
					ld		de, AY_REG_A_Volume
					ld		bc, AY_REG_A_Pitch
					ld		ix, AY_MusicParametersA
					call	AYP_Play					; Process music on channel A
					
					ld		hl, $0820					; hl = 8   l = 32
					ld		de, AY_REG_B_Volume
					ld		bc, AY_REG_B_Pitch					
					ld		ix, AY_MusicParametersB
					call	AYP_Play					; Process music on channel B
					
					ld		hl, $1028					; hl = 16   l = 40
					ld		de, AY_REG_C_Volume
					ld		bc, AY_REG_C_Pitch					
					ld		ix, AY_MusicParametersC
					call	AYP_Play					; Process music on channel C	
;					
AYP_Label_03:		pop		af
AYP_Label_04: 		bit		0, a						; Muted FX?
					jr		nz, AYP_Label_07
;
; End Of FX
;
					ld		a, (T128_AY_FXAction)
					cp		T128_AY_CTRL_ENDFX
					jr		nz, AYP_Label_06
					xor		a
					ld		(AY_CurrFXPriority), a		; Reset FX priority
					ld		a, (T128_AY_Control)
					bit		1, a						; Muted Music?
					jr		nz, AYP_Label_05
					ld		a, (T128_AY_SongAction)
					cp		T128_AY_CTRL_ENDSONG		; Music stopped?
					jr		nz, AYP_Label_07				
AYP_Label_05:		ld		a, (AY_REG_Mixer)
IF AY_FX_CHANNEL="A"
					or		%00001001					; If End Of FX is reached and End Of Song is reached, then mute channel A
ENDIF					
IF AY_FX_CHANNEL="B"
					or		%00010010					; If End Of FX is reached and End Of Song is reached, then mute channel B
ENDIF
IF AY_FX_CHANNEL="C"
					or		%00100100					; If End Of FX is reached and End Of Song is reached, then mute channel C
ENDIF
					ld		(AY_REG_Mixer), a			
					jp		AY_UpdateAYRegs
;
; Play channel for FX
;
IF AY_FX_CHANNEL="A"					
AYP_Label_06:		ld		hl, $0018					; h = 0   l = 24
					ld		de, AY_REG_A_Volume
					ld		bc, AY_REG_A_Pitch					
ENDIF					
IF AY_FX_CHANNEL="B"					
AYP_Label_06:		ld		hl, $0820					; h = 8   l = 32
					ld		de, AY_REG_B_Volume
					ld		bc, AY_REG_B_Pitch					
ENDIF					
IF AY_FX_CHANNEL="C"					
AYP_Label_06:		ld		hl, $1028					; h = 16  l = 40
					ld		de, AY_REG_C_Volume
					ld		bc, AY_REG_C_Pitch					
ENDIF					
					ld		ix, AY_FX_Parameters
					call	AYP_Play					; Process channel for FX
;					
AYP_Label_07:		jp		AY_UpdateAYRegs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AYP_Play
;
; Process a channel
;
; Input: 
;   h  = Sound Channel (0 = A, 8 = B, 16 = C)
;   l  = noise Channel (24 = A, 32 = B, 40 = C)
;   de = AY_REG_X_Volume (AY_REG_A_Volume / AY_REG_B_Volume / AY_REG_C_Volume)
;   bc = AY_REG_X_Pitch (AY_REG_A_Pitch / AY_REG_B_Pitch / AY_REG_C_Pitch)
;   ix = Channel structure
;  
AYP_Play:			ld		a, RES_N_A					; Do Self Modifying Code
					or		h
					ld		(AYPP_SMC_02+1), a
					ld		a, SET_N_A
					or		h
					ld		(AYPP_SMC_01+1), a					
					ld		a, RES_N_A
					or		l
					ld		(AYPP_SMC_09+1), a
					ld		a, SET_N_A
					or		l
					ld		(AYPP_SMC_08+1), a
					ld		(AYPP_SMC_03+1), bc
					ld		(AYPP_SMC_05+1), bc					
					ld		(AYPP_SMC_04+1), de
					ld		(AYPP_SMC_06+1), de
					ld		(AYPP_SMC_07+1), de
					ld		(AYPP_SMC_10+1), de
					ld		(AYPP_SMC_11+1), de
;
; Setup instrument tick
;					
					ld		l, (ix+AY_PARAM.INST_POS)
					ld		h, (ix+AY_PARAM.INST_POS+1)
					push	hl
					pop		iy
;
; Check for special tick (hardware envelope)
; 
					ld		a, (iy+1)
					bit		7, a
					jr		z, AYPP_Label_00
					ld		(ix+AY_PARAM.ENV_MULT), a
					ld		a, (iy)
					ld		(ix+AY_PARAM.ENV_TYPE), a
					ld		a, (iy+2)
					ld		(ix+AY_PARAM.ENV_DUR), a
					ld		a, (iy+3)
					ld		(ix+AY_PARAM.ENV_DUR+1), a
					ld		e, 1
					call	AYPP_Label_23				; Next intrument tick
;
; Pitch
;					
AYPP_Label_00:		ld		a, (iy+1)
					bit		6, a						; Muted channel for pitch?
					jr		z, AYPP_Label_01
;					
					ld		a, (AY_REG_Mixer)
AYPP_SMC_01:		set		0, a						; Disable sound channel
					ld		(AY_REG_Mixer), a
					jr		AYPP_Label_06
; 
AYPP_Label_01:		ld		e, a
					ld		a, (AY_REG_Mixer)
AYPP_SMC_02:		res		0, a						; Enable sound channel
					ld		(AY_REG_Mixer), a
;
; Frequency Modulation
; 					
					ld		l, (ix+AY_PARAM.CURR_PITCH)
					ld		h, (ix+AY_PARAM.CURR_PITCH+1)
					ld		c, (iy)
					ld		a, e
					and		%00000111
					ld		b, a						; bc = Delta pitch
					bit		3, e						; 1 negative / 0 positive
					jr		z, AYPP_Label_02
					or		a							; carry flag = 0
					sbc		hl, bc
					jp		p, AYPP_Label_03			; Min pitch value = 0
					ld		hl, 0
					jr		AYPP_Label_03
AYPP_Label_02:		add		hl, bc
					ld		a, h
					cp		%00010000
					jr		c, AYPP_Label_03			; Max pitch value = 4095
					ld		hl, 4095
AYPP_Label_03:		bit		4, e						; 0 go / 1 accumulate and go
					jr		z, AYPP_Label_04
					ld		(ix+AY_PARAM.CURR_PITCH), l	; Accumulate
					ld		(ix+AY_PARAM.CURR_PITCH+1), h
;
; Arpeggio/ornament
;					
AYPP_Label_04:		ld		a, (ix+AY_PARAM.ARP_ORN+1)
					or		a
					jr		nz, AYPP_Label_05
					ld		a, (ix+AY_PARAM.ARP_ORN)
					or		a
					jr		z, AYPP_SMC_03
AYPP_Label_05:		ld		c, (ix+AY_PARAM.ARP_ORN)
					ld		b, (ix+AY_PARAM.ARP_ORN+1)
					ld		a, (bc)
					cp		$80
					jr		z, AYPP_SMC_03				; End of arpeggio/ornament
					inc		bc
					ld		(ix+AY_PARAM.ARP_ORN), c
					ld		(ix+AY_PARAM.ARP_ORN+1), b	; Next arpeggio/ornament
					ld		b, (ix+AY_PARAM.BASE_NOTE)
					add		a, b						; New base note
					add		a, a						; Notes < 128
					ld		c, a
					ld		b, 0
					push	hl
					ld		hl, T128_AY_PitchTable
					add		hl, bc
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						
					ld		l, c
					ld		h, b						; hl = new note pitch
					ld		c, (ix+AY_PARAM.BASE_PITCH)
					ld		b, (ix+AY_PARAM.BASE_PITCH+1)
					or		a
					sbc		hl, bc						; hl = pitch difference
					pop		bc							; bc = current pitch
					add		hl, bc 						; add difference
;					
; Save pitch in AY register
;
AYPP_SMC_03:		ld		($0000), hl
;
; Amplitude Modulation
; 
AYPP_Label_06:		ld		a, (ix+AY_PARAM.CURR_AMOP)
					cp		T128_AY_OP_INC
					jr		nz, AYPP_Label_07
					ld		a, (ix+AY_PARAM.CURR_VOL)
					inc		a							; Increment volume
					cp		$10							
					jr		c, AYPP_Label_09			; Max volumn value = $f
					dec		a
					jr		AYPP_Label_09
;					
AYPP_Label_07:		cp		T128_AY_OP_DEC
					jr		nz, AYPP_Label_08
					ld		a, (ix+AY_PARAM.CURR_VOL)					
					dec		a							; Decrement volume
					cp		$ff
					jr		nz, AYPP_Label_09			; Min volumne value = 0
					inc		a
					jr		AYPP_Label_09
;					
AYPP_Label_08:		ld		a, (iy+2)					; No AM operation ==> Instrument volume
					and		%00001111					; Instrument volume
;					
AYPP_Label_09:		ld		(ix+AY_PARAM.CURR_VOL), a	; Save volume in current volume
AYPP_SMC_04:		ld		($0000), a					; Save volume in AY register
					ld		a, (iy+2)					
					and		%11110000
					rrca
					rrca
					rrca
					rrca								; a = Instrument operation
					ld		(ix+AY_PARAM.CURR_AMOP), a	; Save operation in current AM operation for next tick
;
; Hardware envelope
; 
					ld		a, (ix+AY_PARAM.ENV_TYPE)
					cp		$ff
					jr		z, AYPP_Label_12
					; ENVELOPE ON
					ld		(AY_REG_Envelope), a		; Save envelope type
					cp		(ix+AY_PARAM.ENV_PREV)					
					jr		z, AYPP_Label_10
					ld		(ix+AY_PARAM.ENV_PREV), a	; New previous envelope type
					ld		a, 1
					ld		(AY_EnvelopControl) ,a 		; Toggle R13 (only if current type != previos type)
AYPP_Label_10:		ld		b, %00010000				; Volume envelope
					ld		a, (ix+AY_PARAM.ENV_MULT)
					cp		$ff
					jr		z, AYPP_Label_11
					; ENVELOPE: RELATIVE
					and		%00000111					; Relative envelope must be between 0 and 4. Otherwise, sound is distorted
AYPP_SMC_05:		ld		hl, ($0000)
AYPP_Loop_01:		or		a
					jr		z, AYPP_SMC_06
					sra		h
					rr		l
					dec		a
					jr		AYPP_Loop_01
					; ENVELOPE: ABSOLUTE
AYPP_Label_11:		ld		l, (ix+AY_PARAM.ENV_DUR)
					ld		h, (ix+AY_PARAM.ENV_DUR+1)	; Envelope duration. Envelope duration must be lower than 1000. Otherwise, sound is distorted
					jr		AYPP_SMC_06
					;ENVELOPE OFF
AYPP_Label_12:		cp		(ix+AY_PARAM.ENV_PREV)					
					jr		z, AYPP_Label_13
					ld		(ix+AY_PARAM.ENV_PREV), a	; New previous envelope type
					ld		b, 0						; Volume envelope (only if previos type != $ff)
					ld		hl, $ffff					; Envelope duration (only if previos type != $ff)
AYPP_SMC_06:		ld		a, ($0000)					; Get volume register
					or		b
AYPP_SMC_07:		ld		($0000), a					; Save volume register
					ld		(AY_REG_EnvDurL), hl		; Save envelope duration
;
; Noise
;					
AYPP_Label_13:		ld		a, (iy+1)
					bit		5, a						; Muted channel for noise?
					jr		z, AYPP_Label_14
;					
					ld		a, (AY_REG_Mixer)
AYPP_SMC_08:		set		0, a						; Disable noise channel
					ld		(AY_REG_Mixer), a
					jr		AYPP_Label_18
; 
AYPP_Label_14:		ld		a, (AY_REG_Mixer)
AYPP_SMC_09:		res		0, a						; Enable noise channel in AY register
					ld		(AY_REG_Mixer), a										
;
; Noise modulation
; 					
					ld		c, (ix+AY_PARAM.CURR_NOISE)
					ld		a, (iy+3)
					ld		e, a
					and		%00011111
					bit		5, e						; 1 negative / 0 positive
					jr		z, AYPP_Label_15
					sub		c
					jp		p, AYPP_Label_16			; Min noise value = 0
					xor		a
					jr		AYPP_Label_16
AYPP_Label_15:		add		a, c
					cp		$20
					jr		c, AYPP_Label_16			; Max noise value = 31
					ld		a, $1f				
AYPP_Label_16:		bit		6, e						; 0 go / 1 accumulate and go
					jr		z, AYPP_Label_17
					ld		(ix+AY_PARAM.CURR_NOISE), a	; Accumulate
AYPP_Label_17:		ld		(AY_REG_Noise), a			; Save noise in AY register
;
; Fade in/out/off
;
AYPP_Label_18:		ld		a, (ix+AY_PARAM.FADE_TYPE)
					cp		T128_AY_FADEOFF
					jr		z, AYPP_Label_22			
AYPP_SMC_10:		ld		a, ($0000)
					and		%00001111					; Current volume (exclude hardware envelope)
					cp		(ix+AY_PARAM.FADE_CURR)	
					jr		c, AYPP_SMC_11
					ld		a, (ix+AY_PARAM.FADE_CURR)
AYPP_SMC_11:		ld		($0000), a			
					ld		a, (ix+AY_PARAM.FADE_COUNT)
					dec		a
					jr		nz, AYPP_Label_21
					ld		a, (ix+AY_PARAM.FADE_TYPE)
					cp		T128_AY_FADEIN
					jr		nz, AYPP_Label_19
					ld		a, (ix+AY_PARAM.FADE_CURR)
					inc		a
					cp		$10
					jr		nz, AYPP_Label_20
					dec		a
					jr		AYPP_Label_20
AYPP_Label_19:		ld		a, (ix+AY_PARAM.FADE_CURR)
					dec		a
					cp		$ff
					jr		nz, AYPP_Label_20
					inc		a
AYPP_Label_20		ld		(ix+AY_PARAM.FADE_CURR), a					
					ld		a, (ix+AY_PARAM.FADE_SPEED)
AYPP_Label_21:		ld		(ix+AY_PARAM.FADE_COUNT), a
;
; Set up next tick
;					
AYPP_Label_22:		ld		e, 0
AYPP_Label_23:		ld		a, (ix+AY_PARAM.INST_COUNT)
					inc		a
					cp		(ix+AY_PARAM.INST_LEN)		; End of instrument?
					jr		z, AYPP_Label_25
					ld		bc, 4
					push	iy
					pop		hl
					add		hl, bc
AYPP_Label_24:		ld		(ix+AY_PARAM.INST_COUNT), a	; Next instrument position (counter)
					ld		(ix+AY_PARAM.INST_POS), l	; Next instrument position (address)
					ld		(ix+AY_PARAM.INST_POS+1), h
;
; Check note duration
;
					ld		a, e
					or		a
					ret		nz							; If we are here after a call AYPP_Label_23, then do not check note duration
					ld		a, (ix+AY_PARAM.DURATION)
					dec		a							; Decrement duration
					jr		z, AYPP_Label_26			; End of note?
					ld		(ix+AY_PARAM.DURATION), a					
					ret									
;
; Instrument loop
;					
AYPP_Label_25:		ld		a, (ix+AY_PARAM.INST_LOOPI)
					ld 		l, (ix+AY_PARAM.INST_LOOP)
					ld 		h, (ix+AY_PARAM.INST_LOOP+1)
					jr		AYPP_Label_24
;
; Next note
;					
AYPP_Label_26:		ld		e, (ix+AY_PARAM.CURR_NOTE)
					ld		d, (ix+AY_PARAM.CURR_NOTE+1)
					inc		de
					inc		de
					inc		de
					inc		de
					ld		a, (de)
					cp		T128_AY_CTRL_EOP
					jr		z, AYPP_Label_27			; End of Pattern?
					jp		AY_InitNote					; Next note
;
; Next pattern
;					
AYPP_Label_27:		ld		e, (ix+AY_PARAM.CURR_PATT)
					ld		d, (ix+AY_PARAM.CURR_PATT+1)
					inc		de
					inc		de
					ld		a, (de)
					ld		b, a
					inc		de
					ld		a, (de)
					cp 		T128_AY_CTRL_EOS
					jr		z, AYPP_Label_28			; End Of Song?
					dec		de
					jp 		AY_InitPattern				; Next pattern
;
; End of Song
;					
AYPP_Label_28:		ld		a, b
					cp		T128_AY_CTRL_ENDFX
					jr		nz, AYPP_Label_29
					ld		(T128_AY_FXAction), a		; Set ENDFX for FX
IF AY_FX_CHANNEL="A"
					ld		hl, AY_MusicParametersA + AY_PARAM.ENV_PREV
ENDIF					
IF AY_FX_CHANNEL="B"
					ld		hl, AY_MusicParametersB + AY_PARAM.ENV_PREV					
ENDIF
IF AY_FX_CHANNEL="C"
					ld		hl, AY_MusicParametersC + AY_PARAM.ENV_PREV					
ENDIF
					ld		(hl), $ef					; A little trick to reset envelope for music					
					ret
AYPP_Label_29:		ld		(T128_AY_SongAction), a		; Set ENDSONG or LOOPSONG for Music
					ret
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AY_InitPattern
;
; Setup a pattern within a channel
;
; Input:
;   de = Current pattern pointer
;   ix = Channel structure
;
AY_InitPattern:		push	hl
					ld		(ix+AY_PARAM.CURR_PATT), e	; Current pattern pointer
					ld		(ix+AY_PARAM.CURR_PATT+1), d
					ex		de, hl
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					call	AY_InitNote
					pop		hl
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AY_InitNote
;
; Setup a note within a channel
;
; Input:
;   de = Current note pointer
;   ix = Channel structure
;
AY_InitNote:		ld		(ix+AY_PARAM.ENV_TYPE), $ff	; Reset envelope type
					ld		(ix+AY_PARAM.ENV_PREV), $ff	; Reset envelope type (previous value)
					ld		a, (de)						; check fade in/out/off
					ld		b, 15
					cp		T128_AY_FADEOUT
					jr		z, AYIN_Label_01
					ld		b, 0
					cp		T128_AY_FADEIN
					jr		z, AYIN_Label_01					
					cp		T128_AY_FADEOFF
					jr		z, AYIN_Label_01
					jr		AYIN_Label_02
;
; Set up Fade in, fade out or fade off
; 					
AYIN_Label_01:		ld		(ix+AY_PARAM.FADE_TYPE), a
					inc		de
					ld		a, (de)
					ld		(ix+AY_PARAM.FADE_SPEED), a
					ld		(ix+AY_PARAM.FADE_COUNT), a
					ld		(ix+AY_PARAM.FADE_CURR), b
					inc		de
					jr		AYPP_Label_27
;
; Process note
;
AYIN_Label_02:		ld		(ix+AY_PARAM.CURR_NOTE), e	; Current note pointer
					ld		(ix+AY_PARAM.CURR_NOTE+1), d					
					inc		de
					ld		(ix+AY_PARAM.BASE_NOTE), a	; a = base note index
					add		a, a						; Notes < 128
					ld		c, a
					ld		b, 0
					ld		hl, T128_AY_PitchTable
					add		hl, bc
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = note pitch
					ld		(ix+AY_PARAM.BASE_PITCH), c
					ld		(ix+AY_PARAM.BASE_PITCH+1), b
					ld		(ix+AY_PARAM.CURR_PITCH), c
					ld		(ix+AY_PARAM.CURR_PITCH+1), b
					ld		a, (de)						; a = duration
					inc		de
					ld		(ix+AY_PARAM.DURATION), a
					ld		a, (de)
					push	af							; save arpeggio/ornament

					and		%00111111					; a = Instrument

					inc		de
					add		a, a						
					ld		c, a
					ld		b, 0
					ld		hl, AYP_Instruments
					add		hl, bc
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = Instrument definition
					ld		a, (bc)						; Instrument length
					inc		bc
					ld		(ix+AY_PARAM.INST_LEN), a
					xor		a
					ld		(ix+AY_PARAM.CURR_AMOP), a	; Current AM operation = none
					ld		(ix+AY_PARAM.INST_COUNT), a	; Instrument counter
					ld		a, (bc)						; Instrument loop position
					inc		bc
					ld		(ix+AY_PARAM.INST_LOOPI), a	; Instrument loop position (index)					
					ld		(ix+AY_PARAM.INST_POS), c	; Instrument position (address)
					ld		(ix+AY_PARAM.INST_POS+1), b
					add		a, a
					add		a, a						; Instrument ticks < 64
					ld		l, a
					ld		h, 0
					add		hl, bc
					ld		(ix+AY_PARAM.INST_LOOP), l	; Instrument loop position (address)
					ld		(ix+AY_PARAM.INST_LOOP+1), h
					pop		af							; restore arpeggio/ornament

					and		%11000000
					rlca
					rlca
					ld		b, a
					ld		a, (de)
					push	af
					and		%11100000
					rrca
					rrca
					rrca
					or		b							; a = arpeggio/ornament 
					cp		%00011111
					jr		z, AYIN_Label_03
					add		a, a						; a = arp/orn * 2
;					and		%11110000					
;					cp		%11110000					
;					jr		z, AYIN_Label_03
;					rrca								
;					rrca
;					rrca								; a = arp/orn * 2

					ld		c, a
					ld		b, 0
					ld		hl, T128_AY_ArpOrn
					add		hl, bc
					ld		c, (hl)
					inc		hl
					ld		b, (hl)						; bc = Arpeggio/ornament (address)
					jr		AYIN_Label_04
AYIN_Label_03:		ld		bc, 0						; No arpeggio/ornament
AYIN_Label_04:		ld		(ix+AY_PARAM.ARP_ORN), c
					ld		(ix+AY_PARAM.ARP_ORN+1), b	; Arpeggio/ornament (address)

					pop		af
					and		%00011111					; a = noise color
;					ld		a, (de)						; a = noise color

					ld		(ix+AY_PARAM.CURR_NOISE), a	;
	 				ret					


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AY_UpdateAYRegs
;
; Update AY registers
;
AY_UpdateAYRegs:	xor		a
					ld 		de, $ffbf
					ld		bc, #fffd
					ld 		hl, AY_REG_A_Pitch
AYUAYR_Loop_01:		out		(c), a
					ld		b, e
					outi 
					ld		b, d
					inc		a
					cp		AY_ENVELOPE
					jr		nz,	AYUAYR_Loop_01
;
					out 	(c), a
					ld		a, (AY_EnvelopControl)
					or		a
					ret		z
					ld		a, (hl)
					ld		b, e
					out		(c), a
					xor		a
					ld		(AY_EnvelopControl), a
					ret
					
					
					