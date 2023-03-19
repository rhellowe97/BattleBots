using CapsuleHands.Data;
using UnityEngine;

namespace CapsuleHands.Singleton
{
    public class GameManager : Singleton<GameManager>
    {
        public PlayerData PlayerData;

        protected override void Awake()
        {
            base.Awake();

            PlayerData = new PlayerData(); //Load from save file

            PlayerData.SetPlayerName( PlayerPrefs.GetString( "Name", "Player" ) );
        }

        public void UpdatePlayerName( string s )
        {
            PlayerData.SetPlayerName( s );

            PlayerPrefs.SetString( "Name", s );
        }
    }
}
