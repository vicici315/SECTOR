// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "VIC/Vic_Transparent" {
    Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1)
      _MainTex ("Texture", 2D) = "white"{}
      _SpecularC ("Specular Material Color", Color) = (1,1,1,1)
      _Shininess ("Shininess", Range(2,600)) = 10
      _Cutoff ("Cut Off", Range(0,1)) = 0.5
   }
   SubShader {
        Tags{"Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent"}
        Pass {      
            Tags {"LightMode" = "ForwardBase" } // pass for 
            // 4 vertex lights, ambient light & first pixel light
            ZWrite On
            ZTest Less
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            // color of light source (from "Lighting.cginc")

            // User-specified properties
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _SpecularC;
            float _Shininess;
            float _Cutoff;

            struct vertexInput {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct vertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD3;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float3 vertexLighting : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            vertexOutput vert(vertexInput input)
            {
            vertexOutput o;
            o.uv = input.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject; 

            o.posWorld = mul(modelMatrix, input.vertex);
            o.normalDir = normalize(
                mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            o.pos = UnityObjectToClipPos(input.vertex);

            // Diffuse reflection by four "vertex lights"            
            o.vertexLighting = float3(0.0, 0.0, 0.0);
            #ifdef VERTEXLIGHT_ON
            for (int index = 0; index < 4; index++)
            {    
                float4 lightPosition = float4(unity_4LightPosX0[index], 
                    unity_4LightPosY0[index], 
                    unity_4LightPosZ0[index], 1.0);

                float3 vertexToLightSource = 
                    lightPosition.xyz - o.posWorld.xyz;        
                float3 lightDirection = normalize(vertexToLightSource);
                float squaredDistance = 
                    dot(vertexToLightSource, vertexToLightSource);
                float attenuation = 1.0 / (1.0 + 
                    unity_4LightAtten0[index] * squaredDistance);
                float3 diffuseReflection = attenuation 
                    * unity_LightColor[index].rgb * _Color.rgb 
                    * max(0.0, dot(o.normalDir, lightDirection));         

                o.vertexLighting = 
                    o.vertexLighting + diffuseReflection;
            }
            #endif
            TRANSFER_SHADOW(o);
            return o;
        }
 
        float4 frag(vertexOutput input) : SV_Target
        {
            fixed4 diff = tex2D(_MainTex, input.uv);
            float3 normalDirection = normalize(input.normalDir); 
            float3 viewDirection = normalize(
                _WorldSpaceCameraPos - input.posWorld.xyz);
            float3 lightDirection;
            float attenuation;

            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
                attenuation = 1.0; // no attenuation
                lightDirection = 
                    normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
                float3 vertexToLightSource = 
                    _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
                float distance = length(vertexToLightSource);
                attenuation = 1.0 / distance; // linear attenuation 
                lightDirection = normalize(vertexToLightSource);
            }

            float3 ambientLighting = 
                UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

            float3 diffuseReflection = 
                attenuation * _LightColor0.rgb * _Color.rgb 
                * max(0.0, dot(normalDirection, lightDirection));

            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
                // light source on the wrong side?
            {
                specularReflection = float3(0.0, 0.0, 0.0); 
                    // no specular reflection
            }
            else // light source on the right side
            {
                specularReflection = attenuation * _LightColor0.rgb 
                    * _SpecularC.rgb * pow(max(0.0, dot(
                    reflect(-lightDirection, normalDirection), 
                    viewDirection)), _Shininess);
            }
            fixed shadow = SHADOW_ATTENUATION(i);
            clip(diff.a - _Cutoff);
            return float4((input.vertexLighting + ambientLighting 
                + diffuseReflection + specularReflection)*diff.rgb*shadow, diff.a);
        }
        ENDCG
    }
    }
    FallBack "Diffuse"
 
}