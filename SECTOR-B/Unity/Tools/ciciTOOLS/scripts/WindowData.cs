using ToolsClass;
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class WindowData : ToolsData {
    public TOOLSlist toolsList;
    public Vector4 ReadColorFrom (string str)
    {
        string[] ccs = str.Split(',', '(', ')');
        float v1 = float.Parse(ccs[1]);
        float v2 = float.Parse(ccs[2]);
        float v3 = float.Parse(ccs[3]);
        float v4 = float.Parse(ccs[4]);
        return new Vector4(v1,v2,v3,v4);
    }

    public Material GetLLerpMat(string file_path, string file_name)
    {
        Material lm = new Material(Shader.Find("Standard"));
        lm = (Material)AssetDatabase.LoadAssetAtPath(file_path + file_name, typeof(Material));
        return lm;
    }
        public void ReadFileList(string file_path, string file_name, Renderer ren_set, string[,] MatT, bool UsOld)
    {
        Material lm = new Material(Shader.Find("Standard"));
        lm = (Material)AssetDatabase.LoadAssetAtPath(file_path+file_name, typeof(Material));
        Texture2D[] oldTex = new Texture2D[] { };
        string[] oldTN = new string[] { };
        int n = 0;
        if (UsOld)
        for (int i = 0; i < MatT.GetLength(0); i++)
        {
            if (ren_set.sharedMaterial.shader.name == MatT[i, 0])
            {
                int co = int.Parse(MatT[i, 1]);
                oldTex = new Texture2D[co];
                oldTN = new string[co];
                    for (int I = 2; I < co + 2; I++)
                    {
                        if (MatT[i, I] != null)
                        oldTex[n] = (Texture2D)ren_set.sharedMaterial.GetTexture(MatT[i, I]);
                          //  Debug.Log(MatT[i, I]);
                        else
                            oldTex[n] = null;
                        oldTN[n] = MatT[i, I];
                          //  Debug.Log(MatT[i, I]);
                        n++;
                    }
            }
        }

        Undo.RecordObject(ren_set.sharedMaterial, "Undo Material");
        ren_set.sharedMaterial.shader = lm.shader;
        ren_set.sharedMaterial.CopyPropertiesFromMaterial(lm);

        if (UsOld)
        for (int t=0; t < oldTex.Length; t++)
        {
            if(oldTex[t] != null)
            ren_set.sharedMaterial.SetTexture(oldTN[t],oldTex[t]);
        }
    }
    public void GetParentMatPri(Material Par, Material Chi, string[,] MatT)
    {
        Texture2D[] oldTex = new Texture2D[] { };
        string[] oldTN = new string[] { };
        int n = 0;
            for (int i = 0; i < MatT.GetLength(0); i++)
            {
                if (Chi.shader.name == MatT[i, 0])
                {
                    int co = int.Parse(MatT[i, 1]);
                    oldTex = new Texture2D[co];
                    oldTN = new string[co];
                    for (int I = 2; I < co + 2; I++)
                    {
                        oldTex[n] = (Texture2D)Chi.GetTexture(MatT[i, I]);
                        oldTN[n] = MatT[i, I];
                        n++;
                    }
                }
            }
        Chi.shader = Par.shader;
        Chi.CopyPropertiesFromMaterial(Par);
            for (int t = 0; t < oldTex.Length; t++)
            {
                Chi.SetTexture(oldTN[t], oldTex[t]);
            }
    }
    public bool HaveShaderInList(GameObject ren, string[,] MatT)
    {
        int cont = 0;
        if (ren != null)
        {
            Renderer rr = ren.GetComponent<Renderer>();
            if (rr != null)
                for (int i = 0; i < MatT.GetLength(0); i++)
                {
                    if (rr.sharedMaterial.shader.name == MatT[i, 0])
                        cont += 1;
                }
        }
            if (cont > 0)
                return true;
            else
                return false;
    }
    public string HaveShaderInListMat(string file_path, string file_name, string[,] MatT)
    {
        Material lm = new Material(Shader.Find("Standard"));
        lm = (Material)AssetDatabase.LoadAssetAtPath(file_path + file_name, typeof(Material));
        int cont = 0;
        for (int i = 0; i < MatT.GetLength(0); i++)
        {
            try {
                if (lm.shader.name == MatT[i, 0])
                    cont += 1;
            }
            catch { }
            }
        if (cont > 0)
            return "";
        else
            return "  ☢";
    }
    public string[,] ReadFileList(string file_path, string file_name)
    {
        string[,] MatT = { };
        StreamReader sr;
        if (File.Exists(file_path + "//" + file_name))
        {
            sr = File.OpenText(file_path + "//" + file_name);
        }
        else return MatT;
        List<string> list = new List<string>();
        //加上str的临时变量是为了避免sr.ReadLine()在一次循环内执行两次
        string str;
        while ((str = sr.ReadLine()) != null)
            list.Add(str);
        int o = 1;
        int ss = 1;
        for (int a = 0; a < list.Count; a++)
        {
            string[] s = list[a].Split(',');
            if (s.Length > o) ss = s.Length;
            o = s.Length;
        }
            
        MatT = new string[list.Count, ss];
        for (int i = 0; i < list.Count; i++)
        {
            string[] s = list[i].Split(',');
            for (int e = 0; e < s.Length; e++)
            {
                MatT[i, e] = s[e];
            }
        }
        sr.Close();
        sr.Dispose();
        return MatT;
    }
    public int Findstring(string[] array, string str)
    {
        int R = 0;
        foreach(string a in array)
        {
            if (str == a)
                R++;
        }
        return R;
    }

    public void SelAllChildred()
    {
        if (Selection.objects.Length > 0)
        {
            Transform pp = Selection.activeGameObject.transform.parent;
            GameObject[] chobjs = new GameObject[pp.childCount];
            for (int i = 0; i < pp.childCount; i++)
            {
                chobjs[i] = pp.GetChild(i).gameObject;
            }
            Selection.objects = chobjs;
        }
        else { Debug.Log("请选择一个 confirm 成员"); }
    }
}
