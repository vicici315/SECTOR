

Shader "ZhuDaChang/Vertex Colored" {
Properties {
	_MainTex ("Texture", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range (0,1)) = 0.5
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off
	Lighting Off
		
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	SubShader {
		Pass {
			AlphaTest Greater [_Cutoff]
			SetTexture [_MainTex] {
				combine texture * primary
			}
		}
	}
}
}
