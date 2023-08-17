# 将图标转成二进制代码
import sys
import subprocess
# import threading
import icondata
# from cryptography.fernet import Fernet
import redis
import os
from configparser import ConfigParser
import base64
import wx
import wx.grid
import time
import json

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

username = os.getlogin()

if conf.has_option('set_DS', 'HOST'):
    s_host = conf.get('set_DS', 'HOST')
else:
    conf.set('set_DS', 'HOST', '192.168.17.99')
    s_host = '192.168.17.99'

R_Data = dict() #预读取数据
search_count = False
conf.write(open(setPath, 'w+', encoding="utf-8"))


class MySecondaryDialog(wx.Dialog):  #使用Dialog，实现窗口打开时锁定主窗口
    def __init__(self, parent, title, text, showedit, pas, call_func):
        super(MySecondaryDialog, self).__init__(parent, title=title, size=(420, 170))  #置顶窗口
        self.callback_func = call_func  #副窗口传入函数
        self.pas=pas
        # 创建副窗口的内容
        panel = wx.Panel(self)
        label = wx.StaticText(panel, label=text, pos=(10, 10))
        but = wx.Button(panel,label='确定',pos=(200,90))
        but.Bind(wx.EVT_BUTTON, self.go_fun)
        close_btn = wx.Button(panel,label='取消',pos=(300,90))
        close_btn.Bind(wx.EVT_BUTTON, self.close_win)
        new = conf.get('set_DS', 'HOST')
        self.pasw = wx.TextCtrl(panel, style=wx.ALIGN_CENTER|wx.TE_PROCESS_ENTER, pos=(105,40), size=(200,22))
        self.pasw.Bind(wx.EVT_TEXT_ENTER,self.go_fun)
        self.text = wx.TextCtrl(panel, style=wx.TE_PROCESS_ENTER, pos=(105,40), size=(200,22))
        self.text.SetValue(new) #注意：该文本控件添加了 style 参数所以 Value的默认参数就不能在创建时添加了
        self.text.Bind(wx.EVT_TEXT_ENTER,self.go_fun)
        self.pasw.Hide()
        self.text.Hide()
        self.Center()   # 将副窗口放置在屏幕中间
        self.IsTopLevel()
        self.Show()
        if showedit:
            if self.pas == 'passwer':
                self.pasw.Show()
                self.pasw.SetFocus()
            else:
                self.text.Show()
                self.text.SetFocus()
    def close_win(self,event):
        self.Close()

    def go_fun(self,event):
        if self.pas == 'passwer':
            value = self.pasw.GetValue()
        else:
            value = self.text.GetValue()
        if self.callback_func:
            self.callback_func(value)   #传出副窗口控件值
            self.Close()


class MyFrame(wx.Frame):

    def __init__(self, parent, title):
        super(MyFrame, self).__init__(parent, title=title, size=(1052, 900))
        global username
        # 加载图标文件并创建 wx.Icon 对象
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_ds']))
        icon = wx.Icon(temp_icon_file, wx.BITMAP_TYPE_ICO)
        # 设置窗口的标题栏图标
        self.SetIcon(icon)
#控件主面板
        self.panel = wx.Panel(self)
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
        inputData_btn = wx.Button(self.panel, wx.ID_ANY, label="导入", size=(80, 28))
        inputData_btn.SetBitmap(icon2)
        inputData_btn.SetToolTip('将选中的文件导入数据库（右键双击刷新数据库）')
        inputData_btn.Bind(wx.EVT_BUTTON, self.posswer)
        inputData_btn.Bind(wx.EVT_RIGHT_DCLICK, lambda event, value=conf.get('set_DS', 'HOST'): self.get_Data_list(event,value))
        h_sizer.Add(inputData_btn, flag=wx.ALL, border=4)
#CheckBox遍历文件选项：search_fol
        self.search_fol_chk = wx.CheckBox(self.panel)
        self.search_fol_chk.SetToolTip('勾选对当前路径进行数据预处理')
        self.search_fol_chk.Bind(wx.EVT_CHECKBOX, self.check_extfilter)
        h_sizer.Add(self.search_fol_chk, flag=wx.ALIGN_CENTER|wx.RIGHT, border=2)
#ComboBox路径下拉列表：path_combox
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
        self.path_combox = wx.ComboBox(self.panel, wx.ID_ANY, choices=current_values, size=(-1, 20), style=wx.TE_PROCESS_ENTER) # size=设置宽度 -1为默认高度
        self.path_combox.Bind(wx.EVT_COMBOBOX, self.on_comb_return)
        self.path_combox.Bind(wx.EVT_TEXT_ENTER, self.on_comb_return)
        # self.combox.Bind(wx.EVT_COMBOBOX_DROPDOWN, self.on_comb_return) #这里使用打开下拉列表事件替代文本修改，避免函数死循环
        try:
            self.path_combox.SetValue(conf.get('PATH_DS', 'current'))
        except:
            self.path_combox.SetValue(os.getcwd())
        h_sizer.Add(self.path_combox, proportion=2, flag=wx.EXPAND | wx.TOP | wx.RIGHT | wx.BOTTOM, border=4)
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
        self.combox_S = wx.ComboBox(self.panel, wx.ID_ANY, choices=t_currents_values,style=wx.TE_PROCESS_ENTER) #size设置宽度 -1为默认高度
        self.combox_S.SetToolTip('搜索关键字（在导入时也作为过滤导入）')
        self.combox_S.Bind(wx.EVT_COMBOBOX, self.on_comb_sel)
        self.combox_S.Bind(wx.EVT_TEXT_ENTER, self.on_comb_ds_return)
        try:
            self.combox_S.SetValue(conf.get('search_text','current'))
        except:
            pass
        h_sizer.Add(self.combox_S, proportion=1, flag=wx.EXPAND|wx.TOP|wx.RIGHT|wx.BOTTOM, border=4)
#ComboBox修改方式选择：comb_edits
        self.comb_edits = wx.ComboBox(self.panel, wx.ID_ANY, value='<All>', choices=['<All>','write','create','rename','move','delete','property set'])
        self.comb_edits.SetToolTip('过滤：操作类型')
        self.comb_edits.SetBackgroundColour(wx.Colour(255, 210, 230))
        self.comb_edits.Bind(wx.EVT_COMBOBOX, self.filter_search)
        h_sizer.Add(self.comb_edits,proportion=1, flag=wx.EXPAND|wx.TOP|wx.RIGHT|wx.BOTTOM, border=4)
        self.edits_comb = ['<All>']
