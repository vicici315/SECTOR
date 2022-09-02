using UnityEditor;

public class MyEditor : AssetPostprocessor
{
	public void OnPreprocessModel()
	{
		ModelImporter modelImporter = (ModelImporter) assetImporter;
		modelImporter.animationType = ModelImporterAnimationType.None;
	}
}