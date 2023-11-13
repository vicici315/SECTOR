PerCopyFiles = {1: 'value1', 2: 'value2', 3: 'value3', 4: 'value4'}

# 假设要删除键为2的成员
deleted_key = 2
del PerCopyFiles[deleted_key]
del PerCopyFiles[3]

# 重新编号
new_PerCopyFiles = {new_index: value for new_index, (old_index, value) in enumerate(PerCopyFiles.items(), start=1)}

# 更新原字典
PerCopyFiles = new_PerCopyFiles

# 打印结果
print(PerCopyFiles)
