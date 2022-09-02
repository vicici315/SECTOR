using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlitchTexture : MonoBehaviour {
    public Material material;
    public Texture2D displacementTex;
    public float intensity;
    public Color GlitchColor;
    [Range(0.0f,0.9f)] public float Frequency;
    [Range(0,1)] public float DoGlitch;
    //[Range(0,1)] public float DoGlitch2;
    float flicker, flickerTime = 0.2f;
	// Use this for initialization
	void Start () {
        
	}
    void GoGlicth()
    {
        //material.SetFloat("_Always", DoGlitch2);
        material.SetFloat("_Intensity", intensity);
        material.SetTexture("_DispTex", displacementTex);
        flicker += Time.deltaTime * intensity;

        if (flicker > flickerTime)
        {
            material.SetFloat("filterRadius", Random.Range(-3f, 3f) * intensity);
            flicker = 0;
            flickerTime = Random.value / 1.3f;
        }
        //if (GlitchOn > GlitchOnTime)
        //{
        //    if (Random.value < 0.4f * intensity)
        //        material.SetFloat("_GlitchON", 1);
        //    else
        //        material.SetFloat("_GlitchON", 0);
        //    GlitchOn = 0;
        //    GlitchOnTime = Random.value / 1f;
        //}
        if (Random.value < Frequency)
        {
            if (Random.value < 0.5f)
                material.SetFloat("displace", Random.value * intensity);
            else
                material.SetFloat("displace", -Random.value * intensity);
            material.SetFloat("scale", 1 - Random.value * intensity);
            material.SetColor("_Color", GlitchColor);
        }
        else
        {
            material.SetColor("_Color", Color.white);
            material.SetFloat("displace", 0);
        }
        material.SetFloat("DoGlitch", DoGlitch);
    }
	// Update is called once per frame
	void Update () {
        if (DoGlitch > 0)
            GoGlicth();
        else
            material.SetFloat("displace", 0);
	}
}
