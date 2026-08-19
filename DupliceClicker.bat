echo off

set /p comments= Enter build version:
::Delete previous build/dist artifacts, then rebuild
pyinstaller --clean -y DupliceClicker.py
rem Subtract 0.1 from the entered version number
REM for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
set /a "result=comments - 1"
rem Delete temporary files and folders
del /q %~n0_%result%.spec
RD /Q /S build\%~n0_%result%\

call %~dp0venv\Scripts\activate

chcp 65001
c:\Users\%username%\AppData\Local\Programs\Python\Python39\Scripts\pyinstaller.exe --collect-all cryptography DupliceClicker.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
::d:\Gits\MyWinUI\venv\Scripts\pyinstaller.exe --collect-all cryptography DupliceClicker.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
pause

chcp 936
echo Move exe to root directory? Press any key to continue.
pause
move /y "dist\DupliceClicker_%comments%.exe" %~d0%~p0DupliceClicker.exe
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch

