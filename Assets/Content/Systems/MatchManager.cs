using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using DG.Tweening;
using Mirror;

namespace CapsuleHands.Singleton
{
    public class MatchManager : Singleton<MatchManager>
    {
        [SerializeField] private RectTransform timerContainer;

        [SerializeField] private TMP_Text timerText;

        private float timer = 0f;

        private int lastSecond = 3;

        public static Action OnTimerComplete;

        private Tween countdownTween;

        private void Start()
        {
            NetworkTimer.OnStartCountdown += StartMatch;
        }

        private void OnDestroy()
        {
            NetworkTimer.OnStartCountdown -= StartMatch;
        }

        public void StartMatch( float duration )
        {
            timer = duration;

            lastSecond = Mathf.CeilToInt( timer );

            timerContainer.gameObject.SetActive( true );

            timerContainer.localScale = Vector3.zero;

            countdownTween = timerContainer.DOScale( Vector3.one, 1f ).SetEase( Ease.OutCirc );

            timerText.text = lastSecond.ToString();

            StartCoroutine( TimerRoutine() );
        }

        private IEnumerator TimerRoutine()
        {
            while ( timer > 0 )
            {
                yield return null;

                timer -= Time.deltaTime;

                int currentSecond = Mathf.CeilToInt( timer );

                if ( currentSecond != lastSecond )
                {
                    lastSecond = currentSecond;

                    timerText.text = lastSecond.ToString();

                    if ( countdownTween != null && !countdownTween.IsComplete() )
                    {
                        countdownTween.Kill();
                    }

                    timerContainer.localScale = Vector3.zero;

                    countdownTween = timerContainer.DOScale( Vector3.one, 1f ).SetEase( Ease.OutCirc );
                }
            }

            timerText.text = "GO!";

            if ( countdownTween != null && !countdownTween.IsComplete() )
            {
                countdownTween.Kill();
            }

            countdownTween = null;

            timerContainer.localScale = Vector3.zero;

            timerContainer.DOScale( Vector3.one, 1f ).SetEase( Ease.OutCirc );

            yield return new WaitForSeconds( 1 );

            OnTimerComplete?.Invoke();

            timerContainer.gameObject.SetActive( false );
        }
    }
}
