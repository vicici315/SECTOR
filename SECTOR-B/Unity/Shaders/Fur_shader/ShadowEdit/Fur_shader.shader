Shader "FGame/Fur_shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        _FurTex ("Fur Texture", 2D) = "white" {}
        _Specular ("Specular", Color) = (0, 0, 0, 1)
        _Shininess ("Shininess", Range(0.01, 256.0)) = 61

        [Header(Fur Properties)]
        _FurLength ("Fur Length", Range(0.01, 0.2)) = 0.08
        _FurDensity ("Fur Density", Range(0, 2)) = 0.35
        _FurThinness ("Fur Thinness", Range(0.01, 20)) = 5.5
        _FurShading ("Fur Shader", Range(0, 3)) = 0.28
        _LitFil ("Light Filter",Range(-1,1)) = 0.5
        _RimPower ("Light Filter Power", Range(0.01,20)) = 3.3

        _ForceGlobal ("Global Force", Vector) = (0,0,0,0)
        _ForceLocal ("Local Force", Vector) = (0,0,0,0)
		_UVoffset ("XY:UVÆ«ÒÆ", Vector) = (0.2, -0.3, 0, 0)

        [HideInInspector]Ls ("",Float) = 10

    }

    SubShader
    {
    	Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
        	Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert_surface
            #pragma fragment frag_surface
            #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase

            #define FUROFFSET 0.00
            #include "Fur_shader_cg.cginc"

            ENDCG
        }
        Pass
            {
            	Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 1
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
            Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 2
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
            Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 3
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
            Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 4
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
            Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 5
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
            Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 6
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
            Tags { "LightMode" = "ForwardBase" }
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 7
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00/Ls * 8
                #include "Fur_shader_cg.cginc"
                ENDCG
            }

            Pass
            {
                CGPROGRAM
                #pragma vertex vert_base
                #pragma fragment frag_base
                #pragma target 3.0
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase
                #define FUROFFSET 1.00
                #include "Fur_shader_cg.cginc"
                ENDCG
            }
    }
    FallBack "Diffuse"
}