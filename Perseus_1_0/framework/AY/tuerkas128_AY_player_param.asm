;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; A Y   P L A Y E R   P A R A M E T E R S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_PARAM_AY_PLAYER
_BEGIN_PARAM_AY_PLAYER:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FX channel
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AY_FX_CHANNEL		EQU		"A"							; A, B or C


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; AY Registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AY_REG				EQU		$fffd						; Register port
AY_DATA				EQU		$bffd						; Data port
AY_A_PITCH_L		EQU		0							; 8 bit
AY_A_PITCH_H		EQU		1							; 4 bit frecuency = 1773500 / (16*CHANEL_A_PITCH)
AY_B_PITCH_L		EQU		2							; 8 bit
AY_B_PITCH_H		EQU		3							; 4 bit frecuency = 1773500 / (16*CHANEL_B_PITCH)
AY_C_PITCH_L		EQU		4							; 8 bit
AY_C_PITCH_H		EQU		5							; 4 bit frecuency = 1773500 / (16*CHANEL_B_PITCH)
AY_NOISE_PITCH		EQU		6							; 5 bit frecuency = 1773500 / (16*NOISE_PITCH)
AY_MIXER			EQU		7							; bits 0-1-2: Mute sound channels A-B-C     bits 3-4-5: Mute noise channels A-B-C
AY_A_VOLUME			EQU		8							; bits 0-3 volumne channel A (0 min / 15 max)    bit 4: envelope on/off on channel A
AY_B_VOLUME			EQU		9							; bits 0-3 volumne channel B (0 min / 15 max)    bit 4: envelope on/off on channel B
AY_C_VOLUME			EQU		10							; bits 0-3 volumne channel C (0 min / 15 max)    bit 4: envelope on/off on channel C
AY_ENVELOPE_DUR_L	EQU		11							; 8 bit 
AY_ENVELOPE_DUR_H	EQU		12							; 8 bit frecuency = 1773500 / (256 * ENVELOPE_DUR)
AY_ENVELOPE			EQU		13							; 4 bit (buscar equivalencia)
														; 0-3:  \__________ (decay - silence)
														; 4-7:  /|_________ (attack - silence)
														; 8:    \|\|\|\|\|\ (repeated decay)
														; 9:    \__________ (decay - silence)
														; 10:   \/\/\/\/\/\ (repeated decay/attack)
														; 11:   \|^^^^^    (decay - max volume)
														; 12:   /|/|/|/|/|/ (repeated attack)
														; 13:   /^^^^^      (attack - max volume)
														; 14:   /\/\/\/\/\/ (repeated attack/decay)
														; 15:   /|_________ (attack - silence)
AY_IO_PORT_A		EQU		14							; 8 bit
AY_IO_PORT_B		EQU		15							; 8 bit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Constants
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_AY_PLAY		EQU		0
T128_AY_MUTE		EQU		1
T128_AY_OP_ADD		EQU		0
T128_AY_OP_ADD_ACC	EQU		1
T128_AY_NEGATIVE	EQU		1
T128_AY_POSITIVE	EQU		0
T128_AY_OP_NONE		EQU		%00000000
T128_AY_OP_INC		EQU		%00000001
T128_AY_OP_DEC		EQU		%00000010


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Macros: INSTRUMENTS
;
; An instrument is defined by a set of instrument ticks preceded by a header
; The header consists of 2 bytes, including the number of ticks of the instrument and the looping tick
; NUmber of ticks must be < 64
;
; Example:
;
;	defb	6, 1	; 6 ticks (0 through 5), looping back to tick #1
;	M_AY_INST_TICK_ENV_ABS 14, 250
;	M_AY_INST_TICK T128_AY_PLAY, T128_AY_OP_ADD, T128_AY_NEGATIVE, 100, T128_AY_OP_NONE, $0F, T128_AY_MUTE, 0, 0, 0
;	M_AY_INST_TICK_ENV_REL 14, 3
;	M_AY_INST_TICK T128_AY_PLAY, T128_AY_OP_ADD, T128_AY_POSITIVE, 100, T128_AY_OP_DEC,  $0E, T128_AY_MUTE, 0, 0, 0
;	M_AY_INST_TICK_ENV_OFF
;	M_AY_INST_TICK T128_AY_PLAY, T128_AY_OP_ADD, T128_AY_POSITIVE, 000, T128_AY_OP_DEC,  $0E, T128_AY_MUTE, 0, 0, 0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_INST_TICK
;
; Define an instrument tick.

