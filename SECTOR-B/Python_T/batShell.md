## 批处理命令简介

- echo

- rem

- pause

- call

- start

- goto

- set

  http://xstarcd.github.io/wiki/windows/windows_cmd_summary_commands.html

## **批处理符号简介**

- 回显屏蔽 @
- 重定向1 >与>>
- 重定向2 <
- 管道符号 |
- 转义符 ^
- 逻辑命令符包括：&、&&、||

## **常用DOS命令**

#### 文件夹管理

- cd 显示当前目录名或改变当前目录。
- md 创建目录。
- rd 删除一个目录。
- dir 显示目录中的文件和子目录列表。
- tree 以图形显示驱动器或路径的文件夹结构。
- path 为可执行文件显示或设置一个搜索路径。
- xcopy 复制文件和目录树。



#### **文件管理**

- type 显示文本文件的内容。
- copy 将一份或多份文件复制到另一个位置。
- del 删除一个或数个文件。
- move 移动文件并重命名文件和目录。(Windows XP Home Edition中没有)
- ren 重命名文件。
- replace 替换文件。
- attrib 显示或更改文件属性。
- find 搜索字符串。
- fc 比较两个文件或两个文件集并显示它们之间的不同



#### **网络命令**

- ping 进行网络连接测试、名称解析
- ftp 文件传输
- net 网络命令集及用户管理
- telnet 远程登陆
- ipconfig显示、修改TCP/IP设置
- msg 给用户发送消息
- arp 显示、修改局域网的IP地址-物理地址映射列表



#### **系统管理**

- at 安排在特定日期和时间运行命令和程序
- shutdown立即或定时关机或重启
- tskill 结束进程
- taskkill结束进程(比tskill高级，但WinXPHome版中无该命令)
- tasklist显示进程列表(Windows XP Home Edition中没有)
- sc 系统服务设置与控制
- reg 注册表控制台工具
- powercfg控制系统上的电源设置

对于以上列出的所有命令，在cmd中输入命令+/?即可查看该命令的帮助信息。如find /?



### **Windows Batch 常用命令**

