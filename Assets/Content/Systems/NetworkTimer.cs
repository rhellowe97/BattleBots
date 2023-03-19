using Mirror;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NetworkTimer : NetworkBehaviour
{
    [SyncVar]
    public float startNetworkTime = 0;

    [SyncVar]
    public float currentDuration = 0;

    [SyncVar]
    public bool isCountingDown = false;

    public float Timer { get; private set; }

    public int GetCurrentSecond() => Mathf.CeilToInt( Timer );

    private Coroutine timerCo;

    private void Awake()
    {
        transform.SetParent( CapsuleNetworkManager.Instance.transform );
    }

    public override void OnStartClient()
    {
        base.OnStartClient();

        if ( isCountingDown && currentDuration - ( (float)NetworkTime.time - startNetworkTime ) > 1 )
        {
            ClientStartCountdown( currentDuration, startNetworkTime );
        }
    }

    public static Action<float> OnStartCountdown;

    [Server]
    public void ServerStartCountdown( float duration, float startTime )
    {
        currentDuration = duration;

        isCountingDown = true;

        startNetworkTime = startTime;

        ClientStartCountdown( duration, startTime );

        StartCoroutine( TimerRoutine() );
    }

    [ClientRpc]
    public void ClientStartCountdown( float duration, float startTime )
    {
        OnStartCountdown?.Invoke( duration - ( (float)NetworkTime.time - startTime ) );
    }

    [ClientRpc]
    public void StopTimer()
    {
        if ( timerCo != null )
        {
            StopCoroutine( timerCo );
        }
    }

    private IEnumerator TimerRoutine()
    {
        Timer = currentDuration;

        while ( Timer > 0 )
        {
            yield return null;

            Timer -= Time.deltaTime;
        }

        Timer = 0;

        timerCo = null;

        isCountingDown = false;
    }
}
