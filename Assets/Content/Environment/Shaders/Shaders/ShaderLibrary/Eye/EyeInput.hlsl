#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "EyeSurfaceInput.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
    half _Cutoff;
    half _SunSensitivity;
    half _LightSensitivity;
    half _PupilFactorMin;
    half _PupilFactorMax;
    half _SpecularAAScreenSpaceVariance;
    half _SpecularAAThreshold;

    real4 _BaseMap_ST;
    half4 _BaseColor;
    half _ScleraNormalScale;
    half _IrisNormalScale;
    half4 _IrisClampColor;
    half _PupilRadius;
    half _PupilAperture;
    half _MinimalPupilAperture;
    half _MaximalPupilAperture;
    half _ScleraSmoothness;
    half _CorneaSmoothness;
    half _IrisOffset;
    
    half4 _LimbalRingColor;
    half _LimbalRingSizeIris;
    half _LimbalRingSizeSclera;
    half _LimbalRingFade;
    half _LimbalRingIntensity;

    half4 _EmissionColor;
    half _EmissionScale;
CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float , _Surface)
    UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _SunSensitivity)
    UNITY_DOTS_INSTANCED_PROP(float , _LightSensitivity)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAScreenSpaceVariance)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAThreshold)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _ScleraNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _IrisNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float4, _IrisClampColor)
    UNITY_DOTS_INSTANCED_PROP(float , _PupilRadius)
    UNITY_DOTS_INSTANCED_PROP(float , _PupilAperture)
    UNITY_DOTS_INSTANCED_PROP(float , _MinimalPupilAperture)
    UNITY_DOTS_INSTANCED_PROP(float , _MaximalPupilAperture)
    UNITY_DOTS_INSTANCED_PROP(float , _ScleraSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _CorneaSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _IrisOffset)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingSizeIris)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingSizeSclera)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingFade)
    UNITY_DOTS_INSTANCED_PROP(float , _LimbalRingIntensity)

    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float, _EmissionScale)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)


#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
#define _SunSensitivity                               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SunSensitivity)
#define _LightSensitivity                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__LightSensitivity)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _BaseMap_ST                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseMap_ST)
#define _BaseColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
#define _ScleraNormalScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ScleraNormalScale)
#define _IrisNormalScale                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__IrisNormalScale)

#define _IrisClampColor                               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__IrisClampColor)
#define _PupilRadius                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__PupilRadius)
#define _PupilAperture                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__PupilAperture)
#define _MinimalPupilAperture                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MinimalPupilAperture)
#define _MaximalPupilAperture                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MaximalPupilAperture)
#define _ScleraSmoothness                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ScleraSmoothness)
#define _CorneaSmoothness                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__CorneaSmoothness)
#define _IrisOffset                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__IrisOffset)

#define _LimbalRingColor                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__LimbalRingColor)
#define _LimbalRingSizeIris                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__LimbalRingSizeIris)
#define _LimbalRingSizeSclera                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__LimbalRingSizeSclera)
#define _LimbalRingFade                               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__LimbalRingFade)
#define _LimbalRingIntensity                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__LimbalRingIntensity)

#define _EmissionColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
#define _EmissionScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__EmissionScale)
#endif

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData.albedo = 1.0h;
    outSurfaceData.specular = 0.0h;
    outSurfaceData.metallic = 0.0h;
    outSurfaceData.alpha = 1.0h;
    outSurfaceData.emission = 0.0h;
    outSurfaceData.smoothness = 0.5h;
    outSurfaceData.normalTS = 1.0h;
    outSurfaceData.occlusion = 1.0h;
    outSurfaceData.surfaceMask = 1.0h;
    outSurfaceData.clearCoatMask = 0.0;
    outSurfaceData.clearCoatSmoothness = 1.0;
}

#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
