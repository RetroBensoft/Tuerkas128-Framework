;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; M E N U   R O U T I N E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_MENU
_BEGIN_CODE_MENU


PUBLIC M_SMC_01_BS1										; This label must exists and it must contain jp $0
														; It is used to launch the game
														; $0 is substituted in T128_DynamicLinks by GameSetup in Bank 2					
PUBLIC T128_GameOverBS1									; This routine must exists
														; T128_GameOverBS1 is called to process game over
PUBLIC T128_TheEnd1BS1									; Ad hoc routine for The End #1
PUBLIC T128_TheEnd1BS2									; Ad hoc routine for The End #2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CONSTANTS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MENU_TITLE_ATTR		EQU		T128_BLACK_RED

MENU_OPTIONS_NUMBER	EQU		6
MENU_OPTIONS_POSX	EQU		11
MENU_OPTIONS_POSY	EQU		9
MENU_OPTIONS_POS	EQU		((MENU_OPTIONS_POSY AND %00000111) SHL 5) + 0 + (%01000000 + (MENU_OPTIONS_POSY AND %11111000))*256
MENU_OPTIONS_POSATTR EQU	$5800 + (MENU_OPTIONS_POSY)*32 + MENU_OPTIONS_POSX
MENU_OPTIONS_ATTR1	EQU		T128_BLACK_CYAN_DK
MENU_OPTIONS_ATTR2	EQU		T128_BLACK_YELLOW_DK
;
MENU_SELECTED_ATTR	EQU		T128_BLACK_WHITE
;
MENU_REDEFINE_POSX	EQU		11
MENU_REDEFINE_POSY	EQU		13
MENU_REDEFINE_POS	EQU		(((MENU_REDEFINE_POSY-1) AND %00000111) SHL 5) + (MENU_REDEFINE_POSX-3) + (%01000000 + ((MENU_REDEFINE_POSY-1) AND %11111000))*256
MENU_REDEFINE_POSATTR EQU	$5800 + (MENU_REDEFINE_POSY-1)*32 + (MENU_REDEFINE_POSX-3)
MENU_REDEFINE_ATTR	EQU		T128_BLUE_WHITE

MENU_GAMEOVER_POSX	EQU		10
MENU_GAMEOVER_POSY	EQU		10
MENU_GAMEOVER_POS	EQU 	((MENU_GAMEOVER_POSY AND %00000111) SHL 5) + MENU_GAMEOVER_POSX + (%01000000 + (MENU_GAMEOVER_POSY AND %11111000))*256
MENU_GAMEOVER_POSATTR0 EQU	$5800 + (MENU_GAMEOVER_POSY-1)*32 + (MENU_GAMEOVER_POSX-1)
MENU_GAMEOVER_POSATTR EQU	$5800 + MENU_GAMEOVER_POSY*32 + MENU_GAMEOVER_POSX
MENU_GAMEOVER_ATTR	EQU		T128_GREEN_BLACK
MENU_GAMEOVER_ATTR0 EQU		T128_GREEN_GREEN_DK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DATA
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Menu options
;
MenuOptions:		defw	MenuOption0, MenuOption1, MenuOption2, MenuOption3, MenuOption4, MenuOption5 

MenuOption0:		defb	$23							; Key code
					defw	M_Label_00					; Routine
					defm	"0 INTRO "					; Text
					defb	0							; End of text
;					
MenuOption1:		defb	$24							; Key code
					defw	M_Label_10					; Routine
					IF T128_LANGUAGE=0					; Text
					defm	"1 TECLADO "                
					ENDIF
					IF T128_LANGUAGE=1
					defm	"1 KEYBOARD "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"1 TECLADO "
					ENDIF
					defb	0							; End of Text
;					
MenuOption2:		defb	$1C							; Key code
					defw	M_Label_20					; Routine
					IF T128_LANGUAGE=0					; Text
					defm	"2 REDEFINIR "              
					ENDIF
					IF T128_LANGUAGE=1
					defm	"2 REDEFINE "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"2 REDEFINIR "
					ENDIF
					defb	0							; End of text
