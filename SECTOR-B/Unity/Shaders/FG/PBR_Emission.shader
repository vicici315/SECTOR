Shader "FGame/PBR_Emission"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_S( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}
		_texEmission("Emission", 2D) = "black" {}
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
			#define FX_PBR_USE_GLOBALBRIGHTNESS
			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}
	}
		
	CustomEditor "FxShaderGUI"

	Fallback "Legacy Shaders/VertexLit"
}
