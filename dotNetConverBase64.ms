-- 图片文件的路径
imagePath = @"d:\\Gits\\MyWinUI\\Mywin.ico"

-- 使用System.IO.File类的ReadAllBytes方法读取图片文件的二进制数据
binaryData = (dotNetClass "System.IO.File").ReadAllBytes imagePath

-- 创建System.Convert类的实例，并使用ToBase64String方法将二进制数据转换为Base64编码
base64Image = (dotNetClass "System.Convert").ToBase64String binaryData
