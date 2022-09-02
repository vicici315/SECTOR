// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "VIC/Vic_NextGenCharacter_v2"
{
    Properties
    {
        [Header(_1___________Diffuse_Control__________________________)]
        [HDR]_Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Diffuse Texture", 2D) = "white" {}
        [Header(_2___________Shadow_Control__________________________)]
        _ShadowPow ("Shadow Pow", Range(0.01,26)) = 2.2
        _ShadowSmoothPow ("Shadow Smooth", Range(0.01,1)) = 0.5
        [HDR]_Shadow ("Shadow Color(RGB) ShadowAlpha(A)", Color) = (.1, .1, .1, 0.5)
        [NoScaleOffset]_ShadowMaskTex ("Shadow Mask Texture", 2D) = "white" {}
        [NoScaleOffset]_AOTex ("Ambient Occlusion", 2D) = "white" {}
        [Header(_3___________Ramp_Control____________________________)]
        // [ToggleOff]_UseMainTex ("Ramp Use TextureColor", Float) = 0
        _RampPower("Ramp Power", Range(0.0, 12)) = 1
        _RampValueA ("Ramp Value X", Range(0.01, 0.998)) = 0.9
        _RampValueB ("Ramp Value Y", Range(0, 0.498)) = 0.49
        _RampColor ("Ramp Color(RGB)", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_RampTex ("Ramp Texture", 2D) = "white" {}
        [NoScaleOffset]_RampMaskTex ("Ramp Mask Texture", 2D) = "white" {}
        [Header(_4__________Specular_Control___________________________)]
        _SpecularPower ("Specular Shininess", Range(8,1200)) = 180
        _SpecularSmoothPow ("Specular Smooth", Range(0.01,1)) = 1
        // _Shininess("Shininess", Range(0.01, 1)) = 0.5
        [HDR]_SpecularColor ("SpecularColor(RGB)", Color) = (1, 1, 1, 1)
        _SpecularTex ("Mask(R) Shininess(G)", 2D) = "white" {}
        [Header(_5__________Reflection_Control__________________________)]
        _ReflectionPow ("Reflection Fresnel", Range(0.0, 6)) = 0
        _CubeScale ("Reflection Power", Range(0.0, 12)) = 1.0
        [NoScaleOffset]_CubeMap ("Cube Map", CUBE) = "cube" {}
        [NoScaleOffset]_ReflectMaskTex ("Reflection Mask Texture", 2D) = "white" {}
        [Header(_6__________Emission_Control___________________________)]
        _EmissionPow ("Emission Power", Float) = 0
        [NoScaleOffset]_EmissionTex ("Emission Texture", 2D) = "white" {}
        [Header(_7___________Bump_Control____________________________)]
        _BumpScale ("Bump Scale", Float) = 1
        _BumpTex ("Bump Texture", 2D) = "bump" {}
        [HideInInspector]_WhiteColor ("", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque"}
        CGPROGRAM
        #include "Lighting.cginc"
        #pragma surface surf Ramp exclude_path:deferred
        #pragma target 3.0
        sampler2D _MainTex;
        sampler2D _RampTex;
        sampler2D _RampMaskTex;
        sampler2D _BumpTex;
        sampler2D _SpecularTex;
        sampler2D _EmissionTex;
        sampler2D _ShadowMaskTex;
        sampler2D _ReflectMaskTex;
        sampler2D _AOTex;
        samplerCUBE _CubeMap;
        float _RampPower;
        float _ReflectionPow;
        fixed _EmissionPow;
        fixed4 _SpecularColor;
        fixed4 _RampColor;
        fixed4 _WhiteColor;
        float _SpecularPower;
        fixed4 _Color;
        float _CubeScale;
        float _RampValueA;
        float _RampValueB;
        float _UseMainTex;
        fixed4 _Shadow;
        float _BumpScale;
        float _ShadowPow;
        float _ShadowSmoothPow;
        float _SpecularSmoothPow;

        struct Input  
        {
            float2 uv_MainTex;
            float2 uv_BumpTex;
            float2 uv_SpecularTex;
            float3 worldRefl;
            INTERNAL_DATA
        };
        half halfDot(half3 A, half3 B){
            return dot(normalize(A),normalize(B)) * 0.5f + 0.5f;
        }
        struct CusSurfaceOutput{
            half3 Albedo;
            half3 Normal;
            half3 Emission;
            half3 SpecularColor;
            half Alpha;
            fixed Reflecttex;
            float3 WorldReflect;
            half2 uv_Main;
            float2 uv_SpecularTex;
        };
        fixed4 LightingRamp (CusSurfaceOutput s, fixed3 lightDir, fixed3 viewDir, half atten) {
            fixed4 diffuse = tex2D(_MainTex, s.uv_Main)*_LightColor0 * _Color;
            //Ramp
            fixed NdotL = dot(s.Normal, lightDir);
            fixed NdotV = dot(s.Normal, viewDir);
            fixed diff = NdotL*_RampValueB+0.5;
            fixed4 BRDFmask = tex2D(_RampMaskTex, s.uv_Main);
            float2 BRDuv = float2(NdotV * _RampValueA, diff);
            fixed3 BRDF = tex2D(_RampTex, BRDuv.xy).rgb *_RampPower;
            //Specular
            half4 specularTexture = tex2D(_SpecularTex, s.uv_SpecularTex);
            half specularVal = pow(halfDot(s.Normal, (lightDir + viewDir)), _SpecularPower*specularTexture.g);
            half3 specularLighting = smoothstep(0,_SpecularSmoothPow,specularVal) * _SpecularColor.rgb * specularTexture.r;
            half3 shadow = (smoothstep(0,_ShadowSmoothPow,(pow(diff,_ShadowPow)))+_Shadow.rgb) * tex2D(_ShadowMaskTex, s.uv_Main).r;
            //Shadow
            half3 BRDFcolor = lerp(_WhiteColor.rgb,(BRDF+_RampColor.rgb), BRDFmask.r);
            //pow次方计算控制 NdotV 基于视角方向的反射控制边沿反射范围，使边沿反射高于中间
            half3 reflect = (s.WorldReflect*smoothstep(0,0.5,pow(1-NdotV,_ReflectionPow))*tex2D(_ReflectMaskTex, s.uv_Main).r*_CubeScale*0.5+0.5);
            fixed4 c;
            c.rgb = (diffuse.rgb* reflect *UNITY_LIGHTMODEL_AMBIENT.xyz * BRDFcolor *clamp(shadow,_Shadow.a,1)*tex2D(_AOTex,s.uv_Main) + specularLighting);
            // c.rgb = (diffuse.rgb * (cc *0.5 + 0.5)) * ((BRDF+_RampColor.a)*_RampColor) * _LightColor0.rgb + specularLighting;
            c.a = diffuse.a;
            return c;
        }
        void surf (Input IN, inout CusSurfaceOutput s){
            //Normal
            fixed3 normalS = fixed3(_BumpScale,_BumpScale,1);
            fixed3 normalN = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex)).rgb;
            s.Normal =normalN * normalS;
            //Reflect
            fixed4 cubeColor = texCUBE(_CubeMap, WorldReflectionVector(IN, s.Normal));
            s.WorldReflect = cubeColor.rgb;
            //Emission
            s.Emission = tex2D(_EmissionTex, IN.uv_MainTex).rgb * _EmissionPow;
            //传递UV
            s.uv_Main = IN.uv_MainTex;
            s.uv_SpecularTex = IN.uv_SpecularTex;
        }
        ENDCG
    }
    FallBack "Specular"
}