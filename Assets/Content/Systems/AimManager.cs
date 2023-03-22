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

        private void Update()
        {
            mouseCastPlane.transform.position = Vector3.Slerp( mouseCastPlane.transform.position, ( controllingPlayer == null || controllingPlayer.ElevatedAiming ) ? Vector3.zero : Vector3.up * controllingPlayer.transform.position.y, smoothing * Time.deltaTime );
        }
    }
}
