import wx
import wx.grid as gridlib

class MyGridTable(gridlib.GridTableBase):
    def __init__(self, num_rows, num_cols):
        super().__init__()
        self.num_rows = num_rows
        self.num_cols = num_cols
        self.data = [['' for _ in range(num_cols)] for _ in range(num_rows)]

        self.cell_colors = {}  # 用于存储单元格颜色的字典

    def GetNumberRows(self):
        return len(self.data)

    def GetNumberCols(self):
        return len(self.data[0]) if self.data else 0

    def GetValue(self, row, col):
        return self.data[row][col]

    def SetValue(self, row, col, value):
        self.data[row][col] = value

    def AppendRows(self, numRows=1):
        numCols = self.GetNumberCols()
        for _ in range(numRows):
            empty_row = [''] * numCols
            self.data.append(empty_row)
        return True

    def SetCellColor(self, row, col, color):
        # 设置单元格的颜色
        self.cell_colors[(row, col)] = color

class MyFrame(wx.Frame):
    def __init__(self):
        super().__init__(None, wx.ID_ANY, "动态表格示例", size=(800, 600))
        self.data_table = None
        self.grid = None
        self.panel = wx.Panel(self)
        self.is_virtual = True
        self.num_rows = 3
        self.num_cols = 7
        
        self.create_table()

        toggle_button = wx.Button(self.panel, label="切换表格类型")
        toggle_button.Bind(wx.EVT_BUTTON, self.toggle_table)
        add_row_button = wx.Button(self.panel, label="添加行")
        add_row_button.Bind(wx.EVT_BUTTON, self.add_row)
        set_color_button = wx.Button(self.panel, label="设置颜色")
        set_color_button.Bind(wx.EVT_BUTTON, self.set_color)

        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.grid, 1, wx.EXPAND)
        sizer.Add(toggle_button, 0, wx.ALL, 10)
        sizer.Add(add_row_button, 0, wx.ALL, 10)
        sizer.Add(set_color_button, 0, wx.ALL, 10)
        self.panel.SetSizer(sizer)

    def create_table(self):
        if self.is_virtual:
            self.data_table = MyGridTable(self.num_rows, self.num_cols)
            self.grid = gridlib.Grid(self.panel)
            self.grid.CreateGrid(0, 0)
            self.grid.SetTable(self.data_table, takeOwnership=True)
        else:
            self.grid = gridlib.Grid(self.panel)
            self.grid.CreateGrid(3, 3)
            for row in range(3):
                for col in range(3):
                    self.grid.SetCellValue(row, col, f"Cell ({row}, {col})")

    def toggle_table(self, event):
        if hasattr(self, 'grid'):
            self.grid.Destroy()

        self.is_virtual = not self.is_virtual
        self.create_table()
        self.Layout()
        self.panel.Layout()

    def add_row(self, event):
        if self.is_virtual:
            # 在虚拟表格中，需要调用数据模型的AppendRows方法
            self.data_table.AppendRows(1)
            numRows = self.grid.GetNumberRows()
            self.grid.InsertRows(numRows)
        else:
            # 在非虚拟表格中，可以直接使用AppendRows添加行
            self.grid.AppendRows(1)
        self.Layout()
        self.panel.Layout()

    def set_color(self, event):
        if self.is_virtual:
            # 设置虚拟表格中的单元格颜色
            self.data_table.SetCellColor(1, 1, wx.Colour(255, 0, 0))  # 设置第二行第二列的单元格为红色
            self.grid.ForceRefresh()

if __name__ == "__main__":
    app = wx.App(False)
    frame = MyFrame()
    frame.Show()
    app.MainLoop()
