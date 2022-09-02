Shader "FGame/PBR_Opacity"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_texNormal_S( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}
        [Header(Ramp Properties)]
        [NoScaleOffset]_RampTex ("Ramp Texture", 2D) = "white" {}
        [HDR]_RampColor ("Ramp Color(RGB)", Color) = (1, 1, 1, 1)
        _RampValueA ("Ramp Value X", Range(0.01, 0.999)) = 0.9
        _RampValueB ("Ramp Value Y", Range(0, 0.498)) = 0.49
        _RampOSx ("Ramp Offset X", Float) = 0
        _RampOSy ("Ramp Offset Y", Float) = 0
        _RampOSz ("Ramp Offset Z", Float) = 0
		_RampOpt ("Ramp Opacity", Range(0,1)) = 0.5
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		Pass
		{
			Name "FORWARD"
			Tags {"LightMode" = "ForwardBase"}
            // ZWrite on
			// Cull Back
Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex VS_Main
			#pragma fragment PS_Main
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase nolightmap
			#pragma multi_compile _ VERTEXLIGHT_ON

			#define FX_PBR_USE_POINTLIGHT
			#include "FX_PBRBase.cginc"

			ENDCG
		}
		Pass{
			Tags {"LightMode" = "ForwardBase"}
Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            // #include "AutoLight.cginc"
            // #pragma multi_compile_fwdbase

			sampler2D _texNormal_S;
            float4 _texNormal_S_ST;
			sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampTex;
			float4 _RampColor;
            float _RampValueA;
            float _RampValueB;
            float _RampOSx;
            float _RampOSy;
            float _RampOSz;
            float _RampOpt;

			struct appdata {
				float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
			};
			struct v2f {
				float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                half3 worldNormal : TEXCOORD3;
			};

			v2f vert (appdata v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _texNormal_S_ST.xy + _texNormal_S_ST.zw;
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}
			fixed4 frag (v2f i) : SV_Target {
				fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed4 packedNormal = tex2D(_texNormal_S, i.uv.xy);
                fixed col = tex2D(_MainTex, i.uv.zw).a;
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
            fixed NdotL = dot(tangentNormal, tangentLightDir);
            fixed diff = NdotL*_RampValueB+0.5;
            fixed3 OffsetViewDir = tangentViewDir;
            OffsetViewDir.x += _RampOSx;
            OffsetViewDir.y += _RampOSy;

            OffsetViewDir.z += _RampOSz;
            fixed NdotV = dot(tangentNormal, OffsetViewDir);
            float2 BRDuv = float2(NdotV * _RampValueA, diff);
            BRDuv.x = (BRDuv.x + BRDuv.y);
            BRDuv.y = (BRDuv.x + BRDuv.y);
            fixed3 BRDF = tex2D(_RampTex, BRDuv.xy + _RampOSz*0.4).rgb;
			return fixed4 (BRDF*_RampColor, _RampOpt*col);
			}
			ENDCG
		}
	}

	Fallback "Mobile/VertexLit"
}
