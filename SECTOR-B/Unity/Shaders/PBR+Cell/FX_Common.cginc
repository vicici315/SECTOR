// !!! Do not change this lines, It will modify by scripts !!!
#define FX_USE_H5 0
// !!! Do not change this lines, It will modify by scripts !!!

#if FX_USE_H5
	#define FX_USE_SPLITALPHA		1
	#define FX_USE_HDR_ENCODE		1
#else
	#define FX_USE_SPLITALPHA		0
	#define FX_USE_HDR_ENCODE		0
#endif

#define FX_USE_GAMMATEXTURE			1
#define FX_USE_TONEMAPPING_ACES		0
#define FX_USE_HDR					1
#define FX_USE_FILETONEMAPPING		0
#define FX_USE_LUT					0
#define FX_FXAA_QUALITY		        2	//1 - LOW  2 - MEDIUM  3 - HIGH

#define FX_PBR_USE_SO				1
//#define FX_PBR_USE_ALPHATEST
//#define FX_PBR_USE_POINTLIGHT
//#define FX_PBR_USE_CARTOON
//#define FX_PBR_USE_TWOSIDE


#if FX_USE_SPLITALPHA
	sampler2D _MainTex_a;
	#define TEX2D_COLOR( tex, uv )		float4( g_Tex2D_Color( tex, uv ).rgb, g_Tex2D_Mask( tex##_a, uv ).r )
#else
	#define TEX2D_COLOR( tex, uv )		g_Tex2D_Color( tex, uv )
#endif


inline float3 g_DecodeHDR( float3 _vColor )
{
	float3 vH = saturate( _vColor * 10.0f - 8.0f );

	float3 vL = saturate( _vColor / 0.8f );
	return vL + vH;
}

inline float3 g_EncodeHDR( float3 _vColor )
{
	return saturate( _vColor ) * 0.8f + saturate( _vColor * 0.5f - 0.5f ) * 0.2f;
}

inline float3 g_DecodeColor( float4 _vColor )
{
#if FX_USE_HDR_ENCODE
	return g_DecodeHDR( _vColor.rgb );
#else
	return _vColor.rgb;
#endif
}

inline float4 g_EncodeColor( float3 _vColor )
{
#if FX_USE_HDR_ENCODE
	return float4( g_EncodeHDR( _vColor ), 1.0f );
#else
	return float4( _vColor, 1.0f );
#endif
}

inline float3 g_CalcDirectionLighting_DiffuseOnly( float3 _vBaseColor, float3 _vLightColor, float3 _vLightDir, float3 _vViewDir, float3 _vNormal )
{
	half  fDiffuseArg = saturate( dot( _vLightDir, _vNormal ) );
	return fDiffuseArg * _vBaseColor * _vLightColor;
}

inline float3 g_CalcDirectionLighting( float3 _vBaseColor, float3 _vLightColor, float3 _vLightDir, float3 _vViewDir, float3 _vNormal, float3 _vGAX, float _fSpecSharp )
{
	half  fDiffuseArg = saturate( dot( _vLightDir, _vNormal ) );

	half3 h = normalize( _vLightDir + _vViewDir );
	half  nh = saturate( dot( _vNormal, h ) );
	half  fSpecularArg = pow( nh, _fSpecSharp ) * _vGAX.r;

	return ( fDiffuseArg * _vBaseColor + fSpecularArg ) * _vLightColor;
}

inline float3 g_CalcPointLighting_DiffuseOnly( float3 _vBaseColor, float3 _vLightColor, float3 _vLightDir, float3 _vViewDir, float3 _vNormal, float _fAtten )
{
	float fLightDistance = length( _vLightDir );
	_vLightDir = _vLightDir / max( fLightDistance, 0.00001f );

	float fAtten = 1.0f / ( 1.0f + fLightDistance * _fAtten );

	half  fDiffuseArg = saturate( dot( _vLightDir, _vNormal ) );
	return fDiffuseArg * _vBaseColor * _vLightColor * fAtten;
}

