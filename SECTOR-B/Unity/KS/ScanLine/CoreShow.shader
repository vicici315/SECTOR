// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CoreShow"
{
	Properties
	{
		_Intensity("Intensity", Float) = 1
		[Header(SobelIntensity)]
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_BumpMap("BumpMap", 2D) = "bump" {}
		_BumpScale("BumpScale", Float) = 1
		[NoScaleOffset]_EmissionMap("EmissionMap", 2D) = "black" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[NoScaleOffset]_OcclusionMap("OcclusionMap", 2D) = "white" {}
		_OcclusionStrength("OcclusionStrength", Range( 0 , 1)) = 1
		[NoScaleOffset]_MetallicGlossMap("MetallicGlossMap", 2D) = "white" {}
		_GlossMapScale("_GlossMapScale", Range( 0 , 1)) = 1
		_SphereCenter("SphereCenter", Vector) = (0,0,0,0)
		_Scale("Scale", Vector) = (1,1,1,0)
		_FadePower("FadePower", Int) = 1
		[HDR]_OutlineColor("OutlineColor", Color) = (0.5,0.5,0.5,0.5)
		_FresnelPower("FresnelPower", Range( 0 , 20)) = 1
		[HDR]_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_ScanLineTexture("ScanLineTexture_OffsetAin", 2D) = "white" {}
		[KeywordEnum(UV_world, UV_texcoord, UV_2)] _UVmode ("UV Mode", Int) = 0
		_ScanLinePow("ScanLine Power", float) = 2
		_Scanning("Scanning", Range(0,1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv_texcoord1;
			float4 screenPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float3 _SphereCenter;
		uniform float3 _Scale;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform int _FadePower;
		uniform sampler2D _CameraDepthTexture;
		uniform sampler2D sampler0159;
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Intensity;
		uniform sampler2D _BumpMap;
		uniform float _BumpScale;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionColor;
		uniform float _GlossMapScale;
		uniform sampler2D _MetallicGlossMap;
		uniform sampler2D _OcclusionMap;
		uniform float _OcclusionStrength;
		uniform float4 _FresnelColor;
		uniform sampler2D _ScanLineTexture;
		uniform float4 _ScanLineTexture_ST;
		uniform float _FresnelPower;
		uniform float4 _OutlineColor;
		uniform float _Scanning;
		uniform float _ScanLinePow;
		uniform half _UVmode;
		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float4 appendResult237 = (float4(_SphereCenter.x , _SphereCenter.y , _SphereCenter.z , 1));
			float4 transform233 = mul(unity_ObjectToWorld,appendResult237);
			float temp_output_238_0 = ( 1 / transform233.w );
			float3 appendResult239 = (float3(( transform233.x * temp_output_238_0 ) , ( transform233.y * temp_output_238_0 ) , ( transform233.z * temp_output_238_0 )));
			float3 temp_output_88_0 = ( ( ase_worldPos - appendResult239 ) / _Scale );
			float dotResult79 = dot( temp_output_88_0 , temp_output_88_0 );
			float sign53 = ( ( sign( ( 1 - dotResult79 ) ) + 1 ) * 0.5 );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float clampResult110 = clamp( sqrt( dotResult79 ) , 0 , 1 );
			float occlend106 = clampResult110;
			float lerpResult119 = lerp( ( _Color * tex2D( _MainTex, uv_MainTex ) ).a , 1 , pow( occlend106 , (float)_FadePower ));
			float ifLocalVar113 = 0;
			if( sign53 <= 0 )
				ifLocalVar113 = 1.0;
			else
				ifLocalVar113 = lerpResult119;
			float opacity7 = ifLocalVar113;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult175 = (float2(ase_grabScreenPosNorm.x , ase_grabScreenPosNorm.y));
			float2 localCenter138_g1 = appendResult175;
			float2 appendResult176 = (float2(_CameraDepthTexture_TexelSize.x , _CameraDepthTexture_TexelSize.y));
			float temp_output_2_0_g1 = ( 1.0 * appendResult176 ).x;
			float localNegStepX156_g1 = -temp_output_2_0_g1;
			float temp_output_3_0_g1 = ( 1.0 * appendResult176 ).y;
			float localStepY164_g1 = temp_output_3_0_g1;
			float2 appendResult14_g85 = (float2(localNegStepX156_g1 , localStepY164_g1));
			float4 tex2DNode16_g85 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g85 ) );
			float temp_output_2_0_g85 = (tex2DNode16_g85).r;
			float temp_output_4_0_g85 = (tex2DNode16_g85).g;
			float temp_output_5_0_g85 = (tex2DNode16_g85).b;
			float localTopLeft172_g1 = ( sqrt( ( ( ( temp_output_2_0_g85 * temp_output_2_0_g85 ) + ( temp_output_4_0_g85 * temp_output_4_0_g85 ) ) + ( temp_output_5_0_g85 * temp_output_5_0_g85 ) ) ) * _Intensity );
			float2 appendResult14_g81 = (float2(localNegStepX156_g1 , 0.0));
			float4 tex2DNode16_g81 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g81 ) );
			float temp_output_2_0_g81 = (tex2DNode16_g81).r;
			float temp_output_4_0_g81 = (tex2DNode16_g81).g;
			float temp_output_5_0_g81 = (tex2DNode16_g81).b;
			float localLeft173_g1 = ( sqrt( ( ( ( temp_output_2_0_g81 * temp_output_2_0_g81 ) + ( temp_output_4_0_g81 * temp_output_4_0_g81 ) ) + ( temp_output_5_0_g81 * temp_output_5_0_g81 ) ) ) * _Intensity );
			float localNegStepY165_g1 = -temp_output_3_0_g1;
			float2 appendResult14_g84 = (float2(localNegStepX156_g1 , localNegStepY165_g1));
			float4 tex2DNode16_g84 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g84 ) );
			float temp_output_2_0_g84 = (tex2DNode16_g84).r;
			float temp_output_4_0_g84 = (tex2DNode16_g84).g;
			float temp_output_5_0_g84 = (tex2DNode16_g84).b;
			float localBottomLeft174_g1 = ( sqrt( ( ( ( temp_output_2_0_g84 * temp_output_2_0_g84 ) + ( temp_output_4_0_g84 * temp_output_4_0_g84 ) ) + ( temp_output_5_0_g84 * temp_output_5_0_g84 ) ) ) * _Intensity );
			float localStepX160_g1 = temp_output_2_0_g1;
			float2 appendResult14_g76 = (float2(localStepX160_g1 , localStepY164_g1));
			float4 tex2DNode16_g76 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g76 ) );
			float temp_output_2_0_g76 = (tex2DNode16_g76).r;
			float temp_output_4_0_g76 = (tex2DNode16_g76).g;
			float temp_output_5_0_g76 = (tex2DNode16_g76).b;
			float localTopRight177_g1 = ( sqrt( ( ( ( temp_output_2_0_g76 * temp_output_2_0_g76 ) + ( temp_output_4_0_g76 * temp_output_4_0_g76 ) ) + ( temp_output_5_0_g76 * temp_output_5_0_g76 ) ) ) * _Intensity );
			float2 appendResult14_g79 = (float2(localStepX160_g1 , 0.0));
			float4 tex2DNode16_g79 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g79 ) );
			float temp_output_2_0_g79 = (tex2DNode16_g79).r;
			float temp_output_4_0_g79 = (tex2DNode16_g79).g;
			float temp_output_5_0_g79 = (tex2DNode16_g79).b;
			float localRight178_g1 = ( sqrt( ( ( ( temp_output_2_0_g79 * temp_output_2_0_g79 ) + ( temp_output_4_0_g79 * temp_output_4_0_g79 ) ) + ( temp_output_5_0_g79 * temp_output_5_0_g79 ) ) ) * _Intensity );
			float2 appendResult14_g80 = (float2(localStepX160_g1 , localNegStepY165_g1));
			float4 tex2DNode16_g80 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g80 ) );
			float temp_output_2_0_g80 = (tex2DNode16_g80).r;
			float temp_output_4_0_g80 = (tex2DNode16_g80).g;
			float temp_output_5_0_g80 = (tex2DNode16_g80).b;
			float localBottomRight179_g1 = ( sqrt( ( ( ( temp_output_2_0_g80 * temp_output_2_0_g80 ) + ( temp_output_4_0_g80 * temp_output_4_0_g80 ) ) + ( temp_output_5_0_g80 * temp_output_5_0_g80 ) ) ) * _Intensity );
			float temp_output_133_0_g1 = ( ( localTopLeft172_g1 + ( localLeft173_g1 * 2 ) + localBottomLeft174_g1 + -localTopRight177_g1 + ( localRight178_g1 * -2 ) + -localBottomRight179_g1 ) / 6.0 );
			float2 appendResult14_g83 = (float2(0.0 , localStepY164_g1));
			float4 tex2DNode16_g83 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g83 ) );
			float temp_output_2_0_g83 = (tex2DNode16_g83).r;
			float temp_output_4_0_g83 = (tex2DNode16_g83).g;
			float temp_output_5_0_g83 = (tex2DNode16_g83).b;
			float localTop175_g1 = ( sqrt( ( ( ( temp_output_2_0_g83 * temp_output_2_0_g83 ) + ( temp_output_4_0_g83 * temp_output_4_0_g83 ) ) + ( temp_output_5_0_g83 * temp_output_5_0_g83 ) ) ) * _Intensity );
			float2 appendResult14_g82 = (float2(0.0 , localNegStepY165_g1));
			float4 tex2DNode16_g82 = tex2D( _CameraDepthTexture, ( localCenter138_g1 + appendResult14_g82 ) );
			float temp_output_2_0_g82 = (tex2DNode16_g82).r;
			float temp_output_4_0_g82 = (tex2DNode16_g82).g;
			float temp_output_5_0_g82 = (tex2DNode16_g82).b;
			float localBottom176_g1 = ( sqrt( ( ( ( temp_output_2_0_g82 * temp_output_2_0_g82 ) + ( temp_output_4_0_g82 * temp_output_4_0_g82 ) ) + ( temp_output_5_0_g82 * temp_output_5_0_g82 ) ) ) * _Intensity );
			float temp_output_135_0_g1 = ( ( -localTopLeft172_g1 + ( localTop175_g1 * -2 ) + -localTopRight177_g1 + localBottomLeft174_g1 + ( localBottom176_g1 * 2 ) + localBottomRight179_g1 ) / 6.0 );
			float temp_output_111_0_g1 = sqrt( ( ( temp_output_133_0_g1 * temp_output_133_0_g1 ) + ( temp_output_135_0_g1 * temp_output_135_0_g1 ) ) );
			float3 appendResult113_g1 = (float3(temp_output_111_0_g1 , temp_output_111_0_g1 , temp_output_111_0_g1));
			float myOutline196 = appendResult113_g1.x;
			SurfaceOutputStandard s123 = (SurfaceOutputStandard ) 0;
			float3 appendResult5 = (float3(( _Color * tex2D( _MainTex, uv_MainTex ) ).r , ( _Color * tex2D( _MainTex, uv_MainTex ) ).g , ( _Color * tex2D( _MainTex, uv_MainTex ) ).b));
			float3 albedo6 = appendResult5;
			s123.Albedo = albedo6;
			float3 normal13 = UnpackScaleNormal( tex2D( _BumpMap, uv_MainTex ) ,_BumpScale );
			s123.Normal = WorldNormalVector( i , normal13 );
			float4 tex2DNode14 = tex2D( _EmissionMap, uv_MainTex );
			float3 appendResult16 = (float3(tex2DNode14.r , tex2DNode14.g , tex2DNode14.b));
			float3 appendResult17 = (float3(_EmissionColor.r , _EmissionColor.g , _EmissionColor.b));
			float3 emission19 = ( appendResult16 * appendResult17 );
			s123.Emission = emission19;
			float4 tex2DNode24 = tex2D( _MetallicGlossMap, uv_MainTex );
			float metallic27 = ( _GlossMapScale * tex2DNode24.r );
			s123.Metallic = metallic27;
			float glossness28 = tex2DNode24.a;
			s123.Smoothness = glossness28;
			float occlusion23 = ( tex2D( _OcclusionMap, uv_MainTex ).g * _OcclusionStrength );
			s123.Occlusion = occlusion23;

			data.light = gi.light;

			UnityGI gi123 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g123 = UnityGlossyEnvironmentSetup( s123.Smoothness, data.worldViewDir, s123.Normal, float3(0,0,0));
			gi123 = UnityGlobalIllumination( data, s123.Occlusion, s123.Normal, g123 );
			#endif

			float3 surfResult123 = LightingStandard ( s123, viewDir, gi123 ).rgb;
			surfResult123 += s123.Emission;
