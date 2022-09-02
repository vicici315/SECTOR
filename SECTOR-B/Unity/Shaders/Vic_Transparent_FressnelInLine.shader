Shader "VIC/Transparent_FressnelInLine" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_FresnelS ("Fresnel Scale", Float) = 1
		_FresnelP ("Fresnel Pow", Float) = 2
		_FresnelOffset ("Fresnel Offset", Float) = 0.2
		_FresnelC ("Fresnel Color", Color) = (0,0,0,0)
		[Enum(Add,1, Normal,11)] _Blend ("Fresnel Blend Mode", int) = 11
	}
	SubShader {
		Tags { "Queue"="Transparent" }
		//混合模式为正常Normal
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100
		Pass {
			Cull Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			float _FresnelS;
			float _FresnelP;
			fixed4 _FresnelC;

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 worldPos : TEXCOORD1; //不能和上面的输入结构体里的uv使用同一个贮存
				float3 worldNormal : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v) {
				v2f o;
				//法线从物体到世界空间转换
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//顶点从模型空间到世界空间转换
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//获取世界空间中相机方向
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldViewDir = normalize(i.worldViewDir);
				fixed fresnel = (_FresnelS)*(pow(1-dot(worldViewDir, worldNormal), _FresnelP));
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		Pass {//描边Pass在最上层，因此后写
		Blend SrcAlpha [_Blend]
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			float _FresnelS;
			float _FresnelP;
			fixed4 _FresnelC;
			fixed _FresnelOffset;

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 worldPos : TEXCOORD1; //不能和上面的输入结构体里的uv使用同一个贮存
				float3 worldNormal : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
			};
			
			v2f vert (appdata v) {
				v2f o;
				//法线从物体到世界空间转换
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//顶点从模型空间到世界空间转换
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//获取世界空间中相机方向
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos+_FresnelOffset);
				//以均勻坐標將對象空間中的點轉換為相機的剪輯空間,等价于：mul(UNITY_MATRIX_MVP, float4(pos, 1.0))
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldViewDir = normalize(i.worldViewDir);
				fixed fresnel = (_FresnelS)*(pow(1-saturate(dot(worldViewDir, worldNormal)), _FresnelP));
				return _FresnelC*saturate(fresnel);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
