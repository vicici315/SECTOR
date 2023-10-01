echo off

rem 批处理中的一个命令，它用于启用延迟环境变量扩展。批处理中的环境变量默认是在批处理脚本开始执行时就展开，即批处理在解析命令之前就会将所有环境变量扩展为其当前值。这样有时会导致意想不到的结果，特别是在使用for循环等结构时
setlocal EnableDelayedExpansion
rem 定义输入的字符串,使用双引号是为了处理含有空格或特殊字符的字符串
set "str=%~n0"

rem 将逗号替换成标记（这里使用了^作为标记，可以根据需要更换为其他字符）
set "str=!str:,=^!"

rem 使用for循环和标记作为分隔符，将字符串分成两段并赋值给变量
for /f "tokens=1,2 delims=^" %%a in ("!str!") do (
    set "var1=%%a"
    set "var2=%%b"
)

rem 输出结果
echo var1: %var1%
echo var2: %var2%


set Program=%~d0%~p0%var1%.exe
set LnkName=ThrottleStop
set WorkDir=%~d0%~p0
if not defined WorkDir call:GetWorkDir "%Program%"
(echo Set WshShell=CreateObject("WScript.Shell"^)
if "%var2%"=="Desktop" (
	echo strDesKtop=WshShell.SpecialFolders("DesKtop"^)
	echo Set oShellLink=WshShell.CreateShortcut(strDesKtop^&"\%var1%.lnk"^)
) else (
	echo Set oShellLink=WshShell.CreateShortcut("C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\%var1%.lnk"^)
)
echo oShellLink.TargetPath="%Program%"
echo oShellLink.WorkingDirectory="%WorkDir%"
echo oShellLink.WindowStyle=1
echo oShellLink.Description="%Desc%"
echo oShellLink.Save)>makelnk.vbs
echo 快捷方式创建成功！
makelnk.vbs
del /f /q makelnk.vbs
exit
goto :eof
:GetWorkDir
set WorkDir=%~dp1
set WorkDir=%WorkDir:~,-1%
goto :eof

endlocal
pause