Shader "FGame/UI/FullScreen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "False"
			"RenderType" = "Opaque"
		}

		Cull Off Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma target 2.0

			#define FX_PBR_USE_GLOBALBRIGHTNESS

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

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f aOutput;
                aOutput.vertex = float4( sign( v.vertex.xy ), 0.000001f, 1.0f );
                aOutput.uv = v.uv;
				aOutput.uv.y = 1.0f - aOutput.uv.y;
                return aOutput;
            }

            fixed4 frag (v2f aInput) : SV_Target
            {
                fixed4 vColor = g_Tex2D_Color(_MainTex, aInput.uv);
				return fixed4( g_OutputColor( vColor ), vColor.a );
            }
            ENDCG
        }
    }
}
