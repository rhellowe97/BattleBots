#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "LayeredSurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
half _Surface;
half4 _DoubleSidedConstants;
half _Cutoff;
half _AlphaCutoffShadow;
half _SpecularAAScreenSpaceVariance;
half _SpecularAAThreshold;

half _PPDMinSamples;
half _PPDMaxSamples;
half _PPDLodThreshold;

real4 _LayerMaskMap_ST;
half _HeightTransition;
half _LayerCount;

half _OpacityAsDensity0; half _OpacityAsDensity1; half _OpacityAsDensity2; half _OpacityAsDensity3;

real4 _BaseMap_ST; real4 _BaseMap1_ST; real4 _BaseMap2_ST; real4 _BaseMap3_ST;
half4 _BaseColor; half4 _BaseColor1; half4 _BaseColor2; half4 _BaseColor3;
half _InheritBaseColor1; half _InheritBaseColor2; half _InheritBaseColor3;

half _Metallic;         half _Metallic1;         half _Metallic2;         half _Metallic3;
half _MetallicRemapMin; half _MetallicRemapMin1; half _MetallicRemapMin2; half _MetallicRemapMin3;
half _MetallicRemapMax; half _MetallicRemapMax1; half _MetallicRemapMax2; half _MetallicRemapMax3;
half _Smoothness;         half _Smoothness1;         half _Smoothness2;         half _Smoothness3;
half _SmoothnessRemapMin; half _SmoothnessRemapMin1; half _SmoothnessRemapMin2; half _SmoothnessRemapMin3;
half _SmoothnessRemapMax; half _SmoothnessRemapMax1; half _SmoothnessRemapMax2; half _SmoothnessRemapMax3;
half _AORemapMin; half _AORemapMin1; half _AORemapMin2; half _AORemapMin3;
half _AORemapMax; half _AORemapMax1; half _AORemapMax2; half _AORemapMax3;

half _NormalScale; half _NormalScale1; half _NormalScale2; half _NormalScale3;
half _InheritBaseNormal1; half _InheritBaseNormal2; half _InheritBaseNormal3;

half4 _HeightMap_TexelSize; half4 _HeightMap1_TexelSize; half4 _HeightMap2_TexelSize; half4 _HeightMap3_TexelSize;
half _HeightAmplitude;     half _HeightAmplitude1;     half _HeightAmplitude2;     half _HeightAmplitude3;
half _HeightCenter;        half _HeightCenter1;        half _HeightCenter2;        half _HeightCenter3;
half _HeightPoMAmplitude;  half _HeightPoMAmplitude1;  half _HeightPoMAmplitude2;  half _HeightPoMAmplitude3;
half _InheritBaseHeight1; half _InheritBaseHeight2; half _InheritBaseHeight3;

real4 _EmissionMap_ST;
half4 _EmissionColor;
half _EmissionScale;

real4 _DetailMap_ST; real4 _DetailMap1_ST; real4 _DetailMap2_ST; real4 _DetailMap3_ST;
half _DetailAlbedoScale;     half _DetailAlbedoScale1;     half _DetailAlbedoScale2;     half _DetailAlbedoScale3;
half _DetailNormalScale;     half _DetailNormalScale1;     half _DetailNormalScale2;     half _DetailNormalScale3;
half _DetailSmoothnessScale; half _DetailSmoothnessScale1; half _DetailSmoothnessScale2; half _DetailSmoothnessScale3;

