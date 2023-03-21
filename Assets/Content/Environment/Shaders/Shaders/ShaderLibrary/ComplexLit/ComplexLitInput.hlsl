#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "ComplexSurfaceInput.hlsl"
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
    half4 _InvPrimScale;

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

    real4 _HeightMap_TexelSize;
    half _HeightCenter;
    half _HeightAmplitude;
    half _HeightOffset;
    half _HeightPoMAmplitude;

    half _Anisotropy;

    half _IridescenceThickness;
    half4 _IridescenceThicknessRemap;
    half _IridescenceMaskScale;
    half _IridescenceShift;
    
    half4 _ScatteringColor;
    half4 _ScatteringShadowsColor;
    half _Thickness;
    half _Curvature;
    half4 _ThicknessCurvatureRemap;
    half _TransmissionScale;

    half _TranslucencyScale;
    half _TranslucencyPower;
    half _TranslucencyAmbient;
    half _TranslucencyDistortion;
    half _TranslucencyShadows;

    half _ClearCoatMask;
    half _ClearCoatSmoothness;
    half _CoatNormalScale;

    half4 _EmissionColor;
    half _EmissionScale;

    real4 _DetailMap_ST;
    half _DetailAlbedoScale;
    half _DetailNormalScale;
    half _DetailSmoothnessScale;

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

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseMap_ST)
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

    UNITY_DOTS_INSTANCED_PROP(float4, _HeightMap_TexelSize)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightCenter)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightAmplitude)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightOffset)
    UNITY_DOTS_INSTANCED_PROP(float , _HeightPoMAmplitude)

    UNITY_DOTS_INSTANCED_PROP(float , _Anisotropy)
    UNITY_DOTS_INSTANCED_PROP(float , _IridescenceMaskScale)
    UNITY_DOTS_INSTANCED_PROP(float , _IridescenceThickness)
    UNITY_DOTS_INSTANCED_PROP(float , _IridescenceThicknessRemap)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _ScatteringColor)
    UNITY_DOTS_INSTANCED_PROP(float , _Thickness)
    UNITY_DOTS_INSTANCED_PROP(float , _Curvature)
    UNITY_DOTS_INSTANCED_PROP(float4, _ThicknessCurvatureRemap)
    UNITY_DOTS_INSTANCED_PROP(float , _TransmissionScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _TranslucencyColor)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyScale)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyPower)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyAmbient)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyDistortion)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyShadows)

    UNITY_DOTS_INSTANCED_PROP(float , _ClearCoatMask)
    UNITY_DOTS_INSTANCED_PROP(float , _ClearCoatSmoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _CoatNormalScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float, _EmissionScale)

    UNITY_DOTS_INSTANCED_PROP(float4, _DetailMap_ST)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailAlbedoScale)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _DetailSmoothnessScale)

    UNITY_DOTS_INSTANCED_PROP(float , _HorizonFade)
    UNITY_DOTS_INSTANCED_PROP(float , _GIOcclusionBias)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _DoubleSidedConstants                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DoubleSidedConstants)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)
#define _AlphaCutoffShadow                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AlphaCutoffShadow)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _PPDMinSamples                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__PPDMinSamples)
#define _PPDMaxSamples                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__PPDMaxSamples)
#define _PPDLodThreshold                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__PPDLodThreshold)

#define _BaseMap_ST                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseMap_ST)
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

#define _HeightMap_TexelSize                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__HeightMap_TexelSize)
#define _HeightCenter                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightCenter)
#define _HeightAmplitude                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightAmplitude)
#define _HeightOffset                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightOffset)
#define _HeightPoMAmplitude                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HeightPoMAmplituder)

#define _Anisotropy                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Anisotropy)
#define _IridescenceMaskScale                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__IridescenceMaskScale)
#define _IridescenceThickness                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__IridescenceThickness)
#define _IridescenceThicknessRemap                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__IridescenceThicknessRemap)

#define _ScatteringColor                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__ScatteringColor)
#define _Thickness                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Thickness)
#define _Curvature                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Curvature)
#define _ThicknessCurvatureRemap                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__ThicknessCurvatureRemap)
#define _TransmissionScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TransmissionScale)

#define _TranslucencyColor                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__TranslucencyColor)
#define _TranslucencyScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyScale)
#define _TransmissionScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TransmissionScale)
#define _TranslucencyPower                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyPower)
#define _TranslucencyAmbient                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyAmbient)
#define _TranslucencyDistortion                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyDistortion)
#define _TranslucencyShadows                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyShadows)

