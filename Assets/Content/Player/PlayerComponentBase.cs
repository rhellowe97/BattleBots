using Mirror;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore
{
    [RequireComponent( typeof( Player ) )]
    public abstract class PlayerComponentBase : NetworkBehaviour
    {
        protected Player player;

        public override void OnStartClient()
        {
            base.OnStartClient();

            player = GetComponent<Player>();

            if ( player.isLocalPlayer )
                LocalPlayerStart();
        }

        protected virtual void LocalPlayerStart()
        {

        }

        protected virtual void LocalPlayerUpdate()
        {

        }

        protected virtual void Update()
        {
            if ( isLocalPlayer )
                LocalPlayerUpdate();
        }

        protected virtual void LocalPlayerFixedUpdate()
        {

        }

        protected virtual void FixedUpdate()
        {
            if ( isLocalPlayer )
                LocalPlayerFixedUpdate();
        }
    }
}