;
MenuOption3:		defb	$14							; Key code
					defw	M_Label_30					; Routine
					defm	"3 SINCLAIR "				; Text
					defb	0							; End of text
;					
MenuOption4:		defb	$0C							; Key code
					defw	M_Label_40					; Routine
					defm	"4 KEMPSTON "				; Text
					defb	0							; End of text
;					
MenuOption5:		defb	$04							; Key code
					defw	M_Label_50					; Routine
					IF T128_LANGUAGE=0					; Text
					defm	"5 FX/MUSICA "             
					ENDIF
					IF T128_LANGUAGE=1
					defm	"5 FX/MUSIC "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"5 FX/MUSICA "
					ENDIF
					defb	0							; End of text
;
; Redefine strings (10 characters long)
;
MenuOption2Values:										
					IF T128_LANGUAGE=0
					defm	"IZQUIERDA "             
					ENDIF
					IF T128_LANGUAGE=1
					defm	"   LEFT   "
					ENDIF
					IF T128_LANGUAGE=2
					defm	" ESQUERDA "
					ENDIF
;					
					IF T128_LANGUAGE=0                  
					defm	" DERECHA  "
					ENDIF
					IF T128_LANGUAGE=1
					defm	"  RIGHT   "
					ENDIF
					IF T128_LANGUAGE=2
					defm	" DIREITA  "
					ENDIF
;
					IF T128_LANGUAGE=0
					defm	"  ARRIBA  "             
					ENDIF
					IF T128_LANGUAGE=1
					defm	"    UP    "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"  SUBIR   "
					ENDIF
;
					IF T128_LANGUAGE=0                  
					defm	"  ABAJO   "
					ENDIF
					IF T128_LANGUAGE=1
					defm	"   DOWN   "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"  DESCER  "
					ENDIF
;
					IF T128_LANGUAGE=0                  
					defm	" DISPARAR "
					ENDIF
					IF T128_LANGUAGE=1
					defm	"   FIRE   "
					ENDIF
					IF T128_LANGUAGE=2
					defm	" DISPARO  "
					ENDIF
;
					IF T128_LANGUAGE=0                  
					defm	"  PAUSA   "
					ENDIF
					IF T128_LANGUAGE=1
					defm	"  PAUSE   "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"  PAUSA   "
					ENDIF
;
					IF T128_LANGUAGE=0                  
					defm	" DESISTIR "
					ENDIF
					IF T128_LANGUAGE=1
					defm	"   QUIT   "
					ENDIF
					IF T128_LANGUAGE=2
					defm	" DESISTIR "
					ENDIF
;
; Sound strings (9 characters long)
;
MenuOption5Values:										
					IF T128_LANGUAGE=0                  ; Option5Value (T128_GameFXMusic) = 0
					defm	"FX/MUSICA"             
					ENDIF
					IF T128_LANGUAGE=1
					defm	"FX/MUSIC "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"FX/MUSICA"
					ENDIF
;					
					IF T128_LANGUAGE=0                  
					defm	"MUSICA   "					; Option5Value (T128_GameFXMusic) = 1
					ENDIF
					IF T128_LANGUAGE=1
					defm	"MUSIC    "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"MUSICA   "
					ENDIF
;
					IF T128_LANGUAGE=0                  ; Option5Value (T128_GameFXMusic) = 2
					defm	"FX       "             
					ENDIF
					IF T128_LANGUAGE=1
					defm	"FX       "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"FX       "
					ENDIF
;
					IF T128_LANGUAGE=0                  
					defm	"SILENCIO "					; Option5Value (T128_GameFXMusic) = 3
					ENDIF
					IF T128_LANGUAGE=1
					defm	"MUTE ALL "
					ENDIF
					IF T128_LANGUAGE=2
					defm	"SILENCIO "
					ENDIF
