@echo off

taskkill /f /im DupliceClicker.exe

REM del /f %~d0%~p0DupliceClicker.exe
timeout /nobreak /t 2
copy /y "\\192.168.10.38\自研产品部\S1产品部\Softs\DUPCLICKER\DupliceClicker.exe" %~d0%~p0DupliceClicker.exe
copy /y "\\192.168.10.38\自研产品部\S1产品部\Softs\DUPCLICKER\DupliceClicker,Desktop.bat" "%~d0%~p0DupliceClicker,Desktop.bat"

if not exist "%USERPROFILE%\Desktop\DupliceClicker.lnk" call "DupliceClicker,Desktop.bat"
start DupliceClicker.exe
exit