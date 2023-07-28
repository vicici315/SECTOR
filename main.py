# This is a sample Python script.

# Press Ctrl+F5 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import tkinter as tk

# 创建窗口对象
root = tk.Tk()

# 窗口标题
root.title("MyWin")

# 设置窗口大小及位置
root.geometry("400x200")

def tick(event):
    print(sc.get()) # sc 是Scale控件，get()获取其值

sb = tk.Spinbox(root, from_=1, to=10, format="%.2f")
sb.place(x=10, y=10)
sc = tk.Scale(root, from_=0, to=100, tickinterval=50, command=tick)
sc.place(x=10, y=50)
var = tk.Variable(root)
var.set(["a", "b", "c",'列表3'])
lb = tk.Listbox(root, height=8, listvariable=var)
lb.place(x=200, y=10)


# 进入消息循环
root.mainloop()
