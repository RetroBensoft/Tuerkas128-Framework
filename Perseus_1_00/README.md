# Perseus (2025)

A game written in Z80 assembly code for the ZX Spectrum 128k

### Requirements
* Windows 10/11 (I'm pretty sure a Lixux version is easy to implement)
* pasmo.exe and gentape.exe folders must be in Windows PATH variable

### Development tools:
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
* Run `makefile_win.bat` to generate `perseus.tap`
* `makefile_win.bat` uses PASMO to assembly the code, `makefile_win.ps1` (Windows PowerShell) to generate `loader.asm` from `loader_template.asm`, and GENTAPE to produce `perseus.tap`
* Main code is in `bank_2.asm`. If you want to dive into the code you can start from here.
* If you ant to dive into Tuerkas128 Framework a good way to start is by doing mods. The easiest mod is changing screens. Blocks and superblocks definitions are in the `screens` folder. Game map is defined in tha `screens`folder as well.
_______________________________

Created by RetroBensoft, 2025
