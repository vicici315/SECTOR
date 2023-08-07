# 将图标转成二进制代码

# import threading
import icondata
# from PIL import Image, ImageTk
# import tkinter as tk
# from tkinter import scrolledtext
# from tkinter import ttk
import redis
import os
from configparser import ConfigParser
import base64
import wx
import wx.grid
# import subprocess

conf = ConfigParser()
setPath = os.getcwd()+'\\PrinterSetting.ini'
pcount = 0
if os.path.exists(setPath):
    conf.read_file(open(setPath, encoding='utf-8'))
if not conf.has_section('set_DS'):
    conf.add_section('set_DS')
if not conf.has_section('set_DS_t'):
    conf.add_section('set_DS_t')
if not conf.has_section('PATH_DS'):
    conf.add_section('PATH_DS')
if not conf.has_section('search_text'):
    conf.add_section('search_text')

try:
    pcount=int(conf.get('set_DS','path_count'))
except:
    conf.set('set_DS', 'path_count','0')
conf.write(open(setPath, 'w+', encoding="utf-8"))




class MyFrame(wx.Frame):



    def __init__(self, parent, title):
        super(MyFrame, self).__init__(parent, title=title, size=(1000, 900))
        # 加载图标文件并创建 wx.Icon 对象
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_ds']))
        icon = wx.Icon(temp_icon_file, wx.BITMAP_TYPE_ICO)
        # 设置窗口的标题栏图标
        self.SetIcon(icon)
#控件主面板
        panel = wx.Panel(self)
#平行布局：h_sizer（用于放置顶部的按钮与下拉列表）
        h_sizer = wx.BoxSizer(wx.HORIZONTAL)
#主布局：sizer
        sizer = wx.BoxSizer(wx.VERTICAL)
#ComboBox可输入下拉列表：combox
        pco=0
        try:
            pco = int(conf.get('set_DS', 'path_count'))
        except: pass
        current_values = []
        if pco > 0:
            for i in range(pco):
                if conf.has_option('PATH_DS', str(i)):
                    pp = conf.get('PATH_DS', str(i))
                    if os.path.exists(pp):
                        current_values.append(pp)
        self.combox = wx.ComboBox(panel, wx.ID_ANY, choices=current_values) # size=设置宽度 -1为默认高度
        self.combox.Bind(wx.EVT_COMBOBOX, self.on_comb_return)
        self.combox.Bind(wx.EVT_COMBOBOX_DROPDOWN, self.on_comb_return) #这里使用打开下拉列表事件替代文本修改，避免函数死循环
        try:
            self.combox.SetValue(conf.get('PATH_DS','current'))
        except:
            self.combox.SetValue(os.getcwd())
        h_sizer.Add(self.combox, proportion=2, flag=wx.EXPAND|wx.ALL, border=4)
#ComboBox搜索内容历史列表：combox_S
        pcos=0
        if conf.has_option('set_DS_t', 'path_count'):
            pcos = int(conf.get('set_DS_t', 'path_count'))
        t_currents_values = []
        if pcos > 0:
            for i in range(pcos):
                if conf.has_option('search_text', str(i)):
                    pp = conf.get('search_text', str(i))
                    t_currents_values.append(pp)
        self.combox_S = wx.ComboBox(panel, wx.ID_ANY, choices=t_currents_values) #size设置宽度 -1为默认高度
        self.combox_S.Bind(wx.EVT_COMBOBOX_DROPDOWN, self.on_comb_ds_return)
        try:
            self.combox_S.SetValue(conf.get('search_text','current'))
        except:
            pass
        h_sizer.Add(self.combox_S, proportion=1, flag=wx.EXPAND|wx.ALL, border=4)
#ComboBox修改方式选择：comb_edits
        self.comb_edits = wx.ComboBox(panel, wx.ID_ANY, value='修改', choices=['读取','修改','创建'], style=wx.CB_READONLY)
        h_sizer.Add(self.comb_edits,proportion=1, flag=wx.EXPAND|wx.ALL, border=4)
#ComboBox文件、文件夹：comb_types
        self.comb_types = wx.ComboBox(panel, wx.ID_ANY, value='文件', choices=['文件','文件夹'], style=wx.CB_READONLY)
        h_sizer.Add(self.comb_types,proportion=1, flag=wx.EXPAND|wx.ALL, border=4)

    #布局：平行布局放入主布局最顶部
        sizer.Add(h_sizer, 0, wx.EXPAND|wx.ALL, 1, )  # 里面的参数同上（占比，标签，边界），参数名如果不写需要统一都不写

