Shader "Vic/FastOutline"
{
	Properties
	{
		_OutlineColor("Outline Color", Color) = (0,1,0,1)
		_Outline("Outline width", Range(0.002, 0.3)) = 0.01		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry-1"}
		LOD 100

		Pass
		{
			ZTest On
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			uniform fixed _Outline;
			uniform fixed4 _OutlineColor;

			v2f vert (appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				float4 pos = UnityObjectToClipPos(v.vertex);
				
				float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				float2 offset = TransformViewToProjection(norm.xy);
				#ifdef UNITY_Z_0_FAR_FROM_CLIPSPACE //to handle recent standard asset package on older version of unity (before 5.5)
					pos.xy += offset * UNITY_Z_0_FAR_FROM_CLIPSPACE(pos.z) * _Outline;
				#else
					pos.xy += offset * pos.z * _Outline;
				#endif

				o.vertex = pos;
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 col = _OutlineColor;				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
