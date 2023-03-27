using CapsuleHands.Singleton;
using Mirror;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class Arena : MonoBehaviour
{
    private float OUT_HEIGHT = 100f;

    [SerializeField] private Transform worldRoot;

    [SerializeField] public List<Transform> PlayerSpawns = new List<Transform>();

    [SerializeField] public List<Transform> PickupSpawns = new List<Transform>();

    private void Awake()
    {
        //PickupManager.Instance.SetPickupSpawns( PickupSpawns );
    }

    public IEnumerator WorldSlide( bool slideIn )
    {
        if ( slideIn )
        {
            worldRoot.position = Vector3.down * OUT_HEIGHT;

            yield return worldRoot.DOMoveY( 0, 3f ).SetEase( Ease.OutSine );
        }
        else
        {
            yield return worldRoot.DOMoveY( OUT_HEIGHT, 3f ).SetEase( Ease.OutSine );
        }
    }
}
