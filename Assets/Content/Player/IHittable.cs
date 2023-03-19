
using UnityEngine;

public interface IHittable
{
    void GetHit( int damage, float forceScale, Vector3 hitDirection );
}

public interface IHitConfigurable
{
    void Configure( IHittable owner, LayerMask targetLayerMask );
}