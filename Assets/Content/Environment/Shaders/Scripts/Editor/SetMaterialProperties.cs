using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public class SetMaterialProperties
    {
        public static MaterialProperty[] FindPropertyLayered(string propertyName, MaterialProperty[] properties, int layerCount = 2, bool isMandatory = false)
        {
            MaterialProperty[] arrayProperties = new MaterialProperty[layerCount];

            string[] prefixes = (layerCount > 1) ? new[] { "", "1", "2", "3" } : new[] { "" };

            for (int i = 0; i < layerCount; i++)
            {
                arrayProperties[i] = BaseShaderGUI.FindProperty(string.Format("{0}{1}", propertyName, prefixes[i]), properties, isMandatory);
            }

            return arrayProperties;
        }

        public static string LayeredKeyWord(string keyWord, int layerIndex)
        {
            string[] prefixes = new[] { "", "1", "2", "3" };

            keyWord = string.Format("{0}{1}", keyWord, prefixes[layerIndex]);
            return keyWord;
        }

        internal static void DrawFloatToggleProperty(GUIContent styles, MaterialProperty prop)
        {
            if (prop == null)
                return;

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;
            bool newValue = EditorGUILayout.Toggle(styles, prop.floatValue == 1);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = newValue ? 1.0f : 0.0f;
            EditorGUI.showMixedValue = false;
        }
        internal static void SetMaterialSrcDstBlendProperties(Material material, UnityEngine.Rendering.BlendMode srcBlend, UnityEngine.Rendering.BlendMode dstBlend)
        {
            if (material.HasProperty("_SrcBlend"))
                material.SetFloat("_SrcBlend", (float)srcBlend);

            if (material.HasProperty("_DstBlend"))
                material.SetFloat("_DstBlend", (float)dstBlend);
        }

        internal static void SetMaterialZWriteProperty(Material material, bool zwriteEnabled)
        {
            if (material.HasProperty("_ZWrite"))
                material.SetFloat("_ZWrite", zwriteEnabled ? 1.0f : 0.0f);
        }

        internal static void SetupMaterialBlendModeInternal(Material material, out int automaticRenderQueue)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            bool alphaClip = false;
            if (material.HasProperty("_"))
                alphaClip = material.GetFloat("_AlphaCutoffEnable") >= 0.5;
            CoreUtils.SetKeyword(material, "_ALPHATEST_ON", alphaClip);

            // default is to use the shader render queue
            int renderQueue = material.shader.renderQueue;
            material.SetOverrideTag("RenderType", "");      // clear override tag
            if (material.HasProperty("_Surface"))
            {
                SurfaceType surfaceType = (SurfaceType)material.GetFloat("_Surface");
                bool zwrite = false;
                CoreUtils.SetKeyword(material, "_SURFACE_TYPE_TRANSPARENT", surfaceType == SurfaceType.Transparent);
                if (surfaceType == SurfaceType.Opaque)
                {
                    if (alphaClip)
                    {
                        renderQueue = (int)RenderQueue.AlphaTest;
                        material.SetOverrideTag("RenderType", "TransparentCutout");
                    }
                    else
                    {
                        renderQueue = (int)RenderQueue.Geometry;
                        material.SetOverrideTag("RenderType", "Opaque");
                    }

                    SetMaterialSrcDstBlendProperties(material, UnityEngine.Rendering.BlendMode.One, UnityEngine.Rendering.BlendMode.Zero);
                    zwrite = true;
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.DisableKeyword("_SURFACE_TYPE_TRANSPARENT");
                }
                else // SurfaceType Transparent
                {
                    BlendMode blendMode = (BlendMode)material.GetFloat("_Blend");

                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.DisableKeyword("_ALPHAMODULATE_ON");

                    // Specific Transparent Mode Settings
                    switch (blendMode)
                    {
                        case BlendMode.Alpha:
                            SetMaterialSrcDstBlendProperties(material,
                                UnityEngine.Rendering.BlendMode.SrcAlpha,
                                UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                            break;
                        case BlendMode.Premultiply:
                            SetMaterialSrcDstBlendProperties(material,
                                UnityEngine.Rendering.BlendMode.One,
                                UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                            material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Additive:
                            SetMaterialSrcDstBlendProperties(material,
                                UnityEngine.Rendering.BlendMode.SrcAlpha,
                                UnityEngine.Rendering.BlendMode.One);
                            break;
                        case BlendMode.Multiply:
                            SetMaterialSrcDstBlendProperties(material,
                                UnityEngine.Rendering.BlendMode.DstColor,
                                UnityEngine.Rendering.BlendMode.Zero);
                            material.EnableKeyword("_ALPHAMODULATE_ON");
                            break;
                    }

                    // General Transparent Material Settings
                    material.SetOverrideTag("RenderType", "Transparent");
                    zwrite = (material.GetFloat("_ZWrite") == 1.0f) ? true : false;
                    material.EnableKeyword("_SURFACE_TYPE_TRANSPARENT");
                    renderQueue = (int)RenderQueue.Transparent;
                }

                SetMaterialZWriteProperty(material, zwrite);
                material.SetShaderPassEnabled("DepthOnly", zwrite);
            }
            else
            {
                // no surface type property -- must be hard-coded by the shadergraph,
                // so ensure the pass is enabled at the material level
                material.SetShaderPassEnabled("DepthOnly", true);
            }

            // must always apply queue offset, even if not set to material control
            if (material.HasProperty("_QueueOffset"))
                renderQueue += (int)material.GetFloat("_QueueOffset");

            automaticRenderQueue = renderQueue;
        }

        public static void SetupMaterialBlendMode(Material material)
        {
            SetupMaterialBlendModeInternal(material, out int renderQueue);

            // apply automatic render queue
            if (renderQueue != material.renderQueue)
                material.renderQueue = renderQueue;
        }

        internal static bool IsOpaque(Material material)
        {
            bool opaque = true;
            if (material.HasProperty("_Surface"))
                opaque = ((BaseShaderGUI.SurfaceType)material.GetFloat("_Surface") == BaseShaderGUI.SurfaceType.Opaque);
            return opaque;
        }

        internal static void UpdateMaterialSurfaceOptions(Material material, bool automaticRenderQueue)
        {
            // Setup blending - consistent across all Universal RP shaders
            SetupMaterialBlendModeInternal(material, out int renderQueue);

            // apply automatic render queue
            if (automaticRenderQueue && (renderQueue != material.renderQueue))
                material.renderQueue = renderQueue;

            // Cast Shadows
            bool castShadows = true;
            if (material.HasProperty("_Surface") && material.HasProperty("_CastShadows"))
            {
                if((BaseShaderGUI.SurfaceType)material.GetFloat("_Surface") == BaseShaderGUI.SurfaceType.Transparent)
                {
                    castShadows = (material.GetFloat("_CastShadows") == 1.0f) ? true : false;
                }
                else
                {
                    castShadows = true;
                }
            }
            else
            {
                // Lit.shader or Unlit.shader -- set based on transparency
                castShadows = IsOpaque(material);
            }
            material.SetShaderPassEnabled("ShadowCaster", castShadows);

            // Receive Shadows
            if (material.HasProperty("_ReceiveShadows"))
                CoreUtils.SetKeyword(material, "_RECEIVE_SHADOWS_OFF", material.GetFloat("_ReceiveShadows") == 0.0f);
        }

        internal static void SetupSpecularWorkflowKeyword(Material material, out bool isSpecularWorkflow)
        {
            isSpecularWorkflow = false;     // default is metallic workflow
            if (material.HasProperty("_WorkflowMode"))
                isSpecularWorkflow = ((WorkflowMode)material.GetFloat("_WorkflowMode")) == WorkflowMode.Specular;
            CoreUtils.SetKeyword(material, "_SPECULAR_SETUP", isSpecularWorkflow);
        }

        public static void SetLitMaterialKeywords(Material material)
        {
            UpdateMaterialSurfaceOptions(material, automaticRenderQueue: true);

            SetupSpecularWorkflowKeyword(material, out bool isSpecularWorkFlow);
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
                if((DoubleSidedNormalMode)material.GetFloat("_DoubleSidedNormalMode") != DoubleSidedNormalMode.None)
                    material.EnableKeyword("_DOUBLESIDED_ON");

            // Alpha Clipping
            if (material.HasProperty("_AlphaCutoffEnable"))
                CoreUtils.SetKeyword(material, "_ALPHATEST_ON", material.GetFloat("_AlphaCutoffEnable") >= 0.5f);

            if (material.HasProperty("_UseShadowThreshold"))
                CoreUtils.SetKeyword(material, "_SHADOW_CUTOFF", material.GetFloat("_UseShadowThreshold") >= 0.5f);
            
            // Material ID
            if(material.HasProperty("_MaterialType"))
            {
                MaterialType materialIDEnum = (MaterialType)material.GetFloat("_MaterialType");
                switch(materialIDEnum)
                {
                    case MaterialType.SubsurfaceScattering:
                        material.EnableKeyword("_MATERIAL_FEATURE_SUBSURFACE_SCATTERING");
                        material.DisableKeyword("_MATERIAL_FEATURE_ANISOTROPY");
                        material.DisableKeyword("_MATERIAL_FEATURE_IRIDESCENCE");
                        material.DisableKeyword("_MATERIAL_FEATURE_TRANSLUCENCY");
                        break;
                    case MaterialType.Standard:
                        material.DisableKeyword("_MATERIAL_FEATURE_SUBSURFACE_SCATTERING");
                        material.DisableKeyword("_MATERIAL_FEATURE_ANISOTROPY");
                        material.DisableKeyword("_MATERIAL_FEATURE_IRIDESCENCE");
                        material.DisableKeyword("_MATERIAL_FEATURE_TRANSLUCENCY");
                        break;
                    case MaterialType.Anisotropy:
                        material.EnableKeyword("_MATERIAL_FEATURE_ANISOTROPY");
                        material.DisableKeyword("_MATERIAL_FEATURE_SUBSURFACE_SCATTERING");
                        material.DisableKeyword("_MATERIAL_FEATURE_IRIDESCENCE");
                        material.DisableKeyword("_MATERIAL_FEATURE_TRANSLUCENCY");
                        break;
                    case MaterialType.Iridescence:
                        material.EnableKeyword("_MATERIAL_FEATURE_IRIDESCENCE");
                        material.DisableKeyword("_MATERIAL_FEATURE_SUBSURFACE_SCATTERING");
                        material.DisableKeyword("_MATERIAL_FEATURE_ANISOTROPY");
                        material.DisableKeyword("_MATERIAL_FEATURE_TRANSLUCENCY");
                        break;
                    case MaterialType.Translucency:
                        material.EnableKeyword("_MATERIAL_FEATURE_TRANSLUCENCY");
                        material.DisableKeyword("_MATERIAL_FEATURE_SUBSURFACE_SCATTERING");
                        material.DisableKeyword("_MATERIAL_FEATURE_ANISOTROPY");
                        material.DisableKeyword("_MATERIAL_FEATURE_IRIDESCENCE");
                        break;
                }

                // SSS LUT
                if (material.HasProperty("_SSSLUT"))
                    CoreUtils.SetKeyword(material, "_SSS_LUT", material.GetTexture("_SSSLUT"));

                // Transmission
                if (material.HasProperty("_TransmissionEnable"))
                    CoreUtils.SetKeyword(material, "_MATERIAL_FEATURE_TRANSMISSION", material.GetFloat("_TransmissionEnable") == 1.0f);
                
                // Fake SSS Shadows
                if (material.HasProperty("_SSSShadowsEnable"))
                    CoreUtils.SetKeyword(material, "_MATERIAL_FEATURE_FAKE_SSS_SHADOWS", material.GetFloat("_SSSShadowsEnable") == 1.0f);
                
                // ThicknessCurvature Map
                if (material.HasProperty("_ThicknessCurvatureMap"))
                    CoreUtils.SetKeyword(material, "_THICKNESS_CURVATUREMAP", material.GetTexture("_ThicknessCurvatureMap"));

                // Tangent Map
                if (material.HasProperty("_TangentMap"))
                    CoreUtils.SetKeyword(material, "_TANGENTMAP", material.GetTexture("_TangentMap"));

                // Anisotropy Map
                if (material.HasProperty("_AnisotropyMap"))
                    CoreUtils.SetKeyword(material, "_ANISOTROPYMAP", material.GetTexture("_AnisotropyMap"));

                // IridescenceThickness Map
                if (material.HasProperty("_IridescenceThicknessMap"))
                    CoreUtils.SetKeyword(material, "_IRIDESCENCE_THICKNESSMAP", material.GetTexture("_IridescenceThicknessMap"));
            }

            // Specular AA
            if (material.HasProperty("_EnableGeometricSpecularAA"))
                CoreUtils.SetKeyword(material, "_ENABLE_GEOMETRIC_SPECULAR_AA", material.GetFloat("_EnableGeometricSpecularAA") == 1.0f);

            // Displacement Mode
            if (material.HasProperty("_DisplacementMode"))
            {
                DisplacementMode displacementModeEnum = (DisplacementMode)material.GetFloat("_DisplacementMode");
                switch(displacementModeEnum)
                {
                    case DisplacementMode.None:
                        material.DisableKeyword("_VERTEX_DISPLACEMENT");
                        material.DisableKeyword("_PIXEL_DISPLACEMENT");
                        material.DisableKeyword("_TESSELLATION_DISPLACEMENT");
                        break;
                    case DisplacementMode.VertexDisplacement:
                        material.EnableKeyword("_VERTEX_DISPLACEMENT");
                        material.DisableKeyword("_PIXEL_DISPLACEMENT");
                        break;
                    case DisplacementMode.PixelDisplacement:
                        material.EnableKeyword("_PIXEL_DISPLACEMENT");
                        material.DisableKeyword("_VERTEX_DISPLACEMENT");
                        break;
                    case DisplacementMode.Tessellation:
                        material.DisableKeyword("_VERTEX_DISPLACEMENT");
                        material.DisableKeyword("_PIXEL_DISPLACEMENT");
                        material.EnableKeyword("_TESSELLATION_DISPLACEMENT");
                        break;
                }
            }

            // Lock With Object Scale
            if (material.HasProperty("_DisplacementLockObjectScale"))
                CoreUtils.SetKeyword(material, "_VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE", material.GetFloat("_DisplacementLockObjectScale") == 1.0f);

            // DepthOffset
            if (material.HasProperty("_DepthOffsetEnable"))
                CoreUtils.SetKeyword(material, "_DEPTHOFFSET_ON", material.GetFloat("_DepthOffsetEnable") == 1.0f);

            // Tesselation
            if(material.HasProperty("_TessellationMode"))
            {
                TessellationMode tessellationModeEnum = (TessellationMode)material.GetFloat("_TessellationMode");
                switch(tessellationModeEnum)
                {
                    case TessellationMode.None:
                        material.DisableKeyword("_TESSELLATION_DISTANCE");
                        material.DisableKeyword("_TESSELLATION_EDGE");
                        break;
                    case TessellationMode.EdgeLength:
                        material.DisableKeyword("_TESSELLATION_DISTANCE");
                        material.EnableKeyword("_TESSELLATION_EDGE");
                        break;
                    case TessellationMode.Distance:
                        material.DisableKeyword("_TESSELLATION_EDGE");
                        material.EnableKeyword("_TESSELLATION_DISTANCE");
                        break;
                }
            }

            // Phong Tessellation
            if (material.HasProperty("_PhongTessellationMode"))
                CoreUtils.SetKeyword(material, "_TESSELLATION_PHONG", material.GetFloat("_PhongTessellationMode") == 1.0f);

            // Mask Map
            if (material.HasProperty("_MaskMap"))
                CoreUtils.SetKeyword(material, "_MASKMAP", material.GetTexture("_MaskMap"));

            // Normal Map
            if (material.HasProperty("_BumpMap"))
                CoreUtils.SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));
            
            // BentNormal Map
            if (material.HasProperty("_BentNormalMap"))
                CoreUtils.SetKeyword(material, "_BENTNORMALMAP", material.GetTexture("_BentNormalMap"));

            // ClearCoat
            if (material.HasProperty("_ClearCoatMask"))
                CoreUtils.SetKeyword(material, "_CLEARCOAT", material.GetFloat("_ClearCoatMask") > 0.0f);
                
            // Height Map
            if (material.HasProperty("_HeightMap"))
                CoreUtils.SetKeyword(material, "_HEIGHTMAP", material.GetTexture("_HeightMap"));

            // Height Map
            if (material.HasProperty("_DetailMap"))
                CoreUtils.SetKeyword(material, "_DETAIL", material.GetTexture("_DetailMap"));

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

            if (material.HasProperty("_CoatNormal"))
                CoreUtils.SetKeyword(material, "_CLEARCOAT_NORMALMAP", material.GetFloat("_CoatNormal") == 1.0f);

            // Horizon Occlusion
            if (material.HasProperty("_HorizonOcclusion"))
                CoreUtils.SetKeyword(material, "_HORIZON_SPECULAR_OCCLUSION", material.GetFloat("_HorizonOcclusion") == 1.0f);

            // Specular Occlusion
            if (material.HasProperty("_SpecularOcclusionMode"))
            {
                SpecularOcclusionMode specularOcclusionModeEnum = (SpecularOcclusionMode)material.GetFloat("_SpecularOcclusionMode");
                switch(specularOcclusionModeEnum)
                {
                    case SpecularOcclusionMode.Off:
                        material.DisableKeyword("_AO_SPECULAR_OCCLUSION");
                        material.DisableKeyword("_BENTNORMAL_SPECULAR_OCCLUSION");
                        material.DisableKeyword("_GI_SPECULAR_OCCLUSION");
                        break;
                    case SpecularOcclusionMode.FromAmbientOcclusion:
                        material.DisableKeyword("_BENTNORMAL_SPECULAR_OCCLUSION");
                        material.DisableKeyword("_GI_SPECULAR_OCCLUSION");
                        material.EnableKeyword("_AO_SPECULAR_OCCLUSION");
                        break;
                    case SpecularOcclusionMode.FromBentNormals:
                        material.DisableKeyword("_AO_SPECULAR_OCCLUSION");
                        material.DisableKeyword("_GI_SPECULAR_OCCLUSION");
                        material.EnableKeyword("_BENTNORMAL_SPECULAR_OCCLUSION");
                        break;
                    case SpecularOcclusionMode.FromGI:
                        material.DisableKeyword("_AO_SPECULAR_OCCLUSION");
                        material.DisableKeyword("_BENTNORMAL_SPECULAR_OCCLUSION");
                        material.EnableKeyword("_GI_SPECULAR_OCCLUSION");
                        break;
                }
            }

            //////////////////////
            /*LayeredLitKeywords*/
            //////////////////////

            if (material.HasProperty("_LayerCount"))
            {
                int numLayer = (int)material.GetFloat("_LayerCount");
                // Layer
                if (numLayer == 4)
                {
                    CoreUtils.SetKeyword(material, "_LAYEREDLIT_4_LAYERS", true);
                    CoreUtils.SetKeyword(material, "_LAYEREDLIT_3_LAYERS", false);
                }
                else if (numLayer == 3)
                {
                    CoreUtils.SetKeyword(material, "_LAYEREDLIT_4_LAYERS", false);
                    CoreUtils.SetKeyword(material, "_LAYEREDLIT_3_LAYERS", true);
                }
                else
                {
                    CoreUtils.SetKeyword(material, "_LAYEREDLIT_4_LAYERS", false);
                    CoreUtils.SetKeyword(material, "_LAYEREDLIT_3_LAYERS", false);
                }
            }
            // VertexMode
            if (material.HasProperty("_VertexColorMode"))
            {
                VertexColorMode VCMode = (VertexColorMode)material.GetFloat("_VertexColorMode");
                if (VCMode == VertexColorMode.Multiply)
                {
                    CoreUtils.SetKeyword(material, "_LAYER_MASK_VERTEX_COLOR_MUL", true);
                    CoreUtils.SetKeyword(material, "_LAYER_MASK_VERTEX_COLOR_ADD", false);
                }
                else if (VCMode == VertexColorMode.Add)
                {
                    CoreUtils.SetKeyword(material, "_LAYER_MASK_VERTEX_COLOR_MUL", false);
                    CoreUtils.SetKeyword(material, "_LAYER_MASK_VERTEX_COLOR_ADD", true);
                }
                else
                {
                    CoreUtils.SetKeyword(material, "_LAYER_MASK_VERTEX_COLOR_MUL", false);
                    CoreUtils.SetKeyword(material, "_LAYER_MASK_VERTEX_COLOR_ADD", false);
                }
            }

            if (material.HasProperty("_UseMainLayerInfluence") && material.HasProperty("_LayerInfluenceMaskMap"))
                CoreUtils.SetKeyword(material, "_INFLUENCEMASK_MAP", material.GetTexture("_LayerInfluenceMaskMap") && material.GetFloat("_UseMainLayerInfluence") != 0.0f);

            if (material.HasProperty("_UseMainLayerInfluence"))
                CoreUtils.SetKeyword(material, "_MAIN_LAYER_INFLUENCE_MODE", material.GetFloat("_UseMainLayerInfluence") != 0.0f);

            if (material.HasProperty("_UseHeightBasedBlend"))
                CoreUtils.SetKeyword(material, "_HEIGHT_BASED_BLEND", material.GetFloat("_UseHeightBasedBlend") != 0.0f);

            if (material.HasProperty("_BaseMap1"))
            {
                for (int i = 0; i < 4; ++i)
                {
                    CoreUtils.SetKeyword(material, LayeredKeyWord("_NORMALMAP", i), material.GetTexture(LayeredKeyWord("_NormalMap", i)) || material.GetTexture(LayeredKeyWord("_DetailMap", i)));
                    CoreUtils.SetKeyword(material, LayeredKeyWord("_MASKMAP", i), material.GetTexture(LayeredKeyWord("_MaskMap", i)));
                    CoreUtils.SetKeyword(material, LayeredKeyWord("_BENTNORMALMAP", i), material.GetTexture(LayeredKeyWord("_BentNormalMap", i)));
                    CoreUtils.SetKeyword(material, LayeredKeyWord("_DETAIL_MAP", i), material.GetTexture(LayeredKeyWord("_DetailMap", i)));
                    CoreUtils.SetKeyword(material, LayeredKeyWord("_HEIGHTMAP", i), material.GetTexture(LayeredKeyWord("_HeightMap", i)));
                }
            }
        }
    }
}
