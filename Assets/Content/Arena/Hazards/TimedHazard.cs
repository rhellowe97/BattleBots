using Mirror;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.Arena.Hazards
{
    public abstract class TimedHazardBase : HazardBase
    {
        [SerializeField] private float cooldown = 10f;

        [SerializeField] private float duration = 5f;

        private float timer = 0f;

        private void Update()
        {
            if ( timer >= cooldown )
            {
                timer = 0f;

                StartCoroutine( HazardSequence( 0 ) );

                ClientPlayHazard( (float)NetworkTime.time );
            }
        }

        [ClientRpc]
        private void ClientPlayHazard( float networkTime )
        {
            StartCoroutine( HazardSequence( networkTime ) );
        }

        protected IEnumerator HazardSequence( float networkTime )
        {
            float t = duration - networkTime;

            HazardBegin();

            while ( t > 0 )
            {
                HazardTick( Time.deltaTime );

                t -= Time.deltaTime;

                yield return null;
            }

            HazardEnd();
        }

        protected virtual void HazardBegin()
        {

        }

        protected virtual void HazardTick( float deltaTime )
        {

        }

        protected virtual void HazardEnd()
        {

        }
    }
}