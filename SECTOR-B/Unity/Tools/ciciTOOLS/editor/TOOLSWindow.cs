using System.IO;
using UnityEngine;
using UnityEditor;
using ToolsClass;
using System;
using Application = UnityEngine.Application;
using Random = System.Random;
using System.Collections.Generic;

public class CICITOOLS : EditorWindow {
    Texture2D headerSectionTex;
    Texture2D bodySectionTex;
    Texture2D logoTex;
    Color headerSectionColor = new Color(0.1f,0.15f,0.27f);
    Rect headerSection = new Rect(0f,0f,0f,0f);
    Rect bodySection = new Rect(0f,0f,0f,0f);
    Rect bodySectionB = new Rect(0f,0f,0f,0f);
    //Rect iconSection = new Rect(0f,0f,0f,0f);
    private Vector3 ArrangeVal;
    private Vector3Int RaceVal = new Vector3Int(1,1,1);
    private bool replaceMat = false;
    private bool keepMat = true;
    private bool _disPar = true;
    private bool _disBut = true;
    private float _SlideV = 0.001f;
    private string SaveDataAsset;
    private int _CheckUV;
    private int _CheckFA = 400;
    private Texture2D[] texsTemp;
    private List<GameObject> allGet;
    GUISkin skin;
	WindowData windowData;

    //static CellMatData cellMatData;
    //static WindowData WindowInfo { get { return windowData; } }

    //public static CellMatData ToolsData { get { return cellMatData; } }
    //readonly float iconSize = 40;
    readonly float headHight = 72;
    //string dataPath = "Assets/ciciTOOLS/data/TOOLSsave.asset";

