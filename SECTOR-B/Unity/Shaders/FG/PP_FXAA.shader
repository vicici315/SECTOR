Shader "Hidden/PP_FXAA"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Cull Off ZWrite Off ZTest Always

        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertDefault
            #pragma fragment frag
            // make fog work
			#pragma target 3.0

			#define FXAA_HLSL_3 1
			#define FXAA_PC 1
			#define FXAA_GREEN_AS_LUMA 1

			#define FX_VALUE_LDRSHIFT
			#include "UnityCG.cginc"
			#include "FX_Common.cginc"

#if FX_FXAA_QUALITY == 1
	#define FXAA_QUALITY__PRESET 12
	#define FXAA_QUALITY_SUBPIX 0.25
	#define FXAA_QUALITY_EDGE_THRESHOLD 0.25
	#define FXAA_QUALITY_EDGE_THRESHOLD_MIN 0.0833
#endif
#if FX_FXAA_QUALITY == 2
	#define FXAA_QUALITY__PRESET 12
	#define FXAA_QUALITY_SUBPIX 0.75
	#define FXAA_QUALITY_EDGE_THRESHOLD 0.166
	#define FXAA_QUALITY_EDGE_THRESHOLD_MIN 0.0833
#endif
#if FX_FXAA_QUALITY == 3
	#define FXAA_QUALITY__PRESET 28
	#define FXAA_QUALITY_SUBPIX 1
	#define FXAA_QUALITY_EDGE_THRESHOLD 0.063
	#define FXAA_QUALITY_EDGE_THRESHOLD_MIN 0.0312
#endif
			#include "FXAA3.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
			float4 _MainTex_ST;
			float _RenderViewportScaleFactor;
			float4 _UVTransform;
			half2 _Grain_Params1; // x: lum_contrib, y: intensity
			half4 _Grain_Params2; // x: xscale, h: yscale, z: xoffset, w: yoffset
			sampler2D _GrainTex;
			sampler2D _DitheringTex;
			float4 _DitheringCoords;

			struct AttributesDefault
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct VaryingsDefault
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSPR : TEXCOORD1; // Single Pass Stereo UVs
			};

			VaryingsDefault VertDefault(AttributesDefault v)
			{
				VaryingsDefault o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
				o.uvSPR = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy, _MainTex_ST);
				return o;
			}

			half AcesLuminance(half3 c)
			{
				return dot(c, half3(0.2126, 0.7152, 0.0722));
			}

			float3 UberSecondPass(half3 color, float2 uv)
			{
				// Grain
				{
					float3 grain = tex2D(_GrainTex, uv * _Grain_Params2.xy + _Grain_Params2.zw).rgb;

					// Noisiness response curve based on scene luminance
					float lum = 1.0 - sqrt(AcesLuminance(color));
					lum = lerp(1.0, lum, _Grain_Params1.x);

					color += color * grain * _Grain_Params1.y * lum;
				}

				// Blue noise dithering 
				{
					// Symmetric triangular distribution on [-1,1] with maximal density at 0
					float noise = tex2D(_DitheringTex, uv * _DitheringCoords.xy + _DitheringCoords.zw).a * 2.0 - 1.0;
					noise = sign(noise) * (1.0 - sqrt(1.0 - abs(noise))) / 255.0;

					color += noise;
				}

				return color;
			}

            fixed4 frag (VaryingsDefault i) : SV_Target
            {
				half4 color = 0.0;
				color = FxaaPixelShader(
					UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST),                 // pos
					0.0,                        // fxaaConsolePosPos (unused)
					_MainTex,                    // tex
					_MainTex,                    // fxaaConsole360TexExpBiasNegOne (unused)
					_MainTex,                    // fxaaConsole360TexExpBiasNegTwo (unused)
					_MainTex_TexelSize.xy,      // fxaaQualityRcpFrame
					0.0,                        // fxaaConsoleRcpFrameOpt (unused)
					0.0,                        // fxaaConsoleRcpFrameOpt2 (unused)
					0.0,                        // fxaaConsole360RcpFrameOpt2 (unused)
					FXAA_QUALITY_SUBPIX,
					FXAA_QUALITY_EDGE_THRESHOLD,
					FXAA_QUALITY_EDGE_THRESHOLD_MIN,
					0.0,                        // fxaaConsoleEdgeSharpness (unused)
					0.0,                        // fxaaConsoleEdgeThreshold (unused)
					0.0,                        // fxaaConsoleEdgeThresholdMin (unused)
					0.0                         // fxaaConsole360ConstDir (unused)
				);
				color.a = 1.0;
				return half4(color.rgb, 1.0);
            }
            ENDCG
        }
    }
}
