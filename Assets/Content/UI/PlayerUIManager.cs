using CapsuleHands.PlayerCore;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace CapsuleHands.UI
{
    public class PlayerUIManager : Singleton<PlayerUIManager>
    {
        public enum UILocation
        {
            TopLeft,
            TopRight,
        }

        [SerializeField] private UDictionary<UILocation, Transform> locationRoots;

        [SerializeField] private GameObject playerUIPrefab;

        [SerializeField] private Transform playerUIContainer;

        private Dictionary<Player, PlayerUI> playerUIMapping = new Dictionary<Player, PlayerUI>();

        public void SubscriptionUpdate( Player player, bool subscribe )
        {
            if ( subscribe && !playerUIMapping.ContainsKey( player ) )
            {
                PlayerUI playerUIInstance = Instantiate( playerUIPrefab, playerUIContainer ).GetComponent<PlayerUI>();

                if ( playerUIInstance == null )
                {
                    Debug.LogError( "Invalid Player UI prefab in use." );
                }
                else
                {
                    playerUIInstance.AssignPlayer( player );

                    playerUIMapping.Add( player, playerUIInstance );
                }
            }
            else if ( !subscribe && playerUIMapping.ContainsKey( player ) )
            {
                Destroy( playerUIMapping[player].gameObject );

                playerUIMapping.Remove( player );
            }
        }

        public void AddUIElement( UILocation location, Transform element )
        {
            if ( locationRoots.ContainsKey( location ) )
            {
                element.SetParent( locationRoots[location] );

                element.localScale = Vector3.one;
            }
        }

        public void RemoveUIElement( UILocation location, Transform element )
        {
            if ( locationRoots.ContainsKey( location ) && element.parent == locationRoots[location] )
            {
                Destroy( element.gameObject );
            }
        }
    }
}
