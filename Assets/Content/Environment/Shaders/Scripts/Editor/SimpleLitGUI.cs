using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public class SimpleLitShaderGUI : BaseShaderGUI
    {
        // Surface Input Props
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
        private MaterialProperty specularMap;
        private MaterialProperty specularColor;

        private PropertyStructures.SurfaceOptions surfaceOptions;
        private PropertyStructures.EmissionInputs emissionInputs;
        private PropertyStructures.AdvancedOptions advancedOptions;

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);

            // Surface Options Props
            surfaceOptions = new PropertyStructures.SurfaceOptions(properties);
            
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
            // SpecularMap properties
            specularColor = BaseShaderGUI.FindProperty("_SpecularColor", properties, false);
            specularMap = BaseShaderGUI.FindProperty("_SpecularColorMap", properties, false);

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
            
            EditorGUILayout.EndVertical();
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            DrawBaseProperties(material);
            materialEditor.DrawMaskMapArea(surfaceOptions.workflowMode, maskMap, metallic, smoothness, 
                                            metallicMin, metallicMax, smoothnessMin, smoothnessMax, aoMin, aoMax);
            //SpecularColor
            if((WorkflowMode)surfaceOptions.workflowMode.floatValue == WorkflowMode.Specular)
                materialEditor.TexturePropertySingleLine(URPPlusStyles.specularColorText, specularMap, specularColor);
            
            BaseShaderGUI.DrawNormalArea(materialEditor, bumpMap, bumpMapScale);

            //Tilling
			materialEditor.TextureScaleOffsetProperty(baseMap);
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

            //HorizonOcclusion
            SetMaterialProperties.DrawFloatToggleProperty(URPPlusStyles.horizonOcclusionText,advancedOptions.horizonOcclusion);
            if (advancedOptions.horizonOcclusion.floatValue == 1) 
            {
                EditorGUI.indentLevel++;
	        	materialEditor.ShaderProperty(advancedOptions.horizonFade, "Horizon Fade");
                EditorGUI.indentLevel--;
	        }
            EditorGUILayout.Space();

            base.DrawAdvancedOptions(material);

            EditorGUILayout.EndVertical();
        }
    }
}