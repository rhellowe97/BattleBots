using CapsuleHands.Arena;
using Mirror;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PickupManager : NetworkBehaviour
{
    [SerializeField] private List<PickupBase> pickups;

    private float pickupChanceSum = 0;

    [SerializeField] private float minSpawnTime = 8f;

    [SerializeField] private float maxSpawnTime = 15f;

    public int GetPickup()
    {
        float randomWeight = Random.Range( 0, pickupChanceSum );

        for ( int i = 0; i < pickups.Count; i++ )
        {
            randomWeight -= pickups[i].SpawnWeight;

            if ( randomWeight < 0 )
            {
                return i;
            }
        }

        return 0;
    }

    private List<int> openSpawns = new List<int>();

    private Dictionary<PickupBase, int> spawnAssignments = new Dictionary<PickupBase, int>();

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

        for ( int i = 0; i < pickups.Count; i++ )
        {
            pickupChanceSum += pickups[i].SpawnWeight;
        }
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

                if ( CapsuleNetworkManager.Instance.Arena != null && CapsuleNetworkManager.Instance.Arena.PickupSpawns.Count > 0 && openSpawns.Count > 0 )
                {
                    int pickupSpawnIndex = Random.Range( 0, openSpawns.Count );

                    ClientSpawnPickup( GetPickup(), openSpawns[pickupSpawnIndex], CapsuleNetworkManager.Instance.Arena.PickupSpawns[openSpawns[pickupSpawnIndex]].position, ( float ) NetworkTime.time );

                    openSpawns.RemoveAt( pickupSpawnIndex );
                }
            }
        }
    }

    public void ConfigureSpawns()
    {
        spawnAssignments.Clear();

        openSpawns.Clear();

        for ( int i = 0; i < CapsuleNetworkManager.Instance.Arena.PickupSpawns.Count; i++ )
        {
            openSpawns.Add( i );
        }
    }

    [ClientRpc]
    private void ClientSpawnPickup( int pickupIndex, int spawnIndex, Vector3 spawnPosition, float networkTime )
    {
        PickupBase pickupPrefab = pickups[pickupIndex];

        if ( pickupPrefab != null )
        {
            PickupBase pickup = ObjectPoolManager.Instance.GetPooled( pickupPrefab.gameObject, transform ).GetComponent<PickupBase>();

            if ( isServer )
            {
                pickup.OnPickup -= PickupBase_OnPickup;

                pickup.OnPickup += PickupBase_OnPickup;

                spawnAssignments.Add( pickup, spawnIndex );
            }

            pickup.SetSpawnPosition( spawnPosition, ( float ) NetworkTime.time - networkTime );
        }
    }

    [Server]
    private void PickupBase_OnPickup( PickupBase pickup )
    {
        if ( spawnAssignments.ContainsKey( pickup ) )
        {
            openSpawns.Add( spawnAssignments[pickup] );

            spawnAssignments.Remove( pickup );
        }
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

        ConfigureSpawns();
    }

    private void OnDestroy()
    {
        if ( CapsuleNetworkManager.Instance != null )
            CapsuleNetworkManager.Instance.OnMatchActiveChanged -= CapsuleNetworkManager_OnMatchActiveChanged;
    }
}
