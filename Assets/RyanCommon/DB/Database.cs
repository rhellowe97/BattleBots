namespace DB
{
    using Sirenix.OdinInspector;
    using System.Collections.Generic;
    using UnityEngine;
#if UNITY_EDITOR
    using UnityEditor;
#endif

    [CreateAssetMenu( menuName = "Database/Database", order = -100 )]
    public class Database : ScriptableData<Database>
    {
        [SerializeField]
        protected List<DatabaseTableBase> items = new List<DatabaseTableBase>();
        public IEnumerable<DatabaseTableBase> Items
        {
            get
            {
                foreach ( var t in items )
                    yield return t;
            }
        }

        [ShowInInspector]
        private Dictionary<System.Type, DatabaseTableBase> tableLookup;
        [ShowInInspector]
        private Dictionary<string, System.Type> typeLookup;

        private void AddTableListLookup( List<DatabaseTableBase> list )
        {
            if ( list == null )
                return;

            for ( int i = list.Count - 1; i >= 0; --i )
            {
                if ( list[i] != null )
                {
                    System.Type type = list[i].Type;
                    tableLookup[list[i].Type] = list[i] as DatabaseTableBase;
                    foreach ( var r in list[i].Items )
                    {
                        if ( string.IsNullOrEmpty( r.ID ) && r is Object )
                            Debug.LogError( $"{r} is missing DB ID." );

                        if ( typeLookup.ContainsKey( r.ID ) )
                        {
                            Debug.LogError( $"Failed to add duplicated ID {r.ID}" );
                        }
                        else
                        {
                            typeLookup.Add( r.ID, type );
                        }
                    }

                    list[i].GenerateLookup();
                }
            }
        }

        public void GenerateLookup()
        {
            tableLookup = new Dictionary<System.Type, DatabaseTableBase>( items.Count );
            typeLookup = new Dictionary<string, System.Type>();

            AddTableListLookup( items );
        }

        public bool ContainsID( string id )
        {
            if ( typeLookup != null )
            {
                return typeLookup.ContainsKey( id );
            }
            else
            {
                foreach ( var item in items )
                {
                    if ( item == null )
                    {
                        Debug.LogError( "Missing DB" );
                        continue;
                    }

                    if ( item.ContainsID( id ) )
                        return true;
                }
            }

            return false;
        }

        public void AddTable<TDatabaseTable, TDatabaseItem>( TDatabaseTable table )
            where TDatabaseTable : DatabaseTableBase, IDatabaseTable<TDatabaseItem>
            where TDatabaseItem : Object, IDatabaseItem
        {
            if ( tableLookup != null )
                tableLookup[table.Type] = table;

#if UNITY_EDITOR
            EditorUtility.SetDirty( this );
#endif
        }

        public IDatabaseItem Get( string searchId )
        {
            if ( tableLookup == null )
                GenerateLookup();

            System.Type type;
            typeLookup.TryGetValue( searchId, out type );

            if ( type == null )
            {
                Debug.LogError( $"{searchId} was not found in {this.name}" );
                return null;
            }

            DatabaseTableBase table;
            tableLookup.TryGetValue( type, out table );

            if ( table == null )
            {
                Debug.LogError( $"{type.Name} was not found in {this.name}" );
            }

            return table.Get( searchId );
        }

        public IDatabaseItem Get( IDBRef searchId )
        {
            return Get( searchId.ID );
        }

        private DatabaseTableBase GetTable( System.Type type )
        {
            if ( tableLookup == null )
                GenerateLookup();

            DatabaseTableBase table;
            tableLookup.TryGetValue( type, out table );

            if ( table == null )
            {
                Debug.LogError( $"{type.Name} not found in {this.name}" );
            }

            return table;
        }

        private DatabaseTable<T> GetTable<T>()
            where T : Object, IDatabaseItem
        {
            return GetTable( typeof( T ) ) as DatabaseTable<T>;
        }

        public T GetT<T>( string searchId )
            where T : Object, IDatabaseItem
        {
            DatabaseTable<T> table = GetTable<T>();
            if ( table != null )
                return table.GetT( searchId );
            return null;
        }

        public T GetT<T>( IDBRef searchId )
            where T : Object, IDatabaseItem
        {
            return GetT<T>( searchId.ID );
        }
    }
}
