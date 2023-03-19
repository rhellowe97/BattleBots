using CapsuleHands.Singleton;
using TMPro;
using UnityEngine;

namespace CapsuleHands.UI
{
    public class MainMenu : MonoBehaviour
    {
        [SerializeField] private TMP_InputField nameInputField;

        private void Start()
        {
            nameInputField.text = GameManager.Instance.PlayerData.playerName;

            nameInputField.onValueChanged.AddListener( GameManager.Instance.UpdatePlayerName );
        }
    }
}