#Button按钮：button
        # 加载图标文件并创建 wx.Bitmap 对象
        icon = wx.Bitmap(temp_icon_file, wx.BITMAP_TYPE_ICO)    #使用ico类型图标
        os.remove(temp_icon_file)
        # 创建 wx.Button，设置图标和标签
        button = wx.Button(panel, wx.ID_ANY, label="搜索", size=(80, 28))
        button.SetBitmap(icon)
        button.SetToolTip('右键双击清空搜索历史')
        # 绑定按钮事件
        button.Bind(wx.EVT_BUTTON, self.DoConvert)
        button.Bind(wx.EVT_RIGHT_DCLICK, self.DelSTHis)
    #布局：按钮放入顶部平行布局
        h_sizer.Add(button, flag=wx.ALL, border=5)

#ListBox多选列表：list
        self.list = wx.ListBox(panel, style=wx.VSCROLL|wx.LB_EXTENDED)
        sizer.Add(self.list, proportion=1, flag=wx.EXPAND|wx.ALL, border=5)
#TextCtrl文本控件：text_out
        # self.text_out = wx.TextCtrl(panel, style=wx.TE_MULTILINE|wx.VSCROLL|wx.TE_READONLY|wx.TE_DONTWRAP) #wx.TE_MULTILINE|wx.TE_READONLY（多行只读）
        # self.text_out.SetBackgroundColour(wx.Colour(17, 16, 20))
        # self.text_out.SetForegroundColour(wx.Colour(113, 216, 130))

        self.grid_out = wx.grid.Grid(panel)
        self.grid_out.CreateGrid(0,6)
        # self.grid_out.SetRowSize(0,28)  #设置第一行高度
        self.grid_out.SetColLabelValue(0, '操作')
        self.grid_out.SetColLabelValue(1, '修改路径')
        self.grid_out.SetColLabelValue(2, '修改内容')
        self.grid_out.SetColLabelValue(3, '大小')
        self.grid_out.SetColLabelValue(4, '作者')
        self.grid_out.SetColLabelValue(5, 'IP')

        self.grid_out.AutoSizeColumns()
        sizer.Add(self.grid_out, proportion=2, flag=wx.EXPAND|wx.ALL, border=5) #proportion比例为整数，该件比上面占面积大2倍
#Gauge进度条：progress_bar
        self.progress_bar = wx.Gauge(panel, range=100)
        sizer.Add(self.progress_bar, proportion=0, flag=wx.EXPAND|wx.ALL, border=5)

        panel.SetSizer(sizer)
#初始化时调用：
        self.FindTxt()
        self.r = redis.StrictRedis(host='192.168.89.28', port=6379, db=0)   # db=0链接到第一个数据库
