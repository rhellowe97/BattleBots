#if UNITY_EDITOR
using System;
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
[InitializeOnLoad]
public class URPPlusSettings : MonoBehaviour
{
    // Material Quality
    [HideInInspector] public int sssModel;
    [HideInInspector] public static bool sssLUT = false;
    [HideInInspector] public int iridescenceModel;
    [HideInInspector] public static bool iridescenceLUT = false;
    [HideInInspector] public int sheenModel;

    // Ambient Occlusion
    [HideInInspector] public bool enableMicroShadows;
    [HideInInspector] public float opacity = 0.0f;
    [HideInInspector] public bool enableHighQualityDepthNormals = false;
    [HideInInspector] public bool disableAllKeywords = false;

    private void OnEnable()
    {
        disableAllKeywords = false;
    }
    private void OnDisable()
    {
        disableAllKeywords = true;
    }
    private void SwitchKeyword(bool condition, string keyword)
    {
        if(condition)
        {
            Shader.EnableKeyword(keyword);
        }
        else
        {
            Shader.DisableKeyword(keyword);
        }
    }

    void Start()
    {
        if(!disableAllKeywords)
        {
            SwitchKeyword(sssModel == 1, "_SHADER_QUALITY_PREINTEGRATED_SSS");
            sssLUT = (sssModel == 1) ? true : false;
            SwitchKeyword(iridescenceModel == 1, "_SHADER_QUALITY_IRIDESCENCE_APPROXIMATION");
            iridescenceLUT = (iridescenceModel == 1) ? true : false;
            SwitchKeyword(sheenModel == 1, "_SHADER_QUALITY_SHEEN_PHYSICAL_BASED");

            SwitchKeyword(enableMicroShadows, "_SHADER_QUALITY_MICRO_SHADOWS");
            if(enableMicroShadows)
            {
                Shader.SetGlobalFloat("_MicroShadowOpacity", opacity);
            }
            SwitchKeyword(enableHighQualityDepthNormals, "_SHADER_QUALITY_HIGH_QUALITY_DEPTH_NORMALS");
        }
    }
}

[CustomEditor(typeof(URPPlusSettings))]
[CanEditMultipleObjects]
public class URPPlusSettingsEditor : Editor 
{
    enum SSSModel
    {
        SGSSS = 0,
        PreIntegratedSSS = 1
    }
    enum IridescenceModel
    {
        PhysicalBased = 0,
        Approximation = 1
    }
    enum SheenModel
    {
        Approximation = 0,
        PhysicalBased = 1
    }
    SerializedProperty _sssModel;
    SerializedProperty _fakeSSSshadows;
    SerializedProperty _iridescenceModel;
    SerializedProperty _sheenModel;

    SerializedProperty _microShadows;
    SerializedProperty _microShadowsOpacity;
    SerializedProperty _enableHighQualityDepthNormals;

    SerializedProperty _disableAllKeywords;

    private void OnEnable()
    {
        _sssModel = serializedObject.FindProperty("sssModel");
        _fakeSSSshadows = serializedObject.FindProperty("enableFakeSSSshadows");
        _iridescenceModel = serializedObject.FindProperty("iridescenceModel");
        _sheenModel = serializedObject.FindProperty("sheenModel");

        _microShadows = serializedObject.FindProperty("enableMicroShadows");
        _microShadowsOpacity = serializedObject.FindProperty("opacity");
        _enableHighQualityDepthNormals = serializedObject.FindProperty("enableHighQualityDepthNormals");

        _disableAllKeywords = serializedObject.FindProperty("disableAllKeywords");
    }
    private static void DrawToggle(GUIContent styles, SerializedProperty prop, string keyword, bool secondCondition = true, int indentLevel = 0, bool isDisabled = false)
    {
        if (prop == null)
            return;

        EditorGUI.BeginDisabledGroup(isDisabled);
        EditorGUI.indentLevel += indentLevel;
        EditorGUI.BeginChangeCheck();
        bool newValue = EditorGUILayout.Toggle(styles, prop.boolValue == true);
        if (EditorGUI.EndChangeCheck())
            prop.boolValue = newValue ? true : false;
        EditorGUI.indentLevel -= indentLevel;
        EditorGUI.EndDisabledGroup();
        if (prop.boolValue == true && secondCondition == true)
        {
            Shader.EnableKeyword(keyword);
        }
        else
        {
            Shader.DisableKeyword(keyword);
        }
    }

