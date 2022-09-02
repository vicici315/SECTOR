Shader "Hidden/PP_Uber"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_CombinedLutTex("Texture", 2D) = "" {}
	}
		SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature FX_USE_LUT

			#include "UnityCG.cginc"
			#include "FX_Common.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			half3 ApplyLut2D(sampler2D tex, float3 uvw, float3 scaleOffset)
			{
				uvw.z *= scaleOffset.z;
				float shift = floor(uvw.z);
				uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
				uvw.x += shift * scaleOffset.y;
				//UE4和Unity中LUT图的g分量正好是相反的
				float3 col1 = tex2D(tex, float2(uvw.x , 1-uvw.y)).rgb;
				float3 col2 = tex2D(tex, float2(uvw.x + scaleOffset.y , 1- uvw.y)).rgb;
				uvw.xyz = lerp(
					col1.rgb,
					col2.rgb,
					uvw.z - shift
				);
				return uvw;
			}

			half3 LinearToSRGB(half3 c)
			{
				return sqrt(c);
			}

			half3 SRGBToLinear(half3 c)
			{
				return c * c;
			}

			sampler2D _MainTex;
			sampler2D _BloomTex;
			sampler2D _CombinedLutTex;
			static const float LUTSize = 32;

			float4 frag(v2f i) : SV_Target
			{
				float3 vSourceColor = g_DecodeColor( tex2D(_MainTex, i.uv) );

				#if FX_USE_FILETONEMAPPING
					#if !FX_USE_HDR
						vSourceColor = GammaToLinearSpace(vSourceColor);
					#endif
					FilmSlope = 0.88;
					FilmToe = 0.55;
					FilmShoulder = 0.26;
					FilmBlackClip = 0;
					FilmWhiteClip = 0.04;
					vSourceColor = FilmToneMap(vSourceColor);
					vSourceColor = LinearToGammaSpace(vSourceColor);
				#endif

				#if FX_USE_HDR && FX_USE_TONEMAPPING_ACES
					vSourceColor = g_ACESToneMapping( vSourceColor );
				#endif

				float3 vBloomColor = tex2D( _BloomTex, i.uv ).rgb;

				float3 vColor = vSourceColor + vBloomColor;

				#if FX_USE_HDR && FX_USE_GAMMATEXTURE
					vColor = pow( vColor, 1.0f / 2.2f );
				#endif

				#ifdef FX_USE_LUT
					vColor = saturate(vColor);
					const float3 _Lut2D_Params = float3(1.0f/ 256.0f , 1.0f / 16.0f, 16.0f - 1.0f);
					vColor.rgb = ApplyLut2D(_CombinedLutTex, vColor.rgb, _Lut2D_Params);
				#endif

				return float4( vColor, 1.0f );
			}
			ENDCG
		}
	}
}
