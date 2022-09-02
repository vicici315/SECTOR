Shader "Hidden/PP_Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

			v2f vert( appdata v )
			{
				v2f o;
				o.vertex = UnityObjectToClipPos( v.vertex );
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;

			float2 g_vTexelHalf;
			float2 g_vBloomArg;		// x: threshold  g:intensity

			inline float3 g_Filter( float3 _vColor, float _fThreshold )
			{
				float fLuminance = g_GetLuminance( _vColor );
				float fBloomLuminance = fLuminance - _fThreshold;
				float BloomAmount = saturate( fBloomLuminance * 0.5f );

                float3 vColor = BloomAmount * _vColor * g_vBloomArg.y;
                return vColor;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				float3 vColor = g_Filter( g_DecodeColor( tex2D( _MainTex, i.uv + float2( -g_vTexelHalf.x, -g_vTexelHalf.y ) ) ), g_vBloomArg.x );
				vColor += g_Filter( g_DecodeColor( tex2D( _MainTex, i.uv + float2(  g_vTexelHalf.x, -g_vTexelHalf.y ) ) ), g_vBloomArg.x );
				vColor += g_Filter( g_DecodeColor( tex2D( _MainTex, i.uv + float2( -g_vTexelHalf.x,  g_vTexelHalf.y ) ) ), g_vBloomArg.x );
				vColor += g_Filter( g_DecodeColor( tex2D( _MainTex, i.uv + float2(  g_vTexelHalf.x,  g_vTexelHalf.y ) ) ), g_vBloomArg.x );

				vColor *= 0.25f;
				return float4( vColor, 1.0f );
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "FX_Common.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float2 g_vTexel;

			v2f vert( appdata v )
			{
				v2f o;
				o.vertex = UnityObjectToClipPos( v.vertex );

				float Start = 2.0f / 9.0f;
				float Scale = 0.66f * 4.0f;

				float2 vOffset = Scale * g_vTexel;

				o.uv[0].xy = v.uv;
				o.uv[0].zw = v.uv + g_Circle( Start, 8.0f, 0.0f ) * vOffset;
				o.uv[1].xy = v.uv + g_Circle( Start, 8.0f, 1.0f ) * vOffset;
				o.uv[1].zw = v.uv + g_Circle( Start, 8.0f, 2.0f ) * vOffset;
				o.uv[2].xy = v.uv + g_Circle( Start, 8.0f, 3.0f ) * vOffset;
				o.uv[2].zw = v.uv + g_Circle( Start, 8.0f, 4.0f ) * vOffset;
				o.uv[3].xy = v.uv + g_Circle( Start, 8.0f, 5.0f ) * vOffset;
				o.uv[3].zw = v.uv + g_Circle( Start, 8.0f, 6.0f ) * vOffset;
				o.uv[4].xy = v.uv + g_Circle( Start, 8.0f, 7.0f ) * vOffset;
				o.uv[4].zw = float2( 0, 0 );
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag( v2f i ) : SV_Target
			{
				float3 vS0 = tex2D( _MainTex, i.uv[0].xy );
				float3 vS1 = tex2D( _MainTex, i.uv[0].zw );
				float3 vS2 = tex2D( _MainTex, i.uv[1].xy );
				float3 vS3 = tex2D( _MainTex, i.uv[1].zw );
				float3 vS4 = tex2D( _MainTex, i.uv[2].xy );
				float3 vS5 = tex2D( _MainTex, i.uv[2].zw );
				float3 vS6 = tex2D( _MainTex, i.uv[3].xy );
				float3 vS7 = tex2D( _MainTex, i.uv[3].zw );
				float3 vS8 = tex2D( _MainTex, i.uv[4].xy );

				float fW = 1.0f / 9.0f;

				float3 vColor =
					vS0 * fW +
					vS1 * fW +
					vS2 * fW +
					vS3 * fW +
					vS4 * fW +
					vS5 * fW +
					vS6 * fW +
					vS7 * fW +
					vS8 * fW;

				return float4( vColor, 1.0f );
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "FX_Common.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv[8] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float2 g_vTexel0;
			float2 g_vTexel1;

			v2f vert( appdata v )
			{
				v2f o;
				o.vertex = UnityObjectToClipPos( v.vertex );

				float Start = 2.0f / 7.0f;
				float Scale = 0.66f * 2.0f;

				float2 vOffset0 = Scale * g_vTexel0;
				o.uv[0].xy = v.uv + g_Circle( Start, 7.0f, 0.0f ) * vOffset0;
				o.uv[0].zw = v.uv + g_Circle( Start, 7.0f, 1.0f ) * vOffset0;
				o.uv[1].xy = v.uv + g_Circle( Start, 7.0f, 2.0f ) * vOffset0;
				o.uv[1].zw = v.uv + g_Circle( Start, 7.0f, 3.0f ) * vOffset0;
				o.uv[2].xy = v.uv + g_Circle( Start, 7.0f, 4.0f ) * vOffset0;
				o.uv[2].zw = v.uv + g_Circle( Start, 7.0f, 5.0f ) * vOffset0;
				o.uv[3].xy = v.uv + g_Circle( Start, 7.0f, 6.0f ) * vOffset0;
				o.uv[3].zw = v.uv;

				float2 vOffset1 = Scale * g_vTexel1;
				o.uv[4].xy = v.uv + g_Circle( Start, 7.0f, 0.0f ) * vOffset1;
				o.uv[4].zw = v.uv + g_Circle( Start, 7.0f, 1.0f ) * vOffset1;
				o.uv[5].xy = v.uv + g_Circle( Start, 7.0f, 2.0f ) * vOffset1;
				o.uv[5].zw = v.uv + g_Circle( Start, 7.0f, 3.0f ) * vOffset1;
				o.uv[6].xy = v.uv + g_Circle( Start, 7.0f, 4.0f ) * vOffset1;
				o.uv[6].zw = v.uv + g_Circle( Start, 7.0f, 5.0f ) * vOffset1;
				o.uv[7].xy = v.uv + g_Circle( Start, 7.0f, 6.0f ) * vOffset1;
				o.uv[7].zw = float2( 0, 0 );
				return o;
			}

			sampler2D _MainTex0;
			sampler2D _MainTex1;

			float3 _vTint0;
			float3 _vTint1;

			fixed4 frag( v2f i ) : SV_Target
			{
				float3 vA0 = tex2D( _MainTex0, i.uv[0].xy );
				float3 vA1 = tex2D( _MainTex0, i.uv[0].zw );
				float3 vA2 = tex2D( _MainTex0, i.uv[1].xy );
				float3 vA3 = tex2D( _MainTex0, i.uv[1].zw );
				float3 vA4 = tex2D( _MainTex0, i.uv[2].xy );
				float3 vA5 = tex2D( _MainTex0, i.uv[2].zw );
				float3 vA6 = tex2D( _MainTex0, i.uv[3].xy );
				float3 vA7 = tex2D( _MainTex0, i.uv[3].zw );

				float3 vB0 = tex2D( _MainTex1, i.uv[3].zw );
				float3 vB1 = tex2D( _MainTex1, i.uv[4].xy );
				float3 vB2 = tex2D( _MainTex1, i.uv[4].zw );
				float3 vB3 = tex2D( _MainTex1, i.uv[5].xy );
				float3 vB4 = tex2D( _MainTex1, i.uv[5].zw );
				float3 vB5 = tex2D( _MainTex1, i.uv[6].xy );
				float3 vB6 = tex2D( _MainTex1, i.uv[6].zw );
				float3 vB7 = tex2D( _MainTex1, i.uv[7].xy );

				float3 vWA = _vTint0 / 5.0f;
				float3 vWB = _vTint1;

				float3 vColor =
					vA0 * vWA +
					vA1 * vWA +
					vA2 * vWA +
					vA3 * vWA +
					vA4 * vWA +
					vA5 * vWA +
					vA6 * vWA +
					vA7 * vWA +
					vB0 * vWB +
					vB1 * vWB +
					vB2 * vWB +
					vB3 * vWB +
					vB4 * vWB +
					vB5 * vWB +
					vB6 * vWB +
					vB7 * vWB;

				return float4( vColor / 8.0f, 1.0f );
			}
			ENDCG
		}
    }
}
