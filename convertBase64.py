# 将图标转成二进制代码
import threading

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
        iconDat = 'AAABAAEAICAAAAEAIACoEAAAFgAAACgAAAAgAAAAQAAAAAEAIAAAAAAAgBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/f382/39/WP9/fxgAAAAAAAAAAP9/fw3/f382/39/Nv9/fzb/f38DAAAAAAAAAAD/f38g/39/Wf9/fywAAAAAAAAAAAAAAAD/f382/39/Nv9/fzb/f38RAAAAAAAAAAD/f38v/39/Nv9/fzb/f38YAAAAAAAAAAAAAAAA/39/Zf9/f4//f38U/39/xv9/fx0AAAAA/39/A/9/f0v/f3/w/39/IgAAAAAAAAAA/39/L/9/f7r/f38O/39/pv9/f0wAAAAAAAAAAP9/fyL/f3/q/39/UP9/fwQAAAAAAAAAAP9/fxn/f3/U/39/bf9/fwYAAAAA/39/Av9/fwP/f3/k/39/EgAAAAD/f39t/39/jgAAAAAAAAAA/39/DP9/f98AAAAAAAAAAAAAAAD/f3+q/39/TwAAAAD/f38t/39/zgAAAAAAAAAAAAAAAP9/f8z/f38fAAAAAAAAAAAAAAAAAAAAAP9/f6z/f38/AAAAAAAAAAD/f39L/39/MP9/f9AAAAAAAAAAAP9/fy//f3/RAAAAAAAAAAD/f38M/39/3wAAAAAAAAAAAAAAAP9/f+//f38RAAAAAAAAAAD/f3/t/39/EgAAAAAAAAAA/39/zP9/fx8AAAAAAAAAAAAAAAAAAAAA/39/rP9/fz8AAAAAAAAAAP9/f5D/f39Q/39/swAAAAB/f/9Ci37wb95+n/MAAAAAAAAAAP9/fwz/f3/ff3//I39//zaWfuVD4n6b9X9//yoAAAAAAAAAAP9/f9LJfrFIf3//Nn9//zbefp/XqH3RSwAAAAAAAAAAAAAAAAAAAADnfpW3o37YiH9//1d/f/8M/39/r/9/f1L/f3+xf3//oH9//6qgfdk1on7a/H9//5YAAAAA/39/DP9/f99/f/8hf3//hH9///+2fsf5f3//JgAAAAAAAAAA/39/0dF/rEd/f/9rf3///6V/2O2rfc9IAAAAAAAAAAAAAAAAf3//SIp+8/W5fcFqf3//Zn9//9ztfo+5/39/ONV+qNl/f//1f3//Ev9/fynwfo3cf3//+X9//z3/f38M/39/3wAAAAB/f/8Vf3///+V+mPf/f38LAAAAAAAAAAD/f3/p/39/GQAAAAB/f//0zn6u3f9/fx8AAAAAAAAAAH9//wR/f//hvn6/zv9/fz8AAAAAf3//s6F+2tj/f38HqH7V+YB++7kAAAAA/39/Yf9/f55/f/+/f3//nf9/fwz/f3/fAAAAAH9//xJ/f///3n6dyP9/f0UAAAAA/39/If9/f94AAAAAAAAAAH9///HPfq3d/39/HwAAAAAAAAAAf3//SH9///7ufo60/39/PwAAAAB/f/9fgH78+QAAAACGfvbypX7Xtv9/fwP/f3/C/39/MX9//4mAfvzb/39/f/9/f98AAAAAf3//En9////Cfrhr/39/rQAAAAD/f3+M/39/awAAAAD/f38FgX7799N+qPX/f38fAAAAAAAAAAB/f/+DhH746v9/f9//f38/AAAAAH9//yl/f///f3//BX5+/v6xfsqe/39/av9/fzoAAAAAf3//bH9///X/f38K/39/VgAAAAB/f/8Sf3///39//zH/f39I/39/af9/f1kAAAAAAAAAAAAAAAB+fv3ysX7KiP9/fw8AAAAAAAAAAH9//6N/f/++/39/Qv9/fx4AAAAAf3//DX9///9/f/8Mf3///39//1YAAAAAAAAAAAAAAAB/f/9ff3///wAAAAAAAAAAAAAAAH9//xJ/f///f3//MQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH9///F/f/9RAAAAAAAAAAAAAAAAf3//rH9//7YAAAAAAAAAAAAAAAAAAAAAf3///39//wV/f//9gXz5YP8AAFb/AABb/wAACn9//2x/f//2/wAAKP8AAGn/AAB43x07TX9///9/f/8x/wAAA/8AAFb/AABb/wAACgAAAAAAAAAAf3379LpDh5n/AAB4/wAAPwAAAAB/f/+jhHjxyf8AAGn/AAB4/wAAP39//w1/f///AAAAAH9//+OtUKHI/wAAMP8AABP/AACif3//in9//9cAAAAA/wAARv8AAId/f/8Sf3///39//zH/AACR/wAAMP8AABP/AACiAAAAAAAAAAB/f//xrk+ggf8AAIcAAAAAAAAAAH9//4N/f//e/wAARv8AAIcAAAAAf3//Kn9///8AAAAAg3n0r5xhxO4AAAAAAAAAAP8AAJ+Fd/DNf3//ngAAAAD/AAA//wAAf39//xJ/f///nF69Qv8AAMEAAAAAAAAAAP8AAJ//AAAvAAAAAH9///GrUqZ8/wAAfwAAAAAAAAAAf3//SX9///7WJUpS/wAAfwAAAAB/f/9hf3799gAAAACxS5d+gXz5/H9//xIAAAAA5Rcvh399/P1/f/9BAAAAAP8AAD/lFy+Nf3//IH9////COnRr/wAAmAAAAAAAAAAA/wAAeeMZM3Z/f/8If3//+KtSpnz/AAB/AAAAAAAAAAB/f/8Ff3//5J9evY//AAB/AAAAAH9//7WQbNq7AAAAAP8AAFqbYsbYf3//p39//xeTadTSm2HEzAAAAAAAAAAA/wAAP8syZZ9/f/+2f3///8ozZnr/AACMAAAAAAAAAAD/AABt0ylTk39//6d/f//9q1KmfP8AAH8AAAAAAAAAAAAAAAB/f/9Ngnr26dkkSZV/f/9cf3//4d8ePWsAAAAA/wAAT/0BA5R/f/9Pf3//dL89e53/AABvAAAAAAAAAAD/AAA//wAAfwAAAAB/f/805BgxXP8AAJMAAAAAAAAAAP8AAHL/AABvAAAAAH9//yjSK1dV/wAAfwAAAAAAAAAAAAAAAAAAAADEOHJgsE2at39//2V/f/8S/wAATwAAAAD/AAAh/wAAtgAAAAAAAAAA/wAAkP8AAEUAAAAAAAAAAP8AAD//AAB/AAAAAAAAAAD/AAAh/wAAtgAAAAAAAAAA/wAAkP8AAEUAAAAAAAAAAP8AAD//AAB/AAAAAAAAAAAAAAAAAAAAAP8AAD//AAB/AAAAAAAAAAD/AAAhAAAAAAAAAAD/AACw/wAAFf8AAAL/AAC0/wAABQAAAAD/AAAo/wAAfv8AAH8AAAAAAAAAAAAAAAD/AACw/wAAFf8AAAL/AAC0/wAABQAAAAD/AAAo/wAAfv8AAH8AAAAAAAAAAAAAAAD/AAAo/wAAfv8AAH8AAAAAAAAAAAAAAAAAAAAAAAAAAP8AABb/AABy/wAAaf8AACcAAAAAAAAAAAAAAAD/AAAc/wAATQAAAAAAAAAAAAAAAP8AABb/AABy/wAAaf8AACcAAAAAAAAAAAAAAAD/AAAc/wAATQAAAAAAAAAAAAAAAAAAAAD/AAAc/wAATQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA///////////////////////////////////////////GDHDDghgwwhM5OeYzOZnmIwGB4AEBgcAAIZGEECExhIAhIYQEIHGEHOPzngAAMICAgDGEmIGRhIiBgYSBgYHAgZGR4JmZmebBHBHHw5w55/////////////////////8='
        # 创建临时图标文件
        temp_icon_file = "temp.ico"
        with open(temp_icon_file, "wb") as f:
            f.write(base64.b64decode(iconDat))

        def Sizeofsize(sNum):
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



        def on_comb_sel(event):
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
        combox.bind('<<ComboboxSelected>>',on_comb_sel)
        combox.bind('<Return>',on_comb_sel)


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
        icon_image = Image.open(temp_icon_file)
        icon_image = icon_image.resize((32, 32))    #必须
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