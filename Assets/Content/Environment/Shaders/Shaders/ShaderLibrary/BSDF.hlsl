#ifndef UNIVERSAL_BSDF_INCLUDED
#define UNIVERSAL_BSDF_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"

half _MicroShadowOpacity;

struct BSDFData
{
    half thickness;
    half curvature;

    half3 scatteringColor;
    half3 scatteringShadowsColor;
    half transmissionScale;

    half translucencyPower;
    half translucencyScale;
    half translucencyAmbient;
    half translucencyDistortion;
    half translucencyShadows;

    half anisotropy;
    half3 iridescence;
    half clearCoatMask;
};

inline void InitializeBSDFData(inout BSDFData bsdfData, SurfaceData surfaceData, half3 iridescence)
{
    bsdfData.thickness = 1.0h;
    bsdfData.scatteringColor = 0.0h;
    bsdfData.scatteringShadowsColor = 0.0h;
    bsdfData.transmissionScale = 0.0h;
    bsdfData.curvature = 0.0h;
    bsdfData.translucencyPower = 0.0h;
    bsdfData.translucencyScale = 0.0h;
    bsdfData.translucencyAmbient = 0.0h;
    bsdfData.translucencyDistortion = 0.0h;
    bsdfData.translucencyShadows = 0.0h;
    bsdfData.anisotropy = 0.0h;
    bsdfData.iridescence = 0.0h;
    bsdfData.clearCoatMask = 0.0h;

#if (defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && defined(_MATERIAL_FEATURE_TRANSMISSION)) || defined(_MATERIAL_FEATURE_TRANSLUCENCY)
    bsdfData.thickness = surfaceData.thickness;
#endif

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING)
    bsdfData.scatteringColor        = surfaceData.scatteringColor;
    bsdfData.scatteringShadowsColor = surfaceData.scatteringShadowsColor;
    bsdfData.transmissionScale      = surfaceData.transmissionScale;
    bsdfData.curvature              = surfaceData.curvature;
#endif

#if defined(_MATERIAL_FEATURE_TRANSLUCENCY)
    bsdfData.scatteringColor        = surfaceData.scatteringColor;
    bsdfData.translucencyPower      = surfaceData.translucencyPower;
    bsdfData.translucencyScale      = surfaceData.translucencyScale;
    bsdfData.translucencyAmbient    = surfaceData.translucencyAmbient;
    bsdfData.translucencyDistortion = surfaceData.translucencyDistortion;
    bsdfData.translucencyShadows    = surfaceData.translucencyShadows;
#endif

#if defined(_MATERIAL_FEATURE_ANISOTROPY)
    bsdfData.anisotropy = surfaceData.anisotropy;
#endif

#if defined(_MATERIAL_FEATURE_IRIDESCENCE)
    bsdfData.iridescence = iridescence;
#endif

#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    bsdfData.clearCoatMask = surfaceData.clearCoatMask;
#endif
}

///////////////////////////////////////////
/**********SubSurface Scattering**********/
///////////////////////////////////////////
#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING)
//ref: https://therealmjp.github.io/posts/sss-sg/
struct SG
{
    real3 Amplitude;
    real3 Axis;
    real Sharpness;
};

half3 ApproximateSGIntegral(in SG sg)
{
    return 2 * PI * (sg.Amplitude / sg.Sharpness);
}

half3 SGIrradianceFitted(in SG lightingLobe, in half3 normal)
{
    const half muDotN = dot(lightingLobe.Axis, normal);
    const half lambda = lightingLobe.Sharpness;

    const half c0 = 0.36f;
    const half c1 = 1.0f / (4.0f * c0);

    half eml  = exp(-lambda);
    half em2l = eml * eml;
    half rl   = rcp(lambda);

    half scale = 1.0f + 2.0f * em2l - rl;
    half bias  = (eml - em2l) * rl - em2l;

    half x  = sqrt(1.0f - scale);
    half x0 = c0 * muDotN;
    half x1 = c1 * x;

    half n = x0 + x1;

    half y = (abs(x0) <= x1) ? n * n / x : saturate(muDotN);

    half normalizedIrradiance = scale * y + bias;

    return normalizedIrradiance * ApproximateSGIntegral(lightingLobe);
}

SG MakeNormalizedSG(in half3 axis, in half sharpness)
{
    SG sg;
    sg.Axis = axis;
    sg.Sharpness = sharpness;
    sg.Amplitude = 1.0f;
    sg.Amplitude = rcp(ApproximateSGIntegral(sg));

    return sg;
}

