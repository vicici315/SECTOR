#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "FX_Common.cginc"

#pragma target 2.0


float _Cutoff;

sampler2D _MainTex;
sampler2D _texNormal_S;
sampler2D _texMRA;
float _T1;
float _T2;
float _T3;
float _T4;
float _MS;
float _SO;
float _SS;

// IBL
float4 g_arrSkyIrradiance[3];
samplerCUBE g_texIBL;
float g_fIBLIntensity;

sampler2D g_texCartoonLit;

struct SVS_Output
{
	float4 pos				: SV_POSITION;
	#ifdef LIGHTMAP_ON
		float4 m_vTex		: TEXCOORD0;
	#else
		float2 m_vTex		: TEXCOORD0;
	#endif
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

	aOutput.pos = UnityObjectToClipPos( v.vertex );
	aOutput.m_vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;

	float3 vNormalW = UnityObjectToWorldNormal( v.normal );
#ifdef FX_PBR_USE_TWOSIDE
	if ( dot( vNormalW, _WorldSpaceCameraPos.xyz - aOutput.m_vPosW ) < 0 )
	{
		vNormalW = -vNormalW;
	}
#endif
	float3 vTangentW = UnityObjectToWorldDir( v.tangent.xyz );
	float fTangentSign = v.tangent.w * unity_WorldTransformParams.w;
	float3 vBinormalW = cross( vNormalW, vTangentW ) * fTangentSign;
	aOutput.m_vT2W_0 = float3( vTangentW.x, vBinormalW.x, vNormalW.x );
	aOutput.m_vT2W_1 = float3( vTangentW.y, vBinormalW.y, vNormalW.y );
	aOutput.m_vT2W_2 = float3( vTangentW.z, vBinormalW.z, vNormalW.z );

	
	aOutput.m_vTex.xy = v.texcoord;
	#ifdef LIGHTMAP_ON
		aOutput.m_vTex.zw = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#endif

	TRANSFER_SHADOW( aOutput );
	UNITY_TRANSFER_FOG( aOutput, aOutput.pos );

	return aOutput;
}

