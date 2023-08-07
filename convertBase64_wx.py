# 将图标转成二进制代码
# import threading
import icondata
import wx
# from PIL import Image, ImageTk
# import tkinter as tk
# from tkinter import scrolledtext
# from tkinter import ttk

import os
from configparser import ConfigParser
import base64
# import subprocess

conf = ConfigParser()
setPath = os.getcwd()+'\\PrinterSetting.ini'
pcount = 0
if os.path.exists(setPath):
    conf.read_file(open(setPath, encoding='utf-8'))
if not conf.has_section('set2'):
    conf.add_section('set2')
if not conf.has_section('PATHicon'):
    conf.add_section('PATHicon')

try:
    pcount=int(conf.get('set2','path_count'))
except:
    conf.set('set2', 'path_count','0')
conf.write(open(setPath, 'w+', encoding="utf-8"))


class MyFrame(wx.Frame):

    def __init__(self, parent, title):
        super(MyFrame, self).__init__(parent, title=title, size=(1000, 900))
        # 加载图标文件并创建 wx.Icon 对象
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_b64']))
        icon = wx.Icon(temp_icon_file, wx.BITMAP_TYPE_ICO)
        # 设置窗口的标题栏图标
        self.SetIcon(icon)
#控件主面板
        panel = wx.Panel(self)
#平行布局：h_sizer（用于放置顶部的按钮与下拉列表）
        h_sizer = wx.BoxSizer(wx.HORIZONTAL)
#主布局：sizer
        sizer = wx.BoxSizer(wx.VERTICAL)
#Button按钮：button
        # 加载图标文件并创建 wx.Bitmap 对象
        icon = wx.Bitmap(temp_icon_file, wx.BITMAP_TYPE_ICO)    #使用ico类型图标
        os.remove(temp_icon_file)
        # 创建 wx.Button，设置图标和标签
        button = wx.Button(panel, wx.ID_ANY, label="转换", size=(80, icon.GetHeight()))
        button.SetBitmap(icon)
        # 绑定按钮事件
        button.Bind(wx.EVT_BUTTON, self.DoConvert)
    #布局：按钮放入顶部平行布局
        h_sizer.Add(button, 0, wx.ALIGN_LEFT|wx.ALL, 5)
#ComboBox可输入下拉列表：combox
        pco = int(conf.get('set2', 'path_count'))
        current_values = []
        if pco > 0:
            for i in range(pco):
                pp = conf.get('PATHicon', str(i))
                if os.path.exists(pp):
                    current_values.append(pp)
        self.combox = wx.ComboBox(panel, wx.ID_ANY, value='默认文本', choices=current_values, size=(480, -1)) #size设置宽度 -1为默认高度
        self.combox.Bind(wx.EVT_COMBOBOX, self.on_comb_return)
        self.combox.Bind(wx.EVT_COMBOBOX_CLOSEUP, self.on_comb_return) #这里使用打开下拉列表事件替代文本修改，避免函数死循环
        try:
            self.combox.SetValue(conf.get('PATHicon','current'))
        except:
            self.combox.SetValue(os.getcwd())
        h_sizer.Add(self.combox, 0, wx.ALIGN_CENTER|wx.ALL, 5)
    #布局：平行布局放入主布局最顶部
        sizer.Add(h_sizer, 0, wx.ALIGN_LEFT|wx.ALL, 1)
#ListBox多选列表：list
        self.list = wx.ListBox(panel, style=wx.VSCROLL|wx.LB_EXTENDED)
        sizer.Add(self.list, proportion=1, flag=wx.EXPAND|wx.ALL, border=6)
#TextCtrl文本控件：text_out
        self.text_out = wx.TextCtrl(panel, style=wx.TE_MULTILINE|wx.VSCROLL|wx.TE_READONLY|wx.TE_DONTWRAP) #wx.TE_MULTILINE|wx.TE_READONLY（多行只读）
        self.text_out.SetBackgroundColour(wx.Colour(17, 16, 20))
        self.text_out.SetForegroundColour(wx.Colour(113, 216, 130))
        sizer.Add(self.text_out, proportion=2, flag=wx.EXPAND|wx.ALL, border=6) #proportion比例为整数，该件比上面占面积大2倍

        panel.SetSizer(sizer)
#初始化时调用：
        self.FindIcon()
#移动主窗口位置
        self.Move(400,200)

    def FindIcon(self):
        path = self.combox.GetValue()
        if os.path.exists(path):
            if path[-1] != '\\': path += '\\'
            self.list.Clear()  # 清空列表，从索引0到末尾的所有项
            with os.scandir(path.strip()) as files:
                for f in files:
                    if not f.is_dir():
                        if f.path.endswith('ico') or f.path.endswith('png'):
                            siz = self.Sizeofsize(os.path.getsize(f.path))
                            self.list.Append(f'{f.name} → {siz}')


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
        selected_indices = self.list.GetSelections()
        if selected_indices:
            selected_items = [self.list.GetString(index) for index in selected_indices]
            scount = len(selected_items)
            path = self.combox.GetValue()
            if path[-1] != '\\': path += '\\'
            for p in selected_items:
                pp = str(p).split(' → ')
                fp = path + pp[0]
                ss = os.path.getsize(fp)
                if ss < 124000:
                    b = self.convertB(fp)
                    self.text_out.AppendText(f'\n({pp[0]}) 二进制代码：\n')
                    self.text_out.AppendText(f'{b}\n')
                    if scount == 1:
                        wx.Clipboard.Get().SetData(wx.TextDataObject(b))    #在多线程应用程序中使用剪贴板时，可能会发生冲突导致操作失败
                else:
                    self.text_out.AppendText(f'\n{p} <图标文件限制 121k 内>\n')
                self.text_out.SetInsertionPointEnd()
                # 滚动到插入点的位置
                self.text_out.ShowPosition(self.text_out.GetInsertionPoint())

    def on_comb_return(self, event):
        # try:
        #     oldtext = conf.get('PATHicon', 'current')
        # except:
        #     oldtext = ''
        path = self.combox.GetValue()
        # if oldtext != path:
        if os.path.exists(path):
            if path[-1] != '\\': path += '\\'
            PC = int(conf.get('set2', 'path_count'))
            same = True
            if PC > 0:
                for i in range(PC):
                    his = conf.get('PATHicon', str(i))
                    if path == his: same = False
                if same:
                    conf.set('PATHicon', str(PC), path)
                    conf.set('set2', 'path_count', str(PC + 1))
                    self.combox.Append(path)
            else:
                conf.set('set2', 'path_count', '1')
                conf.set('PATHicon', '0', path)
                self.combox.Append(path)
            conf.set('PATHicon', 'current', path)
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.combox.SetValue(path)
            self.FindIcon()


app = wx.App(False)
frame = MyFrame(None, "Pic to Base64 v1.2")
frame.Show()
app.MainLoop()