; MAI_SOUND			= Sound: 0 on / 1 mute  [S]
; MAI_FM_OP			= Frequency Modultation operation: 0 go / 1 accumulate and go  [O]
; MAI_FM_SIGN		= Sign for delta pitch: 1 negative / 0 positive  [I]
; MAI_FM			= Delta pitch for Frequency Modulation (11 bits)  [FFFFFFFFFFF]
; MAI_AM_OP			= Amplitude Modulation operation (2 bits): 00 none / 01 Increase / 10 Decrease / 11 not used  [PP]
; MAI_AM			= Volume (4 bits)  [AAAA]
; MAI_NOISE			= Noise: 0 on / 1 mute  [N]
; MAI_NOISE_OP		= Noise operation: 0 add / 1 add and accumulate  [E]
; MAI_NOISE_SIGN	= Sign for noise color: 1 negative / 0 positive  [G]
; MAI_NOISE_COLOR	= Delta noise color (5 bits)  [CCCCC]
;
; These parameters are compressed into 4 bytes:
;
;   Byte 0 : FFFFFFFF
;   Byte 1 : 0SNOIFFF (Bit 7 will never be equal to 1. This is used to detect special ticks for hardware envelope) 
;   Byte 2 : 00PPAAAA
;   Byte 3 : 0EGCCCCC
;
M_AY_INST_TICK MACRO MAI_SOUND, MAI_FM_OP, MAI_FM_SIGN, MAI_FM, MAI_AM_OP, MAI_AM, MAI_NOISE, MAI_NOISE_OP, MAI_NOISE_SIGN, MAI_NOISE_COLOR
					defw	(MAI_SOUND SHL 14) + (MAI_NOISE SHL 13) + (MAI_FM_OP SHL 12) + (MAI_FM_SIGN SHL 11)  + MAI_FM
					defb	(MAI_AM_OP SHL 4) + MAI_AM 
					defb	(MAI_NOISE_OP SHL 6) + (MAI_NOISE_SIGN SHL 5) + MAI_NOISE_COLOR
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_INST_TICK_ENV_ABS
;
; Define an special instrument tick for hardware envelope (abosulte frequency)
;
; MAI_TYPE     = Envelope shape (0 to 15; see top of this file)
; MAI_DURATION = Duration 1773500/(256*frecuency).
;                Duration is limited to 1000. Otherwise, sound is distorted.
;
M_AY_INST_TICK_ENV_ABS MACRO MAI_TYPE, MAI_DURATION
					defb	MAI_TYPE, $ff				; Bit 7 of byte 1 is equal to 1
					defw	(MAI_DURATION>1000 ? 1000 : MAI_DURATION)
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_INST_TICK_ENV_REL
;
; Define an special instrument tick for hardware envelope (relative frequency)
;
; MAI_TYPE = Envelope shape (0 to 15; see top of this file)
; MAI_DIV  = Divisor of pitch frequency
;            Divisor is limited to 4. Otherwise, sound is distorted,
;            0 pitch frecuency is divided by 1
;            1 pitch frecuency is divided by 2
;            2 pitch frecuency is divided by 4
;            3 pitch frecuency is divided by 8
;            4 pitch frecuency is divided by 16
;
M_AY_INST_TICK_ENV_REL MACRO MAI_TYPE, MAI_DIV
					defb	MAI_TYPE, ((MAI_DIV>4 ? 4 : MAI_DIV) OR %10000000)	; Bit 7 of byte 1 is equal to 1
					defw	$ffff
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_INST_TICK_ENV_OFF
;
; Define an special instrument tick for hardware envelope: disable envelope
;
M_AY_INST_TICK_ENV_OFF MACRO
					defb	$ff, $ff					; Bit 7 of byte 1 is equal to 1
					defw	$ffff
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Macros: NOTES
;
; A pattern is defined by a set of notes, ended by an End Of Pattern (EOP) tag
;
; Example:
;
;	M_AY_NOTE T128_AY_A_4, 16, 03, 01, $1F
;	M_AY_NOTE T128_AY_C_4, 16, 03, 01, $1F
;	M_AY_NOTE T128_AY_E_4, 16, 03, 01, $1F
;	M_AY_END_OF_PATT
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_NOTE
;
; Define a note
;
; MAN_NOTE			= Note index (must be < 128 ; See list below)
; MAN_DURATION		= Duration in 1/50th of a second
; MAN_INSTRUMENT	= Instrumment number (6 bits)
; MAN_ARPEGGIO		= Arpeggio/ornament number (5 bits). Predefined arp/orn at the end of this file must be used. Feel free to modify or add new arp/orn
; MAN_NOISE_COLOR	= Noise color (5 bits)
;
; These parameters are compressed into 3 bytes:
;
;   Byte 0 : Note index
;   Byte 1 : Duration
;   Byte 2 : AAIIIIII  AA = Arpeggio/ornament (bits 1-0)		IIIIII = Instrument
;   Byte 3 : AAACCCCC  AAA = Arpeggio/ornament (bits 4-3-2)		CCCCC = Noise color
;
M_AY_NOTE MACRO MAN_NOTE, MAN_DURATION, MAN_INSTRUMENT, MAN_ARPEGGIO, MAN_NOISE_COLOR
					defb	MAN_NOTE, MAN_DURATION
					defb	((MAN_ARPEGGIO AND %00000011) SHL 6) + MAN_INSTRUMENT
					defb	((MAN_ARPEGGIO AND %00011100) SHL 3) + MAN_NOISE_COLOR