```shell
1 echo 和 @回显命令
@                     #关闭单行回显
echo off              #从下一行开始关闭回显
@echo off             #从本行开始关闭回显。一般批处理第一行都是这个
echo on               #从下一行开始打开回显
echo                  #显示当前是 echo off 状态还是 echo on 状态
echo.                 #输出一个”回车换行”，空白行
                         #(同echo, echo; echo+ echo[ echo] echo/ echo)2 errorlevelecho %errorlevel%
每个命令运行结束，可以用这个命令行格式查看返回码
默认值为0，一般命令执行出错会设 errorlevel 为13 dir显示文件夹内容
dir                  #显示当前目录中的文件和子目录
dir /a               #显示当前目录中的文件和子目录，包括隐藏文件和系统文件
dir c: /a:d          #显示 C 盘当前目录中的目录
dir c: /a:-d         #显示 C 盘根目录中的文件
dir c: /b/p         #/b只显示文件名，/p分页显示
dir *.exe /s         #显示当前目录和子目录里所有的.exe文件4 cd切换目录
cd                  #进入根目录
cd                   #显示当前目录
cd /d d:sdk         #可以同时更改盘符和目录5 md创建目录
md d:abc          #如果 d:a 不存在，将会自动创建中级目录
#如果命令扩展名被停用，则需要键入 mkdir abc。6 rd删除目录
rd abc               #删除当前目录里的 abc 子目录，要求为空目录
rd /s/q d:temp      #删除 d:temp 文件夹及其子文件夹和文件，/q安静模式7 del删除文件
del d:test.txt      #删除指定文件，不能是隐藏、系统、只读文件
del /q/a/f d:temp*.*
删除 d:temp 文件夹里面的所有文件，包括隐藏、只读、系统文件，不包括子目录
del /q/a/f/s d:temp*.*
删除 d:temp 及子文件夹里面的所有文件，包括隐藏、只读、系统文件，不包括子目录8 ren重命名命令
ren d:temp tmp      #支持对文件夹的重命名9 cls清屏10 type显示文件内容
type c:boot.ini     #显示指定文件的内容，程序文件一般会显示乱码
type *.txt           #显示当前目录里所有.txt文件的内容11 copy拷贝文件
copy c:test.txt d:test.bak
复制 c:test.txt 文件到 d: ，并重命名为 test.bak
copy con test.txt
从屏幕上等待输入，按 Ctrl+Z 结束输入，输入内容存为test.txt文件
con代表屏幕，prn代表打印机，nul代表空设备
copy 1.txt + 2.txt 3.txt
合并 1.txt 和 2.txt 的内容，保存为 3.txt 文件
如果不指定 3.txt ，则保存到 1.txt
copy test.txt +
复制文件到自己，实际上是修改了文件日期12 title设置cmd窗口的标题
title 新标题         #可以看到cmd窗口的标题栏变了13 ver显示系统版本14 label 和 vol设置卷标
vol                  #显示卷标
label                #显示卷标，同时提示输入新卷标
label c:system       #设置C盘的卷标为 system15 pause暂停命令16 rem 和 ::注释命令
注释行不执行操作17 date 和 time日期和时间
date           #显示当前日期，并提示输入新日期，按"回车"略过输入
date/t         #只显示当前日期，不提示输入新日期
time           #显示当前时间，并提示输入新时间，按"回车"略过输入
time/t         #只显示当前时间，不提示输入新时间18 goto 和 :跳转命令
:label         #行首为:表示该行是标签行，标签行不执行操作
goto label     #跳转到指定的标签那一行19 find (外部命令)查找命令
find "abc" c:test.txt
在 c:test.txt 文件里查找含 abc 字符串的行
如果找不到，将设 errorlevel 返回码为1
find /i “abc” c:test.txt
查找含 abc 的行，忽略大小写
find /c "abc" c:test.txt
显示含 abc 的行的行数20 more (外部命令)逐屏显示
more c:test.txt     #逐屏显示 c:test.txt 的文件内容21 tree显示目录结构
tree d:             #显示D盘的文件目录结构22 &顺序执行多条命令，而不管命令是否执行成功23 &&顺序执行多条命令，当碰到执行出错的命令后将不执行后面的命令
find "ok" c:test.txt && echo 成功
如果找到了"ok"字样，就显示"成功"，找不到就不显示24 ||顺序执行多条命令，当碰到执行正确的命令后将不执行后面的命令
find "ok" c:test.txt || echo 不成功
如果找不到"ok"字样，就显示"不成功"，找到了就不显示
```

https://www.cnblogs.com/lsgxeva/p/10694546.html

## bat示例

### 判断文件是否存在，不存在跳到错误，否则执行

```shell
@echo off

REM Install PS4 visualizer if the SDK and installation file are present
if exist "%~dp0Engine\Extras\VisualStudioDebugging\PS4\InstallPS4Visualizer.bat" (
  call "%~dp0Engine\Extras\VisualStudioDebugging\PS4\InstallPS4Visualizer.bat"
)

if not exist "%~dp0Engine\Build\BatchFiles\GenerateProjectFiles.bat" goto Error_BatchFileInWrongLocation
call "%~dp0Engine\Build\BatchFiles\GenerateProjectFiles.bat" %*
exit /B %ERRORLEVEL%

:Error_BatchFileInWrongLocation
echo GenerateProjectFiles ERROR: The batch file does not appear to be located in the root UE4 directory.  This script must be run from within that directory.
pause
exit /B 1
```

### 特定目录执行命令

```shell
echo
call c:\Users\vic.zeng\AppData\Local\Programs\Python\Python39\Scripts\pyrcc5 -o d:\TempFiles\code_file\qt_code\resource.py d:\TempFiles\code_file\qt_code\resource.qrc
pause
```

