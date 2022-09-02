//#define CHECK_MESH_TRIANGLES
//#define CHECK_TEX_RESOULITION
//#define SET_ANIMATOR_ABNAME
#define GENERATE_LOD_NODE
#define GENERATE_ROOT_NODE

using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor.SceneManagement;
using Object = UnityEngine.Object;

public class ActorAssetProcessor : AssetPostprocessor
{


    void OnPostprocessModel(GameObject model)
    {
        //string assetPath = assetImporter.assetPath.Replace("\\", "/");
        //string dir = assetPath.Substring(0, assetPath.LastIndexOf("/"));
        //DirectoryInfo di = new DirectoryInfo(dir);

        //// 导入的是ActorGPUSkinning目录下的Animation，则自动创建clipMap
        //if ((assetPath.Contains("ActorGPUSkinning/Humanoid/NPC") || assetPath.Contains("ActorGPUSkinning/Generic/NPC"))
        //    && di.Name == "Animation" &&
        //    (di.Parent.Parent.Name == "NPC" || di.Parent.Parent.Name == "Monster" || di.Parent.Parent.Name == "Boss"))
        //{
        //    _CreateAnimClipMap(dir);
        //}
        // model.importMaterials = false;
    }

    void OnPreprocessModel()
    {
        ModelImporter obj = assetImporter as ModelImporter;
        if (obj)
        {
            // obj.importMaterials = false;
            obj.importAnimation = false;
            obj.importCameras = false;
            obj.importLights = false;
            obj.importVisibility = false;
            obj.generateSecondaryUV = false;
            obj.importNormals = ModelImporterNormals.Import;    //Normals
            obj.meshCompression = ModelImporterMeshCompression.Off; //Generate Lightmap UVs
            obj.isReadable = true;
            obj.normalCalculationMode = ModelImporterNormalCalculationMode.Unweighted_Legacy;   //Normals Mode
            obj.importTangents = ModelImporterTangents.CalculateMikk;   //Tangents
            obj.indexFormat = ModelImporterIndexFormat.UInt16;
        }
    }
    void OnPreprocessTexture()
    {
        TextureImporter tex = assetImporter as TextureImporter;
        if (tex)
        {
            tex.wrapMode = TextureWrapMode.Clamp;
            tex.filterMode = FilterMode.Trilinear;
        }
    }

}
