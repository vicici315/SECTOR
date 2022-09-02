// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.36 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.36;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:0,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:2,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:7952,x:34908,y:32596,varname:node_7952,prsc:2|emission-7528-OUT;n:type:ShaderForge.SFN_Tex2d,id:2980,x:31062,y:32967,ptovrint:False,ptlb:2,ptin:_2,varname:_2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-6488-UVOUT;n:type:ShaderForge.SFN_Panner,id:6488,x:30741,y:32842,varname:node_6488,prsc:2,spu:0,spv:0.1|UVIN-195-OUT,DIST-7424-OUT;n:type:ShaderForge.SFN_Tex2d,id:2829,x:31083,y:33317,ptovrint:False,ptlb:3,ptin:_3,varname:_3,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-8500-UVOUT;n:type:ShaderForge.SFN_Panner,id:8500,x:30887,y:33337,varname:node_8500,prsc:2,spu:0,spv:0.1|UVIN-8018-UVOUT,DIST-3985-OUT;n:type:ShaderForge.SFN_Multiply,id:620,x:31282,y:33181,varname:node_620,prsc:2|A-2980-R,B-2829-R;n:type:ShaderForge.SFN_TexCoord,id:8018,x:29164,y:32488,varname:node_8018,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Multiply,id:9718,x:33598,y:32663,varname:node_9718,prsc:2|A-233-OUT,B-3523-OUT,C-1079-OUT;n:type:ShaderForge.SFN_Multiply,id:7528,x:34696,y:32691,varname:node_7528,prsc:2|A-6534-OUT,B-3882-RGB;n:type:ShaderForge.SFN_Color,id:3882,x:34444,y:32776,ptovrint:False,ptlb:1color,ptin:_1color,varname:_1color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6029412,c2:0.6549695,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:195,x:30579,y:32793,varname:node_195,prsc:2|A-2303-OUT,B-8018-UVOUT;n:type:ShaderForge.SFN_Vector2,id:2303,x:30333,y:32704,varname:node_2303,prsc:2,v1:2,v2:1;n:type:ShaderForge.SFN_Multiply,id:7424,x:30615,y:33063,varname:node_7424,prsc:2|A-7613-T,B-5085-OUT;n:type:ShaderForge.SFN_Time,id:7613,x:30286,y:33078,varname:node_7613,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:5085,x:30331,y:33258,ptovrint:False,ptlb:2 speed,ptin:_2speed,varname:_2speed,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:8040,x:30628,y:33637,ptovrint:False,ptlb:1 speed,ptin:_1speed,varname:_1speed,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:3985,x:30646,y:33463,varname:node_3985,prsc:2|A-1014-T,B-8040-OUT;n:type:ShaderForge.SFN_Time,id:1014,x:30350,y:33516,varname:node_1014,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6737,x:31693,y:32632,varname:node_6737,prsc:2|A-2960-OUT,B-363-OUT;n:type:ShaderForge.SFN_Power,id:6586,x:31810,y:32011,varname:node_6586,prsc:2|VAL-8018-V,EXP-8467-OUT;n:type:ShaderForge.SFN_Vector1,id:363,x:31471,y:32731,varname:node_363,prsc:2,v1:5;n:type:ShaderForge.SFN_Slider,id:8591,x:31429,y:32936,ptovrint:False,ptlb:length,ptin:_length,varname:_length,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Multiply,id:4462,x:31723,y:33333,varname:node_4462,prsc:2|A-620-OUT,B-8591-OUT;n:type:ShaderForge.SFN_Power,id:3428,x:33843,y:32689,varname:node_3428,prsc:2|VAL-9718-OUT,EXP-2358-OUT;n:type:ShaderForge.SFN_Vector1,id:8467,x:31509,y:32124,varname:node_8467,prsc:2,v1:15;n:type:ShaderForge.SFN_Add,id:3523,x:32019,y:33311,varname:node_3523,prsc:2|A-6737-OUT,B-4462-OUT;n:type:ShaderForge.SFN_Clamp01,id:1762,x:34139,y:32624,varname:node_1762,prsc:2|IN-3428-OUT;n:type:ShaderForge.SFN_Slider,id:2358,x:33477,y:32925,ptovrint:False,ptlb:blur,ptin:_blur,varname:_blur,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1.5,cur:2,max:30;n:type:ShaderForge.SFN_Multiply,id:2257,x:32787,y:32532,varname:node_2257,prsc:2|A-1494-OUT,B-6587-OUT;n:type:ShaderForge.SFN_Vector1,id:6587,x:32571,y:32599,varname:node_6587,prsc:2,v1:5;n:type:ShaderForge.SFN_Power,id:1494,x:32559,y:32479,varname:node_1494,prsc:2|VAL-8018-V,EXP-6490-OUT;n:type:ShaderForge.SFN_Clamp01,id:233,x:32999,y:32532,varname:node_233,prsc:2|IN-2257-OUT;n:type:ShaderForge.SFN_OneMinus,id:6490,x:32351,y:32579,varname:node_6490,prsc:2|IN-3909-OUT;n:type:ShaderForge.SFN_Add,id:3909,x:32186,y:32598,varname:node_3909,prsc:2|A-8591-OUT,B-6862-OUT;n:type:ShaderForge.SFN_Vector1,id:6862,x:32024,y:32741,varname:node_6862,prsc:2,v1:-11;n:type:ShaderForge.SFN_OneMinus,id:1752,x:32809,y:31960,varname:node_1752,prsc:2|IN-4901-OUT;n:type:ShaderForge.SFN_Multiply,id:4901,x:32424,y:32029,varname:node_4901,prsc:2|A-6586-OUT,B-7661-OUT;n:type:ShaderForge.SFN_Slider,id:7661,x:32035,y:32107,ptovrint:False,ptlb:front blur,ptin:_frontblur,varname:_frontblur,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:50;n:type:ShaderForge.SFN_Clamp01,id:6107,x:33029,y:31977,varname:node_6107,prsc:2|IN-1752-OUT;n:type:ShaderForge.SFN_Multiply,id:6534,x:34347,y:32543,varname:node_6534,prsc:2|A-6107-OUT,B-1762-OUT;n:type:ShaderForge.SFN_Slider,id:1079,x:33180,y:32781,ptovrint:False,ptlb:intensity,ptin:_intensity,varname:_intensity,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:50;n:type:ShaderForge.SFN_Power,id:2960,x:31283,y:32663,varname:node_2960,prsc:2|VAL-8018-V,EXP-3170-OUT;n:type:ShaderForge.SFN_Vector1,id:3170,x:31038,y:32792,varname:node_3170,prsc:2,v1:50;proporder:2980-2829-3882-5085-8040-8591-2358-7661-1079;pass:END;sub:END;*/

Shader "effect/KaTong" {
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
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
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
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
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
                fixed4 finalRGBA = fixed4(finalColor,1);
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
