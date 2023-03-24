using CapsuleHands.Singleton;
using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CapsuleHands.PlayerCore
{
    public class PlayerAiming : PlayerComponentBase
    {
        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference elevationActionRef;
        private InputAction elevationAction;

        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference precisionActionRef;
        private InputAction precisionAction;

        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference lookActionRef;
        private InputAction lookAction;

        [SerializeField] private float turnSpeed = 540f;

        [SerializeField] private Transform elevationAimTarget;

        private LayerMask cachedGroundMask;

        public bool ElevatedAiming { get; private set; } = false;

        private Vector3 lookInput = Vector3.zero;

        private Vector3 lookTargetLocation;

        private Vector3 toLookTargetNormalized = Vector3.zero;

        private RaycastHit raycastHit;

        private bool mouseActive = false;

        private Vector2 controllerAimCursorPosition = Vector2.zero;

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            cachedGroundMask = Constants.Arena.MouseCastLayerMask;

            AimManager.Instance.Register( this );

            elevationAimTarget.SetParent( null );

            if ( elevationActionRef != null )
            {
                elevationAction = PlayerInputManager.Instance.Controls.FindAction( elevationActionRef.action.id );

                elevationAction.performed += ElevationAction_Performed;

                elevationAction.canceled += ElevationAction_Canceled;
            }
            else
            {
                Debug.LogError( "PlayerMovement is missing an Elevation Action Ref." );
            }

            if ( lookActionRef != null )
            {
                lookAction = PlayerInputManager.Instance.Controls.FindAction( lookActionRef.action.id );
            }
            else
            {
                Debug.LogError( "PlayerMovement is missing a Look Action Ref." );
            }

            if ( precisionActionRef != null )
            {
                precisionAction = PlayerInputManager.Instance.Controls.FindAction( precisionActionRef.action.id );
            }
            else
            {
                Debug.LogError( "PlayerMovement is missing a Look Action Ref." );
            }
        }

        private void ElevationAction_Performed( InputAction.CallbackContext context )
        {
            controllerAimCursorPosition = player.MainCamera.WorldToScreenPoint( player.transform.position + player.transform.forward * 5f );
        }

        private void ElevationAction_Canceled( InputAction.CallbackContext context )
        {
            elevationAimTarget.gameObject.SetActive( false );
        }

        protected override void LocalPlayerUpdate()
        {
            base.LocalPlayerUpdate();

            lookInput = lookAction.ReadValue<Vector2>();

            ElevatedAiming = elevationAction.ReadValue<float>() > 0.5f;
        }

        protected override void LocalPlayerFixedUpdate()
        {
            base.LocalPlayerFixedUpdate();

            if ( player != null )
            {
                LayerMask currentMask = cachedGroundMask;

                if ( ElevatedAiming )
                {
                    currentMask |= Constants.Arena.EnvironmentLayerMask;
                }

                if ( PlayerInputManager.Instance.IsKeyboard )
                {
                    if ( Physics.Raycast( player.MainCamera.ScreenPointToRay( lookInput ), out raycastHit, 100f, currentMask ) )
                    {
                        lookTargetLocation = raycastHit.point;
                    }
                }
                else
                {
                    if ( ElevatedAiming )
                    {
                        controllerAimCursorPosition += ( Vector2 ) lookInput * 20f;

                        controllerAimCursorPosition.x = Mathf.Clamp( controllerAimCursorPosition.x, 0, Screen.width );

                        controllerAimCursorPosition.y = Mathf.Clamp( controllerAimCursorPosition.y, 0, Screen.height );

                        if ( Physics.Raycast( player.MainCamera.ScreenPointToRay( controllerAimCursorPosition ), out raycastHit, 100f, currentMask ) )
                        {
                            lookTargetLocation = raycastHit.point;

                            elevationAimTarget.position = lookTargetLocation;

                            if ( !elevationAimTarget.gameObject.activeSelf )
                            {
                                elevationAimTarget.gameObject.SetActive( true );
                            }
                        }
                    }
                    else
                    {
                        if ( lookInput.sqrMagnitude > 0.01f )
                        {
                            lookInput.z = lookInput.y;

                            lookInput.y = 0;

                            lookInput.Normalize();

                            lookTargetLocation = player.transform.position + Quaternion.Euler( 0, player.MainCamera.transform.eulerAngles.y, 0 ) * lookInput * 5f;
                        }
                        else
                        {
                            lookTargetLocation = player.transform.position + player.transform.forward * 5f;
                        }
                    }
                }

                toLookTargetNormalized = ( lookTargetLocation - player.transform.position ).normalized;

                toLookTargetNormalized.y = 0;

                player.transform.rotation = Quaternion.RotateTowards( player.transform.rotation, Quaternion.LookRotation( toLookTargetNormalized, Vector3.up ), turnSpeed * Time.fixedDeltaTime );

                if ( ElevatedAiming )
                {
                    player.GroundTarget.position = lookTargetLocation;
                }
                else
                {
                    player.GroundTarget.position = player.transform.position + player.transform.forward * 5f;
                }

                player.GetAimTarget( ElevatedAiming );
            }
        }

        private void OnDestroy()
        {
            if ( isLocalPlayer )
            {
                AimManager.Instance.UnRegister( this );

                if ( elevationAction != null )
                {
                    elevationAction.performed -= ElevationAction_Performed;

                    elevationAction.canceled -= ElevationAction_Canceled;
                }
            }
        }
    }
}
