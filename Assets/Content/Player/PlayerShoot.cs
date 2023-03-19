using Mirror;
using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CapsuleHands.PlayerCore
{
    public class PlayerShoot : PlayerComponentBase
    {
        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference shootActionRef;
        private InputAction shootAction;

        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference toggleAimActionRef;
        private InputAction toggleAimAction;

        [SerializeField] private AudioSource shotAudio;

        [SerializeField] private GameObject bulletPrefab;

        [SerializeField] private Transform source;

        [SerializeField] private LineRenderer targeter;

        [SerializeField] private Transform shootGroundTarget;

        [SerializeField] private Transform shootAimTarget;

        private LayerMask cachedHitMask;

        private RaycastHit rayCastHit;

        private bool aimingActive = false;

        public override void OnStartClient()
        {
            base.OnStartClient();

            ToggleAiming( false );

            cachedHitMask = Constants.Arena.ProjectileLayerMask;
        }

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            if ( shootActionRef != null )
            {
                shootAction = PlayerInputManager.Instance.Controls.FindAction( shootActionRef.action.id );

                shootAction.performed += ShootAction_Performed;
            }

            if ( toggleAimActionRef != null )
            {
                toggleAimAction = PlayerInputManager.Instance.Controls.FindAction( toggleAimActionRef.action.id );

                toggleAimAction.performed += ToggleAimAction_Performed;
            }

            targeter.positionCount = 2;
        }

        protected override void LocalPlayerUpdate()
        {
            base.LocalPlayerUpdate();

            if ( player != null )
            {
                player.Gun.rotation = Quaternion.RotateTowards( player.Gun.rotation, Quaternion.LookRotation( player.AimTarget - source.position, Vector3.up ), 360f );
            }
        }

        private void LateUpdate()
        {
            if ( isLocalPlayer )
            {
                if ( aimingActive )
                {
                    targeter.SetPosition( 0, source.position );

                    if ( Physics.Raycast( source.position, player.AimTarget - source.position, out rayCastHit, 100f, cachedHitMask, QueryTriggerInteraction.Ignore ) )
                    {
                        targeter.SetPosition( 1, rayCastHit.point );
                    }
                    else
                    {
                        targeter.SetPosition( 1, source.position + ( player.AimTarget - source.position ).normalized * 100f );
                    }

                    shootGroundTarget.position = player.GroundTarget.position;

                    shootAimTarget.position = player.AimTarget;
                }
            }
        }

        private void ToggleAiming( bool isAiming )
        {
            aimingActive = isAiming;

            shootGroundTarget.gameObject.SetActive( aimingActive );

            shootAimTarget.gameObject.SetActive( aimingActive );

            targeter.enabled = aimingActive;
        }

        public void Shoot( Vector3 position, Vector3 direction, float passedTime )
        {
            Projectile.Spawn( bulletPrefab, position, direction, cachedHitMask, player, passedTime );

            shotAudio.Play();
        }

        [Command]
        private void ServerShoot( Vector3 position, Vector3 direction, float networkTime )
        {
            float passedTime = (float)( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME / 2f, passedTime );

            ClientShoot( position, direction, networkTime );
        }

        [ClientRpc( includeOwner = false )]
        private void ClientShoot( Vector3 position, Vector3 direction, float networkTime )
        {
            float passedTime = (float)( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME, passedTime );

            Shoot( position, direction, passedTime );
        }

        private const float MAX_PASSED_TIME = 0.3f;

        private void ShootAction_Performed( InputAction.CallbackContext context )
        {
            if ( player.Active )
            {
                Shoot( source.position, player.AimTarget - source.position, 0f );

                ServerShoot( source.position, player.AimTarget - source.position, (float)NetworkTime.time );
            }
        }

        private void ToggleAimAction_Performed( InputAction.CallbackContext context )
        {
            if ( player.Active )
                ToggleAiming( !aimingActive );
        }

        private void OnDestroy()
        {
            if ( shootAction != null )
            {
                shootAction.performed -= ShootAction_Performed;
            }

            if ( toggleAimAction != null )
            {
                toggleAimAction.performed -= ToggleAimAction_Performed;
            }
        }
    }
}
