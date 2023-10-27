import wx
import wx.grid as gridlib


class MyGridTable(gridlib.GridTableBase):
    def __init__(self, data):
        super().__init__()
        self.data = data

    def GetNumberCols(self):
        return len(self.data[0])  # 返回列数，假设所有行的列数相同

    def GetNumberRows(self):
        return len(self.data)  # 返回行数

    def IsEmptyCell(self, row, col):
        return False  # 告诉表格单元格不是空的

    def GetValue(self, row, col):
        return self.data[row][col]  # 返回数据值

    def GetColLabelValue(self, col):
        # 返回列标签值
        # 假设你有一个列标签的列表，例如 ['Column 1', 'Column 2', ...]
        return f'Column {col}'


app = wx.App(0)
frame = wx.Frame(None, wx.ID_ANY, "Virtual Grid Example")
grid = gridlib.Grid(frame, wx.ID_ANY)
data = [[f"Row {i + 1}, Col {j + 1}" for j in range(5)] for i in range(1000)]  # 生成示例数据
table = MyGridTable(data)
grid.SetTable(table, True)
frame.Show()
app.MainLoop()
