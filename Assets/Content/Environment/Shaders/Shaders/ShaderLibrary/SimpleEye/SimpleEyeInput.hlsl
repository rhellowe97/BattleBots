#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
    half _Cutoff;
    half _SpecularAAScreenSpaceVariance;
    half _SpecularAAThreshold;
    
    real4 _BaseMap_ST;
    half4 _BaseColor;
    half _HueScale;
    half _SaturationScale;

    half _Smoothness;
    half _ScleraSmoothness;
    half _CorneaSmoothness;
    half _BumpScale;
    half _ParallaxAmplitude;
    
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
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAScreenSpaceVariance)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAThreshold)

    
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _HueScale)
    UNITY_DOTS_INSTANCED_PROP(float , _SaturationScale)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _ScleraSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _CorneaSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _BumpScale)
    UNITY_DOTS_INSTANCED_PROP(float , _ParallaxAmplitude)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float , _EmissionScale)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _BaseColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
#define _HueScale                                     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HueScale)
#define _SaturationScale                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SaturationScale)
#define _Smoothness                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness)
#define _ScleraSmoothness                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ScleraSmoothness)
#define _CorneaSmoothness                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__CorneaSmoothness)
#define _BumpScale                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__BumpScale)
#define _ParallaxAmplitude                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ParallaxAmplitude)

#define _EmissionColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
#define _EmissionScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionScale)
#endif

TEXTURE2D(_OpacityMap);                   SAMPLER(sampler_OpacityMap);
TEXTURE2D(_HeightMap);                    SAMPLER(sampler_HeightMap);

void HueRotation(inout real3 aColor, real aHue)
{
    real angle = radians(aHue);
    real3 k = real3(0.57735, 0.57735, 0.57735);
    real cosAngle = cos(angle);
    aColor = aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1.0h - cosAngle);
}

void Saturation(real3 In, real Saturation, out real3 Out)
{
    real luma = dot(In, real3(0.2126729, 0.7151522, 0.0721750));
    Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
}

inline void InitializeStandardLitSurfaceData(real2 uv, out SurfaceData outSurfaceData)
{
    real opacityMap = SAMPLE_TEXTURE2D(_OpacityMap, sampler_OpacityMap, uv).r;
    real3 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb;

    real3 irisColor = baseColor;
#ifdef _HUE
    HueRotation(irisColor, _HueScale * 36.0h);
    baseColor = lerp(baseColor, irisColor, opacityMap);
#endif
#ifdef _SATURATION
    Saturation(irisColor, _SaturationScale, irisColor);
    baseColor = lerp(baseColor, irisColor, opacityMap);
#endif

    real smoothnessValue = _Smoothness;
    real3 scleraNormalMap = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
#ifdef _OPACITY_MAP
    real scleraSmoothness = lerp(_ScleraSmoothness, 0.0h, opacityMap);
    real corneaSmoothness = lerp(0.0h, _CorneaSmoothness, opacityMap);
    smoothnessValue = scleraSmoothness + corneaSmoothness;
#endif

    outSurfaceData.albedo = baseColor;
    outSurfaceData.alpha = 1.0h;
    outSurfaceData.metallic = 0.0h;
    outSurfaceData.specular = 0.0h;
    outSurfaceData.smoothness = smoothnessValue;
    outSurfaceData.normalTS = scleraNormalMap;
    outSurfaceData.occlusion = 1.0h;
    outSurfaceData.emission = 0.0;

#ifdef _EMISSION
    outSurfaceData.emission = _EmissionScale * SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)); 
    #ifdef _EMISSION_WITH_BASE
        outSurfaceData.emission *= outSurfaceData.albedo;
    #endif
#endif

    outSurfaceData.clearCoatMask = 0.0;
    outSurfaceData.clearCoatSmoothness = 1.0;
}
#endif