#define _ClearCoatMask                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ClearCoatMask)
#define _ClearCoatSmoothness                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ClearCoatSmoothness)
#define _CoatNormalScale                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__CoatNormalScale)

#define _EmissionColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
#define _EmissionScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__EmissionScale)

#define _DetailMap_ST                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DetailMap_ST)
#define _DetailAlbedoScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailAlbedoScale)
#define _DetailNormalScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailNormalScale)
#define _DetailSmoothnessScale                        UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__DetailSmoothnessScale)

#define _HorizonFade                                  UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__HorizonFade)
#define _GIOcclusionBias                              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__GIOcclusionBias)
#endif

half4 MaskMapping(real2 uv)
{
    half4 Out;
    half4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv);
    Out.r = _MetallicRemapMin + maskMap.r * (_MetallicRemapMax - _MetallicRemapMin);
    Out.g = _AORemapMin + maskMap.g * (_AORemapMax - _AORemapMin);
    Out.b = maskMap.b;
    Out.a = _SmoothnessRemapMin + maskMap.a * (_SmoothnessRemapMax - _SmoothnessRemapMin);

    return Out;
}

// Returns clear coat parameters
// .x/.r == mask
// .y/.g == smoothness
half2 SampleClearCoat(float2 uv)
{
#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoatMaskSmoothness = half2(_ClearCoatMask, _ClearCoatSmoothness);

#if defined(_CLEARCOATMAP)
    clearCoatMaskSmoothness *= SAMPLE_TEXTURE2D(_ClearCoatMap, sampler_ClearCoatMap, uv).rg;
#endif

    return clearCoatMaskSmoothness;
#else
    return half2(0.0, 1.0);
#endif  // _CLEARCOAT
}

