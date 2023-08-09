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

if conf.has_option('set_DS', 'HOST'):
    s_host = conf.get('set_DS', 'HOST')
else:
    conf.set('set_DS', 'HOST', '192.168.17.99')
    s_host = '192.168.17.99'


conf.write(open(setPath, 'w+', encoding="utf-8"))


class MySecondaryDialog(wx.Dialog):  #使用Dialog，实现窗口打开时锁定主窗口
    def __init__(self, parent, title, text, showedit, call_func):
        super(MySecondaryDialog, self).__init__(parent, title=title, size=(480, 200))  #置顶窗口
        self.callback_func = call_func  #副窗口传入函数
        # 创建副窗口的内容
        panel = wx.Panel(self)
        label = wx.StaticText(panel, label=text, pos=(10, 10))
        but = wx.Button(panel,label='确定',pos=(260,120))
        but.Bind(wx.EVT_BUTTON, self.go_fun)
        close_btn = wx.Button(panel,label='取消',pos=(360,120))
        close_btn.Bind(wx.EVT_BUTTON, self.close_win)
        new = conf.get('set_DS', 'HOST')
        self.text = wx.TextCtrl(panel, value=new, pos=(80,50), size=(200,22))
        self.text.Hide()
        self.Center()   # 将副窗口放置在屏幕中间
        self.IsTopLevel()
        self.Show()
        if showedit:
            self.text.Show()
    def close_win(self,event):
        self.Close()

    def go_fun(self,event):
        value = self.text.GetValue()
        if self.callback_func:
            self.callback_func(value)   #传出副窗口控件值
            self.Close()

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
#主垂直布局：self.sizer
        self.sizer = wx.BoxSizer(wx.VERTICAL)

