using UnityEngine;
using UnityEditor.Rendering;

namespace UnityEditor
{
    public class PropertyStructures : ShaderGUI
    {
        public struct SurfaceOptions
        {
            public MaterialProperty workflowMode;
            public MaterialProperty surfaceType;
		    public MaterialProperty blendMode;
		    public MaterialProperty alphaCutoffEnable;
		    public MaterialProperty alphaCutoff;
            public MaterialProperty useShadowThreshold;
		    public MaterialProperty alphaCutoffShadow;
            public MaterialProperty depthWrite;
		    public MaterialProperty depthTest;
		    public MaterialProperty renderFace;
            public MaterialProperty doubleSidedNormalMode;
            public MaterialProperty specularAA;
            public MaterialProperty specularAAScreenSpaceVariance;
            public MaterialProperty specularAAThreshold;

            public SurfaceOptions(MaterialProperty[] properties)
            {
                workflowMode = BaseShaderGUI.FindProperty("_WorkflowMode", properties, false);
                surfaceType = BaseShaderGUI.FindProperty("_Surface", properties, false);
                blendMode = BaseShaderGUI.FindProperty("_Blend", properties, false);
                depthWrite = BaseShaderGUI.FindProperty("_ZWrite", properties, false);
        	    depthTest = BaseShaderGUI.FindProperty("_ZTest", properties, false);
                alphaCutoffEnable = BaseShaderGUI.FindProperty("_AlphaCutoffEnable", properties, false);
        	    alphaCutoff = BaseShaderGUI.FindProperty("_Cutoff", properties, false);
                useShadowThreshold = BaseShaderGUI.FindProperty("_UseShadowThreshold", properties, false);
        	    alphaCutoffShadow = BaseShaderGUI.FindProperty("_AlphaCutoffShadow", properties, false);
                renderFace = BaseShaderGUI.FindProperty("_Cull", properties, false);
                doubleSidedNormalMode = BaseShaderGUI.FindProperty("_DoubleSidedNormalMode", properties, false);
                specularAA = BaseShaderGUI.FindProperty("_EnableGeometricSpecularAA", properties, false); 
        	    specularAAScreenSpaceVariance = BaseShaderGUI.FindProperty("_SpecularAAScreenSpaceVariance", properties, false);
                specularAAThreshold = BaseShaderGUI.FindProperty("_SpecularAAThreshold", properties, false);
            }
        }
        public struct LayeredSurfaceInputsProperties
        {
            // Surface Input Prop
            public MaterialProperty layerMask;
            public MaterialProperty layerCount;
            public MaterialProperty vertexColorMode;
            public MaterialProperty mainInfluenceProp;
            public MaterialProperty heightBasedBlendingProp;
            public MaterialProperty heightTransitionProp;
            public MaterialProperty layerInfluenceMaskMap;

            public LayeredSurfaceInputsProperties(MaterialProperty[] properties)
            {
                // Surface Inputs Props
                layerMask = BaseShaderGUI.FindProperty("_LayerMaskMap", properties, false);
                layerInfluenceMaskMap = BaseShaderGUI.FindProperty("_LayerInfluenceMaskMap", properties, false);
                layerCount = BaseShaderGUI.FindProperty("_LayerCount", properties, false);
                vertexColorMode = BaseShaderGUI.FindProperty("_VertexColorMode", properties, false);
                mainInfluenceProp = BaseShaderGUI.FindProperty("_UseMainLayerInfluence", properties, false);
                heightBasedBlendingProp = BaseShaderGUI.FindProperty("_UseHeightBasedBlend", properties, false);
                heightTransitionProp = BaseShaderGUI.FindProperty("_HeightTransition", properties, false);
            }
        }
        public struct DisplacementBlock
        {
            public MaterialProperty displacementMode;
            public MaterialProperty PPDMinSamples;
            public MaterialProperty PPDMaxSamples;
            public MaterialProperty PPDLodThreshold;
            public MaterialProperty ppdPrimitiveLength;
            public MaterialProperty ppdPrimitiveWidth;
            public MaterialProperty invPrimScale;
            public MaterialProperty lockWithObjectScale;
            public MaterialProperty depthOffset;

            // HeightMap properties
            public MaterialProperty heightMap;
            public MaterialProperty heightParametrization;
            public MaterialProperty heightCenter;
            public MaterialProperty heightAmplitude;
            public MaterialProperty heightTessCenter;
            public MaterialProperty heightTessAmplitude;
            public MaterialProperty heightMin;
            public MaterialProperty heightMax;
            public MaterialProperty heightOffset;
    	    public MaterialProperty heightPoMAmplitude;

