using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectPoolManager : Singleton<ObjectPoolManager>
{
    private Dictionary<string, ObjectPool> pools = new Dictionary<string, ObjectPool>();

    [SerializeField]
    protected ObjectPoolData poolData;

    protected override void Awake()
    {
        base.Awake();

        foreach ( PooledObjectConfig objConfig in poolData.ObjectConfigs )
        {
            string poolKey = $"{objConfig.PooledPrefab.name}-{objConfig.PooledPrefab.GetInstanceID()}";

            pools.Add( poolKey, new ObjectPool() );

            for ( int i = 0; i < objConfig.PreInstantiateCount; i++ )
            {
                GameObject newPooledGO = CreateNewPooledObject( objConfig.PooledPrefab );

                PooledObject pooledObject = newPooledGO.GetComponent<PooledObject>();

                pools[poolKey].UnUsed.Push( pooledObject );
            }
        }
    }

    public GameObject GetPooled( GameObject pooledPrefab, Transform parent = null, bool worldPositionStays = false )
    {
        string poolKey = $"{pooledPrefab.name}-{pooledPrefab.GetInstanceID()}";

        GameObject pooledInstance = null;

        PooledObject pooledObject = null;

        if ( !pools.ContainsKey( poolKey ) || pools[poolKey].UnUsed.Count == 0 )
        {
            pooledInstance = CreateNewPooledObject( pooledPrefab );

            pooledObject = pooledInstance.GetComponent<PooledObject>();
        }
        else
        {
            pooledObject = pools[poolKey].UnUsed.Pop();

            pooledInstance = pooledObject.gameObject;

            pooledObject.ResetObject();
        }

        pools[poolKey].Used.Add( pooledObject );

        pooledInstance.SetActive( true );

        if ( parent != null )
        {
            pooledInstance.transform.SetParent( parent, true );

            if ( !worldPositionStays )
            {
                pooledInstance.transform.localPosition = Vector3.zero;
                pooledInstance.transform.localRotation = Quaternion.identity;
            }
        }

        return pooledInstance;
    }

    private GameObject CreateNewPooledObject( GameObject pooledObject )
    {
        string poolKey = $"{pooledObject.name}-{pooledObject.GetInstanceID()}";

        if ( !pools.ContainsKey( poolKey ) )
        {
            pools.Add( poolKey, new ObjectPool() );
        }

        GameObject newPooledObject = Instantiate( pooledObject, transform );

        PooledObject pooledObj = newPooledObject.GetComponent<PooledObject>();

        if ( pooledObj == null )
            pooledObj = newPooledObject.AddComponent<PooledObject>();

        pooledObj.SetKey( poolKey );

        pooledObj.Init();

        pooledObj.Returned();

        return newPooledObject;
    }

    public void ReturnToPool( GameObject pooledInstance )
    {
        if ( pooledInstance != null )
        {
            PooledObject pooledObject = pooledInstance.GetComponent<PooledObject>();

            if ( !pools.ContainsKey( pooledObject.Key ) )
            {
                Debug.LogError( "Trying to return a non-pooled object!" );

                return;
            }

            pooledObject.Returned();

            pooledObject.transform.SetParent( transform );

            pools[pooledObject.Key].Used.Remove( pooledObject );

            pools[pooledObject.Key].UnUsed.Push( pooledObject );
        }
    }
}

public class ObjectPool
{
    public List<PooledObject> Used = new List<PooledObject>();

    public Stack<PooledObject> UnUsed = new Stack<PooledObject>();
}

[System.Serializable]
public class PooledObjectConfig
{
    [SerializeField]
    protected GameObject pooledPrefab;
    public GameObject PooledPrefab => pooledPrefab;

    [SerializeField]
    protected int preInstantiateCount = 0;
    public int PreInstantiateCount => preInstantiateCount;

    [SerializeField]
    protected int maxSize = 0;
    public int MaxSize => maxSize;
}