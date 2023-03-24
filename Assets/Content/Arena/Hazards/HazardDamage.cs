using CapsuleHands.PlayerCore;
using Mirror;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.Arena.Hazards
{
    public class HazardDamage : MonoBehaviour
    {
        [SerializeField] private int damage = 10;

        [SerializeField] private float knockbackScale = 2f;

        private Dictionary<Player, double> hitTimes = new Dictionary<Player, double>();

        private void OnCollisionEnter( Collision collision )
        {
            if ( collision.collider.attachedRigidbody != null && collision.collider.attachedRigidbody.TryGetComponent( out Player player ) && ( !hitTimes.ContainsKey( player ) || NetworkTime.time - hitTimes[player] > 0.2f ) )
            {
                player.GetHit( damage, knockbackScale, -collision.contacts[0].normal );

                if ( !hitTimes.ContainsKey( player ) )
                    hitTimes.Add( player, NetworkTime.time );
                else
                    hitTimes[player] = NetworkTime.time;
            }
        }
    }
}
