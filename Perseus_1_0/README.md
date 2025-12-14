# Perseus (2025)

A game written in Z80 assembly code for the ZX Spectrum 128k. 
Available in [itchio](https://retrobensoft.itch.io/perseus)

### Requirements
* Windows 10/11 (I'm pretty sure a Linux version is easy to implement)
* pasmo.exe and gentape.exe folders must be in Windows PATH variable

### Development tools
* Tuerkas128 Framework by RetroBensoft (framework)
* Notepad++ by Don Ho (text editor)
* Pasmo by Julian Albo (Z80 assembler)
* ZEsarUX by César Hernández Bano (code & game testing)
* Retro Virtual Machine by Juan Carlos Gonzalez Amestoy (code debugging, sound tracker fine tuning)
* Gentape by Antonio Villena (tap generator)
* Multipaint by Tero Heikkinen (loading screen & intro)
  
### Acknowledgments
* Manuel Pena (original sketch of Graia)
* Ramón Fernández Ameijeiras (sinclair joystick tester)
* David Gonzalo aka Z80user (code optimization for the loader)

### Notes
* Run `makefile_win.bat` from the Windows command prompt to generate the `perseus.tap` file.
* `makefile_win.bat` uses PASMO to assembly the code, `makefile_win.ps1` (Windows PowerShell) to generate `loader.asm` from `loader_template.asm`, and GENTAPE to produce `perseus.tap`.
* Main code is in `bank_2.asm`. If you want to dive into the code you can start from here.
* If you want to master Tuerkas128 Framework, a good way to start with is by doing mods. The easiest mod is customizing screens. Blocks and superblocks definitions are in the `screens` folder. Game map is defined in the `screens` folder as well. Map shape is a rectangle and its size is defined by parameter T128_SCREEN_ROW_1 located at `framework\tuerkas128_constants.asm`. In Perseus, T128_SCREEN_ROW_1 is set to %00010000 (16), which means that the map could be 16 screens wide by 16 screens high. So the map could be made up of 256 screens, although Perseus only has 144 (16 wide by 8 high).
* Tutorials are available in [YouTube](https://www.youtube.com/@RetroBensoft) (only in spanish, sorry)

### Project content
* The `_doc_\` folder contains documentation.
  
* The Tuerkas128 Framework core is within the `framework\` folder. Some customization can be made by modifying `tuerkas128_constants.asm` and `tuerkas128_global.asm`, but any other file within this folder must not be changed unless you know exactly what you are doing.
  
* The `framework\AY\` folder is the sound tracker based upon the AY-3-8910/8912 specifications.
  
* The `fsm\` folder contains the code for controlling animated blocks, sprites and main char behaviour. The operation of animated blocks is hard-wired in the framework, but it can be customized using parameters. Sprites and main char can be fully controlled by programming their FSMs in assembly language with the help of Tuerkas128 Framework data structures. FSM stands for Finite State Machine.
  * `tuerkas128_AB_types.asm` is used for defining all types of animated blocks.
  * `tuerkas128_AB_def_tables.asm` contains the parameters for every type of animated block. Two or more animated blocks of different type can share the same parameters. For instance, T128_ANIMBLK_STRINGR and T128_ANIMBLK_STRINGL. Or T128_ANIMBLK_SPIKETOP1 and T128_ANIMBLK_SPIKEBOT1.
  * `tuerkas128_SPR_types.asm` is used for defining all types of sprites. 
  * `tuerkas128_SPR_def_tables.asm` contains the parameters for every type of sprite. Two or more sprites of different type can share the same parameters. For instance, T128_SPRITE_SKELETON, T128_SPRITE_CYCLOP, T128_SPRITE_MINOTAURUS and T128_SPRITE_GRAIA. Or T128_SPRITE_DISCOBOLUS and T128_SPRITE_PEGASUS.
  * `tuerkas128_SPR_classes.asm` is used for defining every sprite class and the routines for their FSM. Sprite class 0 is reserved for built-in _CHILD_ class. A class defines the way a sprite behaves throughout a routine written in assembly code. It can be created as much classes as the game needs. All sprites of the same class have the same behaviour (because they have the same FSM routine). For instance, T128_SPRITE_SKELETON, T128_SPRITE_CYCLOP, T128_SPRITE_MINOTAURUS, T128_SPRITE_GRAIA, T128_SPRITE_DWARF and T128_SPRITE_CYCLOP belongs to the class SPR_ClassWalker (the relationship between sprite type and sprite class is defined in `tuerkas128_SPR_def_tables.asm`); the routine SPR_FSM_Walker is called once every game-loop iteration to control the behaviour of sprites of class SPR_ClassWalker. The framework does not provided default actions for any sprite. Behaviour must be coded from scratch in assembly language. The framework only provides data structures and basic routines to make things easier, but not too easy. In addition, two other routines must be associated to a sprite class which are called when the sprite is spawned and they can be used to init some sprite parameters. For instance, the routines for the class SPR_ClassWalker are SPR_FSM_WalkerIS and SPR_FSM_WalkerIS2. Why two routines and not only one? Because they are called at two different stages during sprite spawning, and this can be helpful in some cases.
  * `tuerkas128_SPR_routines.asm` is used to include the asm libraries containing the routines associated to every sprite class. If 13 classes are defined in `tuerkas128_SPR_classes.asm`, then 13 libraries must be included in `tuerkas128_SPR_routines.asm`. 
  * The `fsm\SPR\` folder contains the libraries defined in `tuerkas128_SPR_routines.asm`. In addition, there are two framework files that must not be modified or deleted: tuerkas128_spr_CHILD_.asm and tuerkas128_spr_MAINCHAR_.asm. So that, if 13 classes are defined in `tuerkas128_SPR_classes.asm`, the folder `fsm\SPR\` must contain 15 files.
  * The `fsm\MAINCHAR\` folder must contain a file called tuerkas128_spr_FSM.asm. This filemust be used to define the behaviour of the main char: walk, jump, punch, fire or whatever any other action is needed. The framework does not provided any default action for the main char. They must be coded from scratch in assembly language in this file. The framework only provides data structures and basic routines to make things easier, but not too easy.
  * The `fsm\AB\` folder contains framework files which must not be modified or deleted. There is one file for every animated block class. The framework has 5 predefined animated block classes.
  
* The `gamevars\` folder contains the game variables and timers. For instance: energy, collected objects or any other variable that the game needs to take into account. It also defines which game variables are updated on the scoreboard. The parameter type of GameVar is an important one. It is used to call the appropriate GameVar rendering routine included in the folder `scoreboard\`.
  
* The `graphics\` folder contains the bitmaps for animated blocks, sprites and main char.
  * The `tuerkas128_ab_bitmaps.asm` file must contain a lookup table with as much elements as animated block types are defined at `fsm\tuerkas128_AB_types.asm`. Every entry in this table is pointer to an animated block bitmap (an its size in bytes). Two or more animated blocks of different type could share the same bitmap. For instance, T128_ANIMBLK_SPIKETOP1 and T128_ANIMBLK_SPIKETOP2. Or T128_ANIMBLK_SPIKEBOT1 and T128_ANIMBLK_SPIKEBOT2.
  * The `tuerkas128_spr_bitmaps.asm` file must contain a lookup table with as much elements as sprite types are defined at `fsm\tuerkas128_SPR_types.asm`. Every entry in this table is pointer to a sprite bitmap (an its size in bytes). Two or more sprites of different type could share the same bitmap, although it is not the case in Perseus. 
  * The `graphics\AB\` folder contains the bitmaps included in `tuerkas128_ab_bitmaps.asm`.
  * The `graphics\SPR\` folder contains the bitmaps included in `tuerkas128_spr_bitmaps.asm`.
  * The `graphics\MAINCHAR\` folder must containt a file `tuerkas128_spr_bitmap.asm` with the bitmap of the main char. **SPOILERS AHEAD** Perseus includes two extra files here: one for the bitmap of Perseus himself and another one for the bitmpa of the unexpected appearance of Medusa.
 
* The `intro_menu\` folder contains all the files the game needs for the intro and the menu. These files must be included in the file `bank_S1.asm`, in the root directory. The framework does not provided code for creating the intro or the menu. All of it must be coded in assembly language from scratch. There are 2 requirements:
  * A PUBLIC routine named *T128_IntroBS1* must exists in one of this files. This routine is called right after the game is loaded.
  * A PUBLIC label named *M_SMC_01_BS1* must exists in one of this files. A *jp 0* instruction must be located at this address. The framework dynamically replaces the 0 with the address of the game starting point (GameSetup)

  When the menu launches the game two actions must be done (at least):
  * Render the scoreboard
  * Jump to GameSetup in `bank_2.asm`

    <img width="1129" height="816" alt="image" src="https://github.com/user-attachments/assets/c6870274-694e-4e01-a225-3ca1c94567a8" />

  Perseus includes in this folder:

  * `tuerkas128_code_intro.asm` routines for rendering the intro
  * `tuerkas128_code_text.asm` routines for managing the menu
  * `tuerkas128_code_text.asm` routines for printing text on screen
  * `tuerkas128_data_intro_tittle.asm` bitmap and attributes for the intro tittle
    
    <img width="666" height="168" alt="image" src="https://github.com/user-attachments/assets/76c48436-049b-458c-8770-e0784ff46f40" />

  * `tuerkas128_data_notAI.asm` bitmap and attributes for the lower-right graphic in the menu
    
    <img width="223" height="79" alt="image" src="https://github.com/user-attachments/assets/541f1f24-358c-4b79-92f7-f6bdadf957f7" />

  * `tuerkas128_data_RB2025.asm` bitmap and attributes for the lower-left graphic in the menu

    <img width="373" height="55" alt="image" src="https://github.com/user-attachments/assets/47cdb6f1-4952-4464-89bf-49d8faa6c78e" />

  * `tuerkas128_data_SB.asm` bitmap and attributes for the scoreboard

    <img width="766" height="50" alt="image" src="https://github.com/user-attachments/assets/f104202c-0a36-492a-a9fd-ee56521fc3c7" />

  * `tuerkas128_data_strips.asm` bitmap and attributes for the intro cartoon stripes

    <img width="1037" height="783" alt="image" src="https://github.com/user-attachments/assets/edaa7192-5b0a-4f7b-835b-59c2e185ad28" />

  * `tuerkas128_data_tukers.asm` bitmap for the walking Tuerkas in the intro
      
    <img width="298" height="657" alt="image" src="https://github.com/user-attachments/assets/9259cd89-6353-4379-87fb-4f13c4dffc32" />

* The `scoreboard\` folder must contain the file `tuerkas128_SB_routines.asm`. This file includes a lookup table (SB_RenderRoutines) with an entry for every scoreboard type. Perseus has 3 scoreboard types:
  * DIGIT: It displays a variable by printing a number (for instance, number of coins, or number of knives)
  * BAR:  It displays a variable by rendering a bar (for instance, energy)
  * ICON: It displays an on/off variable (for instance, invisibility or speed up)
  
  The framework does not include code to render the scoreboard, so it must be written for a specific game. The values defined in the SB_RenderRoutines lookup table are the addresses of the assembly routine that renders every piece of scoreboard. There is a file in `scoreboard\` for every scoreboard type. Every file implements its routine. These files must be included at the of the file `framework\tuerkas128_code_scoreboard.asm`.
  
_______________________________

Created by RetroBensoft, 2025

MIT License

