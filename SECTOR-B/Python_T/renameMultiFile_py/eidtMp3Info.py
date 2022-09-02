
# from mutagen.id3 import ID3, APIC, TIT2, TPE1, TALB
from mutagen.easyid3 import EasyID3
import os

# def SetMp3Info(path, info):
#     songFile = ID3(path)
#     if info['picData'] != '':
#         songFile['APIC'] = APIC(  # 插入封面
#             encoding=3,
#             mime='image/jpeg',
#             type=3,
#             desc=u'Cover',
#             data=info['picData']
#         )
#     songFile['TIT2'] = TIT2(  # 插入歌名
#         encoding=3,
#         text=info['title']
#     )
#     songFile['TPE1'] = TPE1(  # 插入第一演奏家、歌手、等
#         encoding=3,
#         text=info['artist']
#     )
#     songFile['TALB'] = TALB(  # 插入专辑名
#         encoding=3,
#         text=info['album']
#     )
#     songFile.save()
#     print(path)


def EditMp3(pic):
    pp = input('输入路径：')
    if pp == 'exit':
        exit()
    ext = ['.mp3', '.MP3']
    count = 0
    if pic != '':
        picPath = picData
        with open(picPath, 'rb') as f:
            picData = f.read()
    else:
        picData = ''
    for e in ext:
        for root, dirs, files in os.walk(pp):
            for file in files:  # file文件名带后缀名
                if file.endswith(e):
                    oldNs = (os.path.join(root, file))
                    til = file.split('.')[0]
                    # info = {'picData': picData, 'title': til,
                    #         'artist': 'art', 'album': 'Oxford'}
                    print(oldNs)
                    try:
                        f = EasyID3(oldNs)                # 如果有ID信息直接获取
                    except mutagen.id3.ID3NoHeaderError:  # 如获取失败ID3没有信息时用add_tags添加标签
                        f = mutagen.File(oldNs, easy=True)# 获取文件
                        f.add_tags()
                    f["title"] = til
                    f.save()
                    count += 1
    print('共{}个文件'.format(count))

q = 'q'
while q == 'q':
    EditMp3('')