_ScanLineTexture_ST.zw += _ScanLineTexture_ST.zw * _Time;
			float2 uv_ScanLineTexture;
switch(_UVmode){
	case 0:
			uv_ScanLineTexture = i.worldPos.xy * _ScanLineTexture_ST.xy + _ScanLineTexture_ST.zw;
		break;
	case 1:
			uv_ScanLineTexture = i.uv_texcoord * _ScanLineTexture_ST.xy + _ScanLineTexture_ST.zw;
		break;
	case 2:
			uv_ScanLineTexture = i.uv_texcoord1 * _ScanLineTexture_ST.xy + _ScanLineTexture_ST.zw;
		break;
}
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNDotV211 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode211 = ( 0 + 1 * pow( 1.0 - fresnelNDotV211, _FresnelPower ) );
			float4 myFresnel224 = ( _FresnelColor * fresnelNode211 );
			float4 myFresnel226 = ( _FresnelColor * fresnelNode211 + ( tex2D( _ScanLineTexture, uv_ScanLineTexture )*_ScanLinePow ) );
			float4 mySobelColor166 = ( _OutlineColor * 2.0 * myOutline196 );
			float4 _Color0 = float4(0,0,0,0);
			float4 ifLocalVar140 = 0;
			UNITY_BRANCH 
			if( sign53 <= 0 )
				ifLocalVar140 = _Color0;
			else
				ifLocalVar140 = mySobelColor166;
			c.rgb = ( float4( surfResult123 , 0.0 ) + (lerp(myFresnel224, myFresnel226, _Scanning) * sign53 * ( 1 - opacity7 ) ) + ifLocalVar140 ).rgb;
			c.a = max( opacity7 , myOutline196 );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14501
