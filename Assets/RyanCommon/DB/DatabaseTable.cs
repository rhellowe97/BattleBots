using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public interface IDatabaseTable<T> : IDatabaseTable
    where T : Object, IDatabaseItem
{
    void Add( T item );

    void Remove( T item );

    T GetT( string searchID );
}

public class DatabaseTable<T> : DatabaseTableBase, IDatabaseTable<T>
    where T : Object, IDatabaseItem
{
    private static T Dummy;
    public override Type Type
    {
        get
        {
            return typeof( T );
        }
    }

    [SerializeField]
    protected List<T> items = new List<T>();

    [NonSerialized]
    protected Dictionary<string, T> lookup;

    private void AddListLookup( List<T> list )
    {
        if ( list == null )
            return;

        for ( int i = list.Count - 1; i >= 0; --i )
        {
            if ( list[i] != null )
                lookup[list[i].ID] = list[i];
        }
    }

    public override void GenerateLookup()
    {
        lookup = new Dictionary<string, T>( items.Count );

        AddListLookup( items );
    }

    public override bool ContainsID( string id )
    {
        if ( lookup != null )
        {
            return lookup.ContainsKey( id );
        }
        else
        {
            foreach ( var item in items )
            {
                if ( item == null )
                {
                    Debug.LogError( "Missing DB Item" );
                    continue;
                }

                if ( item.ID == id )
                    return true;
            }
        }

        return false;
    }

    public override void Add( IDatabaseItem item )
    {
        T typedItem = item as T;
        if ( typedItem == null )
        {
            Debug.LogError( "Invalid type insterted." );
            return;
        }

        Add( typedItem );
    }

    public override void Remove( IDatabaseItem item )
    {
        T typedItem = item as T;
        if ( typedItem == null )
        {
            Debug.LogError( "Invalid type insterted." );
            return;
        }

        Remove( typedItem );
    }

    public override IDatabaseItem Get( string searchId )
    {
        if ( lookup == null )
            GenerateLookup();

        T item;
        lookup.TryGetValue( searchId, out item );

        if ( item == null )
            Debug.LogError( $"{searchId} not found in {this.name}" );

        return item;
    }

    public T GetT( string searchId )
    {
        if ( lookup == null )
            GenerateLookup();

        T item;
        lookup.TryGetValue( searchId, out item );

        if ( item == null )
            Debug.LogError( $"{searchId} not found in {this.name}" );

        return item;
    }

    public void Add( T item )
    {
        throw new NotImplementedException();
    }

    public void Remove( T item )
    {
        throw new NotImplementedException();
    }

    public override IEnumerable<IDatabaseItem> Items
    {
        get
        {
            return items;
        }
    }

    public override void OnAfterDeserialize()
    {
        base.OnAfterDeserialize();

        for ( int i = items.Count - 1; i >= 0; --i )
        {
            if ( items[i] == null )
                items.RemoveAt( i );
        }
    }

    protected override void OnEnable()
    {
        base.OnEnable();

#if UNITY_EDITOR
        if ( Application.isPlaying )
#endif
            GenerateLookup();
    }

#if UNITY_EDITOR
    public virtual void Sort()
    {
        items.Sort( ( x, y ) => x.ID.CompareTo( y.ID ) );
    }

    public void EditorAdd( T item )
    {
        if ( !items.Contains( item ) )
            items.Add( item );
    }

    [ShowInInspector]
    [HideInPlayMode]
    [LabelText( "Refresh" )]
    [Button( DrawResult = false )]
    public override bool EditorRefresh()
    {
        return true;
    }
#endif
}
