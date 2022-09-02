Shader "FGame/PBRCartoon_Actor"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_S( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}
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
			Name "Edge"
			Tags { "LightMode" = "ForwardFull" }

			Cull Front

			CGPROGRAM
			#pragma vertex VS_Main
			#pragma fragment PS_Main
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase nodirlightmap
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#define INTERNAL_DATA
			#define WorldReflectionVector(data,normal) data.worldRefl
			#define WorldNormalVector(data,normal) normal

			#pragma target 2.0

			struct SVS_Output
			{
				float4 pos			: SV_POSITION;
			};

			SVS_Output VS_Main( appdata_full v )
			{
				SVS_Output aOutput;
				v.vertex.xyz += normalize( v.normal.xyz ) * 0.01f;
				aOutput.pos = UnityObjectToClipPos( v.vertex );
				return aOutput;
			}

			fixed4 PS_Main( SVS_Output aInput ) : SV_Target
			{
				return float4( 0.02f, 0.02f, 0.02f, 1.0f );
			}
			ENDCG
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
			#pragma shader_feature VERTEXLIGHT_ON

			#define FX_PBR_USE_CARTOON
			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}
	}

	Fallback "Legacy Shaders/VertexLit"
}
