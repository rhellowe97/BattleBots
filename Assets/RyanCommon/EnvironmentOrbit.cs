using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnvironmentOrbit : MonoBehaviour
{
    [SerializeField]
    protected Vector3 localOrbitAxis = Vector3.up;

    [SerializeField]
    protected float orbitSpeed = 45f;

    private void Update()
    {
        transform.Rotate( localOrbitAxis, orbitSpeed * Time.deltaTime, Space.Self );
    }
}