TEXTURE2D(_SSSLUT);             SAMPLER(sampler_SSSLUT);
half3 SubSurfaceScattering(BRDFData brdfData, BSDFData bsdfData, Light light, half3 normalWS)
{
#if !defined(_SHADER_QUALITY_PREINTEGRATED_SSS)
    // Represent the diffusion profiles as spherical gaussians
    SG redKernel = MakeNormalizedSG(light.direction, 1.0f / max(bsdfData.curvature * bsdfData.scatteringColor.x, 0.0001f));
    SG greenKernel = MakeNormalizedSG(light.direction, 1.0f / max(bsdfData.curvature * bsdfData.scatteringColor.y, 0.0001f));
    SG blueKernel = MakeNormalizedSG(light.direction, 1.0f / max(bsdfData.curvature * bsdfData.scatteringColor.z, 0.0001f));

    // Compute the irradiance that would result from convolving a punctual light source
    // with the SG filtering kernels
    half3 diffuse = half3(SGIrradianceFitted(redKernel, normalWS).x,
                     SGIrradianceFitted(greenKernel, normalWS).x,
                     SGIrradianceFitted(blueKernel, normalWS).x);
#else
    real NdotL = dot(normalWS, light.direction);
    #ifdef _SSS_LUT
    half3 diffuse = SAMPLE_TEXTURE2D(_SSSLUT, sampler_SSSLUT, real2(NdotL * 0.5 + 0.5, bsdfData.curvature)).rgb;
    #else
    half3 diffuse = saturate(NdotL);
    #endif
#endif

    return diffuse;
}

half3 Transmission(Light light, half3 normalWS, half3 subsurfaceColor, half thickness, half scale)
{
    half NdotL = max(0, -dot(light.direction, normalWS));
    half backLight = NdotL * (1.0h - thickness); 
    half3 result = backLight * light.color * scale * subsurfaceColor; 
    return result;
}
#endif

//////////////////////////////////////////
/**************Translucency**************/
//////////////////////////////////////////
//ref: https://colinbarrebrisebois.com/2012/04/09/approximating-translucency-revisited-with-simplified-spherical-gaussian/
//ref: https://github.com/google/filament/blob/24b88219fa6148b8004f230b377f163e6f184d65/shaders/src/shading_model_subsurface.fs
half3 Translucency(BSDFData bsdfData, Light light, half3 diffuse, half3 normalWS, half3 viewDirWS)
{
    half invThickness = (1.0 - bsdfData.thickness);
    half lightAttenuation = light.distanceAttenuation * lerp(1.0, light.shadowAttenuation, bsdfData.translucencyShadows);
    half NdotL = saturate(dot(normalWS, light.direction));
    half3 translucencyAttenuation = bsdfData.scatteringColor * light.color * lightAttenuation;
    real3 H = normalize(-light.direction + normalWS * bsdfData.translucencyDistortion);
    real VdotH = saturate(dot(viewDirWS, H));
    half forwardScatter = exp2(VdotH * bsdfData.translucencyPower - bsdfData.translucencyPower) * bsdfData.translucencyScale;
    half backScatter = saturate(NdotL * bsdfData.thickness + invThickness) * 0.5;
    half subsurface = lerp(backScatter, 1.0, forwardScatter) * invThickness;
    half3 fLT = translucencyAttenuation * (subsurface  * 0.3183h + bsdfData.translucencyAmbient);
    half3 cLT = diffuse * fLT; 
    return cLT * invThickness;
}

/////////////////////////////////////////
/**************Iridescence**************/
/////////////////////////////////////////
TEXTURE2D(_IridescenceLUT);             SAMPLER(sampler_IridescenceLUT);
real3 CalculateIridescence(half eta_1, half cosTheta1, half2 iridescenceTS, real3 specular)
{
    real3 I = half3(1.0, 1.0, 1.0);
    #if defined(_SHADER_QUALITY_IRIDESCENCE_APPROXIMATION)
    real eta_2 = 2.0 - iridescenceTS.x;
    real sinTheta2Sq = Sq(eta_1 / eta_2) * (1.0 - Sq(cosTheta1));
    real cosTheta2Sq = (1.0 - sinTheta2Sq);
    real cosTheta2 = sqrt(cosTheta2Sq);
    real k = iridescenceTS.y + (cosTheta2 * (PI * iridescenceTS.x));
    real R0 = IorToFresnel0(eta_2, eta_1);
    real R12 = saturate(sqrt(F_Schlick(R0, cosTheta1)));

    real3 iridescenceColor = lerp(2.0 * SAMPLE_TEXTURE2D(_IridescenceLUT, sampler_IridescenceLUT, float2(k * 1.5, 1.0)).rgb - 0.2, R12, R12); //just because :)

    I = lerp(specular, iridescenceColor, R12);
    #else
    I = EvalIridescence(eta_1, cosTheta1, iridescenceTS.x, specular);
    #endif

    return I;
}

