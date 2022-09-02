Shader "Vic/NewCellShader"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _Tex ("Texture", 2D) = "white" {}
        _texNormal_S ("Normal", 2D) = "bump" {}
        _Spe ("Specular_Power", Range(0.01,200)) =4.2
        _MaskColor ("Mask Color", Color) = (1,1,1,0.5)
        _BackIntensity ("BackIntensity", Range(0.0, 1.0)) = 0.2
        _FrontIntensity ("FrontIntensity", Range(0.0, 1.0)) = 0.2
    }
    SubShader
    {
        // Project Shadow
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
 
            CGPROGRAM

            #pragma vertex vertShadow
            #pragma fragment fragShadow
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"
            
            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vertShadow(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 fragShadow(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }

            ENDCG
        }

        // Draw Back
        // Draw Front
        Pass
        {
            Name "DrawFront"
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha
            //ZWRITE Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile SHADOWS_SCREEN

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2f
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
                float4 uv : TEXCOORD3;
                float3 lightDir : TEXCOORD4;
                float3 viewDir : TEXCOORD5;
                //fixed3 diffuse : COLOR0;
                //fixed3 ambient : COLOR1;
            };

            fixed4 _TintColor;
            sampler2D _Tex;
            float4 _Tex_ST;
            sampler2D _texNormal_S;
            float4 _texNormal_S_ST;
            float _FrontIntensity;
			float _Spe;

            v2f vert(a2f v)
            {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _Tex);
				o.uv.zw = v.uv.xy * _texNormal_S_ST.xy + _texNormal_S_ST.zw;
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 normalDir = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                //o.diffuse = _LightColor0.rgb * ((dot(lightDir,normalDir) + 1) * 0.5);
                //o.ambient = UNITY_LIGHTMODEL_AMBIENT;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //fixed shadow = SHADOW_ATTENUATION(i);
				fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed4 packedNormal = tex2D(_texNormal_S, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //tangentNormal.xy *= _NormalStr;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed NoL = saturate(dot(tangentNormal,tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                //fixed3 spe = atten * pow(max(0, dot(tangentNormal, halfDir)), _Spe);
                fixed3 spe =  pow(saturate(dot(tangentNormal, halfDir)), _Spe);
                fixed3 albedo = tex2D(_Tex, i.uv.xy) * _TintColor.rgb;
                atten = max(0.4, atten);
                fixed3 diffuse = _LightColor0.rgb * ((saturate(dot(tangentLightDir,tangentNormal))+1)*0.5);
				diffuse = diffuse *albedo * (atten*NoL);
                return fixed4(diffuse * diffuse + spe, _TintColor.a);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}