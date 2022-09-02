#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
public class SetValue : EditorWindow
{
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