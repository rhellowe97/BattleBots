using CapsuleHands.PlayerCore;
using Mirror;
using System;
using UnityEngine;

namespace CapsuleHands.Arena
{
    public abstract class PickupBase : PooledObject
    {
        [SerializeField] private float spawnWeight = 0f;
        public float SpawnWeight => spawnWeight;

        [SerializeField] private PooledEffect pickupEffect;

        private Vector3 spawnPosition;

        private const float SPIN_RATE = 60;

        private const float DROP_SPEED = 2f;

        private const float DROP_HEIGHT = 20f;

        public Action<PickupBase> OnPickup;

        protected virtual void OnTriggerEnter( Collider col )
        {
            if ( col.attachedRigidbody != null && col.attachedRigidbody.TryGetComponent( out Player player ) )
            {
                ServerTriggerEnter( player );

                ObjectPoolManager.Instance.ReturnToPool( gameObject );
            }
        }

        [Server]
        private void ServerTriggerEnter( Player player )
        {
            Pickup( player );

            OnPickup?.Invoke( this );
        }

        protected abstract void Pickup( Player player );

        public void SetSpawnPosition( Vector3 position, float passedTime )
        {
            transform.position = position + Vector3.up * DROP_HEIGHT + ( Vector3.down * DROP_SPEED * passedTime );

            spawnPosition = position;
        }

        private void Update()
        {
            transform.Rotate( Vector3.up * SPIN_RATE * Time.deltaTime, Space.World );

            transform.position = Vector3.MoveTowards( transform.position, spawnPosition, DROP_SPEED * Time.deltaTime );
        }
    }
}
