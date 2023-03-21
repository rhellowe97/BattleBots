#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
/***********Mask Mapping**********/
void MaskMapping_half(Texture2D maskMap, SamplerState sampler_MaskMap, real2 uv,
half metallicMin, half metallicMax, 
half smoothnessMin, half smoothnessMax,
half aoMin, half aoMax,
out half metallic, 
out half ambientOcclusion, 
out half detailMask, 
out half smoothness)
{
    half4 maskMapUnpack = SAMPLE_TEXTURE2D(maskMap, sampler_MaskMap, uv);
    metallic = metallicMin + maskMapUnpack.r * (metallicMax - metallicMin);
    ambientOcclusion = aoMin + maskMapUnpack.g * (aoMax - aoMin);
    detailMask = maskMapUnpack.b;
    smoothness = smoothnessMin + maskMapUnpack.a * (smoothnessMax - smoothnessMin);
}

/**********Detail Mapping*********/
//Calculate DetailAlbedo
half3 DetailAlbedo(half3 albedo, half detailAlbedo, half detailMask, half detailAlbedoScale)
{
    half albedoDetailSpeed = saturate(abs(detailAlbedo) * detailAlbedoScale);
    half3 baseColorOverlay = lerp(sqrt(albedo), (detailAlbedo < 0.0h) ? half3(0.0h, 0.0h, 0.0h) : half3(1.0h, 1.0h, 1.0h), albedoDetailSpeed * albedoDetailSpeed);
    baseColorOverlay *= baseColorOverlay;
    return lerp(albedo, saturate(baseColorOverlay), detailMask);
}

//Calculate DetailNormal
half3 DetailNormal(half3 normalTS, half3 normalDetailTS, half detailMask)
{
    return lerp(normalTS, BlendNormalRNM(normalTS, normalize(normalDetailTS)), detailMask);
}

//Calculate DetailSmoothness
half DetailSmoothness(half smoothness, half detailSmoothness, half detailSmoothnessScale, half detailMask)
{
    detailSmoothness = detailSmoothness * 2.0h - 1.0h;
    half smoothnessDetailSpeed = saturate(abs(detailSmoothness) * detailSmoothnessScale);
    half smoothnessOverlay = lerp(smoothness, (detailSmoothness < 0.0h) ? 0.0h : 1.0h, smoothnessDetailSpeed);
    return lerp(smoothness, saturate(smoothnessOverlay), detailMask);
}

half3 BumpStrength(half3 In, half Strength)
{
    return half3(In.rg * Strength, lerp(1.0h, In.b, saturate(Strength)));
}

void DetailMapping_half(Texture2D detailMap, SamplerState sampler_Detail, real2 uv,
half3 albedoIn, half3 normalIn, half smoothnessIn,
half detailAlbedoScale, half detailNormalScale, half detailSmoothnessScale, half detailMask,
out half3 albedo,
out half3 normal,
out half smoothness)
{
    half4   detail = SAMPLE_TEXTURE2D(detailMap, sampler_Detail, uv);
    half3   detailNormal = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detail.g, detail.a, 1.0h, 1.0h))), detailNormalScale);

    albedo = DetailAlbedo(albedoIn, detail.r, detailMask, detailAlbedoScale);
    normal = DetailNormal(normalIn, detailNormal, detailMask);
    smoothness = DetailSmoothness(smoothnessIn, detail.b, detailSmoothnessScale, detailMask);
}

/**********Thread Mapping*********/
void ThreadMapping_half(Texture2D threadMap, SamplerState sampler_ThreadMap, real2 uv,
half3 normalIn, half smoothnessIn, half aoIn, half alphaIn,
half threadAOStrength, half threadNormalStrength, half threadSmoothnessStrength,
out half3 normal,
out half smoothness,
out half ambientOcclusion,
out half alpha)
{
    half4 thread = SAMPLE_TEXTURE2D(threadMap, sampler_ThreadMap, uv);
    half3 threadNormals = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(thread.g, thread.a, 1.0h, 1.0h))), threadNormalStrength);

    normal = BlendNormalRNM(normalIn, normalize(threadNormals));
    smoothness = saturate(smoothnessIn + lerp(0.0h, (-1.0h + thread.b * 2.0h), threadSmoothnessStrength));
    ambientOcclusion = aoIn * lerp(1.0h, thread.r, threadAOStrength);
    alpha = thread.r * alphaIn;
}