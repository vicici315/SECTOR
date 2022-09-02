Shader "Custom/GlitchTexture" {
	Properties {
		[HideInInspector]_Color ("TintColor", Color) = (1,1,1,1)
		[NoScaleOffset]_MainTex ("Texture", 2D) = "" {}
		[HideInInspector]_DispTex ("Disp (RGB)", 2D) = "" {}
		_ScreenGlitchTex ("Glitch Tex", 2D) = "" {}
		[HideInInspector]_Intensity ("Glitch Intensity", float) = 1
		//[HideInInspector]_Always ("Always Glitch", float) = 0
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" "IgnoreProjector"="True"}
		ZWrite Off
		Pass {
		Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uvB : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvB : TEXCOORD0;
			};
			
		uniform sampler2D _MainTex;
		uniform sampler2D _DispTex;
		sampler2D _ScreenGlitchTex;
		float4 _ScreenGlitchTex_ST;
		float _Intensity;
		float filterRadius;
		float displace;
		float scale;
		float DoGlitch;
		fixed4 _Color;
		//float _Always;
			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uvB = TRANSFORM_TEX(v.uvB, _ScreenGlitchTex);
				o.uv = v.uv;
				return o;
			}

			float4 frag (v2f i) : SV_Target
			{
i.uvB.xy += _Time * scale*2;
				fixed4 normal = tex2D (_DispTex, i.uvB * scale);
				fixed4 SG = tex2D (_ScreenGlitchTex, TRANSFORM_TEX(i.uvB, _ScreenGlitchTex));
				
				i.uv += normal * displace * _Intensity;
				fixed4 redcolor = tex2D(_MainTex,  i.uv.xy + 0.01);
				fixed4 greencolor = tex2D(_MainTex,  i.uv.xy + 0.01);
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 colN = tex2D(_MainTex, i.uv);
				if(filterRadius > 0){
					col.r = redcolor.r * 1.2;
					col.b = greencolor.b * 1.3;
				}else{
					col.g = redcolor.b * 1.3;
					col.r = greencolor.g * 1.3;
				}
				//float4 final =  lerp((lerp(colN*_Color, colorAdd, 0.5)), lerp(colN, col*_Color*(SG+0.4), 0.5), DoGlitch);
				float4 final = lerp(colN, col*(SG+0.4)*_Color,DoGlitch);
				return final;
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}
