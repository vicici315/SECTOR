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
