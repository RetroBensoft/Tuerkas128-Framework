;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; I N T R O   R O U T I N E S
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PUBLIC _BEGIN_CODE_INTRO
_BEGIN_CODE_INTRO



PUBLIC T128_IntroBS1									; This routine must exists.
														; T128_IntroBS1 is called after loading the game


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CONSTANTS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Strip border color
;
INTRO_SB_COLOR		EQU		T128_BLACK_WHITE
;
; Fade in & out attribute for strips
;
INTRO_FADE_COLOR1	EQU		T128_BLACK_MAGENTA_DK
INTRO_FADE_COLOR2	EQU		T128_BLACK_BLUE
INTRO_FADE_COLOR3	EQU		T128_BLACK_BLUE_DK
;
; Fade in & out attribute for text
;
INTRO_FADE_COLOR4	EQU		T128_BLACK_WHITE
INTRO_FADE_COLOR4B	EQU		T128_BLACK_RED
INTRO_FADE_COLOR4DK EQU		T128_BLACK_WHITE_DK
INTRO_FADE_COLOR5	EQU		T128_BLACK_BLUE
INTRO_FADE_COLOR6	EQU		T128_BLACK_BLUE_DK
;
; Address of strip on screen
; 
INTRO_CENTRAL		EQU 	0480BH
INTRO_CENTRAL_ATTR	EQU 	0590BH
;
; Address of text on screen
; 
INTRO_TEXT			EQU		((17 AND %00000111) SHL 5) + 0 + (%01000000 + (17 AND %11111000))*256
;
; Address of A-game-by-RetroBensoft logo
; 
INTRO_A_GAME_BY_RB	EQU		((16 AND %00000111) SHL 5) + 22 + (%11000000 + (16 AND %11111000))*256
;
; Address of text Powered by ...
; 
INTRO_TEXT_POWERED	EQU		((10 AND %00000111) SHL 5) + 6 + (%01000000 + (10 AND %11111000))*256



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; DATA
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Strips data. For every strip:
;   - Strip source address 
;   - Zero-terminated string to show under the strip
;
IntroStory:			defw	((0  AND %00000111) SHL 5) + 0  + (%11000000 + (0  AND %11111000))*256
					IF T128_LANGUAGE=0
					defm	"Acrisio, rey de Argos, consult^ el Or[culo el s\\ptimo d]a de la s\\ptima luna. "
					defm	"Los cuervos volaron y el presagio fue interpretado por los profetas: "
					defm	"Acrisio morir]a a manos de su nieto."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"Acrisius, king of Argos, consulted the Oracle on the seventh day of the seventh moon. "
					defm	"The ravens flew and the omen was interpreted by the prophets: "
					defm	"Acrisius would die at the hands of his grandson."
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Acrisius, rei de Argos, consultou o Or[culo no s\\timo dia da s\\tima lua. "
					defm	"Os corvos voaram, e o press[gio foi interpretado pelos profetas: "
					defm	"Acrisius morreria *s m>os de seu neto."
					ENDIF					
					defb	0
					defw	((0  AND %00000111) SHL 5) + 11 + (%11000000 + (0  AND %11111000))*256
					IF T128_LANGUAGE=0					
					defm	"Para burlar el destino que los dioses le hab]an reservado, Acrisio hizo encerrar a su hija Danae en la torre m[s alta del palacio, y orden^ custodiar la entrada d]a y noche."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"To avoid the fate that the gods had in store for him, Acrisius had his daughter Danae locked up in the highest tower of the palace, and ordered the entrance to be guarded day and night."
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Para desafiar o destino que os deuses lhe tinham reservado, Acrisius mandou fechar a sua filha Danae na torre mais alta do pal[cio e ordenou que a entrada fosse vigiada dia e de noite."
					ENDIF
					defb	0
					defw	((0  AND %00000111) SHL 5) + 22 + (%11000000 + (0  AND %11111000))*256
					IF T128_LANGUAGE=0
					defm	"Sin embargo, Zeus tuvo noticias de la belleza de Danae y quiso tener un hijo de ella. "
					defm	"Cuando descubri^ donde estaba encerrada, logr^ alcanzarla en forma de lluvia de oro y engendr^ un ni<o."
					ENDIF
					IF T128_LANGUAGE=1					
					defm	"However, Zeus heard of Danae's beauty and wanted to have a child with her. "
					defm	"When he discovered where she was, he managed to reach her in the form of a shower of gold and gave birth to a child."					
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Zeus ouviu falar da beleza de Danae e desejou ter um filho com ela. "
					defm	"Quando descobriu onde estava aprisionada, conseguiu alcan=[-la sob a forma de chuva de ouro e concebeu uma crian=a."
					ENDIF
					defb	0
					defw	((8  AND %00000111) SHL 5) + 0  + (%11000000 + (8  AND %11111000))*256
					IF T128_LANGUAGE=0
					defm	"Al nacido le llamaron Perseo y cuando Acrisio se enter^ de su existencia quiso deshacerse de \\l. "
					defm	"Aunque no tuvo agallas para matarlo, lo arroj^ con Danae al mar en un arca de madera."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"The newborn was named Perseus and when Acrisius learned of his existence he wanted to get rid of him. "
					defm	"But he didn't have the courage to kill him, so he threw him and Danae into the sea in a wooden ark."					
					ENDIF
					IF T128_LANGUAGE=2
					defm	"O rec\\m-nascido recebeu o nome de Perseus, e quando Acrisius descobriu a sua exist@ncia, quis ver-se livre dele "
					defm	"e lan=ou-o ao mar, juntamente com Danae, numa arca de madeira."					
					ENDIF
					defb	0
					defw	((8  AND %00000111) SHL 5) + 11 + (%11000000 + (8  AND %11111000))*256
					IF T128_LANGUAGE=0
					defm	"La madre y el hijo lograron sobrevivir y alcanzaron la costa de la isla de Serifos. "
					defm	"All] fueron rescatados por un pescador de nombre Dictis que, junto a su mujer, cuid^ de ellos."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"The mother and son managed to survive and reached the coast of Serifos Island. "
					defm	"There they were rescued by a fisherman named Dictys who, together with his wife, took care of them."					
					ENDIF
					IF T128_LANGUAGE=2
					defm	"A m>e e o filho conseguiram sobreviver e chegaram * costa da ilha de Serifos. "
					defm	"A], foram resgatados por um pescador chamado Dictys que, juntamente com a sua mulher, cuidou deles."					
					ENDIF
					defb	0
					defw	((8  AND %00000111) SHL 5) + 22 + (%11000000 + (8  AND %11111000))*256					
					IF T128_LANGUAGE=0
					defm	"Result^ que Dictis era hermano de Polidectes, rey de la isla. "
					defm	"Un buen d]a Polidectes conoci^ a Danae, se enamor^ de ella y decidi^ que ser]a su esposa."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"It turned out that Dictys was the brother of Polydectes, king of the island. "
					defm	"One day Polydectes met Danae, fell in love with her and decided that she would be his wife."					
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Dictys era o irm>o de Polydectes, o rei da ilha. "
					defm	"Certo dia, Polydectes conheceu Danae, apaixonou-se por ela e decidiu que ela seria a sua esposa."					
					ENDIF
					defb	0
					defw	((16 AND %00000111) SHL 5) + 0  + (%11000000 + (16 AND %11111000))*256
					IF T128_LANGUAGE=0
					defm	"En ese tiempo Perseo ya hab]a crecido fuerte y poderoso y el rey tem]a que pretendiera ocupar su lugar en el trono. "
					defm	"Pero Polidectes conoc]a el car[cter orgulloso de Perseo y supo aprovecharse de ello."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"By that time Perseus had grown strong and powerful and the king feared that he would try to take his place on the throne. "
					defm	"But Polydectes knew Perseus's proud nature and how to take advantage of it."
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Perseus j[ se tinha tornado forte e poderoso, e o rei temia que ele tentasse ocupar o seu lugar no trono. "
					defm	"Mas Polydectes conhecia o car[cter orgulhoso de Perseus e sabia tirar partido disso."
					ENDIF
					defb	0
					defw	((16 AND %00000111) SHL 5) + 11 + (%11000000 + (16 AND %11111000))*256
					IF T128_LANGUAGE=0
					defm	"Polidectes le pidi^ a Perseo como regalo de boda la cabeza de Medusa, algo que ning_n guerrero de Grecia hab]a conseguido. "
					defm	"Perseo le replic^ que \\l ser]a el primero en completar la haza<a."
					ENDIF
					IF T128_LANGUAGE=1
					defm	"Polydectes asked Perseus for Medusa's head as a wedding gift, something that no warrior in Greece had ever achieved. "
					defm	"Perseus replied that he would be the first one to complete the feat."					
					ENDIF
					IF T128_LANGUAGE=2
					defm	"Polydectes pediu a Perseus a cabe=a da Medusa como prenda de casamento, algo que nenhum guerreiro na Gr\\cia tinha conseguido. "
					defm	"Perseus respondeu que seria o primeiro a realizar o feito."					
					ENDIF
					defb	0
					defw	0							; End of story

;
; Powered by Tuerkas128 Framework
; 
IntroPoweredBy1:	defm	"Powered by"
					defb	0
IntroPoweredBy2:	defm	"Tuerkas128 Framework"
					defb	0	
IntroTuerkasSPR		defw	INTRO_TUERKAS_SPR0, INTRO_TUERKAS_SPR1, INTRO_TUERKAS_SPR2, INTRO_TUERKAS_SPR3 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; T128_IntroBS1
;
; PLay intro sequence:
;
;    1. Clear screen
;    2. A game by RetroBensoft
;    3. Powered by Tuerkas128 Framework
;    4. Scroll down title
;    5. Play strips sequence
;    6. Jump to Menu
;
T128_IntroBS1:		xor		a
					out		(254), a					; BORDER 0
					call	IntroClearScreen
					ld		d, 1
					ld		hl, 0
					call	IntroPause

;jp I_Label_01					
					
;
; A game by RetroBensoft
;
					ld		hl, INTRO_A_GAME_BY_RB
					call	IntroStripFadeIn
					ld		d, 4
					ld		hl, 0
					call	IntroPause
					call	IntroStripFadeOut
;			
; Powered by Tuerkas128 Framework
;	
					ld		bc, $2000
					ld		a, 3*8
					ld		hl, INTRO_TEXT_POWERED
					call	IntroBitmapRect
					ld		d, 1
					ld		hl, 0
					call	IntroPause				
					ld 		a, T128_AY_FX_INTRO			; FX number
					call	T128_AY_InitFXBS1			; Sound					
					call	IntroPoweredBy					
;
; Print title and scroll it down from top of the screen
;
					call	IntroTitle					
;			
; Strip sequence
;	
					call	IntroStripBorder
					ld		hl, IntroStory
I_Loop_02:			ld		e, (hl)
					inc		hl
					ld		d, (hl)
					inc		hl
					ld		a, e
					or		d
					jr		z, I_Label_01				
					ex		de, hl
					call	IntroShowStrip
					jr 		I_Loop_02
;
; Menu
;
I_Label_01:			ld		bc, $2000
					ld		a, 17*8
					ld		hl, $40e0
					call	IntroBitmapRect
					ld		a, MENU_OPTIONS_ATTR1
					ld		bc, $1020
					ld		hl, $5900
					call	IntroAttributeRect					
					jp		MenuMenu


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroClearScreen
;
; Clear screen: set bitmap and attribute to 0
;
IntroClearScreen:	ld      hl, $5aff
					ld      de, $5afe
					ld      bc, 6911
					ld      (hl), l
					inc		(hl)
					lddr								; Clear screen
					ret
;IntroClearScreen:	ld      hl, $4000
;					ld      de, $4001
;					ld      bc, 6911
;					ld      (hl), l
;					ldir								; Clear screen
;					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroPause
;
; Take a break by looping around
;
; d  = outer loop counter
; hl = inner loop counter
;					
IntroPause:			ld		b, h
					ld		c, l
IP_Loop_01:			dec		bc
					ld		a, c
					or		b
					jr		nz, IP_Loop_01
					dec		d
					jr		nz, IntroPause
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroPoweredBy
;
; Fade-in and fade-out "Powered by Tuerkas128 Framework"
;
IntroPoweredBy:		ld		bc, $0b0a					; X = 11  Y = 10
					ld		hl, IntroPoweredBy1			; String address (line 1)
					ld		d, $ff						; Zero-terminated string
					call	T128_StrPrintLen			; Print string
					ld		bc, $060c					; X = 6  Y = 12
					ld		hl, IntroPoweredBy2			; String address (line 2)
					ld		d, $ff						; Zero-terminated string
					call	T128_StrPrintLen			; Print string
;
; Text fade-in
; 					
					ld		a, INTRO_FADE_COLOR6
					ld		bc, $0314
					ld		hl, $5946
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR5
					ld		bc, $0314
					ld		hl, $5946
					call	IntroAttributeRect					
					ld		a, INTRO_FADE_COLOR4
					ld		bc, $0114
					ld		hl, $5946
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR4B
					ld		bc, $0114
					ld		hl, $5986
					call	IntroAttributeRect
;
; Tuerkas walking from right to left
;
					xor		a
					ld		bc, $0220
					ld		hl, $59c0
					call	IntroAttributeRect			; Black rows 14 and 15
					ld		a, INTRO_FADE_COLOR4
					ld		bc, $021c
					ld		hl, $59c2
					call	IntroAttributeRect			; White rows 14 and 15, from column 2 to column 29
					ld		de, $48dc					; Screen address for row 14, column 28
					ld		bc, $0204					; Sprite, 2 rows, 4 columns
					ld		a, 0						; Phase of animation
					exx
					ld		b, 29						; Walk 29 columns
IPB_Loop_01:		push	bc
					exx
IPB_Loop_02:		push	af
					exx
					rlca	
					ld		e, a
					ld		d, 0
					ld		hl, IntroTuerkasSPR
					add		hl, de
					ld		e, (hl)
					inc		hl
					ld		d, (hl)
					push	de
					exx
					pop		hl							; hl = simple sprite address
					push	bc
					push	de					
					push	hl
					halt
					halt
					call	IntroSimpleSprite
					pop		hl
					pop		de
					pop		bc
					pop		af
					inc		a
					cp		4
					jr		nz, IPB_Loop_02
					xor		a
					dec		de
					exx
					pop		bc
					djnz	IPB_Loop_01
					exx
					xor		a
					ld		bc, $0220
					ld		hl, $59c0
					call	IntroAttributeRect			; Black rows 14 and 15					
;
; Start Menu/Intro music and do text fade-out
; 					
					ld		d, 3
					ld		hl, 0
					call	IntroPause
					call	MenuIntroSound					
					ld		a, INTRO_FADE_COLOR5
					ld		bc, $0314
					ld		hl, $5946
					call	IntroAttributeRect					
					ld		a, INTRO_FADE_COLOR6
					ld		bc, $0314
					ld		hl, $5946
					call	IntroAttributeRect
					xor		a
					ld		bc, $0314
					ld		hl, $5946
					call	IntroAttributeRect
					ld		d, 10
					ld		hl, 0
					jp		IntroPause
				
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroTitle
;
; Print PERSEUS title for intro and menu
;

IntroTitle:			exx
					ld		hl, INTRO_TITLE_ATTR_7
					exx
					ld		hl, INTRO_TITLE_7
					ld		bc, $0120
I_Loop_01:			halt
					halt
					push	bc
					ld		de, $4000
					push	hl
					exx
					ld		de, $5800
					push	hl					
					exx
					call	IntroCopyScreenData			; Copy title from buffer memory to screen
					exx
					pop		hl
					ld		bc, $ffe0					; -32
					add		hl, bc						; hl = hl - 32 (1 more row for attributes)
					exx
					pop		hl
					dec		h							; hl = hl - 8*32 (1 more row for bitmap)
					pop		bc
					inc		b							; 1 more row to print
					ld		a, 8						
					cp		b
					jr		nz, I_Loop_01
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroStripFadeIn
;
; Draw a strip in the center of the screen
; Strip is showed with a fade-in effect
;
; Input:
;   hl = strip address
;
IntroStripFadeIn:	ld		de, INTRO_CENTRAL
					push	hl
					push	de
;
; Draw strip: transfer bitmap data from source to destination in bank 5 screen
; Source data has the same structure as screen 				
;
					ex		af, af'
					ld		a, 10						; Number of columns
ISFI_Loop_01:		ex		af, af'
					push	de
					push	hl
					ld		c, 8						; Number of rows
ISFI_Loop_02:		ld		b, 8
ISFI_Loop_03:		ld		a, (hl)
					ld		(de), a
					inc		h
					inc		d
					djnz	ISFI_Loop_03				; Next scanline
					ld		a, l
					add		a, $20						
					ld		l, a						
					jr		c, ISFI_Label_01
					ld		a, h
					sub		$08							
					ld		h, a						
ISFI_Label_01:		ld		a, e
					add		a, $20						
					ld		e, a						
					jr		c, ISFI_Label_02
					ld		a, d
					sub		$08							
					ld		d, a						
ISFI_Label_02:		dec		c
					jr		nz, ISFI_Loop_02			; Next row
					pop		hl
					pop		de
					inc		hl
					inc		de
					ex		af, af'
					dec		a
					jr		nz, ISFI_Loop_01			; Next column
					ex		af, af'	
					pop		de
					pop		hl
;
; Attribute fade in
;					
					push	hl
					ld		a, INTRO_FADE_COLOR3
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR2
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR					
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR1
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR					
					call	IntroAttributeRect
					pop		hl
;
; Last fade-in step: transfer attribute data from source to destination in bank 5 screen
; Source has the same same structure as screen 
;			
					ld		de, INTRO_CENTRAL_ATTR		; de = Attribute destination address					
					ld		a, h
					rrca
					rrca
					rrca
					and		3
					or		$d8
					ld		h, a						; hl = Attribute source address
					ld		c, 10						; Number of columns
ISFI_Loop_04:		push	de
					push	hl
					ld		b, 8						; Number of rows
ISFI_Loop_05:		push	bc
					ld		bc, $20
					ld		a, (hl)
					ld		(de), a
					add		hl, bc
					ex		de, hl
					add		hl,  bc
					ex		de, hl
					pop		bc
					djnz	ISFI_Loop_05				; Next row
					pop		hl
					pop		de
					inc		hl
					inc		de
					dec		c
					jr		nz, ISFI_Loop_04
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroStripFadeOut
;
; Hide a strip in the center of the screen with a fade-out effect
;
; Input:
;   hl = strip address
;
IntroStripFadeOut:	ld		a, INTRO_FADE_COLOR1
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR2
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR3
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR
					call	IntroAttributeRect
					xor		a
					ld		bc, $080a
					ld		hl, INTRO_CENTRAL_ATTR					
					jp		IntroAttributeRect					


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroShowStrip
;
; Take one strip from memory and draw it on screen
;   1. Strip fade-in 
;   2. Print text
;   3. Text fade-in
;   4. Wait for a key pressed and released
;   5. Strip fade-out
;   6. Text fade-out
;
; Input:
;   hl = strip address
;   de = text address (zero-terminated string)
;
; Output
;   hl = next strip data
;										
IntroShowStrip:		push	de
					call	IntroStripFadeIn			; Draw strip
;
; Print text
; 					
					pop		hl							; hl = text address (zero-terminated string)
					ld		bc, $0211					; X = 2  Y = 17
					ex		af, af'
					ld		a, 32						; Right limit
					ex		af, af'
					call	T128_StrPrintMulti			; Print multiline string
;
; Text fade-in
; 					
					push	hl
					ld		a, INTRO_FADE_COLOR6
					ld		bc, $0720
					ld		hl, $5a20
					call	IntroAttributeRect
					ld		a, INTRO_FADE_COLOR5
					ld		bc, $0720
					ld		hl, $5a20
					call	IntroAttributeRect					
					ld		a, INTRO_FADE_COLOR4DK
					ld		bc, $0720
					ld		hl, $5a20
					call	IntroAttributeRect					
;
; Wait for a key pressed/released or a Kempston joystick input
;			
					call	MenuWaitForInput
;IShS_Loop_01:		xor		a
;					in		a, ($fe)
;					or		%11100000
;					inc		a
;					jr		z, IShS_Loop_01				; Loop back if no key is pressed
;IShS_Loop_02:		xor		a
;					in		a, ($fe)
;					or		%11100000
;					inc		a
;					jr		nz, IShS_Loop_02
;
; Strip fade out
;						
IShS_Label_01:		call	IntroStripFadeOut
;
; Text fade-out
; 					
					ld		a, INTRO_FADE_COLOR5
					ld		bc, $0720
					ld		hl, $5a20
					call	IntroAttributeRect					
					ld		a, INTRO_FADE_COLOR6
					ld		bc, $0720
					ld		hl, $5a20
					call	IntroAttributeRect
					xor 	a
					ld		bc, $0720
					ld		hl, $5a20
					call	IntroAttributeRect	
					ld		bc, $2000
					ld		a, 7*8
					ld		hl, INTRO_TEXT
					call	IntroBitmapRect
					pop		hl
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroAttributeRect
;
; Change attribute within a rectangle on screen
;
; Input:
;   a  = attribute
;   b  = number of rows
;   c  = number of columns
;   hl = Attribute address (top left corner)
;															
IntroAttributeRect:	halt
					ld		de, $20
ISA_Loop_01:		push	hl
					push	bc
ISA_Loop_02:		ld		(hl), a
					add		hl, de
					djnz	ISA_Loop_02					; Next row
					pop		bc
					pop		hl
					inc		hl
					dec		c
					jr		nz, ISA_Loop_01				; Next column
					ld		bc, 2500
ISA_Loop_03:		dec		bc							; Pause loop
					ld		a, c
					or		b
					jr		nz, ISA_Loop_03
					ret

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroBitmapRect
;
; Set a value within a rectangle on screen
;
; Input:
;   c  = value
;   b  = number of columns
;   a  = number of scanlines
;   hl = Screen address (top left corner)
;															
IntroBitmapRect:	push	af
					push	bc
					push	hl
					xor		a							; Black over black
					call	IntroSB_Hor
					pop		hl
					inc		h
					ld		a, h
					and		7
					jr		nz, IBR_Label_01
					ld		a, l
					add		a, $20				
					ld		l, a						
					jr		c, IBR_Label_01
					ld		a, h
					sub		$08					
					ld		h, a
IBR_Label_01:		pop		bc
					pop		af
					dec		a
					jr		nz, IntroBitmapRect
					ret
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroStripBorder
;
; Draw a square around strip 
;															
IntroStripBorder:	ld		bc, $0103
					ld		hl, $46ea
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Hor
					ld		bc, $0aff
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Hor
					ld		bc, $01c0
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Ver
					ld		bc, $4240
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Ver
					ld		bc, $01c0
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Hor
					ld		bc, $4202
					ld		hl, $47ea
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Ver
					ld		bc, $0103
					ld		a, INTRO_SB_COLOR
					call	IntroSB_Hor
					ld		bc, $0aff
					ld		a, INTRO_SB_COLOR


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroSB_Hor
;
; Fill an horizontal scanline on screen with a value (1 byte)
; Set attribute, as well
;					
; Input:
;	b = number of columns
;   c = value
;   hl = address of first screen position
;   a  = attribute
;
; Output:
;   hl = address of next columne after last value is written, so it can be used in subsequent border sides
;
IntroSB_Hor:		ld		(ISBH_SMC_01+1), a
					ld		d, h
					ld		e, l
					ld		a, d
					rrca
					rrca
					rrca
					and		3
					or		$58
					ld		d, a						; de = Attribute source address
ISBH_SMC_01:		ld		a, 0
ISBH_Loop_01:		ld		(hl), c
					ld		(de), a
					inc		de
					inc		hl
					djnz	ISBH_Loop_01
					ret

					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroSB_Ver
;
; Fill a vertical set of scanlines on screen with a value (1 byte)
; Set attribute, as well
;					
; Input:
;	b = number of scanlines
;   c = value
;   hl = address of first screen position
;   a  = attribute
;
; Output:
;   hl = address of next scanline after last value is written, so it can be used in subsequent border sides
;					
IntroSB_Ver:		ld		(ISBV_SMC_01+1), a
ISBV_Loop_01:		ld		d, h
					ld		e, l
					ld		a, d
					rrca
					rrca
					rrca
					and		3
					or		$58
					ld		d, a						; de = Attribute source address
ISBV_SMC_01:		ld		a, INTRO_SB_COLOR
					ld		(de), a
ISBV_Loop_02:		ld		(hl), c
					inc		h
					dec		b
					jr		z, ISBV_Label_01
					ld		a, h
					and		7
					jr		nz, ISBV_Loop_02
					ld		a, l
					add		a, $20				
					ld		l, a						
					jr		c, ISBV_Loop_01
					ld		a, h
					sub		$08					
					ld		h, a						
					jr		ISBV_Loop_01
ISBV_Label_01:		ld		a, h
					and		7
					ret		nz
					ld		a, l
					add		a, $20				
					ld		l, a						
					ret		c
					ld		a, h
					sub		$08					
					ld		h, a						
					ret
					
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; IntroCopyScreenData
;
; Copy bitmap and attributes from a memory buffer to screen
;
; Bitmap data is stored in scanlines from top to bottom. 
; The first byte of one scanline is W bytes away from the next scanline, where C is the number of columns of the rectangle to be copied
; 
; Attribute data is stored in rows of characters from top to bottom.
; The first buye of one row is W bytes away from the next row, where C is the number of columns of the rectangle to be copied
;
; Input:
;	b   = number of rows
;   c   = number of columns
;   hl  = source address of bitmap buffer
;   de  = destination address of bitmap on screen
;   hl' = source address of attribute buffer
;   de' = destination address of attributes on screen
;
IntroCopyScreenData	push	af
					push	bc
					push	de
					push	hl
					exx
					push	de
					push	hl
					exx
					ld		a, c						; Columns
					ld		(ICSD_SMC_01+1), a	
					ld		(ICSD_SMC_02+1), a	
					ld		(ICSD_SMC_04+1), a	
					ld		a, b						; Rows
					ld		(ICSD_SMC_03+1), a	
;
; Copy bitmap
;
					ex		af, af'
					ld		a, b						; Number of rows
					rlca	
					rlca
					rlca								; Number of scanlines
					ex		af, af'
ICSD_Loop_01:		push	de
ICSD_SMC_01:		ld		bc, 32						; Number of columns
					ldir
					pop		de
					inc		d
					ex		af, af'
					dec		a
					jr		z, ICSD_Label_02
					ex		af, af'
					ld		a, d
					and		7
					jr		nz, ICSD_Loop_01
					ld		a, e
					add		a, $20						
					ld		e, a						
					jr		c, ICSD_Loop_01
					ld		a, d
					sub		$08							
					ld		d, a						
ICSD_Label_01:		jr		ICSD_Loop_01
ICSD_Label_02:		ex		af, af'
;
; Copy attributes
;
					exx
ICSD_SMC_02:		ld		c, 32						; Number of columns
ICSD_Loop_02:		push	de
					push	hl
ICSD_SMC_03:		ld		b, 8						; Number of rows
ICSD_Loop_03:		push	bc
					ld		a, (hl)
					ld		(de), a
ICSD_SMC_04:		ld		bc, 32						; Numer of columns
					add		hl, bc
					ex		de, hl
					ld		bc, $20	
					add		hl,  bc
					ex		de, hl
					pop		bc
					djnz	ICSD_Loop_03				; Next row
					pop		hl
					pop		de
					inc		hl
					inc		de
					dec		c
					jr		nz, ICSD_Loop_02
;					
					pop		hl
					pop		de
					exx
					pop		hl
					pop		de
					pop		bc
					pop		af
					
					ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					
; IntroSimpleSprite					
;
; Simple routine to draw a sprite on screen. Only bitmap, not attributes
; Sprite bitmap is not masked
; Sprite data is stored in scanlines, from left to right
;
; Input:
;	b   = number of rows
;   c   = number of columns
;   hl  = source address of bitmap buffer (to an exact X,Y position in columns,rows)
;   de  = destination address of bitmap on screen
;
IntroSimpleSprite:	ex		af, af'
					ld		a, b
					ex		af, af'
					xor		a
					ld		b, a
					ex		af, af'
ISS_Loop_01:		ex		af, af'
					exx
					ld		b, 8
ISS_Loop_02:		exx
					push	de
					push	bc
					ldir
					pop		bc
					pop		de
					inc		d
					exx
					djnz	ISS_Loop_02
					exx		
					ld		a, e
					add		a, $20						
					ld		e, a						
					jr		c, ISS_Label_01
					ld		a, d
					sub		$08							
					ld		d, a						
ISS_Label_01:		ex		af, af'
					dec		a
					jr		nz, ISS_Loop_01
					ex		af, af'
					ret
					