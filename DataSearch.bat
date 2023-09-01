echo off

set /p comments= 编译版本: 

rem 在输入的版本号减0.1
REM for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
set /a "result=comments - 1"
rem 删除文件和文件夹
del /q %~n0_%result%.spec
RD /Q /S build\%~n0_%result%\

call %~dp0venv\Scripts\activate

chcp 65001
%~dp0venv\Scripts\pyinstaller %~dp0%~n0.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch

