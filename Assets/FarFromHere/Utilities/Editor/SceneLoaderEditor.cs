using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SceneLoader))]
public class SceneLoaderEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        SceneLoader sceneLoader = (SceneLoader)target;

        EditorGUILayout.Space();

        foreach (SceneLoader.SceneList sceneList in sceneLoader.sceneLists)
        {
            EditorGUILayout.LabelField(sceneList.listName, EditorStyles.boldLabel);

            foreach (UnityEngine.Object scene in sceneList.scenes)
            {
                EditorGUILayout.BeginHorizontal();

                EditorGUILayout.ObjectField(scene, typeof(UnityEngine.Object), false);
                if (GUILayout.Button("Load"))
                {
                    sceneLoader.LoadSceneEditor(scene);
                }
                if (GUILayout.Button("Unload"))
                {
                    sceneLoader.UnloadSceneEditor(scene);
                }

                EditorGUILayout.EndHorizontal();
            }

            if (GUILayout.Button($"Load All Scenes in {sceneList.listName}"))
            {
                sceneLoader.LoadAllScenesInList(sceneList.listName);
            }

            if (GUILayout.Button($"Remove All Scenes in {sceneList.listName}"))
            {
                sceneLoader.UnloadAllScenesInList(sceneList.listName);
            }
            EditorGUILayout.Space();
        }
        EditorGUILayout.Space();
    }
}
