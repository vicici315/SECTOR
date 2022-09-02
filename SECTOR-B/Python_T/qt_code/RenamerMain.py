import sys,os
from configparser import ConfigParser

from PyQt5.QtGui import QColor, QMouseEvent, QFont, QIcon, QPixmap
from PyQt5.QtWidgets import QApplication, QMainWindow, QGraphicsDropShadowEffect, QToolTip
from PyQt5.QtCore import QPoint, Qt
from tui import Ui_MainWindow    #这里导入通过PyUIC转换完的.py文件名，获取里面的类
import RenameMultiFiles as RM
import resource
setPath = os.getcwd()+'\\setting.ini'
DELnewname = []
DELoldname = []
DELFBname = []
conf = ConfigParser()
ver = '1.1'
# setting文件未创建时创建并预先初始创建Section区
if not os.path.exists(setPath):
    conf.add_section('TAB1')
    conf.add_section('TAB2')
    conf.add_section('PATH1')
    conf.add_section('PATH2')
    conf.write(open(setPath, 'w', encoding="utf-8"))

class MyWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        # QMainWindow.__init__(self)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.ui.title.setText('<html><head/><body><p><span style=" font-weight:600; color:#aaaaff;">VICICI Tools </span><span style=" color:#7d080e;">'+ver+'</span></p></body></html>')
# 程序图标======================================
        icon = QIcon()
        icon.addPixmap(QPixmap(":/B_exit1_h.png"))
        self.setWindowIcon(icon)
# ui初始状态==================================
        self.ui.progressBar_2.setMinimum(0)
        self.ui.progressBar_2.setValue(0)
        self.ui.progressBar_2.hide()
        self.ui.percent_lbl_2.hide()
        self.ui.comp_No.hide()
        self.ui.comp_Yes.hide()
        self.ui.comp_No_2.hide()
        self.ui.comp_Yes_2.hide()
        self.ui.comp_No_3.hide()
        self.ui.comp_Yes_3.hide()
        self.ui.textEdit.hide()
#===============Set Icon===============
        self.ui.pushButton_3.setIcon(QIcon(':/default.png'))
        self.ui.textEdit_btn.setIcon(QIcon(':/textBtn.png'))
        self.ui.copy_reset_btn.setIcon(QIcon(':/default.png'))
        self.ui.pushButton.setIcon(QIcon(':/B_exit1.png'))
        self.ui.pushButton.setStyleSheet("QPushButton{ background-color: rgba(255, 255, 255, 0);}\n"
"QPushButton:hover{icon:url(:/B_exit1_h.png);}")
        self.ui.comp_Yes.setIcon(QIcon(':/compYes.png'))
        self.ui.comp_No.setIcon(QIcon(':/compNo.png'))
        self.ui.comp_Yes_2.setIcon(QIcon(':/compYes.png'))
        self.ui.comp_No_2.setIcon(QIcon(':/compNo.png'))
        self.ui.comp_Yes_3.setIcon(QIcon(':/compYes.png'))
        self.ui.comp_No_3.setIcon(QIcon(':/compNo.png'))
        self.ui.pushButton_2.setIcon(QIcon(':/start_zi.png'))
        self.ui.pushButton_2.setStyleSheet("QPushButton{background-color:rgba(0,0,0,0);}\n"
                                        "QPushButton:hover{icon:url(:/start_zi_h.png);}")
        self.ui.folderName_chk.setIcon(QIcon(':/folderName.png'))
        self.ui.top_chk.setIcon(QIcon(':/topwin.png'))
        self.ui.subDir_chk.setIcon(QIcon(':/subFolder.png'))
        self.ui.pushButton_4.setIcon(QIcon(':/B_ver.png'))
#=============窗口拖动======================
        self._startPos = None
        self._endPos = None
        self._tracking = False
