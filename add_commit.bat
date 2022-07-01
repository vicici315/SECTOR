@echo off
set d=%date:~0,10%
set t=%time:~0,8%
set timestamp=%d% %t%
 if not exist "ver.txt" echo 0 >> ver.txt
set filePath=ver.txt
set /a lastline = 0
for /f  %%i in (%filePath%) do (
	set /a lastline=lastline+1
)

 
set /p comments=please input commit commits:
echo [%timestamp%] commit: %comments% v%lastline% >> history.txt
echo %lastLine% >> ver.txt
 
git add .
git commit -m "[%timestamp%] commit: %comments% v%lastline%"

git log --stat -1
echo "Finished Add!"
pause