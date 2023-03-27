using CapsuleHands.Arena;
using Mirror;
using System.Collections.Generic;
using UnityEngine;

public class PickupManager : NetworkBehaviour
{
    [SerializeField] private float minSpawnTime = 8f;

    [SerializeField] private float maxSpawnTime = 15f;

    [SerializeField] private List<PickupBase> pickupPrefabs = new List<PickupBase>();

    private float currentSpawnTime = 0f;

    private float spawnTimer = 0f;

    public static PickupManager Instance;

    private void Awake()
    {
        if ( Instance != null )
        {
            Destroy( this );

            return;
        }

        Instance = this;

        transform.SetParent( CapsuleNetworkManager.Instance.transform );
    }

    private void Start()
    {
        CapsuleNetworkManager.Instance.OnMatchActiveChanged += CapsuleNetworkManager_OnMatchActiveChanged;

        currentSpawnTime = Random.Range( minSpawnTime, maxSpawnTime );
    }

    //public void SetPickupSpawns( List<Transform> newLocations )
    //{
    //    spawnLocations = newLocations;
    //}

    private void CapsuleNetworkManager_OnMatchActiveChanged()
    {
        if ( CapsuleNetworkManager.Instance.MatchActive )
        {
            spawnTimer = 0f;
        }
        else
        {
            ClearPickups();
        }
    }

    private void Update()
    {
        if ( isServer )
        {
            spawnTimer += Time.deltaTime;

            if ( spawnTimer >= currentSpawnTime )
            {
                currentSpawnTime = Random.Range( minSpawnTime, maxSpawnTime );

                spawnTimer = 0f;

                if ( CapsuleNetworkManager.Instance.Arena != null && CapsuleNetworkManager.Instance.Arena.PickupSpawns.Count > 0 )
                {
                    ClientSpawnPickup( Random.Range( 0, pickupPrefabs.Count ), CapsuleNetworkManager.Instance.Arena.PickupSpawns[Random.Range( 0, CapsuleNetworkManager.Instance.Arena.PickupSpawns.Count )].position, (float)NetworkTime.time );
                }
            }
        }
    }

    [ClientRpc]
    private void ClientSpawnPickup( int pickupIndex, Vector3 location, float networkTime )
    {
        PickupBase pickup = ObjectPoolManager.Instance.GetPooled( pickupPrefabs[pickupIndex].gameObject, transform ).GetComponent<PickupBase>();

        pickup.SetSpawnPosition( location, (float)NetworkTime.time - networkTime );
    }

    [ClientRpc]
    private void ClearPickups()
    {
        PickupBase[] pickups = GetComponentsInChildren<PickupBase>();

        foreach ( PickupBase pickup in pickups )
        {
            if ( pickup.gameObject.activeInHierarchy )
                ObjectPoolManager.Instance.ReturnToPool( pickup.gameObject );
        }
    }

    private void OnDestroy()
    {
        if ( CapsuleNetworkManager.Instance != null )
            CapsuleNetworkManager.Instance.OnMatchActiveChanged -= CapsuleNetworkManager_OnMatchActiveChanged;
    }
}
