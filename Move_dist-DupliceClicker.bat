rem 移动dist文件夹中指定版本DupliceClicker.exe文件到当前目录

echo off

set /p comments= 版本: 

rem 在输入的版本号减0.1
REM for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
move /y "dist\DupliceClicker_%comments%.exe" %~d0%~p0DupliceClicker.exe
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch

