

inline float4 g_Tex2D_Color( sampler2D _tex, float2 _uv )
{
	float4 vColor = tex2D( _tex, _uv );
	return float4( pow( vColor.rgb, 2.2f ), vColor.a );
	return vColor;
}

inline float4 g_Tex2D_Mask( sampler2D _tex, float2 _uv )
{
	return tex2D( _tex, _uv );
}

inline float3 g_Tex2D_Normal( sampler2D _tex, float2 _uv )
{
	return UnpackNormal( tex2D( _tex, _uv ) );
}

inline fixed3 g_OutputColor( fixed3 _vInput )
{
	return _vInput;
}

inline float3 g_DecodeLightMap( float4 _vLightMap )
{
	return _vLightMap.rgb;
	return 5.0f * _vLightMap.a * _vLightMap.rgb;
}

inline half GGX_Mobile( half Roughness, half NoH, half3 H, half3 N )
{
	float3 NxH = cross( N, H );
	float OneMinusNoHSqr = dot( NxH, NxH );

	half a = Roughness * Roughness;
	float n = NoH * a;
	float p = a / ( OneMinusNoHSqr + n * n );
	float d = p * p;
	return min( d, 65504.0f );
}

inline half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NoV )
{
	// [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
	// Adaptation to fit our G term.
	const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
	const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
	half4 r = Roughness * c0 + c1;
	half a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
	half2 AB = half2( -1.04, 1.04 ) * a004 + r.zw;

	// Anything less than 2% is physically impossible and is instead considered to be shadowing
	// Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
	AB.y *= saturate( 50.0 * SpecularColor.g );

	return SpecularColor * AB.x + AB.y;
}

inline half CalcSpecular( half Roughness, float NoH, float3 H, float3 N )
{
	return ( Roughness*0.25 + 0.25 ) * GGX_Mobile( Roughness, NoH, H, N );
}

#define REFLECTION_CAPTURE_ROUGHEST_MIP 1
#define REFLECTION_CAPTURE_ROUGHNESS_MIP_SCALE 1.2

inline half ComputeReflectionCaptureMipFromRoughness( half Roughness, half CubemapMaxMip )
{
	half LevelFrom1x1 = REFLECTION_CAPTURE_ROUGHEST_MIP - REFLECTION_CAPTURE_ROUGHNESS_MIP_SCALE * log2( Roughness );
	return CubemapMaxMip - 1 - LevelFrom1x1;
}

inline half3 GetImageBasedReflectionLighting( half Roughness, float3 R, samplerCUBE texIBL, half CubemapMaxMip, half3 SkyLightColor )
{
	half AbsoluteSpecularMip = ComputeReflectionCaptureMipFromRoughness( Roughness, CubemapMaxMip );
	half4 SpecularIBLSample = texCUBElod( texIBL, float4( R, AbsoluteSpecularMip ) );
	half3 SpecularIBL = g_DecodeLightMap( SpecularIBLSample );
	SpecularIBL *= SkyLightColor;

	return SpecularIBL;
}

/**
 * Computes sky diffuse lighting from the SH irradiance map.
 * This has the SH basis evaluation and diffuse convolution weights combined for minimal ALU's - see "Stupid Spherical Harmonics (SH) Tricks"
 */
inline float3 GetSkySHDiffuse( float3 Normal, float4 arrSkyIrradiance[7] )
{
	float4 NormalVector = float4( Normal, 1 );

	float3 Intermediate0, Intermediate1, Intermediate2;
	Intermediate0.x = dot( arrSkyIrradiance[0], NormalVector );
	Intermediate0.y = dot( arrSkyIrradiance[1], NormalVector );
	Intermediate0.z = dot( arrSkyIrradiance[2], NormalVector );

	float4 vB = NormalVector.xyzz * NormalVector.yzzx;
	Intermediate1.x = dot( arrSkyIrradiance[3], vB );
	Intermediate1.y = dot( arrSkyIrradiance[4], vB );
	Intermediate1.z = dot( arrSkyIrradiance[5], vB );

	float vC = NormalVector.x * NormalVector.x - NormalVector.y * NormalVector.y;
	Intermediate2 = arrSkyIrradiance[6].xyz * vC;

	// max to not get negative colors
	return max( 0, Intermediate0 + Intermediate1 + Intermediate2 );
}

/**
* Computes sky diffuse lighting from the SH irradiance map.
* This has the SH basis evaluation and diffuse convolution weights combined for minimal ALU's - see "Stupid Spherical Harmonics (SH) Tricks"
* Only does the first 3 components for speed.
*/
inline float3 GetSkySHDiffuseSimple( float3 Normal, float4 arrSkyIrradiance[3] )
{
	float4 NormalVector = float4( Normal, 1 );

	float3 Intermediate0;
	Intermediate0.x = dot( arrSkyIrradiance[0], NormalVector );
	Intermediate0.y = dot( arrSkyIrradiance[1], NormalVector );
	Intermediate0.z = dot( arrSkyIrradiance[2], NormalVector );

	// max to not get negative colors
	return max( 0, Intermediate0 );
}

inline half3 ShadeSHPerPixel_Linear( half3 normal, half3 ambient, float3 worldPos )
{
	half3 ambient_contrib = 0.0;

	// Completely per-pixel
#if UNITY_LIGHT_PROBE_PROXY_VOLUME
	if ( unity_ProbeVolumeParams.x == 1.0 )
		ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume( half4( normal, 1.0 ), worldPos );
	else
		ambient_contrib = SHEvalLinearL0L1( half4( normal, 1.0 ) );
#else
	ambient_contrib = SHEvalLinearL0L1( half4( normal, 1.0 ) );
#endif

	ambient_contrib += SHEvalLinearL2( half4( normal, 1.0 ) );

	ambient += max( half3( 0, 0, 0 ), ambient_contrib );

	return ambient;
}