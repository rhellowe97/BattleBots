using UnityEngine;

namespace CapsuleHands.PlayerCore.Weapons
{
    public class BasicGunWeapon : PlayerWeaponBase
    {
        public override void Shoot( Vector3 position, Vector3 direction, float passedTime )
        {
            base.Shoot( position, direction, passedTime );

            Projectile.Spawn( projectilePrefab, position, direction, targetLayerMask, owner, passedTime );
        }
    }
}
