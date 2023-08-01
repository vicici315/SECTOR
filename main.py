
import tkinter as tk
from tkinter import messagebox
import os
from configparser import ConfigParser
import base64
import win32print
import win32api
import subprocess

class IconData:
    def __init__(self, name, data):
        self.name = name
        self.data = data

conf = ConfigParser()
setPath = os.getcwd()+'\\PrinterSetting.ini'
if not os.path.exists(setPath):
    conf.add_section('set')
    conf.write(open(setPath, 'w', encoding="utf-8"))
conf.read_file(open(setPath,encoding='utf-8'))


class MyWindow:
    def __init__(self):
        super().__init__()
        # 使用max的dotnet即将图标文件转成二进制代码：dotNetConverBase64.ms
        icon_data = "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if/GxcT/3d3d/9jY2P+WlZP/ZWJe/1BMRf9PTEX/Pjw1/zY0Lf82NC3/NjQt//9/f///f3+H/39/p/9/f//Hx8f/9/f3/4+OjP8wLSn/dXNw/6+urP++vbr/nJuX/29sZ/9mY13/ZmNd/4KAe/98eXT/bWpk/1NPSf9QTEX/YF1X/4OAfP/d3d3/3d3d/9jY2P+RkJD/UE9M/0pHQP9GQjv/QT43/zg1Lv82NC3//39///9/f6f/f3+//39//8fHx//39/f/1NPT/728uf+cm5f/b2xn/2ZjXf9mY13/h4WA/4KAe/98eXT/V1NN/1NPSf9PTEX/TElC/0pGP/9IRD3/SUU//357d//d3d3/3d3d/9jY2P+jo6L/XFta/0dEQP9APDX/Pzw1/zo4Mf//f3///39/v/9/f7//f3//rKyq/5ORjf9mY13/ZmNd/2ZjXf+LiYT/iIWB/398eP9VUkz/VlNN/1NPSf9PTEX/TElC/0pGP/9HRD3/RkI7/0RAOf9CPjj/Pzs0/2hlYP/R0dH/3d3d/93d3f/DwsL/np6d/4B/ff9pZ2P/e3l0//9/f///f3+//39/p/9/f/97eXT/ZmNd/4yKhv+LiYX/iIaC/15bVf9UUkv/TktF/09MRv9PTEX/SUZA/0hEPv9HRD3/RUI7/0RAOf9CPjf/QT02/0E9Nv9APDX/QDw1/0dEPv+PjYn/39/f/93d3f/d3d3/zc3N/7e2tv/hZzv//39///9/f6f/f3+H/39//+ZsSP9ST0n/Yl9Z/15bVP9aV1D/VlNM/1JPSP9PS0X/REA7/0dDPf9ZVlH/PDkz/01ENf+JZy3/lGsn/0xDM/9APDX/QDw1/0A8Nf8/OzT/OjYw/9xeK//cXiv/8PDw/+3t7f/cXiv/3F4r/+ZsSP//f3///39/h/9/f1f/f3//7nNc/1JPSf8mwyP/S2hC/1JPSP9PS0X/TEhC/0lGP/9HQz3/SEAz/7mba//EjTP//60n//+qHf//phP/55YP/3pfM/+Bfnr/uLe0/+fn5v9hXlr/VlRQ/9xeK//cXiv/3F4r/9xeK//cXiv/7nNc//9/f///f39X/39/F/9/f//9fXr/3F8s/1JPSf9PS0X/TEhC/0lGP/9HQzz/RUE6/6F9Qv//uET//7Q6//+xMP/zpij/wYsx/7yfb/+4trT/7+/v//Dw8P/w8PD/8PDw/+jo6P9xbmr/VlRQ/9xeK//cXiv/3F4r/9xfLP/9fXr//39///9/fxcAAAAA/39/u/9/f//jaUL/3F4r/1JPSf9STkj/RUE6/0M/Of9CPjf/QT02/4hqOv+rhET/uqB2/6Cem//v7+//8PDw//Dw8P/w8PD/8PDw//Dw8P/w8PD/8PDw/+jo6P9xbmr/VlRQ/9xeK//cXiv/42lC//9/f///f3+7AAAAAAAAAAD/f39P/39///l7cv/cXy3/3F4r/9xeK/9ST0n/TElC/0tIQf9ST0n/3F4r/9xeK//cXiv/3F4r/8G/vf/w8PD/8PDw//Dw8P/w8PD/8PDw//Dw8P/w8PD/8PDw/9nY1/9aVlH/3F4r/9xfLf/5e3L//39///9/f08AAAAAAAAAAAAAAAD/f3/T/39//+dsSv/cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/8G/vf/w8PD/8PDw//Dw8P/w8PD/6Ojo/8G/vf+KhoL/npuY/9xeK//cXiv/52xK//9/f///f3/TAAAAAAAAAAAAAAAAAAAAAP9/fzv/f3/7/X19/+BlOf/cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/8G/vf/o6Oj/wb+9/5qXk/+em5j/3F4r/9xeK//cXiv/3F4r/+BlOf/9fX3//39/+/9/fzsAAAAAAAAAAAAAAAAAAAAAAAAAAP9/f3f/f3//+3x4/91hMf/cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/56bmP/cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//dYTH/+3x4//9/f///f393AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP9/f6P/f3//+3x4/+BlOf/cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/4GU5//t8eP//f3///39/owAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/39/A/9/f6P/f3///X19/+dsSv/cXy3/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F8t/+dsSv/9fX3//39///9/f6P/f38DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP9/f3v/f3/7/39///l7cv/jaUL/3F8s/9xeK//cXiv/3F4r/9xeK//cXiv/3F4r/9xeK//cXiv/3F8s/+NpQv/5e3L//39///9/f/v/f397AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP9/fzv/f3/P/39///9/f//9fXr/7nNc/+ZsSP/hZzv/32Q2/99kNv/hZzv/5mxI/+5zXP/9fXr//39///9/f///f3/P/39/OwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/f39P/39/u/9/f///f3///39///9/f///f3///39///9/f///f3///39///9/f///f3+7/39/TwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/39/F/9/f1f/f3+H/39/p/9/f7//f3+//39/p/9/f4f/f39X/39/FwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/+AH//+AAf/+AAB//AAAP/AAAA/wAAAP4AAAB8AAAAPAAAADgAAAAYAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAYAAAAHAAAADwAAAA+AAAAfwAAAP8AAAD/wAAD/+AAB//4AB///gB/8="

        icon1 = IconData(name="icon1", data=base64.b64decode(icon_data))
        # 创建临时图标文件
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(icon1.data)

        def on_win_resize(event):
            # frame.config(width=event.width // 2)
            # lb.config(width=event.width // 1 , height=event.height // 2)
            fff.config(width=event.width , height=event.height)
            fff.pack_configure(padx=(100,9), pady=(50,10)) #使用padx传入两个值来左右偏移

        def print_docx(filename):
            # 获取默认打印机名称
            open(filename, "r")
            win32api.ShellExecute(
                0,
                "print",
                filename,
                '/d:"%s"' % win32print.GetDefaultPrinter(),
                ".",
                1  # 1 后台运行；0 显示窗口
            )


        # 创建窗口对象
        root = tk.Tk()

        # 窗口标题
        root.title("MyTools v1.0")
        # 设置标题图标
        root.iconbitmap(default=temp_icon_file)
        # 删除临时图标文件
        os.remove(temp_icon_file)

        # 设置窗口大小及位置
        root.geometry("1100x700")


        # def tick(event):
        #     print(sc.get()) # sc 是Scale控件，get()获取其值
        def on_double_click(event):
            selected_indexes = lb.curselection()
            if selected_indexes:
                selected_items = [lb.get(index) for index in selected_indexes]
                if len(selected_items) == 1:
                    filep = text_path.get()+selected_items[0]
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
        def on_path_changed(*args):
            path = text_path.get()
            if os.path.exists(path):
                conf.set('set','text_path',path)
                conf.write(open(setPath, 'w+', encoding="utf-8"))
                FindWold()
        # sb = tk.Spinbox(root, from_=1, to=10, format="%.2f")
        # sb.place(x=100, y=10)
        # sc = tk.Scale(root, from_=0, to=100, tickinterval=50, command=tick) #垂直滑动数值控件
        # sc.place(x=10, y=50)

        # frame面板用于放置 Listbox+滚动条 与 Text+滚动条
        fff = tk.Frame(root,bg="#8c8c8c")
        fff.pack(fill=tk.BOTH, expand=True)
        # lb的滚动条
        scrollbar = tk.Scrollbar(fff)
        scrollbar.grid(row=0,column=1,sticky='ns')
        # text_out的滚动条
        scrollbar2 = tk.Scrollbar(fff)
        scrollbar2.grid(row=1,column=1,sticky='ns')

        var = tk.Variable(root) #lb列表信息成员
        var.set([])
        lb = tk.Listbox(fff, yscrollcommand=scrollbar.set, height=28, listvariable=var, selectmode=tk.EXTENDED) #传统多选方式(EXTENDED)，单击多选(MULTIPLE)
        # 绑定双击事件
        lb.bind("<Double-Button-1>", on_double_click)
        # lb.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(60, 0))
        # lb.pack(side=tk.LEFT,fill=tk.BOTH,expand=True)
        lb.grid(row=0,column=0,sticky='nswe')


        text_out = tk.Text(fff,yscrollcommand=scrollbar2.set,bg='black',foreground='yellow',wrap=tk.WORD)
        text_out.grid(row=1,column=0,sticky='nsew')

        scrollbar.config(command=lb.yview)  #滚动条控制控件
        scrollbar2.config(command=text_out.yview)
        # lb.place(x=200, y=10) #属性来设置控件的左上角在父容器（通常是窗口或 Frame）中的绝对位置
        fff.grid_columnconfigure(0, weight=1)   #控制frame中的控件左右铺满
        # fff.grid_columnconfigure(1, weight=1)
        fff.grid_rowconfigure(0, weight=1)
        fff.grid_rowconfigure(1, weight=1)

        # 绑定滚动条的命令，使两个文本窗口的滚动条同步
        # lb['yscrollcommand'] = on_scroll_y
        # text_out['yscrollcommand'] = on_scroll_y
        # lb.grid(row=0, column=0, sticky="nsew")
        # scrollbar.grid(row=0, column=1, sticky="ns")
        # 设置grid()的列权重，使得Listbox在窗口大小改变时能够自动调整宽度
        # root.grid_columnconfigure(0, weight=1)
        # root.grid_rowconfigure(0, weight=1)
        entry_var = tk.StringVar()
        text_path = tk.Entry(root,width=70,textvariable=entry_var)
        # text_path.bind("<<Modified>>", on_path_changed)
        text_path.place(x=100,y=10)
        # 绑定 StringVar 的 trace 方法，跟踪 Entry 文本的变化
        entry_var.trace_add("write", on_path_changed)

        def FindWold():
            path=text_path.get()
            # PFS = []
            if os.path.exists(path):
                lb.delete(0,tk.END) # 清空列表，从索引0到末尾的所有项
                with os.scandir(path) as files:
                    for f in files:
                        if not f.is_dir():
                            if f.path.endswith('docx'):
                                lb.insert(tk.END,f.name)
                                # PFS.append(f.path)
                                lb.see(tk.END)
            # return PFS

        def PrintFiles():
            result = messagebox.askyesno("打印", "确认开始对选择的文档进行打印?")
            if result:
                selected_indexes = lb.curselection()
                if selected_indexes:
                    selected_items = [lb.get(index) for index in selected_indexes]
                    for p in selected_items:
                        fp = text_path.get()+p
                        print_docx(fp)
                        text_out.insert(tk.END,f'\n{p}(打印完成)')
                        text_out.see(tk.END)
            else:
                text_out.insert(tk.END,'\n<打印取消>')
                text_out.see(tk.END)

        btn_print = tk.Button(root,text="打印",height=1,width=10, command=PrintFiles)
        btn_print.place(x=10,y=10)

        # 创建一个 StringVar 来保存 Entry 的文本内容
        def ReadTxtFile(file):
            if os.path.exists(file):
                cun=0
                FF = open(file, 'r', encoding='utf-8')
                for f in  FF:
                    if cun == 100: return
                    # print(f.readline(), end='')
                    lb.insert(tk.END, f)
                    cun+=1
                FF.close()
        # ReadTxtFile('2023-07-24_2023-07-28.TXT')

# 读取set配置记录
        try:
            text_path.insert(0,conf.get('set', 'text_path'))
            FindWold()
        except:
            print('Not Path set.')


        root.bind("<Configure>", on_win_resize)
        # 进入消息循环
        root.mainloop()



if __name__ == '__main__':
    MyWindow()