#移动主窗口位置
        self.Move(400,200)

    def FindTxt(self):
        path = self.combox.GetValue()
        if os.path.exists(path):
            if path[-1] != '\\': path += '\\'
            self.list.Clear()  # 清空列表，从索引0到末尾的所有项
            with os.scandir(path.strip()) as files:
                for f in files:
                    if not f.is_dir():
                        if f.path.endswith('txt') or f.path.endswith('TXT'):
                            siz = self.Sizeofsize(os.path.getsize(f.path))
                            self.list.Append(f'{f.name} → {siz}')

    def DelSTHis(self,event):
        dbc=self.r.dbsize()
        print(dbc)
        if dbc>0:
            self.grid_out.AppendRows(dbc)
            for i in range(dbc):
                datas = (self.r.get(f'{i}'))
                self.grid_out.SetCellValue(i, 0, datas)
            #     for d in range(len(datas)):
            #         self.grid_out.SetCellValue(i, d, datas[d])
            self.grid_out.AutoSizeColumns()
            self.grid_out.Scroll(dbc, 0)

        dlg = wx.MessageDialog(self, "确定要清空搜索历史吗？", "[清空历史]", wx.YES_NO | wx.ICON_QUESTION)
        result = dlg.ShowModal()
        dlg.Destroy()
        if result == wx.ID_YES:
            if conf.has_option('search_text', 'current'):
                conf.set('search_text', 'current', '')
            if conf.has_option('set_DS_t', 'path_count'):
                conf.set('set_DS_t', 'path_count', '0')
            conf.write(open(setPath, 'w+', encoding="utf-8"))   #设置后记得写入ini文件
            self.combox_S.SetValue('')
            self.combox_S.Clear()

    def Sizeofsize(self,sNum):
        ns = str(sNum) + ' B'
        if int(sNum) > 1024:
            kNum = int(sNum) / 1024
            ns = str(round(kNum, 2)) + ' K'
            if kNum > 1024:
                mNum = kNum / 1024
                ns = str(round(mNum, 2)) + ' M'
        return ns

    def convertB(self,filename):
        with open(filename, 'rb') as file:
            icon_binary = file.read()
        # 将二进制数据进行 Base64 编码
        icon_base64 = base64.b64encode(icon_binary)
        # 将 Base64 编码转换为字符串形式
        return icon_base64.decode('utf-8')

    def DoConvert(self, event):
        dlg = wx.MessageDialog(self, "确定开始搜索自定的路径关键字吗，该操作将会花点时间！", "[搜索]", wx.YES_NO | wx.ICON_QUESTION)
        result = dlg.ShowModal()
        dlg.Destroy()
        if result == wx.ID_YES:
            selected_indices = self.list.GetSelections()
            if selected_indices:
                selected_items = [self.list.GetString(index) for index in selected_indices]
                scount = len(selected_items)
                st = self.combox_S.GetValue()   # 搜索内容
                if scount > 0 and st != '':
                    path = self.combox.GetValue()
                    if path[-1] != '\\': path += '\\'
                    gnum=self.grid_out.GetNumberRows()  # 删除所有行
                    if gnum>0:
                        for i in range(gnum):
                            self.grid_out.DeleteRows(0) # 根据总行数循环删除第一行
                    ssc = 0
                    self.r.flushdb()    #清空数据库
                    for p in selected_items:
                        pp = str(p).split(' → ')
                        fp = path + pp[0]
                        ffc = self.get_line_count(fp)   # 获取文本总行数
                        proc = 0
                        self.progress_bar.SetRange(ffc)
                        with open(fp, 'r', encoding='utf-8') as file:
                            for l in file:
                                if st in l:
                                    try:
                                        # self.grid_out.AppendRows(1)
                                        data = l.split('\t')[6].split(', ')
                                        da_sub=[]
                                        for d in data:
                                            da_sub.append(d.split(': ', 1)[1])
                                        self.r.set(f'{ssc}', str(da_sub))
                                    except:
                                        self.r.set(f'{ssc}',f'[数据有误, {l}]')
                                    ssc += 1
                                proc+=1
                                self.progress_bar.SetValue(proc)

                    # self.grid_out.AutoSizeColumns()
                    # # 滚动到插入点的位置
                    # self.grid_out.Scroll(ssc,0)


    def on_comb_ds_return(self, event):
        if conf.has_option('search_text', 'current'):
            oldt = conf.get('search_text', 'current')
        else: oldt = ''
        path = self.combox_S.GetValue()
        if oldt != path:
            if conf.has_option('set_DS_t', 'path_count'):
                PC = int(conf.get('set_DS_t', 'path_count'))
            else:
                PC = 0
            same = True
            if PC > 0:
                for i in range(PC):
                    if conf.has_option('search_text', str(i)):
                        his = conf.get('search_text', str(i))
                    else: his = ''
                    if path == his: same = False
                if same:
                    conf.set('search_text', str(PC), path)
                    conf.set('set_DS_t', 'path_count', str(PC + 1))
                    self.combox_S.Append(path)
            else:
                conf.set('set_DS_t', 'path_count', '1')
                conf.set('search_text', '0', path)
                self.combox_S.Append(path)
            conf.set('search_text', 'current', path)
            conf.write(open(setPath, 'w+', encoding="utf-8"))

    def on_comb_return(self, event):
        path = self.combox.GetValue()
        if os.path.exists(path):
            if path[-1] != '\\': path += '\\'
            if conf.has_option('set_DS', 'path_count'):
                PC = int(conf.get('set_DS', 'path_count'))
            else:
                PC = 0
            same = True
            if PC > 0:
                for i in range(PC):
                    if conf.has_option('PATH_DS', str(i)):
                        his = conf.get('PATH_DS', str(i))
                    else: his = ''
                    if path == his: same = False
                if same:
                    conf.set('PATH_DS', str(PC), path)
                    conf.set('set_DS', 'path_count', str(PC + 1))
                    self.combox.Append(path)
            else:
                conf.set('set_DS', 'path_count', '1')
                conf.set('PATH_DS', '0', path)
                self.combox.Append(path)
            conf.set('PATH_DS', 'current', path)
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.combox.SetValue(path)
            self.FindTxt()

    def get_line_count(self,file_path):
        line_count = 0
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as file:
                line_count = sum(1 for line in file)
        return line_count

app = wx.App(False)
frame = MyFrame(None, "DataSearcher v1.0")
frame.Show()
app.MainLoop()
