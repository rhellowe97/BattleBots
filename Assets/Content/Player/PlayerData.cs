using UnityEngine;

namespace CapsuleHands.Data
{
    [System.Serializable]
    public class PlayerData
    {
        [SerializeField] public string playerName = "Player";
        public string PlayerName => playerName;

        public PlayerData()
        {

        }

        public PlayerData( string name )
        {
            playerName = name;
        }

        public void SetPlayerName( string s )
        {
            playerName = s;
        }
    }
}
