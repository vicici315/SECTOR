Shader "FGame/PBR_Actor_Hair"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_S( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}

		//hairColor("Hair Color", Color) = (1,1,1)
		//hairBrightness("Hair Brightness", Range(0.1, 2)) = 1
		//hairSpecularStrength("Hair Specular Strength", Range(0,2)) = 0.7
		//hairSpecularPower("Hair Specular Power", Range(10, 120)) = 70
		_texHair("Hair Tangent", 2D) = "black" {}
		hairSpecularColor("Specular Color", Color) = (1,1,1)
		hairStrength("Specular Strength", Range(0,1)) = 0.2
		hairNoise("Hair Noise", Range(0,1)) = 0.48
		hairTangentOffset("Hair Tangent Offset", Range(0,1)) = 0.1
		[NoScaleOffset]_RampTex ("Ramp Texture", 2D) = "white" {}
        _RampValueA ("Ramp Value X", Range(0.01, 0.999)) = 0.9
        _RampValueB ("Ramp Value Y", Range(0, 0.498)) = 0.49
        _RampOSx ("Ramp Offset X", Float) = 0
        _RampOSy ("Ramp Offset Y", Float) = 0
        _RampOSz ("Ramp Offset Z", Float) = 0
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
			#pragma multi_compile _ VERTEXLIGHT_ON

			#define FX_HAIR
			#define FX_PBR_USE_GLOBALBRIGHTNESS
			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}
	}
		
	CustomEditor "FxShaderGUI"

	Fallback "Mobile/VertexLit"
}
