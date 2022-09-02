Shader "Hidden/PP_AirDisturbance"
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			sampler2D _texAD;
			float _Weight;

            fixed4 frag (v2f i) : SV_Target
			{
				float3 vDisturbance = tex2D( _texAD, i.uv ).rgb;
				vDisturbance = normalize( vDisturbance * 2.0f - 1.0f );
				vDisturbance *= vDisturbance;		// reduce error of small number

				fixed4 vColor = tex2D( _MainTex, i.uv + vDisturbance.rg * _Weight );
                return vColor;
            }
            ENDCG
        }
    }
}
