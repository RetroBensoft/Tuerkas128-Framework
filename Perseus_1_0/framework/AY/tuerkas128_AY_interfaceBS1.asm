;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; I N T E R F A C E   F U N C T I O N S   F O R   B A N K   S L O W   1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC AYIFX_SMC_01_BS1, AYIS_SMC_01_BS1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitFXBS1
;
; Call T128_AY_InitFXBF1 from bank S1 through T128_AY_InitFX in bank 2
;
; Input:
;   a = FX number
;
T128_AY_InitFXBS1:	ld		c, a
					ld		a, (T128_SlowBank1)
					ld		b, a						; Return to bank S1 after calling T128_AY_InitFXBF1
					ld		a, c
AYIFX_SMC_01_BS1:	jp		$0000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitSongBS1
;
; Call T128_AY_InitSongBF1 from bank S1 through T128_AY_InitSong in bank 2
;
; Input:
;   a = Song number
;
T128_AY_InitSongBS1:ld		c, a
					ld		a, (T128_SlowBank1)
					ld		b, a						; Return to bank S1 after calling T128_AY_InitFXBF1
					ld		a, c
AYIS_SMC_01_BS1:	jp		$0000
