# 功能说明：遍历指定目录下包括子目录里的pdf文件，去除前面的编号，去除后面括号内容，进行重命名。

import os
def BatchFile(pp):
    if pp=='exit':
        exit()

def SubFloder(pp):
    if pp=='exit':
        exit()
    oldNs = []
    newNs = []
    ext = '.TGA'    # 注意后缀名区分大小写
    count = 0
    for root, dirs, files in os.walk(pp):   #这里的dirs是空的
        # root = 第一个循环是（根目录路径），随后是（根目录+子目录路径）
        if root.find('(') >= 0:
            pf = root.split('(')[1]
            prefix = pf.split(')')[0]   #提取目录名括号中的数字编号
            # print(prefix)
        for file in files:  #file文件名带后缀名
            if file.endswith(ext):
                # print(os.path.join(root, file))
                newName = prefix+'~'+file.split('~')[1] #以~为分隔，替换前面部分字符
                # if file.find('【') >= 0:
                #     newName = file.split('【')[0]+ext  #拆分后需要再加上后缀
                # if file.find('（') >= 0:
                #     newName = file.split('（')[0]+ext
                # if file.find('(') >= 0:
                #     newName = file.split('(')[0]+ext
                # if file.find('-') >= 0:
                #     newName = newName[2:]
                # if file.find('【') >= 0 or file.find('(') >= 0 or file.find('（') >= 0:
                if file.find('~') >= 0:
                    oldNs.append(os.path.join(root, file))
                    newNs.append(os.path.join(root, newName))  #通过join()把路径与文件名结合避免子文件夹里的文件缺少斜杠出错
                    count += 1
                    print(newName)
    que=input('共{}个文件，是否确定按如上重命名 (y\\n)'.format(count))
    if que == 'y':
        c = 0
        for f in oldNs:
            print('□{}\n■{}'.format(f,newNs[c]))
            os.rename(f, newNs[c])
            c += 1
    else:
        return None


q='q'
while q=='q':
    pp = input('重命名路径~子目录(y/n)：')
    SubFloder(pp)
