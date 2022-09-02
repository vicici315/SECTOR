#if UNITY_EDITOR
using System.Collections;
using UnityEngine;
using UnityEditor;

public class VicShaderMaterialPreset : EditorWindow {
	//this
	static Color c_color;
	static float c_ShadowPow;
	static float c_ShadowSmoothPow;
	static Color c_Shadow;
	static float c_RampPower;
	static float c_RampValueA;
	static float c_RampValueB;
	static Color c_RampColor;
	static float c_SpecularPower;
	static float c_SpecularSmoothPow;
	static Color c_SpecularColor;
	static float c_ReflectionPow;
	static float c_CubeScale;
	static float c_EmissionPow;
	static float c_BumpScale;
	static bool haveTex = false;
	static Texture c_MainTex;
	static Texture c_ShadowMaskTex;
	static Texture c_AOTex;
	static Texture c_RampTex;
	static Texture c_RampMaskTex;
	static Texture c_SpecularTex;
	static Texture c_ReflectMaskTex;
	static Texture c_EmissionTex;
	static Texture c_BumpTex;
	// Use this for initialization
	[MenuItem("Tools/VIC_Shader_Copy (No Texture)", false, 10)]
	static void VIC_copy(){
	// string shad = Selection.activeTransform.gameObject.GetComponent<MeshRenderer>().sharedMaterial.shader.ToString();
	// Debug.Log(shad);
		// if(shad == "VIC/Vic_NextGenCharacter_v2"){
			Material[] sel = Selection.activeTransform.gameObject.GetComponent<MeshRenderer>().sharedMaterials;
			c_color = sel[0].GetColor("_Color");
			c_ShadowPow = sel[0].GetFloat("_ShadowPow");
			c_ShadowSmoothPow = sel[0].GetFloat("_ShadowSmoothPow");
			c_Shadow = sel[0].GetColor("_Shadow");
			c_RampPower = sel[0].GetFloat("_RampPower");
			c_RampValueA = sel[0].GetFloat("_RampValueA");
			c_RampValueB = sel[0].GetFloat("_RampValueB");
			c_RampColor = sel[0].GetColor("_RampColor");
			c_SpecularPower = sel[0].GetFloat("_SpecularPower");
			c_SpecularSmoothPow = sel[0].GetFloat("_SpecularSmoothPow");
			c_SpecularColor = sel[0].GetColor("_SpecularColor");
			c_ReflectionPow = sel[0].GetFloat("_ReflectionPow");
			c_CubeScale = sel[0].GetFloat("_CubeScale");
			c_EmissionPow = sel[0].GetFloat("_EmissionPow");
			c_BumpScale = sel[0].GetFloat("_BumpScale");
			haveTex = false;
		// }
	}
	[MenuItem("Tools/VIC_Shader_Copy (Copy Texture)", false, 10)]
	static void VIC_copyT(){
	// string shad = Selection.activeTransform.gameObject.GetComponent<MeshRenderer>().sharedMaterial.shader.ToString();
	// Debug.Log(shad);
		// if(shad == "VIC/Vic_NextGenCharacter_v2"){
			Material[] sel = Selection.activeTransform.gameObject.GetComponent<MeshRenderer>().sharedMaterials;
			c_color = sel[0].GetColor("_Color");
			c_MainTex = sel[0].GetTexture("_MainTex");
			c_ShadowPow = sel[0].GetFloat("_ShadowPow");
			c_ShadowSmoothPow = sel[0].GetFloat("_ShadowSmoothPow");
			c_Shadow = sel[0].GetColor("_Shadow");
			c_RampPower = sel[0].GetFloat("_RampPower");
			c_RampValueA = sel[0].GetFloat("_RampValueA");
			c_RampValueB = sel[0].GetFloat("_RampValueB");
			c_RampColor = sel[0].GetColor("_RampColor");
			c_SpecularPower = sel[0].GetFloat("_SpecularPower");
			c_SpecularSmoothPow = sel[0].GetFloat("_SpecularSmoothPow");
			c_SpecularColor = sel[0].GetColor("_SpecularColor");
			c_ReflectionPow = sel[0].GetFloat("_ReflectionPow");
			c_CubeScale = sel[0].GetFloat("_CubeScale");
			c_EmissionPow = sel[0].GetFloat("_EmissionPow");
			c_BumpScale = sel[0].GetFloat("_BumpScale");
			c_ShadowMaskTex = sel[0].GetTexture("_ShadowMaskTex");
			c_AOTex = sel[0].GetTexture("_AOTex");
			c_RampTex = sel[0].GetTexture("_RampTex");
			c_RampMaskTex = sel[0].GetTexture("_RampMaskTex");
			c_SpecularTex = sel[0].GetTexture("_SpecularTex");
			c_ReflectMaskTex = sel[0].GetTexture("_ReflectMaskTex");
			c_EmissionTex = sel[0].GetTexture("_EmissionTex");
			c_BumpTex = sel[0].GetTexture("_BumpTex");
			haveTex = true;
		// }
	}
	[MenuItem("Tools/VIC_Shader_Pause", false, 10)]
	static void VIC_pause()
	{
		// if(Selection.activeTransform.gameObject.GetComponent<MeshRenderer>().sharedMaterial.shader.ToString() == "VIC/Vic_NextGenCharacter_v2"){
			Material[] sel = Selection.activeTransform.gameObject.GetComponent<MeshRenderer>().sharedMaterials;
		if (haveTex){
			sel[0].SetColor("_Color", c_color);
			sel[0].SetTexture("_MainTex", c_MainTex);
			sel[0].SetFloat("_ShadowPow", c_ShadowPow);
			sel[0].SetFloat("_ShadowSmoothPow", c_ShadowSmoothPow);
			sel[0].SetColor("_Shadow", c_Shadow);
			sel[0].SetFloat("_RampPower", c_RampPower);
			sel[0].SetFloat("_RampValueA", c_RampValueA);
			sel[0].SetFloat("_RampValueB", c_RampValueB);
			sel[0].SetColor("_RampColor", c_RampColor);
			sel[0].SetFloat("_SpecularPower", c_SpecularPower);
			sel[0].SetFloat("_SpecularSmoothPow", c_SpecularSmoothPow);
			sel[0].SetColor("_SpecularColor", c_SpecularColor);
			sel[0].SetFloat("_ReflectionPow", c_ReflectionPow);
			sel[0].SetFloat("_CubeScale", c_CubeScale);
			sel[0].SetFloat("_EmissionPow", c_EmissionPow);
			sel[0].SetFloat("_BumpScale", c_BumpScale);
			sel[0].SetTexture("_ShadowMaskTex", c_ShadowMaskTex);
			sel[0].SetTexture("_AOTex", c_AOTex);
			sel[0].SetTexture("_RampTex", c_RampTex);
			sel[0].SetTexture("_RampMaskTex", c_RampMaskTex);
			sel[0].SetTexture("_SpecularTex", c_SpecularTex);
			sel[0].SetTexture("_ReflectMaskTex", c_ReflectMaskTex);
			sel[0].SetTexture("_EmissionTex", c_EmissionTex);
			sel[0].SetTexture("_BumpTex", c_BumpTex);
		}else{
			sel[0].SetColor("_Color", c_color);
			sel[0].SetFloat("_ShadowPow", c_ShadowPow);
			sel[0].SetFloat("_ShadowSmoothPow", c_ShadowSmoothPow);
			sel[0].SetColor("_Shadow", c_Shadow);
			sel[0].SetFloat("_RampPower", c_RampPower);
			sel[0].SetFloat("_RampValueA", c_RampValueA);
			sel[0].SetFloat("_RampValueB", c_RampValueB);
			sel[0].SetColor("_RampColor", c_RampColor);
			sel[0].SetFloat("_SpecularPower", c_SpecularPower);
			sel[0].SetFloat("_SpecularSmoothPow", c_SpecularSmoothPow);
			sel[0].SetColor("_SpecularColor", c_SpecularColor);
			sel[0].SetFloat("_ReflectionPow", c_ReflectionPow);
			sel[0].SetFloat("_CubeScale", c_CubeScale);
			sel[0].SetFloat("_EmissionPow", c_EmissionPow);
			sel[0].SetFloat("_BumpScale", c_BumpScale);
		}
		// }
	}
	[MenuItem("Tools/VIC_Shader预设/金属", false, 10)]
	static void PrePropertie()
	{
		Debug.Log("还未添加预设属性！");
	}

}
#endif
