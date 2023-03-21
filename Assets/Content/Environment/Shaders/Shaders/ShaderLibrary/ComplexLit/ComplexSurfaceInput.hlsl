#ifndef UNIVERSAL_INPUT_SURFACE_INCLUDED
#define UNIVERSAL_INPUT_SURFACE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ComplexSurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

TEXTURE2D(_BaseMap);                    SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;              float4 _BaseMap_MipInfo;
TEXTURE2D(_MaskMap);                    SAMPLER(sampler_MaskMap);
TEXTURE2D(_SpecularColorMap);           SAMPLER(sampler_SpecularColorMap);
TEXTURE2D(_BumpMap);                    SAMPLER(sampler_BumpMap);
TEXTURE2D(_BentNormalMap);              SAMPLER(sampler_BentNormalMap);
TEXTURE2D(_HeightMap);                  SAMPLER(sampler_HeightMap);
TEXTURE2D(_TangentMap);                 SAMPLER(sampler_TangentMap);
TEXTURE2D(_AnisotropyMap);              SAMPLER(sampler_AnisotropyMap);
TEXTURE2D(_ThicknessCurvatureMap);      SAMPLER(sampler_ThicknessCurvatureMap);
TEXTURE2D(_IridescenceMaskMap);         SAMPLER(sampler_IridescenceMaskMap);
TEXTURE2D(_IridescenceThicknessMap);    SAMPLER(sampler_IridescenceThicknessMap);
TEXTURE2D(_ClearCoatMap);               SAMPLER(sampler_ClearCoatMap);
TEXTURE2D(_CoatNormalMap);              SAMPLER(sampler_CoatNormalMap);
TEXTURE2D(_DetailMap);                  SAMPLER(sampler_DetailMap);
TEXTURE2D(_EmissionMap);                SAMPLER(sampler_EmissionMap);

///////////////////////////////////////////////////////////////////////////////
//                      Material Property Helpers                            //
///////////////////////////////////////////////////////////////////////////////
half Alpha(half albedoAlpha, half4 color, half cutoff)
{
    half alpha = albedoAlpha * color.a;

#if defined(_ALPHATEST_ON)
    clip(alpha - cutoff);
#endif

    return alpha;
}

half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
{
    return SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv);
}

half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
#ifdef _NORMALMAP
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    #if BUMP_SCALE_NOT_SUPPORTED
        return UnpackNormal(n);
    #else
        return UnpackNormalScale(n, scale);
    #endif
#else
    return half3(0.0h, 0.0h, 1.0h);
#endif
}

half3 SampleBentNormal(float2 uv, TEXTURE2D_PARAM(bentNormalMap, sampler_bentNormalMap), half scale = 1.0h)
{
#ifdef _BENTNORMALMAP
    half4 n = SAMPLE_TEXTURE2D(bentNormalMap, sampler_bentNormalMap, uv);
    #if BUMP_SCALE_NOT_SUPPORTED
        return UnpackNormal(n);
    #else
        return UnpackNormalScale(n, scale);
    #endif
#else
    return half3(0.0h, 0.0h, 1.0h);
#endif
}

half3 BumpStrength(half3 In, half Strength)
{
    return half3(In.rg * Strength, lerp(1.0h, In.b, saturate(Strength)));
}

//Calculate DetailAlbedo
half3 DetailAlbedo(half3 baseColor, half detailBaseColor, half detailMask, half detailScale)
{
    half albedoDetailSpeed = saturate(abs(detailBaseColor) * detailScale);
    half3 baseColorOverlay = lerp(sqrt(baseColor), (detailBaseColor < 0.0h) ? half3(0.0h, 0.0h, 0.0h) : half3(1.0h, 1.0h, 1.0h), albedoDetailSpeed * albedoDetailSpeed);
    baseColorOverlay *= baseColorOverlay;

    return lerp(baseColor, saturate(baseColorOverlay), detailMask);
}

//Calculate DetailNormal
half3 DetailNormal(half3 normalTS, half3 normalDetail, half detailMask)
{
    return lerp(normalTS, BlendNormalRNM(normalTS, normalize(normalDetail)), detailMask);
}

//Calculate DetailSmoothness
half DetailSmoothness(half smoothness, half detailSmoothness, half detailSmoothnessScale, half detailMask)
{
    detailSmoothness = detailSmoothness * 2.0h - 1.0h;
    half smoothnessDetailSpeed = saturate(abs(detailSmoothness) * detailSmoothnessScale);
    half smoothnessOverlay = lerp(smoothness, (detailSmoothness < 0.0h) ? 0.0h : 1.0h, smoothnessDetailSpeed);

    return lerp(smoothness, saturate(smoothnessOverlay), detailMask);
}

half3 SampleEmission(float2 uv, half3 emissionColor, TEXTURE2D_PARAM(emissionMap, sampler_emissionMap))
{
#ifndef _EMISSION
    return 0;
#else
    return SAMPLE_TEXTURE2D(emissionMap, sampler_emissionMap, uv).rgb * emissionColor;
#endif
}
#endif
