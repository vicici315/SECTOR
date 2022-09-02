Shader "FGame/Test/PBR_BaseTest"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_R( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}

		_Roughness( "Roughness", Range( 0, 1 ) ) = 0.5
		_Metallic( "Metallic", Range( 0, 1 ) ) = 0
		_SpecularLevel( "SpecularLevel", Range( 0, 1 ) ) = 0.2
		_AO( "AO", Range( 0, 1 ) ) = 1
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
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "FX_Common.cginc"

			#define INTERNAL_DATA
			#define WorldReflectionVector(data,normal) data.worldRefl
			#define WorldNormalVector(data,normal) normal

			#pragma target 2.0


			sampler2D _MainTex;
			sampler2D _texNormal_R;

			// IBL
			float4 g_arrSkyIrradiance[3];
			samplerCUBE g_texIBL;

			float _Roughness;
			float _Metallic;
			float _SpecularLevel;
			float _AO;
			float g_fIBLIntensity;

			struct SVS_Output
			{
				float4 pos				: SV_POSITION;
				float2 m_vTex			: TEXCOORD0;
				float3 m_vT2W_0			: TEXCOORD1;
				float3 m_vT2W_1			: TEXCOORD2;
				float3 m_vT2W_2			: TEXCOORD3;
				float3 m_vPosW			: TEXCOORD4;
				UNITY_FOG_COORDS( 5 )
				SHADOW_COORDS( 6 )
			};

			SVS_Output VS_Main( appdata_full v )
			{
				SVS_Output aOutput;

				float3 vNormalW = UnityObjectToWorldNormal( v.normal );
				float3 vTangentW = UnityObjectToWorldDir( v.tangent.xyz );
				float fTangentSign = v.tangent.w * unity_WorldTransformParams.w;
				float3 vBinormalW = cross( vNormalW, vTangentW ) * fTangentSign;
				aOutput.m_vT2W_0 = float3( vTangentW.x, vBinormalW.x, vNormalW.x );
				aOutput.m_vT2W_1 = float3( vTangentW.y, vBinormalW.y, vNormalW.y );
				aOutput.m_vT2W_2 = float3( vTangentW.z, vBinormalW.z, vNormalW.z );

				aOutput.pos = UnityObjectToClipPos( v.vertex );
				float3 vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;
				aOutput.m_vTex = v.texcoord;

				TRANSFER_SHADOW( aOutput );
				UNITY_TRANSFER_FOG( aOutput, aOutput.pos );
				aOutput.m_vPosW = vPosW;

				return aOutput;
			}

			fixed4 PS_Main( SVS_Output aInput ) : SV_Target
			{
				float4 vBaseColor = g_Tex2D_Color( _MainTex, aInput.m_vTex );
				float3 BaseColor = vBaseColor.rgb;
				float3 vNormal_R = g_Tex2D_Mask( _texNormal_R, aInput.m_vTex );

				float3 vNormal;
				{
					float2 vNormal2 = vNormal_R.xy * 2.0f - 1.0f;
					float z = sqrt( 1.0f - dot( vNormal2, vNormal2 ) );
					float3 vNormalT = normalize( float3( vNormal2, z ) );
					
					float3x3 mT2W;
					mT2W[0] = normalize( aInput.m_vT2W_0 );
					mT2W[1] = normalize( aInput.m_vT2W_1 );
					mT2W[2] = normalize( aInput.m_vT2W_2 );
					vNormal = mul( mT2W, vNormalT );
				}

				float3 vViewDir = normalize( _WorldSpaceCameraPos.xyz - aInput.m_vPosW );

				float Roughness = _Roughness;
				float Metallic = _Metallic;
				float Specular = _SpecularLevel;
				float AO = _AO;


				half DielectricSpecular = 0.08 * Specular;
				half3 DiffuseColor = BaseColor - BaseColor * Metallic;	// 1 mad
				half3 SpecularColor = ( DielectricSpecular - DielectricSpecular * Metallic ) + BaseColor * Metallic;	// 2 mad

				float3 SH = ShadeSHPerPixel_Linear( vNormal, 0, aInput.m_vPosW );
				const float fMipMapCount = 7;

				half NoV = saturate( dot( vNormal, vViewDir ) );
				SpecularColor = EnvBRDFApprox( SpecularColor, Roughness, NoV );


				half3 Color = 0;
				half IndirectIrradiance = AO;

				UNITY_LIGHT_ATTENUATION( Shadow, aInput, aInput.m_vPosW );


				float  NoL = saturate( dot( vNormal, _WorldSpaceLightPos0 ) );
				float3 H = normalize( _WorldSpaceLightPos0 + vViewDir );
				float  NoH = saturate( dot( vNormal, H ) );

				Color += ( Shadow * NoL ) * _LightColor0.rgb * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, NoH, H, vNormal ) );

				half3 SpecularIBL = GetImageBasedReflectionLighting( Roughness, reflect( -vViewDir, vNormal ), g_texIBL, fMipMapCount, g_fIBLIntensity ) * AO;
