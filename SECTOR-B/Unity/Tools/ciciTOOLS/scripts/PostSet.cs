using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostSet : MonoBehaviour
{
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Color[] pixels = new Color[Screen.width*Screen.height];
        for(int x = 0; x < Screen.width; x++)
        {
            for (int y = 0; y < Screen.width; y++)
                pixels[x + y * Screen.height].r = 1.28f * 2.18f;
        }

        Graphics.Blit(source, destination);
    }
}
