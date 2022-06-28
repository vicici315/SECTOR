
@echo off
 if not exist "ver.txt" echo 0 >> ver.txt
set filePath=ver.txt
set /a num = 0
for /f %%i in (%filePath%) do (
	set /a num=num+1
)

echo %num% >> ver.txt

pause