half _HorizonFade;
half _GIOcclusionBias;
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

    UNITY_DOTS_INSTANCED_PROP(float , _PPDMinSamples)
    UNITY_DOTS_INSTANCED_PROP(float , _PPDMaxSamples)
    UNITY_DOTS_INSTANCED_PROP(float , _PPDLodThreshold)

    UNITY_DOTS_INSTANCED_PROP(float4, _LayerMaskMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightTransition)
    UNITY_DOTS_INSTANCED_PROP(float , _LayerCount)

    UNITY_DOTS_INSTANCED_PROP(float , _OpacityAsDensity0)
    UNITY_DOTS_INSTANCED_PROP(float , _OpacityAsDensity1)
    UNITY_DOTS_INSTANCED_PROP(float , _OpacityAsDensity2)
    UNITY_DOTS_INSTANCED_PROP(float , _OpacityAsDensity3)

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap1_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap2_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap3_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor1)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor2)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor3)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseColor1)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseColor2)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseColor3)

    UNITY_DOTS_INSTANCED_PROP(float , _Metallic)
    UNITY_DOTS_INSTANCED_PROP(float , _Metallic1)
    UNITY_DOTS_INSTANCED_PROP(float , _Metallic2)
    UNITY_DOTS_INSTANCED_PROP(float , _Metallic3)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness1)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness2)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness3)

    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMax3)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax3)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin1)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin2)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin3)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax1)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax2)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax3)

    UNITY_DOTS_INSTANCED_PROP(float , _NormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _NormalScale1)
    UNITY_DOTS_INSTANCED_PROP(float , _NormalScale2)
    UNITY_DOTS_INSTANCED_PROP(float , _NormalScale3)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseNormal1)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseNormal2)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseNormal3)

    UNITY_DOTS_INSTANCED_PROP(float4, _HeightMap_TexelSize)
    UNITY_DOTS_INSTANCED_PROP(float4, _HeightMap1_TexelSize)
    UNITY_DOTS_INSTANCED_PROP(float4, _HeightMap2_TexelSize)
    UNITY_DOTS_INSTANCED_PROP(float4, _HeightMap3_TexelSize)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightCenter)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightCenter1)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightCenter2)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightCenter3)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightAmplitude1)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightAmplitude2)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightAmplitude3)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightPoMAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightPoMAmplitude1)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightPoMAmplitude2)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightPoMAmplitude3)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseHeight1)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseHeight2)
    UNITY_DOTS_INSTANCED_PROP(float , _InheritBaseHeight3)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float, _EmissionScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _DetailMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _DetailMap1_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _DetailMap2_ST)
    UNITY_DOTS_INSTANCED_PROP(float4, _DetailMap3_ST)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailAlbedoScale)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailAlbedoScale1)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailAlbedoScale2)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailAlbedoScale3)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailNormalScale1)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailNormalScale2)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailNormalScale3)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailSmoothnessScale)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailSmoothnessScale1)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailSmoothnessScale2)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailSmoothnessScale3)

    UNITY_DOTS_INSTANCED_PROP(float , _HorizonFade)
    UNITY_DOTS_INSTANCED_PROP(float , _GIOcclusionBias)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _DoubleSidedConstants                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DoubleSidedConstants)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
#define _AlphaCutoffShadow                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AlphaCutoffShadow)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _BaseMap_ST                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseMap_ST)
#define _BaseMap1_ST                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseMap1_ST)
#define _BaseMap2_ST                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseMap2_ST)
#define _BaseMap3_ST                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseMap3_ST)
#define _BaseColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
#define _BaseColor1                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor1)
#define _BaseColor2                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor2)
#define _BaseColor3                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor3)
#define _InheritBaseColor1                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__InheritBaseColor1)
#define _InheritBaseColor2                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__InheritBaseColor2)
#define _InheritBaseColor3                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__InheritBaseColor3)

#define _Metallic                                     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Metallic)
#define _Metallic1                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Metallic1)
#define _Metallic2                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Metallic2)
#define _Metallic3                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Metallic3)
#define _Smoothness                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness)
#define _Smoothness1                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness1)
#define _Smoothness2                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness2)
#define _Smoothness3                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness3)

#define _MetallicRemapMin                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMin)
#define _MetallicRemapMin1                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMin1)
#define _MetallicRemapMin2                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMin2)
#define _MetallicRemapMin3                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMin3)
#define _MetallicRemapMax                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMax)
#define _MetallicRemapMax1                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMax1)
#define _MetallicRemapMax2                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMax2)
#define _MetallicRemapMax3                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMax3)
#define _SmoothnessRemapMin                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin)
#define _SmoothnessRemapMin1                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin1)
#define _SmoothnessRemapMin2                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin2)
#define _SmoothnessRemapMin3                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin3)
#define _SmoothnessRemapMax                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax)
#define _SmoothnessRemapMax1                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax1)
#define _SmoothnessRemapMax2                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax2)
#define _SmoothnessRemapMax3                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax3)
#define _AORemapMin                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin)
#define _AORemapMin1                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin1)
#define _AORemapMin2                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin2)
#define _AORemapMin3                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin3)
#define _AORemapMax                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax)
#define _AORemapMax1                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax1)
#define _AORemapMax2                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax2)
#define _AORemapMax3                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax3)

