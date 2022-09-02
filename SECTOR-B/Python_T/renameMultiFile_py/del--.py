# 功能说明：遍历指定目录下包括子目录里的mp3文件，去除后面--内容，进行重命名。

import os


def SubFloder():
    pp = input('输入重命名路径：')
    if pp == 'exit':
        exit()
    oldNs = []
    newNs = []
    ext = ['.mp3', '.MP3']
    count = 0
    for root, dirs, files in os.walk(pp):  # 这里的dirs是空的
        for file in files:  # file文件名带后缀名
            for e in ext:
                if file.endswith(e):
                    # print(os.path.join(root, file))
                    newName = file
                    if file.find('--') >= 0:
                        newName = file.split('--')[0] + e  # 拆分后需要再加上后缀
                    # if file.find('-') >= 0:
                    #     newName = newName[2:]
                    if file.find('--') >= 0:
                        oldNs.append(os.path.join(root, file))
                        newNs.append(os.path.join(root, newName))  # 通过join()把路径与文件名结合避免子文件夹里的文件缺少斜杠出错
                        count += 1
                        print(newName)
    if count > 0:
        que = input('共{}个文件，是否确定按如上重命名 (y\\n)'.format(count))
        if que == 'y':
            c = 0
            for f in oldNs:
                print('□{}\n■{}'.format(f, newNs[c]))

                os.rename(f, newNs[c])
                c += 1
        else:
            return None
    else:
        return None


q = 'q'
while q == 'q':
    SubFloder()
