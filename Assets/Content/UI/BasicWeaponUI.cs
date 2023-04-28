using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace CapsuleHands.UI
{
    public class BasicWeaponUI : MonoBehaviour
    {
        [SerializeField] private Slider basicGunHeat;

        [SerializeField] private Image heatBackground;

        public void Refresh( float fillAmount )
        {
            basicGunHeat.value = fillAmount;

            heatBackground.color = Constants.UI.DamageColorGradient.Evaluate( basicGunHeat.value );
        }
    }
}