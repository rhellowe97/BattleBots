using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

namespace CapsuleHands.PlayerCore.Weapons
{
    public class Explosion : PooledObject
    {
        [SerializeField] private SphereCollider volume;

        private float radius = 1f;

        private int damage = 1;

        private float forceScale = 1f;

        private float speed = 1f;

        private HashSet<IHittable> targetsHit = new HashSet<IHittable>();

        private Tween tween;

        public override void ResetObject()
        {
            base.ResetObject();

            volume.transform.localScale = Vector3.zero;

            targetsHit.Clear();

            if ( tween != null )
            {
                tween.Kill();

                tween = null;
            }
        }

        private void OnTriggerEnter( Collider collider )
        {
            if ( collider.TryGetComponent( out IHittable hittable ) )
            {
                Vector3 hitDirection = ( collider.transform.position - transform.position );

                hitDirection.y *= 0.5f;

                hittable.GetHit( damage, forceScale, hitDirection.normalized );

                targetsHit.Add( hittable );
            }
            else if ( collider.attachedRigidbody != null )
            {
                Vector3 hitDirection = ( collider.transform.position - transform.position );

                hitDirection.y *= 0.5f;

                if ( collider.attachedRigidbody.TryGetComponent( out IHittable rbHittable ) )
                {
                    rbHittable.GetHit( damage, forceScale, hitDirection.normalized );

                    targetsHit.Add( rbHittable );
                }
            }
        }

        public static Explosion Spawn( GameObject explosionPrefab, Vector3 position, float radius, int damage, float forceScale, float speed )
        {
            GameObject go = ObjectPoolManager.Instance.GetPooled( explosionPrefab );

            if ( go == null )
            {
                return null;
            }
            else
            {
                Explosion explosionInstance = go.GetComponent<Explosion>();

                if ( explosionInstance != null )
                {
                    explosionInstance.radius = radius;

                    explosionInstance.damage = damage;

                    explosionInstance.forceScale = forceScale;

                    explosionInstance.speed = speed;

                    explosionInstance.transform.position = position;

                    explosionInstance.tween = explosionInstance.volume.transform.DOPunchScale( Vector3.one * radius * 2f, speed, 0 ).SetUpdate( UpdateType.Fixed ).OnComplete( () => { ObjectPoolManager.Instance.ReturnToPool( explosionInstance.gameObject ); explosionInstance.tween = null; } );
                }

                return explosionInstance;
            }
        }
    }
}
