// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FGame/Cell"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture Map", 2D) = "white" {}
		[NoScaleOffset]_Bump ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_MRO ("MRO", 2D) = "white" {}
        _NormalStr ("Normal_Strength", Range(0,3)) = 1
        [Header(Cartoon Properties)]
        _Spe ("Specular_Power", Range(0,100)) =2.5
        _Detail2("Specular_Level", Range(0,1))=0.5
        _Brightness("Specular_Strength", Range(0,3)) = 1
        _Color("Toon_Color", Color) = (0.1,0.1,0.1,1)
        _Detail("Toon_Level", Range(0,1))=0.2
        _Strength("Toon_Strength", Range(0,2)) = 1
        [Header(Fresnel Properties)]
        _FresnelC("Fresnel_Color", Color) = (0.81,0.81,1,1)
        _FresnelP("Fresnel_Power", Range(-20,20))=-5
        _FresnelL("Fresnel_Level", Range(0,1))=0.5
        _FresnelS("Fresnel_Strength", Range(0,2))=0.5
    }
    SubShader
    {

        pass {
            Name "ShadowCaster"
            Tags { "Queue"="Opaque" "LightMode"="ShadowCaster" }
            ZWrite On
            Cull Off
        }
        Pass {
            Tags { "LightMode"="ForwardBase" }
			Cull Back
       // Tags { "LightMode"="ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
//            #pragma target 2.0
//#pragma multi_compile_fwdbase
        //    #include "HLSLSupport.cginc"
//#include "UnityShaderVariables.cginc"
//#include "UnityShaderUtilities.cginc"
 //           #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MRO;
			sampler2D _Bump;
            float4 _Bump_ST;
            float _Brightness;
            float _Strength;
            float4 _Color;
            float _Detail;
            float _Detail2;
            float _Spe;
            float _NormalStr;
            float _FresnelP;
            float _FresnelS;
            float _FresnelL;
            float4 _FresnelC;
            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                half3 worldNormal : TEXCOORD3;
	float3 m_vPosW : TEXCOORD4;
	SHADOW_COORDS( 5 )
            };


            float Toon(float3 normal,  float3 lightDir){
                float NdotL = max(0,dot(normalize(normal),normalize(lightDir)));
                return floor(NdotL / _Detail);
            }

            v2f vert (appdata v)
            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
	float3 vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _Bump_ST.xy + _Bump_ST.zw;
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
	TRANSFER_SHADOW(o);
	o.m_vPosW = vPosW;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed4 packedNormal = tex2D(_Bump, i.uv.zw);
                fixed3 tangentNormal;
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _NormalStr;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                // sample the texture
                fixed3 col = tex2D(_MainTex, i.uv).rgb;
               // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * col;
	            UNITY_LIGHT_ATTENUATION( Shadow, i, i.m_vPosW );
                //float fresnel = Shadow * pow(1-dot(tangentViewDir,worldNormal), _FresnelP);
                float fresnel = Shadow*saturate(pow(1-dot(tangentLightDir,tangentNormal), _FresnelP));

                fixed3 lightWithShadow = _LightColor0.rgb * Shadow;
                fixed3 diffuse = lightWithShadow * col * max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 spe = lightWithShadow * pow(max(0, dot(tangentNormal, halfDir)), _Spe);
                spe *= 1-tex2D(_MRO, i.uv).g;
                col *= Toon(worldNormal, _WorldSpaceLightPos0.xyz)*diffuse*_Strength+floor(spe/_Detail2)*_Brightness+_Color;
				col *= tex2D(_MRO, i.uv).b;
                
                return fixed4 (col + _FresnelS*_FresnelC*floor(fresnel/_FresnelL), 1.0);
                //return fixed4 (col + floor(fresnel/_FresnelL), 1.0);
            }
            ENDCG
        }
		//*/
		///*
		//*/
    }
}
