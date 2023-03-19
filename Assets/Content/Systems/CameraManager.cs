using CapsuleHands.PlayerCore;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

namespace CapsuleHands.Singleton
{
    public class CameraManager : Singleton<CameraManager>
    {
        [SerializeField] private CinemachineTargetGroup targetGroup;

        private HashSet<Player> activePlayers = new HashSet<Player>();

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
    }
}
