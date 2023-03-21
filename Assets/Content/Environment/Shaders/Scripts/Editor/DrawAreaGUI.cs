using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor
{
    public static partial class MaterialEditorExtension
    {
        public static void DrawAlphaCutoffGUI(this MaterialEditor materialEditor, Material material, MaterialProperty alphaCutoffEnable, MaterialProperty alphaCutoff, MaterialProperty useShadowThreshold, MaterialProperty alphaCutoffShadow)
        {
            bool showAlphaClipThreshold = true;

            if (showAlphaClipThreshold && alphaCutoffEnable != null)
                materialEditor.ShaderProperty(alphaCutoffEnable, URPPlusStyles.alphaCutoffEnableText);

            if (showAlphaClipThreshold && alphaCutoffEnable != null && alphaCutoffEnable.floatValue == 1.0f)
            {
                EditorGUI.indentLevel++;
                if (showAlphaClipThreshold && alphaCutoff != null)
                    materialEditor.ShaderProperty(alphaCutoff, URPPlusStyles.alphaCutoffText);

                if (showAlphaClipThreshold)
                {
                    bool showUseShadowThreshold = useShadowThreshold != null;

                    if (showUseShadowThreshold)
                        materialEditor.ShaderProperty(useShadowThreshold, URPPlusStyles.useShadowThresholdText);

                    if (alphaCutoffShadow != null && useShadowThreshold != null && useShadowThreshold.floatValue == 1.0f)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(alphaCutoffShadow, URPPlusStyles.alphaCutoffShadowText);
                        EditorGUI.indentLevel--;
                    }
                }
                EditorGUI.indentLevel--;
            }
        }
        
        public static void DrawSpecularAAArea(this MaterialEditor materialEditor, MaterialProperty specularAA, MaterialProperty variance, MaterialProperty threshold)
        {
            materialEditor.DrawFloatToggleProperty(URPPlusStyles.enableGeometricSpecularAAText, specularAA);
            bool specularAAToggle = (specularAA.floatValue == 1) ? true : false;
            if (specularAAToggle)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(variance, URPPlusStyles.specularAAScreenSpaceVarianceText);
                materialEditor.ShaderProperty(threshold, URPPlusStyles.specularAAThresholdText);
                EditorGUI.indentLevel--;
	        }
        }
        public static void DrawNormalModeArea(this MaterialEditor materialEditor, Material material, MaterialProperty doubleSidedNormalMode)
        {
            if ((RenderFace)material.GetFloat("_Cull") == RenderFace.Both)
            {
                DoubleSidedNormalMode doubleSidedNormalModeEnum = (DoubleSidedNormalMode)doubleSidedNormalMode.floatValue;
                switch (doubleSidedNormalModeEnum)
                {
                    case DoubleSidedNormalMode.Mirror: // Mirror mode (in tangent space)
                        material.SetVector("_DoubleSidedConstants", new Vector4(1.0f, 1.0f, -1.0f, 0.0f));
                        break;
                    case DoubleSidedNormalMode.Flip: // Flip mode (in tangent space)
                        material.SetVector("_DoubleSidedConstants", new Vector4(-1.0f, -1.0f, -1.0f, 0.0f));
                        break;
                    case DoubleSidedNormalMode.None: // None mode (in tangent space)
                        material.SetVector("_DoubleSidedConstants", new Vector4(1.0f, 1.0f, 1.0f, 0.0f));
                        break;
                }

                if (doubleSidedNormalMode != null)
                    materialEditor.ShaderProperty(doubleSidedNormalMode, URPPlusStyles.doubleSidedNormalModeText);
            }
        }
        public static void DrawMaskMapArea(this MaterialEditor materialEditor,  MaterialProperty workflowMode, MaterialProperty maskMap, 
                                            MaterialProperty metallic, MaterialProperty smoothness, 
                                            MaterialProperty metallicMin, MaterialProperty metallicMax, 
                                            MaterialProperty smoothnessMin, MaterialProperty smoothnessMax,
                                            MaterialProperty aoMin, MaterialProperty aoMax)
        {
            WorkflowMode workflowModeEnum = (WorkflowMode)workflowMode.floatValue;
            if(maskMap.textureValue != null)
            {
                if(workflowModeEnum == WorkflowMode.Metallic)
                    materialEditor.MinMaxShaderProperty(metallicMin, metallicMax, 0.0f, 1.0f, URPPlusStyles.metallicRemappingText);

                materialEditor.MinMaxShaderProperty(smoothnessMin, smoothnessMax, 0.0f, 1.0f, URPPlusStyles.smoothnessRemappingText);
                materialEditor.MinMaxShaderProperty(aoMin, aoMax, 0.0f, 1.0f, URPPlusStyles.aoRemappingText);
            }
            else
            {
                if(workflowModeEnum == WorkflowMode.Metallic)
                    materialEditor.ShaderProperty(metallic, URPPlusStyles.metallicText);

                materialEditor.ShaderProperty(smoothness, URPPlusStyles.smoothnessText);
            }

            if(workflowModeEnum == WorkflowMode.Metallic)
			    materialEditor.TexturePropertySingleLine(URPPlusStyles.maskMapSText, maskMap);
            else
            {
                materialEditor.TexturePropertySingleLine(URPPlusStyles.maskMapSpecularText, maskMap);
            }
        }

        public static void DrawCustomNormalArea(this MaterialEditor materialEditor, GUIContent label, MaterialProperty bumpMap, MaterialProperty bumpMapScale = null)
        {
            if (bumpMapScale != null)
            {
                materialEditor.TexturePropertySingleLine(label, bumpMap,
                    bumpMap.textureValue != null ? bumpMapScale : null);
                if (bumpMapScale.floatValue != 1 &&
                    UnityEditorInternal.InternalEditorUtility.IsMobilePlatform(
                        EditorUserBuildSettings.activeBuildTarget))
                    if (materialEditor.HelpBoxWithButton(URPPlusStyles.bumpScaleNotSupported, URPPlusStyles.fixNormalNow))
                        bumpMapScale.floatValue = 1;
            }
            else
            {
                materialEditor.TexturePropertySingleLine(label, bumpMap);
            }
        }

        public static void DrawDisplacementGUI(this MaterialEditor materialEditor, Material material, MaterialProperty displacementMode, 
                            MaterialProperty PPDMinSamples, MaterialProperty PPDMaxSamples, MaterialProperty PPDLodThreshold, MaterialProperty lockWithObjectScale)
        {
            DisplacementMode displacementModeEnum = (DisplacementMode)displacementMode.floatValue;
            if(!material.HasProperty("_TessellationMode"))
            {
                materialEditor.ShaderProperty(displacementMode, URPPlusStyles.displacementModeText);
                EditorGUI.indentLevel++;
                if (displacementModeEnum != DisplacementMode.None)
                    materialEditor.DrawFloatToggleProperty(URPPlusStyles.lockWithObjectScaleText, lockWithObjectScale);
                EditorGUI.indentLevel--;
                EditorGUILayout.Space();

                if (displacementModeEnum == DisplacementMode.PixelDisplacement)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.IntSliderShaderProperty(PPDMinSamples, URPPlusStyles.ppdMinSamplesText);
                    materialEditor.IntSliderShaderProperty(PPDMaxSamples, URPPlusStyles.ppdMaxSamplesText);
                    materialEditor.ShaderProperty(PPDLodThreshold, URPPlusStyles.ppdLodThresholdText);
                    EditorGUI.indentLevel--;
                }
            }
            else
            {
                materialEditor.ShaderProperty(displacementMode, URPPlusStyles.displacementModeText);
                EditorGUI.indentLevel++;
                if (displacementModeEnum == DisplacementMode.VertexDisplacement)
                    materialEditor.DrawFloatToggleProperty(URPPlusStyles.lockWithObjectScaleText, lockWithObjectScale);
                EditorGUI.indentLevel--;
            }
        }
        
        public static void DrawEmissionSettings(this MaterialEditor materialEditor, Material material, MaterialProperty emissionWithBase, MaterialProperty emissionMap, MaterialProperty emissionColor, MaterialProperty emissionScale)
        {
            EditorGUI.BeginChangeCheck();
			materialEditor.TexturePropertyWithHDRColor(URPPlusStyles.emissiveMapText, emissionMap, emissionColor, false);
            EditorGUI.indentLevel++;
			materialEditor.ShaderProperty(emissionScale, URPPlusStyles.emissiveIntensityText);
	    	if (EditorGUI.EndChangeCheck()) 
            {
	    	    var brightness = emissionColor.colorValue.maxColorComponent;
	    	    material.globalIlluminationFlags = MaterialGlobalIlluminationFlags.BakedEmissive;
	    	    if (brightness <= 0f) 
                {
                    material.globalIlluminationFlags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;
                }
	    	}
            EditorGUI.indentLevel--;

            //Emission multiply with Base
            materialEditor.DrawFloatToggleProperty(URPPlusStyles.albedoAffectEmissiveText, emissionWithBase);
            materialEditor.LightmapEmissionProperty();
        }
    }
}