import wx
import wx.grid as gridlib


class MyGridTable(gridlib.GridTableBase):
    def __init__(self, data):
        super().__init__()
        self.data = data    # 作为表格的数据源，它存储了表格中的所有数据，并在需要时被 MyGridTable 类使用来提供表格所需的数据。

    def GetNumberRows(self):
        return len(self.data)

    def GetNumberCols(self):
        if len(self.data) > 0:
            return len(self.data[0])
        else:
            return 0
# 通过返回 len(self.data) 可以获得表格的行数，这决定了表格中有多少行数据。在 GetNumberCols 方法中，
# 通过检查 self.data 中第一个内层列表的长度来获取表格的列数，从而决定了表格有多少列。
    def IsEmptyCell(self, row, col):
        return False
# 根据传入的行和列索引，通过访问 self.data 来获取相应位置的数据。在示例中，我们假设 self.data 中的每个元素都是字符串类型，
# 所以使用 str(self.data[row][col]) 将数据转换为字符串。
    def GetValue(self, row, col):
        return str(self.data[row][col])
# 将新的值赋给 self.data[row][col]，从而实现更新表格数据。
    def SetValue(self, row, col, value):
        self.data[row][col] = value


class MyFrame(wx.Frame):
    def __init__(self, data):
        super().__init__(None, wx.ID_ANY, "虚拟表格示例", size=(400, 300))

        panel = wx.Panel(self)
        grid = gridlib.Grid(panel)
        grid.CreateGrid(len(data), len(data[0]))

        table = MyGridTable(data)
        grid.SetTable(table, True)

        self.data = data
        self.grid = grid

        refresh_button = wx.Button(panel, label="刷新内容")
        refresh_button.Bind(wx.EVT_BUTTON, self.OnRefresh)

        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(grid, 1, wx.EXPAND)
        sizer.Add(refresh_button, 0, wx.ALIGN_CENTER | wx.TOP, border=10)
        panel.SetSizer(sizer)

    def OnRefresh(self, event):
        # 模拟刷新数据
        new_data = [
            ["姓名", "年龄", "城市"],
            ["David", 28, "Chicago"],
            ["Eve", 35, "Boston"],
        ]
        self.data = new_data

        # 清除之前的数据
        table = MyGridTable([])
        self.grid.SetTable(table, True)

        # 设置新的数据
        table = MyGridTable(self.data)
        self.grid.SetTable(table, True)
        self.grid.ForceRefresh()  # 强制刷新
        self.grid.AutoSizeColumns()  # 自动调整列宽


if __name__ == "__main__":
    app = wx.App(False)
    data = [
        ["姓名", "年龄", "城市", 'test'],
        ["Alice", 25, "New York",'abc'],
        ["Bob", 30, "San Francisco",'asdg'],
        ["Charlie", 22, "Los Angeles",'2352'],
    ]
    frame = MyFrame(data)
    frame.Show()
    app.MainLoop()
