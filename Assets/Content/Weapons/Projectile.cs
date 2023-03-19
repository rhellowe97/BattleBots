using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projectile : PooledObject, IHitConfigurable
{
    [SerializeField] protected ProjectileData data;
    public ProjectileData Data => data;

    public bool Active { get; private set; } = false;

    public float TravelledDistance { get; private set; } = 0f;

    [SerializeField] protected PooledEffect impactEffectPrefab;

    private Transform aimTarget;

    private float lifeTimer = 0f;

    private float distanceChunk = 0f;

    private RaycastHit collisionRayHit;

    private TrailRenderer projTrail;

    private float currentSpeed = 0f;

    private LayerMask hittableMask;

    private IHittable owner;

    public void Configure( IHittable newOwner, LayerMask targetLayerMask )
    {
        owner = newOwner;

        hittableMask = targetLayerMask;
    }

    public void SetAimTarget( Transform target )
    {
        aimTarget = target;
    }

    public void InheritVelocity( Vector3 velocity )
    {
        Vector3 newHeading = velocity + transform.forward * Data.Speed;

        transform.forward = newHeading;
    }

    private void FixedUpdate()
    {
        if ( Data.Seeking && aimTarget != null )
        {
            transform.rotation = Quaternion.RotateTowards( transform.rotation, Quaternion.LookRotation( ( aimTarget.transform.position + Vector3.up * 0.5f ) - transform.position, Vector3.up ), Data.SeekRate * Time.fixedDeltaTime );
        }

        float passedTimeDelta = 0f;

        if ( passedTime > 0f )
        {
            float step = passedTime * 0.08f;

            passedTime -= step;

            if ( passedTime <= ( Time.fixedDeltaTime / 2f ) )
            {
                step += passedTime;

                passedTime = 0f;
            }

            passedTimeDelta = step;

            distanceChunk = currentSpeed * ( Time.fixedDeltaTime + passedTimeDelta );
        }
        else
        {
            distanceChunk = currentSpeed * Time.fixedDeltaTime;
        }

        Vector3 rayStartPosition = transform.position - ( transform.forward * Mathf.Min( TravelledDistance, distanceChunk ) );

        if ( Physics.Raycast( rayStartPosition, transform.forward, out collisionRayHit, 2 * distanceChunk, hittableMask, QueryTriggerInteraction.Ignore ) )
        {
            if ( collisionRayHit.collider.TryGetComponent( out IHittable hittable ) )
            {
                if ( hittable != owner )
                    hittable.GetHit( Data.Damage, 1f, transform.forward );
            }
            else if ( collisionRayHit.collider.attachedRigidbody != null )
            {
                if ( collisionRayHit.collider.attachedRigidbody.TryGetComponent( out IHittable rbHittable ) )
                {
                    if ( rbHittable != owner )
                        rbHittable.GetHit( Data.Damage, 1f, transform.forward );
                }
            }

            if ( impactEffectPrefab != null )
            {
                PooledEffect impactEffectInstance = ObjectPoolManager.Instance.GetPooled( impactEffectPrefab.gameObject ).GetComponent<PooledEffect>();

                impactEffectInstance.transform.position = collisionRayHit.point;

                impactEffectInstance.transform.rotation = Quaternion.LookRotation( collisionRayHit.normal, Vector3.up );

                impactEffectInstance.Play();
            }

            if ( ObjectPoolManager.Exists )
                ObjectPoolManager.Instance.ReturnToPool( gameObject );
            else
                Destroy( gameObject );
        }
        else
        {
            transform.position += transform.forward * distanceChunk;

            if ( TravelledDistance < distanceChunk )
                TravelledDistance += distanceChunk;
        }

        lifeTimer += Time.fixedDeltaTime;

        if ( lifeTimer >= Data.LifeDuration )
        {
            if ( ObjectPoolManager.Exists )
                ObjectPoolManager.Instance.ReturnToPool( gameObject );
            else
                Destroy( gameObject );
        }
    }

    public override void Init()
    {
        currentSpeed = Data.Speed;

        distanceChunk = currentSpeed * Time.fixedDeltaTime;

        projTrail = GetComponent<TrailRenderer>();
    }

    public override void ResetObject()
    {
        lifeTimer = 0f;

        TravelledDistance = 0f;

        owner = null;
    }

    public override void Returned()
    {
        if ( projTrail != null )
        {
            projTrail.Clear();
        }

        Active = false;

        passedTime = 0f;

        base.Returned();
    }

    private float passedTime = 0f;

    public static Projectile Spawn( GameObject projectilePrefab, Vector3 spawnPosition, Vector3 direction, LayerMask targetLayerMask, IHittable owner = null, float passedTime = 0f )
    {
        GameObject go = ObjectPoolManager.Instance.GetPooled( projectilePrefab );

        if ( go == null )
        {
            return null;
        }
        else
        {
            Projectile projectileInstance = go.GetComponent<Projectile>();

            if ( projectileInstance != null )
            {
                projectileInstance.transform.position = spawnPosition;

                projectileInstance.transform.forward = direction;

                projectileInstance.passedTime = passedTime;

                projectileInstance.Configure( owner, targetLayerMask );

                projectileInstance.Active = true;
            }

            return projectileInstance;
        }
    }

    public static void ClearActive()
    {
        Projectile[] activeProjectiles = FindObjectsOfType<Projectile>( false );

        foreach ( Projectile proj in activeProjectiles )
        {
            if ( ObjectPoolManager.Exists )
                ObjectPoolManager.Instance.ReturnToPool( proj.gameObject );
        }
    }
}
