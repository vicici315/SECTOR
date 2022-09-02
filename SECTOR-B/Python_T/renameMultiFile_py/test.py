import mutagen
from mutagen.easyid3 import EasyID3
fp = "9-12 Key Trouble.mp3"
try:
    f = EasyID3(fp)
except mutagen.id3.ID3NoHeaderError:    # 判断ID3没有信息时添加标签
    f = mutagen.File(fp, easy=True)
    f.add_tags()
f['title'] = fp
f.save()
# print(f.List)

# f.save()