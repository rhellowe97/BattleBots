using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( menuName = "Database/Create Weapon Data" )]
public class WeaponData : ScriptableData<WeaponData>
{
    public enum WeaponFireMode
    {
        Single,
        Repeated,
        Release,
    }

    [SerializeField] protected float cooldown = 0.2f;
    public float Cooldown => cooldown;

    [SerializeField] protected int ammoCapactity = -1;
    public int AmmoCapactity => ammoCapactity;

    [SerializeField] protected WeaponFireMode fireMode = WeaponFireMode.Single;
    public WeaponFireMode FireMode => fireMode;
}
