using DB;
using UnityEngine;

public class DatabaseSingleton : Singleton<DatabaseSingleton>
{
    [SerializeField]
    protected Database Data;

    protected void Start()
    {
        Data.GenerateLookup();
    }

    public IDatabaseItem Get( string searchId )
    {
        return Data.Get( searchId );
    }

    public IDatabaseItem Get( IDBRef searchId )
    {
        return Data.Get( searchId );
    }

    public T GetT<T>( string searchId )
       where T : Object, IDatabaseItem
    {
        return Data.GetT<T>( searchId );
    }

    public T GetT<T>( IDBRef<T> searchId )
        where T : Object, IDatabaseItem
    {
        return Data.GetT<T>( searchId );
    }
}