#define CLEAR_COAT_IOR 1.5
real3 IridescenceSpecular(real3 normalWS, real3 viewDirectionWS, real3 specular, half3 iridescenceTMS, half clearCoatMask)
{
    real NdotV = dot(normalWS, viewDirectionWS);
    real clampedNdotV = ClampNdotV(NdotV);
    real viewAngle = clampedNdotV;
    half topIor = 1.0;
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        topIor = lerp(1.0, CLEAR_COAT_IOR, clearCoatMask);
        viewAngle = sqrt(1.0 + Sq(1.0 / topIor) * (Sq(dot(normalWS, viewDirectionWS)) - 1.0));
    #endif
    if (iridescenceTMS.y > 0.0)
    {
        specular = lerp(specular, CalculateIridescence(topIor, viewAngle, iridescenceTMS.xz, specular), iridescenceTMS.y);
    }
    #if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
        specular = lerp(specular, ConvertF0ForClearCoat15(specular), clearCoatMask);
    #endif
    
    return specular;
}

////////////////////////////////////////
/**************Anisotropy**************/
////////////////////////////////////////
real3 DV_Anisotropy(real perceptualRoughness, real anisotropy, real3 lightDirWS, real3 viewDirWS, real4 tangentWS, real3 bitangentWS, real3 normalWS)
{
    real3 H = SafeNormalize(lightDirWS + viewDirWS);
    real NdotL = dot(normalWS, lightDirWS);
    real NdotV = saturate(dot(normalWS, viewDirWS));
    real NdotH = saturate(dot(normalWS, H));
    real LdotH = dot(lightDirWS, H);
    //Anisotropy to Roughness
    real roughnessT;
    real roughnessB;
    ConvertAnisotropyToRoughness(perceptualRoughness, anisotropy, roughnessT, roughnessB);
    roughnessT = max(0.001, roughnessT);
    roughnessB = max(0.001, roughnessB);
    real TdotH = dot(tangentWS.xyz, H);
    real TdotL = dot(tangentWS.xyz, lightDirWS);
    real TdotV = dot(tangentWS.xyz, viewDirWS);
    real BdotH = dot(bitangentWS, H);
    real BdotL = dot(bitangentWS, lightDirWS);
    real BdotV = dot(bitangentWS, viewDirWS);

    real partLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, NdotV, roughnessT, roughnessB);
    real DV = DV_SmithJointGGXAniso(TdotH, BdotH, NdotH, NdotV, TdotL, BdotL, abs(NdotL), roughnessT, roughnessB, partLambdaV);
    return saturate(DV);
}

half3 ComputeRadiance(BRDFData brdfData, VectorsData vectorsData, Light light, half occlusion)
{
    half NdotL = saturate(dot(vectorsData.normalWS, light.direction));
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
#ifdef _SHADER_QUALITY_MICRO_SHADOWS
    lightAttenuation *= NdotL >= 0.0h ? ComputeMicroShadowing(occlusion, dot(vectorsData.normalWS, light.direction), _MicroShadowOpacity) : 1.0;
#endif

    half3 radiance = light.color * (lightAttenuation * NdotL);
    return radiance;
}

half3 ComputeComplexRadiance(BRDFData brdfData, BSDFData bsdfData, VectorsData vectorsData, Light light, half occlusion)
{
#if !defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING)
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    half NdotL = saturate(dot(vectorsData.normalWS, light.direction));
#else
    //SSS shadows
    #if defined(_MATERIAL_FEATURE_FAKE_SSS_SHADOWS)
    bsdfData.scatteringShadowsColor = min(bsdfData.scatteringShadowsColor, 0.45h);
    half3 scatteredShadows = saturate(pow(abs(light.shadowAttenuation), (1.0h - bsdfData.scatteringShadowsColor)));
    half3 lightAttenuation = light.distanceAttenuation * scatteredShadows;
    #else
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    #endif

    half3 NdotL = SubSurfaceScattering(brdfData, bsdfData, light, vectorsData.normalWS);
    #if defined(_MATERIAL_FEATURE_TRANSMISSION)
        NdotL += Transmission(light, vectorsData.normalWS, bsdfData.scatteringColor, bsdfData.thickness, bsdfData.transmissionScale);
    #endif
#endif

#ifdef _SHADER_QUALITY_MICRO_SHADOWS
    half microShadows = ComputeMicroShadowing(occlusion, dot(vectorsData.normalWS, light.direction), _MicroShadowOpacity);
    #if !defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING)
        lightAttenuation *= NdotL >= 0.0h ? microShadows : 1.0;
    #else
        lightAttenuation *= NdotL.g >= 0.0h ? microShadows : 1.0;
    #endif
#endif

    half3 radiance = light.color * (lightAttenuation * NdotL);
    return radiance;
}
#endif