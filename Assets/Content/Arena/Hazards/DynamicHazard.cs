using Mirror;
using Sirenix.OdinInspector;
using UnityEngine;

namespace CapsuleHands.Arena.Hazards
{
    public class DynamicHazard : HazardBase
    {
        private Vector3 startPosition;

        private Quaternion startRotation;

        [BoxGroup( "Translator" )]
        [SerializeField] private bool translator = false;

        [BoxGroup( "Translator" ), ShowIf( nameof( translator ) )]
        [SerializeField] private Vector3 direction;

        [BoxGroup( "Translator" ), ShowIf( nameof( translator ) )]
        [SerializeField] private float distance;

        [BoxGroup( "Translator" ), ShowIf( nameof( translator ) )]
        [SerializeField] private float speed;

        [BoxGroup( "Rotator" )]
        [SerializeField] private bool rotator = false;

        [BoxGroup( "Rotator" ), ShowIf( nameof( rotator ) )]
        [SerializeField] private Vector3 localAxis;

        [BoxGroup( "Rotator" ), ShowIf( nameof( rotator ) )]
        [SerializeField] private float rotationSpeed = 30f;

        private void Awake()
        {
            startPosition = transform.position;

            startRotation = transform.localRotation;

            direction.Normalize();
        }

        private void FixedUpdate()
        {
            if ( translator )
            {
                transform.position = startPosition + direction * ( ( distance * Mathf.Cos( ( float ) NetworkTime.time * speed ) + distance ) / 2 );
            }

            if ( rotator )
            {
                transform.localRotation = startRotation * Quaternion.Euler( localAxis * ( float ) NetworkTime.time * rotationSpeed );
            }
        }
    }
}
