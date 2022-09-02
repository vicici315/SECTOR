#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"

sampler2D 	_MainTex;
float4 		_MainTex_ST;
half 		_FurLength;
half 		_FurThickness;
sampler2D   _FurMask;
half 		_FurOffset;
half4 		_UVOffset;
sampler2D 	_NoiseMap;
float4 		_NoiseMap_ST;
half3 		_RimLightColor;
half 		_RimLightScale;
half 		_DensityAttenBase;
half 		_DensityAttenScale;
half 		_DirectTransmittance;
half4 		_Wind;
half2 		_WindParams;
half3 		_Color;

struct VertexInput
{
	float4 vertex 	: POSITION;
	float2 texcoord : TEXCOORD0;
	float3 normal 	: NORMAL;
	float3 tangent 	: TANGENT;
};

struct VSOut
{
	float4 pos 				: SV_POSITION;
	float4 uv 				: TEXCOORD0;
	float3 worldNormal 		: TEXCOORD1;
	float3 worldPos 		: TEXCOORD2;
	float3 lighting 		: TEXCOORD3;
	//float3 lightingIndirect : TEXCOORD4;
	//UNITY_SHADOW_COORDS(7)
};

float4 SmoothCurve( float4 x ) 
{
    return x * x *( 3.0 - 2.0 * x );
}
float4 TriangleWave( float4 x ) 
{
    return abs( frac( x + 0.5 ) * 2.0 - 1.0 );
}
float4 SmoothTriangleWave( float4 x ) 
{
    return SmoothCurve( TriangleWave( x ) );
}

float2 WindUVOffset(float3 worldPos, float3 worldNormal, float3 worldTangent, float furOffset)
{
	// UV Offset
	float fVtxPhase = dot(worldPos, _WindParams.x);
			
	// x is used for edges; y is used for branches
	float2 vWavesIn = _Time.x * _WindParams.y + float2(fVtxPhase, 0 );
	
	// 1.975, 0.793, 0.375, 0.193 are good frequencies
	float4 vWaves = (frac( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0);
	
	vWaves = SmoothTriangleWave( vWaves );
	float2 vWavesSum = vWaves.xz + vWaves.yw;

	float3 tangentProj = _Wind.xyz - worldNormal * dot(worldNormal, _Wind.xyz);
	float2 uvOffset = 0.0;
	float uWind = dot(tangentProj, worldTangent);
	float vWind = length(tangentProj - uWind * worldTangent);
	float wave = vWaves.x + vWaves.y;
	uvOffset.x -= uWind * wave;
	uvOffset.y -= vWind * wave;
	return uvOffset;
}

VSOut vert(VertexInput v)
{
	VSOut o;
	half4 furMask = tex2Dlod(_FurMask, half4(v.texcoord.xy, 0, 0));
	half furOffset = pow(_FurOffset.x, _FurThickness);
	half offset = _FurLength * furOffset * furMask.r;
	
	v.vertex.xyz += offset * v.normal.xyz;
	o.pos = mul(UNITY_MATRIX_MVP, float4(v.vertex.xyz, 1.0));
	float3 worldNormal 	= normalize(mul(UNITY_MATRIX_M, float4(v.normal.xyz, 0.0)).xyz);
	o.worldNormal = worldNormal;
	float3 worldPos 	= mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1.0)).xyz;
	o.worldPos = worldPos;
	float3 worldTangent = normalize(mul(UNITY_MATRIX_M, float4(v.tangent.xyz, 0.0)).xyz);

	float3 _n = worldNormal;
	float3 _l = _MainLightPosition.xyz;
	float3 _v = normalize(GetCameraPositionWS() - worldPos);

	float nv = max(0.0, dot(_n, _v));
	float2 uvOffset = _UVOffset.xy * (furMask.b*2-1) + _UVOffset.zw * WindUVOffset(worldPos, worldNormal, worldTangent, furOffset) * nv;
	uvOffset *= 0.1 * furOffset;
	o.uv.xy = TRANSFORM_TEX((v.texcoord.xy + uvOffset), _MainTex);
	o.uv.zw = TRANSFORM_TEX((v.texcoord.xy + uvOffset), _NoiseMap);

	//UNITY_TRANSFER_SHADOW(o, v.texcoord1);

	// Lighting
	o.lighting = 0.0;
	half3 ambient = SampleSHVertex(_n);
	o.lighting += ambient;

	half fresnel = 1.0 - nv;
	half3 rim = fresnel * fresnel * _RimLightScale * ambient * _RimLightColor;
	o.lighting += rim;

	half nl = dot(_n, _l);
	half3 direct = saturate(nl + _FurOffset.x + _DirectTransmittance) * _MainLightColor.xyz;
	o.lighting += direct;

	half atten = saturate(_DensityAttenBase + _FurOffset.x * _FurOffset.x * _DensityAttenScale);
	o.lighting *= atten;

	return o;
}

float4 frag(VSOut input) : SV_TARGET
{
    float4 color = 0.0;

    half noiseMask = tex2D(_FurMask, input.uv.xy).g;
	half noise = tex2Dlod(_NoiseMap,  float4(input.uv.zw,  0.0, 0.0)).r;
	half densityClip = _FurOffset.x * 1.0;
	//half alpha = noise - densityClip * densityClip;
	half alpha = (noise - densityClip) * noiseMask;
	color.a = saturate(alpha);

	//UNITY_LIGHT_ATTENUATION(atten, input, input.worldPos);

	half3 albedo = _Color.rgb * tex2D(_MainTex, input.uv.xy).rgb;
	color.rgb = input.lighting * albedo;

	return color;
}