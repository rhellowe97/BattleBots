using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public class FabricGUI : BaseShaderGUI
    {

        // Surface Input Props
        private MaterialProperty materialType;

        private MaterialProperty baseColor;
		private MaterialProperty baseMap;
        private MaterialProperty maskMap;
        private MaterialProperty sheenMap;
        private MaterialProperty specularColor;
        private MaterialProperty smoothness;
		private MaterialProperty smoothnessMin;
        private MaterialProperty smoothnessMax;
        private MaterialProperty aoMin;
        private MaterialProperty aoMax;
        private MaterialProperty anisotropy;
        private MaterialProperty bumpMap;
		private MaterialProperty bumpMapScale;
        //Translucency
        private MaterialProperty translucency;
        private MaterialProperty thicknessMap;
        private MaterialProperty thickness;
        private MaterialProperty thicknessRemap;
        private MaterialProperty translucencyColor;
        private MaterialProperty translucencyScale;
        private MaterialProperty translucencyPower;
        private MaterialProperty translucencyAmbient;
        private MaterialProperty translucencyDistortion;
        private MaterialProperty translucencyShadowsStrength;
        //ThreadMap
		private MaterialProperty threadMap;
    	private MaterialProperty threadAOScale;
    	private MaterialProperty threadNormalScale;
    	private MaterialProperty threadSmoothnessScale;
        //FuzzMap
        private MaterialProperty fuzzMap;
        private MaterialProperty fuzzSize;
        private MaterialProperty fuzzScale;

        private PropertyStructures.SurfaceOptions surfaceOptions;
        private PropertyStructures.AdvancedOptions advancedOptions;

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            
            // Surface Options Props
            surfaceOptions = new PropertyStructures.SurfaceOptions(properties);
            materialType = BaseShaderGUI.FindProperty("_MaterialType", properties, false);

            // Surface Input Props
            // BaseMap properties
            baseMap = BaseShaderGUI.FindProperty("_BaseMap", properties, false); 
            baseColor = BaseShaderGUI.FindProperty("_BaseColor", properties, false);

            // MaskMap properties
            maskMap = BaseShaderGUI.FindProperty("_MaskMap", properties, false);
            sheenMap = BaseShaderGUI.FindProperty("_SheenMap", properties, false);
            anisotropy = BaseShaderGUI.FindProperty("_Anisotropy", properties, false);
            smoothness = BaseShaderGUI.FindProperty("_Smoothness", properties, false);
            smoothnessMin = BaseShaderGUI.FindProperty("_SmoothnessRemapMin", properties, false);
            smoothnessMax = BaseShaderGUI.FindProperty("_SmoothnessRemapMax", properties, false);
            aoMin = BaseShaderGUI.FindProperty("_AORemapMin", properties, false);
            aoMax = BaseShaderGUI.FindProperty("_AORemapMax", properties, false);

            // NormalMap properties
            bumpMap = BaseShaderGUI.FindProperty("_BumpMap", properties, false);
            bumpMapScale = BaseShaderGUI.FindProperty("_BumpScale", properties, false);

            // SpecularMap properties
            specularColor = BaseShaderGUI.FindProperty("_SpecColor", properties, false);

            //Translucency
            translucency = FindProperty("_Translucency", properties, false);
            thicknessMap = FindProperty("_ThicknessMap", properties, false);
            thickness = FindProperty("_Thickness", properties, false);
            thicknessRemap = FindProperty("_ThicknessRemap", properties, false);
            translucencyColor = FindProperty("_TranslucencyColor", properties, false);
            translucencyScale = FindProperty("_TranslucencyScale", properties, false);
            translucencyPower = FindProperty("_TranslucencyPower", properties, false);
            translucencyAmbient = FindProperty("_TranslucencyAmbient", properties, false);
            translucencyDistortion = FindProperty("_TranslucencyDistortion", properties, false);
            translucencyShadowsStrength = FindProperty("_TranslucencyShadows", properties, false);

			//Thread properties
			threadMap = BaseShaderGUI.FindProperty("_ThreadMap", properties, false);
            threadAOScale = BaseShaderGUI.FindProperty("_ThreadAOScale", properties, false);
			threadNormalScale = BaseShaderGUI.FindProperty("_ThreadNormalScale", properties, false);
			threadSmoothnessScale = BaseShaderGUI.FindProperty("_ThreadSmoothnessScale", properties, false);
            fuzzMap = BaseShaderGUI.FindProperty("_FuzzMap", properties, false);
            fuzzSize = BaseShaderGUI.FindProperty("_FuzzMapScale", properties, false);
            fuzzScale = BaseShaderGUI.FindProperty("_FuzzStrength", properties, false);
    
            // Advanced Props
            advancedOptions = new PropertyStructures.AdvancedOptions(properties);
        }

        public override void ValidateMaterial(Material material)
        {
            SetMaterialKeywords(material);
        }

        // material main surface options
        public override void DrawSurfaceOptions(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

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

            //FabricMaterialType
            materialEditor.PopupShaderProperty(materialType, URPPlusStyles.materialIDText, Enum.GetNames(typeof(FabricMaterialType)));

            // Geometric Specular AA
            materialEditor.DrawSpecularAAArea(surfaceOptions.specularAA, surfaceOptions.specularAAScreenSpaceVariance, surfaceOptions.specularAAThreshold);
            EditorGUILayout.EndVertical();
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Base Block", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            
            //////////////////////
            /*****Base Block*****/
            //////////////////////
            DrawBaseProperties(material);
            //MaskMap
            if(maskMap.textureValue != null)
            {
                materialEditor.MinMaxShaderProperty(smoothnessMin, smoothnessMax, 0.0f, 1.0f, URPPlusStyles.smoothnessRemappingText);
                materialEditor.MinMaxShaderProperty(aoMin, aoMax, 0.0f, 1.0f, URPPlusStyles.aoRemappingText);
            }
            else
            {
                materialEditor.ShaderProperty(smoothness, URPPlusStyles.smoothnessText);
            }

            if((FabricMaterialType)materialType.floatValue == FabricMaterialType.Silk)
                materialEditor.RangeProperty(anisotropy, "Anisotropy");

			materialEditor.TexturePropertySingleLine(URPPlusStyles.maskMapSText, maskMap);

            //SpecularColor
            materialEditor.TexturePropertySingleLine(new GUIContent("Sheen Map"), sheenMap, specularColor);
            
            BaseShaderGUI.DrawNormalArea(materialEditor, bumpMap, bumpMapScale);

            //Tilling
			materialEditor.TextureScaleOffsetProperty(baseMap);
            EditorGUILayout.EndVertical();
            
            //////////////////////
            /****Thread Block****/
            //////////////////////
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Thread Block", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            //ThreadMap
			materialEditor.TexturePropertySingleLine(new GUIContent("Thread Map"), threadMap);
            if(threadMap.textureValue != null)
            {
                EditorGUI.indentLevel++;
			    materialEditor.ShaderProperty(threadAOScale, "Thread AO Scale");
			    materialEditor.ShaderProperty(threadNormalScale, "Thread Normal Scale");
			    materialEditor.ShaderProperty(threadSmoothnessScale, "Thread Smoothness Scale");
                EditorGUI.indentLevel--;
            }

            //Fuzz
            materialEditor.TexturePropertySingleLine(new GUIContent("Fuzz Map"), fuzzMap);
            if(fuzzMap.textureValue != null)
            {
                EditorGUI.indentLevel++;
			    materialEditor.ShaderProperty(fuzzSize, "Fuzz Size");
			    materialEditor.ShaderProperty(fuzzScale, "Fuzz Scale");
                EditorGUI.indentLevel--;
            }

			materialEditor.TextureScaleOffsetProperty(threadMap);
            EditorGUILayout.EndVertical();

            ////////////////////////////
            /****Translucency Block****/
            ////////////////////////////
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Translucency Block", EditorStyles.boldLabel);
            EditorGUILayout.EndHorizontal();
            materialEditor.DrawFloatToggleProperty(new GUIContent("Translucency"), translucency);
            if(translucency.floatValue == 1)
            {
                materialEditor.TexturePropertySingleLine(URPPlusStyles.thicknessMapText, thicknessMap, translucencyColor);
                if(thicknessMap.textureValue != null)
                    materialEditor.MinMaxShaderProperty(thicknessRemap, 0.0f, 1.0f, URPPlusStyles.thicknessRemapText);
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
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // _Emission property is lost after assigning Standard shader to the material
            // thus transfer it before assigning the new shader
            if (material.HasProperty("_Emission"))
            {
                material.SetColor("_EmissionColor", material.GetColor("_Emission"));
            }

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
            {
                SetupMaterialBlendMode(material);
                return;
            }

            SurfaceType surfaceType = SurfaceType.Opaque;
            BlendMode blendMode = BlendMode.Alpha;
            if (oldShader.name.Contains("/Transparent/Cutout/"))
            {
                surfaceType = SurfaceType.Opaque;
                material.SetFloat("_AlphaClip", 1);
            }
            else if (oldShader.name.Contains("/Transparent/"))
            {
                // NOTE: legacy shaders did not provide physically based transparency
                // therefore Fade mode
                surfaceType = SurfaceType.Transparent;
                blendMode = BlendMode.Alpha;
            }
            material.SetFloat("_Blend", (float)blendMode);

            material.SetFloat("_Surface", (float)surfaceType);
            if (surfaceType == SurfaceType.Opaque)
            {
                material.DisableKeyword("_SURFACE_TYPE_TRANSPARENT");
            }
            else
            {
                material.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
            }

            if (oldShader.name.Equals("Standard (Specular setup)"))
            {
                material.SetFloat("_WorkflowMode", (float)LitGUI.WorkflowMode.Specular);
                Texture texture = material.GetTexture("_SpecGlossMap");
                if (texture != null)
                    material.SetTexture("_MetallicSpecGlossMap", texture);
            }
            else
            {
                material.SetFloat("_WorkflowMode", (float)LitGUI.WorkflowMode.Metallic);
                Texture texture = material.GetTexture("_MetallicGlossMap");
                if (texture != null)
                    material.SetTexture("_MetallicSpecGlossMap", texture);
            }
        }

        public static void SetMaterialKeywords(Material material)
        {
            SetMaterialProperties.UpdateMaterialSurfaceOptions(material, automaticRenderQueue: true);

            // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
            // (MaterialProperty value might come from renderer material property block)

            // Setup double sided GI based on Cull state
            if (material.HasProperty("_Cull"))
                material.doubleSidedGI = (RenderFace)material.GetFloat("_Cull") != RenderFace.Front;

            // Temporary fix for lightmapping. TODO: to be replaced with attribute tag.
            if (material.HasProperty("_MainTex"))
            {
                material.SetTexture("_MainTex", material.GetTexture("_BaseMap"));
                material.SetTextureScale("_MainTex", material.GetTextureScale("_BaseMap"));
                material.SetTextureOffset("_MainTex", material.GetTextureOffset("_BaseMap"));
            }

            if (material.HasProperty("_Color"))
                material.SetColor("_Color", material.GetColor("_BaseColor"));

            // Cull Mode
            if ((RenderFace)material.GetFloat("_Cull") == RenderFace.Both)
            {
                if ((DoubleSidedNormalMode)material.GetFloat("_DoubleSidedNormalMode") != DoubleSidedNormalMode.None)
                    material.EnableKeyword("_DOUBLESIDED_ON");
            }

            // Alpha Clipping
            if (material.HasProperty("_AlphaCutoffEnable"))
                CoreUtils.SetKeyword(material, "_ALPHATEST_ON", material.GetFloat("_AlphaCutoffEnable") >= 0.5f);

            if (material.HasProperty("_UseShadowThreshold"))
                CoreUtils.SetKeyword(material, "_SHADOW_CUTOFF", material.GetFloat("_UseShadowThreshold") >= 0.5f);

            // MaterialType
            if (material.HasProperty("_MaterialType"))
            {
                if ((FabricMaterialType)material.GetFloat("_MaterialType") == FabricMaterialType.CottonWool)
                    material.EnableKeyword("_MATERIAL_FEATURE_SHEEN");
                else
                {
                    material.DisableKeyword("_MATERIAL_FEATURE_SHEEN");
                }
            }

            // Specular AA
            if (material.HasProperty("_EnableGeometricSpecularAA"))
                CoreUtils.SetKeyword(material, "_ENABLE_GEOMETRIC_SPECULAR_AA", material.GetFloat("_EnableGeometricSpecularAA") == 1.0f);

            // Normal Map
            if (material.HasProperty("_BumpMap"))
                CoreUtils.SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));

            // Mask Map
            if (material.HasProperty("_MaskMap"))
                CoreUtils.SetKeyword(material, "_MASKMAP", material.GetTexture("_MaskMap"));

            // Sheen Map
            if (material.HasProperty("_SheenMap"))
                CoreUtils.SetKeyword(material, "_SHEENMAP", material.GetTexture("_SheenMap"));
            
            // Thread Map
            if (material.HasProperty("_ThreadMap"))
                CoreUtils.SetKeyword(material, "_THREADMAP", material.GetTexture("_ThreadMap"));

            // Fuzz Map
            if (material.HasProperty("_FuzzMap"))
                CoreUtils.SetKeyword(material, "_FUZZMAP", material.GetTexture("_FuzzMap"));

            // Translucency
            if (material.HasProperty("_Translucency"))
                CoreUtils.SetKeyword(material, "_MATERIAL_FEATURE_TRANSLUCENCY", material.GetFloat("_Translucency") == 1.0f);

            // Thickness Map
            if (material.HasProperty("_ThicknessMap"))
                CoreUtils.SetKeyword(material, "_THICKNESSMAP", material.GetTexture("_ThicknessMap"));

            // Additional Options 
            if (material.HasProperty("_SpecularHighlights"))
                CoreUtils.SetKeyword(material, "_SPECULARHIGHLIGHTS_OFF",
                    material.GetFloat("_SpecularHighlights") == 0.0f);
            if (material.HasProperty("_EnvironmentReflections"))
                CoreUtils.SetKeyword(material, "_ENVIRONMENTREFLECTIONS_OFF",
                    material.GetFloat("_EnvironmentReflections") == 0.0f);
        }
    }
}