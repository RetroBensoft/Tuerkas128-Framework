# Perseus (2025)

A game written in Z80 assembly code for the ZX Spectrum 128k

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
* If you want to master Tuerkas128 Framework, a good way to start with is by doing mods. The easiest mod is customizing screens. Blocks and superblocks definitions are in the `screens` folder. Game map is defined in the `screens` folder as well. Map size is defined by parameter T128_SCREEN_ROW_1 located at `framework\tuerkas128_constants.asm`.
* Tutorials are available at https://www.youtube.com/@RetroBensoft (only in spanish, sorry)

### Project content
* The `_doc_\` folder contains documentation.
  
* The Tuerkas128 Framework core is within the `framework\` folder. Some customization can be made by modifying `tuerkas128_constants.asm` and `tuerkas128_global.asm`, but any other file within this folder must not be changed unless you know exactly what you are doing.
  
* The `framework\AY\` folder is the sound tracker based upon the AY-3-8910/8912 specifications.
  
* The `fsm\` folder contains the code for controlling animated blocks, sprites and main char behaviour. The operation of animated blocks is hard-wired in the framework, but it can be customized using parameters. Sprites and main char can be fully controlled by programming their FSMs in assembly language with the help of Tuerkas128 Framework data structures. FSM stands for Finite State Machine.
  * `tuerkas128_AB_types.asm` is used for defining all types of animated blocks.
  * `tuerkas128_AB_def_tables.asm` contains the parameters for every type of animated block. Two or more animated blocks of different type can share the same parameters. For instance, T128_ANIMBLK_STRINGR and T128_ANIMBLK_STRINGL. Or T128_ANIMBLK_SPIKETOP1 and T128_ANIMBLK_SPIKEBOT1.
  * `tuerkas128_SPR_types.asm` is used for defining all types of sprites. 
  * `tuerkas128_SPR_def_tables.asm` contains the parameters for every type of sprite. Two or more sprites of different type can share the same parameters. For instance, T128_SPRITE_SKELETON, T128_SPRITE_CYCLOP, T128_SPRITE_MINOTAURUS and T128_SPRITE_GRAIA. Or T128_SPRITE_DISCOBOLUS and T128_SPRITE_PEGASUS.
  * `tuerkas128_SPR_classes.asm` is used for defining every sprite class and the routines for their FSM. Sprite class 0 is reserved for built-in _CHILD_ class. A class defines the way a sprite behaves throughout a routine written in assembly code. You can use as much classes as your game needs. All sprites of the same class have the same behaviour (because they have the same FSM routine). For instance, T128_SPRITE_SKELETON, T128_SPRITE_CYCLOP, T128_SPRITE_MINOTAURUS, T128_SPRITE_GRAIA, T128_SPRITE_DWARF and T128_SPRITE_CYCLOP belongs to the class SPR_ClassWalker (the relation between sprite type and sprite class is defined in `tuerkas128_SPR_def_tables.asm`), and the routine SPR_FSM_Walker is called once every game-loop iteration to control the behaviour of sprites of class SPR_ClassWalker. The framework does not provided default actions for sprites. They must be coded from scratch in assembly language. The framework only provides data structures and basic routines to make things easier, but not too easy.Two other routinesmust be associated to a sprite class which are called when the sprite is spawned and they can be used to init some sprite parameters. For instance, the routines for the class SPR_ClassWalker are SPR_FSM_WalkerIS and SPR_FSM_WalkerIS2. Why two routines and not only one? Because they are called at two different stages during sprite spawning, and this can be helpful in some cases.
  * `tuerkas128_SPR_routines.asm` is used to include the asm libraries containing the routines associated to every sprite class. If 13 classes are defined in `tuerkas128_SPR_classes.asm`, then 13 libraries must be included in `tuerkas128_SPR_routines.asm`. 
  * The `fsm\SPR\` folder contains the libraries defined in `tuerkas128_SPR_routines.asm`. In addition, there are two framework files that must not be modified or deleted: tuerkas128_spr_CHILD_.asm and tuerkas128_spr_MAINCHAR_.asm. So that, if 13 classes are defined in `tuerkas128_SPR_classes.asm`, the folder `fsm\SPR\` must contain 15 files.
  * The `fsm\MAINCHAR\` folder must contain a file called tuerkas128_spr_FSM.asm. You must use this file to define the behaviour of the main char: walk, jump, punch, fire or whatever any other action you want. The framework does not provided any default action for the main char. They must be coded from scratch in assembly language in this file. The framework only provides data structures and basic routines to make things easier, but not too easy.
  * The `fsm\AB\` folder contains framework files which must not be modified or deleted. There is one file for every animated block class. The framework has 5 predefined animated block classes.
  
* The `gamevars\` folder contains the game variables and timers. For instance: energy, collected objects or anything your game needs.
  
* The `graphics\` folder contains the bitmaps for animated blocks, sprites and main char.
  * The `tuerkas128_ab_bitmaps.asm` file must contain a lookup table with as much elements as animated block types. Every entry in this table is pointer to an animated block bitmap (an its size in bytes). Two or more animated blocks of different type can share the same bitmap. For instance, T128_ANIMBLK_SPIKETOP1 and T128_ANIMBLK_SPIKETOP2. Or T128_ANIMBLK_SPIKEBOT1 and T128_ANIMBLK_SPIKEBOT2.
  * The `tuerkas128_spr_bitmaps.asm` file must contain a lookup table with as much elements as sprite types. Every entry in this table is pointer to a sprite bitmap (an its size in bytes). Two or more sprites of different type can share the same bitmap. No examples here.
_______________________________

Created by RetroBensoft, 2025

MIT License

