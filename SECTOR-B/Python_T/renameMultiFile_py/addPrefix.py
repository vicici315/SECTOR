# 功能说明：添加前缀。

import os


def SubFloder():
    pp = input('输入路径：')
    if pp == 'exit':
        exit()
    oldNs = []
    newNs = []
    ext = '.mp3'
    for root, dirs, files in os.walk(pp):
        for file in files:  # file文件名带后缀名
            if file.endswith(ext):
                print(dirs)
                oldN = os.path.join(root, file)
                newName = os.path.join(root, '9-' + file)
                # os.rename(oldN, newName)


q = 'q'
while q == 'q':
    SubFloder()