#------------------------------------------
        # self.resize(550, 860)
        self.ui.separator_cb.addItems(['-','_','>','<','+','●','★','◎','※','→'])
        ## Remove standard title bar
        self.setWindowFlag(Qt.FramelessWindowHint)   # Remove title bar
        self.setAttribute(Qt.WA_TranslucentBackground)   # Set background to transparent

        ## Apply drop shadow effect
        self.shadow = QGraphicsDropShadowEffect(self)
        self.shadow.setBlurRadius(20)
        self.shadow.setXOffset(2)
        self.shadow.setYOffset(3)
        self.shadow.setColor(QColor(0, 20, 40, 250))
        self.ui.frame.setGraphicsEffect(self.shadow)
        self.shadow1 = QGraphicsDropShadowEffect(self)
        self.shadow1.setBlurRadius(20)
        self.shadow1.setXOffset(2)
        self.shadow1.setYOffset(3)
        self.shadow1.setColor(QColor(0, 20, 40, 250))
        self.ui.textEdit.setGraphicsEffect(self.shadow1)

        QToolTip.setFont(QFont('Monaco',9))
        ## 初始值读取
        try:
            conf.read_file(open(setPath,encoding='utf-8'))
        except:
            self.ui.lbl_err.setText('setting.ini 文件有错，打开修正')
            os.system('explorer.exe "setting.ini"')

        try:
            p1 = int(conf.get('TAB1','pathhistroy'))
        except:
            haveS = False
            for s in conf.sections():
                if s == 'TAB1':
                    haveS = True
                    break
            if not haveS:
                conf.add_section('TAB1')
            conf.set('TAB1','pathhistroy','0')
            p1 = 0
        if p1 > 0:
            for i in range(p1):
                self.ui.pathhist1_cb.addItem(conf.get('PATH1',str(i)))
            self.ui.pathhist1_cb.setMinimumSize(290,20)
        try:
            p2 = int(conf.get('TAB2','pathhistroy'))
        except:
            haveS = False
            for s in conf.sections():
                if s == 'TAB2':
                    haveS = True
                    break
            if not haveS:
                conf.add_section('TAB2')
            conf.set('TAB2','pathhistroy','0')
            p2 = 0
        if p2 > 0:
            for i in range(p2):
                self.ui.pathhist2_cb.addItem(conf.get('PATH2',str(i)))
            self.ui.pathhist2_cb.setMinimumSize(290,20)
        try:
            self.ui.tabWidget.setCurrentIndex(int(conf.get('TAB1', 'tab')))
        except:
            print('Not TAB1 TAB set.')
        try:
            self.ui.subDir_chk.setCheckState(int(conf.get('TAB1','subdir')))
        except:
            print('Not TAB1 subdir set.')
        try:
            folderNchk = int(conf.get('TAB1','folder_name'))
            self.ui.folderName_chk.setCheckState(folderNchk)
            if folderNchk == 0:
                self.ui.floderN_lbl.hide()
        except:
            print('Not TAB1 folder_name set.')
        try:
            self.ui.lineEdit_ext.setText(conf.get('TAB1','ext'))
        except:
            print('Not TAB1 ext set.')
        try:
            self.ui.separator_cb.setCurrentIndex(int(conf.get('TAB1','separator')))
        except:
            print('Not TAB1 separator set.')
        try:
            self.ui.sep_le.setText(conf.get('TAB1','separator_le'))
        except:
            print('Not TAB1 separator set.')
        try:
            self.ui.prefix_le.setText(conf.get('TAB1','prefix'))
        except:
            print('Not TAB1 prefix set.')
        try:
            self.ui.suffix_le.setText(conf.get('TAB1','suffix'))
        except:
            print('Not TAB1 suffix set.')
        try:
            self.ui.newName_le.setText(conf.get('TAB1','newname'))
        except:
            print('Not TAB1 newname set.')
        try:
            self.ui.spinBox.setValue(int(conf.get('TAB1','numbit')))
        except:
            print('Not TAB1 numbit set.')
        try:
            self.ui.copy_parentName_chk.setCheckState(int(conf.get('TAB2','copy_parentDir')))
        except:
            print('Not TAB2 copy_parentDir set.')
        try:
            self.ui.copy_extName_chk.setCheckState(int(conf.get('TAB2','copy_Ext')))
        except:
            print('Not TAB2 copy_Ext set.')
        try:
            self.ui.copy_size_chk.setCheckState(int(conf.get('TAB2','copy_size')))
        except:
            print('Not TAB2 copy_size set.')
        try:
            self.ui.copy_prefix_le.setText(conf.get('TAB2','prefix'))
        except:
            print('Not TAB2 copy_prefix set.')
        try:
            self.ui.copy_suffix_le.setText(conf.get('TAB2','suffix'))
        except:
            print('Not TAB2 copy_suffix set.')
        try:
            self.ui.copy_filter_le.setText(conf.get('TAB2','filter'))
        except:
            print('Not TAB2 filter set.')
        try:
            self.ui.copy_ext_le.setText(conf.get('TAB2','ext'))
        except:
            print('Not TAB2 ext set.')
        try:
            self.ui.pathhist1_cb.setCurrentIndex(int(conf.get('TAB1','pathsel')))
            self.ui.lineEdit.setText(self.ui.pathhist1_cb.currentText())
        except:
            print('Not TAB1 pathselect set.')
        try:
            self.ui.pathhist2_cb.setCurrentIndex(int(conf.get('TAB2','pathsel')))
            self.ui.lineEdit_2.setText(self.ui.pathhist2_cb.currentText())
        except:
            print('Not TAB2 pathselect set.')

        if self.ui.lineEdit_ext.text() == 'mp3' or self.ui.lineEdit_ext.text() == 'MP3':
            self.ui.mp3info_chk.show()
        else:
            self.ui.mp3info_chk.hide()

        self.initUI()
        self.exampName()
        self.tabChangeBG(self.ui.tabWidget.currentIndex())

    def initUI(self):
        # 在启动时执行=============
        ## 控件事件链接
        self.ui.pushButton.clicked.connect(self.exitWin)
        self.ui.tabWidget.currentChanged['int'].connect(self.tabChangeBG)
        self.ui.lineEdit.returnPressed.connect(self.savePath)
        self.ui.lineEdit_2.returnPressed.connect(self.savePath2)
        self.ui.lineEdit_ext.textChanged.connect(self.saveExt)
        self.ui.subDir_chk.stateChanged.connect(self.subDirChk)
        self.ui.folderName_chk.stateChanged.connect(self.folderN)
        self.ui.top_chk.stateChanged.connect(self.topWin)
        self.ui.pushButton_2.clicked.connect(self.Rename)
        self.ui.comp_Yes.clicked.connect(self.RenameYes)
        self.ui.comp_No.clicked.connect(self.RenameNo)
        self.ui.separator_cb.currentIndexChanged.connect(self.sepCB)
        self.ui.sep_le.textChanged.connect(self.sepLE)
        self.ui.spinBox.valueChanged.connect(self.numbitS_Fn)
        self.ui.prefix_le.textChanged.connect(self.prefixS_Fn)
        self.ui.suffix_le.textChanged.connect(self.suffixS_Fn)
        self.ui.newName_le.textChanged.connect(self.newnameS_Fn)
        self.ui.picExt_btn.clicked.connect(self.picExp_FN)
        self.ui.ExtWold_btn.clicked.connect(self.waldExp_FN)
        self.ui.ExtMp3_btn.clicked.connect(self.copyMp3Exp_FN)
        self.ui.deltext_btn.clicked.connect(self.delName)
        self.ui.delFB_btn.clicked.connect(self.delFnameB)
        self.ui.comp_Yes_2.clicked.connect(self.go_delName)
        self.ui.comp_Yes_3.clicked.connect(self.go_delFnameB)
        self.ui.comp_No_2.clicked.connect(self.nobtn_2)
        self.ui.comp_No_3.clicked.connect(self.nobtn_3)
        self.ui.pushButton_3.clicked.connect(self.defaultSet)
        self.ui.copy_parentName_chk.stateChanged.connect(self.copyParentFolder)
        self.ui.copy_extName_chk.stateChanged.connect(self.copyExt)
        self.ui.copy_size_chk.stateChanged.connect(self.copySize)
        self.ui.copy_prefix_le.textChanged.connect(self.copyPrefix)
        self.ui.copy_suffix_le.textChanged.connect(self.copySuffix)
        self.ui.copy_ext_le.textChanged.connect(self.copyExtLe)
        self.ui.copy_filter_le.textChanged.connect(self.copyFilter)
        self.ui.copy_reset_btn.clicked.connect(self.copyReset)
        self.ui.copy_ExtMp3_btn.clicked.connect(self.copyMp3Exp_FN)
        self.ui.copy_ExtWold_btn.clicked.connect(self.waldExp_FN)
        self.ui.copy_ExtPic_btn.clicked.connect(self.picExp_FN)
        self.ui.textEdit_btn.clicked.connect(self.showHideTextWin)
        self.ui.pathhist1_cb.currentIndexChanged.connect(self.path1CB)
        self.ui.pathhist2_cb.currentIndexChanged.connect(self.path2CB)
        self.ui.pushButton_4.clicked.connect(self.showVerstion)

    def showVerstion(self):
        self.ui.textEdit.setText('	<VICICITools '+ver+'>\n'
'\nV1.1\n'
'bug修复：批量命名：前后剔除：出现剔除后命名重名的Bug，跳过重名收集数量。\n'
'批量命名：添加批量重命名文本窗预览显示。\n'
'bug修复：复制文件名：包含过滤：出现空文件夹打印。\n'
'功能添加：工具启动后自动设置上次使用面板。\n'
'ViciciTools：添加文本框按钮，在复制文件名后可以显示复制内容或进行编辑；添加路径历史记录保存，优化路径读取。\n'
'\nV1.0\n'
'批量命名：制定命名规则对文件夹内包含子目录的所有文件批量重命名，支持文件格式过滤、关键字过滤、剔除关键字等功能。\n'
'复制文件名：收集文件夹中所有文件，可以根据规则或去除扩展名等。')
        self.ui.textEdit.show()
    def showHideTextWin(self):
        if self.ui.textEdit.isHidden():
            self.ui.textEdit.show()
        else:
            self.ui.textEdit.hide()
    def copyReset(self):
        self.ui.copy_suffix_le.setText('')
        self.ui.copy_prefix_le.setText('')
        self.ui.copy_filter_le.setText('')
        self.exampCopy()
    def copyExtLe(self):
        conf.read_file(open(setPath, encoding='utf-8'))
        conf.set('TAB2', 'ext', self.ui.copy_ext_le.text())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('文件类型过滤：\n'+self.ui.copy_ext_le.text())
    def copyFilter(self):
        conf.read_file(open(setPath, encoding='utf-8'))
        conf.set('TAB2', 'filter', self.ui.copy_filter_le.text())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('关键字过滤：\n'+self.ui.copy_filter_le.text())
    def copySuffix(self):
        conf.read_file(open(setPath, encoding='utf-8'))
        conf.set('TAB2', 'suffix', self.ui.copy_suffix_le.text())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('前缀：\n'+self.ui.copy_suffix_le.text())
        self.exampCopy()
    def copyPrefix(self):
        conf.read_file(open(setPath, encoding='utf-8'))
        conf.set('TAB2', 'prefix', self.ui.copy_prefix_le.text())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('前缀：\n'+self.ui.copy_prefix_le.text())
        self.exampCopy()
    def copyParentFolder(self,state):
        conf.read_file(open(setPath,encoding='utf-8'))
        if state == 0:
            conf.set('TAB2', 'copy_parentDir', '0')
            y='False'
        else:
            conf.set('TAB2', 'copy_parentDir', '2')
            y='True'
        self.ui.lbl_err.setText('')
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('打印父路径：\n'+y)
    def copyExt(self,state):
        conf.read_file(open(setPath,encoding='utf-8'))
        if state == 0:
            conf.set('TAB2', 'copy_Ext', '0')
            y='False'
        else:
            conf.set('TAB2', 'copy_Ext', '2')
            y='True'
        self.ui.lbl_err.setText('')
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('打印扩展名：\n'+y)
        self.exampCopy()
    def copySize(self,state):
        conf.read_file(open(setPath,encoding='utf-8'))
        if state == 0:
            conf.set('TAB2', 'copy_size', '0')
            y='False'
        else:
            conf.set('TAB2', 'copy_size', '2')
            y='True'
        self.ui.lbl_err.setText('')
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lbl_output.setText('打印文件大小：\n'+y)
        self.exampCopy()

