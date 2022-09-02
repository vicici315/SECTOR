Shader "CODM/Character/LobbyHair_BR"
{
	Properties
	{
		_Color("Main Color", color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_DarkToBrithness("Dark To Brighness", range(0,1)) = 0.5
		_DefalutNormal ("Normal", 2D) = "bump" {}
		_BumpFactor("Bump Scale", Range(0, 3.0)) = 1.0
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_SpecularMultiplier ("Specular Range", float) = 128
		_SpecularColor2 ("Secondary Specular Color", Color) = (0.5,0.5,0.5,1)
		_SpecularMultiplier2 ("Secondary Specular Multiplier", float) = 64
		_NoiseIntensity ("Noise Intensity", range(0,1)) = 1
		_NoiseTiling ("Noise Tiling", float) = 1
		_Cut ("Cut", float) = 0.7
	}

	CGINCLUDE
		#pragma multi_compile_fwdbase nolightmap novertexlight
		#pragma multi_compile _ _GPU_SKINNING
		#pragma multi_compile _ TWO_ADDUP_LIGHT
		// 非顶点着色器用到VERTEXLIGHT_ON的判定都需要自己定义，同时上面的fwdbase定义novertexlight减少重复变体。
		#pragma multi_compile _ VERTEXLIGHT_ON

		#define _TANGENT_TO_WORLD 1
		#if defined(_GPU_SKINNING)
			#define CFM_USE_VERTEX_COLOR 
		#endif

		#define _SIMPLE_DYNAMIC_SPECULAR_IBL

		float _DarkToBrithness;
		sampler2D _DefalutNormal;
		float _BumpFactor;
		half4 _SpecularColor;
		float _SpecularMultiplier;
		half4 _SpecularColor2;
		float _SpecularMultiplier2;
		float _SecondaryShift;
		half _NoiseIntensity;
		half _NoiseTiling;
		half _Cut;

		#define CFM_FULL_PIXEL_SH
		#define ENABLE_ADDUP_LIGHT
		#define CALCULATE_ADDUP_LIGHT_DISTANCE_IN_VERTEX
		#define ADDUP_LIGHT_SPECULAR
		// #define VERTEXLIGHT_ON

		#define USE_SHADOWMAP

		#define SURFACE_CUSTOM_DATA SurfaceCustomDataHair
		#define SURFACE_FUNC SurfaceLobbyHair
		#define SURFACE_WORLD_SPACE_FUNC SurfaceWorldSpaceLobbyHair
		#define UNITY_BRDF_PBS BRDFLobbyHair
		#define LIGHTING_ADDUP_FUNC BRDFLobbyHairAddUp
		#define LIGHTING_GI_FUNC BRDFLobbyHairGI

		#define _NO_TANGENT_SPACE_NORMAL_AS_AO 1

		struct SurfaceCustomDataHair {
			half shiftTex;
			half3 t1;
			half3 t2;
		};


	ENDCG
	CGINCLUDE LAST // This is a CUSTOM KEYWORD in TIMI J3
		#include "CFStandardVarients.cginc"
		#include "StdHeader.cginc"


		float3 ShiftTangent ( float3 T, float3 N, float shift)
		{
			float3 shiftedT = T+ shift * N;
			return normalize( shiftedT);
		}

		float StrandSpecular ( half3 T, half3 V, half3 L, float exponent)
		{
			half3 H = normalize ( L + V );
			float dotTH = dot ( T, H );
			float sinTH = sqrt ( 1 - dotTH * dotTH);
			float dirAtten = smoothstep( -1, 0, dotTH );
			return dirAtten * pow(sinTH, exponent);
		}

		float3 UnpackNormalCustom(float4 packednormal)
		{
			float3 normal;
			normal.xy = (packednormal.xy * 2 - 1) * _BumpFactor;
			normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
			return normal;
		}
		
		void SurfaceLobbyHair(inout FragmentCommonData s, VertexOutput i)
		{
			half4 texCol = Degamma(tex2D(_MainTex, i.uv0)) * _Color;

			#if defined(DEPTH_PASS)
			clip(texCol.a - 0.7);
			#endif

			half SecondPassMask = (texCol.a - 0.7) > 0 ? 0 : 1;
			texCol.a = texCol.a * SecondPassMask * rcp(0.7);
			s.diffColor = texCol.rgb;
			s.alpha = texCol.a;

			half4 normalTex = tex2D(_DefalutNormal, i.uv0);
			half3 normalCustom = UnpackNormalCustom(normalTex);
			s.tangentSpaceNormal = normalCustom;

			//half4 flowMap = tex2D(_FlowMap, half2(i.uv.x * _NoiseTiling, i.uv.y));
			float flowMap = tex2D(_DefalutNormal, half2(i.uv0.x * _NoiseTiling, i.uv0.y)).b;
			s.custom.shiftTex = (flowMap - 0.5) * _NoiseIntensity;
			
		}

		void SurfaceWorldSpaceLobbyHair(inout FragmentCommonData s, inout FragmentDerived d, VertexOutput i)
		{
			float3 T = -normalize(cross(d.normalWorld, i.wsTangent));
			s.custom.t1 = ShiftTangent(T, d.normalWorld, s.custom.shiftTex);
			s.custom.t2 = ShiftTangent(T, d.normalWorld, s.custom.shiftTex);
		}

		half3 BRDFLobbyHair(VertexOutput i, FragmentCommonData s, FragmentDerived d, inout LightingEnv env, AnalyticalLight light)
		{
			float diff = light.ndl * _DarkToBrithness + (1 - _DarkToBrithness);
			half3 lightCol = light.color;
			float3 realDiff = s.diffColor * lightCol * diff;

			float3 specular = _SpecularColor * StrandSpecular(s.custom.t1, i.wsEyeDir, light.dir, _SpecularMultiplier);
			float3 specular1 = _SpecularColor2 * StrandSpecular(s.custom.t2, i.wsEyeDir, light.dir, _SpecularMultiplier2);
			float3 realSpec = (specular + specular1) * light.ndl * lightCol;
			return realDiff + realSpec;
		}
		half3 BRDFLobbyHairAddUp(VertexOutput i, FragmentCommonData s, FragmentDerived d, inout LightingEnv env, AnalyticalLight light)
		{
			half3 lightCol = light.color * light.atten * light.shadow;
			half3 realDiff = s.diffColor * lightCol * light.ndl;
			half3 realSpec = _SpecularColor * StrandSpecular(s.custom.t1, i.wsEyeDir, light.dir, _SpecularMultiplier) * light.ndl * lightCol;
			return realDiff + realSpec;
		}

		half3 BRDFLobbyHairGI (VertexOutput i, FragmentCommonData s, FragmentDerived d, inout LightingEnv env)
		{
			half3 diffuseLighting = s.diffColor * env.diffuse;

			half3 specularLighting = 0; //env.specColorWithEnvBRDF * env.specular;

			half3 color = diffuseLighting + specularLighting;

			return color;
		}

		#include "StdPassForward.cginc"
	ENDCG


	SubShader
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}

		LOD 100
		Cull Off

		Pass
		{
			Name "DEPTH"
			Tags { "LightMode" = "ForwardBase" }
			ZWrite On

			CGPROGRAM
			#pragma target 3.0
			#define DEPTH_PASS
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vertBase
			#pragma fragment fragBase
			#pragma multi_compile_fog

			//#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile_fwdbase nodynlightmap nodirlightmap
			#pragma multi_compile _ ENABLE_CUSTOM_SHADOWMAP
			#pragma multi_compile _ ONEPASS_TONEMAPPING


			ENDCG
		}

		Pass
		{
			Name "FORWARD"
			Tags {"LightMode"="ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma target 3.0
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vertBase
			#pragma fragment fragBase
			#pragma multi_compile_fog
			//#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			//#pragma multi_compile_fwdbase nodynlightmap nodirlightmap
			#pragma multi_compile _ ENABLE_CUSTOM_SHADOWMAP
			#pragma multi_compile _ ONEPASS_TONEMAPPING
			

			ENDCG
		}
		//Pass
		//{
		//	Name "FORWARD_DELTA"
		//	Tags { "LightMode" = "ForwardAdd" }
		//	Blend SrcAlpha One
		//	Fog { Color (0,0,0,0) } // in additive pass fog should be black
		//	ZWrite Off
		//	ZTest LEqual

		//	CGPROGRAM
		//	#pragma target 3.0
		//	#define ADD_PASS
		//	#pragma multi_compile_fwdadd_fullshadows
		//	#pragma fragmentoption ARB_precision_hint_fastest
		//	#pragma vertex vertBase
		//	#pragma fragment fragBase
		//	#pragma multi_compile_fog

		//	//#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
		//	//#pragma multi_compile_fwdbase nodynlightmap nodirlightmap
		//	#pragma multi_compile _ ENABLE_CUSTOM_SHADOWMAP
		//	#pragma multi_compile _ ONEPASS_TONEMAPPING
		//	

		//	ENDCG
		//}
	}

	FallBack "Mobile/VertexLit-SupportGPUSkinShadow"
	CustomEditor "LobbyHairGUI"
}