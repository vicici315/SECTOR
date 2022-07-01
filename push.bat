@echo off

git status
set/p a=确定执行推送到远程吗？(y/n)
if %a% == y git push

git log --stat -1
echo [%timestamp%] comments: %comments% >> history.txt
echo "Finished Push!"
pause