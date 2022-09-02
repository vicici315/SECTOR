#ifndef DEBRION_FX_INCLUDED
#define DEBRION_FX_INCLUDED

//sampler2D_float _CameraDepthTexture;
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

inline fixed CalcSoftParticleFade(fixed4 projPos, fixed invFade) 
{
	fixed sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(projPos)));
	fixed partZ = projPos.z;
	return saturate(invFade * (sceneZ - partZ));
}

#endif
