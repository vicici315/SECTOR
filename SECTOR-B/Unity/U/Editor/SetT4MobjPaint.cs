#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
public class SetT4MobjPaint : EditorWindow
{
	static Vector2[] staticRecode=new Vector2[4];
	[MenuItem("Window/T4Mset/SetT4MObjPaint")]
	static void T4MObjPaint()
	{
		Selection.activeTransform.gameObject.layer = 30;
		if(Selection.activeTransform.gameObject.GetComponent<MeshCollider>() == null)
			Selection.activeTransform.gameObject.AddComponent<MeshCollider>();
		if(Selection.activeTransform.gameObject.GetComponent<T4MObjSC>() == null)
			Selection.activeTransform.gameObject.AddComponent<T4MObjSC>();
		string sName = Selection.activeTransform.gameObject.renderer.sharedMaterial.shader.ToString ();
		string[] sName_b= sName.Split(new char[]{'/'});
		string[] endName=sName_b[sName_b.Length-1].Split(new char[]{' '} ,StringSplitOptions.RemoveEmptyEntries);
		if(endName[endName.Length-2]=="Spec")
			Selection.activeTransform.gameObject.renderer.sharedMaterial.shader = Shader.Find("T4MShaders/ShaderModel2/Specular/T4M "+endName[0]+" Textures Spec");
		else
			Selection.activeTransform.gameObject.renderer.sharedMaterial.shader = Shader.Find("T4MShaders/ShaderModel2/Diffuse/T4M "+endName[0]+" Textures");
		CopyValue ();
	}
	[MenuItem("Window/T4Mset/DeleteT4MObj")]
	static void DelT4MObjPaint()
	{
		Selection.activeTransform.gameObject.layer = 0;
		if(Selection.activeTransform.gameObject.GetComponent<MeshCollider>() != null)
		{
			DestroyImmediate(Selection.activeGameObject.GetComponent<MeshCollider>());
		}
		if(Selection.activeTransform.gameObject.GetComponent<T4MObjSC>() != null)
		{
			DestroyImmediate( Selection.activeTransform.gameObject.GetComponent<T4MObjSC>());
		}
		string sName = Selection.activeTransform.renderer.sharedMaterial.shader.ToString ();
		string[] sName_b= sName.Split(new char[]{'/'});
		string[] endName=sName_b[sName_b.Length-1].Split(new char[]{' '} ,StringSplitOptions.RemoveEmptyEntries);
		if(endName[endName.Length-2]=="Spec")
			Selection.activeTransform.renderer.sharedMaterial.shader = Shader.Find("Custom/Scene/"+endName[1]+" Textures Spec");
		else
			Selection.activeTransform.renderer.sharedMaterial.shader = Shader.Find("Custom/Scene/"+endName[1]+" Textures for Mobile");
	}
	[MenuItem("Window/Test")]
	static void test()
	{
		string sName = Selection.activeTransform.gameObject.renderer.sharedMaterial.shader.ToString ();
		string[] sName_b= sName.Split(new char[]{'/'});
		string[] endName=sName_b[sName_b.Length-1].Split(new char[]{' '} ,StringSplitOptions.RemoveEmptyEntries);
		Debug.Log (endName[0]);
//		if (File.Exists (Application.dataPath + "\\UserText") != true)
//			File.Create(Application.dataPath+"\\UserText");
//		else{
//			StreamReader sr = File.Open(Application.dataPath+"\\UserText",FileMode);
//			Debug.Log (sr);
//		}
//		for (int i = 0; i<=3; i++) {
//			try{staticRecode[i]=Selection.activeTransform.renderer.material.GetTextureScale ("_Splat"+i.ToString());}catch{staticRecode[i]=new Vector2(0.0f,0.0f);}
		//	try{Debug.Log (Selection.activeTransform.gameObject.renderer.material.GetTextureScale ("_Splat"+i.ToString()).ToString ());}catch{}
//		}

//		ArrayList info = File.
//		Debug.Log(Selection.activeTransform.gameObject.renderer.material.GetTextureOffset("_MainTex").ToString());
//		Selection.activeTransform.gameObject.renderer.material.SetTextureScale("_Splat0",new Vector2(11.0f,3.0f));
//		Selection.activeTransform.gameObject.renderer.material.mainTexture.sharedMaterial.GetVector ("Layer 1").ToString();
	}
	[MenuItem("Window/T4Mset/CopyValue")]
	static void CopyValue()
	{
		int c = 2;
		string sName = Selection.activeTransform.renderer.sharedMaterial.shader.ToString ();
		string[] sName_b= sName.Split(new char[]{'/'});
		if (sName_b [sName_b.Length - 1].IndexOf ("T4M 3") >= 0 || sName_b [sName_b.Length - 1].IndexOf ("3 Textures") >= 0)
			c = 2;
		else
			c = 3;
		for (int i = 0; i<=c; i++) {
			staticRecode [i] = Selection.activeTransform.renderer.sharedMaterial.GetTextureScale ("_Splat" + i.ToString ());
		}
		Debug.Log("CopyFinesh");
	}
	[MenuItem("Window/T4Mset/PauseValue")]
	static void PauseValue()
	{
		int c = 2;
		string sName = Selection.activeTransform.renderer.sharedMaterial.shader.ToString ();
		string[] sName_b= sName.Split(new char[]{'/'});
		if (sName_b [sName_b.Length - 1].IndexOf ("T4M 3") >= 0 || sName_b [sName_b.Length - 1].IndexOf ("3 Textures") >= 0)
			c = 2;
		else
			c = 3;
		for (int i = 0; i<=c; i++) {
			Selection.activeTransform.renderer.sharedMaterial.SetTextureScale (("_Splat"+i.ToString()),staticRecode[i]);
		}

	}
	static bool FogTure;
	static Color FogColor;
	static float FogDensity;
	static float FogStart;
	static float FogEnd;
	static Color AmbLight;
	[MenuItem("Window/RenderSet/CopyFog")]
	static void CopyRenderSet()
	{
		FogTure	=	RenderSettings.fog;
		FogColor =	RenderSettings.fogColor;
		FogDensity= RenderSettings.fogDensity;
		FogStart =	RenderSettings.fogStartDistance;
		FogEnd =	RenderSettings.fogEndDistance;
		AmbLight =	RenderSettings.ambientLight;
	}
	[MenuItem("Window/RenderSet/PauseFog")]
	static void PauseRenderSet()
	{
		RenderSettings.fog = FogTure;
		RenderSettings.fogColor = FogColor;
		RenderSettings.fogDensity = FogDensity;		
		RenderSettings.fogStartDistance = FogStart;
		RenderSettings.fogEndDistance = FogEnd;
		RenderSettings.ambientLight = AmbLight;
	}
}
#endif