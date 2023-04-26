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

        private float defaultDrag = 0f;

        public CapsuleCollider Collider { get; private set; }

        public Animator Animator { get; private set; }

        public PlayerData Data { get; private set; }

        [SerializeField] private bool startActive = false;

        [SerializeField] private Transform graphicsRoot;

        [SerializeField] private SkinnedMeshRenderer primaryRenderer;

        private MaterialPropertyBlock mpb;

        [SerializeField] private ParticleSystem knockbackSmokeFX;

        [SerializeField] private ParticleSystem playerHitFX;

        [SerializeField] private float hoverHeight;
        public float HoverHeight => hoverHeight;

        public float BotControl { get; private set; } = 1f;

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

        private Dictionary<object, float> mitigationSources = new Dictionary<object, float>();

        [SyncVar( hook = nameof( OnColorUpdated ) )]
        private int playerColor = 0;
        public int PlayerColor => playerColor;

        [SyncVar]
        private Vector3 spawn;

        [SerializeField] private ParticleSystem spawnEffect;

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

        public Action OnUIRefresh;

        public Camera MainCamera { get; private set; }

        public void GetAimTarget( bool elevation )
        {
            float groundToAimDist = hoverHeight + Gun.localPosition.y + 0.15f;// / ( Mathf.Sin( Mathf.Deg2Rad * MainCamera.transform.eulerAngles.x ) );
            //( MainCamera.transform.position - groundTarget.position ).normalized
            AimTarget = groundTarget.position + Vector3.up * ( elevation ? Mathf.Lerp( groundToAimDist, groundToAimDist * 0.5f, Mathf.Clamp( ( transform.position.y - groundToAimDist ) - groundTarget.position.y, 0f, 1f ) ) : 0f );
        }

        private void Awake()
        {
            Rigidbody = GetComponent<Rigidbody>();

            defaultDrag = Rigidbody.drag;

            Collider = GetComponent<CapsuleCollider>();

            Animator = graphicsRoot.GetComponentInChildren<Animator>();

            MainCamera = CameraManager.Instance.GetComponentInChildren<Camera>();

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

                if ( Camera.main != null ) //TODO, move to scene load logic
                {
                    Camera.main.gameObject.SetActive( false );
                }
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
            {
                UpdateDamage( damage );

                PlayPlayerHit();

                if ( forceScale * ( Damage / 4 ) > 20f )
                {
                    PlayKnockbackSmoke();
                }
            }

            if ( isLocalPlayer )
            {
                if ( hitDirection.sqrMagnitude != 1 )
                    hitDirection.Normalize();

                float totalMitigation = 0f;

                if ( mitigationSources.Count > 0 )
                {
                    foreach ( float mitValue in mitigationSources.Values )
                        totalMitigation += mitValue;
                }

                float knockbackForce = forceScale * ( Damage / 5f );

                if ( knockbackForce > 15f )
                {
                    CameraManager.Instance.ApplyShake( Mathf.Lerp( 1, 4, ( knockbackForce - 15f ) / 30f ), 0.5f );
                }

                if ( knockBackCo != null )
                {
                    StopCoroutine( knockBackCo );
                }

                StartCoroutine( KnockbackRoutine( Mathf.Lerp( 0, 0.1f, knockbackForce / 15f ) ) );

                Rigidbody.AddForce( ( knockbackForce * hitDirection ) * ( 1 - totalMitigation ), ForceMode.Impulse );
            }
        }

        private Coroutine knockBackCo;

        private IEnumerator KnockbackRoutine( float returnTime )
        {
            BotControl = 0.25f;

            Rigidbody.drag = defaultDrag * 0.25f;

            yield return new WaitForSeconds( 0.25f );

            float t = 0;

            while ( t < returnTime )
            {
                Rigidbody.drag = Mathf.Lerp( defaultDrag * 0.25f, defaultDrag, t / 0.25f );

                t += Time.deltaTime;

                yield return null;
            }

            Rigidbody.drag = defaultDrag;

            BotControl = 1f;

            knockBackCo = null;
        }

        public void ToggleMitigationSource( bool isAdding, object source, float mitPercentage )
        {
            if ( isAdding )
            {
                if ( mitigationSources.ContainsKey( source ) )
                {
                    mitigationSources[source] = mitPercentage;
                }
                else
                {
                    mitigationSources.Add( source, mitPercentage );
                }
            }
            else if ( mitigationSources.ContainsKey( source ) )
            {
                mitigationSources.Remove( source );
            }
        }

        public void UpdateDamage( float delta )
        {
            damage = Mathf.Max( 0, damage + delta );
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

        public Action OnPlayerReset;

        [Server]
        public void OnServerPlayerReset( Vector3 resetSpawn )
        {
            ToggleActive( false );

            damage = 0;

            eliminated = false;

            if ( isServerOnly )
                OnPlayerReset?.Invoke();

            OnClientPlayerReset( resetSpawn );
        }

        [ClientRpc]
        public void OnClientPlayerReset( Vector3 resetSpawn )
        {
            graphicsRoot.gameObject.SetActive( true );

            if ( isLocalPlayer )
            {
                Rigidbody.velocity = Vector3.zero;

                transform.position = resetSpawn;

                Vector3 pos = transform.position;

                pos.y = 0;

                transform.rotation = Quaternion.LookRotation( -pos, Vector3.up );

                Rigidbody.isKinematic = false;

                Rigidbody.collisionDetectionMode = CollisionDetectionMode.Continuous;

                groundTarget.position = Vector3.zero;
            }

            spawnEffect.transform.position = resetSpawn;

            spawnEffect.Play();

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

        [Server]
        public void OnServerHideForMapLoad()
        {
            ToggleActive( false );

            OnClientPlayerEliminated();
        }

        [ClientRpc]
        private void PlayKnockbackSmoke()
        {
            if ( knockbackSmokeFX != null )
            {
                knockbackSmokeFX.Play();
            }
        }

        [ClientRpc]
        private void PlayPlayerHit()
        {
            if ( playerHitFX != null )
            {
                playerHitFX.Play();
            }
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
        }
#endif
    }

    public class PlayerAnimationParams
    {
        public const string MoveX = "MoveX";

        public const string MoveZ = "MoveZ";
    }
}
