Shader "FGame/Effect_AD"
{
	Properties{
	_MainTex( "Base (RGB) Trans (A)", 2D ) = "white" {}
	}

	SubShader
	{
		Tags { "Queue" = "Transparent+1"  "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "DisableBatching" = "True" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off ZTest Always
		ColorMask RGB


		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float4 scrPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;

			v2f vert( appdata_t v )
			{
				v2f o;
				o.vertex = UnityObjectToClipPos( v.vertex );
				o.texcoord = TRANSFORM_TEX( v.texcoord, _MainTex );
				o.scrPos = ComputeScreenPos( o.vertex );
				COMPUTE_EYEDEPTH( o.scrPos.z );
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				float Zbuffer = LinearEyeDepth( SAMPLE_DEPTH_TEXTURE_PROJ( _CameraDepthTexture, UNITY_PROJ_COORD( i.scrPos ) ) );
				fixed4 col = tex2D( _MainTex, i.texcoord );
				col.a *= saturate( ( Zbuffer - i.scrPos.z )  );
				return col;
			}
			ENDCG
		}
	}

}
