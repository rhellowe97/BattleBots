#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "HairSurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
    half _Surface;
    half4 _DoubleSidedConstants;
    half _Cutoff;
    half _AlphaCutoffShadow;
    half _SpecularAAScreenSpaceVariance;
    half _SpecularAAThreshold;

    real4 _BaseMap_ST;
    half4 _BaseColor;
    
    half _AORemapMin;
    half _AORemapMax;

    real4 _SmoothnessMaskMap_ST;
    half _Smoothness;
    half _SmoothnessRemapMin;
    half _SmoothnessRemapMax;
    half _BumpScale;

    half4 _SpecularColor;
    half4 _SpecularTintColor;
    half _SpecularMultiplier;
    half _SpecularShift;
    half _SecondarySpecularMultiplier;
    half _SecondarySpecularShift;
    half4 _TransmissionColor;
    half _TransmissionIntensity;
CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float , _Surface)
    UNITY_DOTS_INSTANCED_PROP(float4, _DoubleSidedConstants)
    UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _AlphaCutoffShadow)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAScreenSpaceVariance)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAThreshold)

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)

    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _BumpScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _SpecularColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecularTintColor)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularMultiplier)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularShift)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularMultiplier)
    UNITY_DOTS_INSTANCED_PROP(float , _SecondarySpecularShift)

    UNITY_DOTS_INSTANCED_PROP(float4, _TransmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _TransmissionIntensity)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _DoubleSidedConstants                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DoubleSidedConstants)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
#define _AlphaCutoffShadow                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AlphaCutoffShadow)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _BaseColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)

#define _AORemapMin                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin)
#define _AORemapMax                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax)
#define _Smoothness                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness)
#define _SmoothnessRemapMin                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin)
#define _SmoothnessRemapMax                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax)
#define _BumpScale                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__BumpScale)

#define _SpecularColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__SpecularColor)
#define _SpecularTintColor                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__SpecularTintColor)
#define _SpecularMultiplier                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularMultiplier)
#define _SpecularShift                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularShift)
#define _SecondarySpecularMultiplier                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SecondarySpecularMultiplier)
#define _SecondarySpecularShift                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SecondarySpecularShift)

#define _TransmissionColor                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TransmissionColor)
#define _TransmissionIntensity                        UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TransmissionIntensity)
#endif

TEXTURE2D(_AmbientOcclusionMap);                  SAMPLER(sampler_AmbientOcclusionMap);
TEXTURE2D(_SmoothnessMaskMap);                    SAMPLER(sampler_SmoothnessMaskMap);

#define DEFAULT_HAIR_SPECULAR_VALUE 0.0465

inline void InitializeStandardLitSurfaceData(real2 uv, out SurfaceData outSurfaceData)
{
    real2 baseUV = TRANSFORM_TEX(uv, _BaseMap);

    half4 albedoAlpha = SampleAlbedoAlpha(baseUV, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);

    half aoValue = 1.0h;
    half smoothnessValue = _Smoothness;
#ifdef _AO_MAP
    aoValue = _AORemapMin + SAMPLE_TEXTURE2D(_AmbientOcclusionMap, sampler_AmbientOcclusionMap, baseUV).r * (_AORemapMax - _AORemapMin);
#endif
#ifdef _SMOOTHNESS_MASK
    real2 smoothnessUV = TRANSFORM_TEX(uv, _SmoothnessMaskMap);
    smoothnessValue = lerp(_SmoothnessRemapMin, _SmoothnessRemapMax, SAMPLE_TEXTURE2D(_SmoothnessMaskMap, sampler_SmoothnessMaskMap, smoothnessUV).r);
#endif

    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    outSurfaceData.normalTS = SampleNormal(baseUV, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.metallic = 0;
    outSurfaceData.smoothness = 0.0;
    outSurfaceData.occlusion = aoValue;
    outSurfaceData.emission = 0;
    outSurfaceData.specular = DEFAULT_HAIR_SPECULAR_VALUE;

    outSurfaceData.specularTint = albedoAlpha.a * lerp(real3(1.0h, 1.0h, 1.0h), _SpecularTintColor.rgb, 0.3h) * _SpecularMultiplier;
    outSurfaceData.secondarySpecularTint = albedoAlpha.a * lerp(real3(0.0h, 0.0h, 0.0h), _SpecularColor.rgb, 0.5h) * _SecondarySpecularMultiplier;
    outSurfaceData.specularShift = _SpecularShift;
    outSurfaceData.secondarySpecularShift = _SecondarySpecularShift;
    outSurfaceData.perceptualSmoothness = smoothnessValue;
    outSurfaceData.secondaryPerceptualSmoothness = smoothnessValue;

    outSurfaceData.transmissionColor = _TransmissionColor.rgb;
    outSurfaceData.transmissionIntensity = _TransmissionIntensity;

    outSurfaceData.clearCoatMask = 0.0;
    outSurfaceData.clearCoatSmoothness = 1.0;

    outSurfaceData.geomNormalWS = 0.0;
}
#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
