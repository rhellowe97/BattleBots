using Sirenix.OdinInspector;
using UnityEngine;

public class Singleton<TSelf> : MonoBehaviour
    where TSelf : Singleton<TSelf>
{
    public static TSelf Instance;

    public static bool Exists => Instance != null;

    [BoxGroup( "Singleton" )]
    [SerializeField]
    protected bool isPersistent = false;

    protected virtual void Awake()
    {
        if ( Instance )
        {
            Destroy( gameObject );
            return;
        }

        Instance = (TSelf)this;

        if ( isPersistent )
        {
            transform.SetParent( null );

            DontDestroyOnLoad( gameObject );
        }
    }
}
