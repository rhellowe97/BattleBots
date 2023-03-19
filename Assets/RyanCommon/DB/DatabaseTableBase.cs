using System;
using System.Collections.Generic;

public interface IDatabaseItem
{
    string ID { get; }
}

public interface IDatabaseTable
{
    System.Type Type { get; }

    bool ContainsID( string id );

    void Add( IDatabaseItem item );

    void Remove( IDatabaseItem Remove );

    IDatabaseItem Get( string searchId );

    IEnumerable<IDatabaseItem> Items { get; }
}

public abstract class DatabaseTableBase : ScriptableData<DatabaseTableBase>, IDatabaseTable
{
    public abstract Type Type { get; }

    public abstract void GenerateLookup();

    public abstract bool ContainsID( string id );

    public abstract void Add( IDatabaseItem item );

    public abstract void Remove( IDatabaseItem item );

    public abstract IDatabaseItem Get( string searchId );

    public abstract IEnumerable<IDatabaseItem> Items { get; }

#if UNITY_EDITOR
    public abstract bool EditorRefresh();
#endif
}