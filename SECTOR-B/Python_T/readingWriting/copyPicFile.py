#复制图片文件

with open('j:/T1.ico', 'rb') as rf:
    with open('icon_copy.ico', 'wb') as wf:
        chunk_size = 256
        rf_chunk = rf.read(chunk_size)
        while len(rf_chunk) > 0:
            wf.write(rf_chunk)
            rf_chunk = rf.read(chunk_size)