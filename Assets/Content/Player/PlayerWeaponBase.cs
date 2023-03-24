using UnityEngine;

namespace CapsuleHands.PlayerCore.Weapons
{
    public abstract class PlayerWeaponBase : MonoBehaviour, IHitConfigurable
    {
        [SerializeField] protected WeaponData data;
        public WeaponData Data => data;

        [SerializeField] protected Transform source;
        public Transform Source => source;

        [SerializeField] protected GameObject projectilePrefab;

        [SerializeField] protected AudioSource shotAudio;

        [SerializeField] protected ParticleSystem shotEffect;

        public bool Active { get; private set; }

        protected LayerMask targetLayerMask;

        protected IHittable owner;

        private void Awake()
        {
            Setup();
        }

        public virtual void Setup()
        {
      
        }

        public void Configure( IHittable owner, LayerMask targetLayerMask )
        {
            this.owner = owner;
            this.targetLayerMask = targetLayerMask;
        }

        public virtual void Shoot( Vector3 position, Vector3 direction, float passedTime )
        {
            if ( shotAudio != null )
                shotAudio.Play();

            if ( shotEffect != null )
                shotEffect.Play();
        }

        public virtual void UpdateAim( Player player )
        {

        }

        public virtual void Activate( float passedTime )
        {
            Active = true;
        }

        public virtual void Release( float passedTime )
        {
            Deactivate();
        }

        public virtual void Deactivate()
        {
            Active = false;
        }

        public virtual bool CanShoot()
        {
            return true;
        }

        public virtual Vector3 GetAimDirection( Player player )
        {
            return player.AimTarget - source.position;
        }

        public virtual void Equip()
        {

        }

        public virtual void Eject()
        {

        }
    }
}
