using Sirenix.OdinInspector;
using UnityEngine;

[CreateAssetMenu( menuName = "Database/Create Projectile Data" )]
public class ProjectileData : ScriptableData<ProjectileData>
{
    [SerializeField] protected float speed = 10f;
    public float Speed => speed;

    [SerializeField] protected int damage = 1;
    public int Damage => damage;

    [SerializeField] protected float lifeDuration = 3f;
    public float LifeDuration => lifeDuration;

    [SerializeField] protected GameObject impactEffect;
    public GameObject ImpactEffect => impactEffect;

    [BoxGroup( "Seek" )]
    [SerializeField] protected bool seeking = false;
    public bool Seeking => seeking;

    [BoxGroup( "Seek" )]
    [ShowIf( nameof( seeking ) )]
    [SerializeField] protected float seekRate = 30f;
    public float SeekRate => seekRate;

    [BoxGroup( "Splash" )]
    [HideIf( nameof( pierce ) )]
    [SerializeField] protected bool splash = false;
    public bool Splash => splash;

    [BoxGroup( "Splash" )]
    [ShowIf( nameof( splash ) )]
    [SerializeField] protected float splashRadius = 3f;
    public float SplashRadius => splashRadius;

    [BoxGroup( "Pierce" )]
    [HideIf( nameof( splash ) )]
    [SerializeField] protected bool pierce = false;
    public bool Pierce => pierce;

    [BoxGroup( "Pierce" )]
    [ShowIf( nameof( pierce ) )]
    [SerializeField] protected int pierceCount = 2;
    public int PierceCount => pierceCount;

    [BoxGroup( "Damage Over Time" )]
    [SerializeField] protected bool dot = false;
    public bool Dot => dot;

    [BoxGroup( "Damage Over Time" )]
    [ShowIf( nameof( dot ) )]
    [SerializeField] protected float dotRate = 1f;
    public float DotRate => dotRate;

    [BoxGroup( "Damage Over Time" )]
    [ShowIf( nameof( dot ) )]
    [SerializeField] protected float dotDuration = 5f;
    public float DotDuration => dotDuration;

    [BoxGroup( "Damage Over Time" )]
    [ShowIf( nameof( dot ) )]
    [SerializeField] protected int dotDamage = 1;
    public int DotDamage => dotDamage;
}