ENDM

;M_AY_NOTE MACRO MAN_NOTE, MAN_DURATION, MAN_INSTRUMENT, MAN_ARPEGGIO, MAN_NOISE_COLOR
;					defb	MAN_NOTE, MAN_DURATION
;					defb	(MAN_ARPEGGIO SHL 4) + MAN_INSTRUMENT
;					defb	MAN_NOISE_COLOR
;ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_END_OF_PATT
;
; End Of Pattern markup 
;
M_AY_END_OF_PATT MACRO 
					defb	T128_AY_CTRL_EOP
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Macros: CONTROL
;
; Control patterns and markups
;
; M_AY_END_OF_SONG, M_AY_LOOP_SONG and M_AY_END_OF_FX must be used at song level in every channel.
;
; M_AY_FADEIN, M_AY_FADEOUT and M_AY_FADEOFF must be used at song level in every channel.
; For this control patters, it is recomended to use predefined patterns defined at the end of this file. Example, for channel A:
;
; T128_AY_Song00:	defw	Song00Channel_A, Song00Channel_B, Song00Channel_C
; Song00Channel_A:	defw	PatternFadeIn_1s, S00_A_Pattern01
;					defw	PatternFadeOut_1s, S00_A_Pattern02
;					M_AY_LOOP_SONG
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_FADEIN
;
; Special pattern for fade in software effect
;
M_AY_FADEIN MACRO MAF_SPEED
					defb	T128_AY_FADEIN
					defb	MAF_SPEED
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_FADEOUT
;
; Special pattern for fade OUT software effect
;
M_AY_FADEOUT MACRO MAF_SPEED
					defb	T128_AY_FADEOUT
					defb	MAF_SPEED
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_FADEOFF
;
; Special pattern for fade OUT software effect
;
M_AY_FADEOFF MACRO 
					defb	T128_AY_FADEOFF
					defb	1
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_END_OF_SONG
;
; End Of Song markup. Stop song
;
M_AY_END_OF_SONG MACRO 
					defb	T128_AY_CTRL_ENDSONG, T128_AY_CTRL_EOS
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_LOOP_SONG
;
; End Of Song markup. Stop song and go to the begin of the song
;
M_AY_LOOP_SONG MACRO 
					defb	T128_AY_CTRL_LOOPSONG, T128_AY_CTRL_EOS
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M_AY_END_OF_FX
;
; End Of FX markup 
;
M_AY_END_OF_FX MACRO 
					defb	T128_AY_CTRL_ENDFX, T128_AY_CTRL_EOS
