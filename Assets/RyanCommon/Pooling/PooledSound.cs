using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent( typeof( AudioSource ) )]
public class PooledSound : PooledObject
{
    [SerializeField] private List<AudioClip> clipSelection = new List<AudioClip>();

    private AudioSource audioSource;

    private WaitForSeconds soundDelay;

    public override void Init()
    {
        base.Init();

        audioSource = GetComponent<AudioSource>();

        float longestLength = 0f;

        foreach ( AudioClip clip in clipSelection )
        {
            if ( clip.length > longestLength )
                longestLength = clip.length;
        }

        soundDelay = new WaitForSeconds( longestLength );
    }

    public void Play()
    {
        audioSource.clip = clipSelection[Random.Range( 0, clipSelection.Count )];

        audioSource.Play();

        StartCoroutine( WaitForCompletion() );
    }

    private IEnumerator WaitForCompletion()
    {
        yield return soundDelay;

        ObjectPoolManager.Instance.ReturnToPool( gameObject );
    }
}
