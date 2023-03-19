using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputManager : Singleton<PlayerInputManager>
{
    [SerializeField]
    protected InputActionAsset controls;
    public InputActionAsset Controls => controls;

    protected override void Awake()
    {
        base.Awake();

        if ( Controls != null )
            Controls.Enable();
    }

    public void ToggleControls( bool toggle )
    {
        if ( toggle )
        {
            Controls.Enable();
        }
        else
        {
            Controls.Disable();
        }
    }
}
