using CapsuleHands.Singleton;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore.Weapons
{
    public class MortarWeapon : PlayerWeaponBase
    {
        [SerializeField] private Transform midpoint;

        [SerializeField] private float midPointHeight;

        [SerializeField] private int arcCurveSteps = 12;

        [SerializeField] private LineRenderer aimLine;

        public override void Setup()
        {
            aimLine.positionCount = arcCurveSteps + 1;

            aimLine.enabled = false;
        }

        public override void Equip()
        {
            AimManager.Instance.AddLock( this );

            aimLine.enabled = true;
        }

        public override void Eject()
        {
            AimManager.Instance.RemoveLock( this );

            aimLine.enabled = false;
        }

        public override void UpdateAim( Player player )
        {
            midpoint.position = source.position + ( player.GroundTarget.position - source.position ) / 2f + Vector3.up * ( Mathf.Lerp( 2f, 1f, Mathf.Min( 1f, ( player.GroundTarget.position - source.position ).sqrMagnitude / 16f ) ) ) * midPointHeight;

            aimLine.SetPosition( 0, source.position );

            for ( int i = 1; i <= arcCurveSteps; i++ )
            {
                aimLine.SetPosition( i, GetPoint( ( float ) i / arcCurveSteps, player.GroundTarget.position ) );
            }
        }

        public override void Shoot( Vector3 position, Vector3 direction, float passedTime )
        {
            base.Shoot( position, direction, passedTime );

            Vector3[] positions = new Vector3[arcCurveSteps + 2];

            positions[0] = position;

            midpoint.position = position + ( direction - position ) / 2f + Vector3.up * ( Mathf.Lerp( 2f, 1f, Mathf.Min( 1f, ( direction - position ).sqrMagnitude / 16f ) ) ) * midPointHeight;

            for ( int i = 1; i <= arcCurveSteps; i++ )
            {
                positions[i] = GetPoint( ( float ) i / arcCurveSteps, direction );
            }

            positions[positions.Length - 1] = direction;

            ArcProjectile.Spawn( projectilePrefab, positions, targetLayerMask, owner, passedTime );
        }

        public override Vector3 GetAimDirection( Player player )
        {
            return player.GroundTarget.position;
        }

        private Vector3 GetPoint( float t, Vector3 endpoint )
        {
            return Vector3.Lerp( Vector3.Lerp( source.position, midpoint.transform.position, t ), Vector3.Lerp( midpoint.transform.position, endpoint, t ), t );
        }
    }
}
