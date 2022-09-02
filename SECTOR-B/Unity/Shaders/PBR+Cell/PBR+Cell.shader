// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FGame/Test/PBR+Cell"
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
        _Color("Toon_Color", Color) = (0,0,0,1)
        [HideInInspector]_Detail("Toon_Level", Range(-0.01,1))=0.35
        _Strength("Toon_Strength", Range(0,2)) = 0.6
        [HideInInspector][Header(Fresnel Properties)]
        [HideInInspector][KeywordEnum(Light, Normal)] _FreDir ("Fresnel_Mode", Int) = 0
        [HideInInspector]_FresnelC("Fresnel_Light_Color", Color) = (0.5,0.2,0,1)
        [HideInInspector]_FresnelBC("Fresnel_Shadow_Color", Color) = (0,0.1,0.5,1)
        [HideInInspector]_FresnelP("Fresnel_Offset", Range(-20,20))=4.4
        [HideInInspector]_FresnelL("Fresnel_Level", Range(0,1))=0.22
        _Outline("Outline_Width", Range(0,0.1))=0.015
        _OLStrength("Outline_Opacity", Range(0,1))=0
        [HideInInspector]_Test("Shadow_Level", Range(0,1))=0.5
        _T1("smoothV1", Range(0,1))=0
        _T3("PBR Shadow Brightness", Range(0,3))=0
[Header(Toon)]
        _Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {}
		// Ambient light is applied uniformly to all surfaces on the object.
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		// Controls the size of the specular reflection.
		_Glossiness("Glossiness", Float) = 32
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		// Control how smoothly the rim blends when approaching unlit
		// parts of the surface.
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
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
		
        Pass {
            Tags { "LightMode"="ForwardBase" }
            Blend DstColor Zero
			Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
//            #pragma target 2.0
//#pragma multi_compile_fwdbase
        //    #include "HLSLSupport.cginc"
//#include "UnityShaderVariables.cginc"
//#include "UnityShaderUtilities.cginc"
 //           #include "UnityCG.cginc"
            #include "Lighting.cginc"
            // #include "AutoLight.cginc"
            float _Outline;
            float _OLStrength;
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 outlineViewDir : TEXCOORD1;
                half3 worldNormal : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);

	float3 vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;
				o.outlineViewDir = UnityWorldSpaceViewDir(vPosW);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 outlineViewDir = normalize(i.outlineViewDir);
                fixed3 worldNormal = normalize(i.worldNormal);

                float outline = max(_OLStrength,(floor(pow(dot(outlineViewDir,worldNormal),_Outline)/0.98)));

                
                return fixed4 (outline,outline,outline, 1.0);
                //return fixed4 (col + floor(fresnel/_FresnelL), 1.0);
            }
            ENDCG
        }

    }
	Fallback "Legacy Shaders/VertexLit"
}

