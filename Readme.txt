说明：查重数据库工具DupliceClicker

本地仓库：http://localhost:3000/viczeng/vic.remote.git
远程仓库：https://github.com/vicici315/SECTOR.git

分支：master_dupcheck

23.00
数据库dbid选择使用cryptography模块加密；空关键字搜索提示显示全部；修复list2选中记录bug
23.02
优化虚拟表格删除文件标识（del）的传递显示；#虚拟表格取消文件存在检查
23.03
添加查重列表读取显示self.data内存占用
23.04
优化获取拷贝文件进度显示
23.05
修改搜索图标；导入排除~$文件

24.00
修复获取待提交文件列表后，删除个别文件排序影响拷贝问题 #重新排序待拷贝文件
24.01
删除待拷贝字典使用del self.PerCopyFiles[L]，避免使用pop时带来多余反馈信息

25.0
添加根目录的文件所有类型获取
25.01
添加list获取文件数量Tooltip显示
25.02
修复获取拷贝文件时不勾选虚拟表格不载入虚拟表格数据
25.03
修复拷贝按钮隐藏后刷新界面