            public DisplacementBlock(MaterialProperty[] properties)
            {
                displacementMode = BaseShaderGUI.FindProperty("_DisplacementMode", properties, false);
                PPDMinSamples = BaseShaderGUI.FindProperty("_PPDMinSamples", properties, false);
                PPDMaxSamples = BaseShaderGUI.FindProperty("_PPDMaxSamples", properties, false);
                PPDLodThreshold = BaseShaderGUI.FindProperty("_PPDLodThreshold", properties, false);
                ppdPrimitiveLength = BaseShaderGUI.FindProperty("_PPDPrimitiveLength", properties, false);
                ppdPrimitiveWidth = BaseShaderGUI.FindProperty("_PPDPrimitiveWidth", properties, false);
                invPrimScale = BaseShaderGUI.FindProperty("_InvPrimScale", properties, false);
                lockWithObjectScale = BaseShaderGUI.FindProperty("_DisplacementLockObjectScale", properties, false);
                depthOffset = BaseShaderGUI.FindProperty("_DepthOffsetEnable", properties, false);

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
            }
        }

        public struct TessellationOptions
        {
            public MaterialProperty tessellationMode;
            public MaterialProperty phongTessellationEnable;
            public MaterialProperty tessellationShapeFactor;
            public MaterialProperty tessellationFactor;
            public MaterialProperty tessellationEdgeLength;
            public MaterialProperty tessellationFactorMinDistance;
            public MaterialProperty tessellationFactorMaxDistance;
            public MaterialProperty tessellationBackFaceCullEpsilon;

            public TessellationOptions(MaterialProperty[] properties)
            {
                tessellationMode = BaseShaderGUI.FindProperty("_TessellationMode", properties, false);
                phongTessellationEnable = BaseShaderGUI.FindProperty("_PhongTessellationMode", properties, false);
                tessellationShapeFactor = BaseShaderGUI.FindProperty("_TessellationShapeFactor", properties, false);
                tessellationFactor = BaseShaderGUI.FindProperty("_TessellationFactor", properties, false);
                tessellationEdgeLength = BaseShaderGUI.FindProperty("_TessellationEdgeLength", properties, false);
                tessellationFactorMinDistance = BaseShaderGUI.FindProperty("_TessellationFactorMinDistance", properties, false);
                tessellationFactorMaxDistance = BaseShaderGUI.FindProperty("_TessellationFactorMaxDistance", properties, false);
                tessellationBackFaceCullEpsilon = BaseShaderGUI.FindProperty("_TessellationBackFaceCullEpsilon", properties, false);
            }
        }

        public struct EmissionInputs
        {
            public MaterialProperty emissionColor;
		    public MaterialProperty emissionMap;
		    public MaterialProperty emissionScale;
            public MaterialProperty emissionWithBase;

            public EmissionInputs(MaterialProperty[] properties)
            {
                emissionColor = BaseShaderGUI.FindProperty("_EmissionColor", properties, false);
			    emissionMap = BaseShaderGUI.FindProperty("_EmissionMap", properties, false);
			    emissionScale = BaseShaderGUI.FindProperty("_EmissionScale", properties, false);
                emissionWithBase = BaseShaderGUI.FindProperty("_AlbedoAffectEmissive", properties, false);
            }
        }

        public struct AdvancedOptions
        {
            public MaterialProperty castShadows;
            public MaterialProperty receiveShadows;
            public MaterialProperty highlights;
            public MaterialProperty reflections;
            public MaterialProperty coatNormalEnabled;

            public MaterialProperty horizonOcclusion;
            public MaterialProperty horizonFade;
            public MaterialProperty specularOcclusionMode;
            public MaterialProperty giOcclusionBias;

            public AdvancedOptions(MaterialProperty[] properties)
            {
                castShadows = BaseShaderGUI.FindProperty("_CastShadows", properties, false);
                receiveShadows = BaseShaderGUI.FindProperty("_ReceiveShadows", properties, false);
                highlights = BaseShaderGUI.FindProperty("_SpecularHighlights", properties, false);
                reflections = BaseShaderGUI.FindProperty("_EnvironmentReflections", properties, false);
                coatNormalEnabled = BaseShaderGUI.FindProperty("_CoatNormal", properties, false);

                horizonOcclusion = BaseShaderGUI.FindProperty("_HorizonOcclusion", properties, false);
                horizonFade = BaseShaderGUI.FindProperty("_HorizonFade", properties, false);
                specularOcclusionMode = BaseShaderGUI.FindProperty("_SpecularOcclusionMode", properties, false);
                giOcclusionBias = BaseShaderGUI.FindProperty("_GIOcclusionBias", properties, false);
            }
        }
    }
}