import icondata
import tkinter as tk
from tkinter import messagebox
from tkinter import ttk
import os
from configparser import ConfigParser
import base64
import win32print
import win32api
import subprocess


conf = ConfigParser()
setPath = os.getcwd()+'\\PrinterSetting.ini'
pcount = 0
if os.path.exists(setPath):
    conf.read_file(open(setPath, encoding='utf-8'))
if not conf.has_section('set'):
    conf.add_section('set')
if not conf.has_section('PATH'):
    conf.add_section('PATH')

try:
    pcount=int(conf.get('set','path_count'))
except:
    conf.set('set', 'path_count','0')
conf.write(open(setPath, 'w+', encoding="utf-8"))



class MyWindow:
    def __init__(self):
        super().__init__()
        # 使用max的dotnet即将图标文件转成二进制代码：dotNetConverBase64.ms

        # 创建临时图标文件
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon1']))

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
        root.title("MyTools v1.1")
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
        fff = tk.Frame(root,bg="#8c8c8c")
        fff.pack(fill=tk.BOTH, expand=True)
        # lb的滚动条
        scrollbar = tk.Scrollbar(fff)
        scrollbar.grid(row=0,column=0,sticky='ns')
        # text_out的滚动条
        scrollbar2 = tk.Scrollbar(fff)
        scrollbar2.grid(row=1,column=0,sticky='ns')

        var = tk.Variable(root) #lb列表信息成员
        var.set([])
        lb = tk.Listbox(fff, yscrollcommand=scrollbar.set, height=28, listvariable=var, selectmode=tk.EXTENDED) #传统多选方式(EXTENDED)，单击多选(MULTIPLE)
        # 绑定双击事件
        lb.bind("<Double-Button-1>", on_double_click)
        # lb.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(60, 0))
        # lb.pack(side=tk.LEFT,fill=tk.BOTH,expand=True)
        lb.grid(row=0,column=1,sticky='nswe')

        text_out = tk.Text(fff,yscrollcommand=scrollbar2.set,bg='black',foreground='yellow',wrap=tk.WORD)
        text_out.grid(row=1,column=1,sticky='nsew')

        scrollbar.config(command=lb.yview)  #滚动条控制控件
        scrollbar2.config(command=text_out.yview)
        # lb.place(x=200, y=10) #属性来设置控件的左上角在父容器（通常是窗口或 Frame）中的绝对位置
        fff.grid_columnconfigure(1, weight=1)   #★控制frame中的第几列控件左右按其宽度铺满（第2列listbox铺满）
        # fff.grid_columnconfigure(1, weight=1)
        fff.grid_rowconfigure(0, weight=1)  #★第1行上下铺满
        fff.grid_rowconfigure(1, weight=1)

        # 绑定滚动条的命令，使两个文本窗口的滚动条同步
        # lb['yscrollcommand'] = on_scroll_y
        # text_out['yscrollcommand'] = on_scroll_y
        # lb.grid(row=0, column=0, sticky="nsew")
        # scrollbar.grid(row=0, column=1, sticky="ns")
        # 设置grid()的列权重，使得Listbox在窗口大小改变时能够自动调整宽度
        # root.grid_columnconfigure(0, weight=1)
        # root.grid_rowconfigure(0, weight=1)


        def on_comb_sel(event):
            path=combox.get()
            if os.path.exists(path):
                if path[-1] != '\\': path += '\\'
                PC=int(conf.get('set','path_count'))
                same=True
                if PC>0:
                    for i in range(PC):
                        his=conf.get('PATH',str(i))
                        if path==his: same=False
                    if same:
                        conf.set('PATH',str(PC),path)
                        conf.set('set','path_count',str(PC+1))
                else:
                    conf.set('set', 'path_count', '1')
                    conf.set('PATH', '0', path)
                conf.set('PATH','current',path)
                combox.set(path)
                conf.write(open(setPath, 'w+', encoding="utf-8"))
                FindWold()

        pco = int(conf.get('set', 'path_count'))
        current_values = []
        if pco>0:
            for i in range(pco):
                pp=conf.get('PATH',str(i))
                if os.path.exists(pp):
                    current_values.append(pp)
        combox = ttk.Combobox(root,width=70, values=tuple(current_values))  #下拉列表
        combox.place(x=100,y=10)
        combox.bind('<<ComboboxSelected>>',on_comb_sel)
        combox.bind('<Return>',on_comb_sel)


        combox['values'] = tuple(current_values)
        try:
            combox.set(conf.get('PATH','current'))
        except:
            pass
        def FindWold():
            path=combox.get()
            if os.path.exists(path):
                if path[-1] != '\\': path += '\\'
                lb.delete(0,tk.END) # 清空列表，从索引0到末尾的所有项
                with os.scandir(path.strip()) as files:
                    for f in files:
                        if not f.is_dir():
                            if f.path.endswith('docx'):
                                lb.insert(tk.END,f.name)
                                lb.see(tk.END)
        FindWold()
        def PrintFiles():
            result = messagebox.askyesno("打印", "确认开始对选择的文档进行打印?")
            if result:
                selected_indexes = lb.curselection()
                if selected_indexes:
                    selected_items = [lb.get(index) for index in selected_indexes]
                    path = combox.get()
                    if path[-1] != '\\': path += '\\'
                    for p in selected_items:
                        fp = path+p
                        print_docx(fp)
                        text_out.insert(tk.END,f'\n{p}(打印操作完成)')
                        text_out.see(tk.END)
            else:
                text_out.insert(tk.END,'\n<打印取消>')
                text_out.see(tk.END)

        printicon_file = "temp.png"
        with open(printicon_file, "wb") as f:
            f.write(base64.b64decode(icondata.icons_data['icon2']))
        icon_image = tk.PhotoImage(file=printicon_file)
        btn_print = tk.Button(root,text="打印", image=icon_image,compound=tk.LEFT,height=18,width=70, command=PrintFiles)
        btn_print.place(x=10,y=10)
        os.remove(printicon_file)
        # 创建一个 StringVar 来保存 Entry 的文本内容


# 读取set配置记录



        root.bind("<Configure>", on_win_resize)
        # 进入消息循环
        root.mainloop()



if __name__ == '__main__':
    MyWindow()