1927;16;1186;976;3337.52;-1366.148;2.165922;True;False
Node;AmplifyShaderEditor.Vector3Node;67;-1882.064,1606.993;Float;False;Property;_SphereCenter;SphereCenter;11;0;Create;True;0;0,0,0;-0.05199993,-0.237,0.458;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;237;-1563.062,1627.29;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;233;-1661.229,1847.168;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;238;-1417.96,1969.668;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;-1229.062,1702.29;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;241;-1223.062,1897.29;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;242;-1218.33,1798.29;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;239;-1017.062,1907.29;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;232;-1515.07,1426.465;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;87;-1458.107,2096.824;Float;False;Property;_Scale;Scale;12;0;Create;True;0;1,1,1;0.14,0.14,0.14;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-948.351,1647.274;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-881.1014,2098.251;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;151;-3485.156,2054.154;Float;False;1268.424;818.2188;Camera Depth sobel find outline;15;155;159;162;163;164;173;174;175;176;190;200;211;213;230;196;Sobel;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexelSizeNode;159;-3440.894,2334.712;Float;False;173;1;0;SAMPLER2D;sampler0159;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;79;-690.2167,1944.238;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-721.4441,1624.301;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;190;-3433.952,2599.62;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;180;-2078.95,573.1708;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;176;-3124.454,2448.68;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SqrtOpNode;105;-480.2542,1744.877;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-3191.02,2209.016;Float;False;Constant;_Step;Step;27;0;Create;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;174;-3173.978,2647.225;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-3021.241,2232.182;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1680.925,-285.1656;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;None;3b2015e052d71714394a05ff57189e83;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-1606.925,-459.1657;Float;False;Property;_Color;Color;2;0;Create;True;0;1,1,1,1;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;110;-282.5137,1828.309;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;50;-563.8571,1617.803;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;164;-3008.802,2124.639;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-80.25415,1751.877;Float;True;occlend;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-429.2736,1599.049;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1316.929,-393.1657;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;175;-2831.194,2527.637;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;122;-738.5372,-203.5625;Float;False;Property;_FadePower;FadePower;13;0;Create;True;0;1;25;0;1;INT;0
Node;AmplifyShaderEditor.TexturePropertyNode;173;-2962.242,2333.363;Float;True;Global;_CameraDepthTexture;_CameraDepthTexture;15;0;Create;True;0;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-771.5205,-320.8662;Float;False;106;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;4;-1159.929,-390.1657;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PowerNode;120;-549.5898,-313.1566;Float;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-259.1827,1614.105;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-2828.035,2683.659;Float;False;Property;_FresnelPower;FresnelPower;16;0;Create;True;0;1;3.294117;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;244;-2720.005,2923.809;Float;False;0;243;2;3;2;SAMPLER2D;;False;0;FLOAT2;1.83,5.82;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;155;-2703.364,2202.753;Float;True;SobelMain;-1;;1;481788033fe47cd4893d0d4673016cbc;0;4;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT2;0,0;False;1;SAMPLER2D;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-457.9288,-397.179;Float;False;Constant;_Float0;Float 0;14;0;Create;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;142;-2848.688,1337.549;Float;False;405.9817;484.097;MatCap UV;2;129;131;MatCapSample;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-83.72066,1636.616;Float;False;sign;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;243;-2389.391,2914.032;Float;True;Property;_ScanLineTexture;ScanLineTexture;18;0;Create;False;0;None;3d6bff77f18763747aedd1d2b40307c1;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;200;-2457.949,2111.336;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;119;-362.8169,-220.5418;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-821.0212,-476.7654;Float;False;53;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;211;-2512.299,2451.294;Float;True;World;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;-1666.659,476.7552;Float;False;Property;_EmissionColor;EmissionColor;6;1;[HDR];Create;True;0;0,0,0,0;2,2,2,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1669.62,280.1524;Float;True;Property;_EmissionMap;EmissionMap;5;1;[NoScaleOffset];Create;True;0;None;59b992f14de486f468e6b70b2847b22d;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;17;-1321.675,470.2773;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1631.871,852.0969;Float;False;Property;_OcclusionStrength;OcclusionStrength;8;0;Create;True;0;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-2747.212,1655.353;Float;False;Constant;_Float1;Float 1;18;0;Create;True;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-2429.592,2296.513;Float;False;myOutline;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-1663.725,1053.59;Float;True;Property;_MetallicGlossMap;MetallicGlossMap;9;1;[NoScaleOffset];Create;True;0;None;d944fc98f0764444cb30d4393a4ab8e6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-1578.151,152.2219;Float;False;Property;_BumpScale;BumpScale;4;0;Create;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;113;-226.3315,-488.715;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1617.199,947.4305;Float;False;Property;_GlossMapScale;_GlossMapScale;10;0;Create;True;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;230;-2453.135,2685.193;Float;False;Property;_FresnelColor;FresnelColor;17;1;[HDR];Create;True;0;0,0,0,0;0,0.4250501,0.485294,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;129;-2757.825,1451.794;Float;False;Property;_OutlineColor;OutlineColor;14;1;[HDR];Create;True;0;0.5,0.5,0.5,0.5;0,0.528651,0.5514706,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-2104.976,2656.98;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-1667.308,653.4699;Float;True;Property;_OcclusionMap;OcclusionMap;7;1;[NoScaleOffset];Create;True;0;None;e6432ded93763e64fb12674b20526c12;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-1678.151,-48.77813;Float;True;Property;_BumpMap;BumpMap;3;1;[NoScaleOffset];Create;True;0;None;00aa6c58bfdf9b14b9124a586df056af;True;0;True;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1326.663,283.7082;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-339.6536,448.9657;Float;False;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1318.272,616.0514;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-12.22129,-317.7972;Float;False;opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-1824.885,2442.53;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-2086.684,1840.308;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1148.604,287.4714;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1260.881,1060.243;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;-908.9282,-393.1657;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;12;-1355.15,-53.77813;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;-1537.918,2517.06;Float;True;myFresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-342.9514,277.1949;Float;False;28;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-280.3951,-669.941;Float;False;albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1105.349,1055.184;Float;False;metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-342.9512,134.3082;Float;False;19;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-340.4222,66.02579;Float;False;13;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;141;18.86376,412.5846;Float;False;Constant;_Color0;Color 0;18;0;Create;True;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-1893.138,1989.805;Float;False;mySobelColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-995.6963,372.8336;Float;False;occlusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-342.9512,207.6484;Float;False;27;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-997.1672,286.3898;Float;False;emission;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-344.8475,-24.17401;Float;False;6;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-1111.15,-52.77813;Float;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;205.2173,-245.5316;Float;True;224;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1100.291,1165.194;Float;False;glossness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;231;97.06569,134.6632;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;29.58071,259.5168;Float;False;53;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-337.8933,351.7997;Float;False;23;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;49.45862,339.6794;Float;False;166;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;461.2718,-75.05348;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-357.4116,636.6553;Float;False;196;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;123;-65.15099,-58.01101;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ConditionalIfNode;140;381.761,269.3824;Float;False;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;644.4451,58.61339;Float;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;210;112.2168,577.0491;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;876.0807,36.09058;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;CoreShow;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;Back;2;0;False;0;0;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;237;0;67;1
WireConnection;237;1;67;2
WireConnection;237;2;67;3
WireConnection;233;0;237;0
WireConnection;238;1;233;4
WireConnection;240;0;233;1
WireConnection;240;1;238;0
WireConnection;241;0;233;3
WireConnection;241;1;238;0
WireConnection;242;0;233;2
WireConnection;242;1;238;0
WireConnection;239;0;240;0
WireConnection;239;1;242;0
WireConnection;239;2;241;0
WireConnection;78;0;232;0
WireConnection;78;1;239;0
WireConnection;88;0;78;0
WireConnection;88;1;87;0
WireConnection;79;0;88;0
WireConnection;79;1;88;0
WireConnection;71;1;79;0
WireConnection;176;0;159;1
WireConnection;176;1;159;2
WireConnection;105;0;79;0
WireConnection;174;0;190;0
WireConnection;163;0;162;0
WireConnection;163;1;176;0
WireConnection;1;1;180;0
WireConnection;110;0;105;0
WireConnection;50;0;71;0
WireConnection;164;0;163;0
WireConnection;106;0;110;0
WireConnection;51;0;50;0
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;175;0;174;0
WireConnection;175;1;174;1
WireConnection;4;0;3;0
WireConnection;120;0;108;0
WireConnection;120;1;122;0
WireConnection;52;0;51;0
WireConnection;155;2;164;0
WireConnection;155;3;164;1
WireConnection;155;4;175;0
WireConnection;155;1;173;0
WireConnection;53;0;52;0
WireConnection;243;1;244;2
WireConnection;200;0;155;0
WireConnection;119;0;4;3
WireConnection;119;2;120;0
WireConnection;211;3;213;0
WireConnection;14;1;180;0
WireConnection;17;0;15;1
WireConnection;17;1;15;2
WireConnection;17;2;15;3
WireConnection;196;0;200;0
WireConnection;24;1;180;0
WireConnection;113;0;55;0
WireConnection;113;2;119;0
WireConnection;113;3;114;0
WireConnection;113;4;114;0
WireConnection;245;0;243;4
WireConnection;245;1;211;0
WireConnection;20;1;180;0
WireConnection;8;1;180;0
WireConnection;16;0;14;1
WireConnection;16;1;14;2
WireConnection;16;2;14;3
WireConnection;22;0;20;2
WireConnection;22;1;21;0
WireConnection;7;0;113;0
WireConnection;223;0;230;0
WireConnection;223;1;245;0
WireConnection;165;0;129;0
WireConnection;165;1;131;0
WireConnection;165;2;196;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;26;0;25;0
WireConnection;26;1;24;1
WireConnection;5;0;4;0
WireConnection;5;1;4;1
WireConnection;5;2;4;2
WireConnection;12;0;8;0
WireConnection;12;1;11;0
WireConnection;224;0;223;0
WireConnection;6;0;5;0
WireConnection;27;0;26;0
WireConnection;166;0;165;0
WireConnection;23;0;22;0
WireConnection;19;0;18;0
WireConnection;13;0;12;0
WireConnection;28;0;24;4
WireConnection;231;1;35;0
WireConnection;227;0;225;0
WireConnection;227;1;137;0
WireConnection;227;2;231;0
WireConnection;123;0;29;0
WireConnection;123;1;30;0
WireConnection;123;2;31;0
WireConnection;123;3;32;0
WireConnection;123;4;33;0
WireConnection;123;5;34;0
WireConnection;140;0;137;0
WireConnection;140;2;154;0
WireConnection;140;3;141;0
WireConnection;140;4;141;0
WireConnection;135;0;123;0
WireConnection;135;1;227;0
WireConnection;135;2;140;0
WireConnection;210;0;35;0
WireConnection;210;1;204;0
WireConnection;0;9;210;0
WireConnection;0;13;135;0
ASEEND*/
//CHKSM=B8D9AC76B9844220764A248E49A9155D1F7BA14A