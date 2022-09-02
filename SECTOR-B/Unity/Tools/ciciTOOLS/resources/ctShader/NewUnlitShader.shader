Shader "Vic/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal", 2D) = "white" {}
        _mro ("MRO", 2D) = "white" {}
        _Spe ("Specular Shininess", Range(0.01,200)) = 20
        _ShadowPow ("Shadow Pow", Range(-20,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite On
        pass {
            Name "ShadowCaster"
            Tags { "Queue"="Opaque" "LightMode"="ShadowCaster" }
            // ZWrite On
            //Cull Front
        }
        Pass
        {
            Cull back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
          #include "AutoLight.cginc"
        #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                // float3 worldPos : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldNormal : TEXCOORD4;
                float3 worldPos : TEXCOORD5;
                float3 worldTangent : TEXCOORD6;
	SHADOW_COORDS( 3 )
            };

            sampler2D _NormalMap;
            sampler2D _mro;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Spe;
            float _ShadowPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
       TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 packedNormal = tex2D(_NormalMap, i.uv);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                // tangentNormal.xy *= _NormalStr;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                half3 NoL = saturate(dot(normalize(cross(worldNormal,tangentNormal)) ,worldLight));
                // half3 NoL = saturate(cross(tangentNormal ,worldLight));
                //Shadow = pow(Shadow,_ShadowPow);
                UNITY_LIGHT_ATTENUATION( Shadow, i, i.worldPos );
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                fixed3 color = col.rgb*_LightColor0.rgb*(NoL*Shadow)+col.rgb*ambient*0.45;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