;
; Start text
;
MenuStartText:		
					IF T128_LANGUAGE=0                  
					defm	"Que la fuerza de Zeus impregne tu alma y " 
					defm	"que la sabidur]a ilumine tu senda, pues ya sabes que a veces las palabras no son lo que parecen. "
					defm	"Encuentra la guarida de Medusa y elige tu destino." 					
					ENDIF
					IF T128_LANGUAGE=1
					defm	"May the strength of Zeus pervade your soul and " 
					defm	"may wisdom illuminate your path, cause you know sometimes words have two meanings. "
					defm	"Find Medusa's lair and choose your destiny."
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Que o poder de Zeus perpasse a tua alma e " 
					defm	"que a sabedoria ilumine o teu caminho, pois sabes que, por vezes, as palavras n>o s>o o que parecem. "
					defm	"Encontra o covil da Medusa e escolhe o teu destino."
					ENDIF
					defb	0
;
; GAME OVER text
;
MenuGAMEOVER:		defm	"GAME"
					defb	0
					defm	"OVER"
					defb	0
;
; THE END #1
;
TheEnd1Text:		
					IF T128_LANGUAGE=0                  
					defm	"Enhorabuena Perseo, has logrado completar la misi^n con \\xito y has sorprendido a Polidectes con "
					defb	"la cabeza de Medusa, m[s tu orgullo no te permitir[ morar en la casa de Zeus." 
					ENDIF
					IF T128_LANGUAGE=1
					defm	"Congratulations Perseus, you have successfully completed the mission and surprised Polydectes with "
					defm	"Medusa's head, but your pride shall not allow you to dwell in the house of Zeus."
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Parab\\ns, Perseus. Conclu]ste a miss>o com sucesso e surpreendeste Polydectes com "
					defm	"a cabe=a da Medusa, mas o teu orgulho n>o te permitir[ habitar a casa de Zeus."
					ENDIF
					defb	0
;
; THE END #2
;
TheEnd2Text:		
					IF T128_LANGUAGE=0                  
					defm	"Perseo ha sabido elegir el camino correcto y con su sacrificio se le ha abierto la puerta de la casa de Zeus. "
					defm	"Y a t], Medusa, se te ha permitido volver a tu pueblo y recuperar el lugar que Polidectes te arrebat^." 
					ENDIF
					IF T128_LANGUAGE=1
					defm	"Perseus has chosen the right path and with his sacrifice he has been granted entry to Zeus's house. "
					defm	"And you, Medusa, have been allowed to return to your people and reclaim the place that Polydectes stole from you."
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Perseus escolheu o caminho certo e, com o seu sacrif]cio, a porta da casa de Zeus foi-lhe aberta. "
					defm	"E a ti, Medusa, foi-te permitido regressar ao teu povo e reivindicar o lugar que Polydectes usurpou."
					ENDIF
					defb	0

					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					
; MenuMenu
;
; Manage Menu
;

MenuMenu:			call	MenuRender
;
; RetroBenSoft 2025
;
					ld		bc, $010f
					ld		a, $e0
					ld		d, $50
					exx
					ld		d, $5a
					ld		hl, MENU_RB_2025_ATTR					
					exx
					ld		hl, MENU_RB_2025
M_Loop_01:			halt
					halt
					ld		e, a
					exx
					ld		e, a
					exx
					call	IntroCopyScreenData			
					inc		b
					sub		$20
					cp		$a0
					jr		nz, M_Loop_01
					ld 		a, T128_AY_FX_OUCH			; FX number
					call	T128_AY_InitFXBS1			; Sound
;
; Written by humnan, not AI
; 					
					ld		bc, $0109
					ld		a, $f7
					ld		d, $50
					exx
					ld		d, $5a
					ld		hl, MENU_NOTAI_ATTR
					exx
					ld		hl, MENU_NOTAI
