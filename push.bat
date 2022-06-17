@echo off
set d=%date:~0,10%
set t=%time:~0,8%
set timestamp=%d% %t%
 
set /p comments=please input commit commits:
echo [%timestamp%] commit: %comments% >> history.txt
 
git add .
git commit -m "[%timestamp%] commit: %comments%"
git push
git log --stat -1
echo "Finished Push!"
pause