ENDM


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Indexes for every note in the lookup table T128_AY_PitchTable
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_AY_C_0			EQU		0
T128_AY_C_S_0		EQU		1
T128_AY_D_0			EQU		2
T128_AY_D_S_0		EQU		3
T128_AY_E_0			EQU		4
T128_AY_F_0			EQU		5
T128_AY_F_S_0		EQU		6
T128_AY_G_0			EQU		7
T128_AY_G_S_0		EQU		8
T128_AY_A_0			EQU		9
T128_AY_A_S_0		EQU		10
T128_AY_B_0			EQU		11
T128_AY_C_1			EQU		12
T128_AY_C_S_1		EQU		13
T128_AY_D_1			EQU		14
T128_AY_D_S_1		EQU		15
T128_AY_E_1			EQU		16
T128_AY_F_1			EQU		17
T128_AY_F_S_1		EQU		18
T128_AY_G_1			EQU		19
T128_AY_G_S_1		EQU		20
T128_AY_A_1			EQU		21
T128_AY_A_S_1		EQU		22
T128_AY_B_1			EQU		23
T128_AY_C_2			EQU		24
T128_AY_C_S_2		EQU		25
T128_AY_D_2			EQU		26
T128_AY_D_S_2		EQU		27
T128_AY_E_2			EQU		28
T128_AY_F_2			EQU		29
T128_AY_F_S_2		EQU		30
T128_AY_G_2			EQU		31
T128_AY_G_S_2		EQU		32
T128_AY_A_2			EQU		33
T128_AY_A_S_2		EQU		34
T128_AY_B_2			EQU		35
T128_AY_C_3			EQU		36
T128_AY_C_S_3		EQU		37
T128_AY_D_3			EQU		38
T128_AY_D_S_3		EQU		39
T128_AY_E_3			EQU		40
T128_AY_F_3			EQU		41
T128_AY_F_S_3		EQU		42
T128_AY_G_3			EQU		43
T128_AY_G_S_3		EQU		44
T128_AY_A_3			EQU		45
T128_AY_A_S_3		EQU		46
T128_AY_B_3			EQU		47
T128_AY_C_4			EQU		48
T128_AY_C_S_4		EQU		49
T128_AY_D_4			EQU		50
T128_AY_D_S_4		EQU		51
T128_AY_E_4			EQU		52
T128_AY_F_4			EQU		53
T128_AY_F_S_4		EQU		54
T128_AY_G_4			EQU		55
T128_AY_G_S_4		EQU		56
T128_AY_A_4			EQU		57
T128_AY_A_S_4		EQU		58
T128_AY_B_4			EQU		59
T128_AY_C_5			EQU		60
T128_AY_C_S_5		EQU		61
T128_AY_D_5			EQU		62
T128_AY_D_S_5		EQU		63
T128_AY_E_5			EQU		64
T128_AY_F_5			EQU		65
T128_AY_F_S_5		EQU		66
T128_AY_G_5			EQU		67
T128_AY_G_S_5		EQU		68
T128_AY_A_5			EQU		69
T128_AY_A_S_5		EQU		70
T128_AY_B_5			EQU		71
T128_AY_C_6			EQU		72
T128_AY_C_S_6		EQU		73
T128_AY_D_6			EQU		74
T128_AY_D_S_6		EQU		75
T128_AY_E_6			EQU		76
T128_AY_F_6			EQU		77
T128_AY_F_S_6		EQU		78
T128_AY_G_6			EQU		79
T128_AY_G_S_6		EQU		80
T128_AY_A_6			EQU		81
T128_AY_A_S_6		EQU		82
T128_AY_B_6			EQU		83
T128_AY_C_7			EQU		84
T128_AY_C_S_7		EQU		85
T128_AY_D_7			EQU		86
T128_AY_D_S_7		EQU		87
T128_AY_E_7			EQU		88
T128_AY_F_7			EQU		89
T128_AY_F_S_7		EQU		90
T128_AY_G_7			EQU		91
T128_AY_G_S_7		EQU		92
T128_AY_A_7			EQU		93
T128_AY_A_S_7		EQU		94
T128_AY_B_7			EQU		95
T128_AY_C_8			EQU		96
T128_AY_C_S_8		EQU		97
T128_AY_D_8			EQU		98
T128_AY_D_S_8		EQU		99
T128_AY_E_8			EQU		100
T128_AY_F_8 		EQU		101
T128_AY_F_S_8		EQU		102
T128_AY_G_8			EQU		103
T128_AY_G_S_8		EQU		104
T128_AY_A_8			EQU		105
T128_AY_A_S_8		EQU		106
T128_AY_B_8			EQU		107
T128_AY_C_9			EQU		108
T128_AY_C_S_9		EQU		109
T128_AY_D_9			EQU		110
T128_AY_D_S_9		EQU		111
T128_AY_E_9			EQU		112
T128_AY_F_9 		EQU		113
T128_AY_F_S_9		EQU		114
T128_AY_G_9			EQU		115
T128_AY_G_S_9		EQU		116
T128_AY_A_9			EQU		117
T128_AY_A_S_9		EQU		118
T128_AY_B_9			EQU		119
; Special Notes
T128_AY_FADEOFF		EQU		$80
T128_AY_FADEIN		EQU		$81
T128_AY_FADEOUT		EQU		$82


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Tempos
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_AY_TEMPO50		EQU		50
T128_AY_TEMPO32		EQU		32
T128_AY_TEMPO25		EQU		50
T128_AY_TEMPO16		EQU		16
T128_AY_TEMPO12		EQU		12
T128_AY_TEMPO8		EQU		8
T128_AY_TEMPO6		EQU		8
T128_AY_TEMPO5		EQU		5
T128_AY_TEMPO4		EQU		4
T128_AY_TEMPO3		EQU		3
T128_AY_TEMPO2		EQU		2
T128_AY_TEMPO1		EQU		1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Lookup table for AY periods corresponding to every note (12-bit value, ranging from 0 to 4095)
; It is limited to 10 scales
;
; AY period = 1773500 / (16*frecuency)
;
; For instance, an A in 4th octave has frecuency of 440 Hz  ==>  AY period = 1773500 / (16*440) = 251.9 = 252
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T128_AY_PitchTable	defw	4095, 4095, 4095, 4095, 4095, 4095, 4095, 4095, 4095, 4031, 3804, 3591	; Octave 0
					defw	3389, 3199, 3020, 2850, 2690, 2539, 2397, 2262, 2135, 2015, 1902, 1795	; Octave 1
					defw	1695, 1600, 1510, 1425, 1345, 1270, 1198, 1131, 1068, 1008, 951, 898	; Octave 2
					defw	847, 800, 755, 713, 673, 635, 599, 566, 534, 504, 476, 449				; Octave 3
					defw	424, 400, 377, 356, 336, 317, 300, 283, 267, 252, 238, 224				; Octave 4
					defw	212, 200, 189, 178, 168, 159, 150, 141, 133, 126, 119, 112				; Octave 5
					defw	106, 100, 94, 89, 84, 79, 75, 71, 67, 63, 59, 56						; Octave 6
					defw	53, 50, 47, 45, 42, 40, 37, 35, 33, 31, 30, 28							; Octave 7
					defw	26, 25, 24, 22, 21, 20, 19, 18, 17, 16, 15, 14							; Octave 8
					defw	13, 13, 12, 11, 11, 10, 10, 9, 9, 8, 8, 7								; Octave 9


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Predefined Fade in, fade out and fade off patterns
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PatternFadeIn_0.5s	M_AY_FADEIN 25/15
PatternFadeIn_1s	M_AY_FADEIN 50/15
PatternFadeIn_1.5s	M_AY_FADEIN 75/15
PatternFadeIn_2s	M_AY_FADEIN 100/15
PatternFadeIn_2.5s	M_AY_FADEIN 125/15
PatternFadeIn_3s	M_AY_FADEIN 150/15
PatternFadeIn_3.5s	M_AY_FADEIN 175/15
PatternFadeIn_4s	M_AY_FADEIN 200/15
PatternFadeIn_4.5s	M_AY_FADEIN 250/15
PatternFadeIn_5s	M_AY_FADEIN 300/15
PatternFadeIn_5.5s	M_AY_FADEIN 350/15
PatternFadeIn_6s	M_AY_FADEIN 400/15
PatternFadeIn_6.5s	M_AY_FADEIN 450/15
PatternFadeIn_7s	M_AY_FADEIN 500/15
PatternFadeIn_7.5s	M_AY_FADEIN 550/15
PatternFadeIn_8s	M_AY_FADEIN 600/15
PatternFadeIn_8.5s	M_AY_FADEIN 650/15
PatternFadeIn_9s	M_AY_FADEIN 700/15