M_Loop_02:			halt
					halt
					ld		e, a
					exx
					ld		e, a
					exx
					call	IntroCopyScreenData			
					inc		b
					sub		$20
					cp		$97
					jr		nz, M_Loop_02
					ld 		a, T128_AY_FX_OUCH			; FX number
					call	T128_AY_InitFXBS1			; Sound
;
; Menu loop
; 
M_Label_01:			call	MenuKeyDetect				; Detect pressed key
					jr		nz, M_Label_01
					inc		d
					jr		z, M_Label_01
					dec		d
					call	MenuKeyReleasedWait
					ld		a, d						; a = key pressed
					ld		hl, MenuOptions
					ld		b, MENU_OPTIONS_NUMBER
M_Loop_03:			ld		e, (hl)
					inc		hl
					ld		d, (hl)
					inc		hl
					ld		ixl, e
					ld		ixh, d
					cp		(ix)
					jr		nz, M_Label_02
					push	bc
					push	hl
					ld		l, (ix+1)
					ld		h, (ix+2)
					jp		(hl)
M_Label_02:			djnz	M_Loop_03
					jr		M_Label_01

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0. Intro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
M_Label_00:			ld		hl, $5800 + MENU_OPTIONS_POSX+2+(MENU_OPTIONS_POSY+0*2)*32
					call	MenuOptSelected				; Enhance selected option
;
					pop		hl							; Collect garbage
					pop		bc							; from stack
;					
					ld		a, T128_AY_CTRL_ENDSONG
					ld		(T128_AY_SongAction), a		; Stop Music and
					halt								; wait for next AY Player					
					jp		T128_IntroBS1				; Intro
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1. Keyboard: scoreboard and start game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
M_Label_10:			ld		hl, $5800 + MENU_OPTIONS_POSX+2+(MENU_OPTIONS_POSY+1*2)*32
					call	MenuOptSelected				; Enhance selected option
;
					pop		hl							; Collect garbage
					pop		bc							; from stack
;
					ld		hl, T128_KeyLeft			; Input source = Keyboard
M_Label_11:			ld		(T128_KeyBase), hl
					xor		a
;
; Start game
;					
M_Label_12:			ld		(T128_InputSource), a					
;
					call	IntroClearScreen
; 
					ld		a, MENU_OPTIONS_ATTR1
					ld		bc, $0b20
					ld		hl, $5900
					call	IntroAttributeRect			; Color for text
					ld		hl, MenuStartText			; hl = text address (zero-terminated string)
					ld		bc, $030a					; X = 3  Y = 10
					ex		af, af'
					ld		a, 31						; Right limit
					ex		af, af'
					call	T128_StrPrintMulti			; Print multiline string					
;
					call	MenuWaitForInput
;					
					call	IntroClearScreen
;
					ld		bc, $0220
					ld		hl, SCOREBOARD
					ld		de, $4000
					exx
					ld		hl, SCOREBOARD_ATTR
					ld		de, $5800					
					exx
					call	IntroCopyScreenData			; Copy scoreboard from buffer memory to screen
;
					ld		a, T128_AY_CTRL_ENDSONG
					ld		(T128_AY_SongAction), a		; Stop Music and
					halt								; wait for next AY Player					
;
M_SMC_01_BS1:		jp		0000						; Jump to GameSetup
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2. Redefine keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
M_Label_20:			ld		hl, $5800 + MENU_OPTIONS_POSX+2+(MENU_OPTIONS_POSY+2*2)*32
					call	MenuOptSelected				; Enhance selected option
;
					ld		bc, $1000
					ld		a, 3*8
					ld		hl, MENU_REDEFINE_POS
					call	IntroBitmapRect					
					ld		a, MENU_REDEFINE_ATTR
					ld		bc, 3*256+16
					ld		hl, MENU_REDEFINE_POSATTR
					call	IntroAttributeRect			; Color for refefine keys text
;					
					ld		b, 7
					ld		de, T128_KeyLeft
					ld		hl, MenuOption2Values					
