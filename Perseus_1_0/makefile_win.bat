@echo off

echo Assembling data block on RAM 2
pasmo --public bank_2_data.asm bank_2_data.bin bank_2_data.sym
echo ...

echo Assembling RAM 5
pasmo --public bank_5.asm bank_5.bin bank_5.sym
echo ...

echo Assembling RAM 7
pasmo --public bank_7.asm bank_7.bin bank_7.sym
echo ...

echo Assembling Slow RAM #1
pasmo --public bank_S1.asm bank_S1.bin bank_S1.sym
echo ....

echo Assembling Slow RAM #2
pasmo --public bank_S2.asm bank_S2.bin bank_S2.sym
echo ....

echo Assembling Fast RAM #1
pasmo --public bank_F1.asm bank_F1.bin bank_F1.sym
echo ....

echo Assembling Fast RAM #2
pasmo --public bank_F2.asm bank_F2.bin bank_F2.sym
echo ....

echo Assembling RAM 0
pasmo --public bank_0.asm bank_0.bin bank_0.sym
echo ...

echo Assembling main block on RAM 2
pasmo --public bank_2.asm bank_2.bin bank_2.sym
echo ...

powershell -ExecutionPolicy Bypass -file .\makefile_win.ps1

echo Assembling loader
pasmo --public loader.asm loader.bin loader.sym
echo ...

echo Generating TAP file
GenTape   perseus.tap   basic Perseus 10 loader.bin   data perseus.scr   data bank_5.bin   data bank_2.bin   data bank_0.bin   data bank_7.bin   data bank_S1.bin   data bank_S2.bin   data bank_F1.bin   data bank_F2.bin
echo ...
