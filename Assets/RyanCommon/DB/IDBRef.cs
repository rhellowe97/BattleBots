namespace DB
{
    using UnityEngine;

    public interface IDBRef
    {
        string ID { get; set; }
    }

    public interface IDBRef<T> : IDBRef where T : Object
    {
        T DBItem { get; }
    }
}
