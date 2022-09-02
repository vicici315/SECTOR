// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FGame/Cellv3_vic"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Base Map", 2D) = "white" {}
		[NoScaleOffset]_texNormal_S ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset]_texMRA ("MRA", 2D) = "white" {}
        [NoScaleOffset]_lighting ("Lighting Map", 2D) = "black" {}
        _lightingStr("Lighting Strength", Range(0,20))=1
        _NormalStr ("Normal_Strength", Range(0,3)) = 1
        [Header(Cartoon Properties)]
		// _texHair("Hair Tangent", 2D) = "black" {}
        _Spe ("Specular_Power", Range(0.01,170)) =4.2
        _SpeBrightness("Specular_Strength", Range(0,5)) = 0.5
        _Color("Color", Color) = (0,0,0,1)
        // _Detail("Toon_Level", Range(0,1))=0.35
        // _Strength("Toon_Strength", Range(0,2)) = 0.6
        // [Header(Fresnel Properties)]
        // _FresnelC("Fresnel_Light_Color", Color) = (0.5,0.2,0,1)
        // _FresnelBC("Fresnel_Shadow_Color", Color) = (0,0.1,0.5,1)
        // _FresnelL("Fresnel_Level", Range(0,1))=0.22
        // _Outline("Outline_Width", Range(0,0.1))=0.015
        // _OLStrength("Outline_Opacity", Range(0,1))=0
        _AOstr("AO Strength", Range(0.01,10))=0.5
        [Header(Ramp Properties)]
        [KeywordEnum(LightDirection, NormalDirection)] _FreDir ("Ramp Mode", Int) = 0
        [NoScaleOffset]_RampTex ("Ramp Texture", 2D) = "white" {}
        [HDR]_RampColor ("Ramp Color(RGB)", Color) = (1, 1, 1, 1)
        _RampValueA ("Ramp Value X", Range(0.01, 0.999)) = 0.9
        _RampValueB ("Ramp Value Y", Range(0, 0.498)) = 0.49
        _RampOSx ("Ramp Offset X", Float) = 0
        _RampOSy ("Ramp Offset Y", Float) = 0
        _RampOSz ("Ramp Offset Z", Float) = 0
        _Speed ("Scroll Speed", Float) = 0
         _FresnelP("Fresnel_Offset", Range(0.5,20))=4.4
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase
            // #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _texMRA;
            sampler2D _lighting;
            sampler2D _RampTex;
			sampler2D _texNormal_S;
// sampler2D _texHair;
            float4 _texNormal_S_ST;
            float4 _RampColor;
            float _RampValueA;
            float _RampValueB;
            float _RampOSx;
            float _RampOSy;
            float _RampOSz;
            float _Speed;
            float _SpeBrightness;
            float4 _Color;
            float _lightingStr;
            float _Spe;
            float _NormalStr;
            // float _Outline;
            // float _OLStrength;
            float _AOstr;
            float _FresnelP;
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
    // float2 m_vTex : TEXCOORD7;
	SHADOW_COORDS( 5 )
            };


            // float Toon(float3 normal,  float3 lightDir){
            //     float NdotL = max(0,dot(normalize(normal),normalize(lightDir)));
            //     return floor(NdotL / _Detail);
            // }

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
				fixed4 Lighting = tex2D(_lighting, i.uv);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
	float3 vViewDir = normalize( _WorldSpaceCameraPos.xyz - i.m_vPosW );
                tangentNormal.xy *= _NormalStr;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                fixed3 col = tex2D(_MainTex, i.uv).rgb;
                fixed3 ocol = col;
            //    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * col;
	            // UNITY_LIGHT_ATTENUATION( Shadow, i, i.m_vPosW );
                float Shadow = SHADOW_ATTENUATION(i);
                float fresnel = pow(1-saturate(dot(outlineViewDir,worldNormal)), _FresnelP);
                // float outline = max(_OLStrength,(floor(pow(dot(outlineViewDir,worldNormal),_Outline)/0.98)));
                //float fresnel = floor(saturate(pow(1-dot(lerp(tangentLightDir,tangentViewDir,_FreDir),tangentNormal),_FresnelP))/_FresnelL);
                // float fresnel = saturate(pow(1-dot(lerp(tangentLightDir,tangentViewDir,_FreDir),tangentNormal),_FresnelP));
// half3 NoL = saturate(dot(worldNormal ,tangentLightDir));
            fixed NdotL = dot(tangentNormal, tangentLightDir);
            fixed diff = NdotL*_RampValueB+0.5;
            fixed3 OffsetViewDir = lerp(tangentLightDir,tangentViewDir,_FreDir);
            OffsetViewDir.x += _RampOSx;
            OffsetViewDir.y += _RampOSy;

            OffsetViewDir.z += sin(_RampOSz * _Time*_Speed);
            fixed NdotV = dot(tangentNormal, OffsetViewDir);
            float2 BRDuv = float2(NdotV * _RampValueA, diff);
            BRDuv.x = sin(_Time*_Speed + (BRDuv.x + BRDuv.y));
            BRDuv.y = cos(_Time*_Speed + (BRDuv.x + BRDuv.y));
            fixed3 BRDF = tex2D(_RampTex, BRDuv.xy + _RampOSz*0.4).rgb;

                // fixed3 lightWithShadow = _LightColor0.rgb * floor(Shadow/_AOstr);
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
	// fixed3 hairTex = tex2D(_texHair, i.m_vTex).xyz;
	// fixed viewDot = saturate(dot(tangentNormal, vViewDir));
	// fixed sinV = pow(sin(viewDot * 3.141593), 2);
	// fixed powRoughness = pow(MRO.g, 4);
	// fixed pSinV = (powRoughness - 1) * sinV + 1.0;
	// fixed hairSpecular = powRoughness / (pSinV * pSinV);
	// float mask = step(0.01, dot(hairTex, 1));
                // fixed3 lightWithShadow =  _LightColor0.rgb * Shadow + ((1-Shadow)*col*0.5);
                fixed3 lightWithShadow =  _LightColor0.rgb * Shadow + ((1-Shadow)*col*0.5);
                fixed3 diffuse = lightWithShadow * col ;//* max(0, dot(tangentNormal, tangentLightDir));
                fixed3 spe = lightWithShadow * pow(max(0, dot(tangentNormal, halfDir)), _Spe);
                half3 BRDFcolor = lerp(half3(1,1,1),(BRDF+fresnel*1.2), MRO.a);
                //Light Position : _WorldSpaceLightPos0.xyz
                // col *= Toon(worldNormal, _WorldSpaceLightPos0.xyz)*diffuse*_Strength+floor(spe/_lightingStr)*_SpeBrightness+_Color;
                
                col = col*(diffuse+(spe*(1-MRO.g))*_SpeBrightness +_Color);
                // col = col*(diffuse*(1-MRO.g) +_Color);
                // col += (hairSpecular * _SpeBrightness * mask * 0.1);
				col *= pow(MRO.b,_AOstr);
                col = col + Lighting.rgb * _lightingStr;
                // return fixed4 ((col * (_FresnelBC*fresnel+(0.6*(1-Shadow)+Shadow)) + (ocol*_FresnelC*Shadow*fresnel))*outline, 1.0);
                return fixed4 (col*BRDFcolor*_RampColor, 1.0);
                //return fixed4 (col + floor(fresnel/_FresnelL), 1.0);
            }
            ENDCG
        }
    }
}

