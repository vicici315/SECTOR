from reportlab.graphics.barcode import code128
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

def generate_barcode_pdf(data, filename='barcode.pdf'):
    """使用reportlab生成PDF格式的标准条形码"""
    c = canvas.Canvas(filename, pagesize=letter)
    barcode = code128.Code128(data, barHeight=50, barWidth=1.0)
    barcode.drawOn(c, 100, 600)
    c.save()
    print(f"生成PDF条形码: {filename}")

# 使用示例
generate_barcode_pdf("HELLO123")




