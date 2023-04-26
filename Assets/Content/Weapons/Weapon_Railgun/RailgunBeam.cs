using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RailgunBeam : PooledObject
{
    [SerializeField] private ProjectileData beamData;

    [SerializeField] private LineRenderer laserRenderer;

    [SerializeField] private LayerMask targetLayer;

    [SerializeField] private float beamSpeed = 0.3f;

    [SerializeField] private AnimationCurve beamFireCurve;

    public Action<IHittable> OnHittableHit;

    private RaycastHit[] hitResults = new RaycastHit[10];

    private float distance = 0;

    public void Setup( float distance )
    {
        this.distance = distance;
    }

    public void Fire( Vector3 position, Vector3 forward, float passedTime )
    {
        transform.forward = forward;

        transform.position = position;

        laserRenderer.positionCount = 2;

        laserRenderer.SetPosition( 0, transform.position );

        laserRenderer.SetPosition( 1, transform.position + transform.forward * distance );

        if ( laserCo != null )
        {
            StopCoroutine( laserCo );
        }

        laserCo = StartCoroutine( BeamRoutine( passedTime ) );

        if ( Physics.RaycastNonAlloc( transform.position, transform.forward, hitResults, distance, targetLayer, QueryTriggerInteraction.Ignore ) > 0 )
        {
            for ( int i = 0; i < hitResults.Length; i++ )
            {
                if ( hitResults[i].collider != null && hitResults[i].collider.attachedRigidbody != null && hitResults[i].collider.attachedRigidbody.gameObject.TryGetComponent( out IHittable hittable ) )
                {
                    hittable.GetHit( beamData.Damage, 1.5f, forward );
                }
            }
        }
    }

    private Coroutine laserCo;

    private IEnumerator BeamRoutine( float passedTime )
    {
        float duration = beamSpeed - passedTime;

        float t = 0;

        laserRenderer.enabled = true;

        while ( t < duration )
        {
            laserRenderer.startWidth = laserRenderer.endWidth = beamFireCurve.Evaluate( t / duration );

            t += Time.deltaTime;

            yield return null;
        }

        laserRenderer.startWidth = laserRenderer.endWidth = 0;

        laserRenderer.enabled = false;

        laserCo = null;

        ObjectPoolManager.Instance.ReturnToPool( gameObject );
    }
}