PatternFadeOut_0.5s	M_AY_FADEOUT 25/15
PatternFadeOut_1s	M_AY_FADEOUT 50/15
PatternFadeOut_1.5s	M_AY_FADEOUT 75/15
PatternFadeOut_2s	M_AY_FADEOUT 100/15
PatternFadeOut_2.5s	M_AY_FADEOUT 125/15
PatternFadeOut_3s	M_AY_FADEOUT 150/15
PatternFadeOut_3.5s	M_AY_FADEOUT 175/15
PatternFadeOut_4s	M_AY_FADEOUT 200/15
PatternFadeOut_4.5s	M_AY_FADEOUT 250/15
PatternFadeOut_5s	M_AY_FADEOUT 300/15
PatternFadeOut_5.5s	M_AY_FADEOUT 350/15
PatternFadeOut_6s	M_AY_FADEOUT 400/15
PatternFadeOut_6.5s	M_AY_FADEOUT 450/15
PatternFadeOut_7s	M_AY_FADEOUT 500/15
PatternFadeOut_7.5s	M_AY_FADEOUT 550/15
PatternFadeOut_8s	M_AY_FADEOUT 600/15
PatternFadeOut_8.5s	M_AY_FADEOUT 650/15
PatternFadeOut_9s	M_AY_FADEOUT 700/15

PatternFadeOff:		M_AY_FADEOFF