#ComboBox文件、文件夹：comb_types
        self.comb_types = wx.ComboBox(self.panel, wx.ID_ANY, value='<All>', choices=['<All>','File','Folder'])#, style=wx.CB_READONLY
        self.comb_types.SetToolTip('过滤：文件或文件夹')
        self.comb_types.SetBackgroundColour(wx.Colour(255, 240, 190))
        self.comb_types.Bind(wx.EVT_COMBOBOX,self.filter_search)
        h_sizer.Add(self.comb_types,proportion=1, flag=wx.EXPAND|wx.TOP|wx.RIGHT|wx.BOTTOM, border=4)
#ComboBox修改方式选择：comb_edits
        self.comb_users = wx.ComboBox(self.panel, wx.ID_ANY, value='<All>', choices=['<All>'])
        self.comb_users.SetToolTip('过滤：作者')
        self.comb_users.SetBackgroundColour(wx.Colour(225, 250, 240))
        self.comb_users.Bind(wx.EVT_COMBOBOX, self.filter_search)
        h_sizer.Add(self.comb_users,proportion=1, flag=wx.EXPAND|wx.TOP|wx.RIGHT|wx.BOTTOM, border=4)
        self.users_comb = ['<All>']

    #布局：平行布局放入主布局最顶部
        self.sizer.Add(h_sizer, 0, wx.EXPAND|wx.ALL, 1)  # 里面的参数同上（占比，标签，边界），参数名如果不写需要统一都不写

