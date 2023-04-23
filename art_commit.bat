@echo off
set d=%date:~0,1000%
set t=%time:~0,8%
set timestamp=%d% %t%
 if not exist "ver.txt" echo 0 >> ver.txt
set filePath=ver.txt
set /a lastline = 0
for /f  %%i in (%filePath%) do (
	set /a lastline=lastline+1
)

echo 类型参考：^<New、Edit、Test、Revert^>
echo 书写格式参考：^<类型^>:^<内容^>
echo.
set /p comments= 本地提交说明: 
echo [%timestamp%] commit: %comments% (%COMPUTERNAME%) v%lastline% >> history.txt
echo %lastLine% >> ver.txt

git commit -m "[%timestamp%] commit: %comments% (%COMPUTERNAME%) v%lastline%"

git log --stat -1
echo "Finished Add!"
pause