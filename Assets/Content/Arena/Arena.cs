using CapsuleHands.Singleton;
using Mirror;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;
using System.Linq;

public class Arena : MonoBehaviour
#if UNITY_EDITOR
    , ISerializationCallbackReceiver
#endif
{
    private float OUT_HEIGHT = 100f;

    [SerializeField] private Transform worldRoot;

    [BoxGroup( "Player Spawn" )]
    [SerializeField] private Transform playerSpawnParent;

    [BoxGroup( "Player Spawn" ), ReadOnly]
    [SerializeField] public List<Transform> PlayerSpawns = new List<Transform>();

    [BoxGroup( "Pickup Spawn" )]
    [SerializeField] private Transform pickupSpawnParent;

    [BoxGroup( "Pickup Spawn" ), ReadOnly]
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

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        for ( int i = 0; i < PlayerSpawns.Count; i++ )
        {
            if ( PlayerSpawns[i] == null )
                continue;

            Color c = Color.red;

            switch ( i )
            {
                case 1:
                    c = Color.blue;
                    break;
                case 2:
                    c = Color.yellow;
                    break;
                case 3:
                    c = Color.green;
                    break;
            }

            GizmoHelper.DrawSphere( PlayerSpawns[i].position, 0.5f, c, 0.7f );
        }

        foreach ( Transform pickupSpawn in PickupSpawns )
        {
            if ( pickupSpawn == null )
                continue;

            GizmoHelper.DrawSphere( pickupSpawn.position, 0.4f, Color.magenta, 0.7f );
        }
    }

    public void OnBeforeSerialize()
    {
        if ( playerSpawnParent != null )
        {
            PlayerSpawns = playerSpawnParent.GetComponentsInChildren<Transform>().ToList();

            PlayerSpawns.Remove( playerSpawnParent );
        }

        if ( pickupSpawnParent != null )
        {
            PickupSpawns = pickupSpawnParent.GetComponentsInChildren<Transform>().ToList();

            PickupSpawns.Remove( pickupSpawnParent );
        }
    }

    public void OnAfterDeserialize()
    {

    }
#endif
}
