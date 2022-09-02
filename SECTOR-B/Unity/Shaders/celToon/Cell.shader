// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FGame/Test/Cell"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Base Map", 2D) = "white" {}
		[NoScaleOffset]_texNormal_S ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_texMRA ("MRA", 2D) = "white" {}
        _NormalStr ("Normal_Strength", Range(0,3)) = 1
        [Header(Cartoon Properties)]
        [Toggle(UNITY_UI_ALPHACLIP)]  _UseToonSpe ("Use Cell Specular", int) = 0
        _Spe ("Specular_Power", Range(0,100)) =4.2
        _Detail2("Specular_Level", Range(0,1))=0.3
        _Brightness("Specular_Strength", Range(0,3)) = 0.5
        _Color("Toon_Color", Color) = (0,0,0,1)
        _Detail("Toon_Level", Range(0,1))=0.35
        _Strength("Toon_Strength", Range(0,2)) = 0.6
        [Header(Fresnel Properties)]
        [KeywordEnum(Light, Normal)] _FreDir ("Fresnel_Mode", Int) = 0
        _FresnelC("Fresnel_Light_Color", Color) = (0.5,0.2,0,1)
        _FresnelBC("Fresnel_Shadow_Color", Color) = (0,0.1,0.5,1)
        _FresnelP("Fresnel_Offset", Range(-20,20))=4.4
        _FresnelL("Fresnel_Level", Range(0,1))=0.22
        _Outline("Outline_Width", Range(0,0.1))=0.015
        _OLStrength("Outline_Opacity", Range(0,1))=0
        [HideInInspector]_Test("Shadow_Level", Range(0,1))=0.5
    //    [Toggle(UNITY_UI_ALPHACLIP)] _FreToonA("Fresnel_ToonActive", Int) = 1
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
            sampler2D _texMRA;
			sampler2D _texNormal_S;
            float4 _texNormal_S_ST;
            float _Brightness;
            float _Strength;
            float4 _Color;
            float _Detail;
            float _Detail2;
            float _Spe;
            float _NormalStr;
            float _FresnelP;
            float _Outline;
            float _FresnelL;
            float4 _FresnelC;
            float4 _FresnelBC;
            float _OLStrength;
            float _Test;
            int _UseToonSpe;
            //int _FreToonA;
            int _FreDir;
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
                float3 outlineViewDir : TEXCOORD6;
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
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _texNormal_S_ST.xy + _texNormal_S_ST.zw;
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
	float3 vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				o.outlineViewDir = UnityWorldSpaceViewDir(vPosW);
	TRANSFER_SHADOW(o);
	o.m_vPosW = vPosW;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 outlineViewDir = normalize(i.outlineViewDir);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed4 packedNormal = tex2D(_texNormal_S, i.uv.zw);
				fixed4 MRO = tex2D(_texMRA, i.uv);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _NormalStr;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                // sample the texture
                fixed3 col = tex2D(_MainTex, i.uv).rgb;
                fixed3 ocol = col;
               // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * col;
	            UNITY_LIGHT_ATTENUATION( Shadow, i, i.m_vPosW );
                //float fresnel = Shadow * pow(1-dot(tangentViewDir,worldNormal), _FresnelP);
                float outline = max(_OLStrength,(floor(pow(dot(outlineViewDir,worldNormal),_Outline)/0.98)));
                //float fresnel = floor(saturate(pow(1-dot(lerp(tangentLightDir,tangentViewDir,_FreDir),tangentNormal),_FresnelP))/_FresnelL);
                float fresnel = floor(saturate(pow(1-dot(lerp(tangentLightDir,tangentViewDir,_FreDir),tangentNormal),_FresnelP))/_FresnelL);

                // fixed3 lightWithShadow = _LightColor0.rgb * floor(Shadow/_Test);
                fixed3 lightWithShadow = _LightColor0.rgb * Shadow;
                fixed3 diffuse = lightWithShadow * col ;//* max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 spe = lightWithShadow * pow(max(0, dot(tangentNormal, halfDir)), _Spe);
                spe *= 1-MRO.g;
                //Light Position : _WorldSpaceLightPos0.xyz
                if (_UseToonSpe == 1) spe = floor(spe/_Detail2);
                col *= Toon(worldNormal, _WorldSpaceLightPos0.xyz)*diffuse*_Strength+spe*_Brightness+_Color;
				col *= MRO.b;
                
                return fixed4 ((col * (_FresnelBC*fresnel+(0.6*(1-Shadow)+Shadow)) + (ocol*_FresnelC*Shadow*fresnel))*outline, 1.0);
                //return fixed4 (col + floor(fresnel/_FresnelL), 1.0);
            }
            ENDCG
        }
    }
}