inline void InitializeStandardLitSurfaceData(real2 uv, out SurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

    half metallicValue = _Metallic;
    half smoothnessValue = _Smoothness;
    half detailMask = 1.0h;
    half aoValue = 1.0h;
#ifdef _MASKMAP
    half4 maskMapUnpack = MaskMapping(uv);
    metallicValue = maskMapUnpack.r;
    smoothnessValue = maskMapUnpack.a;
    detailMask = maskMapUnpack.b;
    aoValue = maskMapUnpack.g;
#endif

#ifdef _SPECULAR_SETUP
    outSurfaceData.metallic = 1.0h;
    outSurfaceData.specular = SAMPLE_TEXTURE2D(_SpecularColorMap, sampler_SpecularColorMap, uv).rgb * _SpecularColor.rgb;
#else
    outSurfaceData.metallic = metallicValue;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
#endif

    real3 normalMap = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    real3 tangentMap = half3(0.0, 1.0, 1.0);
#ifdef _TANGENTMAP
    tangentMap = UnpackNormalmapRGorAG(SAMPLE_TEXTURE2D(_TangentMap, sampler_TangentMap, uv));
#endif

    outSurfaceData.smoothness = smoothnessValue;
    outSurfaceData.normalTS = normalMap;
    outSurfaceData.bentNormalTS = SampleBentNormal(uv, TEXTURE2D_ARGS(_BentNormalMap, sampler_BentNormalMap), _BumpScale);
    outSurfaceData.tangentTS = tangentMap;
    outSurfaceData.occlusion = aoValue;

#ifdef _ANISOTROPYMAP
    outSurfaceData.anisotropy = SAMPLE_TEXTURE2D(_AnisotropyMap, sampler_AnisotropyMap, uv).r;
#else
    outSurfaceData.anisotropy = 1.0;
#endif
    outSurfaceData.anisotropy *= _Anisotropy;

#ifdef _MATERIAL_FEATURE_IRIDESCENCE
    #if defined(_IRIDESCENCE_THICKNESSMAP)
    half iridescenceThickness = _IridescenceThicknessRemap.x + _IridescenceThicknessRemap.y * SAMPLE_TEXTURE2D(_IridescenceThicknessMap, sampler_IridescenceThicknessMap, uv).r;
    #else
    half iridescenceThickness = _IridescenceThickness;
    #endif

    half iridescenceMask = _IridescenceMaskScale;
    iridescenceMask *= SAMPLE_TEXTURE2D(_IridescenceMaskMap, sampler_IridescenceMaskMap, uv).r;

    outSurfaceData.iridescenceTMS = half3(iridescenceThickness, iridescenceMask, _IridescenceShift);
#else
    outSurfaceData.iridescenceTMS = half3(1.0, 0.0, 0.0);
#endif

    outSurfaceData.thickness = 1.0h;
    outSurfaceData.curvature = 0.0h;
    outSurfaceData.scatteringColor = 0.0h;
    outSurfaceData.scatteringShadowsColor = 0.0h;
    outSurfaceData.transmissionScale = 0.0h;
    outSurfaceData.translucencyScale = 0.0h;
    outSurfaceData.translucencyPower = 0.0h;
    outSurfaceData.translucencyAmbient = 0.0h;
    outSurfaceData.translucencyDistortion = 0.0h;
    outSurfaceData.translucencyShadows = 1.0h;
#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING)
    #ifdef _THICKNESS_CURVATUREMAP
    half2 thicknessCurvature = SAMPLE_TEXTURE2D(_ThicknessCurvatureMap, sampler_ThicknessCurvatureMap, uv).rg;
    outSurfaceData.thickness = _ThicknessCurvatureRemap.x + thicknessCurvature.r * (_ThicknessCurvatureRemap.y - _ThicknessCurvatureRemap.x);
    outSurfaceData.curvature = _ThicknessCurvatureRemap.z + thicknessCurvature.g * (_ThicknessCurvatureRemap.w - _ThicknessCurvatureRemap.z);
    #else
    outSurfaceData.thickness = _Thickness;
    outSurfaceData.curvature = _Curvature;
    #endif
    outSurfaceData.scatteringColor = _ScatteringColor.rgb;
    outSurfaceData.scatteringShadowsColor = _ScatteringShadowsColor.rgb;
    outSurfaceData.transmissionScale = _TransmissionScale;
#elif defined(_MATERIAL_FEATURE_TRANSLUCENCY)
    #ifdef _THICKNESS_CURVATUREMAP
    half2 thicknessCurvature = SAMPLE_TEXTURE2D(_ThicknessCurvatureMap, sampler_ThicknessCurvatureMap, uv).rg;
    outSurfaceData.thickness = _ThicknessCurvatureRemap.x + thicknessCurvature.r * (_ThicknessCurvatureRemap.y - _ThicknessCurvatureRemap.x);
    #else
    outSurfaceData.thickness = _Thickness;
    #endif
    outSurfaceData.scatteringColor = _ScatteringColor.rgb;
    outSurfaceData.translucencyScale = _TranslucencyScale;
    outSurfaceData.translucencyPower = 100.0h * _TranslucencyPower;
    outSurfaceData.translucencyAmbient = _TranslucencyAmbient;
    outSurfaceData.translucencyDistortion = _TranslucencyDistortion;
    outSurfaceData.translucencyShadows = _TranslucencyShadows;
#endif

#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    half2 clearCoat = SampleClearCoat(uv);
    outSurfaceData.clearCoatMask       = clearCoat.r;
    outSurfaceData.clearCoatSmoothness = clearCoat.g;
    #ifdef _CLEARCOAT_NORMALMAP
        real3 coatNormalMap = SampleNormal(uv, TEXTURE2D_ARGS(_CoatNormalMap, sampler_CoatNormalMap), _CoatNormalScale);
        outSurfaceData.coatNormalTS = coatNormalMap;
    #else
        outSurfaceData.coatNormalTS = real3(0.0, 0.0, 1.0);
    #endif
#else
    outSurfaceData.clearCoatMask = 0.0h;
    outSurfaceData.clearCoatSmoothness = 1.0h;
    outSurfaceData.coatNormalTS = real3(0.0, 0.0, 1.0);
#endif

#if defined(_DETAIL)
    real2   detailUV = TRANSFORM_TEX(uv, _DetailMap);
    half4   detail = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, detailUV);
    half    detailAlbedo = detail.r;
    half3   detailNormal = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detail.g, detail.a, 1.0h, 1.0h))), _DetailNormalScale);
    outSurfaceData.albedo = DetailAlbedo(outSurfaceData.albedo, detailAlbedo, detailMask, _DetailAlbedoScale);
    outSurfaceData.normalTS = DetailNormal(normalMap, detailNormal, detailMask);
    outSurfaceData.smoothness = DetailSmoothness(smoothnessValue, detail.b, _DetailSmoothnessScale, detailMask);
#endif

    // Emission
    outSurfaceData.emission = 0;
#ifdef _EMISSION
    outSurfaceData.emission = _EmissionScale * SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap)); 
    #ifdef _EMISSION_WITH_BASE
        outSurfaceData.emission *= outSurfaceData.albedo;
    #endif
#endif

    outSurfaceData.geomNormalWS = 0.0h;
    outSurfaceData.horizonFade = _HorizonFade;

    outSurfaceData.giOcclusionBias = _GIOcclusionBias;
}
#endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
