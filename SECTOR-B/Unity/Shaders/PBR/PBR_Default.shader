Shader "FGame/PBR_Default"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		[HideInInspector]_BaseColor("Base Color", COLOR) = (1,1,1,1)
		//_BCPower("BaseColor Power", Range( 0, 3 )) = 1
		_texNormal_S( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}
		_SPELEV( "SpecularLevel", Range( 0, 1 ) ) = 1
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}
		[HideInInspector]_METALLIC( "Metallic", Range( 0, 1 ) ) = 1
		[HideInInspector]_ROUGHNESS( "Roughness", Range( 0, 1 ) ) = 1
		_texIBL( "IBL CubeMap", CUBE ) = "black" {}
		_IBLCorrect( "IBL Correct", Range( 0, 1 ) ) = 0.5
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
			Tags { "LightMode" = "ForwardBase" }

			Cull Back

			CGPROGRAM
			#pragma vertex VS_Main
			#pragma fragment PS_Main
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase nolightmap

			#include "FX_PBRBase.cginc"

			ENDCG
		}
	}

	Fallback "Legacy Shaders/VertexLit"
}
