--创建Bone骨骼序列，并设置骨骼层级
pos = 0
allbo=#()
for i in 1 to 7 do(
	bb = BoneSys.createBone [0,pos,0] [0,pos+15,0] [0,0,1]
	pos = i * 15
	append allbo bb
)
for i in 2 to allbo.count do(
	allbo[i].parent = allbo[i-1]
)
--计算子物体数量的函数
global ccc
fn CHILDRENCOUNT OBJ = (
	if OBJ.children.count > 0 do(
		ccc+=OBJ.children.count
		for o in OBJ.children do
			CHILDRENCOUNT o
	)
	return ("有 "+(ccc as string)+" 个子物体")
)
--调用
ccc = 0
CHILDRENCOUNT $

--自动编号命名参数 prefix:
for i in 1 to 100 do sphere prefix:"baz"
--creates 100 spheres, giving each a unique name
--beginning with "baz", such as $baz01, $baz02, $baz03, etc.

--刷新材质显示模型贴图
	showTextureMap o.material off
	showTextureMap o.material on
--取模（每6执行一次）
ss = ""
for i = 1 to 100 do(
	ss += i as string + " "
	if ((mod i 6) == 0) do (ss+="\n")
)
--每17格输出一个累加数
ss = ""
nn = 0
for i = 1 to 500 do(
	if ((mod i 17) == 0) do (
	nn += 17
	ss += nn as string
	ss +="\n")
)
ss
--重置场景，传入中括号中的值不弹出提示，值写在括号中
resetMaxFile() [#noPrompt] 
--获取MAX版本
fn getVer =(
    v = (maxversion())[1] / 1000
    if v <= 9 then return v
    else return (2008 + v - 10)
)
--随机选择物体示例（场景中的物体会随机被选中）《3dsMax Monday Movie #66: MaxScript Rollouts》
for obj in objects do
	if (random 0 1) == 1 do
		selectmore obj
--跨文件调用其它文件函数（可把共用函数集中一个文件中）
	--1函数文件定义函数struct函数
	struct  allFunctions 
 	(
		fn getFile filepath =(		)
	)
	--2跨文件调用函数
	pyc_inscript "allFunctions"		--包含进静态函数
	--使用函数
		io = allFunctions()
		c = io.getfile config 
--DotNet-System.Windows.Forms.ListBox
rollout autoRollout "Parent" --define a rollout and create a dialog 
(
dotNetControl f1 "System.Windows.Forms.ListBox"height:180 
        
 on autoRollout open do (
	f1.text = "ssss"
	u =  dotnetclass  "system.drawing.color"
	c = u.FromArgb  12 23 12
	f1.BackColor   = c
	f1.AllowDrop = true --拉入文件列表需要
 )
)
createDialog autoRollout 200 200 
--列出ListBox组件的属性
showProperties autoRollout.f1
	--根据参数层级查看每一级参数
showProperties meditMaterials[1][#Maps][#Diffuse_Color__Gradient____Gradient].coords
--获取成员数
autoRollout.f1.items.count
--添加成员项
autoRollout.f1.items.add("safssfsaf")
--删除成员项，括号内是成员内容
autoRollout.f1.items.Remove(autoRollout.f1.SelectedItem)
--起始数值0
autoRollout.f1.items.item[2]
--返回选择的内容
autoRollout.f1.SelectedItem
--返回选择的编号
autoRollout.f1.SelectedIndex
--取消所有选择
autoRollout.f1.ClearSelected()
--Select three items from the ListBox.列表选择方式： One 只能选择一项。MultiSimple 可以选择多项。MultiExtended 可以选择多项，并且用户可使用 Shift、Ctrl 和箭头键来进行选择。None 无法选择项。
autoRollout.f1.SelectionMode = autoRollout.f1.SelectionMode.MultiExtended
autoRollout.f1.SetSelected 0 true
autoRollout.f1.SetSelected 1 true
--获取选择的成员数
autoRollout.f1.SelectedItems.count
--获取选择的成员
autoRollout.f1.SelectedItems.Item[1]
		--拖拽文件方法
        on listmax DragDrop  arg do (
                listmax.items.clear()
                filetype = dotnetclass "System.Windows.Forms.DataFormats"
                filet = filetype.FileDrop 
                p = arg.Data.GetData (filet)
                for i in p do (
					kn= tolower ( getfilenametype i )
					if kn ==".max"then (
							listmax.items.add (i )
					)
                )        
        )

        on listmax  DragEnter arg do (
                -- 写格式
                filetype = dotnetclass "System.Windows.Forms.DataFormats"
                filet = filetype.FileDrop 
                
                ftt = arg.Data.GetDataPresent (filet)
                ef = dotnetclass "System.Windows.Forms.DragDropEffects"
                if  ftt then (
                        arg.Effect = ef.link 
                )else (
                        arg.Effect = ef.None 
                )
        )
		--双击事件
		on f1 DoubleClick  arg do ()
		--双击全选
	on f1 doubleClick arg do (
		for i in 0 to (f1.items.count - 1)do
		f1.SetSelected i true
	)
		--单击鼠标左中右方法（适合label）
		on listmax Click  arg do (
			bi = dotnetclass  ("System.Windows.Forms.MouseButtons" )
                if  arg.Button == bi.left then (
                        bi = clock.active
                        clock.active =not bi 
                        if( not  chek_rot.checked )then (
                        getbi = isAnimPlaying()
                        if not getbi then (playAnimation realTimePlayback:false)else (stopAnimation())
                        )
                )else if arg.Button == bi.Middle then (
                        --onoff = ATSOps.visible 
                        --ATSOps.visible = not onoff  
                )else if arg.Button == bi.right then (
                        popUpMenu   pyc_ling_menu_openmapfile
                )
		)
--二维数组查找
fn FindNameMat Array Ob Ma = (
	RR = 0
	for o in Array do(
		if o[1] == Ob and o[2] == Ma do(
			RR += 1
		)
	)
	return RR
)
	--use
	B=#(); Buse=#()
	for o in selection do(
		n = (filterstring o.name "s")[1]
		if (FindNameMat B n o.material.name)==0 do (
			append B #(n,o.material.name)
			append Buse o
		)
	)
--导出FBX设置参数http://help.autodesk.com/view/3DSMAX/2020/ENU/?guid=GUID-3242579C-E37D-4A7C-BFA5-F4A2F22653E7
FBXExporterSetParam [arg] [value]
FBXExporterSetParam "Cameras" false
FBXExporterSetParam "Animation" true
FBXExporterSetParam "BakeAnimation" true
FBXExporterSetParam "BakeFrameStart" animationRange.start
FBXExporterSetParam "BakeFrameEnd" animationRange.end
exportFile "<path>" #noPrompt selectedOnly:true
--旋转归零
$.transform.controller.rotation.controller.x_rotation = 0
$.transform.controller.rotation.controller.y_rotation = 0
$.transform.controller.rotation.controller.z_rotation = 0
	--使用四元数要记录位置 旋转后再归位一下
	$.rotation = (quat 0 0 0 1)
--对齐两组物体中心位置
	p=(Objs.max + Objs.min)*0.5 --P1 center pos
	p2=(Buse.max + Buse.min)*0.5 --P2 center pos
	move Buse [p.x-p2.x, p.y-p2.y, 0]
--遍历抽取不重复的值
A = #(2,6,2,2,4,4,5)
B = #()
for o in A do(
	if finditem B o == 0 do append B o
)
B = #(2, 6, 4, 5)
--读取加密文件
x = openEncryptedFile "c:\Program Files\Autodesk\3ds Max 2015\scripts\MyBaby\main.dll" 7411074110
f = createfile "c:\Program Files\Autodesk\3ds Max 2015\scripts\MyBaby\main1.ms"
for i in 1 to 9999 do(
	if eof F == false then(
	id = readline x
	format "%\n" id to:f
	)else exit
)
close f
--密码加密文件
f = createFile "lock.tmp"
format "%" hardwareLockID to:f
close f
encryptFile "lock.tmp" "lock.dat" 5476557
deleteFile "lock.tmp"
--停顿时间后再执行下面的代码
sleep 0.51 --second
print "go"
--bip骨骼平移1垂直2旋转3模式
biped_ctrl=$bip01.controller
<biped_ctrl>.trackSelection Integer Default: 0
--设置bip关键帧
biped.setSelectedKey <bipedCtrl>
--对Bip01骨骼旋转设关键帧
 $.transform.controller.trackSelection=3
 biped.setSelectedKey $.controller
--拷贝黏贴Bip骨骼蒙皮姿势
biped.copyBipPose <biped_ctrl> <ICC_MXCopyCollection>(#snapView |#snapAuto |#snapNone)
biped.pasteBipPose <biped_ctrl> <ICP_MXBipedCopy> <bool_opposite> (#pstdefault |#pstcopied |#pstinterp) <bool_hor> <bool_ver> <bool_trn> <bool_byvel>
	--例子：
	bip=$Bip001.controller
	bip.figureMode = true	--激活Bip小人模式
	biped.createcopyCollection bip "pose"
	ICC = biped.getcopycollection bip 1
	ICP = biped.copyBipPose bip ICC #snapNone
	$bip001.controller.figureMode = false
	max tool animmode; set animate on
	biped.pasteBipPose bip ICP false #pstdefault on on on off
--获取所选物体的动画帧范围
getAppData $ 77	--return："0f|33f"
--dotNetControl多元列表控件，文档地址：
https://docs.microsoft.com/zh-cn/dotnet/api/?view=netframework-4.8
--DotNet In MAXScript 使用方法
http://help.autodesk.com/view/3DSMAX/2018/ENU/?guid=__files_GUID_779FD7AC_953D_4567_B2A8_60B1D8695B95_htm
--控件：listbox、treeview
dotNetControl lv_objects "System.Windows.Forms.ListView" pos:[8,8]
	--第一个item[0]编号控制竖列表，第二个Item[2]编号控制横列表（最小从0起始）
	lv_objects.items.item[0].SubItems.Item[2].text
	--初始化表格的函数
	fn initListView lv =
	(
		lv.View = (dotNetClass "System.Windows.Forms.View").Details --.net版本
		lv.gridLines = true
		lv.fullRowSelect = true --显示表格
		--设置颜色
		lv.backcolor = lv.backcolor.FromArgb 180 112 120
		lv.forecolor = lv.forecolor.FromArgb 155 225 255
		
		--定义每个列头要显示的数组，也就是每个列头要显示的内容和列宽
		layout_def = #(#("序号",36),#("*.max",130),#("*.bip",130),#("*.xaf",130),#("时间范围",80))
		--设置列头要显示的文字
		for i in layout_def do lv.Columns.add i[1] i[2]
	)
	--dotNetControl使用ListBox控件实例：
	rollout parent_dialog "Parent" --define a rollout and create a dialog 
	(
	dotNetControl listmax "System.Windows.Forms.ListBox"height:180 
	 
	 on parent_dialog open do (
	  listmax.text = "ssss"
	 u =  dotnetclass  "system.drawing.color" 
		c = u.FromArgb  12 23 12 
	  listmax.BackColor   = c 
	 )
	  on listmax DragDrop  arg do (
  listmax.items.clear()
  filetype = dotnetclass "System.Windows.Forms.DataFormats"
  filet = filetype.FileDrop 
  p = arg.Data.GetData (filet)
  for i in p do (
   kn= tolower ( getfilenametype i )
   if kn ==".max"then (
    listmax.items.add (i )
   )
  ) 
 )

 on listmax  DragEnter arg do (
  -- 写格式
  filetype = dotnetclass "System.Windows.Forms.DataFormats"
  filet = filetype.FileDrop 
  
  ftt = arg.Data.GetDataPresent (filet)
  ef = dotnetclass "System.Windows.Forms.DragDropEffects"
  if  ftt then (
   arg.Effect = ef.link 
  )else (
   arg.Effect = ef.None 
  )
 )
	)
	createDialog parent_dialog  200 200 
--获取Environment and Effects渲染特效Atmosphere数量
numAtmospherics
--材质路径整理 Asset Tracking(Shift+T)
ATSOps
--创建多个卷帘窗口
	global AnimateToolFloater
	AnimateToolFloater = newRolloutFloater "动画工具" 180 880
	AnimateToolFloater.pos=AnimateTool_pos
	addRollout PlayTools_Rollout AnimateToolFloater
	removeRollout PlayTools_Rollout AnimateToolFloater
	--关闭RolloutFloater窗口
	closeRolloutFloater AnimateToolFloater
--函数条件调用
callbacks.removescripts id:#prem	--通过id删除回调函数
callbacks.removescripts id:#postm
callbacks.addscript #filepremerge "AMSS_collectobj()" id:#prem  --添加条件回调函数，#filepremerge（当合并文件时回调）
callbacks.addscript #filepostmerge "AMSS_myimport()" id:#postm  --#filepostmerge（当合并post时回调）
--设置选择过滤，上方工具栏里有下拉列表可选，1为全部无过滤
SetSelectFilter 1
GetSelectFilter() --返回int
--创建曲线路径约束
pc = path_constraint()
$.position.controller = pc  --assign it to the sphere's position
pc.path = $Line001
$.pos.controller.PERCENT = 16
------
cc = 0
for o in selection do(
	pc = path_constraint()
	o.position.controller = pc
	pc.path = $Line001
	o.pos.controller.PERCENT = (100.0/(selection.count-1))*cc
	cc+=1
	o.position.controller = Position_XYZ ()
)
--对比两个列表里的物体按最近的重新排列L2
	fn MinDistance =(
		L1 = lbx1.items
		L2 = lbx2.items
		NewL2 = #()
		NN = ""
		F = 0
		for i in 1 to L1.count-1 do(
			MinD = distance (getnodebyname L1[i]) (getnodebyname L2[1])
			NN = L2[1]
			for o in 2 to L2.count do(
				Dis = distance (getnodebyname L1[i]) (getnodebyname L2[o])
				if Dis < MinD do(
					MinD = Dis
					NN = L2[o]
				)
			)
			append NewL2 NN
			if (finditem L2 NN) > 0 do deleteItem L2 (finditem L2 NN)
		)
		append NewL2 L2[1]
		return NewL2
	)
--计算两个物体位置的中间
(selection[1].position + selection[2].position)/2
--删除空物体病毒
$'　'.name = "a"
$''.name = "b"
try(delete $a; delete$b)catch()

throw <error_message_string> [ <value> ] throw()

--用脚本创建曲线三角形
addKnot <shape> <spline_index_integer> \
(#smooth | #corner | #bezier | #bezierCorner) \
(#curve | #line) <position_point3> \
[invec_point3 outvec_point3] \
[where_integer]

	ss = SplineShape()
	addNewSpline ss
	addKnot ss 1 #corner #line [-100,200,0]
	addKnot ss 1 #corner #line [-100,0,0]
	addKnot ss 1 #corner #line [0,200,0]
	close ss 1
	updateshape ss
	(
	local sp = splineShape()
	addnewSpline sp
	addKnot sp 1 #corner #line [20,10,0]
	addKnot sp 1 #corner #line [-20,11,0]
	addKnot sp 1 #corner #line [-20,-11,0]
	addKnot sp 1 #corner #line [20,-10,0]
	close sp 1
	updateShape sp
	select sp
	subobjectlevel = 1
	setKnotSelection sp 1 #(1,4) keep:false -- Select the right most knots
	weldSpline sp 21.0
	local knotCount = numknots sp
	if (knotCount != 3) do
	 throw ("Spline should have 3 knots, found "+ (knotCount as string))
	)
--创建实例复制
b1 = instance b1Max
a = instance $ name:"abc"
select a --复制一个物体时可以选择操作
--编辑器命令选择的曲线
splineOps.delete($) --删除选择的点线面元素
subobjectlevel = 2 --进入线编辑模式
$curver.render_displayRenderMesh = false --曲线显示模型开关
$curver.render_renderable = false --曲线渲染开关
$curver.render_thickness = 2.0 --曲线模型厚度
$curver.render_sides = 6 --曲线模型段数

--检查场景节点是否没被删除，是返回true
isValidObj $names
--判断物体是否可以转换为Editable_mesh，可以返回True。
if canConvertTo $foo Editable_mesh then...

--设置获取UV通道ID
$.modifiers[#unwrap_uvw].unwrap.setMapChannel 2
$.modifiers[#unwrap_uvw].unwrap.setMapChannel 0
$.modifiers[#unwrap_uvw].unwrap.getMapChannel() 
--1为顶点颜色通道，0为1号UV通道
0 - UVW Channel 1
1 - Vertex Colors Channel
2..99 - UVW Channels 2 .. 99

--测量曲线长度
curvelength $Curver

null	undefined --空和未发现
hasProperty
--转换字符为大写或小写
toUpper "abc"	--"ABC"
toLower "ABC"	--"abc"
--查找并替换字符  在<source_string>里查找<from_string>，并将其替换为<to_string> 
substituteString <source_string> <from_string> <to_string> 
--从一段字符中清除右边包含的字符： <String>trimRight <String> [String trimChars]
trimright "$Teapot0911" "1234567890" --删除所有数字  返回："$Teapot"
--查找字符，返回字符所在位号
<integer> findString <string> <search_string>
--根据token_string拆分字符串到数组[splitEmptyTokens:是否拆分空字符]
<array of strings> filterstring <string> <token_string> [splitEmptyTokens:<boolean>]
--字符串里从<from_integer>到<length_integer>替换成<new_string>
<string> replace <string> <from_integer> <length_integer> <new_string>
--提取字符串里从<from_integer>到<length_integer>的字符
<string> substring <string> <from_integer> <length_integer>
	substring "Balerofon" 5 3 -- returns "rof"
	substring "Balerofon" 5 -1 -- returns "rofon"
	substring "Balerofon" 5 100 -- returns "rofon"
--添加<string2>到<string1>
<string> append <array> <string2>
--获取字符串的长和高的像素数宽高
<Point2> GetTextExtent <string>
--获取字符串字数
"\ggg".count -- retures 4
--层操作
layerManager.count
refs.dependents (layerManager.getLayer 0).layerAsRefTarg
--EditablePoly detach 分离选择的面
$.EditablePoly.detachToElement #Face keepOriginal:off
showProperties $ --显示节点属性
getPropNames $ --获取属性名称变成数组
getPropNames Normalmodifier() --获取函数属性名
aa = getPropNames $.material	--收集属性名
getProperty $.material aa[3]	--获取属性

a=getPropNames V_Ray_RT_2_10_01 --获取Vray属性参数名称
for pp in a do format "%\n" pp
renderers.production.gi_on --设置参数

getDialogSize <rollout> --point2 <rollout>.width <rollout>.height

getFilenameFile --获取uiMaxMin用到的bitmap位图文件名
if (getFilenameFile uiMaxMin.bitmap.filename) == "dts_max"
--rcmenu弹出式菜单 必须放在rollout 前面
--rcmenu菜单里调用rollout时，rollout名称需要在前面用Global声明
rcmenu SpeedCusmenu
(
	menuitem mi_Model1 ""checked:false
	separator sep1
	subMenu "Stuff" (	--子菜单
		menuitem quadmenu_mi "Quad Menu"
		separator spe3
		menuitem quadcolor "Quad Color"
	)
)
--列出类
showClass "*:*controller*"
--设置变换工具
setCoordCenter #system -- #local #selection
--获取变换中心类型
getCoordCenter()
--setRefCoordSys <mode_name> 设置变换轴中心
setRefCoordSys #hybrid
#hybrid -- View
#screen -- Screen
#world -- World
#parent -- Parent
#local -- Local
#object -- Pick object or Grid - not valid for setRefCoordSys()
--获取变换轴中心类型
getRefCoordSys()
--获取物体的Visibility属性关键帧
getVisController
--判断Program Files\Autodesk\3ds Max 9\ui\Icons\中没有UVtools_24i.tga文件弹出对话框
if (getfiles (getdir #ui + "\\icons\\UVtools_24i.tga")).count == 0 do
	(
	messagebox "You are missing you icon tga file!\nPlace UVtools_24i.tga in you ui\\icons dir." title:"Setup Error"
	return false
	)
--按钮image属性
local uvicons = (getdir #scripts + "/Outline_UI.bmp")
local iconCount = 4 --为了方便设置全部的按钮这里做个变量设置
images: #(uvicons, <maskImage>, <count_integer全部按钮数目>, <enabled_out_image_index>, <enabled_in_image_index>, <disabled_out_image_index>, <disabled_in_image_index>)
--网址链接对象
hyperLink diWeb_hl "http://www.darkindustries.com" address:"http://www.darkindustries.com" \
	pos:[143, 107] color:(color 0 0 255) hoverColor:(color 215 28 57)
--mod <number1> <number2> 逻辑运算,当number1小于number2时返回number1的值；当number1大于number2时返回number1减去number2的值（返回值始终为浮点值）
--如果<number2>可以被<number1>整除则返回值为0.0
mod 2 4  -- 2.0
mod 5 4  -- 1.0
mod 10 5  -- 0.0
--例：获取1到10可以被2整除的数
a = for i in 1 to 10 where mod i 2 == 0 collect i  --#(2, 4, 6, 8, 10)
--2的10次方
2^10 = 1024
2^2 = 4
--输出字符“\” “"” 用反斜杠 \ 放在特殊字符前面
print "\\"
print "\""

--获取和设置属性
getProperty <obj> <property_name>
setProperty <obj> <property_name> <value> 
--判断节点是否包含有指定字符里的属性
hasProperty()
hasProperty <obj> <prop_name_or_pattern_string>
--判断是否包含未塌陷物体属性
isProperty <MAXWrapper_object> <property_name_or_string> 
--MSF2-01_Arrays_&_Object_Sets

--二维数组读取
OS[1][2]
append <array> <elements> --添加数组成员
--添加指定数组位置成员
	<array>[编号] = 成员
	Arr = #()
	Arr[1] = 123
--数组可以相加
#("----Medit Materials----") + (for o in meditmaterials collect o.name)
deleteItem <array> <number> --按编号删除数组里的成员
join <array> <collection> --添加一个数组里的所有成员到数组
findItem <array> <value> --返回<value>所在位置的号数，返回0则数组里没有找到对象
insertItem <value> <array> <integer>
sort <array> --排序升序排列数组里的对象,对象必须有可比性

--求数组里的数相加
theArr=#(234,5,16,326,24)
theNum=0
for i in theArr do theNum=theNum+i
theNum
--升序排列数组元素,所有的元素必须是具有可比性。
sort theArr --#(5, 16, 24, 234, 326)
theArrE=#("b","d","e","c","a")
sort theArrE --#("a", "b", "c", "d", "e")
--将个为数为1的所有Box放入数组("?"用于替换一位未知数)
$Box?1 as array
--转换物体的旋转值为矢量,获取x值
x_angle = ($.rotation as eulerAngles).x
--提取挑帧属性转为字符
	a=""
	for i in 1 to rendPickupFrames.count do a=a+(rendPickupFrames[i] as string)
	--设置挑帧属性
	a="1,5,12,17-19,22"
	rendPickupFrames = a
--时间栏控制，渲染范围
max time play
stopAnimation()
playAnimation()
interval <start_time> <end_time>
animationRange = interval 0 100
--Properties:
animationRange.start : Time
animationRange.end : Time
--当前时间栏滑块位置
slidertime = 22
--MSF2-04_Working_With_General_Node_Properties
--列出物体所有属性show <objects>
show $
$.isselected = false --将取消选择的
--判断物体是否隐藏
$.isHidden
--判断物体是否冻结
$.isFrozen
--物体线框颜色
$.wirecolor = color 198 224 87

--选择被赋予材质编辑器里当前选择的材质球的物体
select (for o in objects where o.material == medit.GetCurMtl() collect o)
--获取当前选择的Returns the current selection as an array. This is similar to selection as array, however selection as array returns a copy of the selection. 
getCurrentSelection()
--while循环倒序 -Returns:10 9 8 7 6 5 4 3 2 1 0
x=10
while x>0 do print (x-=1)
while (finditem Rnum RR)==0 do RR=random 1 colorStor.count --挑选没有重复的数，有则继续随机
--倒序ALLG里的数组
	Tmp = ALLG
	ALLG = #()
	x=Tmp.count
	while x>0 do(
		x-=0
	)
--MSF2-09_Working_With_Modifiers
--添加变形器 addModifier <theBox> <theMod>
theBox = box height:100 heightsegs:10
theMod = bend angle:80
addModifier theBox theMod
addModifier <node> <modifier> [before:index]
---循环添加变形器给选择的
for o in selection do addModifier o theMod
--Modifiers开关<.enabled> 运用循环开关变形器 true / false
for o in objects do for m in o.modifiers do m.enabled = true
---运用not开关所有物体变形器.当m != m,意味着当值为true时改为false,false时改为true
for o in objects do for m in o.modifiers do m.enabled = not m.enabled
	.enabledInViews <boolean>--变形器效果不可见,可渲染
---挑选出Bend变形器类型进行改变classof <node>
for o in objects do for m in o.modifiers where classof m == Bend do m.enabled = not m.enabled
---在对第一个循环层再添加一个条件,只对Box的Bend变形器进行改变.<判断物体的基本物体类型>
for o in objects where coassof o.baseobject == Box do for m in o.modifiers where classof m == Bend do m.enabled = not m.enabled
--所有灯光作开关 where superclassof <objects>  hasProperty <objects> <"property"> 判断 light 是否含有"enabled"属性
for l in objects where superclassof l == light and hasProperty l "enabled" do l.enabled = not l.enabled

--deleteModifier <obj> <integer>要删除的变成器位置,从上往下1 2 3... 
--删除所有物体中 第一个Bend 变形器(该循环只会删除一个Bend)
for o in objects do for m in o.modifiers where classof m == Bend do deleteModifier o m
	--从2到20,没2个数打印一次 for to by do--returns: 2 4 6...18 20
	for i = 2 to 20 by 2 do print i
	--运用by加负数可以从大到小循环--returns: 20 18 16...4 2
	for i = 20 to 2 by -2 do print i
--{运用倒循环删除物体变形器中的所有Bend变形器}从每个物体的变形器数量开始到1,没次循环减1,查找每个变形器[编号]类型为Bend的变形器,删除
for o in objects do for m = o.modifiers.count to 1 by -1 where classof o.modifiers[m] == Bend do deleteModifier o m
--{删除所有的物体中的所有变形器}去除了变形器类型判定
for o in objects do for m = o.modifiers.count to 1 by -1 do deleteModifier o m
--判断每个选择物体的Bend类变形器数量,没有则添加Bend变形器
for o in selection where (for m in o.modifiers where classof m == Bend collect m).count == 0 do addModifier o (Bend angle:90)

--MSF2-10_Working_With_Animation_Keys
--创建10*10的Box阵列
for y=0 to 9 do for x=0 to 9 do box length:10 width:10 height:10 pos:[20*x,20*y,0]
--设置自动打帧开关
max tool animmode
--表达式创建动画关键帧 animate on(<time> <value>; <time> <value>)
animate on (at time 20 $.height=100;at time 30 $.height=10)
--在0-10之间随机移动所有关键帧 movekeys <.controller>
for o in $Box* do movekeys o.height.controller (random 0 10)
--只随机移动第2个关键帧 movekey <.controller 2>
for o in $Box* do movekey o.height.controller 2 (random 0 10)
--创建递增移动关键帧应用moveKeys函数移动 < .height.controller> 帧
keymove = 0
for o in $Box* do movekeys o.height.controller (keymove += 1)

--时间栏里的起始时间和结束时间属性
animationrange.start
animationrange.end
animationRange = interval <integer> <integer> --设置时间栏范围
animationRange = interval 0 (animationRange.end + 1)
--群添加关键帧
with animate on
(
	at time 50 source_obj.pos.controller.x_position = 100
	at time 100 source_obj.pos.controller.x_position= 200
)
--设置动画曲线循环loop 向前循环setAfterORT 向后循环setBeforeORT
setBeforeORT <controller> <ORT_type_name>
	<ORT_type_name>: #constant #cycle #loop #pingPong #linear #relativeRepeat
setAfterORT $.unwrap_uvw.point5.controller #loop
--删除第几帧
deleteKey <controller> <index>
deleteKeys <controller> [ #allKeys | #selection ]
 Example:
deletekey $.visibility.controller 1
deletekeys $.visibility.controller
--选择关键帧，和选择一个间隔<interval>区域里的多个帧:0-??
selectKey <controller> <index_integer>
selectKeys <controller> [ <interval> | <time> ]

--修改Box01位移的Z轴的第2个关键帧的曲线类型为：#linear
$Box01.pos.controller.Z_Position.controller.keys[2].inTangentType = #linear
--修改第二帧的visibility值
$Box01.visibility.controller.keys[2].value = 1
--获取关键帧值
$.pos.controller.keys[1].time

--MSF2-11_Working_With_Materials
--为选择的物体赋予standard材质,此材质不会在材质编辑器中显示
$.material = standard diffuse:(random black white)
--移除选择的物体材质
$.material = undefined
--获取名为GridMap_mat的材质球在材质编辑器中第几号（按名字查找材质球）
findItem meditmaterials meditmaterials["GridMap_mat"]
--赋予Bitmaptexture贴图
$.material = standard diffusemap:(Bitmaptexture filename:(getdir #Scripts+"\\oxTOOLSfiles\\Icons\\UV_512.jpg")) name:"GridMap_mat"
--材质编辑器上第一个球获取场景名为"GridMap_mat"的材质球
meditMaterials[1] = sceneMaterials["GridMap_mat"]
--设置选中的物体材质名跟模型名相同
$.material.name = $.name

--{创建出砖墙叠放效果的Box}创建一个真假值shift变量定义为Boolean,z从0到9,(shift=not shift在true与false间循环;[分号隔开]x从0到9创建Box Pos:为(当shift==true时[...]否则[x轴加10位移..]))
shift = true
for z=0 to 9 do (shift=not shift;for x=0 to 9 do box length:10 width:19.6 height:9.6 pos:(if shift then [20*x,0,10*z] else [10+20*x,0,10*z]))
--循环创建4个standard材质球 diffuse:(创建四个颜色数组[ArrayItem])name:("名称"+编号 转换为字符)
for m=1 to 4 do meditmaterials[m] = standard diffuse:(#(red,blue,white,yellow)[m]) name:("Lego_"+m as string)
--为选择的物体随机赋予上面创建的4个颜色材质
seed 12346 --随机数种子

--MSF2-12_Saving_Objects
--获取保存路径
getsavepath()
--max公用场景目录
getdir #maxstart  --"C:\Users\Administrator\Documents\3dsMax\scenes"
--保存选择的物体到temp目录,名字为test.max
saveNodes $ "c:/test.max"
mergeMAXFile "c:/test.max" quiet:true
--打开max文档useFileUnits:应用文档尺寸单位	注意斜杠方向相反
loadMaxFile "RA.max" useFileUnits:true quiet:true
loadmaxfile "c:/temp/test.max"
--保存所有Box物体到max项目目录下的scene文件夹(c:\Users\oox\Documents\3dsmax\scenes\)
saveNodes $Box* (GetDir #scene + "/allBoxes")
--导出导入选择的
	na="$scripts\oxTOOLSfiles\TmpScene\copyfile.max"
	saveNodes selection na quiet:true
	mergeMAXFile na #select quiet:true
--打开max文件,要加后缀
loadMaxFile (GetDir #scene + "/allBoxes.max")
--输入一个错误的目录可以查看所有可用目录--打开Customize>Comfigure User Paths...也可以查看
getdir #a
getdir #maxroot --max安装根目录
--反馈当前打开的文件名称和路径
maxfilepath + maxfilename
--在scene文件夹里创建allBoxes文件夹,注意:GetDir #scene反馈的文件夹后没有"/",所以要在新文件夹前加"/"
makedir (GetDir #scene + "/allBoxes")
--在当前文件所在目录里建立新文件夹
thePath = maxfilepath + "newFolder"
makedir thePath
makedir "d:\\xxx\\bbb\\ccc"
--保存每个物体到刚才新建的目录,注意文件夹后要有"/".也可写成(...saveNodes o thePath)
for o in objects do saveNodes o (GetDir #scene+"/newFolder/"+o.name+".max")
--运行window的Explorer浏览器,并打开目录
shellLaunch "Explorer.EXE" thePath
--创建singleObjExp目录,把所有几何体分别导出obj格式,#noPrompt设置选项selectedOnly:为开
makedir (thePath=maxfilepath+"singleObjExp")
for o in geometry do (select o; exportfile (thePath+"/"+o.name+".obj")#noPrompt selectedOnly:true)
--获取文件夹里所有后缀为obj的文件到变量,用for循环导入所有obj
theFiles = getfiles (thePath+"/*.obj") 

for f in theFiles do importfile f #noPrompt

--执行字符串
execute "select $aa*"
--multiListBox多选列表创建双击选择物体操作
multiListBox details_lbx "" pos:[19,162] width:164 height:8 items:(for o in objects collect o.name)
	on details_lbx doubleClicked items do
	(
		selectionTmp = details_lbx.selection as array --获取列表里选择的ID号到数组。选择多项放数组里(运用于multiListBox)
		detailObj = getNodeByName details_lbx.items[selectionTmp[1]] --selectionTmp[1]不代表列表里的第一个，而是列表里选择的
		select detailObj	--getNodeByName 用于获取items 里的元素的名称
	)
	--获取multiListBox列表里选择的多个选项，并选择物体
	selectionTmp = details_lbx.selection as array --获取列表里选择的ID号到数组
	tmpArr = details_lbx.items --获取列表里的所有项到数组
	for itemNum in selectionTmp do --通过循环选择获取的节点名
	(
		selectmore (getNodeByName tmpArr[itemNum])
	)
	--全选操作
	on lbx1 doubleclicked item do(
		i=(lbx1.items.count)
		lbx1.selection=#{1..i}
	)
--listBox创建双击选择物体操作
listBox details_lbx "" pos:[8,21] width:137 height:14
	on details_lbx doubleclicked items do
	(
		selTmp = details_lbx.selection as integer --获取列表里选项的编号(运用于listBox)
		detailObj = getNodeByName details_lbx.items[selTmp] --获取选项元素的名称
		select detailObj
	)

--combobox组合框列表
combobox scale_cb "Scale" items: #("1/2", "1/4", "1/8", "1/16")
on scale_cb selected i do --当选择列表里某个对象 返回选择的对象ID到"i"
  format "You selected '%'!\n" scale_cb.items[i]
on scale_cb doubleClicked itm do
  format "You double-clicked '%'!\n" scale_cb.items[itm]
on scale_cb entered txt do scale_cb.selected = txt --当上面的文本框里输入并回车时,把选择的对象改成输入的字符
--dropdownlist下拉列表工具栏运用
rollout ddl_test "Drop-Down List"
(
dropdownlist scale_dd "Scale" items:#("1/2", "1/4", "1/8", "1/16")
on scale_dd selected i do
format "You selected '%'!\n" scale_dd.items[i]
)
createDialog ddl_test

--提问对话框，提供Yes/No选择
if queryBox "请为物体材质的Diffuse通道贴上一张贴图。\n    是否打开材质编辑器？" title:"Set OpacityMap" do()
	--queryBox 另一种用法
	fn maybe_saveMaxFile filename =
	( 
		if getFilenamePath filename == "" do
		filename = getdir #scene + "\\" + filename 
		if (not (doesfileexist filename)) or querybox ("filename: "+filename + "\nexists. Overwrite?") then (
			saveMaxFile filename 
			true 
		)else false 
	) 

--消息对话框
messagebox "请选择包含导出的.OBJ模型名称的物体" title:"Set OpacityMap"
--包含Yes/No/Cancel三个按钮的提示框
yesNoCancelBox
--关闭窗口
destroydialog name_Rollout
--设置窗口位置
setDialogPos gDTSUtility_rollout [UiX,UiY]
--保存窗口位置
on gDTSUtility_rollout moved pos do
(
	setINISetting "$scripts\dts_prefs.ini" "Interface" "UiX" ((pos.x as integer) as string)
	setINISetting "$scripts\dts_prefs.ini" "Interface" "UiY" ((pos.y as integer) as string)
)
--delIniSetting 删除INI里的一个章节
delIniSetting <filename_string> <section_string>
--当窗口打开着先关闭窗口,避免重复打开窗口
if globalUtility_rollout != undefined then destroydialog globalUtility_rollout
--设置对话框位置
setDialogPos RenameABC_rollout.helpRollout [pos.x-370,pos.y]
--选择父层级
select rootNode.children
--imgTag 位图按钮运用-----------------------------------------
imgTag uiquickSetup "" bitmap: (openBitMap "$scripts\dts\dts_quicksetup.bmp") align:#left offset:[8,0]
	on uiquickSetup click do --按钮命令
	(
		quickExport "setup"
	)
	on uiquickSetup mousedown do --按钮按下位图变化操作
	(
		uiquickSetup.bitmap = (openBitMap "$scripts\dts\dts_quicksetupc.bmp")
	)
	on uiquickSetup mouseup do --鼠标放开位图回复原来的
	(
		uiquickSetup.bitmap = (openBitMap "$scripts\dts\dts_quicksetup.bmp")
	)
----------------------------------------------------------------
--为选择的物体添加XForm
ResetXForm selection
--界面打开时获取ini里的值，保存值
 on RenameABC_rollout open do 
 (	newname_save = getINISetting "$scripts\custom_prefs.ini" "RenameABC" "newName"
	newName.text = newname_save as string
 )
 on newName_editText changed val do
 (
 	setINISetting "$scripts\custom_prefs.ini" "RenameABC" "newName" (newName_editText.text as string)
 )
-- Load SubRollout UIs 从ini读取子窗口 rolledUp:(设置卷栏是否卷起)
if renameABC_Open == true then AddSubRollout globalUtility_rollout.myRcmenuSubRollout RenameABC_rollout rolledUp:true
-- 关闭子UI
removeSubRollout <subrollout> <rollout>
-- checkBox 变化时操作命令
on checkbox changed state do
(	setinisetting "$scripts\custom_prefs.ini" "BakeFrame" "translateChk" (checkbox.checked as string)	)
--globalUtility_rollout窗口大小重建时，子窗口大小也重建， newSz 为变量，包含x/y两个值
on globalUtility_rollout resized newSz do
(	newSize = newSz.y as integer
	pDialogHeight = newSz.y
	myRcmenuSubRollout.height = pDialogHeight - 25
	if newSize > 75 then
	(
		if newSize != UiHeight then
		(
			setINISetting "$scripts\custom_prefs.ini" "Interface" "UiHeight" (newSize as string)
			UiHeight = newSize
		)
	)
)
-------rightclick
on button rightclick do
--复制Map
op = copy $.material.diffuseMap --复制diffuseMap
$.material.opacityMap = op --运用复制diffuseMap
$.material.opacityMap.monoOutput = 1 --设置MonoChannelOutput:Alpha
$.material.opacityMap.viewImage() --查看opacityMap里的贴图
--queryBox弹出“是”“否”两个按钮对话框，并做命令。
matm = queryBox "请只选择一个物体，并贴上一张贴图。\n    是否打开材质编辑器？" title:"Set OpacityMap"
if matm == true do( MatEditor.Open() ) --打开材质编辑器
if matm == false do( MatEditor.Close() ) --关闭材质编辑器
--判断材质编辑器是否打开
MatEditor.isOpen()
for o in $ do o.material = meditmaterials[random 1 4]
--打开选择的物体的材质球贴图
$.material.diffuseMap.bitmaptex.viewImage()
--获取材质编辑器当前选择的材质球 名称：类型
medit.GetCurMtl()
--材质编辑器上的第个球
meditMaterials[1]
--获取当前选择的材质球编号
medit.GetActiveMtlSlot()
--选择材质编辑器里使用当前选择的材质球的所有物体
select (for o in objects where o.material == medit.GetCurMtl() collect o)
getMeditMaterial
--多维材质球属性
Multimaterial
  .materialList (Material) : material array
  .mapEnabled (Map_1_Enable) : boolean array
  .names (Map) : string array
  .materialIDList (Index) : int array
  .material1 (alias for materialList[0])
--根据多维材质的数量按顺序设置ID号
	nn = 1
	for n in 1 to meditMaterials[1].material.count do(
	meditMaterials[1].materialIDList[n] = nn
	nn += 1
	)
--获取面数
$.faces.count
--获取点数
$.verts.count
--获取多边形Poly面数
polyop.getNumFaces $
--获取选择的物体在空间中的x.y.z轴的最大和最小值
selection.max.x
selection.min.x
--执行宏命令，执行Poly编辑的Cap命令
macros.run "Editable Polygon Object" "EPoly_Cap"
--转换字符为布尔的函数
function ConvertToBool state =(
	if state == "true" then( newState = true )else( newState = false )
	newState
)
ConvertToBool "true"	--返回：true
--模式选择函数调用
mapped fn freezeTM obj mode:#{1..2} =
(
		if mode[1] then
		(
			local lstCnt = position_List()
			obj.position.controller = lstCnt
			lstCnt[1].controller = position_xyz()
			lstCnt[2].controller = position_xyz()
			lstCnt.active = 2
		)
		if mode[2] then
		(
			local lstCnt = rotation_List()
			obj.rotation.controller = lstCnt
			lstCnt[1].controller = euler_xyz()
			lstCnt[2].controller = euler_xyz()
			lstCnt.active = 2
		)
		if mode[3] then
		(
			local lstCnt = scale_List()
			obj.scale.controller = lstCnt
			lstCnt[1].controller = bezier_scale()
			lstCnt[2].controller = bezier_scale()
			lstCnt.active = 2
		)
		return true
)
freezeTM springnode mode: #{1,2}
--例2
fn createBox mode:#{1,2} = --括号内为默认值，createBox()直接执行mode[1]和[2]里的命令,可留空
(
	if mode[1] then
	(
	box name:"mode1Box" length:20 width:20 height:20
	)
	if mode[2] then
	(
	box name:"mode2Box" pos:[18,0,0] length:20 width:20 height:26
	)
	if mode[3] then
	(
	box name:"mode3Box" pos:[35,0,0] length:20 width:20 height:31
	)
	if mode[4] then
	(
	box name:"mode3Box" pos:[-22,0,0] length:20 width:20 height:27
	)
	return true
)
createBox mode:#{4}
createBox mode:#{1..4} --执行1到4的全部命令
--定义函数开关
fn fillInSpreadSheet lv cleanselected filter:false=(
	if filter==false  then (
	)
)
fillInSpreadSheet SpringList  true

--ActiveXControl控件运用----------------------------------------------------------------
rollout rolloutObjList "oox_ObjLister v1.0" width:520 height:605 
(
	ActiveXControl axObjList "MSComctlLib.ListViewCtrl" pos:[2,25] width:517 height:558 
	button btnRefresh "Refresh" pos:[2,3] width:60 height:20
	button btnSelList "Select" pos:[420,3] width:45 height:20
	button btnUnhide "Unhide" pos:[468,3] width:50 height:20
	checkbox chkSuperC "主类" pos:[150,4] width:60 height:16 checked:classofChk
	edittext edtDisText "" pos:[1,585] width:515 height:18 enabled:false
	button btnSelAll "SelAll" pos:[468,585] width:50 height:18

	fn initListView lv = --该函数用于设置控件列表属性
	(
		lv.backcolor = color 80 80 50
		lv.forecolor = color 225 225 155
		lv.gridLines = true
		lv.MousePointer = #ccCross   
		lv.View = #lvwReport
		lv.Appearance = #ccFlat
		lv.BorderStyle = #ccFixedSingle
		lv.MultiSelect =true
		lv.fullRowSelect = true 
		lv.sorted = false --true
		lv.LabelEdit=  #lvwManual	
		lv.AllowColumnReorder =true
		lv.Checkboxes = false --true 	
		lv.HideSelection = false
			layout_def = #(#("-",25),#("  Name",120), #("  Type",90), #("  Parent",120),#("  Material",100), #("H",18))
			for i in layout_def do
			(--增加列
				column = lv.ColumnHeaders.add() 
				column.text = i[1]
			)
			LV_FIRST = 0x1000
			LV_SETCOLUMNWIDTH = (LV_FIRST + 30) 
			for i = 0 to layout_def.count-1 do 
			windows.sendMessage lv.hwnd LV_SETCOLUMNWIDTH i layout_def[1+i][2]
	)
	fn fillInSpreadSheet_RW lv = --当选择场景物体时，列表中的也相应选中(Bip骨骼需加$'name'单引号)
	(	--配合下方updateRoll函数，和registerRedrawViewsCallback updateRoll注册重画窗口回应
		try(
			for i in lv.ListItems do
			(
				drv = getnodebyname i.ListSubItems[1].Text 
				if drv.isselected == true then i.Selected = true
				else i.Selected = false
			)
		)catch()
	)
	fn fillInSpreadSheet lv = --该函数用于添加文字到列表的每个子列里
	(
	 	lv.ListItems.clear() --清除列表项
		local index=1 --定义序号变量
		for o in objects do (
			local con = o --定义没个物体在下面findItem中使用
			--序号
			li = lv.ListItems.add()
			li.text = index as string
			--add name
			sub_li = li.ListSubItems.add()
			sub_li.text = o.name as string	
			--add type
			if chkSuperC.checked == false then(
				sub_li = li.ListSubItems.add()
				sub_li.text = classof o as string
			)else(
				sub_li = li.ListSubItems.add()
				sub_li.text = superclassof o as string
			)
			--add parent
			sub_li = li.ListSubItems.add() --添加列必须放if外面，在不符合条件时才能添加空列
			if o.parent != undefined then(
				sub_li.text = o.parent.name as string
			)
			--add material
			sub_li = li.ListSubItems.add()
			if o.material != undefined then(
				sub_li.text = o.material as string
			)
			--add isHidden
			sub_li = li.ListSubItems.add()
			if o.isHidden == true then(
				sub_li.text = "*"
			)
			index+=1 --序号递增
		try(	li.Selected = false --避免每次刷新都选中第一个项
			if (findItem (selection as array) con > 0) then li.Selected = true)catch()--通过查找选择中的，设置上次选择的项依然选中
		)--end for o
	)
	fn updateRoll = 
	(
		fillInSpreadSheet_RW axObjList
	)
	--Events-Start---------------------------------
	on rolloutObjList open do
	(
		initListView axObjList --窗口打开时调用列表控件
		fillInSpreadSheet axObjList --将文字放入各子列表
		registerRedrawViewsCallback updateRoll --注册一个函数回调，在MAX窗口中称为重绘
	)
	on rolloutObjList close do
	(
		unRegisterRedrawViewsCallback updateRoll --窗口关闭时注销函数回调
	)
	on axObjList DblClick do( --双击列表项时选择物体
		clearselection()
		for item in axObjList.listItems do if item.selected then 
		(
		objName = item.listSubItems[1].text --获取选中的第1个子列里的名字
		select (getnodebyname objName)
		)
	)
	on btnSelAll pressed do( --选择列表里的全部节点
		for item in axObjList.listItems do item.selected=true --选择全部时用于激活所有节点为选择的
		clearselection()	
		tempNode = #()
		for item in axObjList.listItems do if item.selected then 
		(
			objName = item.listSubItems[1].text
			selectmore (getnodebyname objName)
		)
	)
	on axObjList itemclick item do --点击列表时将第4列里的文字放到文本框控件中
	(
		for item in axObjList.listItems do if item.selected then 
		(
		matTmp=item.listSubItems[4].text --获取第4列中的文字
		edtDisText.text=matTmp
		)
		item.index --返回选中项的序号
		--选择先中的项
		ObjTmp=getNodeByName item.listSubItems[1].text
		select ObjTmp
	)--Events-End
)--ActiveXControl控件运用-End--------------------------------------------------------------
--ActiveXControl控件属性
PROPERTIES:
  .Arrange : ListArrangeConstants( #lvwNone | #lvwAutoLeft | #lvwAutoTop )
  .ColumnHeaders : IColumnHeaders
  .DropHighlight : IListItem
  .DropHighlight : undefined, read-only
  .HideColumnHeaders : boolean
  .HideSelection : boolean
  .Icons : IVBDataObject
  .Icons : undefined, read-only
  .ListItems : IListItems
  .LabelEdit : ListLabelEditConstants( #lvwAutomatic | #lvwManual )
  .LabelWrap : boolean
  .MouseIcon : IPictureDisp
  .MousePointer : MousePointerConstants( #ccDefault | #ccArrow | #ccCross | #ccIBeam | #ccIcon | #ccSize | #ccSizeNESW | #ccSizeNS | #ccSizeNWSE | #ccSizeEW | #ccUpArrow | #ccHourglass | #ccNoDrop | #ccArrowHourglass | #ccArrowQuestion | #ccSizeAll | #ccCustom )
  .MultiSelect : boolean
  .SelectedItem : IListItem
  .SelectedItem : undefined, read-only
  .SmallIcons : IVBDataObject
  .SmallIcons : undefined, read-only
  .Sorted : boolean
  .SortKey : integer
  .SortOrder : ListSortOrderConstants( #lvwAscending | #lvwDescending )
  .View : ListViewConstants( #lvwIcon | #lvwSmallIcon | #lvwList | #lvwReport )
  .OLEDragMode : OLEDragConstants( #ccOLEDragManual | #ccOLEDragAutomatic )
  .OLEDropMode : OLEDropConstants( #ccOLEDropNone | #ccOLEDropManual )
  .Appearance : AppearanceConstants( #ccFlat | #cc3D )
  .BackColor : OLE_COLOR
  .BorderStyle : BorderStyleConstants( #ccNone | #ccFixedSingle )
  .Enabled : boolean
  .Font : IFontDisp
  .ForeColor : OLE_COLOR
  .hWnd : OLE_HANDLE
  .AllowColumnReorder : boolean
  .Checkboxes : boolean
  .FlatScrollBar : boolean
  .FullRowSelect : boolean --false选择的反色只显示在序号
  .GridLines : boolean
  .HotTracking : boolean --热跟踪，鼠标放选项上会变手指
  .HoverSelection : boolean --鼠标盘旋选择
  .Picture : IPictureDisp
  .PictureAlignment : ListPictureAlignmentConstants( #lvwTopLeft | #lvwTopRight | #lvwBottomLeft | #lvwBottomRight | #lvwCenter | #lvwTile )
  .ColumnHeaderIcons : IVBDataObject
  .ColumnHeaderIcons : undefined, read-only
  .TextBackground : ListTextBackgroundConstants( #lvwTransparent | #lvwOpaque )
METHODS:
  .FindItem sz:string Where:undefined Index:undefined fPartial:undefined
  .GetFirstVisible()
  .HitTest x:float y:float
  .StartLabelEdit()
  .OLEDrag()
  .Refresh()
EVENTS:
  on <control_name> BeforeLabelEdit Cancel:integer do ( ... )
  on <control_name> AfterLabelEdit Cancel:integer NewString:string do ( ... )
  on <control_name> ColumnClick ColumnHeader:ColumnHeader do ( ... )
  on <control_name> ItemClick Item:ListItem do ( ... )
  on <control_name> KeyDown KeyCode:integer Shift:integer do ( ... )
  on <control_name> KeyUp KeyCode:integer Shift:integer do ( ... )
  on <control_name> KeyPress KeyAscii:integer do ( ... )
  on <control_name> MouseDown Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> MouseMove Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> MouseUp Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> Click do ( ... )
  on <control_name> DblClick do ( ... )
  on <control_name> OLEStartDrag &Data:DataObject &AllowedEffects:integer do ( ... )
  on <control_name> OLEGiveFeedback &Effect:integer &DefaultCursors:boolean do ( ... )
  on <control_name> OLESetData &Data:DataObject &DataFormat:integer do ( ... )
  on <control_name> OLECompleteDrag &Effect:integer do ( ... )
  on <control_name> OLEDragOver &Data:DataObject &Effect:integer &Button:integer &Shift:integer &x:float &y:float &State:integer do ( ... )
  on <control_name> OLEDragDrop &Data:DataObject &Effect:integer &Button:integer &Shift:integer &x:float &y:float do ( ... )
  on <control_name> ItemCheck Item:ListItem do ( ... )

--format--------------------------------
--运用format读取编辑INI
--\t --添加缩进
function loaddate = (
	f = openfile ("$UI\\cstool.ini")

	if f != undefined then 
	   try
		  (
	   dialog_x=readvalue f;dialog_y=readvalue f;
	   mystarttime =readvalue f; myendtime =readvalue f; myrangetime =readvalue f; mymovetime =readvalue f;myaddtime =readvalue f;    
	   bspeed=readvalue f;
	   filepath=readLine f --读取整行
	   autotimelimit=readvalue f
	   bipnumlimit =readvalue f
	   format "%\t%\n" dialog_x dialog_y 
	   format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime 
	   format "%\n" bspeed 
	   format "%\n" filepath  
	   format "%\n" autotimelimit
	   format "%\n" bipnumlimit  
	   close f 
	  ) 	catch()
	  else 
	  try( 

	   f=createFile("$ui\\cstool.ini")
 	   format "%\t%\t%\n" dialog_x dialog_y to:f
 	   format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime to:f
	   format "%\n" bspeed to:f
	   format "%\n" filepath  to: f
	   format "%\n" autotimelimit to:f
	   format "%\n" bipnumlimit  to:f
	   close f
	  
	  )catch() 
   )
--通过format写入到ini文件--下面的参数为全局变量
function savedate = (
	   f=createFile("$ui\\cstool.ini")
 	   format "%\t%\n" dialog_x dialog_y to:f
 	   format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime to:f
	   format "%\n" bspeed to:f
	   format "%\n" filepath  to: f
	   format "%\n" autotimelimit to:f
	   format "%\n" bipnumlimit  to:f
	   close f
    )
--控件参数变化时改变变量，再运行保存函数
on spn1 changed val do(
	mystarttime = val
	savedate()
)
--cstool.ini 文件内容--------
218.0	147.0
0	35	50	10	10
1
C:\Program Files (x86)\Autodesk\3ds Max 9\
3
30
--cstool.ini 文件内容--------end
--format--------------------------------end
--打开修改MaxStartUI.cui文件，添加t里的文字 参考openfile的mode:"a"为添加文字
fi=getdir #UI+"DefaultUI.cui"
f = openfile fi mode:"a"
t="\n[OOX_Toolbars]\nRank=1\nSubRank=2\nHidden=0\nFRect=335 404 393 456\nDRect=1151 0 1187 30\nDRectPref=2147483647 2147483647\n-2147483648 -2147483648\nDPanel=1\nTabbed=0\nTabCt=0\nCurTab=-1\nCurPos=1 1151 0 1187 30\nCType=1\nToolbarRows=1\nToolbarType=3\nItemCount=1\nItem0=2|0|0|31|3|647394|oox_Outline`oox_Tools|0|0|\"oox_Outline\"|\"oox_Outline\"|-1|"
format "%" t to:f
close f
--imgTag按钮用法
imgTag uiMenu "" bitmap:(openBitMap "$ui\Icons\UT_menu.bmp") pos:[254,0] tooltip:"功能"

on uiMenu mouseover do( --鼠标停放
	uiMenu.bitmap = (openBitMap "$ui\Icons\UT_menuo.bmp")
)
on uiMenu mouseout do( --鼠标移开
	uiMenu.bitmap = (openBitMap "$ui\Icons\UT_menu.bmp")
)
on uiMenu mousedown do( --鼠标按下
	uiMenu.bitmap = (openBitMap "$ui\Icons\UT_menud.bmp")
)
on uiMenu mouseup do( --鼠标松开
	uiMenu.bitmap = (openBitMap "$ui\Icons\UT_menuo.bmp")
)
on uiMenu click do( --点击实现功能
	popupMenu ConfigCusmenu
)
on uiMenu rightclick do( --右键点击实现功能
	popupMenu ConfigCusmenu
)
--============================
--将ms生成mse加密文件
encryptScript "dts_utility.ms"
--打开选中物件属性
max properties
--加选物体
selectmore $
--减选物体
deselect $
--选择物体的子级
max select child
--选择物体的父级
max select parent
--获取文件是否存在，返回：“ture 或 false”
doesFileExist ".\Models\model1_1.bmp"
--判断max文件是否存在，注意斜杠写法！返回：“ture 或 false”
isMaxFile "$scenes/ca_test1.max" --returns true if file exists
--获取max文件里面的模型名
getMAXFileObjectNames "f:\Files\ScriptsIDIR\oox_Models\Models\model1_1.max"
--保存节点到新max文件
saveNodes <node_collection> <filename_string> [quiet:<bool>]
-----例-将选择的物体一个个另存为新max文件----startNum 为起始编号 model4_1.max (model'modIndex'_'startNum'.max)
startNum=1	--设置起始编号
modIndex="4"	--设置模型库类编号
o=1
for i=startNum to (selection.count+startNum-1) do (
	selection[o].name = ("model"+modIndex+"_"+i as string)
	saveNodes selection[o] ("f:\Files\ScriptsIDIR\oox_Models\max\model"+modIndex+"_"+i as string+".max") quiet: true
	o+=1
)
--获取名称
file="g:\\subdir1\\subdir2\\myImage.jpg"
filenameFromPath file -- returns: "myImage.jpg"
getFilenamePath file -- returns: "g:\subdir1\subdir2\"
getFilenameFile file -- returns: "myImage"
getFilenameType file -- returns: ".jpg"
pathIsNetworkPath "c:\\temp\\test.txt" --returns: false
pathIsNetworkPath "\\\\someserver\\temp\\test.txt" --returns: true

--获取文件夹里所有max文件 getFiles
files = getFiles "c:\\foo\\*.max"
--获取文件类型 返回：".dds"
getFilenameType "emplate\Documents\3dsmax\scenes\aaa.dds"
--快速打开指定文件夹下的max文件
getMAXOpenFileName filename:"model1_1.max" dir:"$scripts\\Models\\"
--复制文件到当前场景文件夹
copyFile "..\Models\model1_1.bmp" (maxfilepath+"cccmodel1_1.bmp")
--删除文件
deleteFile (maxfilepath+"BlackBoasRabbi_01.dds")
--对齐排列按钮等UI组件，across:列数 align:停靠:#center offset:位移
button aa "aa" across:2 align:#left offset:[-8,0]
button bb "bb" align:#left offset:[-8,0]	--第一个设置为2列时,下面就不用再设置列数,会直接跟在上面的组件右边
--快速打印出指定目录里的所有文件
ff=getFiles "f:\Files\ScriptsIDIR\oox_Models\Models\*.*"
for i in ff do (
	print ("File \""+i)
)
--复制并根据max文件名+_01保存贴图，删除原贴图，并命名选择的模型名和场景文件名一样
nameTmp= filterstring maxfilename "."
newname=(nameTmp[1]+"_01.dds")
oldTeture=$.name+"_01.dds"
if (doesFileExist (maxfilepath+newname))==false then(
	copyFile (maxfilepath+oldTeture) (maxfilepath+newname)
	deleteFile (maxfilepath+oldTeture)
	$.name=nameTmp[1]
	----------指定新复制的贴图
	$.material.diffusemap.bitmap=(openBitMap (maxfilepath+newname))
	--也可写成：(贴图与模型相同目录时可直接写贴图名称)
	$.material.diffusemap.filename = newname
)else(	qq=yesNoCancelBox "贴图文件已存在,是否确定要覆盖"
	if qq==#yes do(
		copyFile (maxfilepath+oldTeture) (maxfilepath+newname)
		deleteFile (maxfilepath+oldTeture)
		$.name=nameTmp[1]
		$.material.diffusemap.bitmap=(openBitMap (maxfilepath+newname))
	)
)
--定义字符串变量时注意\反斜杠的写法！！！注意:凡是遇到反斜杠前是特殊符号（如："*）前面的斜杠要双写\\
savePath=("f:\\Files\\ScriptsIDIR\\oox_Models\\max\\")
--设置选择尺寸
renderWidth = 80
renderHeight = 80
--设置渲染背景图
environmentMap = Bitmaptexture fileName:"D:\Program Files\Autodesk\3ds Max 9\Scripts\TmpScene\BG.bmp"
--修改UI内容的方法，
	rollout test "Test" (
	group "Group" (
	button pressme "Press Me"
	))
	createDialog test
	test.controls
	test.controls[1].caption = "XXX" --this is the GroupStartControl修改了Group的名称
	test.controls[3].caption = "Test me" --this is the GroupEndControl 同样修改了Group的名称
	test.controls[2].caption = "buttom name" --修改了按钮的名称
--设置所有Rollout里的UI元素为不可用。foo为UI名称
for c in foo.controls do c.enabled = false
--判断脚本窗口是否打开
if saveAniTime_Rollout.open --打开返回true
--修改rollout的抬头名称
Model_4_rollout.title = "test"
--修改rcMenu里的菜单选项名字
myrcMenu.myMenuItem.text="test"
--创建文件夹，all:true 创建所有子文件夹
makedir "d:\aaa\bbb\ccc\dd" all:true
--拖拉创建物体 Box
StartObjectCreation Box
--获取指定文件夹里的所有文件夹，返回为数组 子目录
getDirectories "$scripts\\*"
--imgTag图像按钮可以设为空
on help1_img mousedown do(help1_img.bitMap = null)
--该函数用于获取数组里的最大数
fn GetMaxNum NUMARRAY = (
	nn = 1
	for n in NUMARRAY do(
		if n > nn then(
			nn = n
		)
	)
	return nn
)
tmpNumAry = #(1,4,6,8,22,88,67,5)
GetMaxNum tmpNumAry --返回:88
--随机选择不同的七个数（36选7）
SNum=#()
Nums = for i = 1 to 36 collect i
RR = random 1 Nums.count
for i = 1 to 7 do(
	while (finditem Nums RR)==0 do RR = random 1 Nums.count
	FNM = finditem Nums RR
	deleteitem Nums FNM
	append SNum RR
)
SNum
--获取场景属性数
fileProperties.getNumProperties #custom
	fn getMaxV = (
		if fileProperties.findProperty #contents "Headers" > 0 then(
			a = fileproperties.getPropertyValue #contents (fileProperties.findProperty #contents "Headers")
			b = fileProperties.getItems a[1]
			maxVer.text = b[1]
		)else(maxVer.text = "     Max 文件版本")
	)
	--添加场景文件属性
	fileProperties.addProperty #custom "R8D_CustemCameraScale" glScale_spn.val
	--删除属性
	fileProperties.deleteProperty <set_name> <prop_name_string> 
--场景单位设置#Inches #Feet #Miles #Millimeters #Centimeters #Meters #Kilometers
units.SystemType = #Inches
	--场景显示单位
	units.DisplayType = #Metric
	units.MetricType = #meters
--获取保存路径
getSavePath [caption:<window_caption_string>] [initialDir:<pathname>]
--保存\打开文件窗口 types:"Data(*.dat)|*.dat|Excel(*.csv)|*.csv|All|*.*|"
getsavefilename caption:"打开R8D全局设置" filename:("d:\\"+"GlobalSet.r8d") types:"R8D(*.r8d)|*.r8d|All|*.*|"
getOpenFileName caption:"打开R8D全局设置" filename:("d:\\"+"*.R8D") types:"Data(*.dat)|*.dat|Excel(*.csv)|*.csv|All|*.*|"
--保存、打开设置函数例子----------
fn saveGlobalSet = (
	saveSet = getsavefilename caption:"保存R8D全局设置" filename:("d:\\"+"GlobalSet.r8d") types:"R8D(*.r8d)|*.r8d|All|*.*|"
	fName = filterString saveSet "\\"
	fNnoTyp = filterString fName[fName.count] "."
	f = createFile saveSet
	format "%\t%\t%\t%\t%\n" ("\""+fNnoTyp[1]+"\"") 35 5 7.4 15 to:f	--注意保存字符要加双引号一起保存，才能读取字符
	format "%\t%\n" renderWidth renderHeight to:f
	close f
)
global lsetName,Deg,Hei,Sca,Fov,RWid,RHei
fn loadGlobalSet = (
	f = openfile (getOpenFileName caption:"打开R8D全局设置" filename:("d:\\"+"*.r8d") types:"R8D(*.r8d)|*.r8d|All|*.*|")
	if f != undefined then
		try(
			format "%\t%\t%\t%\t%\n" (lsetName=readvalue f) (Deg=readvalue f) (Hei=readvalue f) (Sca=readvalue f) (Fov=readvalue f)
			format "%\t%\n" (RWid=readvalue f) (RHei=readvalue f)
			close f
		)catch()
)
------------------------保存、打开设置函数例子----------END
--创建Utilities菜单到工具条-----------
utility foo "Utility"
(
local var1, var2
checkbox enable "Enable"
rollout setup "Setup" -- local rollout
(
local var3
button doit "Execute" enabled:false
on doit pressed do 
(
var3 = var1 + var2
) 
)--end rollout
function frab a b = (var1 = b-a; var2 = a*b)
on enable changed state do 
(
frab 10 20
if state then
(
  addRollout setup
  setup.doit.enabled = true
)
else (
  removeRollout setup
	max modify mode
)
)--end on enable handler 
)--end utility
createDialog foo
----------------创建Utilities菜单到工具条-----------END
--设置视窗绽放
viewport.zoom 7
	--缩放后刷新视窗
	completeredraw()
--进度条控件
progressBar load_pro color:(color 215 50 70) pos:[40,309] width:310 height:18
for i = 1 to 500 do(
	load_pro.value = 100.*i/500
)
--单项选择控件
radioButtons rdo1 "选择保存路径" pos:[29,9] width:110 height:30 labels:#("max文件路径", "指定输出路径") default:1 columns:2
rdo1.state = 1
on rdo1 changed state do()
on rdo1 rightclick do()
--读取打开的文件信息（可以把不要的信息不指定给变量直接readline f跳过这一行）
f = openfile ((getdir #help)+"\Backburner_.chm") mode:"r+" --该模式可读取写入
aaa = readvalue f --读取数值
bbb = readline f  --读取下一行，返回字符串
ccc = readchar f  --读取一个字符
ddd = readchars f 4 --读取指定4个字符数（包括回车也算一个字）
eof f  --判断文件里是否还有信息未读取，如果全部读取返回 true

skipToNextLine f --跳过一行读取下一行，回车的空行不算
filePos f  --返回文件总字数

--获取当前渲染器
renderers.production
renderers.current
--设置渲染器
renderers.production = Default_Scanline_Renderer()
renderers.production = mental_ray_renderer()
--设置默认渲染器的Filter属性
scanlineRender.antiAliasFilter = Catmull_Rom()
	--修改 Cook Variable 的 Filter Size 属性
scanlineRender.antiAliasFilter = Cook_Variable()
scanlineRender.antiAliasFilterSize = 1
--渲染属性设置
	--高级照明Common->Acvanced Lighting (Set\Get)
	RadiosityPreferences.useAdvancedLighting = true
	RadiosityPreferences.computeAdvancedLighting = true
--设置MentalRay渲染属性
	--Final Gather->Enable Final Gather 开关 (Set\Get)
	renderers.production.FinalGatherEnable2 = true
	--Final Gather->Rays per FG Point FG光子数 Draft=50 ; Low=150 ; Medium=250 ; High=500 ; VeryHigh=10000 (Set\Get)
	renderers.production.FinalGatherAccuracy = 500
	--Final Gather->Advanced->Noise Filtering 0=None;1=Standard;2;3;4 (Set\Get)
	renderers.production.FinalGatherFilter=2
	--GI->Global Illumination (GI) (Set\Get)
	renderers.production.GlobalIllumEnable = true
	
--当渲染完成后执行命令....
bm = render cancelled:&wasCancelled
if (not wasCancelled) do ....
	--或者：
if wasCancelled == false do ....
--运用DOS命令关机操作
doscommand "shutdown -s -f -t 20"
doscommand "f:\Files\maxscript.chm"
--打开网页链接可以直接用start
doscommand "start http://iwiki.woa.com/pages/viewpage.action?pageId=377885051"
doscommand "start explorer http://blog.sina.com.cn/s/blog_753586a60101fykg.html"
将上面的脚本保存名为“ shutdown.ms（这就是3dsmax的脚本控制文件的格式）”，或者起你喜欢的名字，尽可能的使用英文字符；
然后启动你的3dsmax软件，进入到渲染设置面板；
打开Scripts（脚本）卷展栏，选择点击Post-Render下的“File..”按扭；
选择刚才建立的shutdown.ms文件
--显示和关闭Bitmap预览 Close the VFB
bm=(bitmap renderwidth renderheight color:red)
render camera:$RCCC outputwidth:renderWidth outputheight:renderHeight vfb: SRView outputfile:"d:\file.png" frame:1 pos:#vfb_upper_left to:bm
display bm
unDisplay bm
--将窗口停放到右边
	createdialog saveAniTime_Rollout
	cui.RegisterDialogBar saveAniTime_Rollout style:#(#cui_dock_right,#cui_dock_top, #cui_floatable)
	cui.DockDialogBar saveAniTime_Rollout #cui_dock_right
	--注册窗口的时候用#cui_max_sized样式可使窗口放在最底部，靠左边会在最左边，靠右则在最右边。
	cui.RegisterDialogBar saveAniTime_Rollout style:#(#cui_max_sized)
	--打开窗口前先尝试取消注册窗口并关闭
	try (	cui.unRegisterDialogBar saveAniTime_Rollout)catch()
	try (	destroydialog saveAniTime_Rollout)catch()
	
--跳出循环 exit 读取未知行数，用eof判断是否还有下一行
for i in 1 to 1000 do(
	if eof F == false then
		format "%\n" (readline F) to:D
	else
		exit
)
--创建新窗口函数newRolloutFloater
	theNewFloater = newRolloutFloater "Spring Magic V0.7" 210 300
	addRollout splineAnime theNewFloater
	--关闭窗口
	closeRolloutFloater theNewFloater
--Vray Enable built-in Frame Buffer 属性名
renderers.production.output_on
--继续执行下一循环 (必需放在循环中)
continue
--continue 在循环中跳到下一次循环
for i=1 to 8 do (if i == 5 do continue ; print i) -- prints 1..4, 6..8
--exit 终止循环
for i=1 to 8 do (if i == 5 do exit ; print i) -- prints 1..4 undefined
--获取物体节点的User-Defined属性object properties
getUserPropBuffer <node>
setUserPropBuffer <node> <string>
	--获取指定属性值
	getUserProp <node> <propertie_string>
	--设置指定属性值
	setUserProp <node> <propertie_string> <value>
	setUserProp $ "VRay_Matte_Alpha" -1
	setUserProp $ "VRay_Matte_Enable" true
	--设置模型阴影不接收GI阴影
	setUserProp $Plane01 "VRay_GI_Receive" false
	--Vrays属性列表
		setUserProp o "VRay_MoBlur_GeomSamples" 2
		setUserProp o "VRay_GI_Generate" True
		setUserProp o "VRay_GI_Receive" True
		setUserProp o "VRay_GI_Multipier" 1.000000
		setUserProp o "VRay_GI_GenerateMultipier" 1.000000
		setUserProp o "VRay_GI_SubdivsMultiplier" 1.000000
		setUserProp o "VRay_Caustics_Generate" True
		setUserProp o "VRay_Caustics_Receive" True
		setUserProp o "VRay_Caustics_Multipier" 1.000000
		setUserProp o "VRay_MoBlur_DefaultGeomSamples" True
		setUserProp o "VRay_Matte_Enable" True
		setUserProp o "VRay_Matte_Alpha" 0
		setUserProp o "VRay_Matte_Shadows" False
		setUserProp o "VRay_Matte_ShadowAlpha" False
		setUserProp o "VRay_Matte_ShadowColor" [0,0,0]
		setUserProp o "VRay_Matte_ShadowBrightness" 1.000000
		setUserProp o "VRay_Matte_ReflectionAmount" 1.000000
		setUserProp o "VRay_Matte_RefractionAmount" 1.000000
		setUserProp o "VRay_Matte_GIAmount" 1.000000
		setUserProp o "VRay_Matte_GI_OtherMattes" True
		setUserProp o "VRay_GI_SurfaceID" 0
		setUserProp o "VRay_GI_VisibleToGI" False
		setUserProp o "VRay_GI_VisibleToReflections" False
		setUserProp o "VRay_GI_VisibleToRefractions" False
		setUserProp o "VRay_Secondary_Matte_Enable" False
		setUserProp o "VRay_MoBlur_Override" False
		setUserProp o "VRay_MoBlur_Override_Duration" 1.000000
--两个数组成员对比，注意被挑选循环放外面
	for ro in ROName do(	--被挑选成员
	for ao in AllSS do(
		if ao == ro do(
			deleteitem AllSS (finditem AllSS ao)
		)
	))
--检查Rollout窗口是否打开
if R8DSet_rollout.open == true do
--调用RappaTools3.ms里的函数，RappaTools3.ms放到Startup里自启动
::RappaTools3.validobjfunc()
	--函数在RappaTools3.ms里定义，放在结构里
	struct RappaTools3 (
		fn validobjfunc = (),  --！注意多个函数前面的函数要加逗号
		fn validobjfunc2 = ()
	)
--$plugcfg目录等于(getdir #plugcfg)
setIniSetting ("$plugcfg\\rt3_settings.ini") "Settings" "Rappatools3UI" "Closed"
--按钮运行函数配合快捷键 例子：
fn Quadrifyfunc ctrl:keyboard.controlpressed shift:keyboard.shiftpressed alt:keyboard.altpressed selLevel:subobjectlevel =(
	if shift then (
		if selLevel == 1 then alledges = ::RappaTools3.EPEUV (::RappaTools3.cursel.getSelection #Vertex)
		else if selLevel == 2 or selLevel == 3 then alledges = ::RappaTools3.cursel.getSelection #Edge
		else if selLevel == 4 or selLevel == 5 then alledges = ::RappaTools3.EPEUF (::RappaTools3.cursel.getSelection #Face)
		else alledges = #{}
	)
	if (not ctrl) and (not shift) then
	else
		if (ctrl) and (not shift) then
)
--判断函数中带冒号的参数是否有运用，用 unsupplied
	fn show this textColor: time: offset: horizontal: vertical: = (
		if textColor == unsupplied then textColor = white;
		if time == unsupplied then time = 500;
		if offset == unsupplied then offset = [0,0];
		if horizontal == unsupplied then horizontal = #middle;
		if vertical == unsupplied then vertical = #center;
		message = ::RT3Stuff.info() message.display this textColor:textColor time:time offset:offset horizontal:horizontal vertical:vertical
	)
--跨脚本调用Rollout UI参数方法
rollout oxTools "test" ()
struct oxTui (
	Test = TestT, --！！结构中有多个成员要用逗号分隔！！
	Tui = oxTools  --如此设置在其它脚本中才能获取这个UI参数（getDialogPos ::oxTui.Tui）
)
::oxTui = oxTui()
	--其它脚本中获取调用
	getDialogPos ::oxTui.Tui
--case / of 事件容器 的应用
	on addmodifiers selected i do (
		undo "Add Modifier" on (
			addmodifiers.selection = 1
			case i of (
				1: ::RappaTools3.show "Quick add an modifier."
				2: Try( AddMod EditPolyMod ) Catch( ::RappaTools3.show "Error!" textColor:red )
				3: Try( AddMod FFDBox ) Catch( ::RappaTools3.show "Error!" textColor:red )
			)
		)
	)
	--示例2
	case intersect_c.state of
	(
		true:(SetAverageNormalsTwo ObjSel)
		false:(SetAverageNormalsTwoSpeedup ObjSel)
	)
	--示例3
	fn lablelStatus lbl status: #disabled = 
	(
		case status of
		(
			#disabled:
			(
				bgColor = dotnetColor.FromArgb 255 229 153
				fgColor = dotnetColor.FromArgb 215 144 0
				txt = _DISABLED
			)
			#notfound:
			(
				bgColor = dotnetColor.FromArgb 147 196 125
				fgColor = dotnetColor.FromArgb 56 118 79
				txt = _NOTFOUND
			)
		)
	)
--底部信息栏面板显示开关
	statusPanel.visible = true
	--时间栏
	trackbar.visible = true
	timeSlider.SetVisible true
	
--素材库应用方法
	global RT3Stuff
	try DestroyDialog ::RT3Stuff.layout Catch()
	--定义结构体
	struct RT3Stuff (
		colorsload, colorssave, layout, roNotify, CpList
	)
	::RT3Stuff = RT3Stuff()
	--函数创建UI
	fn Layoutfunc = (
		try destroyDialog ::RT3Stuff.layout Catch()
		RT3Stuff.layout = rollout layout "RT3: Viewport Layout"
		(
			......
		)
		createDialog ::RT3Stuff.layout style:#(#style_SysMenu, #style_ToolWindow)
	)
--这样就可以在其它脚本访问::RT3Stuff.layout 里的元素

--保存
renderpresets.SaveAll 0 ("e:\Works\Pro_Game\EffectWork\JiDi_R_ps.rps")
--读取一个文件预设，需要LoadCategories获取该预设内容项
renderpresets.Load 0 ("e:\Works\Pro_Game\EffectWork\JiDi_R2_ps.rps") (renderPresets.LoadCategories("e:\Works\Pro_Game\EffectWork\JiDi_R2_ps.rps"))
--完整读取一个文件预设
renderpresets.LoadAll 0 ("e:\Works\Pro_Game\EffectWork\JiDi_R_ps.rps")
--获取当前场景预设类和编号
renderpresets.MapSceneIndexToCategory 0 32	-- "V-Ray Adv  3.00.01"
renderpresets.MapSceneCategoryToIndex 0 "V-Ray Adv  3.00.01"	-- 32
--列出当前预设内容的位数组
renderpresets.SaveCategories 0
--保存指定的预设内容
renderpresets.Save 0 "e:\test.rps " #{32}
--EditablePolydetach
$.EditablePoly.detachToElement #Face keepOriginal:off
$.modifiers[#Edit_Poly].DetachToObject "name"
$.modifiers[#Edit_Poly].ButtonOp #DetachFace
$.modifiers[#Edit_Poly].ButtonOp #DetachFace
$.modifiers[#Edit_Poly].ButtonOp #DetachFace
$.modifiers[#Edit_Poly].ButtonOp #DeleteFace
--判断底层物体属性.baseobject
classof selection[1].baseobject == Editable_Poly
--获取当前时间,除于1000为秒 最高86400000
timeStamp()
--获取系统桌面大小
sysinfo.desktopSize
--获取MAX窗口大小[111,123]
getMAXWindowSize()
--获取MAX窗口位置[111,123]
getMAXWindowPos()
--创建窗口可拖拉大小
createDialog AutoSplit_rollout style:#(#style_titlebar, #style_sysmenu ,#style_resizing)
	--变换窗口大小，限制窗口大小
	on AutoSplit_rollout resized val do(
		if val.x > 179 then(
		ssList_lbx.width = val.x
		)else AutoSplit_rollout.width = 180
		ssList_lbx.height = val.y-21
	)
--计算时间函数T：5000秒
fn getTimeUse_fn T =(
	h = (T as integer/60)/60
	m = T as integer/60
	s = T-60*m
	if m > 60 do(
		m = m - (m as integer / 60)*60
	)
	format "\n%.h %.m %.s" h m s
)
--获取该函数所在脚本的位置和文件名
getSourceFileName()
--系统注册表编辑
Registry Structure
--读取注册表getoxTKey "OOXTOOLS" 
	fn getoxTKey Key = try(
		local type, val, rappaKey
		registry.createKey HKEY_CURRENT_USER ("Software\\oTx\\") accessRights:#all newKeyCreated:&newKeyCreated key:&rappaKey
		if rappaKey != undefined then ( registry.queryValue rappaKey (Key as string) type:&type value:&val )
		registry.closeKey rappaKey
		val --if classof val == String then execute val else val
	)Catch(false)--fn end
--写入注册表setoxTKey "OOXTOOLS" "11000010" Val要转为String
	fn setoxTKey Key Val = try(
		local newKeyCreated , rappaKey
		registry.createKey HKEY_CURRENT_USER ("Software\\oTx\\") accessRights:#all newKeyCreated:&newKeyCreated key:&rappaKey
		if rappaKey != undefined then (
				try(
					registry.setvalue rappaKey (Key as string) #REG_SZ Val ; finalKey=true ;
				)catch(finalKey=false)
		) else finalKey=false ;
		registry.closeKey rappaKey
		finalKey
	)Catch(false)--fn end
--使名字不重复编号numDigits:编号位数 重名
uniqueName "MyRenamedBox" numDigits:4
--删除包含相同名字的物体
if (execute "$wawawa_*.count") > 0 do (execute "delete $wawawa_*")
--位数组bitArray，位数组间可相互计算，操作位数组的函数和数组一样: append join findItem deleteItem copy
#(1,2,3,4,5) as bitArray	-- #{1..5}
--成组group
MySpheres = selection
group MySpheres name:"MyGroup"
--取消组
setGroupOpen fo false
ungroup fo
max group ungroup
--炸开组
explodeGroup $
--判断节点是否是一个组头节点Group
isGroupHead $Group2112600943
--设置为组头节点，设置成功后可以将子成员append到该头节点
setGroupHead <node> <boolean> 
	setGroupHead $dummy01 true
	append $group03.children $dummy01
--一个头节点的组成员数
$G2.children.count
--判断物体是不是组成员
isGroupMember $obj
	--设置物体为组成员（如果设为非组成员，组关闭时仍可单独选择该物体，依然跟随组移动）
	setGroupMember $Box004 true
--返回头节点是否打开的组
isOpenGroupHead <node>
--判断物体是不是打开的组成员
isOpenGroupMember $obj
--设置组开关
setGroupOpen <group_head_node> <boolean> 
--添加物体集或一个物体到现有组里
attachNodesToGroup <node_collection> <targetNode> 
--需要把GroupHead开放：setGroupOpen $Group001 true
detachNodesFromGroup <node_collection> 
--设置组里的物体是否组成员开关
setGroupMember <node> <boolean>
for o in selection do if (isGroupHead o) do setGroupOpen o true 

--Bitmaptexture的Coordinates的Environ和Mapping属性
<Bitmaptexture>.coords.mappingType=2
<Bitmaptexture>.coords.mapping=3

--获取鼠标在屏幕的位置
mouse.screenpos
--Rollout元素点击命令
on cstoolroll lbuttondown pos do
on cstoolroll lbuttonup pos do
on cstoolroll lbuttondblclk pos do
on cstoolroll rbuttondown pos do
--改变鼠标
setSysCur #select
#move
#rotate
#uscale
#nuscale
#squash
#select
#arrow
--编辑物体轴心位置（pivot）
$.objectoffsetpos = [100,0,0]	--轴心保持原位物体偏移
$.pivot = [100,0,0]	--轴心偏移物体保持原位
--获取设置变换轴心
getCoordCenter()
setCoordCenter #system
#local -- Use Pivot Point Center
#selection -- Use Selection Center
#system
--案例：文本改变时创建dropDownlist历史记录选项//////////////
	on typ_edt entered text do(
		PSP = text
		if (substring PSP PSP.count 1) == "\\" do PSP = replace PSP PSP.count 1 ""	--去除结尾斜杠
		CCC = 0
		for i in his_ddl.items do if i == PSP do CCC+=1
		if CCC == 0 then(
			TC=(getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT") as integer
			if TC == 0 then(
				setinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT" "1"
				setinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_1" PSP
			)else(
				setinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT" ((TC+1)as string)
				setinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" ("TYP_"+((TC+1) as string)) PSP
			)
			TYPITM=#()
			TC=(getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT") as integer
			for i =1 to TC do(
				itm=getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" ("TYP_"+(i as string))
				append TYPITM itm
			)
			append TYPITM "--清除历史--"
			his_ddl.items = TYPITM
		)
		his_ddl.selection = (finditem his_ddl.items PSP)
	)
	--下拉列表选择时
	on his_ddl selected item do(
		if item == his_ddl.items.count then(
			if getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT" != "" do
			if (querybox "确定要删除文件夹历史记录吗？" title:"文件列表") then(
				setinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT" ""
				his_ddl.items = #()
			)else(
				his_ddl.selection = (finditem his_ddl.items (getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_text"))
			)
		)else(
			setinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_text" his_ddl.items[item]
			getMaxNum()
			getDr.tooltip = (his_ddl.items[item])
		)
	)
	--UI打开时
	on multRP_rol open do(
		rTYPITM=#()
		TC=(getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_COUNT") as integer
		if TC>0 do(
		for i =1 to TC do(
			itm=getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" ("TYP_"+(i as string))
			append rTYPITM itm
		)
		append rTYPITM "--清除历史--"
		his_ddl.items = rTYPITM
		)
		--下拉列表中默认选择当前指定的
		his_ddl.selection = (finditem his_ddl.items (getinisetting "$plugcfg\oxtools_settings.ini" "MAXFILEPath" "TYP_text"))
	)
--///////////////////
--2014,保存max为2011版本
saveMaxFile (maxfilepath+maxfilename) quiet:true saveAsVersion:2011
<bool>saveMaxFile <filename_string> [saveAsVersion:<integer>] [clearNeedSaveFlag:<bool>] [useNewFile:<bool>] [quiet:<bool>] 
--include 调用其它脚本	
on add_current pressed do
	include "$scripts/GameModelTools/include/add_current.mse"
--修改器属性创建
modPanel.addModToSelection (meshsmooth iterations:0 sepBySmGroups:on) ui:on
--转为字符流（不应用\t之类的特殊字符形式）
stringStream <initial_string>
<string> as stringStream
--批量设置界面里的UI元素enabled参数
for c in testRollout.controls do c.enabled = false
--activeXControl控件显示网页
	rollout DMP_rollout "View DMP File"
	(
		imgTag uiBar "" pos:[0,0] width:640
		activeXControl ie_ax "Shell.Explorer.2" width:620 height:425 align:#center pos:[10,27]
		
		function OpenDmpFile =
		(
			ie_ax.Navigate ( "http://www.cgjoy.com/data/WebHelp/index.htm" )
		)
		on DMP_rollout open do
			OpenDmpFile()
		on DMP_rollout resized newS do(
			ie_ax.width = (newS.x - 20)
			ie_ax.height = (newS.y - 40)
		)
	)
	CreateDialog DMP_rollout style:#(#style_sysmenu,#style_titlebar,#style_minimizebox,#style_maximizebox,#style_resizing) width:630
--位图Gamma值
fileInGamma
fileOutGamma
bitmap 320 240 gamma:displayGamma
--设置Gamma矫正模式
TY=#(#none,#gamma,#LUT)
IDisplayGamma.colorCorrectionMode = #gamma
IDisplayGamma.colorCorrectionMode = #none
IDisplayGamma.colorCorrectionMode = #LUT

render camera:c to:b
--读取txt文本到label组件
	function readAboutFile =
	(
	aboutFile = openFile  ((getDir #scripts) + "\DebrisMaker2\about.txt") mode:#rt
	fileText = readDelimitedString aboutFile "~"
	close aboutFile
	fileText
	)
	
	aboutText = ("  Debris Maker " + DebrisMakerVerString + "\n ?2014 Aaron Dabelow \n" + readAboutFile())
	aboutTextbox.text = aboutText
	
--通过网络检查版本
		if (internet.CheckConnection url:"http://www.cgjoy.com/" force:true ) == true
		then(
			onlineVersionStr =(dotNetObject "System.Net.WebClient").downloadString "http://www.cgjoy.com/data/WebHelp/Vers/r8dver.txt"
			if ::r8dui.RV != onlineVersionStr then (
				if (querybox ("当前版本：R8D v"+::r8dui.RV+"\n检查到可更新版本：R8D v"+onlineVersionStr+"\n是否现在下载更新？") title:"R8D 更新") then(
					doscommand "start explorer http://pan.baidu.com/s/1kTp6HIv"
				)else(
					messagebox "可访问博客查看R8D下载链接（http://blog.sina.com.cn）" title:"R8D" beep:false
				)
			) else (
				messagebox ("您的R8D已经是最新版本..") title:"R8D" beep:false
			)
		)
--菜单创建方式
	rcMenu rc_MainMenu
	(
	subMenu		"设置"
		(
		menuItem	MI_Settings			"自动载入上次用的工具"		enabled:true
		menuItem	MI_RefreshModulesDrop	"刷新工具列表"	enabled:true
		)
	)
	createDialog DebrisMaker 200 20 menu:rc_MainMenu style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing) lockWidth:true
--批量对选择的物体创建选择组
	for o in selection do(
		selectionSets[o.name] = o
	)
--Delete Empty Sets 清除空选择组（效率低）
if selectionSets.count != 0 do for s = selectionSets.count to 1 by -1 where selectionSets[s][1] == undefined do deleteItem selectionSets s
	--Delete all Sets
	for s = selectionSets.count to 1 by -1 do deleteItem selectionSets s
	
--用函数控制菜单是否显示，判决为true时显示
	rcMenu oxToolsMenu (
		fn GetReg = (		(::OOXTOOLSFN.getkkkk ::OOXTOOLSFN.otCDP) != (::OOXTOOLSFN.otCreateKEY ::OOXTOOLSFN.otIOIIOO "kkk")	)
		menuitem aboutot_mi ">>> 注  册 <<<" filter:GetReg
	)
--计算一个物体所在高度与世界座标中心形成的角度
	fn GetDegrees Note =(
		if Note != undefined do(
		adjacentLine = distance [0,0,0] [(Note.pos.x),(Note.pos.y),0]
		hypotenuseLine = distance [0,0,0] Note.pos
		ADeg = adjacentLine/hypotenuseLine
		return (acos ADeg)
		)
	)
--pickButton拾取控件运用函数过滤只拾取相机
	fn cam_filt obj = superclassof obj == camera
	pickButton getCusCam "- None -" tooltip:"拾取一个摄相机" pos:[147,40] width:80 height:16 filter:cam_filt
--求某数的2次方
	pow 3 2 --9
--设置物体XYZ轴
	$.rotation = (eulerangles -90 0 0)
--设置打开UVWMap多材质选择1为棋格
	$.modifiers[#unwrap_uvw].unwrap.setCurrentMap 3
--检查选择的物体多维材质数量
	($.material.materialIDList ).count
--设置EditablePoly面ID 设置为2
	$.EditablePoly.setMaterialIndex 2 1
--polygon:Smoothing Groups 的 ClearAll 按钮命令
	$.EditablePoly.buttonOp #ClearSmoothingGroups
--渲染属性－像素比例
	renderPixelAspect = 1
	
file="g:\\subdir1\\subdir2\\myImage.jpg"
filenameFromPath file -- returns: "myImage.jpg"
getFilenamePath file -- returns: "g:\subdir1\subdir2\"
getFilenameFile file -- returns: "myImage"
getFilenameType file -- returns: ".jpg"

pathIsNetworkPath "c:\\temp\\test.txt" --returns: false
pathIsNetworkPath "\\\\someserver\\temp\\test.txt" --returns: true
--函数可选参数
fn sortObj clk: =( --用法：sortObj clk:"x"
	if clk == unsupplied do clk = false
)
--获取属性名到数组
pp=getpropnames $.material
--使操作可以回退
	undo on
	(::OOXTOOLSFN.attachObj true)
--打开地址目录
try(shellLaunch "Explorer.EXE" "c:\\ff")catch()
--运行系统定时关机命令
shellLaunch "shutdown.exe" " -s -t 60"
	--取消定时关机
	shellLaunch "shutdown.exe" " -a"
--转换旋转单位
$.rotation --(quat 0.00278701 0.0101506 0.0329193 0.999403)
$.rotation as angleaxis	--(angleAxis 3.96122 [0.0806399,0.293698,0.952491])
<angleaxis> as quat
<eulerangle> as quat
<matrix3> as quat
--克隆物体并选择新物体（主意 newNodes:&d 新物体变量要加"&"）
	for i = 1 to cout do(
		maxOps.CloneNodes sourObj offset:[w*i,0,h] cloneType:#instance newNodes:&d
		append bendObj d
	)
	clearSelection()
	for o in bendObj do selectmore o
--获取颜色数组（图像像素）
(getPixels (openbitmap "f:\Untitled-1.png") [1,0] 1)[1]==(color 255 255 255 0)
	--color的alpha属性值
	(color 0 0 0 33).alpha --33.0
--缓存当前场景
	holdMaxFile()
	--还原缓存场景
	fetchMaxFile quiet:true
--获取模型集合
	geo=geometry as array
--设置视窗为指定相机视图
viewport.setCamera $TagCamera
--maxVersion() --靠近的版本MR渲染设置相同
9.0  #(9000, 21, 0)
2008 #(10000, ?, 0)
2009 #(11000, 25, 0)

2010 #(12000, 33, 0)
2011 #(13000, 35, 0)
2012 #(14000, 38, 0)

2013 #(15000, ?, 0)
2014 #(16000, 42, 0)
2015 #(17000, 42, 0)
2016 #(18000, 46, 0)
	fn VersionC =(
		a = maxVersion()
		if a[1] == 18000 then return "MAX 2016" else
		if a[1] == 17000 then return "MAX 2015" else
		if a[1] == 16000 then return "MAX 2014" else
		if a[1] == 15000 then return "MAX 2013" else
		if a[1] == 14000 then return "MAX 2012" else
		if a[1] == 13000 then return "MAX 2011" else
		if a[1] == 12000 then return "MAX 2010" else
		if a[1] == 11000 then return "MAX 2009" else
		if a[1] == 10000 then return "MAX 2008" else
		if a[1] == 9000 then return "MAX 9.0"   else
			return "MAX ????"
	)
--time:2000 为2秒
::OOXTOOLSFN.show "> 请选择两个以上物体 <" textColor:red time:2000 vertical:#center
::OOXTOOLSFN.show "> 快速创建隐藏显示选择组 <" textColor:green time:2000 vertical:#top

--获取物体的基础属性
<node>.baseObject
--设置物体 visibility为0
$.visibility = false
	animate on
	(
	at time 0 $foo.visibility = on
	at time 35 $foo.visibility = off
	at time 57 $foo.visibility = on
	)
--设置为默认旋转控制
$.rotation.controller = Euler_XYZ ()
--设置为LookAt指向约束
$.rotation.controller = LookAt_Constraint ()
	--添加约束目标（如下物体名字带有“-”时的写法需要加单引号包裹）
	$.rotation.controller.appendTarget $'Camera-render' 60
--拾取有材质的物体过滤函数
fn shapeFilt o = (superClassOf o == GeometryClass and o.material != undefined)
mat=pickObject prompt:"拾取一个有材质的物体" filter:shapeFilt

filein (getdir #startupScripts+"\oxTOOLSfn.ms")
--设置自启动项
 setINISetting  (getMAXIniFile()) " MAXScript " " LoadStartupScripts " " 0 "  
 setINISetting  (getMAXIniFile()) " MAXScript " " LoadSaveSceneScripts " " 0 "  
 setINISetting  (getMAXIniFile()) " MAXScript " " LoadSavePersistentGlobals " " 0 "
--创建平面并转换为editPoly
p = convertToPoly(Plane())
p.GetEdgeVertex 4 2
--获取mesh物体顶点位置
getVert $Box003 50
--判断物体的底层物体属性
if ((classOf $.baseobject) == Editable_Poly)
--获取物体当前修改器类型
modPanel.getCurrentObject()
--获取物体的编辑器数组
$.modifiers
--转换模型为poly mesh
macros.run "Modifier Stack" "Convert_to_Mesh"
macros.run "Modifier Stack" "Convert_to_Poly"
--跳转到编辑面板
max modify mode
--获取模型选择的顶点号数组
getVertSelection $
---------------------------------
	on UPdat pressed do(
		if (internet.CheckConnection url:"http://www.cgjoy.com/" force:true ) == true
		then(
			try(onlineVersionStr = (dotNetObject "System.Net.WebClient").downloadString "http://www.cgjoy.com/data/WebHelp/Vers/r8dver.txt")catch()
			if onlineVersionStr != undefined then(
			if (GetTextExtent onlineVersionStr).x < 50 then(
			upMsg = (dotNetObject "System.Net.WebClient").downloadString "http://www.cgjoy.com/data/WebHelp/Vers/r8dmsg.txt"
			if (GetTextExtent upMsg).x > 9000 do upMsg="..."
			DDL = (dotNetObject "System.Net.WebClient").downloadString "http://www.cgjoy.com/data/WebHelp/Vers/r8ddlo.txt"
			if (GetTextExtent DDL).x > 9000 do DDL=""
			if RVers != onlineVersionStr then (
				if (querybox ("当前版本：\tR8D v"+RVers+"\n可更新版本：\tR8D v"+onlineVersionStr+"\n\n更新内容：\n"+upMsg+"\n\n是否现在下载更新？( 安装完请重启MAX )") title:"R8D 更新") then(
					if DDL!="" do doscommand ("start explorer "+DDL)
				)else(
					messagebox "可访问博客查看R8D下载链接（http://blog.sina.com.cn/qinlaowoniu）" title:"R8D 更新" beep:false
				)
			) else (
				messagebox ("您的R8D已经是最新版本 ...^_^") title:"R8D 更新" beep:false
			)
			)else
			messagebox ("网络暂时不可用，稍候再试！") title:"R8D 更新"
			)else
			messagebox ("网络暂时不可用，稍候再试！") title:"R8D 更新"
		)else(
			messagebox ("检查您的网络连接是否正常！") title:"R8D 更新"
		)
	)