import wx
import wx.grid as gridlib

class MyGridTable(gridlib.GridTableBase):
    def __init__(self, data):
        super().__init__()
        self.data = data
        self.selected_rows = []  # 用于跟踪选中的行

    def GetNumberRows(self):
        return len(self.data)

    def GetNumberCols(self):
        return 7

    def IsEmptyCell(self, row, col):
        return False

    def GetValue(self, row, col):
        return str(self.data[row][col])

    def SetValue(self, row, col, value):
        self.data[row][col] = value

    def IsRowSelected(self, row):
        return row in self.selected_rows

    def SelectRow(self, row):
        if row not in self.selected_rows:
            self.selected_rows.append(row)

    def DeselectRow(self, row):
        if row in self.selected_rows:
            self.selected_rows.remove(row)

    def SelectAll(self):
        for row in range(self.GetNumberRows()):
            self.SelectRow(row)

    def DeselectAll(self):
        self.selected_rows = []

    def AppendRow(self, row_data):
        # 添加新的数据行
        self.data.append(row_data)
        # 通知表格刷新数据
        grid = self.GetView()
        if grid:
            grid.ProcessTableMessage(
                gridlib.GridTableMessage(
                    self, gridlib.GRIDTABLE_NOTIFY_ROWS_APPENDED, 1
                )
            )

app = wx.App(False)
frame = wx.Frame(None, wx.ID_ANY, "虚拟表格示例", size=(600, 400))

panel = wx.Panel(frame)
sizer = wx.BoxSizer(wx.VERTICAL)

grid = gridlib.Grid(panel)
grid.CreateGrid(0, 7)
table = MyGridTable([])  # 使用空数据表初始化
grid.SetTable(table, True)

# 设置列标签
grid.SetColLabelValue(0, '修改时间')
grid.SetColLabelValue(1, '文  件  路  径')
grid.SetColLabelValue(2, '详情')
grid.SetColLabelValue(3, '大小')
grid.SetColLabelValue(4, 'D')
grid.SetColLabelValue(5, '状态')
grid.SetColLabelValue(6, 'MD5')

sizer.Add(grid, 1, wx.EXPAND)

select_all_button = wx.Button(panel, label="全选")
deselect_all_button = wx.Button(panel, label="取消全选")
add_row_button = wx.Button(panel, label="添加行")

# 全选按钮的点击事件
def on_select_all(event):
    table.SelectAll()
    grid.Refresh()

# 取消全选按钮的点击事件
def on_deselect_all(event):
    table.DeselectAll()
    grid.Refresh()

# 添加行按钮的点击事件
def on_add_row(event):
    new_row_data = ["New", "Row", "Data", "100 KB", "D", "OK", "abcdef1234567890"]
    table.AppendRow(new_row_data)

select_all_button.Bind(wx.EVT_BUTTON, on_select_all)
deselect_all_button.Bind(wx.EVT_BUTTON, on_deselect_all)
add_row_button.Bind(wx.EVT_BUTTON, on_add_row)

sizer.Add(select_all_button, 0, wx.ALIGN_CENTER)
sizer.Add(deselect_all_button, 0, wx.ALIGN_CENTER)
sizer.Add(add_row_button, 0, wx.ALIGN_CENTER)

panel.SetSizer(sizer)
frame.Show()

app.MainLoop()
