using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapsuleHands.PlayerCore.Weapons
{
    public class ArcProjectile : Projectile
    {
        [SerializeField] private LineRenderer arcLine;

        [SerializeField] private bool useLine = false;

        private Vector3[] waypoints;

        private float arcDistance = 0f;

        private float arcTravelled = 0f;

        protected override void ProcessMovement()
        {
            if ( arcTravelled < arcDistance )
            {
                float indexDistance = ( arcTravelled / arcDistance ) * waypoints.Length;

                int indexFloor = Mathf.FloorToInt( indexDistance );

                if ( indexFloor + 1 < waypoints.Length )
                {
                    transform.LookAt( waypoints[indexFloor + 1] );
                }

                int positionCount = ( waypoints.Length - 1 ) - ( indexFloor + 1 );

                if ( positionCount > 0 )
                {
                    arcLine.positionCount = positionCount;

                    arcLine.SetPosition( 0, transform.position );

                    for ( int i = 1; i < positionCount; i++ )
                    {
                        int waypointIndex = indexFloor + i;

                        arcLine.SetPosition( i, waypoints[waypointIndex] );
                    }
                }
                else if ( arcLine.enabled )
                {
                    arcLine.enabled = false;
                }

                arcTravelled += distanceChunk;
            }

            transform.position += transform.forward * distanceChunk;
        }

        public override void ResetObject()
        {
            base.ResetObject();

            arcTravelled = 0f;
        }

        public static ArcProjectile Spawn( GameObject projectilePrefab, Vector3[] waypoints, LayerMask targetLayerMask, IHittable owner = null, float passedTime = 0f )
        {
            GameObject go = ObjectPoolManager.Instance.GetPooled( projectilePrefab );

            if ( go == null )
            {
                return null;
            }
            else
            {
                ArcProjectile projectileInstance = go.GetComponent<ArcProjectile>();

                if ( projectileInstance != null )
                {
                    projectileInstance.waypoints = waypoints;

                    projectileInstance.arcDistance = 0f;

                    for ( int i = 0; i < waypoints.Length - 1; i++ )
                    {
                        projectileInstance.arcDistance += ( waypoints[i + 1] - waypoints[i] ).magnitude;
                    }

                    projectileInstance.transform.position = projectileInstance.waypoints[0];

                    projectileInstance.transform.forward = projectileInstance.waypoints[1] - projectileInstance.waypoints[0];

                    projectileInstance.passedTime = passedTime;

                    projectileInstance.Configure( owner, targetLayerMask );

                    projectileInstance.Active = true;

                    if ( projectileInstance.useLine )
                        projectileInstance.arcLine.enabled = true;
                }

                return projectileInstance;
            }
        }
    }
}
