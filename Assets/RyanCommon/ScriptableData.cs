using Sirenix.OdinInspector;
using UnityEngine;

#if UNITY_EDITOR
#endif

[HideMonoScript]
public abstract class ScriptableData : ScriptableObject, IDatabaseItem, ISerializationCallbackReceiver
{
    [BoxGroup( "Asset" )]
    [PropertyOrder( -2 )]
    [ReadOnly]
    [SerializeField]
    protected string guid;
    public string ID => guid;

    protected virtual void OnEnable()
    {

    }

    protected virtual void OnDisable()
    {

    }

    public virtual void OnAfterDeserialize()
    {

    }

    public virtual void OnBeforeSerialize()
    {

    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        if ( string.IsNullOrEmpty( guid ) )
            guid = System.Guid.NewGuid().ToString().Replace( "-", "" ).ToUpperInvariant();
    }
#endif
}

public abstract class ScriptableData<T> : ScriptableData
    where T : ScriptableData<T>
{
#if UNITY_EDITOR
    [BoxGroup( "Asset" )]
    [PropertyOrder( -1 )]
    [ShowInInspector]
    public T self { get { return (T)this; } }

    protected static bool CheckID( T self )
    {
        return !string.IsNullOrEmpty( self.ID );
    }
#endif
}
