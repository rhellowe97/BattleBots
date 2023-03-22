using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputManager : Singleton<PlayerInputManager>
{
    [SerializeField]
    protected PlayerInput playerInput;
    public InputActionAsset Controls => playerInput.actions;

    public bool IsKeyboard => playerInput.currentControlScheme == "Keyboard";

    protected override void Awake()
    {
        base.Awake();

        if ( Controls != null )
            Controls.Enable();

        playerInput.onControlsChanged += PlayerInput_OnControlsChanged;
    }

    private void PlayerInput_OnControlsChanged( PlayerInput obj )
    {

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