	[MenuItem("ciciTOOLS/TOOLS Window")]
    static void OpenWindow()
    {
        CICITOOLS window = (CICITOOLS)GetWindow(typeof(CICITOOLS));
        window.minSize = new Vector2(230f,390f);
        window.Show();
    }
    void OnEnable()
    {
        skin = Resources.Load<GUISkin>("UI/GUISkin");
        InitTextures();
        //   InitData();
        //SaveData = Application.dataPath+ "/ciciTOOLS/data/MatData";
        SaveDataAsset = "Assets/ciciTOOLS/data/MatData/";
Font ff = (Font)Resources.Load("fonts/MONACO");
       skin.FindStyle("text1").font = ff;
       skin.FindStyle("text2").font = ff;
       skin.FindStyle("text3").font = ff;
        windowData.MatTexsList = windowData.ReadFileList(SaveDataAsset, "ShaderList.txt");
        Debug.Log("ciciTOOLS"+windowData.Ver);
    }
    //public static void InitData()
    //{
    //    //cellMatData = (CellMatData)ScriptableObject.CreateInstance(typeof(CellMatData));
    //}
   void RefreshFont()
    {
        Random ran = new Random();
        int Fcout = ran.Next(29);
       skin.FindStyle("Header").font = (Font)Resources.Load("fonts/"+windowData.FontSize[Fcout,0]);
       skin.FindStyle("Header").fontSize = int.Parse(windowData.FontSize[Fcout,1]);
    }
    void InitTextures()
    {
        headerSectionTex = new Texture2D(1, 1);
        headerSectionTex.SetPixel(0, 0, headerSectionColor);
        headerSectionTex.Apply();

        Random ran = new Random();
        int Fc = ran.Next(5);
        bodySectionTex = Resources.Load<Texture2D>("icons/background"+Fc.ToString());
        //bodySectionTex = AssetBundle.LoadFromFile("/ciciTOOLS/data/MatData/icons/background");
        logoTex = Resources.Load<Texture2D>("icons/Tlogo");

		if (windowData == null) {
			windowData = (WindowData)CreateInstance(typeof(WindowData));
		}
		windowData.toolsList = (TOOLSlist)PlayerPrefs.GetInt ("TOOLList");
        ArrangeVal.x = PlayerPrefs.GetFloat("ValueX");
        ArrangeVal.y = PlayerPrefs.GetFloat("ValueY");
        ArrangeVal.z = PlayerPrefs.GetFloat("ValueZ");
        int rpm = PlayerPrefs.GetInt("ReplaceMat");
        if (rpm == 1) replaceMat = true; else replaceMat = false;
        int kep = PlayerPrefs.GetInt("KeepMat");
        if (kep == 1) keepMat = true; else keepMat = false;
        RefreshFont();
    }
    void OnGUI()
    {
        DrawLayouts();
        DrawHeader(windowData);
    }
    void OnDestroy()
    {
        PlayerPrefs.SetFloat("ValueX", ArrangeVal.x);
        PlayerPrefs.SetFloat("ValueY", ArrangeVal.y);
        PlayerPrefs.SetFloat("ValueZ", ArrangeVal.z);
        PlayerPrefs.SetInt ("TOOLList", (int)(windowData.toolsList));
        PlayerPrefs.SetInt("ReplaceMat", Convert.ToInt32(replaceMat));
        PlayerPrefs.SetInt("KeepMat", Convert.ToInt32(keepMat));
    }
    void DrawLayouts()
    {
        headerSection.x = 0;
        headerSection.y = 0;
        headerSection.width = Screen.width;
        headerSection.height = headHight;

        bodySection.x = 0;
        bodySection.y = headHight;
        bodySection.width = 230;
        bodySection.height = Screen.height - headHight;
        bodySectionB.x = 230;
        bodySectionB.y = headHight;
        bodySectionB.width = 230;
        bodySectionB.height = Screen.height - headHight;

        //iconSection.x = 2;
        //iconSection.y = 0;
        //iconSection.width = iconSize;
        //iconSection.height = iconSize;
        //GUI.DrawTexture(headerSection, headerSectionTex);
        GUI.DrawTexture(bodySection, bodySectionTex);
        GUI.DrawTexture(bodySectionB, bodySectionTex);
        //GUI.DrawTexture(iconSection, logoTex);
    }
    void DrawHeader(ToolsData toolsData)
    {
        GUILayout.BeginArea(headerSection);  //Put the headerSection UI in this area
        //GUILayout.Label("ciciTOOLS 1.0 ", skin.GetStyle("Header"));
        GUILayout.Space(6);
        if (GUILayout.Button(" ciciTOOLS "+windowData.Ver, skin.GetStyle("Header")))
            RefreshFont();
        GUILayout.Space(5);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label(" TOOLS：", skin.GetStyle("text1"));
        windowData.toolsList = (TOOLSlist)EditorGUILayout.EnumPopup(windowData.toolsList);
        //持续执行
        EditorGUILayout.EndHorizontal();
        GUILayout.EndArea();            //Area End

        GUILayout.BeginArea(bodySection);
        switch(windowData.toolsList){
            case TOOLSlist.MaterialPropertyPaster :
                    GUILayout.Label("材 质 黏 贴 工 具", skin.GetStyle("text2"));
                    //if (Shader.Find("FGame/Cell") != null || Shader.Find("FGame/PBR_Default") != null) {
                    GUILayout.Space(5);
                    GUILayout.BeginHorizontal();
                    replaceMat = GUILayout.Toggle(replaceMat, logoTex, GUILayout.Height(18), GUILayout.Width(18));
                    if (replaceMat)
                        GUILayout.Label("储存时替换现有材质", skin.GetStyle("text4"));
                    else
                        GUILayout.Label("新建材质副本储存", skin.GetStyle("text4"));
                    GUILayout.EndHorizontal();
                    DirectoryInfo folder = new DirectoryInfo(SaveDataAsset);
                    GUILayout.BeginHorizontal();
                    if (GUILayout.Button("储 存 材 质", GUILayout.Height(26)))
                    {
                        if (Selection.gameObjects.Length > 0)
                        {
                            Renderer actRen = Selection.activeGameObject.GetComponent<Renderer>();
                            if (actRen != null)
                            {
                                Material ma = new Material(Shader.Find("Standard"));
                                ma.shader = Selection.activeGameObject.GetComponent<Renderer>().sharedMaterial.shader;
                                ma.CopyPropertiesFromMaterial(Selection.activeGameObject.GetComponent<Renderer>().sharedMaterial);
                                string mnae = Selection.activeGameObject.name;
                                if (!replaceMat)
                                {
                                    int cc = 1;
                                    var mfiles = folder.GetFiles("*.mat");
                                    for (int i = 0; i < mfiles.Length; i++)
                                    {
                                        string nn = mfiles[i].Name;
                                        nn = nn.Remove(nn.IndexOf("."));
                                        for (int n = 0; n < mfiles.Length; n++)
                                        {
                                            string nnn = mfiles[n].Name;
                                            nnn = nnn.Remove(nnn.IndexOf("."));
                                            if (mnae == nn || mnae == nnn)
                                            {
                                                mnae = Selection.activeGameObject.name;
                                                mnae = (mnae + "(" + cc.ToString()+ ")");
                                                cc++;
                                            }
                                        }
                                    }
                                }
                                AssetDatabase.CreateAsset(ma, SaveDataAsset + mnae + ".mat");
                                Debug.Log("CICI: ["+mnae+"] 材质储存成功。");
                            }
                            else
                            {
                                ShowNotification(new GUIContent("选择一个带材质的物体"));
                            }
                        }
                    }
                    // if (GUILayout.Button("Undo", GUILayout.Height(26))) { }
                    if (Selection.gameObjects.Length == 1)
                    {
                        int mc = 0;
                        Renderer renderer = Selection.activeGameObject.GetComponent<Renderer>();
                        if (renderer != null)
                        {
                            if (renderer.sharedMaterials.Length > 1)
                            {
                                mc = renderer.sharedMaterials.Length;
                                if (GUILayout.Button("复制到子材质 " + mc.ToString(), GUILayout.Height(26)))
                                {
                                    for (int i = 1; i < mc; i++)
                                    {
                                    Undo.RecordObject(renderer.sharedMaterials[i], "Undo SubMaterial");
                                        windowData.GetParentMatPri(renderer.sharedMaterials[0], renderer.sharedMaterials[i], toolsData.MatTexsList);
                                    }
                                }
                            }
                        }
                    }
                    GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                    GUILayout.Label(" Materials:", skin.GetStyle("text3"));
                keepMat = GUILayout.Toggle(keepMat, logoTex, GUILayout.Height(17), GUILayout.Width(17));
                if (keepMat)
                    GUILayout.Label("保留贴图  ", skin.GetStyle("text4"));
                else
                    GUILayout.Label("使用库贴图", skin.GetStyle("text4"));
                GUILayout.EndHorizontal();
                var files = folder.GetFiles("*.mat");
                    for (int i = 0; i < files.Length; i++)
                    {
                        string N = files[i].Name;
                        N = N.Remove(N.IndexOf("."));
                    GUILayout.BeginHorizontal();
                        if (GUILayout.Button("del", GUILayout.Width(30)))
                    {
                        AssetDatabase.DeleteAsset(SaveDataAsset+files[i].Name);
                    }
                        if (GUILayout.Button(N + windowData.HaveShaderInListMat(SaveDataAsset, files[i].Name, toolsData.MatTexsList)))
                        {
                            if (toolsData.ABobj != null) { toolsData.SliterMatB=windowData.GetLLerpMat(SaveDataAsset, files[i].Name); }
                            foreach (GameObject obj in Selection.gameObjects)
                            {
                                if (obj.GetComponent<Renderer>() != null)
                                    windowData.ReadFileList(SaveDataAsset, files[i].Name, obj.GetComponent<Renderer>(), toolsData.MatTexsList, keepMat);
                            }
                        }
                        

                    GUILayout.EndHorizontal();
                    }
                    if (Selection.gameObjects.Length == 1)
                        if (Selection.activeGameObject.GetComponent<Renderer>() != null)
                            if (!windowData.HaveShaderInList(Selection.activeGameObject, toolsData.MatTexsList)) { EditorGUILayout.HelpBox("该材质Shader贴图数据未登记！\n请联系315。", MessageType.Warning); }

                GUILayout.Space(10);
                GUILayout.Label("材 质 参 数 渐 变", skin.GetStyle("text2"));
                GUILayout.BeginHorizontal();
                toolsData.ABobj = (GameObject)EditorGUILayout.ObjectField(toolsData.ABobj, typeof(GameObject), true);
                if (GUILayout.Button("Get"))
                {
                    if (Selection.gameObjects.Length > 0)
                        if (Selection.activeGameObject.GetComponent<Renderer>() != null)
                        {
                            toolsData.ABobj = Selection.activeGameObject;
                            //toolsData.SliterMatA = new Material(toolsData.ABobj.GetComponent<Renderer>().sharedMaterial);
                        }
                }
                if (GUILayout.Button("Del"))
                {
                    toolsData.ABobj = null;
                }
                GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                GUILayout.Label(" 材质A", skin.GetStyle("text4"), GUILayout.Width(42));
                toolsData.SliterMatA = (Material)EditorGUILayout.ObjectField(toolsData.SliterMatA, typeof(Material), false);
                if (GUILayout.Button("G"))
                {
                    if (Selection.gameObjects.Length > 0)
                        if (Selection.activeGameObject.GetComponent<Renderer>() != null)
                        {
                            toolsData.SliterMatA = new Material(Selection.activeGameObject.GetComponent<Renderer>().sharedMaterial);
                        }
                }
                GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                GUILayout.Label(" 材质B", skin.GetStyle("text4"), GUILayout.Width(42));
                toolsData.SliterMatB = (Material)EditorGUILayout.ObjectField(toolsData.SliterMatB, typeof(Material), false);
                if (GUILayout.Button("G"))
                {
                    if (Selection.gameObjects.Length > 0)
                        if (Selection.activeGameObject.GetComponent<Renderer>() != null)
                        {
                            toolsData.SliterMatB = new Material(Selection.activeGameObject.GetComponent<Renderer>().sharedMaterial);
                        }
                }
                GUILayout.EndHorizontal();
                GUILayout.Space(8);
                GUILayout.BeginHorizontal();
                GUILayout.Label(" A", skin.GetStyle("text4"), GUILayout.Width(20));
                _SlideV = GUILayout.HorizontalSlider(_SlideV, 0.001f, 1f);
                GUILayout.Label("B", skin.GetStyle("text4"), GUILayout.Width(20));
                GUILayout.EndHorizontal();
                GUILayout.Space(20);
                GUILayout.Label("  当Get到物体时点击材质库按钮\n可以把材质放入 材质B 中。", skin.GetStyle("info"), GUILayout.Width(200));
                if (toolsData.ABobj != null && toolsData.SliterMatA != null && toolsData.SliterMatB != null)
                {
                    toolsData.ABobj.GetComponent<Renderer>().sharedMaterial.Lerp(toolsData.SliterMatA, toolsData.SliterMatB, _SlideV);
                }
                break;
            case TOOLSlist.ArrayObjects :
                    GUILayout.Label("等 距 排 列", skin.GetStyle("text2"));
                    ArrangeVal = EditorGUILayout.Vector3Field("Spacing", ArrangeVal);
                    RaceVal = EditorGUILayout.Vector3IntField("Column", RaceVal);
                if (RaceVal.x <= 0) RaceVal.x = 1;
                if (RaceVal.y <= 0) RaceVal.y = 1;
                if (RaceVal.z <= 0) RaceVal.z = 1;
                    GUILayout.BeginHorizontal();
                int OS = Selection.objects.Length;
                    if (OS > 1)
                {
                    if (GUILayout.Button("GO Arrange!", GUILayout.Height(30)))
                    {
                        Vector3 NVs = Selection.activeGameObject.transform.position;
                        Vector3 NV;
                        //foreach (GameObject obj in Selection.gameObjects)
                        for (int i=0; i<Selection.gameObjects.Length; i++)
                        {
                            Transform OBJECT = Selection.gameObjects[i].transform;
                            Undo.RecordObject(OBJECT, "Undo Arrange");
                            if (OBJECT != null)
                            {
                                //NV.x += ArrangeVal.x % RaceVal.x;
                                //NV.y += ArrangeVal.y / RaceVal.y;
                                //NV.z += ArrangeVal.z / RaceVal.z;
                                NV.x = (i % RaceVal.x * ArrangeVal.x)+NVs.x;
                                NV.y = (i % RaceVal.y * ArrangeVal.y)+NVs.y;
                                NV.z = (i / RaceVal.z * ArrangeVal.z)+NVs.z;
                                OBJECT.position = NV;
                                //NV += ArrangeVal;
                            }
                            EditorUtility.SetDirty(this);
                        }
                    }
                }
                    else
                    {
                        if (GUILayout.Button("GO Arrange!", GUILayout.Height(40)))
                        {
                            ShowNotification(new GUIContent("选择多个物体"));
                            foreach (SceneView scene in SceneView.sceneViews)
                            {
                                scene.ShowNotification(new GUIContent("这里选择多个物体"));
                            }
                        }
                    }
                    GUILayout.EndHorizontal();
                    GUILayout.BeginHorizontal();
                    if (GUILayout.Button("Reset Value", GUILayout.Height(30)))
                    {
                        ArrangeVal = new Vector3(0, 0, 0);
                    }
                    if (GUILayout.Button("上次参数记录", GUILayout.Height(30)))
                    {
                        ArrangeVal.x = PlayerPrefs.GetFloat("ValueX");
                        ArrangeVal.y = PlayerPrefs.GetFloat("ValueY");
                        ArrangeVal.z = PlayerPrefs.GetFloat("ValueZ");
                    }
                    GUILayout.EndHorizontal();
                    if (Selection.objects.Length < 2)
                    {
                        GUILayout.Space(16);
                        EditorGUILayout.HelpBox("Please select more then 2 Objects!", MessageType.Warning);
                    }
                    else
                    {
                        GUILayout.Space(16);
                        EditorGUILayout.HelpBox("将多个选择的物体等距离排列。\nArrange multiple selected objects equally.", MessageType.Info);
                    }
                    Vector3 pos = Camera.main.transform.position;
                    Ray ray = new Ray(pos, Camera.main.transform.forward);  //定义射线发射位置和方向
                    RaycastHit hit;     //定义接收射线与物体的碰撞点
                    if (Physics.Raycast(ray, out hit, 100))    //判断是否碰撞输出碰撞点到hit
                    {
                        Debug.DrawLine(pos, hit.point, Color.white);   //发射射线（起点，终点，颜色）
                    }
                    if(GUILayout.Button("对 齐 到 相机", GUILayout.Height(30)))
                    {
                    Undo.RecordObject(hit.transform, "Align Background");
                        hit.transform.position = hit.point;
                        hit.transform.rotation = Camera.main.transform.rotation;
                       // hit.transform.rotation = Quaternion.Euler(new Vector3(-45,0,0));
                    }
                break;
        }

        if (windowData.toolsList == TOOLSlist.CheckingResources)
        {
            GUILayout.Label("批 量 处 理", skin.GetStyle("text2"));
            if (GUILayout.Button("批量设置材质球 AssetBundle", GUILayout.Height(26)))
            {
                foreach (var o in Selection.objects)
                {
                    Texture m = o as Texture;
                    if (m != null)
                    {
                        var path = AssetDatabase.GetAssetPath(o);
                        var tex = TextureImporter.GetAtPath(path) as TextureImporter;
                        //tex.ClearPlatformTextureSettings("iPhone");
                        var iPhoneSettings = tex.GetPlatformTextureSettings("iPhone");
                        iPhoneSettings.overridden = false;
                        tex.SetPlatformTextureSettings(iPhoneSettings);
                        tex.SaveAndReimport();
                    }
                }
            }
                if (GUILayout.Button("....", GUILayout.Height(26)))
            {
                foreach (var o in Selection.objects)
                {
                    Material m = o as Material;
                    if (m != null)
                    {
                        var path = AssetDatabase.GetAssetPath(o);
                        AssetImporter.GetAtPath(path).SetAssetBundleNameAndVariant("", "");
                    }
                }
            }
            GUILayout.Space(5);
            GUILayout.Label("资 源 检 查", skin.GetStyle("text2"));
            GUILayout.BeginHorizontal();
            _disPar = GUILayout.Toggle(_disPar, logoTex, GUILayout.Height(17), GUILayout.Width(17));
            GUILayout.Label("显示参数", skin.GetStyle("text4"), GUILayout.Width(90));
            _disBut = GUILayout.Toggle(_disBut, logoTex, GUILayout.Height(17), GUILayout.Width(17));
            GUILayout.Label("显示按钮", skin.GetStyle("text4"), GUILayout.Width(90));
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label(" UV数量检查:", skin.GetStyle("text4"), GUILayout.Width(90));
            _CheckUV = EditorGUILayout.IntSlider(_CheckUV,1,8);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label(" 三角面数检查:", skin.GetStyle("text4"), GUILayout.Width(90));
            _CheckFA = EditorGUILayout.IntField(_CheckFA);
            GUILayout.EndHorizontal();
            GUILayout.Space(6);
            if (Selection.objects.Length > 0)
            {
                allGet = new List<GameObject>();
                foreach (var o in Selection.objects)
                {
                        int uvc = 0;
                    GameObject m = o as GameObject;
                    if (m == null) { continue; }
                    var mf = m.GetComponent<MeshFilter>();
                    if (mf == null) { continue; }
                    if (mf.sharedMesh != null)
                    {
                        string fac;
                        if (mf.sharedMesh.uv != null)
                            if (mf.sharedMesh.uv.Length > 0) { uvc++; }
                        if (mf.sharedMesh.uv2 != null)
                        if (mf.sharedMesh.uv2.Length > 0) { uvc++; }
                        if (mf.sharedMesh.uv3 != null)
                        if (mf.sharedMesh.uv3.Length > 0) { uvc++; }
                        if (mf.sharedMesh.uv4 != null)
                        if (mf.sharedMesh.uv4.Length > 0) { uvc++; }
                        if (_CheckUV <= uvc||_CheckFA <= (mf.sharedMesh.triangles.Length / 3))
                        {
                            allGet.Add(m);
                            if (_disBut)
                            if (GUILayout.Button(o.name))
                            {
                                Selection.activeObject = null;
                                Selection.activeObject = m;
                            }
                            if (_disPar)
                            {
                                if (_CheckFA <= (mf.sharedMesh.triangles.Length / 3))
                                    fac = ("   FACE:[" + (mf.sharedMesh.triangles.Length / 3).ToString() + "]");
                                else fac = "";
                                GUILayout.Label("   uv:[" + uvc.ToString() + "]" + fac, skin.GetStyle("text4"));
                            }
                        }
                    }
                }
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("选中所有超标物体", GUILayout.Height(26), GUILayout.Width(160))) Selection.objects = allGet.ToArray();
                GUILayout.Label("[" +allGet.Count.ToString()+ "]");
                GUILayout.Space(7);

            }
        }
        if (windowData.toolsList == TOOLSlist.EasyPlacement)
        {
            GUILayout.Label("场  景  辅  助", skin.GetStyle("text2"));
            EditorGUILayout.HelpBox("在场景中点击创建形状，可以编辑点位置，在线段插入点，\n按住【Shift】可以删除点，在空白处点击可以创建分离的形状。", MessageType.Info);
            GUILayout.BeginHorizontal();
            GUI.enabled = GameObject.Find("Shape") == null;
            if (GUILayout.Button("GO  创  建  形  状", GUILayout.Height(30)))
            {
                GameObject simpleMesh = new GameObject();
                GameObject shapeMesh = new GameObject();
                shapeMesh.name = "Shape";
                shapeMesh.AddComponent<ShapeC>();
                simpleMesh.name = "ShapeMesh";
                simpleMesh.layer = 5;
                
                simpleMesh.AddComponent<MeshFilter>();
                var RR = simpleMesh.AddComponent<MeshRenderer>();
                RR.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                RR.receiveShadows = false;
                RR.material = (Material)AssetDatabase.LoadAssetAtPath("Assets/ciciTOOLS/scripts/Geometry/shapeMaterial.mat", typeof(Material));
                shapeMesh.GetComponent<ShapeC>().meshObj = simpleMesh;
                var SM = shapeMesh.AddComponent<DStest>();
                SM.shapeMeshOjb = simpleMesh;
                Selection.activeGameObject = shapeMesh;
                simpleMesh.AddComponent<MeshCollider>();
            }
            GUI.enabled = true;
            GUI.enabled = GameObject.Find("Shape") != null;
            if (GUILayout.Button("删 除 形 状"))
            {
                GameObject sp = GameObject.Find("Shape");
                GameObject spm = GameObject.Find("ShapeMesh");
                //Undo.RecordObject(sp, "Delete Shape");
                //Undo.RecordObject(DestroyImmediate(sp), "Delete ShapeMesh");
                DestroyImmediate(sp);
                DestroyImmediate(spm);
            }
            GUI.enabled = true;
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUI.enabled = GameObject.Find("Shape") != null;
            if (GUILayout.Button("编 辑 形 状", GUILayout.Height(36)))
            {
                Selection.activeGameObject = GameObject.Find("Shape");
            }
            if (GUILayout.Button("取 消 编 辑", GUILayout.Height(36)))
            {
                Selection.activeGameObject = null;
            }
            GUI.enabled = true;
            GUILayout.EndHorizontal();
            GUILayout.Space(8);
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("设置为地板", GUILayout.Height(30)))
            {
                if (Selection.objects.Length > 0)
                {
                    foreach(GameObject o in Selection.gameObjects)
                    {
                        o.layer = 5;
                    }
                    Selection.activeGameObject = GameObject.Find("Shape");
                }
            }
            if (GUILayout.Button(" 去除地板 ", GUILayout.Height(30)))
            {
                if (Selection.objects.Length > 0)
                {
                    foreach (GameObject o in Selection.gameObjects)
                    {
                        o.layer = 0;
                    }
                    Selection.activeGameObject = GameObject.Find("Shape");
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("拾 取 资 源", GUILayout.Height(30)))
            {
                if (Selection.objects.Length > 0)
                {
                    GameObject sp = GameObject.Find("Shape");
                    if (sp != null)
                    {
                        sp.GetComponent<DStest>().createObjs = new List<GameObject>();
                        foreach (var o in Selection.objects)
                        {
                            GameObject oo = o as GameObject;
                            sp.GetComponent<DStest>().createObjs.Add(oo);
                        }
                        Selection.activeGameObject = sp;
                    }
                }
            }
            if (GUILayout.Button("清 空 资 源", GUILayout.Height(30)))
            {
                try { GameObject.Find("Shape").GetComponent<DStest>().createObjs = new List<GameObject>(); } catch { }
            }
            GUILayout.EndHorizontal();
            GUILayout.Space(5);
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("选择全部Confirm",GUILayout.Height(30)))
            {
                try { GameObject.Find("Shape").GetComponent<DStest>().SelAllCon(); } catch { }
            }
            if (GUILayout.Button("选择同组Confirm", GUILayout.Height(30)))
            {
                windowData.SelAllChildred();
            }
            GUILayout.EndHorizontal();
            //-------------------------------------------
            GUILayout.Label("排 列 对 齐", skin.GetStyle("text2"));
            ArrangeVal = EditorGUILayout.Vector3Field("Value", ArrangeVal);
            GUILayout.BeginHorizontal();
            if (Selection.objects.Length > 1)
            {
                if (GUILayout.Button("GO Arrange!", GUILayout.Height(30)))
                {
                    Vector3 NV = Selection.activeGameObject.transform.position;
                    foreach (GameObject obj in Selection.gameObjects)
                    {
                        Transform OBJECT = obj.transform;
                        Undo.RecordObject(OBJECT, "Undo Arrange");
                        if (OBJECT != null)
                        {
                            OBJECT.position = NV;
                            NV += ArrangeVal;
                        }
                        EditorUtility.SetDirty(this);
                    }
                }
            }
            else
            {
                if (GUILayout.Button("GO Arrange!", GUILayout.Height(30)))
                {
                    ShowNotification(new GUIContent("选择多个物体"));
                    foreach (SceneView scene in SceneView.sceneViews)
                    {
                        scene.ShowNotification(new GUIContent("这里选择多个物体"));
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Reset Value", GUILayout.Height(30)))
            {
                ArrangeVal = new Vector3(0, 0, 0);
            }
            if (GUILayout.Button("上次参数记录", GUILayout.Height(30)))
            {
                ArrangeVal.x = PlayerPrefs.GetFloat("ValueX");
                ArrangeVal.y = PlayerPrefs.GetFloat("ValueY");
                ArrangeVal.z = PlayerPrefs.GetFloat("ValueZ");
            }
            GUILayout.EndHorizontal();
        }
        GUILayout.EndArea();            //Area End
        switch (windowData.toolsList)
        {
            case TOOLSlist.MaterialPropertyPaster :
                GUILayout.BeginArea(bodySectionB);
                    GUILayout.Space(30);
                windowData.PP = GUILayout.PasswordField(windowData.PP, "♥"[0], 10, GUILayout.Width(88));
                GUILayout.Space(33);
                if (windowData.PP == "zxhp")
                {
                    GUILayout.BeginHorizontal();
                    if (GUILayout.Button("Register Material"))
                    {
                        if (Selection.gameObjects.Length > 0)
                        {
                            Renderer act = Selection.activeGameObject.GetComponent<Renderer>();
                            if (act != null)
                            {
                                StreamWriter sw;
                                StreamReader ex;
                                if (!File.Exists(SaveDataAsset + "ShaderList.txt"))
                                {
                                    sw = File.CreateText(SaveDataAsset + "ShaderList.txt");
                                    Debug.Log("文件创建成功！");
                                }
                                else
                                {
                                    sw = File.AppendText(SaveDataAsset + "ShaderList.txt");
                                }
                                sw.Write("\n" + act.sharedMaterial.shader.name);
                                ex = File.OpenText(SaveDataAsset + "Exclude.txt");
                                string[] exs = (ex.ReadLine()).Split(',');
                                List<string> oktxt = new List<string>();
                                foreach (string n in act.sharedMaterial.GetTexturePropertyNames())
                                    if (windowData.Findstring(exs, n) == 0)
                                        oktxt.Add(n);
                                sw.Write("," + oktxt.Count);
                                ex.Close();
                                ex.Dispose();
                                foreach (string n in oktxt)
                                {
                                    sw.Write("," + n);
                                }
                                sw.Close();
                                sw.Dispose();//文件流释放
                                AssetDatabase.Refresh();
                                windowData.MatTexsList = windowData.ReadFileList(SaveDataAsset, "ShaderList.txt");
                            }
                        }
                    }
                    if (GUILayout.Button("Refresh")) windowData.MatTexsList = windowData.ReadFileList(SaveDataAsset, "ShaderList.txt" );
                    GUILayout.EndHorizontal();
                    GUILayout.BeginHorizontal();
                    if(GUILayout.Button("Open List")){
                        Application.OpenURL(Application.dataPath + "/ciciTOOLS/data/MatData/ShaderList.txt");
                    }
                    if(GUILayout.Button("Open Exclude")){
                        Application.OpenURL(Application.dataPath + "/ciciTOOLS/data/MatData/Exclude.txt");
                    }
                    GUILayout.EndHorizontal();
                    if (GUILayout.Button("s"))
                        Debug.Log(windowData.MatTexsList.GetLength(0));
                }
                GUILayout.EndArea();
                break;
        }
    }
    //===============================================

    void OnInspectorUpdate()
    {
        //这里开启窗口的重绘，不然窗口信息不会刷新
        this.Repaint();
    }

}