inline float3 g_CalcPointLighting( float3 _vBaseColor, float3 _vLightColor, float3 _vLightDir, float3 _vViewDir, float3 _vNormal, float3 _vGAX, float _fSpecSharp, float _fAtten )
{
	float fLightDistance = length( _vLightDir );
	_vLightDir = _vLightDir / max( fLightDistance, 0.00001f );

	float fAtten = 1.0f / ( 1.0f + fLightDistance * _fAtten );

	half  fDiffuseArg = saturate( dot( _vLightDir, _vNormal ) );

	half3 h = normalize( _vLightDir + _vViewDir );
	half  nh = saturate( dot( _vNormal, h ) );
	half  fSpecularArg = pow( nh, _fSpecSharp ) * _vGAX.r;

	return ( fDiffuseArg * _vBaseColor + fSpecularArg ) * _vLightColor * fAtten;
}

inline float4 g_Tex2D_Color( sampler2D _tex, float2 _uv )
{
	float4 vColor = tex2D( _tex, _uv );
#if FX_USE_GAMMATEXTURE
	return float4( pow( vColor.rgb, 2.2f ), vColor.a );
#else
	return vColor;
#endif
}

inline float4 g_Tex2D_Mask( sampler2D _tex, float2 _uv )
{
	return tex2D( _tex, _uv );
}

inline float3 g_Tex2D_Normal( sampler2D _tex, float2 _uv )
{
	return UnpackNormal( tex2D( _tex, _uv ) );
}

inline float4 g_TexCube_Color( samplerCUBE _tex, float3 _uv )
{
	float4 vColor = texCUBE( _tex, _uv );
#if FX_USE_GAMMATEXTURE
	return float4( pow( vColor.rgb, 2.2f ), vColor.a );
#else
	return vColor;
#endif
}

inline float3 g_DecodeLightMap( float4 _vLightMap )
{
#if defined(UNITY_LIGHTMAP_DLDR_ENCODING)
	return unity_Lightmap_HDR.x * _vLightMap.rgb;
#elif defined(UNITY_LIGHTMAP_RGBM_ENCODING)
	return 5.0f * _vLightMap.a * _vLightMap.rgb;
#else
	return _vLightMap.rgb;
#endif
}

inline float3 g_ACESToneMapping( float3 _vInput )
{
	const float A = 2.51f;
	const float B = 0.03f;
	const float C = 2.43f;
	const float D = 0.59f;
	const float E = 0.14f;

	return ( _vInput * ( A * _vInput + B ) ) / ( _vInput * ( C * _vInput + D ) + E );
}

