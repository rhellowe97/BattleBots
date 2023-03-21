#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "ShaderLibrary/SimpleLit/SimpleSurfaceInput.hlsl"
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
    half4 _SpecularColor;
    half _Metallic;
    half _Smoothness;
    half _MetallicRemapMin;
    half _MetallicRemapMax;
    half _SmoothnessRemapMin;
    half _SmoothnessRemapMax;
    half _AORemapMin;
    half _AORemapMax;
    half _BumpScale;
    
    half4 _EmissionColor;
    half _EmissionScale;

    half _HorizonFade;
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
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecularColor)
    UNITY_DOTS_INSTANCED_PROP(float , _Metallic)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _BumpScale)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _EmissionScale)
    
    UNITY_DOTS_INSTANCED_PROP(float , _HorizonFade)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)


#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _DoubleSidedConstants                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DoubleSidedConstants)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
#define _AlphaCutoffShadow                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AlphaCutoffShadow)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _BaseColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
#define _SpecularColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__SpecularColor)
#define _Metallic                                     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Metallic)
#define _Smoothness                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness)
#define _MetallicRemapMin                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMin)
#define _MetallicRemapMax                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMax)
#define _SmoothnessRemapMin                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin)
#define _SmoothnessRemapMax                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax)
#define _AORemapMin                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin)
#define _AORemapMax                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax)
#define _BumpScale                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__BumpScale)

#define _EmissionColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
#define _EmissionScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__EmissionScale)

#define _HorizonFade                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HorizonFade)
#endif

half3 MaskMapping(real2 uv)
{
    half3 Out = half3(0.0, 0.0, 0.0);
    half3 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv).rga;
    Out.r = _MetallicRemapMin + maskMap.r * (_MetallicRemapMax - _MetallicRemapMin);
    Out.g = _AORemapMin + maskMap.g * (_AORemapMax - _AORemapMin);
    Out.b = _SmoothnessRemapMin + maskMap.b * (_SmoothnessRemapMax - _SmoothnessRemapMin);

    return Out;
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

    half metallicValue = _Metallic;
    half smoothnessValue = _Smoothness;
    half aoValue = 1.0h;
#ifdef _MASKMAP
    half3 MaskMapUnpack = MaskMapping(uv);
    metallicValue = MaskMapUnpack.r;
    smoothnessValue = MaskMapUnpack.b;
    aoValue = MaskMapUnpack.g;
#endif

#ifdef _SPECULAR_SETUP
    outSurfaceData.metallic = 1.0h;
    outSurfaceData.specular = SAMPLE_TEXTURE2D(_SpecularColorMap, sampler_SpecularColorMap, uv).rgb * _SpecularColor.rgb;
#else
    outSurfaceData.metallic = metallicValue;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    outSurfaceData.smoothness = smoothnessValue;
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.occlusion = aoValue;
    outSurfaceData.emission = 0;

#ifdef _EMISSION
    outSurfaceData.emission = _EmissionScale * SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)); 
    #ifdef _EMISSION_WITH_BASE
        outSurfaceData.emission *= outSurfaceData.albedo;
    #endif
#endif

    outSurfaceData.clearCoatMask = 0.0;
    outSurfaceData.clearCoatSmoothness = 1.0;

    outSurfaceData.geomNormalWS = 0.0;
    outSurfaceData.horizonFade = _HorizonFade;
}
#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
