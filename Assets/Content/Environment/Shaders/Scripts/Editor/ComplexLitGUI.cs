using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public class ComplexLitShaderGUI : BaseShaderGUI
    {
        private MaterialProperty materialType;
        private MaterialProperty transmissionEnable;
        private MaterialProperty sssShadowsEnable;

        private MaterialProperty baseColor;
		private MaterialProperty baseMap;

        private MaterialProperty maskMap;
        private MaterialProperty metallic;
        private MaterialProperty metallicMin;
        private MaterialProperty metallicMax;
        private MaterialProperty smoothness;
		private MaterialProperty smoothnessMin;
        private MaterialProperty smoothnessMax;
        private MaterialProperty aoMin;
        private MaterialProperty aoMax;

        private MaterialProperty bumpMap;
		private MaterialProperty bumpMapScale;
        private MaterialProperty bentNormalMap;

        private MaterialProperty specularMap;
        private MaterialProperty specularColor;

        private MaterialProperty clearCoatMap;
        private MaterialProperty clearCoatMask;
        private MaterialProperty clearCoatSmoothness;
        private MaterialProperty coatNormalEnabled;
        private MaterialProperty coatNormalMap;
        private MaterialProperty coatNormalScale;

        private MaterialProperty sssLUT;
        private MaterialProperty scatteringColor;
        private MaterialProperty scatteredShadowsColor;
        private MaterialProperty transmissionScale;

        private MaterialProperty thickness;
        private MaterialProperty curvature;
        private MaterialProperty thicknessCurvatureMap;
        private MaterialProperty thicknessCurvatureRemap;

        private MaterialProperty translucencyScale;
        private MaterialProperty translucencyPower;
        private MaterialProperty translucencyAmbient;
        private MaterialProperty translucencyDistortion;
        private MaterialProperty translucencyShadowsStrength;

        private MaterialProperty tangentMap;
        private MaterialProperty anisotropyMap;
        private MaterialProperty anisotropy;

        private MaterialProperty iridescenceLUT;
        private MaterialProperty iridescenceShift;
        private MaterialProperty iridescenceThicknessMap;
        private MaterialProperty iridescenceThickness;
        private MaterialProperty iridescenceThicknessRemap;
        private MaterialProperty iridescenceMaskMap;
        private MaterialProperty iridescenceMaskScale;

        private MaterialProperty heightMap;
        private MaterialProperty heightParametrization;
        private MaterialProperty heightCenter;
        private MaterialProperty heightAmplitude;
        private MaterialProperty heightTessCenter;
        private MaterialProperty heightTessAmplitude;
        private MaterialProperty heightMin;
        private MaterialProperty heightMax;
        private MaterialProperty heightOffset;
    	private MaterialProperty heightPoMAmplitude;

		private MaterialProperty detailMap;
		private MaterialProperty detailAlbedoScale;
		private MaterialProperty detailNormalScale;
		private MaterialProperty detailSmoothnessScale;

        private PropertyStructures.SurfaceOptions surfaceOptions;
        private PropertyStructures.DisplacementBlock displacementBlock;
        private PropertyStructures.TessellationOptions tessellationOptions;
        private PropertyStructures.EmissionInputs emissionInputs;
        private PropertyStructures.AdvancedOptions advancedOptions;

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            
            // Surface Options Props
            surfaceOptions = new PropertyStructures.SurfaceOptions(properties);
            
            materialType = BaseShaderGUI.FindProperty("_MaterialType", properties, false);
            transmissionEnable = BaseShaderGUI.FindProperty("_TransmissionEnable", properties, false);
            sssShadowsEnable = BaseShaderGUI.FindProperty("_SSSShadowsEnable", properties, false);

            displacementBlock = new PropertyStructures.DisplacementBlock(properties);

            // Tessellation Options Props
            tessellationOptions = new PropertyStructures.TessellationOptions(properties);

            // Surface Input Props
            // BaseMap properties
            baseMap = BaseShaderGUI.FindProperty("_BaseMap", properties, false); 
            baseColor = BaseShaderGUI.FindProperty("_BaseColor", properties, false);
            // MaskMap properties
            maskMap = BaseShaderGUI.FindProperty("_MaskMap", properties, false);
            metallic = BaseShaderGUI.FindProperty("_Metallic", properties, false);
            metallicMin = BaseShaderGUI.FindProperty("_MetallicRemapMin", properties, false);
            metallicMax = BaseShaderGUI.FindProperty("_MetallicRemapMax", properties, false);
            smoothness = BaseShaderGUI.FindProperty("_Smoothness", properties, false);
            smoothnessMin = BaseShaderGUI.FindProperty("_SmoothnessRemapMin", properties, false);
            smoothnessMax = BaseShaderGUI.FindProperty("_SmoothnessRemapMax", properties, false);
            aoMin = BaseShaderGUI.FindProperty("_AORemapMin", properties, false);
            aoMax = BaseShaderGUI.FindProperty("_AORemapMax", properties, false);
            // NormalMap properties
            bumpMap = BaseShaderGUI.FindProperty("_BumpMap", properties, false);
            bumpMapScale = BaseShaderGUI.FindProperty("_BumpScale", properties, false);
            bentNormalMap = BaseShaderGUI.FindProperty("_BentNormalMap", properties, false);
            // SpecularMap properties
            specularColor = BaseShaderGUI.FindProperty("_SpecularColor", properties, false);
            specularMap = BaseShaderGUI.FindProperty("_SpecularColorMap", properties, false);
            //ClearCoat
            clearCoatMap = BaseShaderGUI.FindProperty("_ClearCoatMap", properties, false);
            clearCoatMask = BaseShaderGUI.FindProperty("_ClearCoatMask", properties, false);
            clearCoatSmoothness = BaseShaderGUI.FindProperty("_ClearCoatSmoothness", properties, false);
            coatNormalEnabled = BaseShaderGUI.FindProperty("_CoatNormal", properties, false);
            coatNormalMap = BaseShaderGUI.FindProperty("_CoatNormalMap", properties, false);
            coatNormalScale = BaseShaderGUI.FindProperty("_CoatNormalScale", properties, false);

            //SSS
            sssLUT = BaseShaderGUI.FindProperty("_SSSLUT", properties, false);
            scatteringColor = BaseShaderGUI.FindProperty("_ScatteringColor", properties, false);
            scatteredShadowsColor = BaseShaderGUI.FindProperty("_ScatteringShadowsColor", properties, false);
            transmissionScale = BaseShaderGUI.FindProperty("_TransmissionScale", properties, false);
            //Translucency
            thickness = BaseShaderGUI.FindProperty("_Thickness", properties, false);
            curvature = BaseShaderGUI.FindProperty("_Curvature", properties, false);
            thicknessCurvatureMap = BaseShaderGUI.FindProperty("_ThicknessCurvatureMap", properties, false);
            thicknessCurvatureRemap = BaseShaderGUI.FindProperty("_ThicknessCurvatureRemap", properties, false);
            translucencyScale = BaseShaderGUI.FindProperty("_TranslucencyScale", properties, false);
            translucencyPower = BaseShaderGUI.FindProperty("_TranslucencyPower", properties, false);
            translucencyAmbient = BaseShaderGUI.FindProperty("_TranslucencyAmbient", properties, false);
            translucencyDistortion = BaseShaderGUI.FindProperty("_TranslucencyDistortion", properties, false);
            translucencyShadowsStrength = BaseShaderGUI.FindProperty("_TranslucencyShadows", properties, false);
            //Anisotropy properties
            tangentMap = BaseShaderGUI.FindProperty("_TangentMap", properties, false);
            anisotropy = BaseShaderGUI.FindProperty("_Anisotropy", properties, false);
            anisotropyMap = BaseShaderGUI.FindProperty("_AnisotropyMap", properties, false);
            //Iridescence properties
            iridescenceLUT = BaseShaderGUI.FindProperty("_IridescenceLUT", properties, false);
            iridescenceShift = BaseShaderGUI.FindProperty("_IridescenceShift", properties, false);
            iridescenceThicknessMap = BaseShaderGUI.FindProperty("_IridescenceThicknessMap", properties, false);
            iridescenceThickness = BaseShaderGUI.FindProperty("_IridescenceThickness", properties, false);
            iridescenceThicknessRemap = BaseShaderGUI.FindProperty("_IridescenceThicknessRemap", properties, false);
            iridescenceMaskMap = BaseShaderGUI.FindProperty("_IridescenceMaskMap", properties, false);
            iridescenceMaskScale = BaseShaderGUI.FindProperty("_IridescenceMaskScale", properties, false);

            // HeightMap properties
            heightMap = BaseShaderGUI.FindProperty("_HeightMap", properties, false);
            heightParametrization = BaseShaderGUI.FindProperty("_HeightMapParametrization", properties, false);
            heightCenter = BaseShaderGUI.FindProperty("_HeightCenter", properties, false);
            heightAmplitude = BaseShaderGUI.FindProperty("_HeightAmplitude", properties, false);
            heightTessCenter = BaseShaderGUI.FindProperty("_HeightTessCenter", properties, false);
            heightTessAmplitude = BaseShaderGUI.FindProperty("_HeightTessAmplitude", properties, false);
            heightMin = BaseShaderGUI.FindProperty("_HeightMin", properties, false);
            heightMax = BaseShaderGUI.FindProperty("_HeightMax", properties, false);
            heightOffset = BaseShaderGUI.FindProperty("_HeightOffset", properties, false);
            heightPoMAmplitude = BaseShaderGUI.FindProperty("_HeightPoMAmplitude", properties, false);

		    // Detail properties
		    detailMap = BaseShaderGUI.FindProperty("_DetailMap", properties, false);
            detailAlbedoScale = BaseShaderGUI.FindProperty("_DetailAlbedoScale", properties, false);
		    detailNormalScale = BaseShaderGUI.FindProperty("_DetailNormalScale", properties, false);
		    detailSmoothnessScale = BaseShaderGUI.FindProperty("_DetailSmoothnessScale", properties, false);

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
                    DrawSurfaceInputs(material);
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
        {EditorGUILayout.BeginVertical(EditorStyles.helpBox);
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

            //MaterialType
            materialEditor.PopupShaderProperty(materialType, URPPlusStyles.materialIDText, Enum.GetNames(typeof(MaterialType)));
            if ((MaterialType)materialType.floatValue == MaterialType.SubsurfaceScattering)
            {
                EditorGUI.indentLevel++;
                materialEditor.DrawFloatToggleProperty(URPPlusStyles.transmissionEnableText, transmissionEnable);
                materialEditor.DrawFloatToggleProperty(new GUIContent("Fake SSS Shadows"), sssShadowsEnable);
                EditorGUI.indentLevel--;
            }

            // Geometric Specular AA
            materialEditor.DrawSpecularAAArea(surfaceOptions.specularAA, surfaceOptions.specularAAScreenSpaceVariance, surfaceOptions.specularAAThreshold);
            
            //Displacement Mode
            materialEditor.DrawDisplacementGUI(material, displacementBlock.displacementMode, displacementBlock.PPDMinSamples, displacementBlock.PPDMaxSamples, displacementBlock.PPDLodThreshold, displacementBlock.lockWithObjectScale);
            if((DisplacementMode)displacementBlock.displacementMode.floatValue == DisplacementMode.PixelDisplacement)
            {
                EditorGUI.indentLevel++;
                materialEditor.MinFloatShaderProperty(displacementBlock.ppdPrimitiveLength, URPPlusStyles.ppdPrimitiveLength, 0.01f);
                materialEditor.MinFloatShaderProperty(displacementBlock.ppdPrimitiveWidth, URPPlusStyles.ppdPrimitiveWidth, 0.01f);
                displacementBlock.invPrimScale.vectorValue = new Vector4(1.0f / displacementBlock.ppdPrimitiveLength.floatValue, 1.0f / displacementBlock.ppdPrimitiveWidth.floatValue);
                materialEditor.DrawFloatToggleProperty(new GUIContent("DepthOffset"), displacementBlock.depthOffset);
                EditorGUI.indentLevel--;
            } 
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
        public override void DrawSurfaceInputs(Material material)
        {
            //////////////////////
            /*****Base Block*****/
            //////////////////////
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Base Block", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            
            DrawBaseProperties(material);
            materialEditor.DrawMaskMapArea(surfaceOptions.workflowMode, maskMap, metallic, smoothness, 
                                            metallicMin, metallicMax, smoothnessMin, smoothnessMax, aoMin, aoMax);
            //SpecularColor
            if((WorkflowMode)surfaceOptions.workflowMode.floatValue == WorkflowMode.Specular)
                materialEditor.TexturePropertySingleLine(URPPlusStyles.specularColorText, specularMap, specularColor);
            
            BaseShaderGUI.DrawNormalArea(materialEditor, bumpMap, bumpMapScale);
            materialEditor.TexturePropertySingleLine(URPPlusStyles.bentNormalMapText, bentNormalMap);

            //ClearCoat
            materialEditor.TexturePropertySingleLine(URPPlusStyles.clearCoatMaskText, clearCoatMap, clearCoatMask);
            if (clearCoatMask.floatValue > 0) 
            {
                materialEditor.ShaderProperty(clearCoatSmoothness, URPPlusStyles.clearCoatSmoothnessText);
                if(coatNormalEnabled.floatValue == 1)
                {
                    materialEditor.TexturePropertySingleLine(URPPlusStyles.coatNormalMapText, coatNormalMap, coatNormalMap.textureValue != null ? coatNormalScale : null);
                }
            }

            //Tilling
			materialEditor.TextureScaleOffsetProperty(baseMap);
            EditorGUILayout.EndVertical();

            
            ////////////////////////
            /*****Height Block*****/
            ////////////////////////
            DisplacementMode displacementModeEnum = (DisplacementMode)displacementBlock.displacementMode.floatValue;
            if(displacementModeEnum != DisplacementMode.None)
                DrawHeightBlock(material);

            ////////////////////////////
            /*****MaterialID Block*****/
            ////////////////////////////
            if((MaterialType)materialType.floatValue != MaterialType.Standard)
                DrawMaterialIDBlock(material);
            

            ////////////////////////
            /*****Detail Block*****/
            ////////////////////////
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Detail Block", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            materialEditor.TexturePropertySingleLine(URPPlusStyles.detailMapNormalText, detailMap);
            if(detailMap.textureValue != null)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(detailAlbedoScale, URPPlusStyles.detailAlbedoScaleText);
                materialEditor.ShaderProperty(detailNormalScale, URPPlusStyles.detailNormalScaleText);
                materialEditor.ShaderProperty(detailSmoothnessScale, URPPlusStyles.detailSmoothnessScaleText);
                EditorGUI.indentLevel--;

			    materialEditor.TextureScaleOffsetProperty(detailMap);
            }
            EditorGUILayout.EndVertical();
        }

        void DrawMaterialIDBlock(Material material)
        {
            string blockName = "";
            MaterialType materialTypeEnum = (MaterialType)materialType.floatValue;
            switch(materialTypeEnum)
            {
                case MaterialType.SubsurfaceScattering:
                    blockName = "SSS Block";
                    break;
                case MaterialType.Anisotropy:
                    blockName = "Anisotropy Block";
                    break;
                case MaterialType.Iridescence:
                    blockName = "Iridescence Block";
                    break;
                case MaterialType.Translucency:
                    blockName = "Translucency Block";
                    break;
            }
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField(blockName, EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            //SubsurfaceScattering
            if(materialTypeEnum == MaterialType.SubsurfaceScattering)
            {
                if(URPPlusSettings.sssLUT == true)
                    materialEditor.TexturePropertySingleLine(new GUIContent("SSS LUT"), sssLUT);

                //ThicknessCurvatureMap
                if(thicknessCurvatureMap.textureValue != null)
                {
                    materialEditor.TexturePropertySingleLine(URPPlusStyles.thicknessCurvatureMapText, thicknessCurvatureMap, scatteringColor);
                    EditorGUI.indentLevel++;
                    materialEditor.MinMaxShaderPropertyXY(thicknessCurvatureRemap, 0.0f, 1.0f, URPPlusStyles.thicknessRemapText);
                    materialEditor.MinMaxShaderPropertyZW(thicknessCurvatureRemap, 0.0f, 1.0f, URPPlusStyles.curvatureRemapText);
                    EditorGUI.indentLevel--;
                }
                else
                {
                    materialEditor.TexturePropertySingleLine(URPPlusStyles.thicknessCurvatureMapText, thicknessCurvatureMap, scatteringColor);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(thickness, URPPlusStyles.thicknessText);
                    materialEditor.ShaderProperty(curvature, URPPlusStyles.curvatureText);
                    EditorGUI.indentLevel--;
                }
                EditorGUI.indentLevel++;
                if(transmissionEnable.floatValue >= 0.5f)
                    materialEditor.ShaderProperty(transmissionScale, URPPlusStyles.transmissionScaleText);
                if(sssShadowsEnable.floatValue >= 0.5f)
                    materialEditor.ShaderProperty(scatteredShadowsColor, new GUIContent("ScatteredShadows Color"));
                EditorGUI.indentLevel--;
            }
            
            //Anisotropy
            if(materialTypeEnum == MaterialType.Anisotropy)
            {
                materialEditor.TexturePropertySingleLine(URPPlusStyles.tangentMapText, tangentMap);
                materialEditor.ShaderProperty(anisotropy, URPPlusStyles.anisotropyText);
                materialEditor.TexturePropertySingleLine(URPPlusStyles.anisotropyMapText, anisotropyMap);
            }

            //Iridescence
            if(materialTypeEnum == MaterialType.Iridescence)
            {
                if(URPPlusSettings.iridescenceLUT == true)
                    materialEditor.TexturePropertySingleLine(URPPlusStyles.iridescenceLUTText, iridescenceLUT, iridescenceShift);
                
                materialEditor.TexturePropertySingleLine(URPPlusStyles.iridescenceMaskText, iridescenceMaskMap, iridescenceMaskScale);
                if(iridescenceThicknessMap.textureValue != null)
                {
                    materialEditor.TexturePropertySingleLine(URPPlusStyles.iridescenceThicknessMapText, iridescenceThicknessMap);
                    materialEditor.MinMaxShaderProperty(iridescenceThicknessRemap, 0.0f, 1.0f, URPPlusStyles.iridescenceThicknessRemapText);
                }
                else
                {
                    materialEditor.TexturePropertySingleLine(URPPlusStyles.iridescenceThicknessMapText, iridescenceThicknessMap, iridescenceThickness);
                }
            }

            //Translucency
            if(materialTypeEnum == MaterialType.Translucency)
            {
                
                materialEditor.TexturePropertySingleLine(URPPlusStyles.thicknessMapText, thicknessCurvatureMap, scatteringColor);
                if(thicknessCurvatureMap.textureValue != null)
                    materialEditor.MinMaxShaderProperty(thicknessCurvatureRemap, 0.0f, 1.0f, URPPlusStyles.thicknessRemapText);
                else
                {
                    materialEditor.ShaderProperty(thickness, URPPlusStyles.thicknessText);
                }
                materialEditor.ShaderProperty(translucencyScale, URPPlusStyles.translucencyScaleText);
                materialEditor.ShaderProperty(translucencyPower, URPPlusStyles.translucencyPowerText);
                materialEditor.ShaderProperty(translucencyAmbient, URPPlusStyles.translucencyAmbientText);
                materialEditor.ShaderProperty(translucencyDistortion, URPPlusStyles.translucencyDistortionText);
                materialEditor.ShaderProperty(translucencyShadowsStrength, URPPlusStyles.translucencyShadowsText);
            }
            EditorGUILayout.EndVertical();
        }

        void DrawHeightBlock(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Height Block", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            DisplacementMode displacementModeEnum = (DisplacementMode)displacementBlock.displacementMode.floatValue;
            materialEditor.TexturePropertySingleLine(URPPlusStyles.heightMapText, displacementBlock.heightMap);
            if (displacementModeEnum == DisplacementMode.PixelDisplacement)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(displacementBlock.heightPoMAmplitude, URPPlusStyles.heightMapAmplitudeText);
                material.SetFloat("_HeightAmplitude", material.GetFloat("_HeightPoMAmplitude") * 0.01f); // Convert centimeters to meters.
                material.SetFloat("_HeightCenter", 1.0f);
                EditorGUI.indentLevel--;
            }
            else if ((displacementModeEnum == DisplacementMode.VertexDisplacement) || (displacementModeEnum == DisplacementMode.Tessellation))
            {
                EditorGUI.indentLevel++;
                //Height Parametrization
                EditorGUI.BeginChangeCheck();
                HeightParametrization heightParametrizationEnum = (HeightParametrization)displacementBlock.heightParametrization.floatValue;
                heightParametrizationEnum = (HeightParametrization)EditorGUILayout.EnumPopup("Parametrization", heightParametrizationEnum);
                if (EditorGUI.EndChangeCheck()) 
                {
	                materialEditor.RegisterPropertyChangeUndo("Displacement Mode");
	                displacementBlock.heightParametrization.floatValue = (float)heightParametrizationEnum;
	            }
                if(heightParametrizationEnum == HeightParametrization.Amplitude)
                {
                    materialEditor.ShaderProperty(displacementBlock.heightTessAmplitude, URPPlusStyles.heightMapAmplitudeText);
                    materialEditor.ShaderProperty(displacementBlock.heightTessCenter, URPPlusStyles.heightMapCenterText);

                    float offset = material.GetFloat("_HeightOffset");
                    float center = material.GetFloat("_HeightTessCenter");
                    float amplitude = material.GetFloat("_HeightTessAmplitude");

                    material.SetFloat("_HeightAmplitude", amplitude * 0.01f); // Convert centimeters to meters.
                    material.SetFloat("_HeightCenter", -offset / Mathf.Max(1e-6f, amplitude) + center);
                }
                else
                {
                    materialEditor.ShaderProperty(displacementBlock.heightMin, URPPlusStyles.heightMapMinText);
                    materialEditor.ShaderProperty(displacementBlock.heightMax, URPPlusStyles.heightMapMaxText);

                    float offset = material.GetFloat("_HeightOffset");
                    float minHeight = material.GetFloat("_HeightMin");
                    float amplitude = material.GetFloat("_HeightMax") - minHeight;

                    material.SetFloat("_HeightAmplitude", amplitude * 0.01f); // Convert centimeters to meters.
                    material.SetFloat("_HeightCenter", -(minHeight + offset) / Mathf.Max(1e-6f, amplitude));
                }
                materialEditor.ShaderProperty(displacementBlock.heightOffset, URPPlusStyles.heightMapOffsetText);
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndVertical();
        }

        public void DrawEmissionInputs(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            materialEditor.DrawEmissionSettings(material, emissionInputs.emissionWithBase, emissionInputs.emissionMap, emissionInputs.emissionColor, emissionInputs.emissionScale);
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

            if(clearCoatMask.floatValue > 0)
                SetMaterialProperties.DrawFloatToggleProperty(URPPlusStyles.secondaryClearCoatNormalText, advancedOptions.coatNormalEnabled);

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