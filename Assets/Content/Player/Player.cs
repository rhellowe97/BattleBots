using CapsuleHands.Data;
using CapsuleHands.Singleton;
using CapsuleHands.UI;
using Cinemachine;
using Mirror;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore
{
    public class Player : NetworkBehaviour, IHittable
    {
        public Rigidbody Rigidbody { get; private set; }

        public CapsuleCollider Collider { get; private set; }

        public PlayerData Data { get; private set; }

        [SerializeField] private bool startActive = false;

        [SerializeField] private Transform graphicsRoot;

        [SerializeField] private MeshRenderer primaryRenderer;

        private MaterialPropertyBlock mpb;

        [SyncVar( hook = nameof( OnNameUpdated ) )]
        private string playerName = "Player";

        public string PlayerName => playerName;

        [SyncVar]
        private bool active = false;
        public bool Active => active;

        [SyncVar( hook = nameof( OnEliminationUpdated ) )]
        private bool eliminated = false;
        public bool Eliminated => eliminated;

        [SyncVar( hook = nameof( OnDamageUpdated ) )]
        private float damage = 0;
        public float Damage => damage;

        [SyncVar( hook = nameof( OnColorUpdated ) )]
        private int playerColor = 0;
        public int PlayerColor => playerColor;

        [SyncVar]
        private Vector3 spawn;

        #region Grounding

        public bool IsGrounded => validGroundCast || groundContacts.Count > 0;

        private bool validGroundCast = false;

        private RaycastHit[] cachedRaycastBuffer = new RaycastHit[1];

        private HashSet<Collider> groundContacts = new HashSet<Collider>();

        private LayerMask cachedGroundMask;

        private Vector3 spawnLocation;

        [SerializeField] private float groundCheckOffset = 0.2f;

        [SerializeField] private float groundCheckDistance = 0.2f;

        #endregion

        [SerializeField] private Transform gun;
        public Transform Gun => gun;

        [SerializeField] private Transform groundTarget;
        public Transform GroundTarget => groundTarget;

        public Vector3 AimTarget { get; private set; }

        private void GetAimTarget()
        {
            float groundToAimDist = gun.localPosition.y / ( Mathf.Sin( Mathf.Deg2Rad * mainCamera.transform.eulerAngles.x ) );

            AimTarget = groundTarget.position + ( mainCamera.transform.position - groundTarget.position ).normalized * Mathf.Lerp( groundToAimDist, 0.4f, Mathf.Clamp( transform.position.y - groundTarget.position.y, 0, 1 ) );
        }

        public Action OnUIRefresh;

        private Camera mainCamera;

        private void Awake()
        {
            Rigidbody = GetComponent<Rigidbody>();

            Collider = GetComponent<CapsuleCollider>();

            mainCamera = Camera.main;

            if ( startActive )
            {
                active = true;
            }
        }

        [Server]
        public void AssignColor( int colorIndex )
        {
            playerColor = colorIndex;
        }

        [Server]
        public void AssignSpawn( Vector3 spawn )
        {
            this.spawn = spawn;
        }

        private void OnColorUpdated( int oldColor, int newColor )
        {
            if ( mpb == null )
                mpb = new MaterialPropertyBlock();

            mpb.SetColor( "_BaseColor", Constants.Arena.PlayerColors[newColor] );

            primaryRenderer.SetPropertyBlock( mpb );

            OnUIRefresh?.Invoke();
        }

        private void Start()
        {
            cachedGroundMask = Constants.Arena.EnvironmentLayerMask;
        }

        public override void OnStartClient()
        {
            base.OnStartClient();

            if ( isLocalPlayer )
            {
                InitializePlayerData( GameManager.Instance.PlayerData );

                spawnLocation = transform.position;
            }

            CameraManager.Instance.SubscriptionUpdate( this, true );

            PlayerUIManager.Instance.SubscriptionUpdate( this, true );
        }

        [Command]
        private void InitializePlayerData( PlayerData data )
        {
            Data = data;

            playerName = data.PlayerName;

            ClientSetPlayerData( data );
        }

        [ClientRpc]
        private void ClientSetPlayerData( PlayerData data )
        {
            Data = data;

            OnUIRefresh?.Invoke();
        }

        public override void OnStopClient()
        {
            base.OnStopClient();

            if ( PlayerUIManager.Exists )
            {
                PlayerUIManager.Instance.SubscriptionUpdate( this, false );
            }
        }

        private void OnPlayerDataChanged( PlayerData oldData, PlayerData newData )
        {
            OnUIRefresh?.Invoke();
        }

        private void FixedUpdate()
        {
            if ( !isLocalPlayer )
                return;

            validGroundCast = Physics.RaycastNonAlloc(
                transform.position + Vector3.up * groundCheckOffset,
                Vector3.down,
                cachedRaycastBuffer,
                groundCheckDistance + groundCheckOffset,
                cachedGroundMask
                ) > 0;

            if ( validGroundCast )
            {
                transform.position = cachedRaycastBuffer[0].point;
            }

            GetAimTarget();
        }

        private void Update()
        {
            if ( !isLocalPlayer )
                return;
        }

        private void OnCollisionEnter( Collision collision )
        {
            if ( !groundContacts.Contains( collision.collider ) && collision.contacts[0].point.y < transform.position.y + groundCheckOffset )
            {
                groundContacts.Add( collision.collider );
            }
        }

        private void OnCollisionStay( Collision collision )
        {
            if ( groundContacts.Contains( collision.collider ) && collision.contacts[0].point.y > transform.position.y + groundCheckOffset )
            {
                groundContacts.Remove( collision.collider );
            }
        }

        private void OnCollisionExit( Collision collision )
        {
            if ( groundContacts.Contains( collision.collider ) )
            {
                groundContacts.Remove( collision.collider );
            }
        }

        public void GetHit( int damage, float forceScale, Vector3 hitDirection )
        {
            if ( isServer )
                this.damage += damage;

            if ( isLocalPlayer )
                Rigidbody.AddForce( forceScale * ( Damage / 4f ) * hitDirection, ForceMode.Impulse );
        }

        private void OnDamageUpdated( float oldDamage, float newDamage )
        {
            OnUIRefresh?.Invoke();
        }

        private void OnNameUpdated( string oldName, string newName )
        {
            OnUIRefresh?.Invoke();
        }

        private void OnEliminationUpdated( bool oldStatus, bool newStatus )
        {
            OnUIRefresh?.Invoke();
        }

        public void ToggleActive( bool isActive )
        {
            active = isActive;
        }

        private Action OnPlayerReset;

        public void OnServerPlayerReset()
        {
            ToggleActive( false );

            damage = 0;

            eliminated = false;

            OnPlayerReset?.Invoke();

            OnClientPlayerReset();
        }

        [ClientRpc]
        public void OnClientPlayerReset()
        {
            graphicsRoot.gameObject.SetActive( true );

            if ( isLocalPlayer )
            {
                Rigidbody.velocity = Vector3.zero;

                transform.position = spawnLocation;

                Vector3 pos = transform.position;

                pos.y = 0;

                transform.rotation = Quaternion.LookRotation( -pos, Vector3.up );

                Rigidbody.isKinematic = false;

                Rigidbody.collisionDetectionMode = CollisionDetectionMode.Continuous;

                groundTarget.position = Vector3.zero;

                GetAimTarget();
            }

            CameraManager.Instance.SubscriptionUpdate( this, true );

            OnPlayerReset?.Invoke();
        }

        public Action OnPlayerEliminated;

        [Server]
        public void OnServerPlayerEliminated()
        {
            if ( !active )
                return;

            ToggleActive( false );

            eliminated = true;

            OnPlayerEliminated?.Invoke();

            OnClientPlayerEliminated();
        }

        [ClientRpc]
        public void OnClientPlayerEliminated()
        {
            graphicsRoot.gameObject.SetActive( false );

            if ( isLocalPlayer )
                Rigidbody.isKinematic = true;

            CameraManager.Instance.SubscriptionUpdate( this, false );
        }

        private void OnDestroy()
        {
            if ( PlayerUIManager.Exists )
            {
                PlayerUIManager.Instance.SubscriptionUpdate( this, false );
            }
        }

#if UNITY_EDITOR
        private void OnDrawGizmos()
        {
            if ( !Application.isPlaying )
                return;

            Gizmos.color = Color.red;

            Gizmos.DrawSphere( GroundTarget.position, 0.3f );

            Gizmos.color = Color.yellow;

            Gizmos.DrawSphere( AimTarget, 0.3f );
        }
#endif
    }
}