#Button按钮：button_save
        # 加载图标文件并创建 wx.Bitmap 对象
        printicon_file = "temp2.png"
        with open(printicon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_save']))
        iconsave = wx.Bitmap(printicon_file, wx.BITMAP_TYPE_PNG)
        os.remove(printicon_file)
        # 创建 wx.Button，设置图标和标签
        button_save = wx.Button(self.panel, wx.ID_ANY, size=(28, 28))
        button_save.SetBitmap(iconsave)
        button_save.SetToolTip('创建本地数据存档')
        # 绑定按钮事件
        button_save.Bind(wx.EVT_BUTTON, self.save_LocalData)
        # button_save.Bind(wx.EVT_RIGHT_DCLICK, self.del_MemData)
        h_sizer.Add(button_save, flag=wx.ALIGN_CENTER|wx.RIGHT, border=3)
#Button按钮：button_del
        # 加载图标文件并创建 wx.Bitmap 对象
        printicon_file = "temp2.png"
        with open(printicon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_del']))
        icondel = wx.Bitmap(printicon_file, wx.BITMAP_TYPE_PNG)
        os.remove(printicon_file)
        # 创建 wx.Button，设置图标和标签
        button_del = wx.Button(self.panel, wx.ID_ANY, size=(28, 28))
        button_del.SetBitmap(icondel)
        button_del.SetToolTip('清除列表选择的本地存档（双击右键删除缓存）')
        # 绑定按钮事件
        button_del.Bind(wx.EVT_BUTTON, self.del_LocalData)
        button_del.Bind(wx.EVT_RIGHT_DCLICK, self.del_MemData)
        h_sizer.Add(button_del, flag=wx.ALIGN_CENTER|wx.RIGHT, border=3)
#Button按钮：button
        # 加载图标文件并创建 wx.Bitmap 对象
        icon = wx.Bitmap(temp_icon_file, wx.BITMAP_TYPE_ICO)    #使用ico类型图标
        os.remove(temp_icon_file)
        # 创建 wx.Button，设置图标和标签
        button = wx.Button(self.panel, wx.ID_ANY, label="搜索", size=(80, 28))
        button.SetBitmap(icon)
        button.SetToolTip('右键双击清空搜索历史')
        # 绑定按钮事件
        button.Bind(wx.EVT_BUTTON, self.search_Data_list)
        button.Bind(wx.EVT_RIGHT_DCLICK, self.DelSTHis)
    #布局：按钮放入顶部平行布局
        h_sizer.Add(button, flag=wx.ALIGN_CENTER|wx.RIGHT, border=3)

#水平布局：放置两个列表
        h_sizer_list = wx.BoxSizer(wx.HORIZONTAL)
#列表与类型过滤文本的垂直布局
        self.v_sizer = wx.BoxSizer(wx.VERTICAL)
#BoxSizer过滤文本和相关按钮的平行布局：ext_sizer
        self.ext_sizer = wx.BoxSizer(wx.HORIZONTAL)
    # 侧边按垂直布局
        self.btn_sizer = wx.BoxSizer(wx.VERTICAL)
    # 获取所有文件类型
        self.ext_getall_btn = wx.Button(self.panel, id=wx.ID_ANY, label='获', size=(30, 28))
        self.ext_getall_btn.SetBackgroundColour(wx.Colour(250,110,90))
        self.ext_getall_btn.Bind(wx.EVT_BUTTON,self.get_allext)
        self.ext_getall_btn.SetToolTip('获取所有文件类型')
        self.btn_sizer.Add(self.ext_getall_btn,0,wx.TOP,0)
        self.ext_getall_btn.Hide()
    # 保存排除类型按钮
        self.ext_saveext_btn=wx.Button(self.panel, id=wx.ID_ANY, label='存', size=(30, 28))
        self.ext_saveext_btn.SetBackgroundColour(wx.Colour(230,210,90))
        self.ext_saveext_btn.Bind(wx.EVT_BUTTON, self.on_extfilter_saver)
        self.ext_saveext_btn.SetToolTip('保存当前过滤文件类型 (Enter)')
        self.btn_sizer.Add(self.ext_saveext_btn,0,wx.TOP,3)
        self.ext_saveext_btn.Hide()
    # 读取远程设置
        self.ext_read_btn = wx.Button(self.panel, id=wx.ID_ANY, label='读', size=(30, 28))
        self.ext_read_btn.SetBackgroundColour(wx.Colour(130,250,190))
        self.ext_read_btn.Bind(wx.EVT_BUTTON,self.get_server_set)
        self.ext_read_btn.SetToolTip('读取保存设置')
        self.btn_sizer.Add(self.ext_read_btn,0,wx.TOP,3)
        self.ext_read_btn.Hide()
    # 读取全部文件类型
        self.ext_readall_btn = wx.Button(self.panel, id=wx.ID_ANY, label='全', size=(30, 28))
        self.ext_readall_btn.SetBackgroundColour(wx.Colour(110,240,160))
        self.ext_readall_btn.Bind(wx.EVT_BUTTON,self.get_server_set_all)
        self.ext_readall_btn.SetToolTip('读取全部文件类型')
        self.btn_sizer.Add(self.ext_readall_btn,0,wx.TOP,3)
        self.ext_readall_btn.Hide()

        self.ext_sizer.Add(self.btn_sizer,0,wx.CENTER,1)
    # TextCtrl检索路径文件过滤：ext_filter
        extstring = ''
        pp = self.getNoSlashPath(self.path_combox.GetValue())
        if conf.has_option('set_DS', f'EXTFILTER_{pp}_{username}'):
            extstring = conf.get('set_DS', f'EXTFILTER_{pp}_{username}')
        self.ext_filter = wx.TextCtrl(self.panel, value=extstring, style=wx.TE_PROCESS_ENTER|wx.TE_MULTILINE)
        # self.ext_filter.SetToolTip('输入检索预处理文件的排除类型，用;(分号)隔开')
        self.ext_filter.SetBackgroundColour(wx.Colour(242, 246, 240))
        self.ext_filter.SetForegroundColour(wx.Colour(137, 146, 80))
        font = wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
        self.ext_filter.SetFont(font)
        self.ext_filter.Bind(wx.EVT_TEXT_ENTER, self.on_extfilter_saver)
        self.ext_sizer.Add(self.ext_filter,2,wx.EXPAND,1)
        self.ext_filter.Hide()
    # 目录排除文本
        folstring = ''
        if conf.has_option('set_DS', f'FOLFILTER_{pp}_{username}'):
            folstring = conf.get('set_DS', f'FOLFILTER_{pp}_{username}')
        self.fol_filter = wx.TextCtrl(self.panel, value=folstring, style=wx.TE_PROCESS_ENTER|wx.TE_MULTILINE)
        self.fol_filter.SetToolTip('输入排除文件夹，用;(分号)隔开')
        self.fol_filter.SetBackgroundColour(wx.Colour(242, 240, 230))
        self.fol_filter.SetForegroundColour(wx.Colour(157, 126, 80))
        self.fol_filter.SetFont(font)
        self.fol_filter.Bind(wx.EVT_TEXT_ENTER, self.on_folfilter_saver)
        self.ext_sizer.Add(self.fol_filter,1,wx.EXPAND,1)
        self.fol_filter.Hide()
#ListBox多选列表：list
        self.list = wx.ListBox(self.panel, style=wx.VSCROLL|wx.LB_EXTENDED)
        self.v_sizer.Add(self.list, proportion=1, flag=wx.EXPAND, border=4)

        h_sizer_list.Add(self.v_sizer, proportion=1, flag=wx.EXPAND|wx.LEFT, border=4)
#ListBox多选列表：list_2
        self.list_2 = wx.ListBox(self.panel, style=wx.VSCROLL|wx.LB_EXTENDED)
        self.list_2.Bind(wx.EVT_LISTBOX, self.on_list2_sel)
        self.list_2.SetBackgroundColour(wx.Colour(237, 236, 255))
        h_sizer_list.Add(self.list_2, proportion=1, flag=wx.EXPAND|wx.LEFT|wx.RIGHT, border=4)

        self.sizer.Add(h_sizer_list, proportion=1, flag=wx.EXPAND|wx.ALL, border=2)
#中间信息显示文本：msg_txt
        self.msg_txt = wx.StaticText(self.panel,label='点击左边行数字选择整行，Ctrl+C 可打开文件目录 并复制文件名，可以在文件搜索直接粘贴定位该文件')
        self.msg_txt.SetForegroundColour(wx.Colour(197, 96, 120))
        self.sizer.Add(self.msg_txt, proportion=0, flag=wx.LEFT, border=12)
#grid_out表格控件：grid.Grid
        # self.text_out = wx.TextCtrl(self.panel, style=wx.TE_MULTILINE|wx.VSCROLL|wx.TE_READONLY|wx.TE_DONTWRAP) #wx.TE_MULTILINE|wx.TE_READONLY（多行只读）
        # self.text_out.SetBackgroundColour(wx.Colour(17, 16, 20))
        # self.text_out.SetForegroundColour(wx.Colour(113, 216, 130))

        self.grid_out = wx.grid.Grid(self.panel)
        self.grid_out.CreateGrid(0,7)
        # self.grid_out.SetRowSize(0,28)  #设置第一行高度
        self.grid_out.SetColLabelValue(0, '时间')
        self.grid_out.SetColLabelValue(1, '操作')
        self.grid_out.SetColLabelValue(2, '修改路径')
        self.grid_out.SetColLabelValue(3, '内容')
        self.grid_out.SetColLabelValue(4, '大小')
        self.grid_out.SetColLabelValue(5, '作者')
        self.grid_out.SetColLabelValue(6, 'IP')
        self.grid_out.AutoSizeColumns()
        self.grid_out.Bind(wx.EVT_CHAR_HOOK,self.on_char_hook)
        self.sizer.Add(self.grid_out, proportion=3, flag=wx.EXPAND|wx.ALL, border=5) #proportion比例为整数，该件比上面占面积大2倍
    #平行布局2
        h_sizer_2 = wx.BoxSizer(wx.HORIZONTAL)
#StaticText操作状态显示文本：text_label
        self.text_label = wx.StaticText(self.panel, label=':', style=wx.FONTWEIGHT_BOLD, size=(100,-1))
        h_sizer_2.Add(self.text_label, proportion=0, flag=wx.ALIGN_CENTER|wx.LEFT|wx.RIGHT, border=5)
#Gauge进度条：progress_bar
        self.progress_bar = wx.Gauge(self.panel, range=100)
        h_sizer_2.Add(self.progress_bar, proportion=1, flag=wx.EXPAND|wx.LEFT|wx.RIGHT, border=5)
        self.sizer.Add(h_sizer_2, 0, wx.EXPAND|wx.ALL, 1)
#显示查询变量内存占用
        self.member_use = wx.StaticText(self.panel)
        self.member_use.SetToolTip('[搜索缓存数 : 占用内存]')
        h_sizer_2.Add(self.member_use, proportion=0, flag=wx.RIGHT, border=3)
#StaticTextIP显示静态文本：ipshow
        self.ipshow = wx.StaticText(self.panel, label=s_host)
        self.ipshow.Bind(wx.EVT_RIGHT_UP, self.edit_ip)
        h_sizer_2.Add(self.ipshow, proportion=0, flag=wx.RIGHT, border=8)

        self.panel.SetSizer(self.sizer)

        self.Bind(wx.EVT_CHAR_HOOK,self.Esc_Stop)   #绑定快捷键ESC
#移动主窗口位置
        self.Move(400,200)

# 初始化时调用：
        self.r = None   #变量预赋予空值，以便在可以正常链接数据库时赋予
        self.data = []
        self.FindTxt()
        self.StartStop = True

        self.get_Data_list(self,s_host)
        self.get_server_set(self)

    def on_char_hook(self, event):
        keycode = event.GetKeyCode()
        modifiers = event.GetModifiers()
        if keycode == ord('C') and modifiers == wx.MOD_CONTROL:
            selected_rows = self.grid_out.GetSelectedRows()
            if selected_rows:
                selected_cells = self.grid_out.GetCellValue(selected_rows[0],2)
                if selected_cells:
                    if os.path.exists(selected_cells):
                        f_p = os.path.dirname(selected_cells)
                        #程序打包后可以打开目录
                        subprocess.Popen(["explorer.exe", f_p], shell=True)
                        f_f = os.path.basename(selected_cells)
                        #放入剪贴板
                        clipboard = wx.TextDataObject() #用于存储文本数据，以便将其复制到剪贴板中
                        clipboard.SetText(f_f)
                        wx.TheClipboard.Open()  #打开剪贴板
                        wx.TheClipboard.SetData(clipboard)  #放入剪贴板
                        wx.TheClipboard.Close() #关闭剪贴板

                        # clipboard_text = clipboard.GetText()
                        # # self.text_ctrl.SetValue(clipboard_text)
                        # print("Clipboard content:", clipboard_text)

    def on_list2_sel(self,event):
        selected_indices = self.list_2.GetSelections()
        if selected_indices != wx.NOT_FOUND:
            selected_items = [self.list_2.GetString(index) for index in selected_indices]
            scount = len(selected_items)
            if scount > 0:
                conf.set('set_DS', 'LIST2_SEL', str(selected_indices[0]))
                conf.write(open(setPath, 'w+', encoding="utf-8"))
    def resel_list2(self):
        if conf.has_option('set_DS', 'LIST2_SEL'):
            sel = int(conf.get('set_DS', 'LIST2_SEL'))
            self.list_2.SetSelection(sel)

    def save_extfilter_all(self):
        global username
        pp = self.getNoSlashPath(self.path_combox.GetValue())
        conf.set('set_DS', f'All_EXTFILTER_{pp}_{username}', self.ext_filter.GetValue())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        self.ext_readall_btn.Show()
        self.panel.Layout() #显示按钮后需要刷新布局
        if self.check_redis(s_host, ''):
            self.r.hset('SETTINGS', f'All_EXTFILTER_{pp}_{username}', self.ext_filter.GetValue())
    def get_server_set_all(self,event):
        global username
        pp = self.getNoSlashPath(self.path_combox.GetValue())
        extstring = ''
        if conf.has_option('set_DS', f'All_EXTFILTER_{pp}_{username}'):
            extstring = conf.get('set_DS', f'All_EXTFILTER_{pp}_{username}')
        if self.check_redis(s_host,''):
            if self.r.hexists('SETTINGS', f'All_EXTFILTER_{pp}_{username}'):
                extstring = self.r.hget('SETTINGS', f'All_EXTFILTER_{pp}_{username}')
        if extstring != '':
            self.ext_filter.SetValue(extstring)

    def get_server_set(self,event):
        global username
        pp = self.getNoSlashPath(self.path_combox.GetValue())
        extstring = ''
        conf.set('set_DS', f'EXTFILTER_{pp}_{username}', self.ext_filter.GetValue())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        if self.check_redis(s_host, ''):
            if self.r.hexists('SETTINGS', f'EXTFILTER_{pp}_{username}'):
                extstring = self.r.hget('SETTINGS', f'EXTFILTER_{pp}_{username}')
        if extstring != '':
            self.ext_filter.SetValue(extstring)

    # def get_allFolders(self,path):  #获取目录数
    #     folder_c = 0
    #     for dirpath, dirnames, filenames in os.walk(path):
    #         for dirname in dirnames:
    #             folder_c+=1
    #     return folder_c
    #
    # def count_files_in_folder(self,folder_path):    #获取文件数
    #     file_count = 0
    #     for root, dirs, files in os.walk(folder_path):
    #         file_count += len(files)
    #     return file_count
    CCC=0
    def get_all_file_extensions(self,root_dir):
        if os.path.exists(root_dir):
            extensions = set()
            for entry in os.scandir(root_dir):
                if entry.is_file():
                    filename, file_extension = os.path.splitext(entry.name)
                    extensions.add(str(file_extension[1:]).lower())
                    self.CCC += 1
                    self.text_label.SetLabel(str(self.CCC))
                elif entry.is_dir():
                    extensions.update(self.get_all_file_extensions(entry.path))
            return extensions

    def get_allext(self,event):
        self.progress_bar.SetValue(0)
        doit = False
        path = self.path_combox.GetValue()
        if path.startswith('\\'):
            dlg = wx.MessageDialog(self, "确定要重新获取全部文件类型吗？", "[获取文件类型]",
                                   wx.YES_NO|wx.YES_DEFAULT|wx.ICON_INFORMATION)
            result = dlg.ShowModal()
            dlg.Destroy()
            if result == wx.ID_YES:
                doit = True
        else:
            doit = True
        if doit:
            self.text_label.SetLabel('正在查找文件:')
            self.CCC = 0
            ext = '; '.join(self.get_all_file_extensions(self.path_combox.GetValue()))
            self.ext_filter.SetValue(ext)
            # self.on_extfilter_saver(self)
            self.save_extfilter_all()

    def on_extfilter_saver(self, event):
        global username
        pp = self.getNoSlashPath(self.path_combox.GetValue())
        conf.set('set_DS', f'EXTFILTER_{pp}_{username}', self.ext_filter.GetValue())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        if self.check_redis(s_host, ''):
            self.r.hset('SETTINGS', f'EXTFILTER_{pp}_{username}', self.ext_filter.GetValue())
    def on_folfilter_saver(self, event):
        global username
        pp = self.getNoSlashPath(self.path_combox.GetValue())
        conf.set('set_DS', f'FOLFILTER_{pp}_{username}', self.fol_filter.GetValue())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
        if self.check_redis(s_host, ''):
            self.r.hset('SETTINGS', f'FOLFILTER_{pp}_{username}', self.fol_filter.GetValue())

    def check_extfilter(self,event):
        global username
        if self.search_fol_chk.GetValue():
            self.list.Hide()
            self.ext_filter.Show()
            self.fol_filter.Show()
            self.ext_getall_btn.Show()
            self.ext_saveext_btn.Show()
            self.ext_read_btn.Show()
            # self.ext_readall_btn.Show()
            pp = self.getNoSlashPath(self.path_combox.GetValue())
            extstring = ''
            if conf.has_option('set_DS', f'All_EXTFILTER_{pp}_{username}'):
                extstring = conf.get('set_DS', f'All_EXTFILTER_{pp}_{username}')
            if extstring != '':
                self.ext_readall_btn.Show()
            self.v_sizer.Add(self.ext_sizer, proportion=3, flag=wx.EXPAND|wx.LEFT, border=1)
        else:
            self.list.Show()
            self.v_sizer.Detach(self.ext_sizer)
            self.ext_filter.Hide()
            self.fol_filter.Hide()
            self.ext_getall_btn.Hide()
            self.ext_saveext_btn.Hide()
            self.ext_read_btn.Hide()
            self.ext_readall_btn.Hide()
        self.v_sizer.Layout()
        self.panel.Layout()
            
    def edit_ip(self,event):
        def callback(value):    #输出副窗口控件的值（[确定]按钮实现功能函数）
            global s_host
            conf.set('set_DS', 'HOST', value)
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.get_Data_list(self,value)
            self.ipshow.SetLabel(value)
            s_host = value
        second_frame = MySecondaryDialog(self, '设置服务器IP','输入数据库服务器的 IP 地址：', True, 'nopas', callback)
        second_frame.Show() #显示副窗口
        second_frame.ShowModal()    #锁定主窗口
        self.panel.Layout()
    def posswer(self,event):
        def callback(value):    #输出副窗口控件的值（[确定]按钮实现功能函数）
            if value == 'paswer':
                self.GetTextToData(self)
            else:
                self.text_label.SetLabel('<密码错误>')
        second_frame = MySecondaryDialog(self, '导入数据库','输入管理员密码：', True,'passwer', callback)
        second_frame.Show() #显示副窗口
        second_frame.ShowModal()    #锁定主窗口


    def on_open_secondary_window(self, title, msg, show, pas, fun): # ("窗口标题", '提示信息')
        # 创建副对话框的实例并显示为模态（锁定主窗口直到副窗口关闭）
        secondary_dialog = MySecondaryDialog(self, title, msg, show, pas, fun)
        secondary_dialog.ShowModal()
        secondary_dialog.Destroy()  # 关闭副对话框

    def FindTxt(self):
        path = self.path_combox.GetValue()
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

    def convet_time(self,ctime):
        ctime_datetime = ctime + (3600 * 8)  # Convert to your local timezone
        return time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(ctime_datetime))

    def Sizeofsize(self, sNum):
        ns = str(sNum) + ' B'
        if int(sNum) > 1024:
            kNum = int(sNum) / 1024
            ns = str(round(kNum, 2)) + ' K'
            if kNum > 1024:
                mNum = kNum / 1024
                ns = str(round(mNum, 2)) + ' M'
                if mNum > 1024:
                    gNum = mNum / 1024
                    ns = str(round(gNum, 3)) + ' G'
        return ns

    def ignoreFile(self, FCT='', PPP=''):
        if FCT != '':
            IgnoreFo = [e.strip() for e in FCT.split(';')]
            for i in IgnoreFo:
                if PPP == ('.'+i.upper()) or PPP == ('.'+i.lower()):
                    return True

    def ignoreFolder(self,PPP=''):
        fol = self.fol_filter.GetValue()
        if fol != '':
            IgnoreFo = [f.strip() for f in fol.split(';')]
            for i in IgnoreFo:
                if PPP.split('\\')[0]==i:
                    return True #排除文件夹输出True执行continue

    def GetTextToData(self,event):  #导入txt数据 与 文件夹
        if self.check_redis(s_host, ''):
            global username
            if self.search_fol_chk.GetValue():
                dlg = wx.MessageDialog(self, "确定开始导入路径中的文件到数据库？会排除下面用户输入的文件类型\n（注意：原数据将会被替换）", "[导入数据]",
                                       wx.YES_NO | wx.ICON_QUESTION)
                result = dlg.ShowModal()
                dlg.Destroy()
                if result == wx.ID_YES:
                    path = self.path_combox.GetValue()
                    cc = 0
                    if os.path.exists(path):
                        self.r.delete(f'{username}_{path}')
                        self.r.sadd('FS',f'{username}_{path}')
                        for root, dirs, files in os.walk(path):
                            for file_name in files:
                                if self.StartStop:
                                    file_path = os.path.join(root, file_name)
                                    f_subPath = file_path[len(path):]
                                    if self.ignoreFolder(f_subPath): continue  # 目录排除
                                    fl, ex = os.path.splitext(file_name)
                                    if self.ignoreFile(self.ext_filter.GetValue(),ex): continue #类型排除
                                    mtime = self.convet_time(os.path.getmtime(file_path))
                                    FF = "File" if os.path.isfile(file_path) else "Folder"
                                    size = self.Sizeofsize(os.path.getsize(file_path))
                                    a = [mtime, '', file_path, FF, size, '','']
                                    self.r.sadd(f'{username}_{path}', str(a))   #写入数据库
                                    cc += 1
                                    self.text_label.SetLabel(str(cc))
                                    wx.Yield()
                                else:
                                    self.text_label.SetLabel('<搜索停止>')
                                    self.StartStop = True
                                    self.get_Data_list(self, conf.get('set_DS', 'HOST'))
                                    return
                        self.get_Data_list(self, conf.get('set_DS', 'HOST'))
                    else:
                        dlg = wx.MessageDialog(self, "您输入的目录不存在，请输入有效路径", "[预处理文件夹]", wx.ICON_QUESTION)
                        dlg.ShowModal()
                        dlg.Destroy()
            else:
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
                                path = self.path_combox.GetValue()
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
                                    self.r.delete(keyN) #如果文件存在集里则清空，便于写入新元素
                                    proc = 0
                                    # ffc = self.get_line_count(fp)  # 获取文本总行数
                                    # self.progress_bar.SetRange(ffc)
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
                                                    self.text_label.SetLabel(str(proc))
                                                    wx.Yield()
                                                    # self.progress_bar.SetValue(proc)
                        # 写入数据文本(F:文件名)→包含数据数量
                        #             self.r.set(f'F:{keyN}', str(proc))
                        # 记录总导入文件数（用于循环读取）
                        #         self.r.set('FC', str(scount))
                        #         self.text_label.SetLabel('(导入完成)')
                                dlg = wx.MessageDialog(self, "导入工作完成。", "[完成]", wx.OK|wx.ICON_INFORMATION)
                                dlg.ShowModal()
                                dlg.Destroy()
                                self.get_Data_list(self,conf.get('set_DS', 'HOST'))
                else:
                    dlg = wx.MessageDialog(self, "未设置搜索关键字，输入要检查路径关键字，避免导入无用数据。", "[设置搜索关键字]", wx.ICON_QUESTION)
                    dlg.ShowModal()
                    dlg.Destroy()

    def on_comb_sel(self,event):
        conf.set('search_text', 'current', event.GetString())
        conf.write(open(setPath, 'w+', encoding="utf-8"))
    def on_comb_ds_return(self, event): #搜索
        # global search_count
        self.search_Data_list(self)
        if search_count:
            if conf.has_option('search_text', 'current'):
                oldt = conf.get('search_text', 'current')
            else: oldt = ''
            path = self.combox_S.GetValue().strip()
            if path != '' and oldt != path:
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

    def getNoSlashPath(self, pp):
        outs = pp.replace(':','').replace('\\','')  # 获取项目路径去除冒号与斜杠文本
        fist = outs[0:1].lower()
        return fist+outs[1:]

    def on_comb_return(self, event):    #路径下来列表事件
        global username
        path = self.path_combox.GetValue()
        if os.path.exists(path):
            pp = self.getNoSlashPath(self.path_combox.GetValue())
            if self.search_fol_chk.GetValue():
                try:
                    self.ext_filter.SetValue(conf.get('set_DS', f'EXTFILTER_{pp}_{username}'))
                    self.fol_filter.SetValue(conf.get('set_DS', f'FOLFILTER_{pp}_{username}'))
                except:
                    self.ext_filter.SetValue('')
                    self.fol_filter.SetValue('')

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
                    self.path_combox.Append(path)
            else:
                conf.set('set_DS', 'path_count', '1')
                conf.set('PATH_DS', '0', path)
                self.path_combox.Append(path)
            conf.set('PATH_DS', 'current', path)
            conf.write(open(setPath, 'w+', encoding="utf-8"))
            self.path_combox.SetValue(path)
            self.FindTxt()
            if self.search_fol_chk.GetValue():
                extstring = ''
                if conf.has_option('set_DS', f'All_EXTFILTER_{pp}_{username}'):
                    extstring = conf.get('set_DS', f'All_EXTFILTER_{pp}_{username}')
                if extstring != '':
                    self.ext_readall_btn.Show()
                else:
                    self.ext_readall_btn.Hide()
                self.panel.Layout()
    #
    def get_line_count(self,file_path):
        line_count = 0
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as file:
                for line in file:
                    if self.combox_S.GetValue() in line:
                        if 'Event: read' not in line and 'Thumbs.db' not in line:
                            line_count+=1
        return line_count

#刷新数据库内容到列表2
    def get_Data_list(self,event,value):
        if self.check_redis(value, ''):
            dbc = self.r.dbsize()   #获取当前库数据数量
            if dbc > 0:
                getAF = self.r.smembers('FS')
                if self.r.scard('FS') > 0:
                    self.list_2.Clear()
                    for F in getAF: # F从0开始
                        F = F.decode('utf-8')
                        if '\\' in F:
                            nf = str(F).replace('\\', '!')
                        else:
                            nf = F
                        if ':' in nf:
                            nf = nf.replace(':', '=')
                        if os.path.exists(f'{nf}.json'):
                            jj = '(存档)'
                        else:
                            jj = ''
                        if F in R_Data:
                            rr = '【缓存】'
                        else:
                            rr = ''
                        if self.r.exists(F):
                            st = self.r.get(f'{F}>ST')
                            if st is not None:  #注意：在对返回的值进行转换为 UTF-8 字符串之前，你需要检查是否为 None。
                                st = st.decode('utf-8')
                            fnn = self.r.scard(F)
                            self.list_2.Append(f'{F} → 数量:{fnn} <{st}>{jj}{rr}')
                        else:
                            self.r.srem('FS',F) #删除FS中的数据成员
                    self.text_label.SetLabel('(数据库刷新)')
                    self.panel.Layout()
                    self.resel_list2()
        else:
            self.list_2.Clear()

    def up_Data_sel(self,event,value):
        if self.check_redis(value, ''):
            dbc = self.r.dbsize()   #获取当前库数据数量
            if dbc > 0:
                selected_indices = self.list_2.GetSelections()
                if selected_indices:
                    selected_items = [self.list_2.GetString(index) for index in selected_indices]
                    scount = len(selected_items)
                    if scount > 0:

                        getAF = self.r.smembers('FS')
                        if self.r.scard('FS') > 0:
                            global R_Data
                            temp_Data = {}
                            self.list_2.Clear()
                            for F in getAF: # F从0开始
                                F = F.decode('utf-8')
                                if self.r.exists(F):
                                    st = self.r.get(f'{F}>ST')
                                    if st is not None:  #注意：在对返回的值进行转换为 UTF-8 字符串之前，你需要检查是否为 None。
                                        st = st.decode('utf-8')
                                    fnn = self.r.scard(F)
                                    temp_Data[F] = self.r.smembers(F)
                                    self.list_2.Append(f'{F} → 数量:{fnn} <{st}>')
                                else:
                                    self.r.srem('FS',F) #删除FS中的数据成员
                            self.text_label.SetLabel('(数据库刷新)')
                            R_Data.update(temp_Data)    #更新全局变量预读取数据
                            AEsize = self.Sizeofsize(sys.getsizeof(R_Data))
                            self.member_use.SetLabel(f'[ : {AEsize}]')
        else:
            self.list_2.Clear()


    def filter_search(self,event):
        alldata = len(self.data)
        if alldata > 0:
            gnum = self.grid_out.GetNumberRows()  # 删除所有行↓
            if gnum > 0:
                for i in range(gnum):
                    self.grid_out.DeleteRows(0)  # 根据总行数循环删除第一行↑
            row = 0
            self.progress_bar.SetValue(0)
            self.progress_bar.SetRange(alldata)
            pr = 0
            for m in self.data:
                datas = eval(str(m))
                if self.comb_edits.GetValue() == '<All>' or self.comb_edits.GetValue() == datas[1]:
                    if self.comb_types.GetValue() == '<All>' or self.comb_types.GetValue() == datas[3]:
                        if self.comb_users.GetValue() == '<All>' or self.comb_users.GetValue() == datas[5]:
                            col = 0
                            self.grid_out.AppendRows()  # 表格逐一添加新行
                            for d in datas:
                                if col == 5 and self.r.hexists('USERS', d):
                                    d = self.r.hget('USERS', d)
                                self.grid_out.SetCellValue(row, col, d)
                                self.grid_out.SetCellBackgroundColour(row, 1, wx.Colour(255, 210, 230))
                                self.grid_out.SetCellBackgroundColour(row, 3, wx.Colour(255, 240, 190))
                                self.grid_out.SetCellBackgroundColour(row, 5, wx.Colour(225, 250, 240))
                                col += 1
                            row += 1
                            pr+=1
                            # wx.Yield()
                pr+=1
                self.progress_bar.SetValue(pr)
            self.grid_out.AutoSizeColumns()
            self.grid_out.Scroll(0, pr)
            screen_width = wx.Display(0).GetGeometry().GetWidth()  # 获取主显示器宽度
            w = sum(self.grid_out.GetColSize(col) for col in range(self.grid_out.GetNumberCols())) + 130  # 获取Grid总宽度
            if w > screen_width:
                w = screen_width
            if w < 1052: w = 1052
            self.SetSize(wx.Size(w, self.GetSize()[1]))  # 设置主窗口大小
            self.sizer.Layout()

    def Esc_Stop(self,event):
        if event.GetKeyCode() == wx.WXK_ESCAPE:
            self.StartStop = False
        event.Skip()

    def del_MemData(self,event):
        R_Data.clear()
        self.member_use.SetLabel(f'[0 : 0]')
        self.panel.Layout()
        dlg = wx.MessageDialog(self, "缓存已删除", "[删除缓存]", wx.OK | wx.ICON_INFORMATION)
        dlg.ShowModal()
        dlg.Destroy()
    def save_LocalData(self, event):
        if self.check_redis(conf.get('set_DS', 'HOST'),''):
            dlg = wx.MessageDialog(self, "确定保存选择的数据库存档吗？保存本地存档可以大幅加快搜索速度。", "[本地存档]",
                                   wx.YES_NO | wx.ICON_QUESTION)
            result = dlg.ShowModal()
            dlg.Destroy()
            if result == wx.ID_YES:
                selected_indices = self.list_2.GetSelections()
                if selected_indices:
                    selected_items = [self.list_2.GetString(index) for index in selected_indices]
                    scount = len(selected_items)
                    if scount > 0:
                        self.text_label.SetLabel('正在创建存档:')
                        for p in selected_items:
                            self.progress_bar.SetValue(0)
                            pp = str(p).split(' → ')[0]
                            if '\\' in pp:
                                npp = pp.replace('\\', '!')
                            else:
                                npp = pp
                            if ':' in npp:
                                npp = npp.replace(':','=')
                            print(npp)
                            self.progress_bar.SetRange(self.r.scard(pp))
                            pr = 0
                            redis_s = self.r.smembers(pp)
                            R_Data[pp] = redis_s  # 获取所有的member成员
                            aaa = []
                            for i in redis_s:
                                aaa.append(i.decode("utf-8"))
                                pr += 1
                                self.progress_bar.SetValue(pr)
                            wx.Yield()
                            with open(rf"{npp}.json", "w") as json_file:
                                json.dump(aaa, json_file)
                        self.text_label.SetLabel('(创建存档完成)')
                        self.member_use.SetLabel(f'[{len(R_Data)} : **]')
                        self.panel.Layout()
                        self.get_Data_list(self, conf.get('set_DS', 'HOST'))
    def del_LocalData(self,event):
        dlg = wx.MessageDialog(self, "确定删除本地数据库存档吗？删除后在下次启动软件点搜索时会下载服务器上最新的数据。", "[删除存档]",
                               wx.YES_NO | wx.ICON_QUESTION)
        result = dlg.ShowModal()
        dlg.Destroy()
        if result == wx.ID_YES:
            selected_indices = self.list_2.GetSelections()
            if selected_indices:
                selected_items = [self.list_2.GetString(index) for index in selected_indices]
                scount = len(selected_items)
                if scount>0:
                    for p in selected_items:
                        pp = str(p).split(' → ')[0]
                        if '\\' in pp:
                            npp = pp.replace('\\', '!')
                        else:
                            npp = pp
                        if ':' in npp:
                            npp = npp.replace(':', '=')
                        if os.path.exists(f'{npp}.json'):
                            os.remove(f'{npp}.json')
                    self.get_Data_list(self,conf.get('set_DS', 'HOST'))

#搜索数据库到输出到列表Grid
    def search_Data_list(self,event):
        selected_indices = self.list_2.GetSelections()
        if selected_indices:
            selected_items = [self.list_2.GetString(index) for index in selected_indices]
            scount = len(selected_items)
            st = self.combox_S.GetValue()  # 搜索内容
            if st != '':
                if scount > 0:
                    global search_count, R_Data

                    gnum = self.grid_out.GetNumberRows()  # 删除所有行↓
                    if gnum > 0:
                        for i in range(gnum):
                            self.grid_out.DeleteRows(0)  # 根据总行数循环删除第一行↑
                    row = 0 #注意：这个行ID需要在多个数据文件循环外，后面的搜索内容才不会将前面的替换
                    search_count=False
                    pr = 0
                    self.data=[]
                    self.edits_comb = []
                    user = []
                    self.text_label.SetLabel('正在搜索:')
                    self.progress_bar.SetValue(0)
                    for p in selected_items:
                        pp = str(p).split(' → ')[0]
                        if pp not in R_Data:
                    #读取本地数据
                            if '\\' in pp:
                                npp = pp.replace('\\','!')
                            else:
                                npp = pp
                            if os.path.exists(f'{npp}.json'):
                                with open(f'{npp}.json','r') as j_f:
                                    tmp_Data = json.load(j_f)
                                    R_Data[pp] = set(tmp_Data)  #读取json再转换为set字典
                            else:
                                redis_s = self.r.smembers(pp)
                                R_Data[pp] = redis_s #获取所有的member成员
                                # aaa=[]
                                # for i in redis_s:
                                #     aaa.append(i.decode("utf-8"))
                                # with open(f"{npp}.json", "w") as json_file:
                                #     json.dump(aaa, json_file)
                        # self.update_Json(R_Data[pp])
                        getAE = R_Data.get(pp)
                        AES = self.r.scard(pp)
                        self.progress_bar.SetRange(AES)
                        for m in getAE: #遍历set数据类型中的member成员
                            if self.StartStop:
                                if isinstance(m, bytes):
                                    m = m.decode('utf-8')
                                if st in m:
                                    datas = eval(m)  # 转换字符串为数组（将字符串作为代码执行）

                                    self.data.append(datas) #暂存搜索数据，用于过滤显示

                                    col = 0
                                    self.grid_out.AppendRows() #表格逐一添加新行
                                    if datas[5] not in user and datas[5] != '':
                                        user.append(datas[5])
                                    if datas[1] not in self.edits_comb and datas[1] != '':
                                        self.edits_comb.append(datas[1])
                                    for d in datas:
                                        if col == 5 and self.r.hexists('USERS', d):
                                            d = self.r.hget('USERS', d) #读取作者数据

                                        self.grid_out.SetCellValue(row, col, d)
                                        self.grid_out.SetCellBackgroundColour(row, 1, wx.Colour(255, 210, 230))
                                        self.grid_out.SetCellBackgroundColour(row, 3, wx.Colour(255, 240, 190))
                                        self.grid_out.SetCellBackgroundColour(row, 5, wx.Colour(225, 250, 240))
                                        col += 1
                                    row+=1
                                    # wx.Yield()  #等待界面更新后再继续循环
                                pr+=1
                                self.progress_bar.SetValue(pr)
                            else:
                                self.text_label.SetLabel('<搜索停止>')

                                self.comb_edits.Clear()
                                self.comb_edits.Append('<All>')
                                self.comb_edits.AppendItems(self.edits_comb)
                                self.comb_edits.SetValue('<All>')

                                if row > 0:
                                    search_count = True
                                    self.comb_users.Clear()
                                    self.comb_users.Append('<All>')
                                    self.comb_users.AppendItems(user)
                                    self.comb_users.SetValue('<All>')
                                    for u in user:
                                        if not self.r.hexists('USERS', u):  # 判断Hash数据成员是否存在
                                            newname = str(u).split('\\')[1]
                                            self.r.hset('USERS', u, newname)  # 写入Hash数据成员

                                screen_width = wx.Display(0).GetGeometry().GetWidth()  # 获取主显示器宽度
                                w = sum(self.grid_out.GetColSize(col) for col in
                                        range(self.grid_out.GetNumberCols())) + 130  # 获取Grid总宽度
                                if w > screen_width:
                                    w = screen_width
                                if w < 1052: w = 1052
                                self.SetSize(wx.Size(w, self.GetSize()[1]))  # 设置主窗口大小
                                self.sizer.Layout()
                                self.StartStop = True
                                return
                        wx.Yield()
                    AEsize = self.Sizeofsize(sys.getsizeof(getAE))
                    self.member_use.SetLabel(f'[{len(R_Data)} : {AEsize}]')
                    self.panel.Layout()
                    self.text_label.SetLabel('(搜索完成)')
                    self.grid_out.Scroll(0, pr)
                    self.grid_out.AutoSizeColumns()

                    self.comb_edits.Clear()
                    self.comb_edits.Append('<All>')
                    self.comb_edits.AppendItems(self.edits_comb)
                    self.comb_edits.SetValue('<All>')

                    if row > 0:
                        search_count = True
                        self.comb_users.Clear()
                        self.comb_users.Append('<All>')
                        self.comb_users.AppendItems(user)
                        self.comb_users.SetValue('<All>')
                        for u in user:
                            if not self.r.hexists('USERS', u):  #判断Hash数据成员是否存在
                                newname = str(u).split('\\')[1]
                                self.r.hset('USERS', u, newname)    #写入Hash数据成员

                    screen_width = wx.Display(0).GetGeometry().GetWidth()   #获取主显示器宽度
                    w = sum(self.grid_out.GetColSize(col) for col in range(self.grid_out.GetNumberCols()))+130  #获取Grid总宽度
                    if w > screen_width:
                        w = screen_width
                    if w < 1052: w = 1052
                    self.SetSize(wx.Size(w,self.GetSize()[1]))  #设置主窗口大小
                    self.sizer.Layout()
                    self.get_Data_list(self, conf.get('set_DS', 'HOST'))
            else:
                dlg = wx.MessageDialog(self, "未设置搜索关键字，输入要检查路径关键字，避免数据量过大！",
                                       "[设置搜索关键字]",
                                       wx.ICON_QUESTION)
                dlg.ShowModal()
                dlg.Destroy()

    def check_redis(self, host, password):  #检查服务器链接
        self.text_label.SetLabel('正在链接数据库:')
        try:
            t = redis.Redis(host=host, port=6379, password=password, decode_responses=True)
            t.ping()  # 发送一个 ping 命令来检查连接
            self.text_label.SetLabel('(数据库正常)')
            self.r = redis.StrictRedis(host=host, port=6379, db=0)
            return True
        except:
            self.text_label.SetLabel('<服务器异常>')
            return False

app = wx.App(False)
frame = MyFrame(None, "DataSearcher v1.7")
frame.Show()
app.MainLoop()
