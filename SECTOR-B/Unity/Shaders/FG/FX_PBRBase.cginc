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
sampler2D _texEmission;

// IBL
samplerCUBE g_texIBL;
float g_fIBLIntensity;

sampler2D g_texCartoonLit;

float3 hairColor;
float hairBrightness;
float hairSpecularStrength;
float hairSpecularPower;
float sssBrightness;
float sssStrength;
float3 sssColor;

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
#ifdef FX_PBR_USE_ALPHATEST
	float4 vBaseTexture = g_Tex2D_ColorAlpha( _MainTex, aInput.m_vTex );
	clip( vBaseTexture.a - _Cutoff );
#else
	float4 vBaseTexture = g_Tex2D_Color( _MainTex, aInput.m_vTex );
#endif

	float3 BaseColor = vBaseTexture.rgb;
#ifdef FX_HAIR
	BaseColor *= hairColor;
	BaseColor *= hairBrightness;
#endif
	float3 vMRA = g_Tex2D_Mask( _texMRA, aInput.m_vTex );
	float3 vNormal_S = g_Tex2D_Mask( _texNormal_S, aInput.m_vTex ).xyz;

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

#ifdef FX_SSS
	float Specular = 0.5;
	float sssMask = 1 - vNormal_S.b;
#else
	float Specular = vNormal_S.b;
#endif

	float Metallic = vMRA.r;
	float Roughness = vMRA.g;
	float AO = vMRA.b;

	half DielectricSpecular = 0.08 * Specular;
	half3 DiffuseColor = BaseColor - BaseColor * Metallic;	// 1 mad
	half3 SpecularColor = ( DielectricSpecular - DielectricSpecular * Metallic ) + BaseColor * Metallic;	// 2 mad

	float3 SH = ShadeSHPerPixel_Linear( vNormal, 0, aInput.m_vPosW );
	const float fMipMapCount = 7;

	half NoV = saturate( dot( vNormal, vViewDir ) );
	SpecularColor = EnvBRDFApprox( SpecularColor, Roughness, NoV );


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

#ifdef FX_SSS
	half ShadowNoL = lerp(Shadow * NoL, 1, sssBrightness * sssMask);
	half  LoV = saturate(saturate(dot(-vViewDir, _WorldSpaceLightPos0)) + 0.3);
	half edgeScale = saturate(1 - NoV);
	half3 sssAdd = sssMask * sssColor * sssStrength * LoV * edgeScale;

	Color += ShadowNoL * _LightColor0.rgb * (DiffuseColor + SpecularColor * SpecularArg);
	Color += sssAdd;
#else
	Color += Shadow * NoL * _LightColor0.rgb * ( DiffuseColor + SpecularColor * SpecularArg );
#endif

	half3 SpecularIBL = GetImageBasedReflectionLighting( Roughness, reflect( -vViewDir, vNormal ), g_texIBL, fMipMapCount, g_fIBLIntensity ) * AO;
#if FX_PBR_USE_SO
	half3 SpecularOcclusion = CalcSOColorByMaterialAO( vNormal, vViewDir, Roughness, AO, SpecularColor );
	Color += SpecularIBL * SpecularColor * SpecularOcclusion;
#else
	Color += SpecularIBL * SpecularColor;
#endif

	Color += DiffuseColor * SH * AO;

#ifdef FX_HAIR
	half3 T = half3(aInput.m_vT2W_0.y, aInput.m_vT2W_1.y, aInput.m_vT2W_2.y);
	half3 L = _WorldSpaceLightPos0;
	half3 V = -vViewDir;

	float sq1 = sqrt(1.0 - pow(dot(T, L), 2));
	float sq2 = sqrt(1.0 - pow(dot(T, V), 2));
	float aniso = dot(T, L) * dot(T, V) + sq1 * sq2;
	aniso = pow(aniso, hairSpecularPower) * NoL;
	
	half hairSpecular = saturate(aniso * Specular);
	Color += (hairSpecular * hairColor * hairSpecularStrength);
#endif

	// Point Lighting
	#ifdef FX_PBR_USE_POINTLIGHT
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
#ifdef FX_PBR_USE_CARTOON
		vNoL.x = g_Tex2D_Mask( g_texCartoonLit, float2( vNoL.x, 0.5f ) ).r;
		vNoL.y = g_Tex2D_Mask( g_texCartoonLit, float2( vNoL.y, 0.5f ) ).r;
		vNoL.z = g_Tex2D_Mask( g_texCartoonLit, float2( vNoL.z, 0.5f ) ).r;
		vNoL.w = g_Tex2D_Mask( g_texCartoonLit, float2( vNoL.w, 0.5f ) ).r;
#endif

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
	#endif

#ifdef FX_EMISSION
	float3 emissionColor = g_Tex2D_Color(_texEmission, aInput.m_vTex);
	Color += emissionColor;
#endif

	// Fog
	UNITY_APPLY_FOG( aInput.fogCoord, Color );

	return fixed4( g_OutputColor( Color ), vBaseTexture.a );
}