#if FX_PBR_USE_SO
				half3 SpecularOcclusion = CalcSOColorByMaterialAO( vNormal, vViewDir, Roughness, AO, SpecularColor );
				Color += SpecularIBL * SpecularColor * SpecularOcclusion;
#else
				Color += SpecularIBL * SpecularColor;
#endif

				Color += DiffuseColor * SH * AO;

				// Point Lighting
				{
					float4 vToLightX = unity_4LightPosX0 - aInput.m_vPosW.x;
					float4 vToLightY = unity_4LightPosY0 - aInput.m_vPosW.y;
					float4 vToLightZ = unity_4LightPosZ0 - aInput.m_vPosW.z;

					float4 vLenSQ;
					vLenSQ = vToLightX * vToLightX;
					vLenSQ += vToLightY * vToLightY;
					vLenSQ += vToLightZ * vToLightZ;
					vLenSQ = max( vLenSQ, 0.000001 );

#if FX_PBR_USE_LM_POINTATTEN
					float4 vAtten = saturate( 1.0f - sqrt( vLenSQ * unity_4LightAtten0 / 25.0f ) );
#else
					float4 vAtten = 1.0f / ( 1.0f + vLenSQ * unity_4LightAtten0 );
#endif

					float4 vLenCorrect = max( rsqrt( vLenSQ ), 0 );
					vToLightX *= vLenCorrect;
					vToLightY *= vLenCorrect;
					vToLightZ *= vLenCorrect;

					float4 vNoL;
					vNoL = vToLightX * vNormal.x;
					vNoL += vToLightY * vNormal.y;
					vNoL += vToLightZ * vNormal.z;
					vNoL = saturate( vNoL );

					float4 vHX = vToLightX + vViewDir.x;
					float4 vHY = vToLightY + vViewDir.y;
					float4 vHZ = vToLightZ + vViewDir.z;

					float4 vTmpSQ;
					vTmpSQ = vHX * vHX;
					vTmpSQ += vHY * vHY;
					vTmpSQ += vHZ * vHZ;
					vTmpSQ = max( vTmpSQ, 0.000001 );

					float4 vTmpCorrect = rsqrt( vTmpSQ );
					vHX *= vTmpCorrect;
					vHY *= vTmpCorrect;
					vHZ *= vTmpCorrect;

					float4 vNoH;
					vNoH = vHX * vNormal.x;
					vNoH += vHY * vNormal.y;
					vNoH += vHZ * vNormal.z;
					vNoH = saturate( vNoH );

					Color += vAtten.x * vNoL.x * unity_LightColor[0].rgb * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, vNoH.x, float3( vHX.x, vHY.x, vHZ.x ), vNormal ) );
					Color += vAtten.y * vNoL.y * unity_LightColor[1].rgb * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, vNoH.y, float3( vHX.y, vHY.y, vHZ.y ), vNormal ) );
					Color += vAtten.z * vNoL.z * unity_LightColor[2].rgb * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, vNoH.z, float3( vHX.z, vHY.z, vHZ.z ), vNormal ) );
					Color += vAtten.w * vNoL.w * unity_LightColor[3].rgb * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, vNoH.w, float3( vHX.w, vHY.w, vHZ.w ), vNormal ) );
				}

				// Fog
				UNITY_APPLY_FOG( aInput.fogCoord, Color );

				return fixed4( g_OutputColor( Color ), vBaseColor.a );
			}
			ENDCG
		}
	}

	Fallback "Legacy Shaders/VertexLit"
}
