using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(DStest))]
public class DiscSampling_Editor : Editor
{
    public override void OnInspectorGUI()
    {
            GameObject go = GameObject.Find("Shape");
            DStest other = (DStest)go.GetComponent(typeof(DStest));
        base.OnInspectorGUI();  //此行代码让原本存在脚本 DStest.cs 中的变量先显示出来。
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("G o"))
        {
            other.Abc();
        }
        if (GUILayout.Button("Delete"))
        {
            other.DelAbc();
        }
        if (GUILayout.Button("Confirm"))
        {
            other.ConfirmAbc();
            other.SelConfirm();
        }
        if (GUILayout.Button("RandomRotate",GUILayout.Width(96)))
        {
            other.RotClone();
        }
        GUILayout.EndHorizontal();
    }
}
