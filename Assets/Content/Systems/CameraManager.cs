using CapsuleHands.PlayerCore;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

namespace CapsuleHands.Singleton
{
    public class CameraManager : Singleton<CameraManager>
    {
        [SerializeField] private CinemachineVirtualCamera mainVirtualCamera;

        private CinemachineBasicMultiChannelPerlin cameraNoise;

        [SerializeField] private CinemachineTargetGroup targetGroup;

        private HashSet<Player> activePlayers = new HashSet<Player>();

        protected override void Awake()
        {
            base.Awake();

            if ( mainVirtualCamera != null )
            {
                cameraNoise = mainVirtualCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
            }
        }

        public void SubscriptionUpdate( Player player, bool subscribe )
        {
            if ( subscribe && !activePlayers.Contains( player ) )
            {
                activePlayers.Add( player );

                targetGroup.AddMember( player.transform, 2, 1 );
            }
            else if ( !subscribe && activePlayers.Contains( player ) )
            {
                activePlayers.Remove( player );

                targetGroup.RemoveMember( player.transform );
            }
        }

        private Coroutine shakeCo;

        public void ApplyShake( float amplitude, float duration )
        {
            if ( cameraNoise == null )
                return;

            if ( shakeCo != null )
            {
                StopCoroutine( shakeCo );
            }

            shakeCo = StartCoroutine( ShakeRoutine( amplitude, duration ) );
        }

        private IEnumerator ShakeRoutine( float amplitude, float duration )
        {
            cameraNoise.m_AmplitudeGain = amplitude;

            float t = 0;

            while ( t < duration )
            {
                cameraNoise.m_AmplitudeGain = Mathf.Lerp( amplitude, 0, t / duration );

                t += Time.deltaTime;

                yield return null;
            }

            cameraNoise.m_AmplitudeGain = 0;

            shakeCo = null;
        }
    }
}
