@echo off
rem ==================================================
rem  Build script that uses the local venv environment
rem  (DupliceClicker.py + venv\Scripts\pyinstaller.exe)
rem ==================================================

set "APPNAME=DupliceClicker"
set /p comments=Enter build version:

rem Delete previous build/dist artifacts, then rebuild
"%~dp0venv\Scripts\pyinstaller.exe" --clean -y DupliceClicker.py
rem Subtract 0.1 from the entered version number
rem for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
set /a "result=comments - 1"
rem Delete temporary files and folders
del /q "%APPNAME%_%result%.spec" 2>nul
if exist "build\%APPNAME%_%result%" RD /Q /S "build\%APPNAME%_%result%"

call "%~dp0venv\Scripts\activate"

chcp 65001 >nul
"%~dp0venv\Scripts\pyinstaller.exe" --collect-all cryptography DupliceClicker.py -w -F --icon=DupliceClicker.ico -n=%APPNAME%_%comments%
rem Alternative pyinstaller path if needed:
rem d:\Gits\MyWinUI\venv\Scripts\pyinstaller.exe --collect-all cryptography DupliceClicker.py -w -F --icon=DupliceClicker.ico -n=%APPNAME%_%comments%
pause

chcp 936 >nul
echo Move exe to root directory? Press any key to continue.
pause
move /y "dist\%APPNAME%_%comments%.exe" "%~dp0%APPNAME%.exe"
pause

rem pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch
