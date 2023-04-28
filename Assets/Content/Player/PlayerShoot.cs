using CapsuleHands.PlayerCore.Weapons;
using CapsuleHands.UI;
using Mirror;
using Sirenix.OdinInspector;
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

        private float cooldownTimer = 0f;

        [SyncVar( hook = nameof( OnWeaponChanged ) )] private int weaponIndex = 0;
        private PlayerWeaponBase CurrentWeapon => weapons[weaponIndex];

        [SyncVar] private int currentShotsFired = 0;

        [SerializeField] private List<PlayerWeaponBase> weapons = new List<PlayerWeaponBase>();

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

            foreach ( PlayerWeaponBase weapon in weapons )
            {
                weapon.Configure( player, cachedHitMask );
            }

            player.OnPlayerReset += Player_OnPlayerReset;
        }

        private void Player_OnPlayerReset()
        {
            if ( isServer )
                ChangeWeapon( 0 );

            CurrentWeapon.Deactivate();
        }

        [Server]
        public void ChangeWeapon( int index )
        {
            // CurrentWeapon.Eject();

            if ( weapons.Count > index && index >= 0 )
            {
                weaponIndex = index;

                currentShotsFired = 0;

                // CurrentWeapon.Equip();
            }
        }

        private void OnWeaponChanged( int oldIndex, int newIndex )
        {
            weapons[oldIndex].Eject( isLocalPlayer );

            if ( isLocalPlayer )
            {
                if ( weapons[oldIndex].Active )
                {
                    weapons[oldIndex].Release( 0f );

                    ServerRelease( 0f, oldIndex );
                }

                cooldownTimer = weapons[newIndex].Data.Cooldown <= 0.25f ? -0.25f : 0.25f;
            }

            weapons[newIndex].Equip( isLocalPlayer );
        }

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            if ( shootActionRef != null )
            {
                shootAction = PlayerInputManager.Instance.Controls.FindAction( shootActionRef.action.id );

                shootAction.performed += ShootAction_Performed;

                shootAction.canceled += ShootAction_Canceled;
            }

            if ( toggleAimActionRef != null )
            {
                toggleAimAction = PlayerInputManager.Instance.Controls.FindAction( toggleAimActionRef.action.id );

                toggleAimAction.performed += ToggleAimAction_Performed;
            }

            PlayerUIManager.Instance.AddUIElement( PlayerUIManager.UILocation.TopRight, basicWeaponUI.transform );

            basicWeaponUI.gameObject.SetActive( true );
        }

        protected override void LocalPlayerUpdate()
        {
            base.LocalPlayerUpdate();

            if ( player != null )
            {
                player.Gun.rotation = Quaternion.RotateTowards( player.Gun.rotation, Quaternion.LookRotation( player.AimTarget - CurrentWeapon.Source.position, Vector3.up ), 360f * Time.deltaTime );

                CurrentWeapon.UpdateAim( player );
            }

            if ( CurrentWeapon != null )
            {
                if ( cooldownTimer <= CurrentWeapon.Data.Cooldown )
                {
                    cooldownTimer += Time.deltaTime;
                }
                else if ( CurrentWeapon.Active && CurrentWeapon.Data.FireMode == WeaponData.WeaponFireMode.Repeated )
                {
                    LocalShoot();
                }
            }

            heat = Mathf.Max( heat - cooldownRate * Time.deltaTime, 0 );

            if ( basicWeaponUI != null )
            {
                basicWeaponUI.Refresh( heat / heatCap );
            }
        }

        //private void LateUpdate()
        //{
        //    if ( isLocalPlayer )
        //    {
        //        if ( aimingActive )
        //        {
        //            targeter.SetPosition( 0, source.position );

        //            if ( Physics.Raycast( source.position, player.AimTarget - source.position, out rayCastHit, 3f, cachedHitMask, QueryTriggerInteraction.Ignore ) )
        //            {
        //                targeter.SetPosition( 1, rayCastHit.point );
        //            }
        //            else
        //            {
        //                targeter.SetPosition( 1, source.position + ( player.AimTarget - source.position ).normalized * 3f );
        //            }

        //            shootGroundTarget.position = player.GroundTarget.position;

        //            shootAimTarget.position = player.AimTarget;
        //        }
        //    }
        //}

        private void ToggleAiming( bool isAiming )
        {
            aimingActive = isAiming;

            shootGroundTarget.gameObject.SetActive( aimingActive );

            shootAimTarget.gameObject.SetActive( aimingActive );

            //targeter.enabled = aimingActive;
        }

        [Command]
        private void ServerActivate( float networkTime, int index )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME / 2f, passedTime );

            ClientActivate( networkTime, index );
        }

        [ClientRpc( includeOwner = false )]
        private void ClientActivate( float networkTime, int index )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME, passedTime );

            weapons[index].Activate( passedTime );
        }

        [Command]
        private void ServerRelease( float networkTime, int index )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME / 2f, passedTime );

            ClientRelease( networkTime, index );
        }

        [ClientRpc( includeOwner = false )]
        private void ClientRelease( float networkTime, int index )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME, passedTime );

            weapons[index].Release( passedTime );
        }

        [Command]
        private void ServerShoot( Vector3 position, Vector3 direction, float networkTime, int index )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME / 2f, passedTime );

            ClientShoot( position, direction, networkTime, index );

            if ( CurrentWeapon.Data.AmmoCapactity > 0 )
                currentShotsFired++;

            if ( CurrentWeapon.Data.AmmoCapactity == currentShotsFired )
            {
                ChangeWeapon( 0 );
            }
        }

        [ClientRpc( includeOwner = false )]
        private void ClientShoot( Vector3 position, Vector3 direction, float networkTime, int index )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME, passedTime );

            weapons[index].Shoot( position, direction, passedTime );
        }

        private const float MAX_PASSED_TIME = 0.3f;

        [SerializeField] private float heatCap = 100f;

        [SerializeField] private float cooldownRate = 5f;

        [SerializeField] private float shotHeat = 10f;

        [SerializeField] private BasicWeaponUI basicWeaponUI;

        private float heat = 0f;

        private void LocalShoot()
        {
            if ( weaponIndex != 0 || heat < heatCap - shotHeat )
            {
                cooldownTimer = 0f;

                if ( weaponIndex == 0 )
                    heat += shotHeat;

                CurrentWeapon.Shoot( CurrentWeapon.Source.position, CurrentWeapon.GetAimDirection( player ), 0f );

                ServerShoot( CurrentWeapon.Source.position, CurrentWeapon.GetAimDirection( player ), ( float ) NetworkTime.time, weaponIndex );
            }
        }

        private void ShootAction_Performed( InputAction.CallbackContext context )
        {
            if ( player.Active && CurrentWeapon != null )
            {
                if ( CurrentWeapon.Data.AmmoCapactity < 0 || CurrentWeapon.Data.AmmoCapactity > currentShotsFired )
                {
                    if ( CurrentWeapon.Data.FireMode == WeaponData.WeaponFireMode.Single && cooldownTimer >= CurrentWeapon.Data.Cooldown )
                    {
                        LocalShoot();
                    }
                    else if ( CurrentWeapon.Data.FireMode == WeaponData.WeaponFireMode.Repeated || cooldownTimer >= CurrentWeapon.Data.Cooldown )
                    {
                        CurrentWeapon.Activate( 0f );

                        ServerActivate( ( float ) NetworkTime.time, weaponIndex );
                    }
                }
            }
        }

        private void ShootAction_Canceled( InputAction.CallbackContext context )
        {
            if ( player.Active && CurrentWeapon != null && CurrentWeapon.Active )
            {
                if ( CurrentWeapon.Data.FireMode != WeaponData.WeaponFireMode.Single )
                {
                    CurrentWeapon.Release( 0f );

                    ServerRelease( ( float ) NetworkTime.time, weaponIndex );

                    if ( CurrentWeapon.Data.FireMode == WeaponData.WeaponFireMode.Release && CurrentWeapon.CanShoot() )
                    {
                        LocalShoot();
                    }
                }
            }
        }

        private void ToggleAimAction_Performed( InputAction.CallbackContext context )
        {
            if ( player.Active )
                ToggleAiming( !aimingActive );
        }

        public void ForceRelease()
        {
            if ( isLocalPlayer )
            {
                if ( CurrentWeapon.Data.FireMode != WeaponData.WeaponFireMode.Single )
                {
                    CurrentWeapon.Release( 0f );

                    ServerRelease( ( float ) NetworkTime.time, weaponIndex );
                }
            }
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

            if ( isLocalPlayer && PlayerUIManager.Exists )
            {
                PlayerUIManager.Instance.RemoveUIElement( PlayerUIManager.UILocation.TopRight, basicWeaponUI.transform );
            }
        }
    }
}
