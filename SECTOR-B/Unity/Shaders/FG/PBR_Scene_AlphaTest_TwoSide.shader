Shader "FGame/PBR_Scene_AlphaTest_TwoSide"
{
	Properties
	{
		_MainTex( "Base ( RGB )", 2D ) = "black" {}
		_MainTex_a( "Don't use!", 2D ) = "white" {}
		_texNormal_S( "RG:Normalmap B:SpecularLevel", 2D ) = "black" {}
		_texMRA( "R:Metallic G:Roughness B:AO", 2D ) = "black" {}
		_Cutoff( "Alpha cutoff", Range( 0,1 ) ) = 0.5
	}

	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"
			"IgnoreProjector" = "False"
			"RenderType" = "TransparentCutout"
		}

		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardFull" }

			Cull Off

			CGPROGRAM
			#pragma vertex VS_Main
			#pragma fragment PS_Main
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase noshadowmask nodynlightmap
			#pragma shader_feature VERTEXLIGHT_ON

			#define FX_PBR_USE_POINTLIGHT
			#define FX_PBR_USE_ALPHATEST
			#define FX_PBR_USE_TWOSIDE
			#include "FX_PBRBase.cginc"

			ENDCG
		}

		Pass
		{
			Name "Caster"
			Tags { "LightMode" = "ShadowCaster" }

			Cull Off

			CGPROGRAM

			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
			#include "UnityCG.cginc"
			#include "FX_Common.cginc"

			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2  uv : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _MainTex_ST;

			v2f vert( appdata_base v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.uv = TRANSFORM_TEX( v.texcoord, _MainTex );
				return o;
			}

			uniform sampler2D _MainTex;
			uniform fixed _Cutoff;

			float4 frag( v2f i ) : SV_Target
			{
				fixed4 texcol = g_Tex2D_ColorAlpha( _MainTex, i.uv );
				clip( texcol.a - _Cutoff );

				SHADOW_CASTER_FRAGMENT( i )
			}

			ENDCG
		}
	}

	Fallback "FGame/PBR_Scene_AlphaTest"
}
