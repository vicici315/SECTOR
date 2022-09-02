#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "FX_Common.cginc"

#pragma target 2.0


sampler2D _MainTex;
sampler2D _texNormal_S;
sampler2D _texMRA;

// IBL
samplerCUBE _texIBL;
float _IBLCorrect;
float _SPELEV;
float _METALLIC;
float _ROUGHNESS;
float3 _BaseColor;

struct SVS_Output
{
	float4 pos				: SV_POSITION;
	#ifdef FX_PBR_USE_LIGHTMAP
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

	float3 vNormalW = UnityObjectToWorldNormal( v.normal );
	float3 vTangentW = UnityObjectToWorldDir( v.tangent.xyz );
	float fTangentSign = v.tangent.w * unity_WorldTransformParams.w;
	float3 vBinormalW = cross( vNormalW, vTangentW ) * fTangentSign;
	aOutput.m_vT2W_0 = float3( vTangentW.x, vBinormalW.x, vNormalW.x );
	aOutput.m_vT2W_1 = float3( vTangentW.y, vBinormalW.y, vNormalW.y );
	aOutput.m_vT2W_2 = float3( vTangentW.z, vBinormalW.z, vNormalW.z );

	aOutput.pos = UnityObjectToClipPos( v.vertex );
	float3 vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;
	aOutput.m_vTex.xy = v.texcoord;
	#ifdef FX_PBR_USE_LIGHTMAP
		aOutput.m_vTex.zw = v.texcoord1;
	#endif

	TRANSFER_SHADOW( aOutput );
	UNITY_TRANSFER_FOG( aOutput, aOutput.pos );
	aOutput.m_vPosW = vPosW;

	return aOutput;
}

fixed4 PS_Main( SVS_Output aInput ) : SV_Target
{
	float4 vBaseTexture = g_Tex2D_Color( _MainTex, aInput.m_vTex );
	float3 BaseColor = vBaseTexture.rgb * _BaseColor.rgb;
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

	float Specular = vNormal_S.b * _SPELEV;
	float Metallic = vMRA.r * _METALLIC;
	float Roughness = vMRA.g * _ROUGHNESS;
	float AO = vMRA.b;

	half DielectricSpecular = 0.08 * Specular;
	half3 DiffuseColor = (BaseColor - BaseColor * Metallic);	// 1 mad
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

	half3 SpecularIBL = GetImageBasedReflectionLighting( Roughness, reflect( -vViewDir, vNormal ), _texIBL, fMipMapCount, _IBLCorrect ) * AO;
	Color += SpecularIBL * SpecularColor;

	Color += DiffuseColor * SH * AO;

	// Fog
	UNITY_APPLY_FOG( aInput.fogCoord, Color );

	return fixed4( g_OutputColor( Color ), vBaseTexture.a );
}