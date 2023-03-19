// GENERATED AUTOMATICALLY FROM 'Assets/Content/Input/PlayerControls.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class @PlayerControls : IInputActionCollection, IDisposable
{
    public InputActionAsset asset { get; }
    public @PlayerControls()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""PlayerControls"",
    ""maps"": [
        {
            ""name"": ""Player"",
            ""id"": ""32086c88-a71b-4378-a834-f829de9dea26"",
            ""actions"": [
                {
                    ""name"": ""Move"",
                    ""type"": ""Value"",
                    ""id"": ""d4d5e205-3af0-45a8-8c3d-d068fa4faa1c"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Look"",
                    ""type"": ""Value"",
                    ""id"": ""d4bbca33-fab6-4cfc-8dad-0849363dc952"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""AbilityPrimary"",
                    ""type"": ""Button"",
                    ""id"": ""6e6d17a7-7551-4dbe-bd5f-312b07cf0349"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""AbilitySecondary"",
                    ""type"": ""Button"",
                    ""id"": ""53fbbddc-4ba1-4c09-9bea-4fac1e8c2aa6"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""AbilityTertiary"",
                    ""type"": ""Button"",
                    ""id"": ""64a1befd-b965-4b47-bc5b-c1ae6431f2df"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Evade"",
                    ""type"": ""Button"",
                    ""id"": ""7cc9d5ee-9930-4f44-9b13-13d6ee8d720d"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Block"",
                    ""type"": ""Button"",
                    ""id"": ""d23e1696-3a10-4b0c-bca8-a15d22425228"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""ToggleAim"",
                    ""type"": ""Button"",
                    ""id"": ""32535e32-6c7f-4f54-b478-c20718291bc6"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""WASD"",
                    ""id"": ""a0fd600c-11cb-4b47-9a7c-a77bede679c1"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""18315462-f7fe-4de1-9d46-11993e6293ce"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""ba5761b7-b3d1-409c-b493-b21a9d5e0eed"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""1b0d9c99-a80e-4ac3-9fc3-1f2c7d654a89"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""b6488146-ee0a-4d66-9fbb-4446462c2bc6"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""52189faf-678d-4449-98e3-35db0cace55b"",
                    ""path"": ""<Mouse>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""35a2fc10-9232-43ed-99f3-61c87dad8e0d"",
                    ""path"": ""<Mouse>/leftButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""AbilityPrimary"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""3327ea1f-7067-4fea-9c92-c6febbc21fc5"",
                    ""path"": ""<Keyboard>/leftShift"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Evade"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""e6d53ab5-d663-4da1-9076-80344d0ea7a0"",
                    ""path"": ""<Mouse>/rightButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""AbilitySecondary"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""e3330840-811e-40b8-b69f-f8ef066b5044"",
                    ""path"": ""<Keyboard>/space"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Block"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""01a622cf-6cd3-4b2f-a25d-32dcd238c46f"",
                    ""path"": ""<Keyboard>/f"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""AbilityTertiary"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""8a113519-1667-439f-83cb-128fa31a0123"",
                    ""path"": ""<Keyboard>/tab"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""ToggleAim"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        }
    ],
    ""controlSchemes"": []
}");
        // Player
        m_Player = asset.FindActionMap("Player", throwIfNotFound: true);
        m_Player_Move = m_Player.FindAction("Move", throwIfNotFound: true);
        m_Player_Look = m_Player.FindAction("Look", throwIfNotFound: true);
        m_Player_AbilityPrimary = m_Player.FindAction("AbilityPrimary", throwIfNotFound: true);
        m_Player_AbilitySecondary = m_Player.FindAction("AbilitySecondary", throwIfNotFound: true);
        m_Player_AbilityTertiary = m_Player.FindAction("AbilityTertiary", throwIfNotFound: true);
        m_Player_Evade = m_Player.FindAction("Evade", throwIfNotFound: true);
        m_Player_Block = m_Player.FindAction("Block", throwIfNotFound: true);
        m_Player_ToggleAim = m_Player.FindAction("ToggleAim", throwIfNotFound: true);
    }

    public void Dispose()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes => asset.controlSchemes;

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // Player
    private readonly InputActionMap m_Player;
    private IPlayerActions m_PlayerActionsCallbackInterface;
    private readonly InputAction m_Player_Move;
    private readonly InputAction m_Player_Look;
    private readonly InputAction m_Player_AbilityPrimary;
    private readonly InputAction m_Player_AbilitySecondary;
    private readonly InputAction m_Player_AbilityTertiary;
    private readonly InputAction m_Player_Evade;
    private readonly InputAction m_Player_Block;
    private readonly InputAction m_Player_ToggleAim;
    public struct PlayerActions
    {
        private @PlayerControls m_Wrapper;
        public PlayerActions(@PlayerControls wrapper) { m_Wrapper = wrapper; }
        public InputAction @Move => m_Wrapper.m_Player_Move;
        public InputAction @Look => m_Wrapper.m_Player_Look;
        public InputAction @AbilityPrimary => m_Wrapper.m_Player_AbilityPrimary;
        public InputAction @AbilitySecondary => m_Wrapper.m_Player_AbilitySecondary;
        public InputAction @AbilityTertiary => m_Wrapper.m_Player_AbilityTertiary;
        public InputAction @Evade => m_Wrapper.m_Player_Evade;
        public InputAction @Block => m_Wrapper.m_Player_Block;
        public InputAction @ToggleAim => m_Wrapper.m_Player_ToggleAim;
        public InputActionMap Get() { return m_Wrapper.m_Player; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(PlayerActions set) { return set.Get(); }
        public void SetCallbacks(IPlayerActions instance)
        {
            if (m_Wrapper.m_PlayerActionsCallbackInterface != null)
            {
                @Move.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnMove;
                @Move.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnMove;
                @Move.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnMove;
                @Look.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnLook;
                @Look.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnLook;
                @Look.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnLook;
                @AbilityPrimary.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilityPrimary;
                @AbilityPrimary.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilityPrimary;
                @AbilityPrimary.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilityPrimary;
                @AbilitySecondary.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilitySecondary;
                @AbilitySecondary.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilitySecondary;
                @AbilitySecondary.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilitySecondary;
                @AbilityTertiary.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilityTertiary;
                @AbilityTertiary.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilityTertiary;
                @AbilityTertiary.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnAbilityTertiary;
                @Evade.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnEvade;
                @Evade.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnEvade;
                @Evade.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnEvade;
                @Block.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnBlock;
                @Block.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnBlock;
                @Block.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnBlock;
                @ToggleAim.started -= m_Wrapper.m_PlayerActionsCallbackInterface.OnToggleAim;
                @ToggleAim.performed -= m_Wrapper.m_PlayerActionsCallbackInterface.OnToggleAim;
                @ToggleAim.canceled -= m_Wrapper.m_PlayerActionsCallbackInterface.OnToggleAim;
            }
            m_Wrapper.m_PlayerActionsCallbackInterface = instance;
            if (instance != null)
            {
                @Move.started += instance.OnMove;
                @Move.performed += instance.OnMove;
                @Move.canceled += instance.OnMove;
                @Look.started += instance.OnLook;
                @Look.performed += instance.OnLook;
                @Look.canceled += instance.OnLook;
                @AbilityPrimary.started += instance.OnAbilityPrimary;
                @AbilityPrimary.performed += instance.OnAbilityPrimary;
                @AbilityPrimary.canceled += instance.OnAbilityPrimary;
                @AbilitySecondary.started += instance.OnAbilitySecondary;
                @AbilitySecondary.performed += instance.OnAbilitySecondary;
                @AbilitySecondary.canceled += instance.OnAbilitySecondary;
                @AbilityTertiary.started += instance.OnAbilityTertiary;
                @AbilityTertiary.performed += instance.OnAbilityTertiary;
                @AbilityTertiary.canceled += instance.OnAbilityTertiary;
                @Evade.started += instance.OnEvade;
                @Evade.performed += instance.OnEvade;
                @Evade.canceled += instance.OnEvade;
                @Block.started += instance.OnBlock;
                @Block.performed += instance.OnBlock;
                @Block.canceled += instance.OnBlock;
                @ToggleAim.started += instance.OnToggleAim;
                @ToggleAim.performed += instance.OnToggleAim;
                @ToggleAim.canceled += instance.OnToggleAim;
            }
        }
    }
    public PlayerActions @Player => new PlayerActions(this);
    public interface IPlayerActions
    {
        void OnMove(InputAction.CallbackContext context);
        void OnLook(InputAction.CallbackContext context);
        void OnAbilityPrimary(InputAction.CallbackContext context);
        void OnAbilitySecondary(InputAction.CallbackContext context);
        void OnAbilityTertiary(InputAction.CallbackContext context);
        void OnEvade(InputAction.CallbackContext context);
        void OnBlock(InputAction.CallbackContext context);
        void OnToggleAim(InputAction.CallbackContext context);
    }
}
