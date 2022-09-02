# 功能说明：ViciciTools

import os

import pyperclip as pyperclip
from mutagen import File, id3
from mutagen.easyid3 import EasyID3
from PyQt5.QtWidgets import QMainWindow
# from numpy import random

OLDNAME = []
NEWNAME = []
FileNum = 0
from tui import Ui_MainWindow
class RenameC(QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = Ui_MainWindow()
        self.PPf = 0

    def mp3InfoEdit(self, oldN, newN):
        try:
            f = EasyID3(oldN)  # 如果有ID信息直接获取
            print(f)
        except id3.ID3NoHeaderError:  # 如获取失败ID3没有信息时用add_tags添加标签
            f = File(oldN, easy=True)  # 获取文件
            f.add_tags()
        f["title"] = newN
        f.save()

    def CopyFilename(self,PC):
        pp = self.ui.lineEdit_2.text()
        if os.path.exists(pp):
            if PC > 0:
                COPY = ''
                count = 0
                self.PPf = 0
                self.ui.progressBar_2.show()
                self.ui.percent_lbl_2.show()
                self.ui.progressBar_2.setMaximum(PC)
                ext = (self.ui.copy_ext_le.text()).split(';')
                prefix = self.ui.copy_prefix_le.text()
                suffix = self.ui.copy_suffix_le.text()
                if self.ui.subDir_chk.checkState() == 2:
                    for root, dirs, files in os.walk(pp):
                        fs = False
                        if  self.ui.copy_parentName_chk.checkState() == 2:
                            countF = 0
                            for o in os.listdir(root):
                                fl,ex = os.path.splitext(o)
                                if fl.find(self.ui.copy_filter_le.text()) >= 0:
                                    idir = os.path.join(root,o)
                                    for e in ext:
                                        if os.path.isdir(idir) == False:    # 判断是否是文件夹，需跟下面的格式过滤分开
                                            if o.endswith(e.upper()) or o.endswith(e.lower()):
                                                fs = True
                                                countF+=1
                        if fs:
                            COPY += root + '    >>>【{}个文件】\n'.format(countF)
                        for f in files:
                            for e in ext:
                                if f.endswith(e.upper()) or f.endswith(e.lower()):
                                    fl,ex = os.path.splitext(f)
                                    if fl.find(self.ui.copy_filter_le.text()) >= 0:
                                        ff = os.path.join(root,f)
                                        if self.ui.copy_extName_chk.checkState()==2:
                                            extN = ex
                                        else:
                                            extN = ''
                                        if self.ui.copy_size_chk.checkState()==2:
                                            sNum = os.path.getsize(ff)
                                            ns = str(sNum) + 'B'
                                            if sNum > 1024:
                                                kNum = sNum / 1024
                                                ns = str(round(kNum,2)) + 'K'
                                                if kNum > 1024:
                                                    mNum = kNum / 1024
                                                    ns = str(round(mNum,2)) + 'M'
                                            size = ' ('+str(ns)+')'
                                        else:
                                            size = ''
                                        COPY += prefix + fl + extN + suffix + size + '\n'
                                        count += 1
                                        self.PPf += 1
                                        self.ui.progressBar_2.setValue(self.PPf)
                                        val = self.PPf/PC
                                        self.ui.percent_lbl_2.setText(str(int(val*100))+'%')
                else:
                    for f in os.listdir(pp):
                        ff = os.path.join(pp,f)
                        if os.path.isdir(ff) == False:
                            for e in ext:
                                if f.endswith(e.upper()) or f.endswith(e.lower()):
                                    fl,ex = os.path.splitext(f)
                                    if fl.find(self.ui.copy_filter_le.text()) >= 0:
                                        if self.ui.copy_extName_chk.checkState()==2:
                                            extN = ex
                                        else:
                                            extN = ''
                                        if self.ui.copy_size_chk.checkState()==2:
                                            sNum = os.path.getsize(ff)
                                            ns = str(sNum) + 'B'
                                            if sNum > 1024:
                                                kNum = sNum / 1024
                                                ns = str(round(kNum,2)) + 'K'
                                                if kNum > 1024:
                                                    mNum = kNum / 1024
                                                    ns = str(round(mNum,2)) + 'M'
                                            size = ' ('+str(ns)+')'
                                        else:
                                            size = ''
                                        COPY += prefix + fl + extN + suffix + size + '\n'
                                        count += 1
                                        self.PPf += 1
                                        self.ui.progressBar_2.setValue(self.PPf)
                                        val = self.PPf/PC
                                        self.ui.percent_lbl_2.setText(str(int(val*100))+'%')
                if count > 0:
                    pyperclip.copy(COPY)
                    self.ui.lbl_output.setText('共{}个文件，已复制到剪贴板'.format(count))
                    self.ui.textEdit.show()
                    self.ui.textEdit.setText(COPY)
                else:
                    self.ui.lbl_output.setText('没有找到合适格式的文件！')
            else:
                self.ui.lbl_output.setText('没有可处理的文件！')
        else:
            self.ui.lbl_output.setText('请检查您输入的路径是否正确！')

    def SubFloder(self,PC):
        pp = self.ui.lineEdit.text()
        if os.path.exists(pp):
            if PC > 0:
                global OLDNAME, NEWNAME, FileNum
                OLDNAME = []
                NEWNAME = []
                newName = ''
                allnew=''
                FileNum = PC
                self.PPf = 0
                self.ui.progressBar_2.show()
                if FileNum > 0:
                    self.ui.percent_lbl_2.show()
                self.ui.progressBar_2.setMaximum(PC)
                ext = (self.ui.lineEdit_ext.text()).split(';')
                # self.ui.frame_4.show()
                # self.ui.progressBar_3.show()
                sep = self.ui.sep_le.text()
                if self.ui.prefix_le.text() == '':
                    prefix = ''
                else:
                    prefix = self.ui.prefix_le.text()+sep
                nName = self.ui.newName_le.text()
                if self.ui.suffix_le.text() == '':
                    suffix = ''
                else:
                    suffix = sep+self.ui.suffix_le.text()
                if self.ui.subDir_chk.checkState() == 2:
                    for root, dirs, files in os.walk(pp):   #这里的dirs是空的
                        # root = 第一个循环是（根目录路径），随后是（根目录+子目录路径）
                        if self.ui.folderName_chk.checkState() == 2:
                            if root[-1] == '\\':
                                root = root[0:-1]   #剔除最后一个斜杠，避免最后文件夹分割出空符
                            foN = root.split('\\')
                            foName = foN[len(foN)-1]+sep
                        else:
                            foName = ''
                        fCount = 0
                        fs = False
                        for o in os.listdir(root):
                            fl,ex = os.path.splitext(o)
                            if fl.find(self.ui.lineEdit_filter.text()) >= 0:
                                idir = os.path.join(root,o)
                                for e in ext:
                                    if os.path.isdir(idir) == False:
                                        if o.endswith(e.upper()) or o.endswith(e.lower()):
                                            fs = True
                                            break
                        if fs:
                            allnew+=root+'\\\n'
                        for file in files:  #file文件名带后缀名
                            for e in ext:
                                if file.endswith(e.upper()) or file.endswith(e.lower()):
                                    fName,fExt = os.path.splitext(file)
                                    if fName.find(self.ui.lineEdit_filter.text()) >= 0:
                                        if nName == '':
                                            nnn = fName
                                        else:
                                            nnn = nName
                                        self.PPf += 1   # 使用self配置进度值
                                        fCount += 1
                                        if self.ui.spinBox.value() > 0:
                                            num = sep+str(fCount).zfill(self.ui.spinBox.value())
                                        else:
                                            num = ''
                                        newNoEx = prefix+foName+nnn+suffix+num
                                        newName = newNoEx+fExt
                                        allnew+=newName+'\n'
                                        fulN = os.path.join(root, file)
                                        OLDNAME.append(fulN)
                                        NEWNAME.append(os.path.join(root, newName))
                                        self.ui.progressBar_2.setValue(self.PPf)
                                        val = self.PPf/PC
                                        self.ui.percent_lbl_2.setText(str(int(val*100))+'%')
                else:
                    if self.ui.folderName_chk.checkState() == 2:
                        if pp[-1] == '\\':
                            pp = pp[0:-1]   #剔除最后一个斜杠，避免最后文件夹分割出空符
                        foN = pp.split('\\')
                        foName = foN[len(foN)-1]+sep
                    else:
                        foName = ''
                    for f in os.listdir(pp):
                        if not os.path.isdir(f):
                            for e in ext:
                                if f.endswith(e.upper()) or f.endswith(e.lower()):
                                    fName, fExt = os.path.splitext(f)
                                    if fName.find(self.ui.lineEdit_filter.text()) >= 0:
                                        if nName == '':
                                            nnn = fName
                                        else:
                                            nnn = nName
                                        self.PPf += 1
                                        if self.ui.spinBox.value() > 0:
                                            num = sep+str(self.PPf).zfill(self.ui.spinBox.value())
                                        else:
                                            num = ''
                                        newNoEx = prefix+foName+nnn+suffix+num
                                        newName = newNoEx+fExt
                                        allnew+=newName+'\n'
                                        fulN = os.path.join(pp, f)
                                        OLDNAME.append(fulN)
                                        NEWNAME.append(os.path.join(pp,newName))
                                        self.ui.progressBar_2.setValue(self.PPf)
                                        val = self.PPf/PC
                                        self.ui.percent_lbl_2.setText(str(int(val*100))+'%')

                if self.PPf > 0:
                    newName += '\n共{}个文件，是否确定如上示例重命名?'.format(self.PPf)
                    self.ui.lbl_output.setText(newName)
                    self.ui.textEdit.show()
                    self.ui.textEdit.setText(allnew)
                    self.ui.comp_Yes.show()
                    self.ui.comp_No.show()
            else:
                self.ui.lbl_output.setText('没有可处理的文件！')
        else:
            self.ui.lbl_output.setText('您输入的路径不纯真！')
