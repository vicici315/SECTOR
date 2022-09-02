Shader "FGame/UI/RecvShadow"
{
	Properties
	{
		_MainTex( "Texture", 2D ) = "white" {}
		_ShadowColor( "Shadow Color", Color ) = ( 0.5,0.5,0.5,1.0 )
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"IgnoreProjector" = "False"
			"RenderType" = "Opaque"
		}

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardFull" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#pragma skip_variants SPOT POINT LIGHTPROBE_SH FOG_EXP FOG_EXP2 FOG_LINEAR INSTANCING_ON

			#define FX_PBR_USE_GLOBALBRIGHTNESS

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "FX_Common.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos		: SV_POSITION;
				float3 m_vPosW	: TEXCOORD0;
				float4 uv		: TEXCOORD1;
				SHADOW_COORDS( 2 )
			};

			sampler2D _MainTex;
			float4 _ShadowColor;

			v2f vert( appdata v )
			{
				v2f aOutput;
				aOutput.pos = UnityObjectToClipPos( v.vertex );
				aOutput.m_vPosW = mul( unity_ObjectToWorld, v.vertex ).xyz;
				aOutput.uv = aOutput.pos;
				TRANSFER_SHADOW( aOutput );
				return aOutput;
			}

			fixed4 frag( v2f aInput ) : SV_Target
			{
				UNITY_LIGHT_ATTENUATION( Shadow, aInput, aInput.m_vPosW );

				float2 vTex = aInput.uv.xy / aInput.uv.w * 0.5f + 0.5f;
				vTex.y = 1.0f - vTex.y;
				fixed4 vBaseColor = g_Tex2D_Color( _MainTex, vTex );
				fixed4 vFullShadowColor = vBaseColor * _ShadowColor;

				fixed4 vColor = lerp( vFullShadowColor, vBaseColor, Shadow );
				return fixed4( g_OutputColor( vColor ), vBaseColor.a );
			}
			ENDCG
		}
	}
	
	Fallback "Legacy Shaders/VertexLit"
}