# Button导入数据库按钮：inputData_btn
        printicon_file = "temp2.png"
        with open(printicon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_input']))
        icon2 = wx.Bitmap(printicon_file, wx.BITMAP_TYPE_PNG)
        os.remove(printicon_file)
        inputData_btn = wx.Button(panel, wx.ID_ANY, label="导入", size=(80, 28))
        inputData_btn.SetBitmap(icon2)
        inputData_btn.SetToolTip('将选中的文件导入数据库（右键双击刷新数据库）')
        inputData_btn.Bind(wx.EVT_BUTTON, self.GetTextToData)
        inputData_btn.Bind(wx.EVT_RIGHT_DCLICK, lambda event, value=conf.get('set_DS', 'HOST'): self.get_Data_list(event,value))
        h_sizer.Add(inputData_btn, flag=wx.ALL, border=5)
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
        self.combox_S.SetToolTip('搜索关键字（在导入时也作为过滤导入）')
        self.combox_S.Bind(wx.EVT_COMBOBOX_DROPDOWN, self.on_comb_ds_return)
        try:
            self.combox_S.SetValue(conf.get('search_text','current'))
        except:
            pass
        h_sizer.Add(self.combox_S, proportion=1, flag=wx.EXPAND|wx.ALL, border=4)
#ComboBox修改方式选择：comb_edits
        self.comb_edits = wx.ComboBox(panel, wx.ID_ANY, value='<All>', choices=['<All>','write','create','rename','move','delete','property set'])
        self.comb_edits.SetToolTip('过滤：操作类型')
        self.comb_edits.SetBackgroundColour(wx.Colour(255, 210, 230))
        self.comb_edits.Bind(wx.EVT_COMBOBOX, self.search_Data_list)
        h_sizer.Add(self.comb_edits,proportion=1, flag=wx.EXPAND|wx.ALL, border=4)
#ComboBox文件、文件夹：comb_types
        self.comb_types = wx.ComboBox(panel, wx.ID_ANY, value='<All>', choices=['<All>','File','Folder'])#, style=wx.CB_READONLY
        self.comb_types.SetToolTip('过滤：文件或文件夹')
        self.comb_types.SetBackgroundColour(wx.Colour(255, 240, 190))
        self.comb_types.Bind(wx.EVT_COMBOBOX,self.search_Data_list)
        h_sizer.Add(self.comb_types,proportion=1, flag=wx.EXPAND|wx.ALL, border=4)

    #布局：平行布局放入主布局最顶部
        self.sizer.Add(h_sizer, 0, wx.EXPAND|wx.ALL, 1)  # 里面的参数同上（占比，标签，边界），参数名如果不写需要统一都不写

#Button按钮：button
        # 加载图标文件并创建 wx.Bitmap 对象
        icon = wx.Bitmap(temp_icon_file, wx.BITMAP_TYPE_ICO)    #使用ico类型图标
        os.remove(temp_icon_file)
        # 创建 wx.Button，设置图标和标签
        button = wx.Button(panel, wx.ID_ANY, label="搜索", size=(80, 28))
        button.SetBitmap(icon)
        button.SetToolTip('右键双击清空搜索历史')
        # 绑定按钮事件
        button.Bind(wx.EVT_BUTTON, self.search_Data_list)
        button.Bind(wx.EVT_RIGHT_DCLICK, self.DelSTHis)
    #布局：按钮放入顶部平行布局
        h_sizer.Add(button, flag=wx.ALL, border=5)

#水平布局：放置两个列表
        h_sizer_list = wx.BoxSizer(wx.HORIZONTAL)
#ListBox多选列表：list
        self.list = wx.ListBox(panel, style=wx.VSCROLL|wx.LB_EXTENDED)
        h_sizer_list.Add(self.list, proportion=1, flag=wx.EXPAND|wx.ALL, border=5)
#ListBox多选列表：list_2
        self.list_2 = wx.ListBox(panel, style=wx.VSCROLL|wx.LB_EXTENDED)
        h_sizer_list.Add(self.list_2, proportion=1, flag=wx.EXPAND|wx.ALL, border=5)

        self.sizer.Add(h_sizer_list, proportion=1, flag=wx.EXPAND|wx.ALL, border=5)
#grid_out表格控件：grid.Grid
        # self.text_out = wx.TextCtrl(panel, style=wx.TE_MULTILINE|wx.VSCROLL|wx.TE_READONLY|wx.TE_DONTWRAP) #wx.TE_MULTILINE|wx.TE_READONLY（多行只读）
        # self.text_out.SetBackgroundColour(wx.Colour(17, 16, 20))
        # self.text_out.SetForegroundColour(wx.Colour(113, 216, 130))

        self.grid_out = wx.grid.Grid(panel)
        self.grid_out.CreateGrid(0,7)
        # self.grid_out.SetRowSize(0,28)  #设置第一行高度
        self.grid_out.SetColLabelValue(0, '时间')
        self.grid_out.SetColLabelValue(1, '操作')
        self.grid_out.SetColLabelValue(2, '修改路径')
        self.grid_out.SetColLabelValue(3, '修改内容')
        self.grid_out.SetColLabelValue(4, '大小')
        self.grid_out.SetColLabelValue(5, '作者')
        self.grid_out.SetColLabelValue(6, 'IP')
        self.grid_out.AutoSizeColumns()
        self.sizer.Add(self.grid_out, proportion=2, flag=wx.EXPAND|wx.ALL, border=5) #proportion比例为整数，该件比上面占面积大2倍
    #平行布局2
        h_sizer_2 = wx.BoxSizer(wx.HORIZONTAL)
#StaticText操作状态显示文本：text_label
        self.text_label = wx.StaticText(panel, label=':', style=wx.FONTWEIGHT_BOLD, size=(100,-1))
        h_sizer_2.Add(self.text_label, proportion=0, flag=wx.ALIGN_CENTER|wx.ALL, border=5)
#Gauge进度条：progress_bar
        self.progress_bar = wx.Gauge(panel, range=100)
        self.progress_bar.SetForegroundColour(wx.Colour(220, 28, 0))
        h_sizer_2.Add(self.progress_bar, proportion=1, flag=wx.EXPAND|wx.ALL, border=5)
        self.sizer.Add(h_sizer_2, 0, wx.EXPAND|wx.ALL, 1)

        self.ipshow = wx.StaticText(panel, label=s_host)
        self.ipshow.Bind(wx.EVT_RIGHT_UP, self.edit_ip)
        h_sizer_2.Add(self.ipshow, proportion=0, flag=wx.ALIGN_CENTER|wx.ALL, border=5)
        panel.SetSizer(self.sizer)

#移动主窗口位置
        self.Move(400,200)

# 初始化时调用：
        self.FindTxt()
        self.r = None   #变量预赋予空值，以便在可以正常链接数据库时赋予
        if self.check_redis(s_host, ''):
            self.get_Data_list(self,s_host)

    def edit_ip(self,event):
        def callback(value):    #输出副窗口控件的值（[确定]按钮实现功能函数）
            conf.set('set_DS', 'HOST', value)
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.get_Data_list(self,value)
            self.ipshow.SetLabel(value)

        second_frame = MySecondaryDialog(self, '设置服务器IP','输入数据库服务器的IP地址：', True, callback)
        second_frame.Show() #显示副窗口
        second_frame.ShowModal()    #锁定主窗口


    def on_open_secondary_window(self, title, msg, show, fun): # ("窗口标题", '提示信息')
        # 创建副对话框的实例并显示为模态（锁定主窗口直到副窗口关闭）
        secondary_dialog = MySecondaryDialog(self, title, msg, show, fun)
        secondary_dialog.ShowModal()
        secondary_dialog.Destroy()  # 关闭副对话框

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

    def GetRedisData(self,event):
        dbc = self.r.dbsize()
        if dbc > 0:
            self.progress_bar.SetValue(0)
            self.text_label.SetLabel('正在读取数据:')

            gnum = self.grid_out.GetNumberRows()  # 删除所有行↓
            if gnum > 0:
                for i in range(gnum):
                    self.grid_out.DeleteRows(0)  # 根据总行数循环删除第一行↑
            self.grid_out.AppendRows(dbc)
            self.progress_bar.SetRange(dbc)
            for i in range(dbc):
                datas = eval(self.r.get(f'{i}'))  # 转换字符串为数组（将字符串作为代码执行）
                # if len(datas) == 6:
                col = 0
                for d in datas:
                    self.grid_out.SetCellValue(i, col, d)
                    col += 1
                # else:
                #     self.grid_out.SetCellValue(i, 1, str(datas))
                self.progress_bar.SetValue(i + 1)
            #     for d in range(len(datas)):
            #         self.grid_out.SetCellValue(i, d, datas[d])
            self.grid_out.AutoSizeColumns()
            self.grid_out.Scroll(0, dbc)
            self.text_label.SetLabel('(数据读取完成)')

    def DelSTHis(self,event):
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
        result = dlg.ShowModal()    # 冻结主窗口
        dlg.Destroy()
        if result == wx.ID_YES:
            selected_indices = self.list.GetSelections()
            if selected_indices:
                selected_items = [self.list.GetString(index) for index in selected_indices]
                scount = len(selected_items)
                st = self.combox_S.GetValue()   # 搜索内容
                if scount > 0 and st != '':
                    self.progress_bar.SetValue(0)
                    path = self.combox.GetValue()
                    if path[-1] != '\\': path += '\\'
                    self.text_label.SetLabel('正在搜索:')
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
                                if 'Event: read' not in l and 'Thumbs.db' not in l:
                                    if st in l:
                                        # try:
                                        data = l.split('\t')[6].split(', ')
                                        da_sub=[]
                                        ds = len(data)
                                        if ds == 6:
                                            for d in data:
                                                if ': ' in d:
                                                    da_sub.append(d.split(': ', 1)[1])
                                                else:
                                                    da_sub.append(d)
                                        elif ds > 6:
                                            da_sub.append(data[0].split(': ', 1)[1])
                                            # 合并第2个与后4个中间的成员
                                            da_sub.append(str(data[1:-4]).split(': ', 1)[1].replace('\'','')[:-1])   # replace删除字符：'，删除最后一个字符：]
                                            for item in data[-4:]:  # 循环添加最后4个成员
                                                da_sub.append(item.split(': ', 1)[1])

                                        self.r.set(f'{ssc}', str(da_sub))
                                        # except:
                                        #     self.r.set(f'{ssc}',f'[数据有误, {l}]')
                                        ssc += 1
                                    proc+=1
                                    self.progress_bar.SetValue(proc)
                    self.text_label.SetLabel('(搜索完成)')
                    # self.grid_out.AutoSizeColumns()
                    # # 滚动到插入点的位置
                    # self.grid_out.Scroll(ssc,0)
    def GetTextToData(self,event):  #导入数据
        if self.check_redis(s_host, ''):
            st = self.combox_S.GetValue()
            if st != '':
                dlg = wx.MessageDialog(self, "确定开始导入选中文件到数据库吗，该操作将会花点时间！", "[导入数据]",
                                       wx.YES_NO | wx.ICON_QUESTION)
                result = dlg.ShowModal()
                dlg.Destroy()
                if result == wx.ID_YES:
                    if self.r.exists('FS'):
                        getAF = self.r.smembers('FS')   #获取所有集中元素
                    else:
                        getAF = []
                    selected_indices = self.list.GetSelections()
                    if selected_indices:    #获取选中的列表项
                        selected_items = [self.list.GetString(index) for index in selected_indices]
                        scount = len(selected_items)
                        # st = self.combox_S.GetValue()  # 搜索内容
                        if scount > 0:
                            self.progress_bar.SetValue(0)
                            path = self.combox.GetValue()
                            if path[-1] != '\\': path += '\\'
                            self.text_label.SetLabel('正在导入:')

                            # self.r.flushdb()  # 清空数据库

                            for p in selected_items:
                                pp = str(p).split(' → ')
                                fp = path + pp[0]
                                keyN = pp[0][:-4]
                                if keyN not in getAF:
                    #添加新导入数据文件名到FS集合
                                    self.r.sadd('FS',keyN)
                                else:
                                    self.r.delete(keyN) #如果文件存在集里则清空，便于写入新元素
                                ffc = self.get_line_count(fp)  # 获取文本总行数
                                proc = 0
                                self.progress_bar.SetRange(ffc)
                    # 记录文件名的键值（用于获取数据文件名）
                    #             self.r.set(f'FC{FC}', keyN)
                                with open(fp, 'r', encoding='utf-8') as file:
                                    for l in file:
                                        if st in l:
                                            if 'Event: read' not in l and 'Thumbs.db' not in l:
                                                sour_data = l.split('\t')
                                                data = sour_data[6].split(', ')
                                                da_sub = [f'{sour_data[0]}|{sour_data[1]}']
                                                ds = len(data)
                                                if ds == 6:
                                                    for d in data:
                                                        if ': ' in d:
                                                            da_sub.append(d.split(': ', 1)[1])
                                                        else:
                                                            da_sub.append(d)
                                                elif ds > 6:
                                                    da_sub.append(data[0].split(': ', 1)[1])
                                                    # ↓合并第2个与后4个中间的成员
                                                    da_sub.append(str(data[1:-4]).split(': ', 1)[1].replace('\'', '')[:-1])  # replace删除字符：'，删除最后一个字符：]
                                                    for item in data[-4:]:  # 循环添加最后4个成员
                                                        da_sub.append(item.split(': ', 1)[1])
                        # 写入各文件正数据
                        #                         self.r.set(f'{keyN}_{proc}', str(da_sub))
                                                self.r.sadd(keyN, str(da_sub))
                                                self.r.set(f'{keyN}>ST',str(st))

                                                proc += 1
                                                self.progress_bar.SetValue(proc)
                    # 写入数据文本(F:文件名)→包含数据数量
                    #             self.r.set(f'F:{keyN}', str(proc))
                    # 记录总导入文件数（用于循环读取）
                    #         self.r.set('FC', str(scount))
                            self.text_label.SetLabel('(导入完成)')
                            self.get_Data_list(self,conf.get('set_DS', 'HOST'))
            else:
                dlg = wx.MessageDialog(self, "未设置搜索关键字，输入要检查路径关键字，避免导入无用数据。", "[设置路径关键字]",
                                       wx.ICON_QUESTION)
                result = dlg.ShowModal()
                dlg.Destroy()

    def on_comb_ds_return(self, event):
        if conf.has_option('search_text', 'current'):
            oldt = conf.get('search_text', 'current')
        else: oldt = ''
        path = self.combox_S.GetValue()
        if path != '':
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
                for line in file:
                    if self.combox_S.GetValue() in line:
                        if 'Event: read' not in line and 'Thumbs.db' not in line:
                            line_count+=1
        return line_count

    #获取数据库内容到列表2
    def get_Data_list(self,event,value):
        if self.check_redis(value, ''):
            dbc = self.r.dbsize()   #获取当前库数据数量
            if dbc > 0:
                getAF = self.r.smembers('FS')
                if len(getAF) > 0:
                    self.list_2.Clear()
                    for F in getAF: # F从0开始
                        F = F.decode('utf-8')
                        # print(F)
                        if self.r.exists(F):
                            st = self.r.get(f'{F}>ST')
                            if st is not None:  #注意：在对返回的值进行转换为 UTF-8 字符串之前，你需要检查是否为 None。
                                st = st.decode('utf-8')
                            fnn = self.r.scard(F)
                            self.list_2.Append(f'{F} → 数量:{fnn} <{st}>')
                    self.text_label.SetLabel('(数据库刷新)')
        else:
            self.list_2.Clear()

#搜索数据库到输出列表
    def search_Data_list(self,event):
        selected_indices = self.list_2.GetSelections()
        if selected_indices:
            selected_items = [self.list_2.GetString(index) for index in selected_indices]
            scount = len(selected_items)
            st = self.combox_S.GetValue()  # 搜索内容
            if scount > 0:
                gnum = self.grid_out.GetNumberRows()  # 删除所有行↓
                if gnum > 0:
                    for i in range(gnum):
                        self.grid_out.DeleteRows(0)  # 根据总行数循环删除第一行↑
                row = 0 #注意：这个行ID需要在多个数据文件循环外，后面的搜索内容才不会将前面的替换
                for p in selected_items:
                    pp = str(p).split(' → ')[0]
                    getAE = self.r.smembers(pp)
                    for m in getAE:
                        m = m.decode('utf-8')
                        if st in m:
                            datas = eval(m)  # 转换字符串为数组（将字符串作为代码执行）
                            if self.comb_edits.GetValue() == '<All>' or self.comb_edits.GetValue() == datas[1]:
                                if self.comb_types.GetValue() == '<All>' or self.comb_types.GetValue() == datas[3]:
                                    col = 0
                                    self.grid_out.AppendRows(1)
                                    for d in datas:
                                        self.grid_out.SetCellValue(row, col, d)
                                        self.grid_out.SetCellBackgroundColour(row, 1, wx.Colour(255, 210, 230))
                                        self.grid_out.SetCellBackgroundColour(row, 3, wx.Colour(255, 240, 190))
                                        col += 1
                                    row+=1
                self.grid_out.AutoSizeColumns()
                self.grid_out.Scroll(0, row)
                self.text_label.SetLabel('(搜索完成)')
                screen_width = wx.Display(0).GetGeometry().GetWidth()   #获取主显示器宽度
                w = sum(self.grid_out.GetColSize(col) for col in range(self.grid_out.GetNumberCols()))+130  #获取Grid总宽度
                if w > screen_width:
                    w = screen_width
                if w < 1000: w = 1000
                self.SetSize(wx.Size(w,self.GetSize()[1]))  #设置主窗口大小
                self.sizer.Layout()

    def check_redis(self, host, password):  #检查服务器链接
        self.text_label.SetLabel('(正在搜索数据库)')
        try:
            t = redis.Redis(host=host, port=6379, password=password, decode_responses=True)
            t.ping()  # 发送一个 ping 命令来检查连接
            self.text_label.SetLabel('(数据库正常)')
            self.r = redis.StrictRedis(host=host, port=6379, db=0)
            return True
        except:
            self.text_label.SetLabel('<数据库异常>')
            return False

app = wx.App(False)
frame = MyFrame(None, "DataSearcher v1.0")
frame.Show()
app.MainLoop()
