#
# Windows Powershell Script
# 
# Read template file loader_template.asm and replaces file size tokens with real file sizes for the following binary files:
#
#   .\bank_0.bin"
#   .\bank_2.bin"
#   .\bank_5.bin"
#   .\bank_7.bin"
#   .\bank_F1.bin"
#   .\bank_F2.bin"
#   .\bank_S1.bin"
#   .\bank_S2.bin"
#
# Template file loader_template.asm must contain the folowing tokens:
#	<Size0>
#	<Size2>
#	<Size5>
#	<Size7>
#	<SizeFB1>
# 	<SizeFB2>
# 	<SizeSB1>
# 	<SizeSB2>
#
# Outfile is loader.asm
#
###################################################################################################


Write-Host "Processing loader_template.asm --> loader.asm "

#
# Binary files
#
$file0 = ".\bank_0.bin"
$file2 = ".\bank_2.bin"
$file5 = ".\bank_5.bin"
$file7 = ".\bank_7.bin"
$fileFB1= ".\bank_F1.bin"
$fileFB2= ".\bank_F2.bin"
$fileSB1= ".\bank_S1.bin"
$fileSB2= ".\bank_S2.bin"


#
# Loader template
#
$templateFile = ".\loader_template.asm"

#
# Output file
#
$finalFile = ".\loader.asm"

#
# Get file sizes
#
$file0Size = (Get-Item $file0).Length
$file2Size = (Get-Item $file2).Length
$file5Size = (Get-Item $file5).Length
$file7Size = (Get-Item $file7).Length
$fileFB1Size = (Get-Item $fileFB1).Length
$fileFB2Size = (Get-Item $fileFB2).Length
$fileSB1Size = (Get-Item $fileSB1).Length
$fileSB2Size = (Get-Item $fileSB2).Length

#
# Binary files
#
$textContent = Get-Content $templateFile

#
# Tokens
#
$mark0 = "<Size0>"
$mark2 = "<Size2>"
$mark5 = "<Size5>"
$mark7 = "<Size7>"
$markFB1 = "<SizeFB1>"
$markFB2 = "<SizeFB2>"
$markSB1 = "<SizeSB1>"
$markSB2 = "<SizeSB2>"

#
# Replace tokes with file sizes
#
$textNewContent = $textContent -replace $mark0, $file0Size -replace $mark2, $file2Size -replace $mark5, $file5Size -replace $mark7, $file7Size -replace $markFB1, $fileFB1Size -replace $markFB2, $fileFB2Size -replace $markSB1, $fileSB1Size -replace $markSB2, $fileSB2Size

#
# Output file
#
$textNewContent | Set-Content $finalFile 

Write-Host "..."


