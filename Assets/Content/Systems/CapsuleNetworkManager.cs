using CapsuleHands.PlayerCore;
using CapsuleHands.Singleton;
using Mirror;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CapsuleNetworkManager : NetworkManager
{
    public static CapsuleNetworkManager Instance => (CapsuleNetworkManager)singleton;

    public Dictionary<NetworkConnection, Player> Players = new Dictionary<NetworkConnection, Player>();

    public bool MatchActive = false;

    [SerializeField] private GameObject networkTimerPrefab;

    private NetworkTimer networkTimerInstance;

    private Stack<int> availableColorIndices = new Stack<int>();

    public override void OnStartServer()
    {
        base.OnStartServer();

        Players.Clear();

        MatchManager.OnTimerComplete -= MatchManager_OnTimerComplete;
        MatchManager.OnTimerComplete += MatchManager_OnTimerComplete;

        networkTimerInstance = Instantiate( networkTimerPrefab ).GetComponent<NetworkTimer>();

        NetworkServer.Spawn( networkTimerInstance.gameObject );

        availableColorIndices.Clear();

        for ( int i = Constants.Arena.PlayerColors.Count - 1; i >= 0; i-- )
        {
            if ( Constants.Arena.PlayerColors[i] != null )
            {
                availableColorIndices.Push( i );
            }
        }
    }

    private void MatchManager_OnTimerComplete()
    {
        MatchActive = true;

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
        }

        if ( Players.Count == 2 )
        {
            SetupMatch();
        }
    }

    private void StartMatch()
    {
        networkTimerInstance.ServerStartCountdown( 3f, (float)NetworkTime.time );
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

        yield return new WaitForSeconds( 3 );

        restarting = false;

        SetupMatch();
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
}
