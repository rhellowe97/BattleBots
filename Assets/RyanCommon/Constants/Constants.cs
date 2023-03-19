using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( menuName = "Create Constants" )]
public class Constants : ScriptableObject
{
    private static Constants Data => ConstantsSingleton.Data;

    [Serializable]
    public class ArenaConstants
    {
        [SerializeField] protected List<Color> playerColors;
        public List<Color> PlayerColors => playerColors;

        [SerializeField] protected LayerMask mouseCastLayerMask;
        public LayerMask MouseCastLayerMask => mouseCastLayerMask;

        [SerializeField] protected LayerMask environmentLayerMask;
        public LayerMask EnvironmentLayerMask => environmentLayerMask;

        [SerializeField] protected LayerMask projectileLayerMask;
        public LayerMask ProjectileLayerMask => projectileLayerMask;
    }

    [SerializeField] protected ArenaConstants arena;
    public static ArenaConstants Arena => Data.arena;

    [Serializable]
    public class UIConstants
    {
        [Range( 50, 200 )]
        [SerializeField] private int maxDamageColor = 100;
        public int MaxDamageColor => maxDamageColor;

        [SerializeField] private Gradient damageColorGradient;
        public Gradient DamageColorGradient => damageColorGradient;
    }

    [SerializeField] protected UIConstants ui;
    public static UIConstants UI => Data.ui;
}