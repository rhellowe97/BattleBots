using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CapsuleHands.PlayerCore
{
    public class PlayerMovement : PlayerComponentBase
    {
        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference moveActionRef;
        private InputAction moveAction;

        [BoxGroup( "Input" )]
        [SerializeField] private InputActionReference lookActionRef;
        private InputAction lookAction;

        [SerializeField] private float acceleration = 50f;

        [SerializeField] private float moveSpeed = 8f;

        [SerializeField] private float turnSpeed = 540f;

        [SerializeField] private float gravityScale = 1f;

        private LayerMask cachedGroundMask;

        private Camera mainCamera;

        private bool setupSuccessful = true;

        private Vector3 moveInput = Vector3.zero;

        private Vector2 lookInput = Vector2.zero;

        private Vector3 lookTargetLocation;

        private Vector3 toLookTargetNormalized = Vector3.zero;

        private RaycastHit raycastHit;

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            cachedGroundMask = Constants.Arena.MouseCastLayerMask;

            mainCamera = Camera.main;

            player.Rigidbody.useGravity = false;

            if ( moveActionRef != null )
            {
                moveAction = PlayerInputManager.Instance.Controls.FindAction( moveActionRef.action.id );
            }
            else
            {
                Debug.LogError( "PlayerMovement is missing a Move Action Ref." );

                setupSuccessful = false;
            }

            if ( lookActionRef != null )
            {
                lookAction = PlayerInputManager.Instance.Controls.FindAction( lookActionRef.action.id );
            }
            else
            {
                Debug.LogError( "PlayerMovement is missing a Look Action Ref." );

                setupSuccessful = false;
            }
        }

        protected override void LocalPlayerUpdate()
        {
            base.LocalPlayerUpdate();

            if ( setupSuccessful && player.Active )
            {
                moveInput = moveAction.ReadValue<Vector2>();

                moveInput.z = moveInput.y;

                moveInput.y = 0;

                lookInput = lookAction.ReadValue<Vector2>();
            }
            else
            {
                moveInput = Vector3.zero;
            }
        }

        protected override void LocalPlayerFixedUpdate()
        {
            base.LocalPlayerFixedUpdate();

            if ( player != null && setupSuccessful )
            {
                if ( Physics.Raycast( mainCamera.ScreenPointToRay( lookInput ), out raycastHit, 100f, cachedGroundMask ) )
                {
                    lookTargetLocation = raycastHit.point;
                }

                player.GroundTarget.position = lookTargetLocation;

                toLookTargetNormalized = ( lookTargetLocation - player.transform.position ).normalized;

                if ( player.Rigidbody.velocity.sqrMagnitude >= moveSpeed * moveSpeed )
                {
                    Vector3 vel = player.Rigidbody.velocity;

                    vel.y = 0; //Only care about checking xz velocity against input

                    vel.Normalize();

                    float inputVelocityDot = Vector3.Dot( moveInput, vel );

                    if ( inputVelocityDot > 0 )
                        moveInput -= Vector3.Project( moveInput, vel );
                }

                player.Rigidbody.AddForce( Quaternion.Euler( 0, mainCamera.transform.eulerAngles.y, 0 ) * moveInput * acceleration, ForceMode.VelocityChange );

                toLookTargetNormalized.y = 0;

                player.transform.rotation = Quaternion.RotateTowards( player.transform.rotation, Quaternion.LookRotation( toLookTargetNormalized, Vector3.up ), turnSpeed * Time.fixedDeltaTime );

                if ( !player.IsGrounded )
                {
                    player.Rigidbody.AddForce( Vector3.down * 9.81f * gravityScale );
                }
            }
        }
    }
}
