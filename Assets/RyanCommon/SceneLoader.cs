using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoader : Singleton<SceneLoader>
{
    private const string loadingScreen = "LoadingScreen";

    public static bool IsLoading { get; private set; } = false;

    private string mainScene = "";

    public static void Activate( string newScene )
    {
        if ( !IsLoading )
        {
            Instance.StartCoroutine( Instance.SceneLoad( newScene ) );
        }
    }

    private IEnumerator SceneLoad( string newScene )
    {
        IsLoading = true;

        yield return SceneManager.LoadSceneAsync( loadingScreen, string.IsNullOrEmpty( mainScene ) ? LoadSceneMode.Single : LoadSceneMode.Additive );

        if ( !string.IsNullOrEmpty( mainScene ) )
        {
            yield return SceneManager.UnloadSceneAsync( mainScene );
        }

        mainScene = newScene;

        yield return SceneManager.LoadSceneAsync( newScene, LoadSceneMode.Additive );

        yield return SceneManager.UnloadSceneAsync( loadingScreen );

        IsLoading = false;
    }
}
