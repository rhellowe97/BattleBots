using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore
{
    public class Shield : MonoBehaviour, IHittable
    {
        [SerializeField]
        private new MeshRenderer renderer;
        public MeshRenderer Renderer => renderer;

        public Action<int, float> OnBlocked;

        public void GetHit( int damage, float forceScale, Vector3 hitDirection )
        {
            OnBlocked?.Invoke( damage, forceScale );
        }
    }
}
