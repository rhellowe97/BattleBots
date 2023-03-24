using CapsuleHands.PlayerCore;
using UnityEngine;

namespace CapsuleHands.Arena
{
    public class WeaponPickup : PickupBase
    {
        [SerializeField] private int weaponPickup = 1;

        protected override void Pickup( Player player )
        {
            if ( player.TryGetComponent( out PlayerShoot playerShoot ) )
            {
                playerShoot.ChangeWeapon( weaponPickup );
            }
        }
    }
}
