using Mirror;
using Sirenix.OdinInspector;
using System;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CapsuleHands.PlayerCore
{
    public class PlayerShield : PlayerComponentBase
    {
        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference shieldActionRef;
        private InputAction shieldAction;

        [SyncVar]
        private float shieldCharge = 100;

        private bool shieldActive;

        [SerializeField]
        private Shield shield;

        [SerializeField]
        private float shieldUseDecay = 10f;

        [SerializeField]
        private float shieldDamageDecayScale = 1f;

        [SerializeField]
        private float shieldRechargeRate = 5f;

        [SerializeField]
        [ColorUsage( true, true )]
        private Color fullCharge;

        [SerializeField]
        [ColorUsage( true, true )]
        private Color medCharge;

        [SerializeField]
        [ColorUsage( true, true )]
        private Color lowCharge;

        private MaterialPropertyBlock mpb;

        private void Awake()
        {
            mpb = new MaterialPropertyBlock();
        }

        public override void OnStartServer()
        {
            base.OnStartServer();

            shield.OnBlocked += Shield_OnBlocked;
        }

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            if ( shieldActionRef != null )
            {
                shieldAction = PlayerInputManager.Instance.Controls.FindAction( shieldActionRef.action.id );

                shieldAction.performed += ShieldAction_Performed;

                shieldAction.canceled += ShieldAction_Canceled;
            }
        }

        private void Shield_OnBlocked( int damage, float forceScale )
        {
            UpdateShieldCharge( -( damage * shieldDamageDecayScale * forceScale ) );
        }

        private void ShieldAction_Performed( InputAction.CallbackContext obj )
        {
            CmdToggleShield( true );
        }

        private void ShieldAction_Canceled( InputAction.CallbackContext obj )
        {
            CmdToggleShield( false );
        }

        private void ToggleShield( bool toggle )
        {
            shield.gameObject.SetActive( toggle );

            shieldActive = toggle;
        }

        [Command]
        private void CmdToggleShield( bool toggle )
        {
            if ( toggle && !shieldActive && shieldCharge > 0 )
            {
                if ( isServerOnly )
                    ToggleShield( true );

                ClientToggleShield( true );
            }
            else if ( !toggle )
            {
                if ( isServerOnly )
                    ToggleShield( false );

                ClientToggleShield( false );
            }
        }

        [ClientRpc]
        private void ClientToggleShield( bool toggle )
        {
            UpdateShieldVisual();

            ToggleShield( toggle );

            if ( toggle )
            {
                player.ToggleMitigationSource( true, this, 0.5f );
            }
            else
            {
                player.ToggleMitigationSource( false, this, 0.5f );
            }
        }

        protected override void Update()
        {
            base.Update();

            if ( shieldActive )
            {
                if ( isServer )
                    UpdateShieldCharge( -shieldUseDecay * Time.deltaTime );

                UpdateShieldVisual();
            }
            else if ( shieldCharge < 100 )
            {
                if ( isServer )
                    UpdateShieldCharge( shieldRechargeRate * Time.deltaTime );
            }

            if ( isServer && shieldCharge == 0 )
            {
                ToggleShield( false );

                ClientToggleShield( false );
            }
        }

        private void UpdateShieldCharge( float delta )
        {
            shieldCharge = Mathf.Clamp( shieldCharge + delta, 0, 100 );
        }

        private void UpdateShieldVisual()
        {
            mpb.SetColor( "_BaseColor", Color.Lerp( Color.Lerp( lowCharge, medCharge, shieldCharge / 50f ), fullCharge, ( shieldCharge - 50f ) / 50f ) );
            mpb.SetColor( "_EmissionColor", Color.Lerp( Color.Lerp( lowCharge, medCharge, shieldCharge / 50f ), fullCharge, ( shieldCharge - 50f ) / 50f ) );

            shield.Renderer.SetPropertyBlock( mpb );
        }
    }
}