#define _NormalScale                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__NormalScale)
#define _NormalScale1                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__NormalScale1)
#define _NormalScale2                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__NormalScale2)
#define _NormalScale3                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__NormalScale3)
#define _InheritBaseNormal1                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__InheritBaseNormal1)
#define _InheritBaseNormal2                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__InheritBaseNormal2)
#define _InheritBaseNormal3                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__InheritBaseNormal3)

#define _HeightMap_TexelSize                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__HeightMap_TexelSize)
#define _HeightMap1_TexelSize                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__HeightMap1_TexelSize)
#define _HeightMap2_TexelSize                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__HeightMap2_TexelSize)
#define _HeightMap3_TexelSize                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__HeightMap3_TexelSize)
#define _HeightCenter                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightCenter)
#define _HeightCenter1                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata___HeightCenter1)
#define _HeightCenter2                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightCenter2)
#define _HeightCenter3                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightCenter3)
#define _HeightAmplitude                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightAmplitude)
#define _HeightAmplitude1                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightAmplitude1)
#define _HeightAmplitude2                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightAmplitude2)
#define _HeightAmplitude3                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightAmplitude3)
#define _HeightPoMAmplitude                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightPoMAmplitude)
#define _HeightPoMAmplitude1                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightPoMAmplitude1)
#define _HeightPoMAmplitude2                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightPoMAmplitude2)
#define _HeightPoMAmplitude3                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightPoMAmplitude3)
#define _InheritBaseHeight1                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__InheritBaseHeight1)
#define _InheritBaseHeight2                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__InheritBaseHeight2)
#define _InheritBaseHeight3                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__InheritBaseHeight3)

#define _EmissionMap_ST                               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionMap_ST)
#define _EmissionColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
#define _EmissionScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__EmissionScale)

#define _DetailMap_ST                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DetailMap_ST)
#define _DetailMap1_ST                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DetailMap1_ST)
#define _DetailMap2_ST                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DetailMap2_ST)
#define _DetailMap3_ST                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DetailMap3_ST)
#define _DetailAlbedoScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailAlbedoScale)
#define _DetailAlbedoScale1                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailAlbedoScale1)
#define _DetailAlbedoScale2                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailAlbedoScale2)
#define _DetailAlbedoScale3                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailAlbedoScale3)
#define _DetailNormalScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailNormalScale)
#define _DetailNormalScale1                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailNormalScale1)
#define _DetailNormalScale2                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailNormalScale2)
#define _DetailNormalScale3                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailNormalScale3)
#define _DetailSmoothnessScale                        UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailSmoothnessScale)
#define _DetailSmoothnessScale1                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailSmoothnessScale1)
#define _DetailSmoothnessScale2                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailSmoothnessScale2)
#define _DetailSmoothnessScale3                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailSmoothnessScale3)

#define _HorizonFade                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HorizonFade)
#define _GIOcclusionBias                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__GIOcclusionBias)
#endif

