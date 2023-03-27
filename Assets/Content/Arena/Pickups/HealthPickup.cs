using System.Collections;
using System.Collections.Generic;
using CapsuleHands.PlayerCore;
using UnityEngine;

namespace CapsuleHands.Arena
{
    public class HealthPickup : PickupBase
    {
        [SerializeField] private int healthRestored;

        protected override void Pickup( Player player )
        {
            player.UpdateDamage( -healthRestored );
        }
    }
}
