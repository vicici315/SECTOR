echo off

set /p comments= 编译版本: 
::删除之前的 build 和 dist 文件夹，然后重新打包
pyinstaller --clean -y SmartStock.py
rem 在输入的版本号减0.1
REM for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
set /a "result=comments - 1"
rem 删除文件和文件夹
del /q %~n0_%result%.spec
RD /Q /S build\%~n0_%result%\

call %~dp0venv\Scripts\activate

chcp 65001
c:\Users\%username%\AppData\Local\Programs\Python\Python39\Scripts\pyinstaller.exe --collect-all cryptography SmartStock.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
::pyinstaller.exe --collect-all cryptography SmartStock.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
::d:\Gits\MyWinUI\venv\Scripts\pyinstaller.exe --collect-all cryptography SmartStock.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
pause

chcp 936
echo 是否移动到根目录，任意键继续。
pause
move /y "dist\SmartStock_%comments%.exe" %~d0%~p0SmartStock.exe
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch

