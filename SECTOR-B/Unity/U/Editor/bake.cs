#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.Collections;
public class bake : EditorWindow
{
	[MenuItem("Window/Set_LightMapSize/256")]
	static void Init256()
	{
		LightmapEditorSettings.maxAtlasHeight = 256;
		LightmapEditorSettings.maxAtlasWidth = 256;
	}
	[MenuItem("Window/Set_LightMapSize/512")]
	static void Init512()
	{
		LightmapEditorSettings.maxAtlasHeight = 512;
		LightmapEditorSettings.maxAtlasWidth = 512;
	}
	[MenuItem("Window/Set_LightMapSize/1024")]
	static void Init1024()
	{
		LightmapEditorSettings.maxAtlasHeight = 1024;
		LightmapEditorSettings.maxAtlasWidth = 1024;
		//	Lightmapping.Clear();
		//	Lightmapping.Bake();
		//PVRTC 4 bits
	}
}
#endif