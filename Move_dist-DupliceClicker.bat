rem �ƶ�dist�ļ�����ָ���汾DupliceClicker.exe�ļ�����ǰĿ¼

echo off

set /p comments= �汾: 

rem ������İ汾�ż�0.1
REM for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
move /y "dist\DupliceClicker_%comments%.exe" %~d0%~p0DupliceClicker.exe
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch

