using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore.Weapons
{
    public class RailgunWeapon : PlayerWeaponBase
    {
        [SerializeField] private LineRenderer aimLine;

        [SerializeField] private float beamDistance = 10f;

        [SerializeField] private GameObject railBeamPrefab;

        [SerializeField] private float chargeTime = 0.5f;

        [SerializeField] private ParticleSystem chargedEffect;

        private float timeHeld = 0f;

        public override void Equip( bool isLocalPlayer )
        {
            base.Equip( isLocalPlayer );

            if ( isLocalPlayer )
                aimLine.enabled = true;
        }

        public override void Eject( bool isLocalPlayer )
        {
            base.Eject( isLocalPlayer );

            if ( isLocalPlayer )
                aimLine.enabled = false;

            chargedEffect.Stop();
        }

        public override void UpdateAim( Player player )
        {
            aimLine.SetPosition( 0, source.position );

            aimLine.SetPosition( 1, source.position + ( player.AimTarget - source.position ).normalized * beamDistance );
        }

        public override void Activate( float passedTime )
        {
            base.Activate( passedTime );

            timeHeld = 0f;
        }

        public override bool CanShoot()
        {
            return timeHeld >= chargeTime;
        }

        public override void Release( float passedTime )
        {
            base.Release( passedTime );

            chargedEffect.Stop();
        }

        private void Update()
        {
            if ( Active )
            {
                timeHeld += Time.deltaTime;

                if ( timeHeld >= chargeTime && !chargedEffect.isPlaying )
                {
                    chargedEffect.Play();
                }
            }
        }

        public override void Shoot( Vector3 position, Vector3 direction, float passedTime )
        {
            base.Shoot( position, direction, passedTime );

            RailgunBeam railBeamInstance = ObjectPoolManager.Instance.GetPooled( railBeamPrefab ).GetComponent<RailgunBeam>();

            railBeamInstance.Setup( beamDistance );

            railBeamInstance.Fire( position, direction, passedTime );

        }
    }
}