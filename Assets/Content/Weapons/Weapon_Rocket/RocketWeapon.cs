using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore.Weapons
{
    public class RocketWeapon : PlayerWeaponBase
    {
        public override void Shoot( Vector3 position, Vector3 direction, float passedTime )
        {
            base.Shoot( position, direction, passedTime );

            Projectile.Spawn( projectilePrefab, position, direction, targetLayerMask, owner, passedTime );
        }

        public override Vector3 GetAimDirection( Player player )
        {
            return player.GroundTarget.position - source.position;
        }
    }
}
