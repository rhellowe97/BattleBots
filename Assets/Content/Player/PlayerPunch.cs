using CapsuleHands.UI;
using Mirror;
using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CapsuleHands.PlayerCore
{
    public class PlayerPunch : PlayerComponentBase
    {
        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference punchActionRef;
        private InputAction punchAction;

        [SerializeField] private float dashImpulse = 10f;

        [SerializeField] private float dashDuration = 0.5f;

        [SerializeField] private int damage = 7;

        [SerializeField] private float forceScale = 1f;

        [SerializeField] private int charges = 3;

        [SerializeField] private float cooldown = 4;

        public int chargeCount { get; private set; } = 0;

        [SerializeField] private PunchUI punchUI;

        [SerializeField] private AudioSource punchAudio;

        [SerializeField] private ParticleSystem punchEffect;

        [SerializeField] private BoxCollider hitBox;

        private WaitForSeconds punchWait;

        public float punchTimer { get; private set; } = 0f;

        public bool PunchActive { get; private set; } = false;

        private void Start()
        {
            punchWait = new WaitForSeconds( dashDuration );

            chargeCount = 3;
        }

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            if ( punchActionRef != null )
            {
                punchAction = PlayerInputManager.Instance.Controls.FindAction( punchActionRef.action.id );

                punchAction.performed += PunchAction_Performed;

                punchTimer = cooldown;

                PlayerUIManager.Instance.AddUIElement( PlayerUIManager.UILocation.TopRight, punchUI.transform );

                punchUI.gameObject.SetActive( true );
            }
        }

        private IEnumerator ChargeRoutine()
        {
            PunchActive = true;

            yield return punchWait;

            PunchActive = false;
        }

        public void Punch( float passedTime )
        {
            if ( isLocalPlayer )
            {
                player.Rigidbody.AddForce( player.MoveDirection * dashImpulse, ForceMode.Impulse );

                player.ReduceDrag( dashDuration );

                if ( chargeCount == charges )
                    punchTimer = 0f;

                chargeCount--;
            }

            if ( punchEffect != null )
                punchEffect.Play();

            if ( punchAudio != null )
                punchAudio.Play();

            StartCoroutine( ChargeRoutine() );
        }

        private Dictionary<PlayerPunch, double> hitTimes = new Dictionary<PlayerPunch, double>();

        private void OnCollisionEnter( Collision collision )
        {
            if ( collision.collider.attachedRigidbody != null && collision.collider.attachedRigidbody.TryGetComponent( out PlayerPunch otherPlayerPunch ) )
            {
                if ( otherPlayerPunch.PunchActive && !( hitTimes.ContainsKey( otherPlayerPunch ) && ( NetworkTime.time - hitTimes[otherPlayerPunch] ) < 1 ) )
                {
                    player.GetHit( damage, forceScale, ( player.transform.position - collision.collider.transform.position ).normalized );

                    if ( !hitTimes.ContainsKey( otherPlayerPunch ) )
                    {
                        hitTimes.Add( otherPlayerPunch, NetworkTime.time );
                    }
                    else
                    {
                        hitTimes[otherPlayerPunch] = NetworkTime.time;
                    }
                }
            }
        }

        [Command]
        private void ServerPunch( float networkTime )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME / 2f, passedTime );

            ClientPunch( networkTime );
        }

        [ClientRpc( includeOwner = false )]
        private void ClientPunch( float networkTime )
        {
            float passedTime = ( float ) ( NetworkTime.time - networkTime );

            passedTime = Mathf.Min( MAX_PASSED_TIME, passedTime );

            Punch( passedTime );
        }

        private const float MAX_PASSED_TIME = 0.3f;

        protected override void LocalPlayerUpdate()
        {
            base.LocalPlayerUpdate();

            if ( chargeCount < charges )
            {
                punchTimer += Time.deltaTime;

                if ( punchTimer >= cooldown )
                {
                    chargeCount++;

                    if ( chargeCount < charges )
                        punchTimer = 0f;
                    else
                        punchTimer = cooldown;

                }
            }

            punchUI.Refresh( punchTimer / cooldown, chargeCount );
        }

        private void PunchAction_Performed( InputAction.CallbackContext context )
        {
            if ( player.Active && chargeCount > 0 )
            {
                Punch( 0f );

                ServerPunch( ( float ) NetworkTime.time );
            }
        }

        private void OnDestroy()
        {
            if ( punchAction != null )
            {
                punchAction.performed -= PunchAction_Performed;
            }

            if ( isLocalPlayer && PlayerUIManager.Exists )
            {
                PlayerUIManager.Instance.RemoveUIElement( PlayerUIManager.UILocation.TopRight, punchUI.transform );
            }
        }
    }
}
