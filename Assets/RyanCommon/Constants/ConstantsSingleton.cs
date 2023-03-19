using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ConstantsSingleton : Singleton<ConstantsSingleton>
{
    [SerializeField] protected Constants data;
    public static Constants Data;

    protected override void Awake()
    {
        base.Awake();

        Data = data;
    }
}
