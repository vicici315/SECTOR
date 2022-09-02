Shader "FGame/Skybox/Cubemap" {
	Properties {
		_MainTex ("Cubemap(HDR)", Cube) = "grey" {}
	}

	SubShader {
		Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
		Cull Off ZWrite Off

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "FX_Common.cginc"

		float3 RotateAroundYInDegrees (float3 vertex, float degrees)
		{
			float alpha = degrees * UNITY_PI / 180.0;
			float sina, cosa;
			sincos(alpha, sina, cosa);
			float2x2 m = float2x2(cosa, -sina, sina, cosa);
			return float3(mul(m, vertex.xz), vertex.y).xzy;
		}

		struct appdata_t {
			float4 vertex : POSITION;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};
		struct v2f {
			float4 vertex : SV_POSITION;
			float3 texcoord : TEXCOORD0;
			UNITY_VERTEX_OUTPUT_STEREO
		};
		v2f vert (appdata_t v)
		{
			v2f o;
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			o.vertex = UnityObjectToClipPos( v.vertex );
			o.texcoord = v.vertex;
			return o;
		}
		half4 skybox_frag (v2f i, samplerCUBE smp)
		{
			return float4( g_OutputColor( g_TexCube_HDRColor(smp, i.texcoord) ), 1.0f );
		}
		ENDCG

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			samplerCUBE _MainTex;
			half4 frag (v2f i) : SV_Target { return skybox_frag(i,_MainTex ); }
			ENDCG
		}
	}
}