M_Loop_20:			push	bc
					push	de
					ld		d, 10
					ld		bc, MENU_REDEFINE_POSX*256+MENU_REDEFINE_POSY
					call	T128_StrPrintLen			; Prompt text
					call	MenuKeyReleasedWait
					push	hl
M_Loop_21:			call	MenuKeyDetect				; Detect key pressed
					jr		nz, M_Loop_21
					inc		d
					jr		z, M_Loop_21
					dec		d
					ld		a, d
					pop		hl
					pop		de
					pop		bc
					ld		(de), a						; Save key pressed
					inc		de
					djnz	M_Loop_20					; Next prompt
;
					call	MenuRender
					pop		hl							; Collect garbage
					pop		bc							; from stack
					jp		M_Label_01					; Return to menu
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3. Sinclair
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
M_Label_30:			ld		hl, $5800 + MENU_OPTIONS_POSX+2+(MENU_OPTIONS_POSY+3*2)*32
					call	MenuOptSelected				; Enhance selected option
;
					pop		hl							; Collect garbage
					pop		bc							; from stack
;
					ld		hl, T128_SinclairLeft		; Input source = Sinclair
					jp		M_Label_11
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4. Kempston
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
M_Label_40:			ld		hl, $5800 + MENU_OPTIONS_POSX+2+(MENU_OPTIONS_POSY+4*2)*32
					call	MenuOptSelected				; Enhance selected option
;
					pop		hl							; Collect garbage
					pop		bc							; from stack
;
					ld		a, 1						; Input source = Kempston
					jp		M_Label_12

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5. Select Fx / Music
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
M_Label_50:			ld		a, (T128_GameFXMusic)
					inc		a							; Cycle FX/Music option: 0, 1, 2, or 3
					cp		4							
					jr		nz, M_Label_51
					xor		a
M_Label_51:			ld		(T128_GameFXMusic), a
					call	MenuFxMusic					; Select appropriate text for Fx / Music 
					ld		d, $ff
					ld		bc, MENU_OPTIONS_POSX*256+MENU_OPTIONS_POSY+5*2
					push	ix
					pop		hl
					inc		hl
					inc		hl
					inc		hl
					call	T128_StrPrintLen			; Print text
;					
					ld		hl, $5800 + MENU_OPTIONS_POSX+2+(MENU_OPTIONS_POSY+5*2)*32
					call	MenuOptSelected				; Enhance selected option
;
					pop		hl							; Collect garbage
					pop		bc							; from stack
					jp		M_Label_01					; Return to menu
;
; Dummy
;					
M_Label_99:			pop		hl
					pop		bc
					jp		M_Label_01					; Return to menu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; MenuIntroSound
;
; Setup sound for Menu and Intro
;
MenuIntroSound:		ld		a, T128_AY_CTRL_ENDFX
					ld		(T128_AY_FXAction), a		; Stop FX and
					halt								; wait for next AY Player
					ld		a, T128_AY_CTRL_ENDSONG
					ld		(T128_AY_SongAction), a		; Stop Music and
					halt								; wait for next AY Player
					xor		a							; Enable Music & FX
					ld		(T128_AY_Control), a		; Set up sound
					ld		a, T128_AY_MUSIC_MENU		; Song number
					call	T128_AY_InitSongBS1			; Init song
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					
; MenuOptSelected
;
; Enhance selected menu option  
;
; Input:
;   hl = Attribute address of menu option
;
MenuOptSelected:	
;					ld 		a, T128_AY_FX_OUCH			; FX number
;					push	hl
;					call	T128_AY_InitFXBS1			; Sound
;					pop		hl
					ld		b, 10
					ld		a, MENU_SELECTED_ATTR
					ld		c, MENU_OPTIONS_ATTR1
MOS_Loop_01:		ld		(hl), a
					halt
					halt
;					halt
					ld		(hl), c
					inc		hl
					djnz	MOS_Loop_01
					ld		b, 10
MOS_Loop_02:		dec		hl
					ld		(hl), a
					halt
