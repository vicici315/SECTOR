//#define CHECK_MESH_TRIANGLES
//#define CHECK_TEX_RESOULITION
//#define SET_ANIMATOR_ABNAME
#define GENERATE_LOD_NODE
#define GENERATE_ROOT_NODE

using UnityEditor;
//using UnityEditor.Animations;
using UnityEngine;
//using System;
//using System.Collections.Generic;
//using System.IO;
//using UnityEditor.SceneManagement;
//using Object = UnityEngine.Object;

public class ActorAssetProcessor : AssetPostprocessor
{



    void OnPreprocessModel()
    {
        ModelImporter obj = assetImporter as ModelImporter;
        if (obj)
        {
            Object asset = AssetDatabase.LoadAssetAtPath(obj.assetPath, typeof(Mesh));
            if (!asset)
            {
                obj.importMaterials = false;
                obj.importAnimation = false;
                obj.importCameras = false;
                obj.importLights = false;
                obj.importVisibility = false;
                obj.generateSecondaryUV = false;
                obj.importNormals = ModelImporterNormals.Import;    //Normals
                obj.meshCompression = ModelImporterMeshCompression.Off; //Generate Lightmap UVs
                obj.isReadable = false;
                obj.normalCalculationMode = ModelImporterNormalCalculationMode.Unweighted_Legacy;   //Normals Mode
                obj.importTangents = ModelImporterTangents.CalculateMikk;   //Tangents
                obj.indexFormat = ModelImporterIndexFormat.UInt16;
                obj.importMaterials = false;
                obj.importBlendShapes = false;
                obj.normalSmoothingSource = ModelImporterNormalSmoothingSource.None;
            }
        }
    }
    void OnPreprocessTexture()
    {
        TextureImporter tex = assetImporter as TextureImporter;
        if (tex)
        {
            Object asset = AssetDatabase.LoadAssetAtPath(tex.assetPath, typeof(Texture2D));
            if (!asset)
            {
                tex.wrapMode = TextureWrapMode.Clamp;
                tex.textureCompression = TextureImporterCompression.Compressed;
                tex.filterMode = FilterMode.Trilinear;
                var settings = tex.GetPlatformTextureSettings("iOS");
                settings.overridden = false;
                tex.SetPlatformTextureSettings(settings);
            }
        }
    }


}

