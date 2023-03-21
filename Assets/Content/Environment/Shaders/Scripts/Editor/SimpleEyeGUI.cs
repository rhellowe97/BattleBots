using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public class SimpleEyeGUI : BaseShaderGUI
    { 
        // Surface Input Props
        private MaterialProperty parallax;
        private MaterialProperty hue;
        private MaterialProperty saturation;
        private MaterialProperty specularAA;
        private MaterialProperty specularAAScreenSpaceVariance;
        private MaterialProperty specularAAThreshold;

        private MaterialProperty baseMap;
        private MaterialProperty hueScale;
        private MaterialProperty saturationScale;
        private MaterialProperty bumpMap;
        private MaterialProperty bumpMapScale;
        private MaterialProperty opacityMap;
        private MaterialProperty heightMap;
        private MaterialProperty parallaxAmplitude;
        private MaterialProperty smoothness;
        private MaterialProperty scleraSmoothness;
		private MaterialProperty corneaSmoothness;


        private PropertyStructures.EmissionInputs emissionInputs;
        private PropertyStructures.AdvancedOptions advancedOptions;
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);

            // Surface Option Props
            parallax = BaseShaderGUI.FindProperty("_Parallax", properties, false);
            hue = BaseShaderGUI.FindProperty("_Hue", properties, false);
            saturation = BaseShaderGUI.FindProperty("_Saturation", properties, false);
            specularAA = BaseShaderGUI.FindProperty("_EnableGeometricSpecularAA", properties, false); 
            specularAAScreenSpaceVariance = BaseShaderGUI.FindProperty("_SpecularAAScreenSpaceVariance", properties, false);
            specularAAThreshold = BaseShaderGUI.FindProperty("_SpecularAAThreshold", properties, false);

            // Surface Input Props
            baseMap = BaseShaderGUI.FindProperty("_BaseMap", properties, false);
            hueScale = BaseShaderGUI.FindProperty("_HueScale", properties, false);
            saturationScale = BaseShaderGUI.FindProperty("_SaturationScale", properties, false);
            bumpMap = BaseShaderGUI.FindProperty("_BumpMap", properties, false);
            bumpMapScale = BaseShaderGUI.FindProperty("_BumpScale", properties, false);
            heightMap = BaseShaderGUI.FindProperty("_HeightMap", properties, false);
            parallaxAmplitude = BaseShaderGUI.FindProperty("_ParallaxAmplitude", properties, false);
            opacityMap = BaseShaderGUI.FindProperty("_OpacityMap", properties, false);
            smoothness = BaseShaderGUI.FindProperty("_Smoothness", properties, false);
            scleraSmoothness = BaseShaderGUI.FindProperty("_ScleraSmoothness", properties, false);
			corneaSmoothness = BaseShaderGUI.FindProperty("_CorneaSmoothness", properties, false);

            // Emission Props
            emissionInputs = new PropertyStructures.EmissionInputs(properties);

            // Advanced Props
            advancedOptions = new PropertyStructures.AdvancedOptions(properties);
        }

		public override void ValidateMaterial(Material material)
        {
            SetMaterialKeywords(material);
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

            materialEditor.DrawFloatToggleProperty(new GUIContent("Parallax"), parallax);
            materialEditor.DrawFloatToggleProperty(new GUIContent("Hue"), hue);
            materialEditor.DrawFloatToggleProperty(new GUIContent("Saturation"), saturation);

            // Geometric Specular AA
            materialEditor.DrawSpecularAAArea(specularAA, specularAAScreenSpaceVariance, specularAAThreshold);
            EditorGUILayout.EndVertical();
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            
            DrawBaseProperties(material);
            EditorGUI.indentLevel++;
            if(material.GetFloat("_Hue") == 1.0f)
                materialEditor.ShaderProperty(hueScale, "Hue");
            if(material.GetFloat("_Saturation") == 1.0f)
                materialEditor.ShaderProperty(saturationScale, "Saturation");
            EditorGUI.indentLevel--;

            BaseShaderGUI.DrawNormalArea(materialEditor, bumpMap, bumpMapScale);

            materialEditor.TexturePropertySingleLine(URPPlusStyles.heightMapText, heightMap);

            if(heightMap.textureValue != null)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(parallaxAmplitude, URPPlusStyles.heightMapAmplitudeText);
                EditorGUI.indentLevel--;
            }

            materialEditor.TexturePropertySingleLine(new GUIContent("Opacity Map"), opacityMap);
            if(opacityMap.textureValue != null)
            {
                materialEditor.ShaderProperty(scleraSmoothness, "Sclera Smoothness");
                materialEditor.ShaderProperty(corneaSmoothness, "Cornea Smoothness");
            }
            else
            {
                materialEditor.ShaderProperty(smoothness, URPPlusStyles.smoothnessText);
            }

            EditorGUILayout.EndVertical();
        }

        // material main emission inputs
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

        public static void SetMaterialKeywords(Material material)
        {
            SetMaterialProperties.UpdateMaterialSurfaceOptions(material, automaticRenderQueue: true);

            // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
            // (MaterialProperty value might come from renderer material property block)

            // Temporary fix for lightmapping. TODO: to be replaced with attribute tag.
            if (material.HasProperty("_MainTex"))
            {
                material.SetTexture("_MainTex", material.GetTexture("_BaseMap"));
                material.SetTextureScale("_MainTex", material.GetTextureScale("_BaseMap"));
                material.SetTextureOffset("_MainTex", material.GetTextureOffset("_BaseMap"));
            }

            if (material.HasProperty("_Color"))
                material.SetColor("_Color", material.GetColor("_BaseColor"));

            // Parallax
            if (material.HasProperty("_Parallax"))
                CoreUtils.SetKeyword(material, "_PARALLAX", material.GetFloat("_Parallax") == 1.0f);
            
            // Hue
            if (material.HasProperty("_Hue"))
                CoreUtils.SetKeyword(material, "_HUE", material.GetFloat("_Hue") == 1.0f);
            
            // Saturation
            if (material.HasProperty("_Saturation"))
                CoreUtils.SetKeyword(material, "_SATURATION", material.GetFloat("_Saturation") == 1.0f);

            // Specular AA
            if (material.HasProperty("_EnableGeometricSpecularAA"))
                CoreUtils.SetKeyword(material, "_ENABLE_GEOMETRIC_SPECULAR_AA", material.GetFloat("_EnableGeometricSpecularAA") == 1.0f);

            // Normal Map
            if (material.HasProperty("_BumpMap"))
                CoreUtils.SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));

            // Opacity Map
            if (material.HasProperty("_OpacityMap"))
                CoreUtils.SetKeyword(material, "_OPACITY_MAP", material.GetTexture("_OpacityMap"));

            // Emission
            if (material.HasProperty("_EmissionColor"))
                CoreUtils.SetKeyword(material, "_EMISSION", material.GetColor("_EmissionColor") != new Color(0, 0, 0));
            
            if (material.HasProperty("_AlbedoAffectEmissive"))
                CoreUtils.SetKeyword(material, "_EMISSION_WITH_BASE", material.GetFloat("_AlbedoAffectEmissive") == 1.0f);

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