;					halt
					ld		(hl), c
					djnz	MOS_Loop_02
					ret
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					
; MenuFxMusic
;
; Select appropriate text for FxMusic 
;
MenuFxMusic:		ld		a, (T128_GameFXMusic)
					ld		b, a
					add		a, a
					add		a, a
					add		a, a
					add		a, b						; a = a * 9
					ld		c, a
					ld		b, 0
					ld		hl, MenuOption5Values
					add		hl, bc
					ld		de, MenuOption5+5
					ld		bc, 9
					ldir
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					
; MenuRender
;
; Render menu. Every menu option is scrolled from right to left
;

MenuRender:			call	MenuFxMusic					; Select appropriate text for Fx / Music 
;
; Clean Menu area
;
					ld		a, MENU_TITLE_ATTR
					ld		bc, $0720
					ld		hl, $5800
					call	IntroAttributeRect			; Color for title
					
					ld		bc, $2000
					ld		a, 11*8
					ld		hl, MENU_OPTIONS_POS
					call	IntroBitmapRect
					
					ld		a, MENU_OPTIONS_ATTR1
					ld		bc, $0b20
					ld		hl, MENU_OPTIONS_POSATTR-MENU_OPTIONS_POSX
					call	IntroAttributeRect			; Color for text
					
					ld		a, MENU_OPTIONS_ATTR2
					ld		bc, 1+((MENU_OPTIONS_NUMBER*2)-1)*256
					ld		hl, MENU_OPTIONS_POSATTR
					call	IntroAttributeRect			; Color for number options
;
; Render Menu
;
					ld		hl, MenuOption0
					ld		bc, MENU_OPTIONS_NUMBER*256+MENU_OPTIONS_POSY
MR_Loop_01:			push	bc
					ld		b, 20						; Horizontal position on the right side of the screen
					inc		hl
					inc		hl
					inc		hl							; hl = text
					push	bc
					push	hl
					ld 		a, T128_AY_FX_OUCH			; FX number
					call	T128_AY_InitFXBS1			; Sound
					pop		hl
					pop		bc
MR_Loop_02:			ld		d, $ff
					push	hl
					push	bc
					call	T128_StrPrintLen			; Print text
					pop		bc
					dec		b							; Move left
					ld		a, MENU_OPTIONS_POSX-1
					cp		b
					jr		z, MR_Label_02
					pop		hl
					halt
					jr		MR_Loop_02
MR_Label_02:		pop		bc							; Release stack
					pop		bc							; REstor number of columns (b) and vertical position (c)
					inc		c
					inc		c							; 2 rows down
					djnz	MR_Loop_01					; Next option	
					ret
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; MenuKeyReleasedWait
;
; Wait for key release
;

MenuKeyReleasedWait xor		a
					in		a, ($fe)
					or		%11100000
					inc		a
					jr		nz, MenuKeyReleasedWait
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; MenuKeyPressedWait
;
; Wait for a key press
;

MenuKeyPressedWait:	xor		a
					in		a, ($fe)
					or		%11100000
					inc		a
					jr		z, MenuKeyPressedWait
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Wait for joystick / key pressed
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MenuWaitForInput:	ld		a, (T128_InputSource)		; a = 0 Keyboard/sinclair     1 = Kempston
					or		a
					jr		nz, KPQ_Label_04			
					; KEYBOARD / SINCLAIR
					call	MenuKeyReleasedWait
					call	MenuKeyPressedWait			
					jp		MenuKeyReleasedWait
					; KEMPSTON
KPQ_Label_04:		ld		bc, $1f
					in		a, (c)
					and		%00011111
					jr		z, KPQ_Label_04
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; MenuKeyDetect
;
; Find out which key is pressed
;
; Output:
;   d         = Key code. Format is 000rrrppp where
;               rrr = key row
;               ppp = key position within the row
;             = $ff if no key is pressed
;   Zero flag = 0 if more than one key is pressed
;             = 1 if one key is correctly pressed
;		
MenuKeyDetect:		ld		de, $ff2f
					ld		bc, $fefe
