#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "ShaderLibrary/Fabric/FabricBRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

#if defined(LIGHTMAP_ON)
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
    #define OUTPUT_SH(normalWS, OUT)
#else
    #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
    #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
    #define OUTPUT_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
#endif

struct LightingData
{
    half3 giColor;
    half3 mainLightColor;
    half3 additionalLightsColor;
    half3 vertexLightingColor;
    half3 emissionColor;
};

half3 CalculateLightingColor(LightingData lightingData, half3 albedo)
{
    half3 lightingColor = 0;

    if (IsOnlyAOLightingFeatureEnabled())
    {
        return lightingData.giColor; // Contains white + AO
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
    {
        lightingColor += lightingData.giColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
    {
        lightingColor += lightingData.mainLightColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
    {
        lightingColor += lightingData.additionalLightsColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_VERTEX_LIGHTING))
    {
        lightingColor += lightingData.vertexLightingColor;
    }

    lightingColor *= albedo;

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_EMISSION))
    {
        lightingColor += lightingData.emissionColor;
    }

    return lightingColor;
}

half4 CalculateFinalColor(LightingData lightingData, half alpha)
{
    half3 finalColor = CalculateLightingColor(lightingData, 1);

    return half4(finalColor, alpha);
}

half4 CalculateFinalColor(LightingData lightingData, half3 albedo, half alpha, float fogCoord)
{
    #if defined(_FOG_FRAGMENT)
        #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
        float viewZ = -fogCoord;
        float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
        half fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
    #else
        half fogFactor = 0;
        #endif
    #else
    half fogFactor = fogCoord;
    #endif
    half3 lightingColor = CalculateLightingColor(lightingData, albedo);
    half3 finalColor = MixFog(lightingColor, fogFactor);

    return half4(finalColor, alpha);
}

LightingData CreateLightingData(InputData inputData, SurfaceData surfaceData)
{
    LightingData lightingData;

    lightingData.giColor = inputData.bakedGI;
    lightingData.emissionColor = surfaceData.emission;
    lightingData.vertexLightingColor = 0;
    lightingData.mainLightColor = 0;
    lightingData.additionalLightsColor = 0;

    return lightingData;
}

