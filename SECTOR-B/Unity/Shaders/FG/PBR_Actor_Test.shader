Shader "FGame/PBR_Actor_Test"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_S( "RG:Normalmap B:Skin Mask", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}
		_texEmission("Emission", 2D) = "black" {}
		//_texHair("Hair Specular", 2D) = "black" {}
		//hairStrength("Specular Strength", Float) = 0.2
		sssBrightness("Skin Brightness", Range(0,1)) = 0.5
		sssStrength("SSS Strength", Range(0,2)) = 0.8
		sssColor("SSS Color", Color) = (0,0,0)
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "False"
			"RenderType" = "Opaque"
		}

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardFull" }

			Cull Back

			CGPROGRAM
			#pragma vertex VS_Main
			#pragma fragment PS_Main
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase nolightmap
			#pragma shader_feature VERTEXLIGHT_ON

			#define FX_EMISSION
			//#define FX_HAIR
			#define FX_SSS
			#define FX_PBR_USE_GLOBALBRIGHTNESS
			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}
	}

	Fallback "Legacy Shaders/VertexLit"
}
