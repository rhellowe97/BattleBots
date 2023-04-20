using CapsuleHands.Singleton;
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

        [SerializeField] private float acceleration = 50f;

        [SerializeField] private float moveSpeed = 8f;

        [SerializeField] private float gravityScale = 1f;

        [SerializeField] private float heightSmoothing = 3f;

        private Vector3 moveInput = Vector3.zero;

        private RaycastHit raycastHitResult;

        protected override void LocalPlayerStart()
        {
            base.LocalPlayerStart();

            player.Rigidbody.useGravity = false;

            if ( moveActionRef != null )
            {
                moveAction = PlayerInputManager.Instance.Controls.FindAction( moveActionRef.action.id );
            }
            else
            {
                Debug.LogError( "PlayerMovement is missing a Move Action Ref." );
            }
        }

        protected override void LocalPlayerUpdate()
        {
            base.LocalPlayerUpdate();

            if ( player.Active )
            {
                moveInput = moveAction.ReadValue<Vector2>();

                moveInput.z = moveInput.y;

                moveInput.y = 0;
            }
            else
            {
                moveInput = Vector3.zero;
            }
        }

        protected override void LocalPlayerFixedUpdate()
        {
            base.LocalPlayerFixedUpdate();

            if ( player != null )
            {
                Vector3 moveVector = Quaternion.Euler( 0, player.MainCamera.transform.eulerAngles.y, 0 ) * moveInput;

                if ( player.Rigidbody.velocity.sqrMagnitude >= moveSpeed * moveSpeed )
                {
                    Vector3 vel = player.Rigidbody.velocity;

                    vel.y = 0; //Only care about checking xz velocity against input

                    vel.Normalize();

                    float inputVelocityDot = Vector3.Dot( moveVector, vel );

                    if ( inputVelocityDot > 0 )
                        moveVector -= Vector3.Project( moveVector, vel );
                }

                player.Rigidbody.AddForce( moveVector * acceleration, ForceMode.VelocityChange );


                if ( Physics.Raycast( player.transform.position + Vector3.up * 0.1f, Vector3.down, out raycastHitResult, player.HoverHeight + 0.5f, Constants.Arena.EnvironmentLayerMask, QueryTriggerInteraction.Ignore ) )
                {
                    Vector3 position = player.transform.position;

                    position.y = Mathf.Lerp( position.y, raycastHitResult.point.y + player.HoverHeight, heightSmoothing * Time.fixedDeltaTime );

                    player.transform.position = position;
                }
                else
                {
                    player.Rigidbody.AddForce( Vector3.down * 9.81f * gravityScale );
                }

                Vector3 localVel = transform.InverseTransformVector( player.Rigidbody.velocity );

                player.Animator.SetFloat( PlayerAnimationParams.MoveX, localVel.x / moveSpeed, 0.1f, Time.fixedDeltaTime );
                player.Animator.SetFloat( PlayerAnimationParams.MoveZ, localVel.z / moveSpeed, 0.1f, Time.fixedDeltaTime );
            }
        }
    }
}