fixed4 PS_Main( SVS_Output aInput ) : SV_Target
{
	float4 vBaseTexture = g_Tex2D_Color( _MainTex, aInput.m_vTex );

#ifdef FX_PBR_USE_ALPHATEST
	clip( vBaseTexture.a - _Cutoff - 0.2 );
#endif

	float3 BaseColor = vBaseTexture.rgb;
	float3 vMRA = g_Tex2D_Mask( _texMRA, aInput.m_vTex );
	float3 vNormal_S = g_Tex2D_Mask( _texNormal_S, aInput.m_vTex );

	float3 vNormal;
	{
		float2 vNormal2 = vNormal_S.xy * 2.0f - 1.0f;
		float z = sqrt( 1.0f - dot( vNormal2, vNormal2 ) );
		float3 vNormalT = normalize( float3( vNormal2, z ) );
					
		float3x3 mT2W;
		mT2W[0] = normalize( aInput.m_vT2W_0 );
		mT2W[1] = normalize( aInput.m_vT2W_1 );
		mT2W[2] = normalize( aInput.m_vT2W_2 );
		vNormal = mul( mT2W, vNormalT );
	}

	float3 vViewDir = normalize( _WorldSpaceCameraPos.xyz - aInput.m_vPosW );

	float Specular = vNormal_S.b;
	// float Specular = smoothstep(_T4,_T2+_T4,vNormal_S.b);
	float Metallic = vMRA.r;
	float Roughness = vMRA.g;
	float AO = vMRA.b;

	half DielectricSpecular = 0.08 * Specular;
	half3 DiffuseColor =  BaseColor - BaseColor * Metallic;	// 1 mad
	half3 SpecularColor = ( DielectricSpecular - DielectricSpecular * Metallic ) + BaseColor * Metallic;	// 2 mad

	float3 SH = ShadeSHPerPixel_Linear( vNormal, 0, aInput.m_vPosW );
	const float fMipMapCount = 7;

	half NoV = saturate( dot( vNormal, vViewDir ) );
	// SpecularColor =  EnvBRDFApprox( SpecularColor, Roughness, NoV);
	// SpecularColor =   smoothstep(_T4,_MS+_T4,EnvBRDFApprox(SpecularColor, Roughness, NoV));
	SpecularColor =  smoothstep(_SO,_SO+_SS,EnvBRDFApprox( SpecularColor, Roughness, NoV))*(1-Metallic)+smoothstep(_T4,_T4+_MS,EnvBRDFApprox( SpecularColor, Roughness, NoV))*Metallic;


	half3 Color = 0;
	half IndirectIrradiance = AO;

	#ifdef LIGHTMAP_ON
		float4 vLightMap = UNITY_SAMPLE_TEX2D( unity_Lightmap, aInput.m_vTex.zw );
		float3 vLightMapColor = DecodeLightmap( vLightMap );
		Color += vLightMapColor * BaseColor;
	#endif

	UNITY_LIGHT_ATTENUATION( Shadow, aInput, aInput.m_vPosW );


	float  NoL = saturate( dot( vNormal, _WorldSpaceLightPos0 ) );
	float3 H = normalize( _WorldSpaceLightPos0 + vViewDir );
	float  NoH = saturate( dot( vNormal, H ) );

	float SpecularArg = CalcSpecular( Roughness, NoH, H, vNormal );

#ifdef FX_PBR_USE_CARTOON
	NoL = g_Tex2D_Mask( g_texCartoonLit, float2( NoL, 0.5f ) ).r;
	SpecularArg = g_Tex2D_Mask( g_texCartoonLit, float2( saturate( SpecularArg ), 0 ) ).r + max( SpecularArg - 1.0f, 0 );
#endif

	Color += (_T3 + smoothstep(_T1,_T1+_T2,Shadow * NoL)) * _LightColor0.rgb * ( DiffuseColor + SpecularColor * SpecularArg );
	// Color += (_T3 + smoothstep(_T1,_T1+_T2,Shadow * NoL)) * _LightColor0.rgb * ( DiffuseColor + SpecularColor * smoothstep(_T4,_MS+_T4,SpecularArg) );

	half3 SpecularIBL = GetImageBasedReflectionLighting( Roughness, reflect( -vViewDir, vNormal ), g_texIBL, fMipMapCount, g_fIBLIntensity ) * AO;
#if FX_PBR_USE_SO
	half3 SpecularOcclusion = CalcSOColorByMaterialAO( vNormal, vViewDir, Roughness, AO, SpecularColor );
	Color += SpecularIBL * SpecularColor * SpecularOcclusion;
#else
	Color += SpecularIBL * SpecularColor;
#endif

	//Color += GetSkySHDiffuseSimple( vNormal, g_arrSkyIrradiance ) * SkyColor * DiffuseColor * AO;
	//Color += DiffuseColor * ShadeSHPerPixel_Linear( vNormal, 0, aInput.m_vPosW ) * AO;
	Color += DiffuseColor * SH * AO;

	// Point Lighting
	#ifdef FX_PBR_USE_POINTLIGHT
	{
		float4 vToLightX = unity_4LightPosX0 - aInput.m_vPosW.x;
		float4 vToLightY = unity_4LightPosY0 - aInput.m_vPosW.y;
		float4 vToLightZ = unity_4LightPosZ0 - aInput.m_vPosW.z;

		float4 vLenSQ;
		vLenSQ  = vToLightX * vToLightX;
		vLenSQ += vToLightY * vToLightY;
		vLenSQ += vToLightZ * vToLightZ;
		vLenSQ = max( vLenSQ, 0.000001 );

		float4 vLen = sqrt( vLenSQ );
		float4 vLenCorrect = max( 1 / vLen, 0 );

		vToLightX *= vLenCorrect.x;
		vToLightY *= vLenCorrect.y;
		vToLightZ *= vLenCorrect.z;

		float4 vNoL;
		vNoL  = vToLightX * vNormal.x;
		vNoL += vToLightY * vNormal.y;
		vNoL += vToLightZ * vNormal.z;
		vNoL = saturate( vNoL );

		{
			float _fNoL = vNoL.x;
			#ifdef FX_PBR_USE_CARTOON
				_fNoL = g_Tex2D_Mask( g_texCartoonLit, float2( _fNoL, 0.5f ) ).r;
			#endif
			float3 vLightDir = float3( vToLightX.x, vToLightY.x, vToLightZ.x );
			float _fAtten = unity_4LightAtten0.x;
			float3 _vLightColor = unity_LightColor[0].rgb;

			H = normalize( vLightDir + vViewDir );
			NoH = saturate( dot( vNormal, H ) );
			float fAtten = 1.0f / ( 1.0f + vLen.x * _fAtten );
			// float fAtten = smoothstep(_T1,_T2, 1.0f / ( 1.0f + vLen.x * _fAtten ));
			Color += fAtten * _fNoL * _vLightColor * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, NoH, H, vNormal ) );
		}

		{
			float _fNoL = vNoL.y;
			#ifdef FX_PBR_USE_CARTOON
				_fNoL = g_Tex2D_Mask( g_texCartoonLit, float2( _fNoL, 0.5f ) ).r;
			#endif
			float3 vLightDir = float3( vToLightX.y, vToLightY.y, vToLightZ.y );
			float _fAtten = unity_4LightAtten0.y;
			float3 _vLightColor = unity_LightColor[1].rgb;

			H = normalize( vLightDir + vViewDir );
			NoH = saturate( dot( vNormal, H ) );
			float fAtten = 1.0f / ( 1.0f + vLen.x * _fAtten );
			// float fAtten = smoothstep(_T1,_T2, 1.0f / ( 1.0f + vLen.x * _fAtten ));
			Color += fAtten * _fNoL * _vLightColor * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, NoH, H, vNormal ) );
		}

		{
			float _fNoL = vNoL.z;
			#ifdef FX_PBR_USE_CARTOON
				_fNoL = g_Tex2D_Mask( g_texCartoonLit, float2( _fNoL, 0.5f ) ).r;
			#endif
			float3 vLightDir = float3( vToLightX.z, vToLightY.z, vToLightZ.z );
			float _fAtten = unity_4LightAtten0.z;
			float3 _vLightColor = unity_LightColor[2].rgb;

			H = normalize( vLightDir + vViewDir );
			NoH = saturate( dot( vNormal, H ) );
			float fAtten = 1.0f / ( 1.0f + vLen.x * _fAtten );
			Color += fAtten * _fNoL * _vLightColor * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, NoH, H, vNormal ) );
		}
					
		{
			float _fNoL = vNoL.w;
			#ifdef FX_PBR_USE_CARTOON
				_fNoL = g_Tex2D_Mask( g_texCartoonLit, float2( _fNoL, 0.5f ) ).r;
			#endif
			float3 vLightDir = float3( vToLightX.w, vToLightY.w, vToLightZ.w );
			float _fAtten = unity_4LightAtten0.w;
			float3 _vLightColor = unity_LightColor[3].rgb;

			H = normalize( vLightDir + vViewDir );
			NoH = saturate( dot( vNormal, H ) );
			float fAtten = 1.0f / ( 1.0f + vLen.x * _fAtten );
			Color += fAtten * _fNoL * _vLightColor * ( DiffuseColor + SpecularColor * CalcSpecular( Roughness, NoH, H, vNormal ) );
		}
	}
	#endif

	// Fog
	UNITY_APPLY_FOG( aInput.fogCoord, Color );

	return fixed4( g_OutputColor( Color ), vBaseTexture.a );
}

fixed4 PS_Main_Add( SVS_Output aInput ) : SV_Target
{
	return float4( 0.5f, 0, 0, 1.0f );
}