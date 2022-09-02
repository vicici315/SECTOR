Shader "ZhuDaChang/lightChar" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		R ("R0", Range(0, 0.1)) = 0.018
		Power("Power", Range(0, 2)) = 1
	}
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200
		Alphatest Greater 0.2
		ZWrite on
		Blend SrcAlpha OneMinusSrcAlpha 
		ColorMask RGB
		Cull off
		Pass {
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float R;
			float Power;

 
			struct appdata {
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 color : COLOR;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
			};
			
			struct v2f {
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
				float4  worldPos : TEXCOORD1;
				float4  worldNormal : TEXCOORD2;
			};

			
			 float fresnel (float3 light, float3 normal, float R0)
             {
				 
                 float cosAngle = 1 - saturate(dot(light, normal));

                 float result = cosAngle * cosAngle;
                         result = result * result;
                         result = result * cosAngle;
                         result = saturate(result * (1 - saturate(R0)) + R0);

                         return result;
             }
 
			v2f vert (appdata v)
			{ 
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);

				o.worldPos = mul(_Object2World, v.vertex);
				o.worldNormal = mul(_Object2World, float4(v.normal.xyz, 0));
				return o;
			} 

 
			fixed4 frag (v2f i) : COLOR
			{
				float3 eyeVector = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 normalVector = normalize(i.worldNormal);
				
				float fresnelV = fresnel(eyeVector, normalVector, R);



				fixed4 texcol = tex2D(_MainTex, i.uv);


				return (pow(fresnelV,Power) * _Color + texcol);
				//return pow(texcol, fresnelV * 100) * texcol;

			}

			ENDCG
		}
	} 
}
