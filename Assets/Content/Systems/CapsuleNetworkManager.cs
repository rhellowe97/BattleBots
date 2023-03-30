using CapsuleHands.PlayerCore;
using CapsuleHands.PlayerCore.Weapons;
using CapsuleHands.Singleton;
using Mirror;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CapsuleNetworkManager : NetworkManager
{
    public static CapsuleNetworkManager Instance => ( CapsuleNetworkManager ) singleton;

    public Dictionary<NetworkConnection, Player> Players = new Dictionary<NetworkConnection, Player>();

    public bool MatchActive = false;

    public Action OnMatchActiveChanged;

    [SerializeField] private GameObject networkTimerPrefab;

    private NetworkTimer networkTimerInstance;

    [SerializeField] private GameObject pickupManagerPrefab;

    private PickupManager pickupManagerInstance;

    private Stack<int> availableColorIndices = new Stack<int>();

    public Arena Arena;

    public override void OnStartServer()
    {
        base.OnStartServer();

        Players.Clear();

        MatchManager.OnTimerComplete -= MatchManager_OnTimerComplete;
        MatchManager.OnTimerComplete += MatchManager_OnTimerComplete;

        networkTimerInstance = Instantiate( networkTimerPrefab ).GetComponent<NetworkTimer>();

        NetworkServer.Spawn( networkTimerInstance.gameObject );

        pickupManagerInstance = Instantiate( pickupManagerPrefab ).GetComponent<PickupManager>();

        NetworkServer.Spawn( pickupManagerInstance.gameObject );

        availableColorIndices.Clear();

        for ( int i = Constants.Arena.PlayerColors.Count - 1; i >= 0; i-- )
        {
            if ( Constants.Arena.PlayerColors[i] != null )
            {
                availableColorIndices.Push( i );
            }
        }
    }

    public override void OnServerSceneChanged( string sceneName )
    {
        base.OnServerSceneChanged( sceneName );

        Arena = FindObjectOfType<Arena>(); //TODO Better    
    }

    public override void OnServerChangeScene( string newSceneName )
    {
        base.OnServerChangeScene( newSceneName );

        Projectile.ClearActive();
    }

    public override Transform GetStartPosition()
    {
        if ( Arena != null && Arena.PlayerSpawns.Count > 0 )
        {
            if ( playerSpawnMethod == PlayerSpawnMethod.Random )
            {
                return Arena.PlayerSpawns[UnityEngine.Random.Range( 0, Arena.PlayerSpawns.Count )];
            }
            else
            {
                Transform startPosition = Arena.PlayerSpawns[startPositionIndex];
                startPositionIndex = ( startPositionIndex + 1 ) % Arena.PlayerSpawns.Count;
                return startPosition;
            }
        }

        return base.GetStartPosition();
    }

    private void MatchManager_OnTimerComplete()
    {
        MatchActive = true;

        OnMatchActiveChanged?.Invoke();

        foreach ( Player player in Players.Values )
        {
            player.ToggleActive( true );
        }
    }

    public override void OnServerAddPlayer( NetworkConnectionToClient conn )
    {
        Transform startPos = GetStartPosition();
        GameObject player = startPos != null
            ? Instantiate( playerPrefab, startPos.position, startPos.rotation )
            : Instantiate( playerPrefab );

        player.name = $"{playerPrefab.name} [connId={conn.connectionId}]";

        DontDestroyOnLoad( player );

        NetworkServer.AddPlayerForConnection( conn, player );

        if ( player.TryGetComponent( out Player playerComp ) )
        {
            playerComp.OnPlayerEliminated += Player_OnElimination;

            if ( availableColorIndices.Count > 0 )
            {
                playerComp.AssignColor( availableColorIndices.Pop() );
            }

            Players.Add( conn, playerComp );

            if ( Players.Count == 1 || MatchActive )
            {
                playerComp.ToggleActive( true );
            }

            if ( Players.Count == 2 )
            {
                SetupMatch();
            }
        }
    }

    private void StartMatch()
    {
        networkTimerInstance.ServerStartCountdown( 3f, ( float ) NetworkTime.time );
    }

    private int eliminationCount = 0;

    private bool restarting = false;

    private void Player_OnElimination()
    {
        eliminationCount++;

        if ( !restarting && eliminationCount >= Players.Count - 1 )
        {
            restarting = true;

            StartCoroutine( RestartMatchRoutine() );
        }
    }

    private IEnumerator RestartMatchRoutine()
    {
        MatchActive = false;

        OnMatchActiveChanged?.Invoke();

        yield return new WaitForSeconds( 3 );

        restarting = false;

        //If Same Map vs Load?

        foreach ( Player player in Players.Values )
        {
            player.OnServerHideForMapLoad();
        }

        readyCount = 0;

        ServerChangeScene( SceneManager.GetActiveScene().name == "Arena_Prototype" ? "Level01" : "Arena_Prototype" );//; SceneManager.GetActiveScene().name == "Arena_Prototype" ? "Level01" : "Arena_Prototype" );

        // SetupMatch();
    }

    private void SetupMatch()
    {
        eliminationCount = 0;

        foreach ( Player player in Players.Values )
        {
            player.OnServerPlayerReset();
        }

        StartMatch();
    }

    private int readyCount = 0;

    public override void OnServerReady( NetworkConnectionToClient conn )
    {
        base.OnServerReady( conn );

        if ( MatchActive )
            return;

        readyCount++;

        Debug.Log( readyCount + " " + Players.Count );

        if ( readyCount == Players.Count )
        {
            SetupMatch();
        }
    }

    public override void OnServerDisconnect( NetworkConnectionToClient conn )
    {
        base.OnServerDisconnect( conn );

        if ( Players.ContainsKey( conn ) )
        {
            bool otherPlayerHasColor = false;

            foreach ( NetworkConnectionToClient otherConn in Players.Keys )
            {
                if ( otherConn == conn )
                    continue;

                if ( Players[conn].PlayerColor == Players[otherConn].PlayerColor )
                    otherPlayerHasColor = true;
            }

            if ( !otherPlayerHasColor && !availableColorIndices.Contains( Players[conn].PlayerColor ) )
                availableColorIndices.Push( Players[conn].PlayerColor );

            Players.Remove( conn );
        }
    }

    public void UpdateNetworkAddress( string address )
    {
        networkAddress = address;
    }

    public override void OnClientChangeScene( string newSceneName, SceneOperation sceneOperation, bool customHandling )
    {
        base.OnClientChangeScene( newSceneName, sceneOperation, customHandling );

        Projectile.ClearActive();
    }

    public override void OnClientSceneChanged()
    {
        base.OnClientSceneChanged();

        Arena = FindObjectOfType<Arena>();
    }
}
