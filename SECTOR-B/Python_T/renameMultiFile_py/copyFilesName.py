# 功能说明：复制指定文件夹里的所有文件名。
# 输入路径和文件扩展名，例 g:\downloads\.exe
# 全部类型 g:\downloads\*

import os
import pyperclip
count = 0
def CopyName(inp):
    global count
    count = 0
    if inp.find('\\*') >= 0:
        pp = inp.split('\\*')[0]
        ext = '*'
    else:
        ppp = inp.split('\\.')
        pp = ppp[0]
        ext = ppp[1]
    # os.chdir(pp)
    fName = ''
    # for f in os.listdir():    # os.listdir()列出文件夹里的所有文件
    #   f_name, f_ext = os.path.splitext(f)
    #   if f_ext == ext:
    #     fName += f_name+'\n'
    for root, dirs, files in os.walk(pp):  # 这里的dirs是空的
        fs = False
        for o in os.listdir(root):  #遍历判断文件夹内只有文件夹时不打印该路径
            idir = os.path.join(root,o) #合并完整路径
            if ext != '*':
                if os.path.isdir(idir) == False and o.endswith(ext.upper()) or o.endswith(ext.lower()):    #判断不是文件夹 and 限制文件格式
                    fs = True
                    break
            else:
                if os.path.isdir(idir) == False:    #不限制文件类型
                    fs = True
                    break
        if fs:  #实现只有符合文件类型或文件夹内有文件才获取该文件夹路径
            fName += root + '\\\n'
        # if len(dirs) == 0:  #判断当前root目录下如果没有文件夹，就输出root目录
        #     fName += root + '\n'  # 加入目录名
 # 收集文件完整路径
        for file in files:      # file文件名带后缀名
            if ext != '*':
                if file.endswith(ext.upper()) or file.endswith(ext.lower()):  # endswith()判断括号里字符是否等于扩展名，返回Bool
                    fName += file + '\n'   # 文件名.扩展名
                    count += 1
            else:
                fName += file + '\n'
                count += 1

        # print(os.path.join(root, file))
    if count > 0:
        pyperclip.copy(fName)
    pyperclip.copy(fName)
    return None
q='y'
while q=='y':
    inp = input('输入路径和文件后缀名，所有类型输入（*）：')
    CopyName(inp)
    print('共{}个文件，已复制到剪贴板'.format(count))
