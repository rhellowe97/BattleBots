using CapsuleHands.PlayerCore;
using Mirror;
using UnityEngine;

namespace CapsuleHands.Arena
{
    public abstract class PickupBase : MonoBehaviour
    {
        protected virtual void OnTriggerEnter( Collider col )
        {
            if ( col.attachedRigidbody != null && col.attachedRigidbody.TryGetComponent( out Player player ) )
            {
                ServerTriggerEnter( player );

                Destroy( gameObject );
            }
        }

        [Server]
        private void ServerTriggerEnter( Player player )
        {
            Pickup( player );
        }

        protected abstract void Pickup( Player player );
    }
}
