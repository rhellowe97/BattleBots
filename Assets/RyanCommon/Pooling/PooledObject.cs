using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PooledObject : MonoBehaviour
{
    [BoxGroup( "Pooling" )]
    [SerializeField] private bool persist = false;
    public bool Persist => persist;

    [BoxGroup( "Pooling" )]
    [SerializeField] private int maxSize = 0;
    public int MaxSize => maxSize;

    public string Key { get; private set; }

    public void SetKey( string key )
    {
        Key = key;
    }

    public virtual void Init() { }

    public virtual void ResetObject() { }

    public virtual void Returned()
    {
        gameObject.SetActive( false );
    }
}
