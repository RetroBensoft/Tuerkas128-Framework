# Perseus (2025)

A game written in Z80 assembly code for the ZX Spectrum 128k

### Requirements
* Windows 10/11 (I'm pretty sure a Lixux version is easy to implement)
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
* If you want to master Tuerkas128 Framework a good way to start with is by doing mods. The easiest mod is customizing screens. Blocks and superblocks definitions are in the `screens` folder. Game map is defined in the `screens` folder as well. Map size is defined by T128_SCREEN_ROW_1 located at `framework\tuerkas128_constants.asm`.
* Tutorials are available at https://www.youtube.com/@RetroBensoft (only in spanish, sorry)

### Project content
* The `_doc_` folder contains documentation.
* The Tuerkas128 Framework core is within the `framework` folder. Some customization can be made by modifying `tuerkas128_constants.asm` and `tuerkas128_global.asm`, but any other file within this folder must not be changed unless you know exactly what you are doing.
* The `framework\AY` folder is the sound tracker based upon the AY-3-8910/8912 specifications.
* The `FSM` folder contains the code for controlling sprites, animated blocks and main char behaivour. The operation of animated blocks is hard-wired in the framework, but it can be customized using parameters. Sprites and main char can be fully controlled by programming their FSMs in assembly language using Tuerkas128 Framework data structures. FSM stands for Finite State Machine. 
_______________________________

Created by RetroBensoft, 2025
MIT License

