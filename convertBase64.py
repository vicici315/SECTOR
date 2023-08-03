# 将图标转成二进制代码
import threading
import icondata
from PIL import Image, ImageTk

import tkinter as tk
from tkinter import scrolledtext
from tkinter import ttk
import os
from configparser import ConfigParser
import base64
import subprocess


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



class MyWindow:
    def __init__(self):
        super().__init__()
        # 使用max的dotnet即将图标文件转成二进制代码：dotNetConverBase64.ms
        # 创建临时图标文件
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon_b64']))

        def Sizeofsize(sNum):
            ns = str(sNum) + ' B'
            if int(sNum) > 1024:
                kNum = int(sNum) / 1024
                ns = str(round(kNum, 2)) + ' K'
                if kNum > 1024:
                    mNum = kNum / 1024
                    ns = str(round(mNum, 2)) + ' M'
            return ns
        def on_win_resize(event):
            # frame.config(width=event.width // 2)
            # lb.config(width=event.width // 1 , height=event.height // 2)
            fff.config(width=event.width , height=event.height)
            fff.pack_configure(padx=(100,9), pady=(50,10)) #使用padx传入两个值来左右偏移

        def convertB(filename):
            with open(filename, 'rb') as file:
                icon_binary = file.read()
            # 将二进制数据进行 Base64 编码
            icon_base64 = base64.b64encode(icon_binary)
            # 将 Base64 编码转换为字符串形式
            return icon_base64.decode('utf-8')


        # 创建窗口对象
        root = tk.Tk()

        # 窗口标题
        root.title("ConvertB64 v1.3")
        # 设置标题图标
        root.iconbitmap(default=temp_icon_file)

        # 设置窗口大小及位置
        root.geometry("1100x900")


        # def tick(event):
        #     print(sc.get()) # sc 是Scale控件，get()获取其值
        def on_double_click(event):
            selected_indexes = lb.curselection()
            if selected_indexes:
                selected_items = [lb.get(index) for index in selected_indexes]
                if len(selected_items) == 1:
                    path = combox.get()
                    if path[-1] != '\\': path += '\\'
                    filep = path+selected_items[0]
                    try:
                        # 针对不同操作系统，可以使用不同的命令来打开文档
                        if os.name == "nt":  # Windows
                            subprocess.Popen(["start", filep], shell=True)
                        elif os.name == "posix":  # macOS and Linux
                            subprocess.Popen(["xdg-open", filep])
                        else:
                            text_out.insert(tk.END,"\n<不支持的操作系统>")
                            text_out.see(tk.END)
                    except Exception as e:
                        text_out.insert(tk.END,f"\n打开文件错误: {e}")

                    # print("Selected items:{}".format(lb.get(index)))

        # sb = tk.Spinbox(root, from_=1, to=10, format="%.2f")
        # sb.place(x=100, y=10)
        # sc = tk.Scale(root, from_=0, to=100, tickinterval=50, command=tick) #垂直滑动数值控件
        # sc.place(x=10, y=50)


        # frame面板用于放置 Listbox+滚动条 与 Text+滚动条
        fff = tk.Frame(root,bg="black")
        fff.pack(fill=tk.BOTH, expand=True)
        # lb的滚动条
        scrollbar = tk.Scrollbar(fff)
        scrollbar.grid(row=0,column=0,sticky='ns')
        # text_out的滚动条
        # scrollbar2 = tk.Scrollbar(fff)
        # scrollbar2.grid(row=1,column=0,sticky='ns')

        var = tk.Variable(root) #lb列表信息成员
        var.set([])
        lb = tk.Listbox(fff, yscrollcommand=scrollbar.set, listvariable=var, selectmode=tk.EXTENDED) #传统多选方式(EXTENDED)，单击多选(MULTIPLE)
        # 绑定双击事件
        lb.bind("<Double-Button-1>", on_double_click)
        # lb.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(60, 0))
        # lb.pack(side=tk.LEFT,fill=tk.BOTH,expand=True)
        lb.grid(row=0,column=1,sticky='nswe')

        text_out = scrolledtext.ScrolledText(fff, height=52,bg='black',foreground='gray',wrap=tk.WORD)
        text_out.grid(row=1,column=1,sticky='nsew')

        scrollbar.config(command=lb.yview)  #滚动条控制控件
        # scrollbar2.config(command=text_out.yview)
        # lb.place(x=200, y=10) #属性来设置控件的左上角在父容器（通常是窗口或 Frame）中的绝对位置
        fff.grid_columnconfigure(1, weight=1)   #★控制frame中的第几列控件左右按其宽度铺满（第2列listbox铺满）
        # fff.grid_columnconfigure(1, weight=1)
        fff.grid_rowconfigure(0, weight=1)  #★第1行上下铺满
        fff.grid_rowconfigure(1, weight=1)



        def on_comb_return(event):
            path=combox.get()
            if os.path.exists(path):
                if path[-1] != '\\': path += '\\'
                PC=int(conf.get('set2','path_count'))
                same=True
                if PC>0:
                    for i in range(PC):
                        his=conf.get('PATHicon',str(i))
                        if path==his: same=False
                    if same:
                        conf.set('PATHicon',str(PC),path)
                        conf.set('set2','path_count',str(PC+1))
                else:
                    conf.set('set2', 'path_count', '1')
                    conf.set('PATHicon', '0', path)
                conf.set('PATHicon','current',path)
                combox.set(path)
                conf.write(open(setPath, 'w+', encoding="utf-8"))
                FindIcon()

        pco = int(conf.get('set2', 'path_count'))
        current_values = []
        if pco>0:
            for i in range(pco):
                pp=conf.get('PATHicon',str(i))
                if os.path.exists(pp):
                    current_values.append(pp)
        combox = ttk.Combobox(root,width=70, values=tuple(current_values))  #下拉列表
        combox.place(x=100,y=10)
        combox.bind('<<ComboboxSelected>>',on_comb_return)
        combox.bind('<Return>',on_comb_return)


        combox['values'] = tuple(current_values)
        try:
            combox.set(conf.get('PATHicon','current'))
        except:
            combox.set(os.getcwd())

        def DoConvert():
            selected_indexes = lb.curselection()
            if selected_indexes:
                selected_items = [lb.get(index) for index in selected_indexes]
                path = combox.get()
                if path[-1] != '\\': path += '\\'
                for p in selected_items:
                    pp = str(p).split(' → ')
                    fp = path + pp[0]
                    ss = os.path.getsize(fp)
                    if ss < 124000:
                        b = convertB(fp)
                        text_out.insert(tk.END, f'\n({pp[0]}) 二进制代码：\n')
                        text_out.insert(tk.END, f'{b}\n')
                    else:
                        text_out.insert(tk.END, f'\n{p} <图标文件限制 121k 内>\n')
                    text_out.see(tk.END)
        def DoConver_thread():
            thread = threading.Thread(target=DoConvert)
            thread.start()
        # 使用ico作为按钮图标
        icon_image = Image.open(temp_icon_file)
        icon_image = icon_image.resize((32, 22))    #必须
        icon_photo = ImageTk.PhotoImage(icon_image)
        btn_print = tk.Button(root,text="转换", image=icon_photo,compound=tk.LEFT,height=18,width=70, command=DoConver_thread)
        btn_print.place(x=10,y=10)
        # 删除临时图标文件
        os.remove(temp_icon_file)
        def FindIcon():
            path=combox.get()
            if os.path.exists(path):
                if path[-1] != '\\': path += '\\'
                lb.delete(0,tk.END) # 清空列表，从索引0到末尾的所有项
                with os.scandir(path.strip()) as files:
                    for f in files:
                        if not f.is_dir():
                            if f.path.endswith('ico') or f.path.endswith('png'):
                                siz = Sizeofsize(os.path.getsize(f.path))
                                lb.insert(tk.END, f'{f.name} → {siz}')
                                lb.see(tk.END)
        FindIcon()


        # 创建一个 StringVar 来保存 Entry 的文本内容


# 读取set配置记录



        root.bind("<Configure>", on_win_resize)
        # 进入消息循环
        root.mainloop()



if __name__ == '__main__':
    MyWindow()