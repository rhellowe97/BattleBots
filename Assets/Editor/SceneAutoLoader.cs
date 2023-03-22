using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

[InitializeOnLoad]
public class SceneAutoLoader
{
    private const string MenuName = "Tools/Scene Auto Loader";
    private const string SettingName = "SceneAutoLoaderEnabled";

    public static bool IsEnabled
    {
        get { return EditorPrefs.GetBool( SettingName, true ); }
        set { EditorPrefs.SetBool( SettingName, value ); }
    }

    [MenuItem( MenuName )]
    private static void ToggleAction()
    {
        IsEnabled = !IsEnabled;

        SetStartScene();
    }

    [MenuItem( MenuName, true )]
    private static bool ToggleActionValidate()
    {
        Menu.SetChecked( MenuName, IsEnabled );
        return true;
    }

    static SceneAutoLoader()
    {
        SetStartScene();
    }

    static void SetStartScene()
    {
        var pathOfFirstScene = IsEnabled ? EditorBuildSettings.scenes[0].path : EditorSceneManager.GetActiveScene().path;
        var sceneAsset = AssetDatabase.LoadAssetAtPath<SceneAsset>( pathOfFirstScene );
        EditorSceneManager.playModeStartScene = sceneAsset;
        Debug.Log( pathOfFirstScene + " was set as default play mode scene" );
    }
}
