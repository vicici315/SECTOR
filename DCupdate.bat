@echo off

taskkill /f /im DupliceClicker.exe

del /f %~d0%~p0DupliceClicker.exe
timeout /nobreak /t 2
copy /y "\\192.168.10.38\点睛工作室\Softs\DUPCLICKER\DupliceClicker.exe" %~d0%~p0DupliceClicker.exe
copy /y "\\192.168.10.38\点睛工作室\Softs\DUPCLICKER\DupliceClicker,Desktop.bat" "%~d0%~p0DupliceClicker,Desktop.bat"

if not exist "%USERPROFILE%\Desktop\DupliceClicker.lnk" call "DupliceClicker,Desktop.bat"
start DupliceClicker.exe
exit