#==========窗口拖动==============================================
    def mouseMoveEvent(self, e: QMouseEvent):  # 重写移动事件
        if self._tracking:
            self._endPos = e.pos() - self._startPos
            self.move(self.pos() + self._endPos)

    def mousePressEvent(self, e: QMouseEvent):
        if e.button() == Qt.LeftButton or e.button() == Qt.RightButton:
            self._startPos = QPoint(e.x(), e.y())
            self._tracking = True

    def mouseReleaseEvent(self, e: QMouseEvent):
        if e.button() == Qt.LeftButton:
            self._tracking = False
            self._startPos = None
            self._endPos = None
            self.ui.progressBar_2.hide()
            self.ui.percent_lbl_2.hide()
#---------------------------------------------------------------
    def getFileNum(self, mod):
        if mod > 0:
            pp = self.ui.lineEdit.text()
            ext = (self.ui.lineEdit_ext.text()).split(';')  # 注意后缀名区分大小写
        else:
            pp = self.ui.lineEdit_2.text()
            ext = (self.ui.copy_ext_le.text()).split(';')
        if os.path.exists(pp):
            PPC = 0
            if self.ui.subDir_chk.checkState() == 2:
                for root, dirs, files in os.walk(pp):   #这里的dirs是空的
                    for file in files:  #file文件名带后缀名
                        for e in ext:
                            if file.endswith(e.upper()) or file.endswith(e.lower()):
                                fiNa,ex = os.path.splitext(file)
                                if mod > 0:
                                    if fiNa.find(self.ui.lineEdit_filter.text()) >= 0:
                                        if mod == 3:
                                            if self.ui.delF_spn.value() > 0 or self.ui.delB_spn.value() > 0:    # 前后剔除需至少设置一个字符
                                                PPC += 1
                                        if mod == 2:
                                            if self.ui.deltext_le.text() != '' and fiNa.find(self.ui.deltext_le.text()) >= 0:
                                                PPC += 1
                                        if mod == 1:
                                            PPC += 1
                                else:
                                    if fiNa.find(self.ui.copy_filter_le.text()) >= 0:
                                        PPC += 1
            else:
                for f in os.listdir(pp):
                    if not os.path.isdir(f):
                        for e in ext:
                            if f.endswith(e.upper()) or f.endswith(e.lower()):
                                fiNa,ex = os.path.splitext(f)
                                if mod > 0:
                                    if fiNa.find(self.ui.lineEdit_filter.text()) >= 0:
                                        if mod == 3:
                                            if self.ui.delF_spn.value() > 0 or self.ui.delB_spn.value() > 0:
                                                PPC += 1
                                        if mod == 2:
                                            if self.ui.deltext_le.text() != '' and fiNa.find(self.ui.deltext_le.text()) >= 0:
                                                PPC += 1
                                        if mod == 1:
                                            PPC += 1
                                else:
                                    if fiNa.find(self.ui.copy_filter_le.text()) >= 0:
                                        PPC += 1
            if PPC > 0:
                newName1 = '正在开始...\n共{}个文件'.format(PPC)
                self.ui.lbl_output.setText(newName1)
            return PPC
        else:
            self.ui.lbl_output.setText('您指定的路径不存在！')

    # cao定义事件槽函数
    def defaultSet(self):
        self.ui.lineEdit_filter.setText('')
        self.ui.newName_le.setText('')
        self.ui.prefix_le.setText('')
        self.ui.suffix_le.setText('')
        self.ui.folderName_chk.setCheckState(0)
        self.ui.spinBox.setValue(0)
    def nobtn_2(self):
        self.ui.comp_Yes_2.hide()
        self.ui.comp_No_2.hide()
    def nobtn_3(self):
        self.ui.comp_Yes_3.hide()
        self.ui.comp_No_3.hide()

    def go_delFnameB(self):
        global DELoldname,DELFBname
        c = 0
        errN = 0
        count = len(DELFBname)
        self.ui.progressBar_2.show()
        self.ui.percent_lbl_2.show()
        for f in DELFBname:
            try:
                os.rename(DELoldname[c],f)
            except:
                errN += 1
            c+=1
            self.ui.progressBar_2.setValue(c)
            val = c / count
            self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
        if errN > 0:
            self.ui.lbl_output.setText('\n共{}个文件重命名完成。{}个文件因重名保持原名'.format(c,errN))
        else:
            self.ui.lbl_output.setText('\n共{}个文件重命名完成'.format(c))
        self.ui.comp_Yes_3.hide()
        self.ui.comp_No_3.hide()
        if self.ui.mp3info_chk.checkState() == 2:
            if self.ui.lineEdit_ext.text()=='mp3' or self.ui.lineEdit_ext.text()=='MP3':
                for f in DELFBname:
                    nn = os.path.basename(f)
                    endN, ext = os.path.splitext(nn)
                    RM.RenameC().mp3InfoEdit(f, endN)
    def delFnameB(self):
        pp = self.ui.lineEdit.text()
        if os.path.exists(pp):
            self.nobtn_2()
            Fcount = self.getFileNum(3)  # 不同命名规则需要按不同规则进行计数
            if Fcount > 0:
                self.ui.progressBar_2.setMaximum(Fcount)
                ext = (self.ui.lineEdit_ext.text()).split(';')  # 注意后缀名区分大小写
                c = 0
                self.ui.progressBar_2.show()
                self.ui.percent_lbl_2.show()
                global DELoldname, DELFBname
                DELoldname = []
                DELFBname = []
                allnew = ''
                if self.ui.subDir_chk.checkState() == 2:
                    for root, dirs, files in os.walk(pp):
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
                        for file in files:
                            for e in ext:
                                if file.endswith(e.upper()) or file.endswith(e.lower()):
                                    fiNa,ex = os.path.splitext(file)
                                    if fiNa.find(self.ui.lineEdit_filter.text()) >= 0:
                                        fName, fExt = os.path.splitext(file)
                                        if self.ui.delF_spn.value() > 0 or self.ui.delB_spn.value() > 0:
                                            DELoldname.append(os.path.join(root, file))
                                            if self.ui.delB_spn.value() == 0:
                                                fbDel = fName[self.ui.delF_spn.value():]
                                            else:
                                                fbDel = fName[self.ui.delF_spn.value():-self.ui.delB_spn.value()]
                                            DELFBname.append(os.path.join(root, fbDel) + fExt)
                                            allnew+=fbDel+fExt+'\n'
                                            c += 1
                                            self.ui.progressBar_2.setValue(c)
                                            val = c / Fcount
                                            self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
                else:
                    for f in os.listdir(pp):
                        if not os.path.isdir(f):
                            for e in ext:
                                if f.endswith(e.upper()) or f.endswith(e.lower()):
                                    fiNa,ex = os.path.splitext(f)
                                    if fiNa.find(self.ui.lineEdit_filter.text()) >= 0:
                                        fName, fExt = os.path.splitext(f)
                                        if self.ui.delF_spn.value() > 0 or self.ui.delB_spn.value() > 0:
                                            DELoldname.append(os.path.join(pp, f))
                                            if self.ui.delB_spn.value() == 0:
                                                fbDel = fName[self.ui.delF_spn.value():]
                                            else:
                                                fbDel = fName[self.ui.delF_spn.value():-self.ui.delB_spn.value()]
                                            DELFBname.append(os.path.join(pp, fbDel) + fExt)
                                            allnew+=fbDel+fExt+'\n'
                                            c += 1
                                            self.ui.progressBar_2.setValue(c)
                                            val = c / Fcount
                                            self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
                if c > 0:
                    self.ui.lbl_output.setText(fbDel+'\n共{}个文件，是否如上重命名？'.format(c))
                    self.ui.comp_Yes_3.show()
                    self.ui.comp_No_3.show()
                    self.ui.textEdit.show()
                    self.ui.textEdit.setText(allnew)
                else:
                    self.ui.lbl_output.setText('\n文件中没有包含要删除的字符！')
                    self.ui.progressBar_2.hide()
                    self.ui.percent_lbl_2.hide()
            else:
                self.ui.lbl_output.setText('没有文件可处理！')
        else:
            self.ui.lbl_output.setText('您输入的路径不纯真！')
    def go_delName(self):
        global DELoldname,DELnewname
        c = 0
        count = len(DELnewname)
        self.ui.progressBar_2.show()
        self.ui.percent_lbl_2.show()
        for f in DELoldname:
            os.rename(f,DELnewname[c])
            c+=1
            self.ui.progressBar_2.setValue(c)
            val = c / count
            self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
        self.ui.lbl_output.setText('\n共{}个文件，重命名完成。'.format(c))
        self.ui.comp_Yes_2.hide()
        self.ui.comp_No_2.hide()
        if self.ui.mp3info_chk.checkState() == 2:
            if self.ui.lineEdit_ext.text()=='mp3' or self.ui.lineEdit_ext.text()=='MP3':
                for f in DELnewname:
                    nn = os.path.basename(f)
                    endN, ext = os.path.splitext(nn)
                    RM.RenameC().mp3InfoEdit(f, endN)
    def delName(self):
        pp = self.ui.lineEdit.text()
        if os.path.exists(pp):
            self.nobtn_3()
            self.RenameNo()
            Fcount = self.getFileNum(2)
            if Fcount > 0:
                self.ui.progressBar_2.setMaximum(Fcount)
                ext = (self.ui.lineEdit_ext.text()).split(';')    # 注意后缀名区分大小写
                c = 0
                self.ui.progressBar_2.show()
                self.ui.percent_lbl_2.show()
                global DELoldname,DELnewname
                DELoldname = []
                DELnewname = []
                allnew = ''
                if self.ui.subDir_chk.checkState() == 2:
                    for root, dirs, files in os.walk(pp):
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
                        for file in files:
                            for e in ext:
                                if file.endswith(e.upper()) or file.endswith(e.lower()):
                                    fName, fExt = os.path.splitext(file)
                                    if fName.find(self.ui.lineEdit_filter.text()) >= 0:
                                        if self.ui.deltext_le.text() != '' and fName.find(self.ui.deltext_le.text()) >= 0:
                                            DELoldname.append(os.path.join(root, file))
                                            newSpl = fName.split(self.ui.deltext_le.text())
                                            NS = ''
                                            for s in newSpl:
                                                NS += s
                                            DELnewname.append(os.path.join(root, NS)+fExt)
                                            allnew+=NS+fExt+'\n'
                                            c += 1
                                            self.ui.progressBar_2.setValue(c)
                                            val = c / Fcount
                                            self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
                if self.ui.subDir_chk.checkState() == 0:
                    lists = os.listdir(pp)
                    if len(lists) > 0:
                        for f in lists:
                            if not os.path.isdir(f):
                                for e in ext:
                                    if f.endswith(e.upper()) or f.endswith(e.lower()):
                                        fName, fExt = os.path.splitext(f)
                                        if fName.find(self.ui.lineEdit_filter.text()) >= 0:
                                            if self.ui.deltext_le.text() != '' and fName.find(self.ui.deltext_le.text()) >= 0:
                                                DELoldname.append(os.path.join(pp, f))
                                                newSpl = fName.split(self.ui.deltext_le.text())
                                                NS = ''
                                                for s in newSpl:
                                                    NS += s
                                                DELnewname.append(os.path.join(pp, NS)+fExt)
                                                allnew+=NS+fExt+'\n'
                                                c += 1
                                                self.ui.progressBar_2.setValue(c)
                                                val = c / Fcount
                                                self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
                if c > 0:
                    self.ui.lbl_output.setText('\n共{}个文件，是否重命名？'.format(c))
                    self.ui.comp_Yes_2.show()
                    self.ui.comp_No_2.show()
                    self.ui.textEdit.show()
                    self.ui.textEdit.setText(allnew)
                else:
                    self.ui.lbl_output.setText('\n文件中没有包含要删除的字符！')
                    self.ui.progressBar_2.hide()
                    self.ui.percent_lbl_2.hide()
            else:
                self.ui.lbl_output.setText('没有可处理的文件！')
        else:
            self.ui.lbl_output.setText('您输入的路径不纯真！')

    def exampCopy(self):
        pre=self.ui.copy_prefix_le.text()
        suf=self.ui.copy_suffix_le.text()
        if self.ui.copy_extName_chk.checkState() == 2:
            eN = '.ext'
        else:
            eN = ''
        if self.ui.copy_size_chk.checkState() == 2:
            size = ' 77.16M'
        else:
            size = ''
        self.ui.copy_Example_le.setText(pre+'原名'+eN+suf+size)

    def exampName(self):    # 新名规则预览
        sep = self.ui.sep_le.text()
        if self.ui.prefix_le.text() == '':
            prefix = ''
        else:
            prefix = self.ui.prefix_le.text()+sep
        if self.ui.suffix_le.text() == '':
            suffix = ''
        else:
            suffix = sep+self.ui.suffix_le.text()
        nName = self.ui.newName_le.text()
        if self.ui.folderName_chk.checkState() == 2:
            pp = self.ui.lineEdit.text()
            if pp != '':
                if pp[-1] == '\\':
                    pp = pp[0:-1]   #剔除最后一个斜杠，避免最后文件夹分割出空符
                foN = pp.split('\\')
                foName = foN[len(foN)-1]+sep
            else:
                foName = '未指定目录'+sep
        else:
            foName = ''
        if nName == '':
            nnn = '原名'
        else:
            nnn = nName
        if self.ui.spinBox.value() > 0:
            num = sep+'1'.zfill(self.ui.spinBox.value())
        else:
            num = ''
        newName = prefix + foName + nnn + suffix + num + '.ext'
        self.ui.finalNameSample.setText(newName)
    def waldExp_FN(self):
        if self.ui.tabWidget.currentIndex() == 0:
            self.ui.lineEdit_ext.setText('pdf;doc;docx;ppt;pptx;xls;xlsx')
        if self.ui.tabWidget.currentIndex() == 1:
            self.ui.copy_ext_le.setText('pdf;doc;docx;ppt;pptx;xls;xlsx')
    def picExp_FN(self):
        if self.ui.tabWidget.currentIndex() == 0:
            self.ui.lineEdit_ext.setText('jpg;tga;png;bmp;dds;tif;jpeg;gif')
        if self.ui.tabWidget.currentIndex() == 1:
            self.ui.copy_ext_le.setText('jpg;tga;png;bmp;dds;tif;jpeg;gif')
    def copyMp3Exp_FN(self):
        if self.ui.tabWidget.currentIndex() == 0:
            self.ui.lineEdit_ext.setText('mp3')
        if self.ui.tabWidget.currentIndex() == 1:
            self.ui.copy_ext_le.setText('mp3')
    def Rename(self):
        self.nobtn_2()
        if self.ui.tabWidget.currentIndex() == 0:
            RM.RenameC.SubFloder(self, self.getFileNum(1))
        if self.ui.tabWidget.currentIndex() == 1:
            RM.RenameC.CopyFilename(self,self.getFileNum(0))
    def RenameNo(self):
        self.ui.comp_No.hide()
        self.ui.comp_Yes.hide()
    def RenameYes(self):
        c = 0
        for f in RM.NEWNAME:
            os.rename(RM.OLDNAME[c], f)
            c += 1
            self.ui.progressBar_2.setValue(c)
            val = c / RM.FileNum
            self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')
        self.ui.lbl_output.setText('\n共{}个文件，重命名完成。'.format(c))
        self.ui.comp_No.hide()
        self.ui.comp_Yes.hide()
        if self.ui.mp3info_chk.checkState() == 2:
            if self.ui.lineEdit_ext.text()=='mp3' or self.ui.lineEdit_ext.text()=='MP3':
                for f in RM.NEWNAME:
                    nn = os.path.basename(f)
                    endN, ext = os.path.splitext(nn)
                    RM.RenameC().mp3InfoEdit(f, endN)
                    c += 1
                    self.ui.progressBar_2.setValue(c)
                    val = c / RM.FileNum
                    self.ui.percent_lbl_2.setText(str(int(val * 100)) + '%')

    def folderN(self,state):
        self.exampName()
        try:
            conf.read_file(open(setPath,encoding='utf-8'))
            if state == 0:
                self.ui.floderN_lbl.hide()
                conf.set('TAB1', 'folder_name', '0')
                y = 'False'
            else:
                self.ui.floderN_lbl.show()
                conf.set('TAB1', 'folder_name', '2')
                y = 'True'
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('是否应该父目录名：\n'+y)
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def numbitS_Fn(self):
        self.exampName()
        try:
            conf.read_file(open(setPath, encoding='utf-8'))
            conf.set('TAB1', 'numbit', str(self.ui.spinBox.value()))
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('编号位数：\n'+str(self.ui.spinBox.value()))
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def sepLE(self):
        self.exampName()
        try:
            conf.read_file(open(setPath, encoding='utf-8'))
            conf.set('TAB1', 'separator_le', self.ui.sep_le.text())
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('分隔符：\n'+self.ui.sep_le.text())
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def sepCB(self,i):
        self.ui.separator_cb.setCurrentText(self.ui.separator_cb.itemText(i))
        self.ui.sep_le.setText(self.ui.separator_cb.currentText())
        self.exampName()
        try:
            conf.read_file(open(setPath,encoding='utf-8'))
            conf.set('TAB1','separator',str(self.ui.separator_cb.currentIndex()))
            conf.set('TAB1','separator_le',self.ui.separator_cb.currentText())
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def prefixS_Fn(self):
        self.exampName()
        try:
            conf.read_file(open(setPath, encoding='utf-8'))
            conf.set('TAB1', 'prefix', self.ui.prefix_le.text())
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('文件名前缀：\n'+self.ui.prefix_le.text())
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def suffixS_Fn(self):
        self.exampName()
        try:
            conf.read_file(open(setPath, encoding='utf-8'))
            conf.set('TAB1', 'suffix', self.ui.suffix_le.text())
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('文件名后缀：\n'+self.ui.suffix_le.text())
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def newnameS_Fn(self):
        self.exampName()
        try:
            conf.read_file(open(setPath, encoding='utf-8'))
            conf.set('TAB1', 'newname', self.ui.newName_le.text())
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            if self.ui.newName_le.text() != '':
                self.ui.lbl_output.setText('使用新名：\n'+self.ui.newName_le.text())
            else:
                self.ui.lbl_output.setText('')
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def saveExt(self):
        if self.ui.lineEdit_ext.text() == 'mp3' or self.ui.lineEdit_ext.text() == 'MP3':
            self.ui.mp3info_chk.show()
        else:
            self.ui.mp3info_chk.hide()
        try:
            conf.read_file(open(setPath, encoding='utf-8'))
            conf.set('TAB1', 'ext', self.ui.lineEdit_ext.text())
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('搜索扩展名：\n'+self.ui.lineEdit_ext.text())
            self.ui.lbl_err.setText('')
        except:
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def savePath(self):
        try:
            conf.read_file(open(setPath,encoding='utf-8'))
            text = self.ui.lineEdit.text()
            self.ui.lbl_err.setText('')
            self.ui.lbl_output.setText('重命名搜索路径：\n' + text)
            p1 = int(conf.get('TAB1', 'pathhistroy'))
            same = True
            if p1 > 0:  #数目大于0时添加不同项目
                for i in range(p1):
                    get = conf.get('PATH1', str(i))
                    if text == get:
                        same = False
                if same:
                    conf.set('PATH1', str(p1), text)
                    conf.set('TAB1', 'pathhistroy', str(p1+1))
                    conf.write(open(setPath, 'w+', encoding="utf-8"))
                    self.ui.pathhist1_cb.addItem(text)
            else:   #数目为0个时写入第一个记录
                conf.set('TAB1', 'pathhistroy', '1')
                conf.set('PATH1', '0', text)
                self.ui.pathhist1_cb.addItem(text)
                conf.write(open(setPath, 'w+', encoding="utf-8"))
        except:
            haveS = False
            for s in conf.sections():
                if s == 'PATH1':
                    haveS = True
                    break
            if not haveS:
                conf.add_section('PATH1')
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def path1CB(self,i):
        conf.set('TAB1','pathsel',str(i))
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lineEdit.setText(self.ui.pathhist1_cb.itemText(i))
    def path2CB(self,i):
        conf.set('TAB2','pathsel',str(i))
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ui.lineEdit_2.setText(self.ui.pathhist2_cb.itemText(i))
    def savePath2(self):
        try:
            conf.read_file(open(setPath,encoding='utf-8'))
            text = self.ui.lineEdit_2.text()
            self.ui.lbl_output.setText('搜索路径：\n'+text)
            self.ui.lbl_err.setText('')
            p1 = int(conf.get('TAB2', 'pathhistroy'))
            same = True
            if p1 > 0:  #数目大于0时添加不同项目
                for i in range(p1):
                    get = conf.get('PATH2', str(i))
                    if text == get:
                        same = False
                if same:
                    conf.set('PATH2', str(p1), text)
                    conf.set('TAB2', 'pathhistroy', str(p1+1))
                    conf.write(open(setPath, 'w+', encoding="utf-8"))
                    self.ui.pathhist2_cb.addItem(text)
            else:   #数目为0个时写入第一个记录
                conf.set('TAB2', 'pathhistroy', '1')
                conf.set('PATH2', '0', text)
                self.ui.pathhist2_cb.addItem(text)
                conf.write(open(setPath, 'w+', encoding="utf-8"))
        except:
            haveS = False
            for s in conf.sections():
                if s == 'PATH2':
                    haveS = True
                    break
            if not haveS:
                conf.add_section('PATH2')
            self.ui.lbl_err.setText('<UI记录写入错误>')
    def subDirChk(self, state):
        self.exampName()
        if os.path.exists(setPath):
            conf.read_file(open(setPath,encoding='utf-8'))
            if state == 0:
                conf.set('TAB1', 'subdir', '0')
                y='False'
            else:
                conf.set('TAB1', 'subdir', '2')
                y='True'
            self.ui.lbl_err.setText('')
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.ui.lbl_output.setText('是否搜索子目录：\n'+y)
        else:
            self.ui.lbl_err.setText('<UI记录写入错误>')

    def topWin(self, state):
        if state == Qt.Checked:
            self.setWindowFlags(Qt.FramelessWindowHint | Qt.WA_TranslucentBackground | Qt.WindowStaysOnTopHint)
        else:
            self.setWindowFlags(Qt.Widget | Qt.FramelessWindowHint | Qt.WA_TranslucentBackground)
        self.show()

    def tabChangeBG(self,index):
        conf.read_file(open(setPath,encoding='utf-8'))
        conf.set('TAB1','tab',str(index))
        if (index == 0):
            self.ui.lbl_output.setText('功能说明：\n对指定类型文件进行规则批量重命名，对mp3可以更新其标题。')
            self.ui.frame.setStyleSheet("QFrame{\n"
"    border-radius:28px;\n"
"    background-color: qlineargradient(spread:pad, x1:0, y1:0, x2:0, y2:1, stop:0.85 rgb(87, 85, 147), stop:0.852 rgb(48, 39, 78));\n"
"}")
        elif (index == 1):
            self.ui.lbl_output.setText('功能说明：\n根据规则获取指定类型文件名列表，并复制到剪贴板。')
            self.exampCopy()
            self.ui.frame.setStyleSheet("QFrame{\n"
"    border-radius:28px;\n"
"    background-color: qlineargradient(spread:pad, x1:0, y1:0, x2:0, y2:1, stop:0.85 rgb(67, 95, 127), stop:0.852 rgb(25, 51, 73));\n"
"}")
        elif (index == 2):
            self.ui.lbl_output.setText('未开发的功能区，有何实用建议都可以找Vic述说')
            self.ui.frame.setStyleSheet("QFrame{\n"
"    border-radius:28px;\n"
"    background-color: qlineargradient(spread:pad, x1:0, y1:0, x2:0, y2:1, stop:0.85 rgb(202, 100, 97), stop:0.852 rgb(0, 34, 40));\n"
"}")
        conf.write(open(setPath, 'w+', encoding="utf-8"))
    def exitWin(self):
        sys.exit(app.exec_())


if __name__ == '__main__':
    app = QApplication(sys.argv)
    myWin = MyWindow()
    myWin.show()
    sys.exit(app.exec_())
