# 变量类型
## 基本数据类型
<img src="UEc++.assets\b0809de17a1bbfd5d3092d0e4c70846f.png">

## TCHAR：UE4通过对char和wchar_t的封装

TCHAR就是UE4通过对char和wchar_t的封装
char ANSI编码
wchar_t 宽字符的Unicode编码
使用 TEXT() 宏包裹作为字面值
```cpp
TCHAR* TCharString = TEXT("Hello, World!");
 
	// 引擎字符串(TCHAR*) -> ANSI字符串(char*)
	char* CharString = TCHAR_TO_ANSI(TCharString);
 
	// 引擎字符串(TCHAR*) -> std::string
	std::string str = TCHAR_TO_UTF8(TCharString);
 
	// 引擎字符串(TCHAR*) -> wchar_t*
	wchar_t* WCharString = TCHAR_TO_WCHAR(TCharString);
 
	// ANSI字符串(char*) -> 引擎字符串(TCHAR*)
	TCHAR* TCharString1 = ANSI_TO_TCHAR(CharString);
 
	// wchar_t* -> 引擎字符串(TCHAR*)
	TCHAR* TCharString2 = UTF8_TO_TCHAR(WCharString);
	TCHAR* TCharString3 = WCHAR_TO_TCHAR(WCharString);
```
## FNames：常用作标识符等不变的字符串
常用作标识符等不变的字符串（如：资源路径/资源文件类型/骨骼名称/表格行名等）
比较字符串操作非常快
即使多个相同的字符串，也只在内存存储一份副本，避免了冗余的内存分配操作
不区分大小写
使用
初始化

# 插件ChildSlot操作界面

## 垂直排列中创建多个平行排列

```cpp
//主垂直面板
+ SVerticalBox::Slot().AutoHeight()
    .Padding(2.0f)    //间距
    [
        SAssignNew(Expnv12,SExpandableArea)    //可折疊面板创建
       .AreaTitle(LOCTEXT("v12expn", "AlignParent"))
       .InitiallyCollapsed(true)
       .Padding(2.0f)
       .HeaderContent()[    //折叠面板抬头的本行控件内容
          SNew(SHorizontalBox)
          + SHorizontalBox::Slot()
          .HAlign(HAlign_Left).VAlign(VAlign_Center).FillWidth(30.0f)
          .Padding(2.0f)[
              SNew(STextBlock).Text(LOCTEXT("v12", "层级与对齐："))
            ]
        ].BodyContent()[    //折叠面板里面的控件内容
            SNew(SVerticalBox) //第一行控件内容(多行垂直控件,只有第一行需要加SNew)
            + SVerticalBox::Slot().AutoHeight()
            .Padding(2.0f)    //间距
            [
                SNew(SHorizontalBox)
                + SHorizontalBox::Slot()
                .HAlign(HAlign_Left).Padding(5.0f)
                [
                    SNew(SButton)
                    .Text(LOCTEXT("parent", "设置父子层级"))
                    .ToolTipText(LOCTEXT("parentTT", "选择要设置层级关系的物体，最后选择的为父物体"))
                    .OnClicked(this, &SSlateMain::ParentHelpClicked)
                ]
                + SHorizontalBox::Slot()
                .HAlign(HAlign_Right).VAlign(VAlign_Center).AutoWidth().Padding(2.0f)
                [
                    SNew(STextBlock).Text(LOCTEXT("align", "变换匹配:"))
                ]
            ]
             //第二行控件内容
            + SVerticalBox::Slot().AutoHeight()
            .Padding(2.0f)    //间距
            []
        ]
    ]
```

## 路径获取

```cpp
FPaths::ProjectContentDir()    //可以拿到Content目录的绝对路径

FPaths::ProjectPluginsDir()    //获取Plugins目录
FPaths::FileExists(*(FPaths::ProjectPluginsDir() + "SceneTools_W_P/ST.txt"))
```
