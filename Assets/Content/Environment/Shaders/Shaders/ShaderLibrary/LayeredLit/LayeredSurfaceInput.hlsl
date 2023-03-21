#ifndef UNIVERSAL_INPUT_SURFACE_INCLUDED
#define UNIVERSAL_INPUT_SURFACE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "LayeredSurfaceData.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

TEXTURE2D(_BaseMap);                    SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;              float4 _BaseMap_MipInfo;
TEXTURE2D(_BaseMap1);
TEXTURE2D(_BaseMap2);
TEXTURE2D(_BaseMap3);

TEXTURE2D(_MaskMap);                    SAMPLER(sampler_MaskMap);
TEXTURE2D(_MaskMap1);                   SAMPLER(sampler_MaskMap1);
TEXTURE2D(_MaskMap2);                   SAMPLER(sampler_MaskMap2);
TEXTURE2D(_MaskMap3);                   SAMPLER(sampler_MaskMap3);

#if defined(_NORMALMAP)
TEXTURE2D(_NormalMap);                  SAMPLER(sampler_NormalMap);
TEXTURE2D(_BentNormalMap);
#endif
#if defined(_NORMALMAP1)
TEXTURE2D(_NormalMap1);                 SAMPLER(sampler_NormalMap1);
TEXTURE2D(_BentNormalMap1);
#endif
#if defined(_NORMALMAP2)
TEXTURE2D(_NormalMap2);                 SAMPLER(sampler_NormalMap2);
TEXTURE2D(_BentNormalMap2);
#endif
#if defined(_NORMALMAP3)
TEXTURE2D(_NormalMap3);                 SAMPLER(sampler_NormalMap3);
TEXTURE2D(_BentNormalMap3);
#endif

TEXTURE2D(_HeightMap);                  SAMPLER(sampler_HeightMap);
TEXTURE2D(_HeightMap1);
TEXTURE2D(_HeightMap2);
TEXTURE2D(_HeightMap3);

TEXTURE2D(_DetailMap);                  SAMPLER(sampler_DetailMap);
TEXTURE2D(_DetailMap1);                 SAMPLER(sampler_DetailMap1);
TEXTURE2D(_DetailMap2);                 SAMPLER(sampler_DetailMap2);
TEXTURE2D(_DetailMap3);                 SAMPLER(sampler_DetailMap3);

TEXTURE2D(_LayerMaskMap);               SAMPLER(sampler_LayerMaskMap);
TEXTURE2D(_LayerInfluenceMaskMap);      SAMPLER(sampler_LayerInfluenceMaskMap);

TEXTURE2D(_EmissionMap);                SAMPLER(sampler_EmissionMap);

///////////////////////////////////////////////////////////////////////////////
//                      Material Property Helpers                            //
///////////////////////////////////////////////////////////////////////////////
struct LayerTexCoord
{
    real2 layerMaskUV;
    real2 baseUV0;
    real2 baseUV1;
    real2 baseUV2;
    real2 baseUV3;

    real2 detailUV0;
    real2 detailUV1;
    real2 detailUV2;
    real2 detailUV3;

    real2 emissionUV;
};

struct LayeredData
{
    half4 baseColor0;
    half4 baseColor1;
    half4 baseColor2;
    half4 baseColor3;

    half4 maskMap0;
    half4 maskMap1;
    half4 maskMap2;
    half4 maskMap3;

    half3 normalMap0;
    half3 normalMap1;
    half3 normalMap2;
    half3 normalMap3;

    half3 bentNormalMap0;
    half3 bentNormalMap1;
    half3 bentNormalMap2;
    half3 bentNormalMap3;
    
    half heightMap0;
    half heightMap1;
    half heightMap2;
    half heightMap3;
};

half LayeredAlpha(half alpha, half cutoff)
{
#if defined(_ALPHATEST_ON)
    clip(alpha - cutoff);
#endif

    return alpha;
}

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
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    #if BUMP_SCALE_NOT_SUPPORTED
        return UnpackNormal(n);
    #else
        return UnpackNormalScale(n, scale);
    #endif
}

half3 BumpStrength(half3 In, half Strength)
{
    return half3(In.rg * Strength, lerp(1.0h, In.b, saturate(Strength)));
}

half4 LayeredMaskMapping(Texture2D MaskMap, SamplerState Sampler, real2 UV, half2 metallicRemap, half2 aoRemap, half2 smoothnessRemap)
{
    half4 maskUnpack = SAMPLE_TEXTURE2D(MaskMap, Sampler, UV);
    
    maskUnpack.r = metallicRemap.x + maskUnpack.r * (metallicRemap.y - metallicRemap.x);
    maskUnpack.g = aoRemap.x + maskUnpack.g * (aoRemap.y - aoRemap.x);
    maskUnpack.a = smoothnessRemap.x + maskUnpack.a * (smoothnessRemap.y - smoothnessRemap.x);

    return half4(maskUnpack.r, maskUnpack.g, maskUnpack.b, maskUnpack.a);
}

half3 DetailAlbedo(half3 baseColor, half detailBaseColor, half detailMask, half detailScale)
{
    half albedoDetailSpeed = saturate(abs(detailBaseColor) * detailScale);
    half3 baseColorOverlay = lerp(sqrt(baseColor), (detailBaseColor < 0.0h) ? half3(0.0h, 0.0h, 0.0h) : half3(1.0h, 1.0h, 1.0h), albedoDetailSpeed * albedoDetailSpeed);
    baseColorOverlay *= baseColorOverlay;

    return lerp(baseColor, saturate(baseColorOverlay), detailMask);
}

half3 DetailNormals(half3 normals, half3 detailNormals, half detailMask)
{
    return lerp(normals, BlendNormalRNM(normals, normalize(detailNormals)), detailMask);
}

half DetailSmoothness(half smoothness, half detailSmoothness, half detailSmoothnessScale, half detailMask)
{
    detailSmoothness = detailSmoothness * 2.0h - 1.0h;
    half smoothnessDetailSpeed = saturate(abs(detailSmoothness) * detailSmoothnessScale);
    half smoothnessOverlay = lerp(smoothness, (detailSmoothness < 0.0h) ? 0.0h : 1.0h, smoothnessDetailSpeed);

    return lerp(smoothness, saturate(smoothnessOverlay), detailMask);
}

half HeightAmplitude(half height, half heightCenter, half heightAmplitude)
{
    return (height - heightCenter) * heightAmplitude;
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
