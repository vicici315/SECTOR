// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.36 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge

Shader "VIC/Effect Shader/Vic_KaTong" {
    Properties {
        _2 ("2", 2D) = "white" {}
        _3 ("3", 2D) = "white" {}
        _1color ("1color", Color) = (0.6029412,0.6549695,1,1)
        _2speed ("2 speed", Float ) = 1
        _1speed ("1 speed", Float ) = 1
        _length ("length", Range(0, 10)) = 0
        _blur ("blur", Range(1.5, 30)) = 2
        _frontblur ("front blur", Range(0, 50)) = 0
        _intensity ("intensity", Range(0, 50)) = 1
		[Toggle] _UseGray("Convert Input Texture to Grayscale", Float) = 0
		_GrayIntensity("Grayscale Intensity", Float) = 1
		_FresnelScale ("Mask Fresnel Scale", Range(0,1)) = 0.26
		_FresnelScaleP ("Mask Fresnel Pow", Range(0,3)) = 1.58
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Blend SrcAlpha One ZWrite Off Lighting Off 
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            // Blend One One
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _ _USEGRAY_O
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 3.0
			half _GrayIntensity;
            uniform float4 _TimeEditor;
            uniform sampler2D _2; uniform float4 _2_ST;
            uniform sampler2D _3; uniform float4 _3_ST;
            uniform float4 _1color;
            uniform float _2speed;
            uniform float _1speed;
            uniform float _length;
            uniform float _blur;
            uniform float _frontblur;
            uniform float _intensity;
            float _FresnelScale;
            float _FresnelScaleP;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
					float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
					float3 worldPos : TEXCOORD2;
					float3 worldViewDir : TEXCOORD3;
					float3 worldNormal : TEXCOORD4;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed fresnel = _FresnelScale + (1-_FresnelScale)*pow(dot(worldViewDir,worldNormal),_FresnelScaleP);
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_7613 = _Time + _TimeEditor;
                float2 node_6488 = ((float2(2,1)*i.uv0)+(node_7613.g*_2speed)*float2(0,0.1));
                float4 _2_var = tex2D(_2,TRANSFORM_TEX(node_6488, _2));
#if _USEGRAY_ON
				half l = Luminance(_2_var.rgb);
				_2_var.rgb = l * _GrayIntensity;
				_2_var = float4((_2_var.rgb + _1color.rgb), (_2_var.a * _1color.a));
#endif
                float4 node_1014 = _Time + _TimeEditor;
                float2 node_8500 = (i.uv0+(node_1014.g*_1speed)*float2(0,0.1));
                float4 _3_var = tex2D(_3,TRANSFORM_TEX(node_8500, _3));
#if _USEGRAY_ON
                float3 emissive = ((saturate((1.0 - (pow(i.uv0.g,15.0)*_frontblur)))*saturate(pow((saturate((pow(i.uv0.g,(1.0 - (_length+(-11.0))))*5.0))*((pow(i.uv0.g,50.0)*5.0)+((_2_var.r*_3_var.r)*_length))*_intensity),_blur))));
#else
                float3 emissive = ((saturate((1.0 - (pow(i.uv0.g,15.0)*_frontblur)))*saturate(pow((saturate((pow(i.uv0.g,(1.0 - (_length+(-11.0))))*5.0))*((pow(i.uv0.g,50.0)*5.0)+((_2_var.r*_3_var.r)*_length))*_intensity),_blur)))*_1color.rgb);
#endif
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor* smoothstep(0,1,fresnel),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            // Blend One One
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _ _USEGRAY_O
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 3.0
			half _GrayIntensity;
            uniform float4 _TimeEditor;
            uniform sampler2D _2; uniform float4 _2_ST;
            uniform sampler2D _3; uniform float4 _3_ST;
            uniform float4 _1color;
            uniform float _2speed;
            uniform float _1speed;
            uniform float _length;
            uniform float _blur;
            uniform float _frontblur;
            uniform float _intensity;
            float _FresnelScale;
            float _FresnelScaleP;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
					float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
					float3 worldPos : TEXCOORD2;
					float3 worldViewDir : TEXCOORD3;
					float3 worldNormal : TEXCOORD4;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(i.worldViewDir);
                fixed fresnel = _FresnelScale*pow(1-dot(worldViewDir,worldNormal),_FresnelScaleP);
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_7613 = _Time + _TimeEditor;
                float2 node_6488 = ((float2(2,1)*i.uv0)+(node_7613.g*_2speed)*float2(0,0.1));
                float4 _2_var = tex2D(_2,TRANSFORM_TEX(node_6488, _2));
#if _USEGRAY_ON
				half l = Luminance(_2_var.rgb);
				_2_var.rgb = l * _GrayIntensity;
				_2_var = float4((_2_var.rgb + _1color.rgb), (_2_var.a * _1color.a));
#endif
                float4 node_1014 = _Time + _TimeEditor;
                float2 node_8500 = (i.uv0+(node_1014.g*_1speed)*float2(0,0.1));
                float4 _3_var = tex2D(_3,TRANSFORM_TEX(node_8500, _3));
#if _USEGRAY_ON
                float3 emissive = ((saturate((1.0 - (pow(i.uv0.g,15.0)*_frontblur)))*saturate(pow((saturate((pow(i.uv0.g,(1.0 - (_length+(-11.0))))*5.0))*((pow(i.uv0.g,50.0)*5.0)+((_2_var.r*_3_var.r)*_length))*_intensity),_blur))));
#else
                float3 emissive = ((saturate((1.0 - (pow(i.uv0.g,15.0)*_frontblur)))*saturate(pow((saturate((pow(i.uv0.g,(1.0 - (_length+(-11.0))))*5.0))*((pow(i.uv0.g,50.0)*5.0)+((_2_var.r*_3_var.r)*_length))*_intensity),_blur)))*_1color.rgb);
#endif
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor* smoothstep(0,1,fresnel),1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
