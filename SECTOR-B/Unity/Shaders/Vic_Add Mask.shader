// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "VIC/Effect Shader/AdditiveMask_SoftBoundary" 
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		[Enum(Add,1, Normal,11)] _Blend ("Blend Mode", int) = 1
		_MainTex ("Texture", 2D) = "white" {}
		_Uflow("U Flow (UV1)", Float) = 0
		_Vflow("V Flow (UV2)", Float) = 0
		_Mask ("Mask ( R )", 2D) = "white" {}
		[KeywordEnum(UV1, UV2)] _UV ("MaskUV ID", Int) = 0
		_FresnelScale ("Mask Fresnel Scale", Range(0,1)) = 0.26
		_FresnelScaleP ("Mask Fresnel Pow", Range(0,3)) = 1.58
		[HideInInspector]_Center ("Center",Vector) = (0,0,0,1)
		[HideInInspector]_Scale ("Scale",Vector) = (1,1,1,1)
		[HideInInspector]_Normal ("Normal",Vector) = (0,0,1,0)
	}

	Category 
	{
		Tags { "Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent" }
		// Blend SrcAlpha One
		Blend SrcAlpha [_Blend]
		Lighting Off ZWrite Off Fog { Color (0,0,0,0) }

		SubShader 
		{
		// /*
			Pass {
				Cull Back
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile SCALE_OFF SCALE_ON
				#pragma multi_compile MIRROR_OFF MIRROR_ON
				#pragma multi_compile MESH BILLBOARD
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _Mask;
				fixed4 _TintColor;
				float _FresnelScale;
				float _FresnelScaleP;
				float _Uflow;
				float _Vflow;
				int _UV;

				struct appdata_t 
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
				};

				struct v2f 
				{
					float3 normal : NORMAL;
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					float3 worldViewDir : TEXCOORD3;
					float3 worldNormal : TEXCOORD4;
				};
			
				float4 _MainTex_ST;
				float4 _Mask_ST;

				float4 _Center;
				float4 _Scale;
				float4 _Normal;

				uniform float4x4 _Camera2World;

				v2f vert (appdata_t v)
				{
					v2f o;
					#if SCALE_ON
					float4 worldpos;
					#if BILLBOARD
					worldpos = mul(_Camera2World,v.vertex);
					#else //BILLBOARD
					worldpos = mul(unity_ObjectToWorld,v.vertex);		
					#endif //BILLBOARD
					#if MIRROR_ON
					float3 srcDir = _Center.xyz - worldpos.xyz;
					float3 refDir = reflect(srcDir,_Normal.xyz);
					refDir.y = -srcDir.y;
					worldpos.xyz = refDir *_Scale.xyz + _Center.xyz;
					#else //MIRROR_ON 
					worldpos.xyz = (worldpos.xyz-_Center.xyz)*_Scale.xyz + _Center.xyz;
					#endif //MIRROR_ON 
					o.vertex = mul(UNITY_MATRIX_VP, worldpos);
					#else //SCALE_ON
					o.vertex = UnityObjectToClipPos(v.vertex);
					#endif //SCALE_ON

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.texcoord1 = TRANSFORM_TEX(v.texcoord1,_Mask);
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
                	fixed3 worldNormal = normalize(i.worldNormal);
					// i.normal = UnityObjectToWorldNormal(i.normal);
                	fixed3 worldViewDir = normalize(i.worldViewDir);
					fixed fresnel = _FresnelScale + (1-_FresnelScale)*pow(dot(worldViewDir,worldNormal),_FresnelScaleP);
					i.texcoord.x += _Time.y*_Uflow;
					i.texcoord.y += _Time.y*_Vflow;
				    fixed4 c = tex2D(_MainTex, i.texcoord);
					c.a *= tex2D(_Mask, lerp(i.texcoord,i.texcoord1, _UV)).r;
					return 2.0f * i.color * _TintColor * c * smoothstep(0,1,fresnel);
				}
				ENDCG
			}
			// */

			Pass {
				Cull Front
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile SCALE_OFF SCALE_ON
				#pragma multi_compile MIRROR_OFF MIRROR_ON
				#pragma multi_compile MESH BILLBOARD
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _Mask;
				fixed4 _TintColor;
				float _FresnelScale;
				float _FresnelScaleP;
				float _Uflow;
				float _Vflow;
				int _UV;

				struct appdata_t 
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
				};

				struct v2f 
				{
					float3 normal : NORMAL;
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
					float3 worldViewDir : TEXCOORD3;
					float3 worldNormal : TEXCOORD4;
				};
			
				float4 _MainTex_ST;
				float4 _Mask_ST;

				float4 _Center;
				float4 _Scale;
				float4 _Normal;

				uniform float4x4 _Camera2World;

				v2f vert (appdata_t v)
				{
					v2f o;
					#if SCALE_ON
					float4 worldpos;
					#if BILLBOARD
					worldpos = mul(_Camera2World,v.vertex);
					#else //BILLBOARD
					worldpos = mul(unity_ObjectToWorld,v.vertex);		
					#endif //BILLBOARD
					#if MIRROR_ON
					float3 srcDir = _Center.xyz - worldpos.xyz;
					float3 refDir = reflect(srcDir,_Normal.xyz);
					refDir.y = -srcDir.y;
					worldpos.xyz = refDir *_Scale.xyz + _Center.xyz;
					#else //MIRROR_ON 
					worldpos.xyz = (worldpos.xyz-_Center.xyz)*_Scale.xyz + _Center.xyz;
					#endif //MIRROR_ON 
					o.vertex = mul(UNITY_MATRIX_VP, worldpos);
					#else //SCALE_ON
					o.vertex = UnityObjectToClipPos(v.vertex);
					#endif //SCALE_ON

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.texcoord1 = TRANSFORM_TEX(v.texcoord1,_Mask);
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
                	fixed3 worldNormal = normalize(i.worldNormal);
					// i.normal = UnityObjectToWorldNormal(i.normal);
                	fixed3 worldViewDir = normalize(i.worldViewDir);
					fixed fresnel = (_FresnelScale)*pow(1-dot(worldViewDir,worldNormal),_FresnelScaleP);
					i.texcoord.x += _Time.y*_Uflow;
					i.texcoord.y += _Time.y*_Vflow;
				    fixed4 c = tex2D(_MainTex, i.texcoord);
					c.a *= tex2D(_Mask, lerp(i.texcoord,i.texcoord1, _UV)).r;
					return 2.0f * i.color * _TintColor * c * smoothstep(0,1,fresnel);
				}
				ENDCG
			}
		}

	}
	FallBack "Transparent/Diffuse"
}