half3 CharlieDV(half sheenSmoothness, half3 sheenColor, half3 viewDirWS, half3 lightDirWS, half3 normalWS)
{
    half LdotV, NdotH, LdotH, invLenLV;

    half NdotL = saturate(dot(normalWS, lightDirWS));
    half NdotV = saturate(dot(normalWS, viewDirWS));
    half clampedNdotV = ClampNdotV(NdotV);

    GetBSDFAngle(viewDirWS, lightDirWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

    half smoothness = lerp(0.0h, 0.5h, sheenSmoothness);
    half perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
    half roughness = max(PerceptualRoughnessToRoughness(perceptualRoughness), HALF_MIN_SQRT);

    half D = D_CharlieNoPI(NdotH, roughness);
    half V = V_Ashikhmin(NdotL, clampedNdotV);
    half3 F = F_Schlick(sheenColor, LdotH);

    half3 Fr = saturate(V * D) * F;
    
    return Fr;
}

//////////////////////////
/***My old Sheen model***/
//////////////////////////
/*half3 SheenVD(half NoH, half smoothness)
{
    half sheenPowCoef = lerp(0.75h, 2.0h, smoothness);
    half invValue = lerp(0.25h, 0.9h, smoothness);
    half sheen = saturate(0.9h * pow((1.0h - NoH), sheenPowCoef) * invValue);

	return sheen * PI;
}*/
/////////////////////////////////
/***My Sheen model(Optimized)***/
/////////////////////////////////
half3 SheenVD(half NoH, half smoothness)
{
    half sheen = saturate((0.22h + 0.585h * smoothness) * pow(1.0h - NoH, 0.75h + 1.25h * smoothness));

	return sheen * PI;
}

/***********Anisotropy***********/
half3 Anisotropic(BRDFData brdfData, half3 lightDirWS, real3 viewDirWS, real4 tangentWS, real3 bitangentWS, real3 normalWS, half anisotropy)
{
    float3 H = SafeNormalize(lightDirWS + viewDirWS);
    half NdotL = saturate(dot(normalWS, lightDirWS));
    half NdotV = saturate(dot(normalWS, viewDirWS));
    half clampedNdotV = ClampNdotV(dot(normalWS, viewDirWS));
    half NdotH = saturate(dot(normalWS, H));
    half LdotH = saturate(dot(lightDirWS, H));

    //Anisotropy to Roughness
    half roughnessT;
    half roughnessB;

    //half perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);

    ConvertAnisotropyToRoughness(brdfData.perceptualRoughness, anisotropy, roughnessT, roughnessB);

    roughnessT = max(0.001, roughnessT);
    roughnessB = max(0.001, roughnessB);

    half TdotH = dot(tangentWS.xyz, H);
    half TdotL = dot(tangentWS.xyz, lightDirWS);
    half TdotV = dot(tangentWS.xyz, viewDirWS);

    half BdotH = dot(bitangentWS, H);
    half BdotL = dot(bitangentWS, lightDirWS);
    half BdotV = dot(bitangentWS, viewDirWS);

    real partLambdaV = GetSmithJointGGXAnisoPartLambdaV(TdotV, BdotV, NdotV, roughnessT, roughnessB);
    float DV = DV_SmithJointGGXAniso(TdotH, BdotH, NdotH, clampedNdotV, TdotL, BdotL, abs(NdotL), roughnessT, roughnessB, partLambdaV);
    float3 F = F_Schlick(brdfData.specular, LdotH);

    return DV * F * PI;
}

// Computes the scalar specular term for Minimalist CookTorrance BRDF
// NOTE: needs to be multiplied with reflectance f0, i.e. specular color to complete
half3 DirectBRDFSpecular(BRDFData brdfData, half3 sheenColor, half sheenSmoothness, half anisotropy, half3 normalWS, half4 tangentWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
#ifdef _MATERIAL_FEATURE_SHEEN
    #ifdef _SHADER_QUALITY_SHEEN_PHYSICAL_BASED
        half3 specularFabric = CharlieDV(sheenSmoothness, brdfData.specular, viewDirectionWS, lightDirectionWS, normalWS);
    #else
        float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
        float NoH = saturate(dot(normalWS, halfDir));
        half LoH = saturate(dot(lightDirectionWS, halfDir));
        half3 F = F_Schlick(brdfData.specular, LoH);

        half3 specularFabric = SheenVD(NoH, sheenSmoothness) * F;
    #endif
#else
    //real3 bitangentWS = tangentWS.w * cross(normalWS, tangentWS.xyz);
    half3 specularFabric = Anisotropic(brdfData, lightDirectionWS, viewDirectionWS, tangentWS, cross(normalWS, tangentWS.xyz), normalWS, anisotropy);
#endif

    return specularFabric;
}

// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF [Modified] GGX
// * Modified Kelemen and Szirmay-Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half3 DirectBDRF(BRDFData brdfData, half3 sheenColor, half sheenSmoothness, half anisotropy, half3 normalWS, half4 tangentWS, half3 lightDirectionWS, half3 viewDirectionWS, bool specularHighlightsOff)
{
    // Can still do compile-time optimisation.
    // If no compile-time optimized, extra overhead if branch taken is around +2.5% on Switch, -10% if not taken.
    [branch] if (!specularHighlightsOff)
    {
        half3 specularTerm = DirectBRDFSpecular(brdfData, sheenColor, sheenSmoothness, anisotropy, normalWS, tangentWS, lightDirectionWS, viewDirectionWS);
        half3 color = brdfData.diffuse + specularTerm;
        return color;
    }
    else
        return brdfData.diffuse;
}

// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF [Modified] GGX
// * Modified Kelemen and Szirmay-Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half3 DirectBRDF(BRDFData brdfData, half3 sheenColor, half sheenSmoothness, half anisotropy, half3 normalWS, half4 tangentWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
#ifndef _SPECULARHIGHLIGHTS_OFF
    return brdfData.diffuse + DirectBRDFSpecular(brdfData, sheenColor, sheenSmoothness, anisotropy, normalWS, tangentWS, lightDirectionWS, viewDirectionWS);
#else
    return brdfData.diffuse;
#endif
}

half3 GlobalIllumination(BRDFData brdfData, half3 bakedGI, half4 tangentWS, half3 normalWS, half3 viewDirectionWS, half anisotropy, half occlusion)
{
#if defined(_MATERIAL_FEATURE_SHEEN)
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
#else
    half3 modifiedNormalWS = normalWS;
    half3 bitangentWS = tangentWS.w * cross(normalWS, tangentWS.xyz);
    GetGGXAnisotropicModifiedNormalAndRoughness(bitangentWS, tangentWS.xyz, normalWS, viewDirectionWS, anisotropy, brdfData.perceptualRoughness, modifiedNormalWS, brdfData.perceptualRoughness);
    half3 reflectVector = reflect(-viewDirectionWS, modifiedNormalWS);
#endif
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half fresnelTerm = Pow4(1.0 - NoV);

    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);

    half3 color = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);

    return color;
}

///////////////////////////////////////////////////////////////////////////////
//                      Lighting Functions                                   //
///////////////////////////////////////////////////////////////////////////////
half3 LightingLambert(half3 lightColor, half3 lightDir, half3 normal)
{
    half NdotL = saturate(dot(normal, lightDir));
    return lightColor * NdotL;
}

half3 LightingSpecular(half3 lightColor, half3 lightDir, half3 normal, half3 viewDir, half4 specular, half smoothness)
{
    float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
    half NdotH = saturate(dot(normal, halfVec));
    half modifier = pow(NdotH, smoothness);
    half3 specularReflection = specular.rgb * modifier;
    return lightColor * specularReflection;
}