KD_Loop_01:			in		a, (c)
					cpl
					and		$1f
					jr		z, KD_Label_01				; No key is pressed
					inc		d
					ret		nz							; Return if more than one key is pressed
					ld		h, a
					ld		a, e
KD_Loop_02:			sub		8
					srl		h
					jr		nc, KD_Loop_02
					ret		nz							; Return if more than one key is presed
					ld		d, a
KD_Label_01:		dec		e
					rlc		b
					jr		c, KD_Loop_01				; Try next row
					cp		a							; Unset Zero flag
					ret
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_GameOverBS1
;
; Process GAME OVER
;							
T128_GameOverBS1: 	call	MenuIntroSound				; Setup sound for Menu
;
					ld		bc, $0c00
					ld		a, 4*8
					ld		hl, MENU_GAMEOVER_POS
					call	IntroBitmapRect
					ld		a, MENU_GAMEOVER_ATTR0
					ld		bc, $060e
					ld		hl, MENU_GAMEOVER_POSATTR0
					call	IntroAttributeRect
					ld		a, MENU_GAMEOVER_ATTR
					ld		bc, $040c
					ld		hl, MENU_GAMEOVER_POSATTR
					call	IntroAttributeRect			; Setup window		
;
					ld		hl, MenuGAMEOVER
					ld		bc, MENU_GAMEOVER_POSY+1+(MENU_GAMEOVER_POSX+4)*256
					ld		d, $ff
					call	T128_StrPrintLen
					ld		bc, MENU_GAMEOVER_POSY+2+(MENU_GAMEOVER_POSX+4)*256
					ld		d, $ff
					call	T128_StrPrintLen			; Print text on window
;					
					ld 		a, T128_AY_FX_GAMEOVER		; FX number
					call	T128_AY_InitFXBS1			; Sound					
;
					ld		d, 8
					ld		hl, 0
					call	IntroPause
					call	MenuWaitForInput
;
					call	IntroClearScreen
					call	IntroTitle
					jp		MenuMenu					; Clear screen, print title and go to menu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TheEnd1BS1
;
; Process The End #1
;							
T128_TheEnd1BS1: 	call	MenuIntroSound				; Setup sound for Menu
;
					call	IntroClearScreen
					
					ld		a, MENU_OPTIONS_ATTR1
					ld		bc, $0b20
					ld		hl, $5900
					call	IntroAttributeRect			; Color for text
					ld		hl, TheEnd1Text				; hl = text address (zero-terminated string)
					ld		bc, $030a					; X = 3  Y = 10
					ex		af, af'
					ld		a, 31						; Right limit
					ex		af, af'
					call	T128_StrPrintMulti			; Print multiline string					
;
					ld		d, 8
					ld		hl, 0
					call	IntroPause
					call	MenuWaitForInput
;
					call	IntroClearScreen
					call	IntroTitle
					jp		MenuMenu					; Clear screen, print title and go to menu
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_TheEnd1BS2
;
; Process The End #2
;							
T128_TheEnd1BS2: 	call	MenuIntroSound				; Setup sound for Menu
;
					call	IntroClearScreen
					
					ld		a, MENU_OPTIONS_ATTR1
					ld		bc, $0b20
					ld		hl, $5900
					call	IntroAttributeRect			; Color for text
					ld		hl, TheEnd2Text				; hl = text address (zero-terminated string)
					ld		bc, $030a					; X = 3  Y = 10
					ex		af, af'
					ld		a, 31						; Right limit
					ex		af, af'
					call	T128_StrPrintMulti			; Print multiline string					
;
					ld		d, 8
					ld		hl, 0
					call	IntroPause
					call	MenuWaitForInput					
;
					call	IntroClearScreen
					call	IntroTitle
					jp		MenuMenu					; Clear screen, print title and go to menu
