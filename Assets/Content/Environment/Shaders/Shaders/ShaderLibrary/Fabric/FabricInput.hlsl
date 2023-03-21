#ifndef UNIVERSAL_LIT_INPUT_INCLUDED
#define UNIVERSAL_LIT_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "FabricSurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

// NOTE: Do not ifdef the properties here as SRP batcher can not handle different layouts.
CBUFFER_START(UnityPerMaterial)
    half _Surface;
    half4 _DoubleSidedConstants;
    half _Cutoff;
    half _SpecularAAScreenSpaceVariance;
    half _SpecularAAThreshold;

    real4 _BaseMap_ST;
    half4 _BaseColor;
    half4 _SpecColor;

    half _Anisotropy;
    half _Smoothness;
    half _SmoothnessRemapMin;
    half _SmoothnessRemapMax;
    half _AORemapMin;
    half _AORemapMax;
    half _BumpScale;

    //Translucency
    half _Thickness;
    half4 _ThicknessRemap;
    half4 _TranslucencyColor;
    half _TranslucencyScale;
    half _TranslucencyPower;
    half _TranslucencyAmbient;
    half _TranslucencyDistortion;
    half _TranslucencyShadows;

    //Thread and Fuzz
    real4 _ThreadMap_ST;
    half _ThreadAOScale;
    half _ThreadNormalScale;
    half _ThreadSmoothnessScale;
    half _FuzzMapScale;
    half _FuzzStrength;

    half4 _EmissionColor;
    half _EmissionScale;
CBUFFER_END

// NOTE: Do not ifdef the properties for dots instancing, but ifdef the actual usage.
// Otherwise you might break CPU-side as property constant-buffer offsets change per variant.
// NOTE: Dots instancing is orthogonal to the constant buffer above.
#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float , _Surface)
    UNITY_DOTS_INSTANCED_PROP(float4, _DoubleSidedConstants)
    UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAScreenSpaceVariance)
    UNITY_DOTS_INSTANCED_PROP(float , _SpecularAAThreshold)

    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)

    UNITY_DOTS_INSTANCED_PROP(float , _Anisotropy)
    UNITY_DOTS_INSTANCED_PROP(float , _Smoothness)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _MetallicRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _SmoothnessRemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMin)
    UNITY_DOTS_INSTANCED_PROP(float , _AORemapMax)
    UNITY_DOTS_INSTANCED_PROP(float , _BumpScale)

    UNITY_DOTS_INSTANCED_PROP(float , _Thickness)
    UNITY_DOTS_INSTANCED_PROP(float4, _ThicknessRemap)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyColor)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyPower)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyAmbient)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyDistortion)
    UNITY_DOTS_INSTANCED_PROP(float , _TranslucencyShadows)

    UNITY_DOTS_INSTANCED_PROP(float , _ThreadAOScale)
    UNITY_DOTS_INSTANCED_PROP(float , _ThreadNormalScale)
    UNITY_DOTS_INSTANCED_PROP(float , _ThreadSmoothnessScale)
    UNITY_DOTS_INSTANCED_PROP(float , _FuzzMapScale)
    UNITY_DOTS_INSTANCED_PROP(float , _FuzzStrength)
    
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float, _EmissionScale)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _Surface                                      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Surface)
#define _DoubleSidedConstants                         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__DoubleSidedConstants)
#define _SpecularAAScreenSpaceVariance                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAScreenSpaceVariance)
#define _SpecularAAThreshold                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SpecularAAThreshold)

#define _BaseColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__BaseColor)
#define _SpecColor                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__SpecColor)
#define _Cutoff                                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Cutoff)

#define _Anisotropy                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Anisotropy)
#define _Smoothness                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Smoothness)
#define _MetallicRemapMin                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMin)
#define _MetallicRemapMax                             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__MetallicRemapMax)
#define _SmoothnessRemapMin                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMin)
#define _SmoothnessRemapMax                           UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__SmoothnessRemapMax)
#define _AORemapMin                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMin)
#define _AORemapMax                                   UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__AORemapMax)
#define _BumpScale                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__BumpScale)

#define _Thickness                                    UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__Thickness)
#define _ThicknessRemap                               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__ThicknessRemap)
#define _TranslucencyColor                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__TranslucencyColor)
#define _TranslucencyPower                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyPower)
#define _TranslucencyAmbient                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyAmbient)
#define _TranslucencyDistortion                       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyDistortion)
#define _TranslucencyShadows                          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__TranslucencyShadows)

#define _ThreadAOScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ThreadAOScale)
#define _ThreadNormalScale                            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ThreadNormalScale)
#define _ThreadSmoothnessScale                        UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__ThreadSmoothnessScale)
#define _FuzzMapScale                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__FuzzMapScale)
#define _FuzzStrength                                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__FuzzStrength)