struct BSDFData
{
    //Specular
    half3 sheenColor;
    half sheenSmoothness;
    half anisotropy;

    //Translucency
    half thickness;
    half3 translucencyColor;
    half translucencyPower;
    half translucencyScale;
    half translucencyAmbient;
    half translucencyDistortion;
    half translucencyShadows;
};

inline void InitializeBSDFData(inout BSDFData bsdfData, SurfaceData surfaceData)
{
    //Specular
    bsdfData.sheenColor = surfaceData.sheenColor;
    bsdfData.sheenSmoothness = surfaceData.sheenSmoothness;
    bsdfData.anisotropy = surfaceData.anisotropy;

    //Translucency
    bsdfData.thickness = 1.0 - surfaceData.thickness;
    bsdfData.translucencyColor = surfaceData.translucencyColor;
    bsdfData.translucencyPower = surfaceData.translucencyPower;
    bsdfData.translucencyScale = surfaceData.translucencyScale;
    bsdfData.translucencyAmbient = surfaceData.translucencyAmbient;
    bsdfData.translucencyDistortion = surfaceData.translucencyDistortion;
    bsdfData.translucencyShadows = surfaceData.translucencyShadows;
}

//ref: https://colinbarrebrisebois.com/2012/04/09/approximating-translucency-revisited-with-simplified-spherical-gaussian/
half3 Translucency(BSDFData bsdfData, Light light, half3 diffuse, half3 normalWS, half3 viewDirWS)
{
    half lightAttenuation = light.distanceAttenuation * lerp(1.0, light.shadowAttenuation, bsdfData.translucencyShadows);

    real3 H = normalize(-light.direction + normalWS * bsdfData.translucencyDistortion);
    half fLTDot = exp2(saturate(dot(viewDirWS, -H)) * bsdfData.translucencyPower - bsdfData.translucencyPower) * bsdfData.translucencyScale;
    half3 fLT = lightAttenuation * (fLTDot + bsdfData.translucencyAmbient) * bsdfData.thickness;
    half3 cLT = bsdfData.translucencyColor * light.color * fLT;

    return cLT;
}

half3 LightingPhysicallyBased(BRDFData brdfData, BSDFData bsdfData, Light light, half3 normalWS, half4 tangentWS, half3 viewDirectionWS, bool specularHighlightsOff)
{
    half NdotL = saturate(dot(normalWS, light.direction));
    half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
    half3 radiance = light.color * (lightAttenuation * NdotL);

    half3 brdf = brdfData.diffuse;
#ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        brdf += DirectBRDFSpecular(brdfData, bsdfData.sheenColor, bsdfData.sheenSmoothness, bsdfData.anisotropy, normalWS, tangentWS, light.direction, viewDirectionWS);
    }
#endif // _SPECULARHIGHLIGHTS_OFF

    return brdf * radiance;
}

half3 VertexLighting(float3 positionWS, half3 normalWS)
{
    half3 vertexLightColor = half3(0.0, 0.0, 0.0);

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    uint lightsCount = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(lightsCount)
        Light light = GetAdditionalLight(lightIndex, positionWS);
        half3 lightColor = light.color * light.distanceAttenuation;
        vertexLightColor += LightingLambert(lightColor, light.direction, normalWS);
    LIGHT_LOOP_END
#endif

    return vertexLightColor;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
//       Used by ShaderGraph and others builtin renderers                    //
///////////////////////////////////////////////////////////////////////////////
half4 FabricFragment(InputData inputData, SurfaceData surfaceData, real4 tangentWS)
{
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif

    BRDFData brdfData;
    BSDFData bsdfData;
    // NOTE: can modify alpha
    InitializeBRDFData(surfaceData.albedo, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
    InitializeBSDFData(bsdfData, surfaceData);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);

    lightingData.giColor = GlobalIllumination(brdfData, inputData.bakedGI, tangentWS, inputData.normalWS, inputData.viewDirectionWS, surfaceData.anisotropy, surfaceData.occlusion);
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor = LightingPhysicallyBased(brdfData, bsdfData, mainLight, inputData.normalWS, tangentWS, inputData.viewDirectionWS, specularHighlightsOff);
        #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
            lightingData.mainLightColor += Translucency(bsdfData, mainLight, brdfData.diffuse, inputData.viewDirectionWS, inputData.normalWS);
        #endif
    }

    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_CLUSTERED_LIGHTING
    for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, bsdfData, light, inputData.normalWS, tangentWS, inputData.viewDirectionWS, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
                lightingData.additionalLightsColor += Translucency(bsdfData, light, brdfData.diffuse, inputData.viewDirectionWS, inputData.normalWS);
            #endif
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, bsdfData, light, inputData.normalWS, tangentWS, inputData.viewDirectionWS, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
                lightingData.additionalLightsColor += Translucency(bsdfData, light, brdfData.diffuse, inputData.viewDirectionWS, inputData.normalWS);
            #endif
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}
#endif