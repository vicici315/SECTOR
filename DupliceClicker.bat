echo off

set /p comments= ����汾: 

rem ������İ汾�ż�0.1
REM for /f %%A in ('powershell -command "[math]::Round(%comments% - 0.1, 2)"') do set "result=%%A"
set /a "result=comments - 1"
rem ɾ���ļ����ļ���
del /q %~n0_%result%.spec
RD /Q /S build\%~n0_%result%\

call %~dp0venv\Scripts\activate

chcp 65001
c:\Users\Administrator\AppData\Local\Programs\Python\Python39\Scripts\pyinstaller.exe D:\Gits\MyWinUI\DupliceClicker.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
pause

chcp 936
echo �Ƿ��ƶ�����Ŀ¼�������������
pause
move /y "dist\DupliceClicker_%comments%.exe" %~d0%~p0DupliceClicker.exe
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch

