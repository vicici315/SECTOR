Shader "FGame/Particles/Falloff Alpha" {
Properties {
    _FresnelC ("Out Color", Color) = (0.5,0.5,1,0.5)
    _FresnelCB ("In Color", Color) = (1,0.5,0.5,0.5)
    _ColorSmoothA ("InOut Color Offset", Range(0.0,3.0)) = 1.0
    _FresnelS ("Scale", Range(0.01,3.0)) = 1.0
    _FresnelP ("Pow", Range(0.01,6.0)) = 1.0
}

// Category {

    SubShader {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" }
    Blend SrcAlpha One
    ZWrite On
    // ColorMask RGB
    // Cull Off Lighting Off ZWrite Off
        Pass{
//混合模式
// Blend SrcAlpha [_Blend]
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#include "UnityCG.cginc"
float _FresnelS;
float _FresnelP;
float4 _FresnelC;
float4 _FresnelCB;
float _ColorSmoothA;
// fixed _FresnelOffset_x;
// fixed _FresnelOffset_y;
// fixed _FresnelOffset_z;

struct appdata
{
float4 vertex : POSITION;
float3 normal : NORMAL;
};

struct v2f
{
float4 vertex : SV_POSITION;
float3 normal : NORMAL;
float3 worldPos : TEXCOORD1; //不能和上面的输入结构体里的uv使用同一个贮存
float3 worldNormal : TEXCOORD2;
float3 worldViewDir : TEXCOORD3;
};
v2f vert (appdata v)
{
v2f o;
//法线从物体到世界空间转换
o.worldNormal = UnityObjectToWorldNormal(v.normal);
//顶点从模型空间到世界空间转换
fixed3 OTW = mul(unity_ObjectToWorld, v.vertex);
// OTW.x += _FresnelOffset_x;
// OTW.y += _FresnelOffset_y;
// OTW.z += _FresnelOffset_z;
o.worldPos = OTW.xyz;
//获取世界空间中相机方向
o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

o.vertex = UnityObjectToClipPos(v.vertex);
return o;
}
fixed4 frag (v2f i) : SV_Target
{
fixed3 worldNormal = normalize(i.worldNormal);
fixed3 worldViewDir = normalize(i.worldViewDir);
fixed fresnel = _FresnelS*saturate(pow(1.0-saturate(dot(worldViewDir, worldNormal)), _FresnelP));
// return _FresnelC*smoothstep(0,1,fresnel);
fixed cf = smoothstep(0,_ColorSmoothA,fresnel);
// _FresnelC.a = fresnel;
float4 col = _FresnelC*cf + _FresnelCB*(1-cf);

col.a = saturate(fresnel);
return col*_FresnelS; 
}
ENDCG
}
    }
// }
}