    private static int PopupProperty(GUIContent styles, SerializedProperty prop, string[] displayedOptions, bool isDisabled = false)
    {
        int val = (int)prop.intValue;

        EditorGUI.BeginDisabledGroup(isDisabled);
        EditorGUI.BeginChangeCheck();
        int newValue = EditorGUILayout.Popup(styles, val, displayedOptions);
        EditorGUI.showMixedValue = false;
        if (EditorGUI.EndChangeCheck() && (newValue != val))
        {
            prop.intValue = val = newValue;
        }
        EditorGUI.EndDisabledGroup();

        return val;
    }

    public override void OnInspectorGUI()
    {
        //base.OnInspectorGUI();
        serializedObject.Update();
        ///////////////////////////
        /*****Shaders Quality*****/
        ///////////////////////////
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Materials Quality", EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();
        // SSS Model
        PopupProperty(new GUIContent("SSS Model"), _sssModel, Enum.GetNames(typeof(SSSModel)), _disableAllKeywords.boolValue);
        if((_disableAllKeywords.boolValue == false) && _sssModel.intValue == 1)
        {
            Shader.EnableKeyword("_SHADER_QUALITY_PREINTEGRATED_SSS");
            URPPlusSettings.sssLUT = true;
        }
        else
        {
            Shader.DisableKeyword("_SHADER_QUALITY_PREINTEGRATED_SSS");
            URPPlusSettings.sssLUT = false;
        }
        
        // Iridescence Model
        PopupProperty(new GUIContent("Iridescence Model"), _iridescenceModel, Enum.GetNames(typeof(IridescenceModel)), _disableAllKeywords.boolValue);
        if((_disableAllKeywords.boolValue == false) && _iridescenceModel.intValue == 1)
        {
            Shader.EnableKeyword("_SHADER_QUALITY_IRIDESCENCE_APPROXIMATION");
            URPPlusSettings.iridescenceLUT = true;
        }
        else
        {
            Shader.DisableKeyword("_SHADER_QUALITY_IRIDESCENCE_APPROXIMATION");
            URPPlusSettings.iridescenceLUT = false;
        }

         // Sheen Model
        PopupProperty(new GUIContent("Sheen Model"), _sheenModel, Enum.GetNames(typeof(SheenModel)), _disableAllKeywords.boolValue);
        if((_disableAllKeywords.boolValue == false) && _sheenModel.intValue == 1)
        { 
            Shader.EnableKeyword("_SHADER_QUALITY_SHEEN_PHYSICAL_BASED");
        }
        else
        {
            Shader.DisableKeyword("_SHADER_QUALITY_SHEEN_PHYSICAL_BASED");
        }
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
        
        ///////////////////////////
        /****Ambient Occlusion****/
        ///////////////////////////
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.LabelField("Ambient Occlusion", EditorStyles.boldLabel);
        // MicroShadows
        DrawToggle(new GUIContent("MicroShadows"), _microShadows, "_SHADER_QUALITY_MICRO_SHADOWS", _disableAllKeywords.boolValue == false, 0, _disableAllKeywords.boolValue);
        if (_disableAllKeywords.boolValue == false && _microShadows.boolValue == true)
        {
            EditorGUI.indentLevel++;
            _microShadowsOpacity.floatValue = EditorGUILayout.Slider("Opacity", _microShadowsOpacity.floatValue, 0.0f, 1.0f);
            EditorGUI.indentLevel--;
            Shader.SetGlobalFloat("_MicroShadowOpacity", _microShadowsOpacity.floatValue);
        }

        // High Quality DepthNormals
        DrawToggle(new GUIContent("High Quality DepthNormals"), _enableHighQualityDepthNormals, "_SHADER_QUALITY_HIGH_QUALITY_DEPTH_NORMALS", _disableAllKeywords.boolValue == false, 0, _disableAllKeywords.boolValue);
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
        
        serializedObject.ApplyModifiedProperties();
    }
}
#endif