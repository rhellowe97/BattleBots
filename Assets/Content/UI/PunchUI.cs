using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace CapsuleHands.UI
{
    public class PunchUI : MonoBehaviour
    {
        [SerializeField] private Image punchFill;

        [SerializeField] private TMP_Text punchText;

        public void Refresh( float fillAmount, int chargeCount )
        {
            punchFill.fillAmount = fillAmount;

            punchText.text = $"{chargeCount}";
        }
    }
}
