using CapsuleHands.PlayerCore;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.Singleton
{
    public class AimManager : Singleton<AimManager>
    {
        [SerializeField] private Transform mouseCastPlane;

        [SerializeField] private float smoothing = 5f;

        private PlayerAiming controllingPlayer;

        private HashSet<object> locks = new HashSet<object>();

        public void Register( PlayerAiming move )
        {
            if ( controllingPlayer == null )
            {
                controllingPlayer = move;
            }
        }

        public void UnRegister( PlayerAiming move )
        {
            if ( controllingPlayer == move )
            {
                controllingPlayer = null;
            }
        }

        public void AddLock( object o )
        {
            locks.Add( 0 );
        }

        public void RemoveLock( object o )
        {
            if ( locks.Contains( 0 ) )
            {
                locks.Remove( 0 );
            }
        }

        private void Update()
        {
            mouseCastPlane.transform.position = ( locks.Count > 0 || ( controllingPlayer == null || controllingPlayer.ElevatedAiming ) ) ? Vector3.zero : Vector3.up * controllingPlayer.transform.position.y;
        }
    }
}
