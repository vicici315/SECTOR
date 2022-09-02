using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TextureTools
{
    static HashSet<TextureFormat> ms_setAlphaFormat;

    static public bool HasAlpha(Texture2D _texSrc)
    {
        if (ms_setAlphaFormat == null)
        {
            ms_setAlphaFormat = new HashSet<TextureFormat>();
            ms_setAlphaFormat.Add(TextureFormat.ARGB32);
            ms_setAlphaFormat.Add(TextureFormat.RGBA32);
            ms_setAlphaFormat.Add(TextureFormat.DXT5);
            ms_setAlphaFormat.Add(TextureFormat.DXT5Crunched);
            ms_setAlphaFormat.Add(TextureFormat.ARGB4444);
            ms_setAlphaFormat.Add(TextureFormat.RGBA4444);
            ms_setAlphaFormat.Add(TextureFormat.PVRTC_RGBA2);
            ms_setAlphaFormat.Add(TextureFormat.PVRTC_RGBA4);
            ms_setAlphaFormat.Add(TextureFormat.ETC2_RGBA1);
            ms_setAlphaFormat.Add(TextureFormat.ETC2_RGBA8);
            ms_setAlphaFormat.Add(TextureFormat.ASTC_RGBA_4x4);
            ms_setAlphaFormat.Add(TextureFormat.ASTC_RGBA_5x5);
            ms_setAlphaFormat.Add(TextureFormat.ASTC_RGBA_6x6);
            ms_setAlphaFormat.Add(TextureFormat.ASTC_RGBA_8x8);
            ms_setAlphaFormat.Add(TextureFormat.ASTC_RGBA_10x10);
            ms_setAlphaFormat.Add(TextureFormat.ASTC_RGBA_12x12);
        }

        return ms_setAlphaFormat.Contains(_texSrc.format);
    }
}

public class TextureProcessor : AssetPostprocessor
{
    static protected bool ms_bCloseProcessor = false;

    static public void Enable()
    {
        ms_bCloseProcessor = false;
    }

    static public void Disable()
    {
        ms_bCloseProcessor = true;
    }

    TextureImporterFormat _GetIOSTextureFormat(Texture2D texture, TextureImporter _aImporter)
    {
        if (assetPath.Contains("/LUT/") || assetPath.Contains("\\LUT\\"))
        {
            return TextureImporterFormat.RGB24;
        }

        if (TextureTools.HasAlpha(texture) && _aImporter.alphaSource != TextureImporterAlphaSource.None)
        {
            return TextureImporterFormat.ASTC_4x4;
        }

        if (assetPath.Contains("/UIResources/") || assetPath.Contains("\\UIResources\\"))
        {
            return TextureImporterFormat.ASTC_5x5;
        }

        return TextureImporterFormat.ASTC_6x6;
    }

    void OnPreprocessTexture()
    {
        if (ms_bCloseProcessor)
            return;

        if (assetPath.Contains("Packages/") || assetPath.Contains("Packages\\")
            || assetPath.Contains("/BuiltInPackages/") || assetPath.Contains("\\BuiltInPackages\\"))
            return;

        TextureImporter aImporter = assetImporter as TextureImporter;
        aImporter.npotScale = TextureImporterNPOTScale.ToSmaller;

        if (assetPath.Contains("/UIResources/") || assetPath.Contains("\\UIResources\\"))
        {
            aImporter.alphaSource = TextureImporterAlphaSource.None;
            aImporter.maxTextureSize = Mathf.Min(aImporter.maxTextureSize, 2048);
            aImporter.mipmapEnabled = false;

            //var aSetting = aImporter.GetPlatformTextureSettings("WebGL");
            //aSetting.maxTextureSize = Mathf.Min(aImporter.maxTextureSize, 1024);
            //aImporter.SetPlatformTextureSettings(aSetting);
        }
        else if (assetPath.Contains("/Scenes/") || assetPath.Contains("\\Scenes\\"))
        {
            aImporter.alphaSource = TextureImporterAlphaSource.None;
            aImporter.maxTextureSize = Mathf.Min(aImporter.maxTextureSize, 2048);
            aImporter.mipmapEnabled = false;

            //var aSetting = aImporter.GetPlatformTextureSettings("WebGL");
            //aSetting.maxTextureSize = Mathf.Min(aImporter.maxTextureSize, 1024);
            //aImporter.SetPlatformTextureSettings(aSetting);
        }
        else
        {
            aImporter.maxTextureSize = Mathf.Min(aImporter.maxTextureSize, 1024);
        }

        var aSetting = aImporter.GetPlatformTextureSettings("WebGL");
        if (aSetting.overridden)
        {
            aSetting.overridden = false;
            aImporter.SetPlatformTextureSettings(aSetting);
        }
    }

    void OnPostprocessTexture(Texture2D texture)
    {
        if (ms_bCloseProcessor)
            return;

        if (assetPath.Contains("Packages/") || assetPath.Contains("Packages\\")
            || assetPath.Contains("/BuiltInPackages/") || assetPath.Contains("\\BuiltInPackages\\")
            || assetPath.Contains("/Programmers/") || assetPath.Contains("\\Programmers\\")
            || assetPath.Contains("/ReflectionProbe") || assetPath.Contains("\\ReflectionProbe"))
        {
            return;
        }

        TextureImporter aImporter = assetImporter as TextureImporter;

        if (aImporter.textureType == TextureImporterType.Lightmap)
        {
            return;
        }

        var aSetting = aImporter.GetPlatformTextureSettings("iPhone");
        var aFormat = _GetIOSTextureFormat(texture, aImporter);
        if (!aSetting.overridden || aSetting.format != aFormat)
        {
            aSetting.overridden = true;
            aSetting.format = aFormat;
            aImporter.SetPlatformTextureSettings(aSetting);
            aImporter.SaveAndReimport();
        }
    }

    void OnPostprocessCubemap(Cubemap texture)
    {
        if (ms_bCloseProcessor)
            return;

        if (assetPath.Contains("/Programmers/") || assetPath.Contains("\\Programmers\\")
            || assetPath.Contains("/ReflectionProbe") || assetPath.Contains("\\ReflectionProbe"))
        {
            return;
        }

        TextureImporter aImporter = assetImporter as TextureImporter;

        if (aImporter.textureType == TextureImporterType.Lightmap)
        {
            return;
        }

        var aSetting = aImporter.GetPlatformTextureSettings("iPhone");
        if (!aSetting.overridden || aSetting.format != TextureImporterFormat.ASTC_5x5)
        {
            aSetting.overridden = true;
            aSetting.format = TextureImporterFormat.ASTC_5x5;
            aImporter.SetPlatformTextureSettings(aSetting);
            aImporter.SaveAndReimport();
        }
    }
}