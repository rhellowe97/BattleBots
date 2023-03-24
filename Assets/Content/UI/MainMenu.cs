using CapsuleHands.Singleton;
using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace CapsuleHands.UI
{
    public class MainMenu : MonoBehaviour
    {
        [SerializeField] private TMP_InputField nameInputField;

        [SerializeField] private TMP_InputField testSceneField;

        public static string OnlineScene = "";

        private const string TEST_SCENE_KEY = "TestScene";

        private void Start()
        {
            if ( string.IsNullOrEmpty( OnlineScene ) && !string.IsNullOrEmpty( CapsuleNetworkManager.Instance.onlineScene ) )
            {
                string[] s = CapsuleNetworkManager.Instance.onlineScene.Split( "/" );

                if ( s.Length > 0 )
                {
                    OnlineScene = s[s.Length - 1].Split( "." )[0];

                    testSceneField.text = PlayerPrefs.GetString( TEST_SCENE_KEY, OnlineScene );

                }
            }
            else
            {
                CapsuleNetworkManager.Instance.onlineScene = OnlineScene;

                testSceneField.text = OnlineScene;
            }

            nameInputField.text = GameManager.Instance.PlayerData.playerName;

            nameInputField.onValueChanged.AddListener( GameManager.Instance.UpdatePlayerName );
        }

        public void LoadTestScene()
        {
            PlayerPrefs.SetString( TEST_SCENE_KEY, testSceneField.text.Trim() );

            CapsuleNetworkManager.Instance.onlineScene = testSceneField.text.Trim();

            CapsuleNetworkManager.Instance.StartHost();
        }
    }
}