#define _EmissionColor                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__EmissionColor)
#define _EmissionScale                                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata__EmissionScale)
#endif

half3 BumpStrength(half3 In, half Strength)
{
    return half3(In.rg * Strength, lerp(1.0h, In.b, saturate(Strength)));
}

half2 MaskMapping(real2 uv)
{
    half2 Out;
    half2 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, uv).ga;
    Out.x = _AORemapMin + maskMap.x * (_AORemapMax - _AORemapMin);
    Out.y = _SmoothnessRemapMin + maskMap.y * (_SmoothnessRemapMax - _SmoothnessRemapMin);

    return Out;
}

inline void InitializeStandardLitSurfaceData(real2 uv, out SurfaceData outSurfaceData)
{
    real2 baseUV = TRANSFORM_TEX(uv, _BaseMap);
    real2 threadUV = TRANSFORM_TEX(uv, _ThreadMap);

    half4 albedoAlpha = SampleAlbedoAlpha(baseUV, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

    half smoothnessValue = _Smoothness;
    half aoValue = 1.0h;
#ifdef _MASKMAP
    half2 maskMapUnpuck = MaskMapping(baseUV);
    smoothnessValue = maskMapUnpuck.r;
    aoValue = maskMapUnpuck.g;
#endif

    real3 normalMap = SampleNormal(baseUV, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

    //Fuzz
#ifdef _FUZZMAP
    half fuzz = lerp(0.0h, SAMPLE_TEXTURE2D(_FuzzMap, sampler_FuzzMap, _FuzzMapScale * threadUV).r, _FuzzStrength);
    outSurfaceData.albedo = saturate(outSurfaceData.albedo + fuzz.xxx);
#endif

    outSurfaceData.specular = _SpecColor.rgb;
#ifdef _SHEENMAP
    outSurfaceData.specular = _SpecColor.rgb * SAMPLE_TEXTURE2D(_SheenMap, sampler_SheenMap, baseUV).rgb;
#endif
    outSurfaceData.metallic = 0.0;
    outSurfaceData.smoothness = smoothnessValue;
    outSurfaceData.sheenSmoothness = _Smoothness;
    outSurfaceData.anisotropy = _Anisotropy;
    outSurfaceData.normalTS = normalMap;
    outSurfaceData.occlusion = aoValue;
    outSurfaceData.emission = 0.0;
    
    outSurfaceData.sheenColor = _SpecColor.rgb;
#ifdef _SHEENMAP
    outSurfaceData.sheenColor = _SpecColor.rgb * SAMPLE_TEXTURE2D(_SheenMap, sampler_SheenMap, baseUV);
#endif

    outSurfaceData.thickness = _Thickness;
#ifdef _THICKNESSMAP
    outSurfaceData.thickness = _ThicknessRemap.x + SAMPLE_TEXTURE2D(_ThicknessMap, sampler_ThicknessMap, baseUV).r * (_ThicknessRemap.y - _ThicknessRemap.x);
#endif
    outSurfaceData.translucencyColor = _TranslucencyColor.rgb;
    outSurfaceData.translucencyScale = _TranslucencyScale;
    outSurfaceData.translucencyPower = 100.0h * _TranslucencyPower;
    outSurfaceData.translucencyAmbient = _TranslucencyAmbient;
    outSurfaceData.translucencyDistortion = _TranslucencyDistortion;
    outSurfaceData.translucencyShadows = _TranslucencyShadows;

#ifdef _THREADMAP
    half4 thread = SAMPLE_TEXTURE2D(_ThreadMap, sampler_ThreadMap, threadUV);
    half3 threadNormal = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(thread.g, thread.a, 1.0h, 1.0h))), _ThreadNormalScale);
    half threadAO = aoValue * lerp(1.0h, thread.r, _ThreadAOScale);
    outSurfaceData.albedo *= threadAO;
    outSurfaceData.alpha = Alpha(albedoAlpha.a * threadAO, _BaseColor, _Cutoff);
    outSurfaceData.occlusion = threadAO;
    outSurfaceData.normalTS = BlendNormalRNM(normalMap, normalize(threadNormal));

    smoothnessValue = saturate(smoothnessValue + lerp(0.0h, (-1.0h + thread.b * 2.0h), _ThreadSmoothnessScale));
    outSurfaceData.smoothness = smoothnessValue;
    outSurfaceData.sheenSmoothness = smoothnessValue;
#endif

    outSurfaceData.clearCoatMask = 0.0;
    outSurfaceData.clearCoatSmoothness = 1.0;
}
#endif