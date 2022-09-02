Shader "FGame/PBR_Actor_Hair"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_S( "RG:Normalmap B:Hair Specular", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}

		hairColor("Hair Color", Color) = (1,1,1)
		hairBrightness("Hair Brightness", Range(0.1, 2)) = 1
		hairSpecularStrength("Hair Specular Strength", Range(0,2)) = 0.7
		hairSpecularPower("Hair Specular Power", Range(10, 120)) = 70
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

			#define FX_HAIR
			#define FX_PBR_USE_GLOBALBRIGHTNESS
			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}
	}
		
	CustomEditor "FxShaderGUI"

	Fallback "Legacy Shaders/VertexLit"
}
