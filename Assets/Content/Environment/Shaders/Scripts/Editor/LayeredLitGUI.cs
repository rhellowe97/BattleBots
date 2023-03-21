using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public class LayeredLitGUI : BaseShaderGUI
    {
        // Surface Input Props
        private MaterialProperty displacementMode;
        private MaterialProperty PPDMinSamples;
        private MaterialProperty PPDMaxSamples;
        private MaterialProperty PPDLodThreshold;
        private MaterialProperty lockWithObjectScale;

        // Layer Prop
        internal const int kMaxLayerCount = 4;
        MaterialProperty[] inheritBaseNormal = new MaterialProperty[kMaxLayerCount - 1];
        const string kInheritBaseNormal = "_InheritBaseNormal";
        MaterialProperty[] inheritBaseHeight = new MaterialProperty[kMaxLayerCount - 1];
        const string kInheritBaseHeight = "_InheritBaseHeight";
        MaterialProperty[] inheritBaseColor = new MaterialProperty[kMaxLayerCount - 1];
        const string kInheritBaseColor = "_InheritBaseColor";
        MaterialProperty[] opacityAsDensity = new MaterialProperty[kMaxLayerCount];
        const string kOpacityAsDensity = "_OpacityAsDensity";
        MaterialProperty[] baseColor = new MaterialProperty[kMaxLayerCount];
        const string kBaseColor = "_BaseColor";
        MaterialProperty[] baseColorMap = new MaterialProperty[kMaxLayerCount];
        const string kBaseColorMap = "_BaseMap";
        MaterialProperty[] metallic = new MaterialProperty[kMaxLayerCount];
        const string kMetallic = "_Metallic";
        MaterialProperty[] metallicRemapMin = new MaterialProperty[kMaxLayerCount];
        const string kMetallicRemapMin = "_MetallicRemapMin";
        MaterialProperty[] metallicRemapMax = new MaterialProperty[kMaxLayerCount];
        const string kMetallicRemapMax = "_MetallicRemapMax";
        MaterialProperty[] smoothness = new MaterialProperty[kMaxLayerCount];
        const string kSmoothness = "_Smoothness";
        MaterialProperty[] smoothnessRemapMin = new MaterialProperty[kMaxLayerCount];
        const string kSmoothnessRemapMin = "_SmoothnessRemapMin";
        MaterialProperty[] smoothnessRemapMax = new MaterialProperty[kMaxLayerCount];
        const string kSmoothnessRemapMax = "_SmoothnessRemapMax";
        MaterialProperty[] aoRemapMin = new MaterialProperty[kMaxLayerCount];
        const string kAORemapMin = "_AORemapMin";
        MaterialProperty[] aoRemapMax = new MaterialProperty[kMaxLayerCount];
        const string kAORemapMax = "_AORemapMax";
        MaterialProperty[] maskMap = new MaterialProperty[kMaxLayerCount];
        const string kMaskMap = "_MaskMap";
        MaterialProperty[] normalScale = new MaterialProperty[kMaxLayerCount];
        const string kNormalScale = "_NormalScale";
        MaterialProperty[] normalMap = new MaterialProperty[kMaxLayerCount];
        const string kNormalMap = "_NormalMap";
        MaterialProperty[] bentNormalMap = new MaterialProperty[kMaxLayerCount];
        const string kBentNormalMap = "_BentNormalMap";
        MaterialProperty[] heightMap = new MaterialProperty[kMaxLayerCount];
        const string kHeightMap = "_HeightMap";
        MaterialProperty[] heightParametrization = new MaterialProperty[kMaxLayerCount];
        const string kHeightParametrization = "_HeightMapParametrization";
        MaterialProperty[] heightTessCenter = new MaterialProperty[kMaxLayerCount];
        const string kHeightTessCenter = "_HeightTessCenter";
        MaterialProperty[] heightTessAmplitude = new MaterialProperty[kMaxLayerCount];
        const string kHeightTessAmplitude = "_HeightTessAmplitude";
        MaterialProperty[] heightMin = new MaterialProperty[kMaxLayerCount];
        const string kHeightMin = "_HeightMin";
        MaterialProperty[] heightMax = new MaterialProperty[kMaxLayerCount];
        const string kHeightMax = "_HeightMax";
        MaterialProperty[] heightOffset = new MaterialProperty[kMaxLayerCount];
        const string kHeightOffset = "_HeightOffset";
        MaterialProperty[] heightPoMAmplitude = new MaterialProperty[kMaxLayerCount];
        const string kHeightPoMAmplitude = "_HeightPoMAmplitude";
        MaterialProperty[] detailMap = new MaterialProperty[kMaxLayerCount];
        const string kDetailMap = "_DetailMap";
        MaterialProperty[] detailAlbedoScale = new MaterialProperty[kMaxLayerCount];
        const string kDetailAlbedoScale = "_DetailAlbedoScale";
        MaterialProperty[] detailNormalScale = new MaterialProperty[kMaxLayerCount];
        const string kDetailNormalScale = "_DetailNormalScale";
		MaterialProperty[] detailSmoothnessScale = new MaterialProperty[kMaxLayerCount];
        const string kDetailSmoothnessScale = "_DetailSmoothnessScale";

        private PropertyStructures.SurfaceOptions surfaceOptions;
        private PropertyStructures.LayeredSurfaceInputsProperties surfaceInputs;
        private PropertyStructures.TessellationOptions tessellationOptions;
        private PropertyStructures.EmissionInputs emissionInputs;
        private PropertyStructures.AdvancedOptions advancedOptions;

        public override void FindProperties(MaterialProperty[] properties)
        {
            surfaceOptions = new PropertyStructures.SurfaceOptions(properties);
            
            displacementMode = BaseShaderGUI.FindProperty("_DisplacementMode", properties, false);
            PPDMinSamples = BaseShaderGUI.FindProperty("_PPDMinSamples", properties, false);
            PPDMaxSamples = BaseShaderGUI.FindProperty("_PPDMaxSamples", properties, false);
            PPDLodThreshold = BaseShaderGUI.FindProperty("_PPDLodThreshold", properties, false);
            lockWithObjectScale = BaseShaderGUI.FindProperty("_DisplacementLockObjectScale", properties, false);

            // Tessellation Options Props
            tessellationOptions = new PropertyStructures.TessellationOptions(properties);
            
            surfaceInputs = new PropertyStructures.LayeredSurfaceInputsProperties(properties);

            int m_LayerCount = (int)surfaceInputs.layerCount.floatValue;

            for (int i = 1; i < kMaxLayerCount; ++i)
            {
                // Influence
                inheritBaseNormal[i - 1] = FindProperty(string.Format("{0}{1}", kInheritBaseNormal, i), properties);
                inheritBaseHeight[i - 1] = FindProperty(string.Format("{0}{1}", kInheritBaseHeight, i), properties);
                inheritBaseColor[i - 1] = FindProperty(string.Format("{0}{1}", kInheritBaseColor, i), properties);
            }

            opacityAsDensity = SetMaterialProperties.FindPropertyLayered(kOpacityAsDensity, properties, m_LayerCount);

            baseColor = SetMaterialProperties.FindPropertyLayered(kBaseColor, properties, m_LayerCount);
            baseColorMap = SetMaterialProperties.FindPropertyLayered(kBaseColorMap, properties, m_LayerCount);
            metallic = SetMaterialProperties.FindPropertyLayered(kMetallic, properties, m_LayerCount);
            metallicRemapMin = SetMaterialProperties.FindPropertyLayered(kMetallicRemapMin, properties, m_LayerCount);
            metallicRemapMax = SetMaterialProperties.FindPropertyLayered(kMetallicRemapMax, properties, m_LayerCount);
            smoothness = SetMaterialProperties.FindPropertyLayered(kSmoothness, properties, m_LayerCount);
            smoothnessRemapMin = SetMaterialProperties.FindPropertyLayered(kSmoothnessRemapMin, properties, m_LayerCount);
            smoothnessRemapMax = SetMaterialProperties.FindPropertyLayered(kSmoothnessRemapMax, properties, m_LayerCount);
            aoRemapMin = SetMaterialProperties.FindPropertyLayered(kAORemapMin, properties, m_LayerCount);
            aoRemapMax = SetMaterialProperties.FindPropertyLayered(kAORemapMax, properties, m_LayerCount);
            maskMap = SetMaterialProperties.FindPropertyLayered(kMaskMap, properties, m_LayerCount);
            normalMap = SetMaterialProperties.FindPropertyLayered(kNormalMap, properties, m_LayerCount);
            normalScale = SetMaterialProperties.FindPropertyLayered(kNormalScale, properties, m_LayerCount);
            bentNormalMap = SetMaterialProperties.FindPropertyLayered(kBentNormalMap, properties, m_LayerCount);

            // Height
            heightMap = SetMaterialProperties.FindPropertyLayered(kHeightMap, properties, m_LayerCount);
            heightParametrization = SetMaterialProperties.FindPropertyLayered(kHeightParametrization, properties, m_LayerCount);
            heightTessCenter = SetMaterialProperties.FindPropertyLayered(kHeightTessCenter, properties, m_LayerCount);
            heightTessAmplitude = SetMaterialProperties.FindPropertyLayered(kHeightTessAmplitude, properties, m_LayerCount);
            heightMin = SetMaterialProperties.FindPropertyLayered(kHeightMin, properties, m_LayerCount);
            heightMax = SetMaterialProperties.FindPropertyLayered(kHeightMax, properties, m_LayerCount);
            heightOffset = SetMaterialProperties.FindPropertyLayered(kHeightOffset, properties, m_LayerCount);
            heightPoMAmplitude = SetMaterialProperties.FindPropertyLayered(kHeightPoMAmplitude, properties, m_LayerCount);

            // Detail
            detailMap = SetMaterialProperties.FindPropertyLayered(kDetailMap, properties, m_LayerCount);
            detailAlbedoScale = SetMaterialProperties.FindPropertyLayered(kDetailAlbedoScale, properties, m_LayerCount);
            detailNormalScale = SetMaterialProperties.FindPropertyLayered(kDetailNormalScale, properties, m_LayerCount);
            detailSmoothnessScale = SetMaterialProperties.FindPropertyLayered(kDetailSmoothnessScale, properties, m_LayerCount);

			// Emission Props
            emissionInputs = new PropertyStructures.EmissionInputs(properties);

            // Advanced Props
            advancedOptions = new PropertyStructures.AdvancedOptions(properties);
        }

        public override void ValidateMaterial(Material material)
        {
            SetMaterialProperties.SetLitMaterialKeywords(material);
        }

        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] properties)
        {
            if (materialEditorIn == null)
                throw new ArgumentNullException("materialEditorIn");

            materialEditor = materialEditorIn;
            Material material = materialEditor.target as Material;

            FindProperties(properties);   // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly

            // SurfaceOptions
            using (var header = new MaterialHeaderScope(Styles.SurfaceOptions, (uint)LitExpandable.SurfaceOptions, materialEditor))
            {
                if (header.expanded)
                {
                    DrawSurfaceOptions(material);
                }
            }

            // Tessellation
            if (material.HasProperty("_TessellationMode"))
            {
                using (var header = new MaterialHeaderScope(URPPlusStyles.TessellationOptions, (uint)LitExpandable.Tessellation, materialEditor))
                {
                    if (header.expanded)
                    {
                        DrawTessellationOptions(material);
                    }
                }
            }

            // SurfaceInputs
            using (var header = new MaterialHeaderScope(Styles.SurfaceInputs, (uint)LitExpandable.SurfaceInputs, materialEditor))
            {
                if (header.expanded)
                {
                    DrawLayeredSurfaceInputs(material);
                }
            }

            // Layers
            var iconSize = EditorGUIUtility.GetIconSize();
            for (int layerIndex = 0; layerIndex < surfaceInputs.layerCount.floatValue; layerIndex++)
            {
                EditorGUIUtility.SetIconSize(LayeredStyles.layerIconSize);
                using (var header = new MaterialHeaderScope(LayeredStyles.layers[layerIndex], (uint)LayeredStyles.layerExpandableBits[layerIndex], materialEditor))
                {
                    if (header.expanded)
                    {
                        EditorGUIUtility.SetIconSize(iconSize);
                        DrawLayer(material, materialEditor, layerIndex);
                    }
                }
            }

            // EmissionInputs
            using (var header = new MaterialHeaderScope(URPPlusStyles.EmissionInputs, (uint)LitExpandable.Emission, materialEditor))
            {
                if (header.expanded)
                {
                    DrawEmissionInputs(material);
                }
            }

            // AdvancedOptions
            using (var header = new MaterialHeaderScope(Styles.AdvancedLabel, (uint)LitExpandable.Advanced, materialEditor))
            {
                if (header.expanded)
                {
                    DrawAdvancedOptions(material);
                }
            }
        }

        // material main surface options
        public override void DrawSurfaceOptions(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

            if (surfaceOptions.workflowMode != null)
                DoPopup(LitGUI.Styles.workflowModeText, surfaceOptions.workflowMode, Enum.GetNames(typeof(WorkflowMode)));

            DoPopup(URPPlusStyles.surfaceTypeText, surfaceOptions.surfaceType, Enum.GetNames(typeof(SurfaceType)));
            EditorGUI.indentLevel++;
            if ((surfaceOptions.surfaceType != null) && ((SurfaceType)surfaceOptions.surfaceType.floatValue == SurfaceType.Transparent))
            {
                DoPopup(URPPlusStyles.blendingModeText, surfaceOptions.blendMode, Enum.GetNames(typeof(BlendMode)));
                //DepthWrite and DepthTest
                materialEditor.DrawFloatToggleProperty(URPPlusStyles.zWriteEnableText, surfaceOptions.depthWrite);
                if (surfaceOptions.depthTest != null)
                    materialEditor.PopupShaderProperty(surfaceOptions.depthTest, URPPlusStyles.transparentZTestText, Enum.GetNames(typeof(UnityEngine.Rendering.CompareFunction)));
            }
            DoPopup(URPPlusStyles.cullingText, surfaceOptions.renderFace, Styles.renderFaceNames);
            materialEditor.DrawNormalModeArea(material, surfaceOptions.doubleSidedNormalMode);
            EditorGUI.indentLevel--;

            // AlphaClipping
            materialEditor.DrawAlphaCutoffGUI(material, surfaceOptions.alphaCutoffEnable, surfaceOptions.alphaCutoff, surfaceOptions.useShadowThreshold, surfaceOptions.alphaCutoffShadow);
            // Geometric Specular AA
            materialEditor.DrawSpecularAAArea(surfaceOptions.specularAA, surfaceOptions.specularAAScreenSpaceVariance, surfaceOptions.specularAAThreshold);
            // Displacement Mode
            materialEditor.DrawDisplacementGUI(material, displacementMode, PPDMinSamples, PPDMaxSamples, PPDLodThreshold, lockWithObjectScale);
            EditorGUILayout.EndVertical();
        }

        // material main tessellation options
        public void DrawTessellationOptions(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

            materialEditor.ShaderProperty(tessellationOptions.tessellationMode, URPPlusStyles.tessellationModeText);
            TessellationMode tessellationModeEnum = (TessellationMode)tessellationOptions.tessellationMode.floatValue;
            materialEditor.DrawFloatToggleProperty(URPPlusStyles.phongTessellationText, tessellationOptions.phongTessellationEnable);
            
            if(tessellationOptions.phongTessellationEnable.floatValue == 1)
                materialEditor.ShaderProperty(tessellationOptions.tessellationShapeFactor, URPPlusStyles.tessellationShapeFactorText);

            if(tessellationModeEnum == TessellationMode.EdgeLength)
            {
                materialEditor.ShaderProperty(tessellationOptions.tessellationFactor, URPPlusStyles.tessellationFactorText);
                materialEditor.ShaderProperty(tessellationOptions.tessellationEdgeLength, URPPlusStyles.tessellationEdgeLengthText);
            }
            else if(tessellationModeEnum == TessellationMode.Distance)
            {
                materialEditor.ShaderProperty(tessellationOptions.tessellationFactor, URPPlusStyles.tessellationFactorText);
                materialEditor.ShaderProperty(tessellationOptions.tessellationFactorMinDistance, URPPlusStyles.tessellationFactorMinDistanceText);
                materialEditor.ShaderProperty(tessellationOptions.tessellationFactorMaxDistance, URPPlusStyles.tessellationFactorMaxDistanceText);
            }
            else
            {
                materialEditor.ShaderProperty(tessellationOptions.tessellationFactor, URPPlusStyles.tessellationFactorText);
            }
            materialEditor.ShaderProperty(tessellationOptions.tessellationBackFaceCullEpsilon, URPPlusStyles.tessellationBackFaceCullEpsilonText);
            EditorGUILayout.EndVertical();
        }

        // material main surface inputs
        public void DrawLayeredSurfaceInputs(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            materialEditor.IntSliderShaderProperty(surfaceInputs.layerCount, 2, 4, URPPlusStyles.layerCountText);
            materialEditor.TexturePropertySingleLine(URPPlusStyles.layerMapMaskText, surfaceInputs.layerMask);
            materialEditor.TextureScaleOffsetProperty(surfaceInputs.layerMask);

            //Vertex Color Mode
            DoPopup(URPPlusStyles.vertexColorModeText, surfaceInputs.vertexColorMode, Enum.GetNames(typeof(VertexColorMode)));
            //Main Influence
            materialEditor.DrawFloatToggleProperty(URPPlusStyles.useMainLayerInfluenceModeText, surfaceInputs.mainInfluenceProp);
            //Height Base Blending
            materialEditor.DrawFloatToggleProperty(URPPlusStyles.useHeightBasedBlendText, surfaceInputs.heightBasedBlendingProp);
            if(material.GetFloat("_UseHeightBasedBlend") != 0.0f)
                materialEditor.ShaderProperty(surfaceInputs.heightTransitionProp, URPPlusStyles.heightTransition);

            EditorGUILayout.EndVertical();
        }
        

        private void DrawLayer(Material material, MaterialEditor materialEditor, int m_LayerIndex = 0)
        {
            EditorGUIUtility.labelWidth = 0f;

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Layering Options", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            if(m_LayerIndex == 0)
            {
                materialEditor.TexturePropertySingleLine(URPPlusStyles.layerInfluenceMapMaskText, surfaceInputs.layerInfluenceMaskMap);
                EditorGUILayout.Space();
            }
            else
            {
                materialEditor.DrawFloatToggleProperty(URPPlusStyles.opacityAsDensityText, opacityAsDensity[m_LayerIndex]);
                if(surfaceInputs.mainInfluenceProp.floatValue == 1)
                {
                    materialEditor.ShaderProperty(inheritBaseColor[m_LayerIndex - 1], URPPlusStyles.inheritBaseColorText);
                    materialEditor.ShaderProperty(inheritBaseNormal[m_LayerIndex - 1], URPPlusStyles.inheritBaseNormalText);
                    materialEditor.ShaderProperty(inheritBaseHeight[m_LayerIndex - 1], URPPlusStyles.inheritBaseHeightText);
                    EditorGUILayout.Space();
                }
            }
            EditorGUILayout.EndVertical();
            
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Surface Inputs", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            //BaseMap
            materialEditor.TexturePropertySingleLine(URPPlusStyles.baseColorText, baseColorMap[m_LayerIndex], baseColor[m_LayerIndex]);
            //MaskMap
            if (maskMap[m_LayerIndex].textureValue != null)
            {
                materialEditor.MinMaxShaderProperty(metallicRemapMin[m_LayerIndex], metallicRemapMax[m_LayerIndex], 0.0f, 1.0f, URPPlusStyles.metallicRemappingText);
                materialEditor.MinMaxShaderProperty(smoothnessRemapMin[m_LayerIndex], smoothnessRemapMax[m_LayerIndex], 0.0f, 1.0f, URPPlusStyles.smoothnessRemappingText);
                materialEditor.MinMaxShaderProperty(aoRemapMin[m_LayerIndex], aoRemapMax[m_LayerIndex], 0.0f, 1.0f, URPPlusStyles.aoRemappingText);
            }
            else
            {
                materialEditor.ShaderProperty(metallic[m_LayerIndex], URPPlusStyles.metallicText);
                materialEditor.ShaderProperty(smoothness[m_LayerIndex], URPPlusStyles.smoothnessText);
            }
            materialEditor.TexturePropertySingleLine(URPPlusStyles.maskMapSText, maskMap[m_LayerIndex]);
            //NormalMap
            BaseShaderGUI.DrawNormalArea(materialEditor, normalMap[m_LayerIndex], normalScale[m_LayerIndex]);
            //BentNormalMap
            materialEditor.TexturePropertySingleLine(URPPlusStyles.bentNormalMapText, bentNormalMap[m_LayerIndex]);

            //Height Map
            materialEditor.TexturePropertySingleLine(URPPlusStyles.heightMapText, heightMap[m_LayerIndex]);
            if(heightMap[m_LayerIndex].textureValue != null)
            {
                DisplacementMode displacementModeEnum = (DisplacementMode)displacementMode.floatValue;
                HeightParametrization heightParametrizationEnum = (HeightParametrization)heightParametrization[m_LayerIndex].floatValue;
                if(displacementModeEnum == DisplacementMode.PixelDisplacement)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(heightPoMAmplitude[m_LayerIndex], URPPlusStyles.heightMapAmplitudeText);
                    material.SetFloat(SetMaterialProperties.LayeredKeyWord("_HeightAmplitude", m_LayerIndex), material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightPoMAmplitude", m_LayerIndex)) * 0.01f); // Convert centimeters to meters.
                    material.SetFloat(SetMaterialProperties.LayeredKeyWord("_HeightCenter", m_LayerIndex), 1.0f);
                    EditorGUI.indentLevel--;
                }
                else
                {
                    EditorGUI.indentLevel++;
                    //Height Parametrization
                    EditorGUI.BeginChangeCheck();
                    heightParametrizationEnum = (HeightParametrization)EditorGUILayout.EnumPopup(URPPlusStyles.heightMapParametrization, heightParametrizationEnum);
                    if (EditorGUI.EndChangeCheck()) 
                    {
	                    materialEditor.RegisterPropertyChangeUndo("Parametrization");
	                    heightParametrization[m_LayerIndex].floatValue = (float)heightParametrizationEnum;
	                }
                    if(heightParametrizationEnum == HeightParametrization.Amplitude)
                    {
                        materialEditor.ShaderProperty(heightTessAmplitude[m_LayerIndex], URPPlusStyles.heightMapAmplitudeText);
                        materialEditor.ShaderProperty(heightTessCenter[m_LayerIndex], URPPlusStyles.heightMapCenterText);
                        float offset = material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightOffset", m_LayerIndex));
                        float center = material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightTessCenter", m_LayerIndex));
                        float amplitude = material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightTessAmplitude", m_LayerIndex));
                        material.SetFloat(SetMaterialProperties.LayeredKeyWord("_HeightAmplitude", m_LayerIndex), amplitude * 0.01f); // Convert centimeters to meters.
                        material.SetFloat(SetMaterialProperties.LayeredKeyWord("_HeightCenter", m_LayerIndex), -offset / Mathf.Max(1e-6f, amplitude) + center);
                    }
                    else
                    {
                        materialEditor.ShaderProperty(heightMin[m_LayerIndex], URPPlusStyles.heightMapMinText);
                        materialEditor.ShaderProperty(heightMax[m_LayerIndex], URPPlusStyles.heightMapMaxText);
                        float offset = material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightOffset", m_LayerIndex));
                        float minHeight = material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightMin", m_LayerIndex));
                        float amplitude = material.GetFloat(SetMaterialProperties.LayeredKeyWord("_HeightMax", m_LayerIndex)) - minHeight;
                        material.SetFloat(SetMaterialProperties.LayeredKeyWord("_HeightAmplitude", m_LayerIndex), amplitude * 0.01f); // Convert centimeters to meters.
                        material.SetFloat(SetMaterialProperties.LayeredKeyWord("_HeightCenter", m_LayerIndex), -(minHeight + offset) / Mathf.Max(1e-6f, amplitude));
                    }
                    materialEditor.ShaderProperty(heightOffset[m_LayerIndex], URPPlusStyles.heightMapOffsetText);
                    EditorGUI.indentLevel--;
                }
            }
            materialEditor.TextureScaleOffsetProperty(baseColorMap[m_LayerIndex]);
            EditorGUILayout.EndVertical();

            //Detail Map
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Detail Inputs", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            materialEditor.TexturePropertySingleLine(URPPlusStyles.detailMapNormalText, detailMap[m_LayerIndex]);
            if (detailMap[m_LayerIndex].textureValue != null)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(detailAlbedoScale[m_LayerIndex], URPPlusStyles.detailAlbedoScaleText);
                materialEditor.ShaderProperty(detailNormalScale[m_LayerIndex], URPPlusStyles.detailNormalScaleText);
                materialEditor.ShaderProperty(detailSmoothnessScale[m_LayerIndex], URPPlusStyles.detailSmoothnessScaleText);
                EditorGUI.indentLevel--;
                materialEditor.TextureScaleOffsetProperty(detailMap[m_LayerIndex]);
            }
            EditorGUILayout.EndVertical();
        }

        public void DrawEmissionInputs(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            materialEditor.DrawEmissionSettings(material, emissionInputs.emissionWithBase, emissionInputs.emissionMap, emissionInputs.emissionColor, emissionInputs.emissionScale);
            materialEditor.TextureScaleOffsetProperty(emissionInputs.emissionMap);
            EditorGUILayout.EndVertical();
        }

        // material main advanced options
        public override void DrawAdvancedOptions(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            if ((SurfaceType)surfaceOptions.surfaceType.floatValue == SurfaceType.Transparent)
                SetMaterialProperties.DrawFloatToggleProperty(Styles.castShadowText, castShadowsProp);

            SetMaterialProperties.DrawFloatToggleProperty(Styles.receiveShadowText, receiveShadowsProp);
            if (advancedOptions.reflections != null && advancedOptions.highlights != null)
            {
                materialEditor.ShaderProperty(advancedOptions.highlights, URPPlusStyles.highlightsText);
                materialEditor.ShaderProperty(advancedOptions.reflections, URPPlusStyles.reflectionsText);
            }
            EditorGUILayout.Space();
            base.DrawAdvancedOptions(material);
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            //HorizonOcclusion
            SetMaterialProperties.DrawFloatToggleProperty(URPPlusStyles.horizonOcclusionText, advancedOptions.horizonOcclusion);
            if (advancedOptions.horizonOcclusion.floatValue == 1) 
            {
                EditorGUI.indentLevel++;
	        	materialEditor.ShaderProperty(advancedOptions.horizonFade, "Horizon Fade");
                EditorGUI.indentLevel--;
	        }
            //SpecularOcclusion Mode
            materialEditor.ShaderProperty(advancedOptions.specularOcclusionMode, URPPlusStyles.specularOcclusionModeText);

            EditorGUI.indentLevel++;
            if((SpecularOcclusionMode)advancedOptions.specularOcclusionMode.floatValue == SpecularOcclusionMode.FromGI)
                    materialEditor.ShaderProperty(advancedOptions.giOcclusionBias, URPPlusStyles.giOcclusionBiasText);
            EditorGUI.indentLevel--;

            EditorGUILayout.EndVertical();
        }
    }
}