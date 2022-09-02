import os


pp = input('输入重命名路径：')
os.chdir(pp)

for f in os.listdir():
  f_name, f_ext = os.path.splitext(f)
  if f_ext == ".pdf":
    newName = f_name
    if f_name.find('【') >= 0:
       newName = f_name.split('【')[0]
    if f_name.find('(') >= 0:
       newName = f_name.split('(')[0]
    if f_name.find('-') >= 0:
        newName = newName[2:]
    newName = newName + f_ext
    os.rename(f, newName)
    print(newName)
