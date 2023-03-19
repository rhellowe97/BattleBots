using CapsuleHands.PlayerCore;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace CapsuleHands.UI
{
    public class PlayerUI : MonoBehaviour
    {
        [SerializeField] private TMP_Text damageText;

        [SerializeField] private TMP_Text nameText;

        private Player assignedPlayer;

        public void AssignPlayer( Player player )
        {
            assignedPlayer = player;

            player.OnUIRefresh += Player_OnUIRefresh;

            Player_OnUIRefresh();
        }

        private void Player_OnUIRefresh()
        {
            damageText.text = $"{assignedPlayer.Damage}%";

            damageText.color = Constants.UI.DamageColorGradient.Evaluate( Mathf.Clamp( assignedPlayer.Damage / Constants.UI.MaxDamageColor, 0, 1 ) );

            nameText.text = assignedPlayer.PlayerName;

            nameText.color = Color.Lerp( Constants.Arena.PlayerColors[assignedPlayer.PlayerColor], Color.white, 0.3f );

            nameText.fontStyle = assignedPlayer.Eliminated ? FontStyles.Strikethrough : FontStyles.Normal;
        }
    }
}
