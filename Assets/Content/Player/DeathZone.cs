using CapsuleHands.PlayerCore;
using Mirror;
using UnityEngine;

public class DeathZone : MonoBehaviour
{
    private void OnTriggerEnter( Collider other )
    {
        if ( !NetworkServer.active )
            return;

        if ( other.attachedRigidbody != null && other.attachedRigidbody.TryGetComponent( out Player player ) )
        {
            player.OnServerPlayerEliminated();
        }
    }
}
