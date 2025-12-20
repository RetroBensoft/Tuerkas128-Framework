;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; I N T E R F A C E   F U N C T I O N S   F O R   B A N K   0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC AYIFX_SMC_01_B0, AYIS_SMC_01_B0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitFXB0
;
; Call T128_AY_InitFXBF1 through T128_AY_InitFX in bank 2
;
; Input:
;   a = FX number
;
T128_AY_InitFXB0:	ld		b, 0						; Return to bank 0 after calling T128_AY_InitFXBF1
AYIFX_SMC_01_B0:	jp		$0000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_AY_InitSongB0
;
; Call T128_AY_InitSongBF1 through T128_AY_InitSong in bank 2
;
; Input:
;   a = Song number
;
T128_AY_InitSongB0:	ld		b, 0						; Return to bank 0 after calling T128_AY_InitFXBF1
AYIS_SMC_01_B0:		jp		$0000
