// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FGame/Test/PBR+Cell2"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Base Map", 2D) = "white" {}
		[NoScaleOffset]_texNormal_S ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_texMRA ("MRA", 2D) = "white" {}
        [HideInInspector]_NormalStr ("Normal_Strength", Range(0,3)) = 1
        [HideInInspector][Header(Cartoon Properties)]
        [HideInInspector]_Spe ("Specular_Power", Range(0,100)) =4.2
        [HideInInspector]_Detail2("Specular_Level", Range(0,1))=0.3
        [HideInInspector]_Brightness("Specular_Strength", Range(0,3)) = 0.5
        [HideInInspector]_Detail("Toon_Level", Range(-0.01,1))=0.35
        [HideInInspector][Header(Fresnel Properties)]
        [HideInInspector][KeywordEnum(Light, Normal)] _FreDir ("Fresnel_Mode", Int) = 0
        [HideInInspector]_FresnelC("Fresnel_Light_Color", Color) = (0.5,0.2,0,1)
        [HideInInspector]_FresnelBC("Fresnel_Shadow_Color", Color) = (0,0.1,0.5,1)
        [HideInInspector]_FresnelP("Fresnel_Offset", Range(-20,20))=4.4
        [HideInInspector]_FresnelL("Fresnel_Level", Range(0,1))=0.22
        [HideInInspector]_Test("Shadow_Level", Range(0,1))=0.5
        _SO("Specular Offset", Range(0,1))=0.01
        _SS("Specular Smooth", Range(0,1))=0.3
        _T4("Metallic Offset", Range(0,1))=0.01
        _MS("Metallic Smooth", Range(0,1))=0.3
        _T1("Cell Offset", Range(0,1))=0
        _T2("Cell Smooth", Range(0,1))=0.01
        _T3("PBR Shadow Brightness", Range(0,3))=0
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline width", Range(0.001, 0.3)) = 0.002		
    //    [Toggle(UNITY_UI_ALPHACLIP)] _FreToonA("Fresnel_ToonActive", Int) = 1
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
			#pragma multi_compile_fwdbase noshadowmask nodynlightmap

			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}

        Pass
		{
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			uniform fixed _Outline;
			uniform fixed4 _OutlineColor;

			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				float4 pos = UnityObjectToClipPos(v.vertex);
				
				float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(norm.xy);
				#ifdef UNITY_Z_0_FAR_FROM_CLIPSPACE //to handle recent standard asset package on older version of unity (before 5.5)
					pos.xy += offset * UNITY_Z_0_FAR_FROM_CLIPSPACE(pos.z) * _Outline;
				#else
					pos.xy += offset * pos.z * _Outline;
				#endif

				o.vertex = pos;
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 col = _OutlineColor;				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
    }
	Fallback "Legacy Shaders/VertexLit"
}

