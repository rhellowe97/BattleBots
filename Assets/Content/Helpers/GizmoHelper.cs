using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GizmoHelper
{
    public static void DrawSphere( Vector3 position, float radius, Color color, float opacity = 1f )
    {
        Gizmos.color = Color.Lerp( Color.clear, color, opacity );

        Gizmos.DrawSphere( position, radius );
    }
}
