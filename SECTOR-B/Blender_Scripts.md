# Blender_Scripts

## 通用设置

视图切换(Navigation) > ■围绕选择物体旋转(OrbitAroundSelection)
         > □自动透视(Auto Perspective)
系统(System) > 撤销次数(UndoSteps):100

# 脚本

## Blender 初始设置

Blender设置:Interface > ■PythonTooltips (勾选该项python命令会被显示)
实现 自动补全功能的方法,就是在ide 环境里边安装 fake -bpy-module-版本号

```python
pip install --user fake-bpy-module-3.2
```

## 导入bpy内部模块

```python
from bpy.types import AddonPreferences
from bpy.props import StringProperty
```

## 变换选择的物体

location[0] 代表 location.x , 1,2 是 y,z

```python
import bpy    #导入bpy模块
bpy.context.object.location[0] = 4
bpy.context.object.location.x = 4
#三个值一起设置
bpy.context.object.location = (4,1,0)
#指定物体名称设置参数 bpy.data.bojects['Name']
bpy.data.objects['Cube.001'].location = (-2,1.5,2)
```

## 获取游标位置

```python
bpy.context.scene.cursor.location
#返回:
Vector((0.0, 0.0, 0.0))
```
