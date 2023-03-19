using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnvironmentTranslation : MonoBehaviour
{
    [SerializeField]
    protected Vector3 localTranslationVector = Vector3.zero;

    [SerializeField]
    protected float halfDuration = 4f;

    [SerializeField]
    protected Ease stopEase = Ease.InOutSine;

    private Tween translationTween;

    private int direction = 1;

    private void Awake()
    {
        if ( localTranslationVector.sqrMagnitude > 0 )
        {
            StartCoroutine( Translation() );
        }
    }

    private IEnumerator Translation()
    {
        while ( true )
        {
            translationTween = transform.DOMove( transform.position + transform.TransformVector( localTranslationVector ) * direction, halfDuration ).SetEase( stopEase );

            yield return translationTween.WaitForCompletion();

            direction *= -1;
        }
    }
}