inline fixed3 g_OutputColor( fixed3 _vInput )
{
#if FX_USE_HDR
    #if FX_USE_HDR_ENCODE
	    return g_EncodeHDR( _vInput );
    #else
        return _vInput;
    #endif
#else
	#if FX_USE_TONEMAPPING_ACES
		float3 vColor = g_ACESToneMapping( _vInput );
	#else
		float3 vColor = _vInput;
	#endif

	#if FX_USE_GAMMATEXTURE
		return pow( vColor, 1.0f / 2.2f );
	#else
		return vColor;
	#endif
#endif
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
	half3 SpecularIBL = pow( SpecularIBLSample.rgb, 2.2f );
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

// -------------------- For PostProcess -------------------- //

inline float g_GetLuminance( float3 _vColor )
{
	const float3 s_vLuminance = float3( 0.2126f, 0.7152f, 0.0722f );
	return dot( _vColor, s_vLuminance );
}

static const float3x3 AP0_2_XYZ_MAT =
{
	0.9525523959, 0.0000000000, 0.0000936786,
	0.3439664498, 0.7281660966,-0.0721325464,
	0.0000000000, 0.0000000000, 1.0088251844,
};

static const float3x3 XYZ_2_AP0_MAT =
{
	 1.0498110175, 0.0000000000,-0.0000974845,
	-0.4959030231, 1.3733130458, 0.0982400361,
	 0.0000000000, 0.0000000000, 0.9912520182,
};

static const float3x3 AP1_2_XYZ_MAT =
{
	 0.6624541811, 0.1340042065, 0.1561876870,
	 0.2722287168, 0.6740817658, 0.0536895174,
	-0.0055746495, 0.0040607335, 1.0103391003,
};

static const float3x3 XYZ_2_AP1_MAT =
{
	 1.6410233797, -0.3248032942, -0.2364246952,
	-0.6636628587,  1.6153315917,  0.0167563477,
	 0.0117218943, -0.0082844420,  0.9883948585,
};

static const float3x3 AP0_2_AP1_MAT =
{
	 1.4514393161, -0.2365107469, -0.2149285693,
	-0.0765537734,  1.1762296998, -0.0996759264,
	 0.0083161484, -0.0060324498,  0.9977163014,
};

static const float3x3 AP1_2_AP0_MAT =
{
	 0.6954522414,  0.1406786965,  0.1638690622,
	 0.0447945634,  0.8596711185,  0.0955343182,
	-0.0055258826,  0.0040252103,  1.0015006723,
};

static const float3 AP1_RGB2Y =
{
	0.2722287168,
	0.6740817658,
	0.0536895174,
};

static const float3x3 XYZ_2_sRGB_MAT =
{
	 3.2409699419, -1.5373831776, -0.4986107603,
	-0.9692436363,  1.8759675015,  0.0415550574,
	 0.0556300797, -0.2039769589,  1.0569715142,
};

static const float3x3 sRGB_2_XYZ_MAT =
{
	0.4124564, 0.3575761, 0.1804375,
	0.2126729, 0.7151522, 0.0721750,
	0.0193339, 0.1191920, 0.9503041,
};

static const float3x3 XYZ_2_Rec2020_MAT =
{
	 1.7166084, -0.3556621, -0.2533601,
	-0.6666829,  1.6164776,  0.0157685,
	 0.0176422, -0.0427763,  0.94222867
};

static const float3x3 Rec2020_2_XYZ_MAT =
{
	0.6369736, 0.1446172, 0.1688585,
	0.2627066, 0.6779996, 0.0592938,
	0.0000000, 0.0280728, 1.0608437
};

static const float3x3 XYZ_2_P3D65_MAT =
{
	 2.4933963, -0.9313459, -0.4026945,
	-0.8294868,  1.7626597,  0.0236246,
	 0.0358507, -0.0761827,  0.9570140
};

static const float3x3 P3D65_2_XYZ_MAT =
{
	0.4865906, 0.2656683, 0.1981905,
	0.2289838, 0.6917402, 0.0792762,
	0.0000000, 0.0451135, 1.0438031
};

static const float3x3 D65_2_D60_CAT =
{
	 1.01303,    0.00610531, -0.014971,
	 0.00769823, 0.998165,   -0.00503203,
	-0.00284131, 0.00468516,  0.924507,
};

static const float3x3 D60_2_D65_CAT =
{
	 0.987224,   -0.00611327, 0.0159533,
	-0.00759836,  1.00186,    0.00533002,
	 0.00307257, -0.00509595, 1.08168,
};

static const float HALF_MAX = 65504.0;
const static float PI = 3.1415f;

inline float Square(float x)
{
	return x * x;
}

inline float2 Square(float2 x)
{
	return x * x;
}

inline float3 Square(float3 x)
{
	return x * x;
}

inline float4 Square(float4 x)
{
	return x * x;
}

inline float center_hue(float hue, float centerH)
{
	float hueCentered = hue - centerH;
	if (hueCentered < -180.)
		hueCentered += 360;
	else if (hueCentered > 180.)
		hueCentered -= 360;
	return hueCentered;
}

inline float rgb_2_saturation(float3 rgb)
{
	float minrgb = min(min(rgb.r, rgb.g), rgb.b);
	float maxrgb = max(max(rgb.r, rgb.g), rgb.b);
	return (max(maxrgb, 1e-10) - max(minrgb, 1e-10)) / max(maxrgb, 1e-2);
}

inline float rgb_2_hue(float3 rgb)
{
	float hue;
	if (rgb[0] == rgb[1] && rgb[1] == rgb[2])
	{
		hue = 0;
	}
	else
	{
		hue = (180. / PI) * atan2(sqrt(3.0)*(rgb[1] - rgb[2]), 2 * rgb[0] - rgb[1] - rgb[2]);
	}

	if (hue < 0.)
		hue = hue + 360;

	return clamp(hue, 0, 360);
}

float FilmSlope = 0.91;
float FilmToe = 0.53;
float FilmShoulder = 0.23;
float FilmBlackClip = 0;
float FilmWhiteClip = 0.035;

inline half3 FilmToneMap(half3 LinearColor)
{
	const float3x3 sRGB_2_AP0 = mul(XYZ_2_AP0_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
	const float3x3 sRGB_2_AP1 = mul(XYZ_2_AP1_MAT, mul(D65_2_D60_CAT, sRGB_2_XYZ_MAT));
	const float3x3 AP1_2_sRGB = mul(XYZ_2_sRGB_MAT, mul(D60_2_D65_CAT, AP1_2_XYZ_MAT));

	float3 ACESColor = mul(sRGB_2_AP0, float3(LinearColor));

	const float RRT_RED_SCALE = 0.82;
	const float RRT_RED_PIVOT = 0.03;
	const float RRT_RED_HUE = 0;
	const float RRT_RED_WIDTH = 135;
	float saturation = rgb_2_saturation(ACESColor);
	float hue = rgb_2_hue(ACESColor);
	float centeredHue = center_hue(hue, RRT_RED_HUE);
	float hueWeight = Square(smoothstep(0, 1, 1 - abs(2 * centeredHue / RRT_RED_WIDTH)));
	ACESColor.r += hueWeight * saturation * (RRT_RED_PIVOT - ACESColor.r) * (1. - RRT_RED_SCALE);
	float3 WorkingColor = mul(sRGB_2_AP1, float3(LinearColor));

	WorkingColor = max(0, WorkingColor);
	WorkingColor = lerp(dot(WorkingColor, AP1_RGB2Y), WorkingColor, 0.96);

	const half ToeScale = 1 + FilmBlackClip - FilmToe;
	const half ShoulderScale = 1 + FilmWhiteClip - FilmShoulder;

	const float InMatch = 0.18;
	const float OutMatch = 0.18;
	float ToeMatch;
	if (FilmToe > 0.8)
	{
		ToeMatch = (1 - FilmToe - OutMatch) / FilmSlope + log10(InMatch);
	}
	else
	{
		const float bt = (OutMatch + FilmBlackClip) / ToeScale - 1;
		ToeMatch = log10(InMatch) - 0.5 * log((1 + bt) / (1 - bt)) * (ToeScale / FilmSlope);
	}
	float StraightMatch = (1 - FilmToe) / FilmSlope - ToeMatch;
	float ShoulderMatch = FilmShoulder / FilmSlope - StraightMatch;

	half3 LogColor = log10(WorkingColor);
	half3 StraightColor = FilmSlope * (LogColor + StraightMatch);

	half3 ToeColor = (-FilmBlackClip) + (2 * ToeScale) / (1 + exp((-2 * FilmSlope / ToeScale) * (LogColor - ToeMatch)));
	half3 ShoulderColor = (1 + FilmWhiteClip) - (2 * ShoulderScale) / (1 + exp((2 * FilmSlope / ShoulderScale) * (LogColor - ShoulderMatch)));

	ToeColor = LogColor < ToeMatch ? ToeColor : StraightColor;
	ShoulderColor = LogColor > ShoulderMatch ? ShoulderColor : StraightColor;


	half3 t = saturate((LogColor - ToeMatch) / (ShoulderMatch - ToeMatch));
	t = ShoulderMatch < ToeMatch ? 1 - t : t;
	t = (3 - 2 * t)*t*t;
	half3 ToneColor = lerp(ToeColor, ShoulderColor, t);

	ToneColor = lerp(dot(float3(ToneColor), AP1_RGB2Y), ToneColor, 0.93);

	return max(0, ToneColor);
}

float2 g_Circle( float Start, float Points, float Point )
{
	float Rad = ( 3.141592 * 2.0 * ( 1.0 / Points ) ) * ( Point + Start );
	return float2( sin( Rad ), cos( Rad ) );
}

// -------------------- For SO -------------------- //

struct FSphericalGaussian
{
	float3	Axis;		// u
	float	Sharpness;	// L
	float	Amplitude;	// a
};

float Evaluate( FSphericalGaussian G, float3 Direction )
{
	// G( v; u,L,a ) = a * exp( L * (dot(u,v) - 1) )

	return G.Amplitude * exp( G.Sharpness * ( dot( G.Axis, Direction ) - 1 ) );
}

FSphericalGaussian Hemisphere_ToSphericalGaussian( float3 Normal )
{
	FSphericalGaussian G;

	G.Axis = Normal;
	G.Sharpness = 0.81;
	G.Amplitude = 0.81 / ( 1 - exp( -2 * 0.81 ) );

	return G;
}

// Bent normal is normalized. AO is [0,1]. Both are cosine weighted.
FSphericalGaussian BentNormalAO_ToSphericalGaussian( float3 BentNormal, float AO )
{
	// ConeAngle ~= sqrt( 2/L )
	// L ~= 2/ConeAngle^2

	FSphericalGaussian G;

	G.Axis = BentNormal;

#if 1
	// Cosine weighted integration of spherical cap
	// PI * SinAlpha^2
	// L ~= 2 / Pow2( acos( sqrt(1- AO) ) );

	// Approximation (no acos)
	G.Sharpness = ( 0.75 + 1.25 * sqrt( 1 - AO ) ) / AO;
#else
	// Solid angle of cone = 2 * PI * (1 - CosTheta)
	// Solid angle of cone = 2*PI * AO
	// AO = 1 - cos( ConeAngle )
	// L ~= 2 / Pow2( acos( 1- AO ) );

	// Approximation (no acos)
	G.Sharpness = ( 1 - 0.19 * AO ) / AO;
#endif

	// AO=1 integrates to 2pi
	const float HemisphereSharpness = 0.81;
	G.Amplitude = HemisphereSharpness / ( 1 - exp( -2 * HemisphereSharpness ) );

	return G;
}

// [ Jimenez et al. 2016, "Practical Realtime Strategies for Accurate Indirect Occlusion" ]
float3 AOMultiBounce( float3 BaseColor, float AO )
{
	float3 a = 2.0404 * BaseColor - 0.3324;
	float3 b = -4.7951 * BaseColor + 0.6417;
	float3 c = 2.7552 * BaseColor + 0.6903;
	return max( AO, ( ( AO * a + b ) * AO + c ) * AO );
}

struct FAnisoSphericalGaussian
{
	float3	AxisX;
	float3	AxisY;
	float3	AxisZ;
	float	SharpnessX;
	float	SharpnessY;
	float	Amplitude;
};

inline float Pow2( float _vValue )
{
	return _vValue * _vValue;
}

float Evaluate( FAnisoSphericalGaussian ASG, float3 Direction )
{
	float L = ASG.SharpnessX * Pow2( dot( Direction, ASG.AxisX ) );
	float u = ASG.SharpnessY * Pow2( dot( Direction, ASG.AxisY ) );
	return ASG.Amplitude * saturate( dot( Direction, ASG.AxisZ ) ) * exp( -L - u );
}

float Dot( FAnisoSphericalGaussian ASG, FSphericalGaussian SG )
{
	// ASG( v; u,nu,a ) = a * exp( 2 * nu * (dot(u,v) - 1) )

	float nu = SG.Sharpness * 0.5;

	ASG.Amplitude *= SG.Amplitude;
	ASG.Amplitude *= PI * rsqrt( ( nu + ASG.SharpnessX ) * ( nu + ASG.SharpnessY ) );
	ASG.SharpnessX = ( nu * ASG.SharpnessX ) / ( nu + ASG.SharpnessX );
	ASG.SharpnessY = ( nu * ASG.SharpnessY ) / ( nu + ASG.SharpnessY );

	return Evaluate( ASG, SG.Axis );
}

float DotSpecularSG( float Roughness, float3 N, float3 V, FSphericalGaussian LightSG )
{
	float a = Pow2( max( 0.02, Roughness ) );
	float a2 = a * a;

	float3 L = LightSG.Axis;
	float3 H = normalize( V + L );

	float NoV = saturate( abs( dot( N, V ) ) + 1e-5 );

	FSphericalGaussian NDF;
	NDF.Axis = N;
	NDF.Sharpness = 2 / a2;
	NDF.Amplitude = rcp( PI * a2 );

#if 0
	{
		// Reflect NDF
		//float3 R = 2 * dot( V, N ) * N - V;
		float3 R = 2 * NoV * N - V;

		// Point lobe in off-specular peak direction
		//R = lerp( N, R, (1 - a) * ( sqrt(1 - a) + a ) );
		//R = normalize( R );

#if 0
		// Warp
		FSphericalGaussian SpecularSG;
		SpecularSG.Axis = R;
		SpecularSG.Sharpness = 0.5 / ( a2 * max( NoV, 0.1 ) );
		SpecularSG.Amplitude = rcp( PI * a2 );
#else
		FAnisoSphericalGaussian SpecularSG;
		SpecularSG.AxisZ = R;
		SpecularSG.AxisX = normalize( cross( N, SpecularSG.AxisZ ) );
		SpecularSG.AxisY = normalize( cross( R, SpecularSG.AxisX ) );

		// Second derivative of the sharpness with respect to how
		// far we are from basis Axis direction
		SpecularSG.SharpnessX = 0.25 / ( a2 * Pow2( max( NoV, 0.001 ) ) );
		SpecularSG.SharpnessY = 0.25 / a2;
		SpecularSG.Amplitude = rcp( PI * a2 );
#endif
		return Dot( SpecularSG, LightSG );
	}
#elif 0
	{
		// Project LightSG into half vector space
#if 0
		FSphericalGaussian WarpedLightSG;
		WarpedLightSG.Axis = H;
		WarpedLightSG.Sharpness = LightSG.Sharpness * 1.5 * NoV;
		WarpedLightSG.Amplitude = LightSG.Amplitude;
#else
		FAnisoSphericalGaussian WarpedLightSG;
		WarpedLightSG.AxisZ = H;
		WarpedLightSG.AxisX = normalize( cross( N, WarpedLightSG.AxisZ ) );
		WarpedLightSG.AxisY = normalize( cross( H, WarpedLightSG.AxisX ) );

		// Second derivative of the sharpness with respect to how
		// far we are from basis Axis direction
		WarpedLightSG.SharpnessX = LightSG.Sharpness * 2 * Pow2( NoV );
		WarpedLightSG.SharpnessY = LightSG.Sharpness * 2;
		WarpedLightSG.Amplitude = LightSG.Amplitude;
#endif

		return Dot( WarpedLightSG, NDF );
	}
#else
	{
		// We can do the half space ASG method cheaper by assuming H is in the YZ plane.
		float SharpnessX = LightSG.Sharpness * 2 * Pow2( NoV );
		float SharpnessY = LightSG.Sharpness * 2;

		float nu = NDF.Sharpness * 0.5;

		FSphericalGaussian ConvolvedNDF;
		ConvolvedNDF.Axis = NDF.Axis;
		ConvolvedNDF.Sharpness = 2 * ( nu * SharpnessY ) / ( nu + SharpnessY );
		ConvolvedNDF.Amplitude = NDF.Amplitude * LightSG.Amplitude;
		ConvolvedNDF.Amplitude *= PI * rsqrt( ( nu + SharpnessX ) * ( nu + SharpnessY ) );

		//float3 AxisX = normalize( cross( N, V ) );
		//ConvolvedNDF.Amplitude *= exp( -(nu * SharpnessX) / (nu + SharpnessX) * Pow2( dot( H, AxisX ) ) );

		return Evaluate( ConvolvedNDF, H );
	}
#endif
}

float3 CalcSOColorByMaterialAO( float3 _vNormal, float3 _vCameraDir, float _fRoughness, float _fSpecOcclusion, float3 _vSpecularColor )
{
	FSphericalGaussian HemisphereSG = Hemisphere_ToSphericalGaussian( _vNormal );
	FSphericalGaussian VisibleSG = BentNormalAO_ToSphericalGaussian( _vNormal, _fSpecOcclusion );

	_fSpecOcclusion = DotSpecularSG( _fRoughness, _vNormal, _vCameraDir, VisibleSG );
	_fSpecOcclusion /= DotSpecularSG( _fRoughness, _vNormal, _vCameraDir, HemisphereSG );

	_fSpecOcclusion = saturate( _fSpecOcclusion );

	return AOMultiBounce( _vSpecularColor, _fSpecOcclusion );
}

// -------------------- End -------------------- //