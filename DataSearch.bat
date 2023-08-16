echo off

set /p comments= ±‡“Î∞Ê±æ: 
del /q %~n0_%comments%.spec
RD /Q /S build\%~n0_%comments%\

call %~dp0venv\Scripts\activate

chcp 65001
%~dp0venv\Scripts\pyinstaller %~dp0%~n0.py -w -F --icon=%~n0.ico -n=%~n0_%comments%
pause

::pyinstaller d:\Gits\MyWinUI\DataSearch.py -w -F --icon=d:\Gits\MyWinUI\DataSearch.ico -n=DataSearch