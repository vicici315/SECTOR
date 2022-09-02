// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "effect/Standard_E_FadeOut" {
    Properties {
        _Diffuse ("Diffuse", 2D) = "white" {}
		_RotationAng("RotationAng", Float) = 0
		_DiffuseColor("Tint Color", Color) = (1,1,1,1)
		_Alpha("AlphaBlur(0-1)", Range(0,1)) = 0.5
		_Brightness("Brightness(0-10)", Range(0,10)) = 1
		[Enum(Additive,1,AlphaBlend,10)] _BlendMode("Blend Mode",Float) = 10
		[Enum(TwoSide,0,Off,2)] _TwoSide("2-Side",Float) = 2
		[HideInInspector]_cpfv("cpfv", Int) = 0
		_InvFade("Soft Particles Factor", Range(0.01,3.0)) = 3.0
		_ADDTIVE_COLOR_ON("Additive Color On", float) = 0
		[PreRendererData]_StartFade_Time("Start Fade Time", float) = 0
		[PreRendererData]_FadeOut_Time("Fade Out Time", float) = 0
	}
		SubShader{
			Tags {
				"IgnoreProjector" = "True"
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
			}
			Pass {
				Lighting Off
				Blend SrcAlpha[_BlendMode]
				Cull[_TwoSide]
				ZWrite Off
				Stencil {
					Ref 2
					Comp[_cpfv]
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
			//#pragma multi_compile _ _USEGRAY_ON
			//#pragma multi_compile _ _IGNOREUSEGRAY_ON
			//#pragma multi_compile _FOGMODE_ON _FOGMODE_OFF
			//#pragma multi_compile _LOCAL_SOFT_PARTICLE_ON _LOCAL_SOFT_PARTICLE_OFF

			//#if defined (_SOFT_PARTICLE_ON)
				#pragma multi_compile_particles
			//#endif

			//#if defined (_FOGMODE_ON)
				#pragma multi_compile_fog
			//#endif
			#include "UnityCG.cginc"
			#include "EffectCommon.cginc"

			float _StartFade_Time;
			float _FadeOut_Time;

			uniform float _ADDTIVE_COLOR_ON;
            uniform sampler2D _Diffuse; 
			uniform float4 _Diffuse_ST;
            uniform float _RotationAng;
			fixed4 _DiffuseColor;
			float _Alpha;
			float _Brightness;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
				//#if defined (_FOGMODE_ON)
					UNITY_FOG_COORDS(1)
				//#endif
				#if defined(SOFTPARTICLES_ON) //&& defined(_LOCAL_SOFT_PARTICLE_ON)
				fixed4 projPos : TEXCOORD2;
				#endif
				UNITY_VERTEX_OUTPUT_STEREO
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
				//#if defined (_FOGMODE_ON)
				UNITY_TRANSFER_FOG(o,o.pos);
				//#endif
				
				#if defined(SOFTPARTICLES_ON) //&& defined(_LOCAL_SOFT_PARTICLE_ON)
				o.projPos = ComputeScreenPos(o.pos);
				COMPUTE_EYEDEPTH(o.projPos.z);
				#endif

                return o;
            }

			float _InvFade;

            fixed4 frag(VertexOutput i) : COLOR {
                float i_cos = cos(_RotationAng*0.0174);
                float i_sin = sin(_RotationAng*0.0174);
                fixed4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX((mul(i.uv0-float2(0.5,0.5),float2x2( i_cos, -i_sin, i_sin, i_cos))+float2(0.5,0.5)), _Diffuse));
				
				_Diffuse_var.rgb = _Diffuse_var.rgb*_Brightness;
				_Diffuse_var.a = pow(_Diffuse_var.a, (0.4 + _Alpha));
				fixed4 col;
				if (_ADDTIVE_COLOR_ON > 0)
				{
					_Diffuse_var.rgb = Luminance(_Diffuse_var.rgb);
					_Diffuse_var = fixed4((_Diffuse_var.rgb + _DiffuseColor.rgb), (_Diffuse_var.a * _DiffuseColor.a));
					col = i.vertexColor.a *_Diffuse_var;
				}
				else
				{
					 col = i.vertexColor*_Diffuse_var*_DiffuseColor;
				}
				//#if defined (_FOGMODE_ON)
					UNITY_APPLY_FOG(i.fogCoord, col);
				//#endif

				#if defined(SOFTPARTICLES_ON) //&& defined(_LOCAL_SOFT_PARTICLE_ON)
				col.a *= CalcSoftParticleFade(i.projPos, _InvFade);
				#endif

				if (_FadeOut_Time > 0)
					col.a *= saturate((_FadeOut_Time - (_Time.y - _StartFade_Time)) / _FadeOut_Time);

                return col;
            }
            ENDCG
        }
    }
    FallBack "Legacy Shaders/Transparent/Diffuse"
}