#include "LayeredLitData.hlsl"
#include "LayeredInputs.hlsl"
inline void InitializeStandardLitSurfaceData(LayerTexCoord layerTexCoord, half4 vertexColor, out SurfaceData outSurfaceData)
{
    LayeredData layeredData;
    InitializeLayeredData(layerTexCoord, layeredData);

    real weights[_MAX_LAYER];
    half4 blendMasks = GetBlendMask(_LayerMaskMap, sampler_LayerMaskMap, layerTexCoord.layerMaskUV, vertexColor);
    ComputeLayerWeights(_LayerCount, half4(layeredData.heightMap0, layeredData.heightMap1, layeredData.heightMap2, layeredData.heightMap3),
                         half4(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a), blendMasks, _HeightTransition, weights);

#if defined(_MAIN_LAYER_INFLUENCE_MODE)
    #ifdef _INFLUENCEMASK_MAP
    float influenceMask = GetInfluenceMask(layerTexCoord);
    #else
    float influenceMask = 1.0;
    #endif

    if (influenceMask > 0.0f)
    {
        half3 baseMeanColor0 = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, layerTexCoord.baseUV0, 15.0).rgb * _BaseColor.rgb;
        half3 baseMeanColor1 = SAMPLE_TEXTURE2D_LOD(_BaseMap1, sampler_BaseMap, layerTexCoord.baseUV1, 15.0).rgb * _BaseColor1.rgb;
        half3 baseMeanColor2 = SAMPLE_TEXTURE2D_LOD(_BaseMap2, sampler_BaseMap, layerTexCoord.baseUV2, 15.0).rgb * _BaseColor2.rgb;
        half3 baseMeanColor3 = SAMPLE_TEXTURE2D_LOD(_BaseMap3, sampler_BaseMap, layerTexCoord.baseUV3, 15.0).rgb * _BaseColor3.rgb;
        outSurfaceData.albedo = ComputeMainBaseColorInfluence(influenceMask, layeredData.baseColor0.rgb, layeredData.baseColor1.rgb, layeredData.baseColor2.rgb, layeredData.baseColor3.rgb,
                                                                baseMeanColor0, baseMeanColor1, baseMeanColor2, baseMeanColor3,    
                                                                blendMasks.a, half3(_InheritBaseColor1, _InheritBaseColor2, _InheritBaseColor3), weights);

        outSurfaceData.normalTS = ComputeMainNormalInfluence(influenceMask, layeredData.normalMap0, layeredData.normalMap1, layeredData.normalMap2, layeredData.normalMap3,
                                                                blendMasks.a, half3(_InheritBaseNormal1, _InheritBaseNormal2, _InheritBaseNormal3), weights);

        outSurfaceData.bentNormalTS = ComputeMainNormalInfluence(influenceMask, layeredData.bentNormalMap0, layeredData.bentNormalMap1, layeredData.bentNormalMap2, layeredData.bentNormalMap3,
                                                                    blendMasks.a, half3(_InheritBaseNormal1, _InheritBaseNormal2, _InheritBaseNormal3), weights);
    }
    else
#endif
    {
        outSurfaceData.albedo = BlendLayeredVector3(layeredData.baseColor0.rgb, layeredData.baseColor1.rgb, layeredData.baseColor2.rgb, layeredData.baseColor3.rgb, weights);
        outSurfaceData.normalTS = BlendLayeredVector3(layeredData.normalMap0, layeredData.normalMap1, layeredData.normalMap2, layeredData.normalMap3, weights);
        outSurfaceData.bentNormalTS = BlendLayeredVector3(layeredData.bentNormalMap0, layeredData.bentNormalMap1, layeredData.bentNormalMap2, layeredData.bentNormalMap3, weights);
    }

    outSurfaceData.metallic = BlendLayeredScalar(layeredData.maskMap0.r, layeredData.maskMap1.r, layeredData.maskMap2.r, layeredData.maskMap3.r, weights);
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
    outSurfaceData.smoothness = BlendLayeredScalar(layeredData.maskMap0.a, layeredData.maskMap1.a, layeredData.maskMap2.a, layeredData.maskMap3.a, weights);
    outSurfaceData.occlusion = BlendLayeredScalar(layeredData.maskMap0.g, layeredData.maskMap1.g, layeredData.maskMap2.g, layeredData.maskMap3.g, weights);

    outSurfaceData.alpha = LayeredAlpha(BlendLayeredScalar(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a, weights), _Cutoff);
    
    CalculateLayeredDetailMap(layeredData, layerTexCoord, outSurfaceData.albedo, outSurfaceData.normalTS, outSurfaceData.smoothness, weights);

    outSurfaceData.clearCoatMask = 0.0;
    outSurfaceData.clearCoatSmoothness = 0.0;

    outSurfaceData.emission = 0;
#ifdef _EMISSION
    outSurfaceData.emission = _EmissionScale * SampleEmission(layerTexCoord.emissionUV, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)); 
    #ifdef _EMISSION_WITH_BASE
        outSurfaceData.emission *= outSurfaceData.albedo;
    #endif
#endif

    outSurfaceData.geomNormalWS = 0.0;
    outSurfaceData.horizonFade = _HorizonFade;

    outSurfaceData.giOcclusionBias = _GIOcclusionBias;
}
#endif