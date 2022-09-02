# 功能说明：收集png图标资源，添加格式并复制，为创建文件：resource.qrc 用于生成 resource.py 二进制文件

import os
import pyperclip
count = 0
def CopyName(inp):
    global count
    count = 0
    ext = 'png'
    os.chdir(inp)
    fName = '<RCC>\n\t<qresource prefix="/">\n'

 # 收集文件完整路径
    for file in os.listdir():      # file文件名带后缀名
        if not os.path.isdir(file):
            if file.endswith(ext.upper()) or file.endswith(ext.lower()):  # endswith()判断括号里字符是否等于扩展名，返回Bool
                fName += '\t\t<file>'+file+'</file>' + '\n'   # 文件名.扩展名
                count += 1

    fName += '\t</qresource>\n</RCC>'
        # print(os.path.join(root, file))
    if count > 0:
        pyperclip.copy(fName)
    pyperclip.copy(fName)
    return None
q='y'
while q=='y':
    inp = input('输入路径：')
    CopyName(inp)
    print('共{}个文件，已复制到剪贴板'.format(count))
