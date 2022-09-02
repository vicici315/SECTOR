using UnityEngine;
using UnityEditor;
using Sebastian.Geometry;

[CustomEditor(typeof(ShapeC))]
public class ShapeE : Editor
{
    ShapeC shapeC;
    SlectionInfo selectionInfo;
    bool shapeChangedSinceLastRepaint;
    GameObject shapeCom;
    //在脚本Inspector创建UI
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        int shapeDelIndex = -1;
        shapeC.showShapesList = EditorGUILayout.Foldout(shapeC.showShapesList, "Shapes List");
        if (shapeC.showShapesList)
        for (int i=0; i<shapeC.shapes.Count; i++)
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("Shape " + (i + 1));

            GUI.enabled = i != selectionInfo.selectedShapeIndex;
            if (GUILayout.Button("Select"))
            {
                selectionInfo.selectedShapeIndex = i;
            }
            GUI.enabled = true;

            if (GUILayout.Button("Delete"))
            {
                shapeDelIndex = i;
            }
            GUILayout.EndHorizontal();
            if (shapeDelIndex != -1)
            {
                Undo.RecordObject(shapeC, "Delete sphape");
                shapeC.shapes.RemoveAt(shapeDelIndex);
                selectionInfo.selectedShapeIndex = Mathf.Clamp(selectionInfo.selectedShapeIndex, 0, shapeC.shapes.Count - 1);
            }
            if (GUI.changed)
            {
                shapeChangedSinceLastRepaint = true;
                SceneView.RepaintAll();  //刷新场景窗口
            }
        }
        shapeCom = GameObject.Find("Shape");
    }
    void OnSceneGUI()
    {
        Event guiEvent = Event.current;
        if (guiEvent.type == EventType.Repaint)
        {
            Draw();
        }
        //Prevent deselection when left clicking（保持Gameobject选择状态，在左键点击创建点时）
        else if (guiEvent.type == EventType.Layout)
        {
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
        }
        else
        {
            HandleInput(guiEvent);
            if (shapeChangedSinceLastRepaint)
            {
                HandleUtility.Repaint();
            }
        }
    }
    //创建新的形状Shape
    void CreateNewShape()
    {
        Undo.RecordObject(shapeC, "Create shape");
        shapeC.shapes.Add(new Shape());
        selectionInfo.selectedShapeIndex = shapeC.shapes.Count - 1;
    }

    void CreateNewPoint(Vector3 position)
    {
        bool mouseIsOverSelectedShape = selectionInfo.mouseOverShapeIndex == selectionInfo.selectedShapeIndex;  //判断鼠标在线段上时按Shift创建新Shape出错
        int newPointIndex = (selectionInfo.mouseIsOverLine && mouseIsOverSelectedShape) ? selectionInfo.lineIndex + 1 : SelectedShape.points.Count;
        Undo.RecordObject(shapeC, "Add point");
        //shapeC.points.Add(mousePosition); //添加点
        SelectedShape.points.Insert(newPointIndex, position);   //插入点
        //selectionInfo.pointIndex = shapeC.points.Count - 1; //添加点
        selectionInfo.pointIndex = newPointIndex;  //插入点
        selectionInfo.mouseOverShapeIndex = selectionInfo.selectedShapeIndex;
        shapeChangedSinceLastRepaint = true;
        SelectPointUnderMouse();
    }
    void DelPointUnderMouse()
    {
        Undo.RecordObject(shapeC, "Delete point");
        SelectedShape.points.RemoveAt(selectionInfo.pointIndex);
    }

    void SelectPointUnderMouse()
    {
        selectionInfo.pointIsSlected = true;
        selectionInfo.mouseIsOverPoint = true;
        selectionInfo.mouseIsOverLine = false;
        selectionInfo.lineIndex = -1;

        selectionInfo.posAtStartOfDrag = SelectedShape.points[selectionInfo.pointIndex];
        shapeChangedSinceLastRepaint = true;
    }

    void SelectShapeUnderMouse()
    {
        if (selectionInfo.mouseOverShapeIndex != -1)
        {
            selectionInfo.selectedShapeIndex = selectionInfo.mouseOverShapeIndex;
            shapeChangedSinceLastRepaint = true;
        }
    }

    void HandleInput(Event guiEvent)
    {
            Ray mouseRay = HandleUtility.GUIPointToWorldRay(guiEvent.mousePosition);
            float drawPlaneHeight = 0;
            float dstToDrawPlane = (drawPlaneHeight - mouseRay.origin.y) / mouseRay.direction.y;
            Vector3 mousePosition = mouseRay.GetPoint(dstToDrawPlane);
            if (guiEvent.type == EventType.MouseDown && guiEvent.button == 0 && guiEvent.modifiers == EventModifiers.Shift)//3.判断在使用Shift+左键时添加新Shape
            {
                HandleShiftLeftMouseDown(mousePosition);
            }
            if (guiEvent.type == EventType.MouseDown && guiEvent.button == 0 && guiEvent.modifiers == EventModifiers.None)//1.判断鼠标按下 & 2.鼠标左键为 0 3.判断是否有组合键，如：在使用Alt+左键旋转视图
            {
                HandleLeftMouseDown(mousePosition);
            }
            if (guiEvent.type == EventType.MouseUp && guiEvent.button == 0)
            {
                HandleLeftMouseUp(mousePosition);
            }
            if (guiEvent.type == EventType.MouseDrag && guiEvent.button == 0 && guiEvent.modifiers == EventModifiers.None)
            {
                HandleLeftMouseDrag(mousePosition);

                if (shapeCom.GetComponent<DStest>().reflashLine) { 
                    shapeCom.GetComponent<DStest>().displaySphere = false;
                    shapeCom.GetComponent<DStest>().OnValidate();
                    shapeCom.GetComponent<DStest>().OnDrawGizmos();
                }
            }
            if (!selectionInfo.pointIsSlected)
                UpdateMouseOverSelection(mousePosition);
    }

    void HandleShiftLeftMouseDown(Vector3 mousePosition)
    {
        if (selectionInfo.mouseIsOverPoint)
        {
            SelectShapeUnderMouse();
            DelPointUnderMouse();
        }
        else
        {
            CreateNewShape();
            CreateNewPoint(mousePosition);
        }
    }

    void HandleLeftMouseDown(Vector3 mousePosition)
    {
        if (shapeC.shapes.Count == 0)
        {
            CreateNewShape();
        }
        SelectShapeUnderMouse();
        if (selectionInfo.mouseIsOverPoint)    //当鼠标没有碰触创建点时操作创建新点
        {
            SelectPointUnderMouse();
        }
        else
        {
            CreateNewPoint(mousePosition);
        }
        //selectionInfo.pointIsSlected = true;
        //selectionInfo.posAtStartOfDrag = mousePosition; //Undo"Move point":移动时记录拖拽位置
        //needsRepaint = true;
    }
    void HandleLeftMouseUp(Vector3 mousePosition)
    {
        if (selectionInfo.pointIsSlected)
        {
            ////Undo"Move point":Undo时获取拖拽时的初始位置
            SelectedShape.points[selectionInfo.pointIndex] = selectionInfo.posAtStartOfDrag;
            Undo.RecordObject(shapeC, "Move point");
            SelectedShape.points[selectionInfo.pointIndex] = mousePosition;

            selectionInfo.pointIsSlected = false;
            selectionInfo.pointIndex = -1;
            shapeChangedSinceLastRepaint = true;
        }
    }
    void HandleLeftMouseDrag(Vector3 mousePosition)
    {
        if (selectionInfo.pointIsSlected)
        {
            SelectedShape.points[selectionInfo.pointIndex] = mousePosition;
            shapeChangedSinceLastRepaint = true;
        }
    }

    void UpdateMouseOverSelection(Vector3 mousePostion) //更新鼠标悬停点的选择状态
    {
        int mouseOverPointIndex = -1;
        int mouseOverShapeIndex = -1;
        for (int shapeIndex = 0; shapeIndex < shapeC.shapes.Count; shapeIndex++)    //创建多个形状循环
        {
            Shape currentShape = shapeC.shapes[shapeIndex];
            for (int i = 0; i < currentShape.points.Count; i++)
            {
                if (Vector3.Distance(mousePostion, currentShape.points[i]) < shapeC.handleRadius)
                {
                    mouseOverPointIndex = i;
                    mouseOverShapeIndex = shapeIndex;
                    break;
                }
            }
        }
        if (mouseOverPointIndex != selectionInfo.pointIndex || mouseOverShapeIndex != selectionInfo.mouseOverShapeIndex)  //或者 判断形状悬停索引
        {
            selectionInfo.mouseOverShapeIndex = mouseOverShapeIndex;
            selectionInfo.pointIndex = mouseOverPointIndex;
            selectionInfo.mouseIsOverPoint = mouseOverPointIndex != -1;
            shapeChangedSinceLastRepaint = true;
        }
        if (selectionInfo.mouseIsOverPoint)
        {
            selectionInfo.mouseIsOverLine = false;
            selectionInfo.lineIndex = -1;
        }
        else
        {
            int mouseOverLineIndex = -1;
            float closestLineDst = shapeC.handleRadius;
            for (int shapeIndex = 0; shapeIndex < shapeC.shapes.Count; shapeIndex++)    //创建多个形状循环
            {
                Shape currentShape = shapeC.shapes[shapeIndex];
                for (int i = 0; i < currentShape.points.Count; i++)     //i起始值0，避免创建的第一条线无法高亮
                {
                    Vector3 nextPointInShape = currentShape.points[(i + 1) % currentShape.points.Count];
                    float dstFromMouseToLine = HandleUtility.DistancePointToLineSegment(mousePostion.ToXZ(), currentShape.points[i].ToXZ(), nextPointInShape.ToXZ());
                    if (dstFromMouseToLine < closestLineDst)
                    {
                        closestLineDst = dstFromMouseToLine;
                        mouseOverLineIndex = i;
                        mouseOverShapeIndex = shapeIndex;
                    }
                }
            }
            if (selectionInfo.lineIndex != mouseOverLineIndex || mouseOverShapeIndex != selectionInfo.mouseOverShapeIndex)
            {
                selectionInfo.mouseOverShapeIndex = mouseOverShapeIndex;
                selectionInfo.lineIndex = mouseOverLineIndex;
                selectionInfo.mouseIsOverLine = mouseOverLineIndex != -1;
                shapeChangedSinceLastRepaint = true;
            }
        }
    }
    void Draw()
    {
        for (int shapeIndex = 0; shapeIndex < shapeC.shapes.Count; shapeIndex++)    //创建多个形状循环
        {
            Shape shapeToDraw = shapeC.shapes[shapeIndex];
            bool shapeIsSelected = shapeIndex == selectionInfo.selectedShapeIndex;
            bool mouseIsOverShape = shapeIndex == selectionInfo.mouseOverShapeIndex;
            Color deselectedShapeColour = Color.gray;
            //Create Solid Point in click
            for (int i = 0; i < shapeToDraw.points.Count; i++)
            {
                Vector3 nextPoint = shapeToDraw.points[(i + 1) % shapeToDraw.points.Count];
                if (i == selectionInfo.lineIndex && mouseIsOverShape)   //判断鼠标放在线段上，改变线颜色
                {
                    Handles.color = Color.yellow;
                    Handles.DrawLine(shapeToDraw.points[i], nextPoint);
                }
                else  //鼠标不在线上改变点颜色
                {
                    Handles.color = (shapeIsSelected) ? Color.red : deselectedShapeColour;
                    Handles.DrawDottedLine(shapeToDraw.points[i], nextPoint, 4);
                }
                //判断鼠标触碰点时颜色为红色
                if (i == selectionInfo.pointIndex && mouseIsOverShape)
                    Handles.color = (selectionInfo.pointIsSlected) ? Color.yellow : Color.yellow;
                else
                    Handles.color = (shapeIsSelected)?Color.red:deselectedShapeColour;
                Handles.DrawSolidDisc(shapeToDraw.points[i], Vector3.up, shapeC.handleRadius);
            }
    if (shapeChangedSinceLastRepaint)
        {
            shapeC.UpdateMeshDisplay();
        }
            shapeChangedSinceLastRepaint = false;
        }
    }

   void OnEnable()
    {
        shapeChangedSinceLastRepaint = true;
        shapeC = target as ShapeC;
        selectionInfo = new SlectionInfo();
        Undo.undoRedoPerformed += OnUndoOrRedo; //加入 Undo Redo 执行队列；
        Tools.hidden = true;    //选择的时候显示形状
    }
    void OnDisable()
    {
        Undo.undoRedoPerformed -= OnUndoOrRedo; //移出 Undo Redo 执行队列；
        Tools.hidden = false;    //未选择的时候隐藏
    }

    void OnUndoOrRedo() //创建一个形状后，Undo到这个形状消失，能回退到上一个编辑状态的形状（判断形状的数量）
    {
        if (selectionInfo.selectedShapeIndex >= shapeC.shapes.Count || selectionInfo.selectedShapeIndex == -1)
            selectionInfo.selectedShapeIndex = shapeC.shapes.Count - 1;
    }

    Shape SelectedShape
    {
        get
        {
            return shapeC.shapes[selectionInfo.selectedShapeIndex];
        }
    }
    public class SlectionInfo
    {
        public int selectedShapeIndex;  //选择的形状索引
        public int mouseOverShapeIndex; //鼠标悬停在一个形状上的索引
        public int pointIndex = -1;
        public bool mouseIsOverPoint;
        public bool pointIsSlected;
        public Vector3 posAtStartOfDrag;

        public int lineIndex = -1;
        public bool mouseIsOverLine;
    }
}
