#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

#include "ShaderLibrary/Hair/HairBRDF.hlsl"
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

struct HairData
{  
    real3 specularTint;
    real3 secondarySpecularTint;
    real specularShift;
    real secondarySpecularShift;
    real perceptualSmoothness; 
    real secondaryPerceptualSmoothness;
    real3 transmissionColor;
    real transmissionIntensity;
};

void InitializeHairData(SurfaceData surfaceData, out HairData hairData)
{
    hairData.specularTint = surfaceData.specularTint;
    hairData.secondarySpecularTint = surfaceData.secondarySpecularTint;
    hairData.specularShift = surfaceData.specularShift;
    hairData.secondarySpecularShift = surfaceData.secondarySpecularShift;
    hairData.perceptualSmoothness = surfaceData.perceptualSmoothness;
    hairData.secondaryPerceptualSmoothness = surfaceData.secondaryPerceptualSmoothness;
    hairData.transmissionColor = surfaceData.transmissionColor;
    hairData.transmissionIntensity = surfaceData.transmissionIntensity;
}

real RoughnessToBlinnPhongSpecularExponent(real roughness)
{
    return clamp(2 * rcp(roughness * roughness) - 2, FLT_EPS, rcp(FLT_EPS));
}

void HairSpecularWithSingleRoughness(BRDFData brdfData, HairData hairData, real3 normalWS, real3 geomNormalWS, real3 viewDirectionWS, real3 tangentWS, real3 lightDirectionWS, real NdotL, out real3 specR, out real3 specT)
{
    real NdotV = saturate(dot(geomNormalWS, viewDirectionWS));

    real LdotV, NdotH, LdotH, invLenLV;
    GetBSDFAngle(viewDirectionWS, lightDirectionWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);

    real3 t1 = ShiftTangent(tangentWS, normalWS, hairData.specularShift);
    real3 t2 = ShiftTangent(tangentWS, normalWS, hairData.secondarySpecularShift);

    real3 H = (lightDirectionWS + viewDirectionWS) * invLenLV;

    real perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(hairData.perceptualSmoothness);
    real roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    real specularExponent = RoughnessToBlinnPhongSpecularExponent(roughness);

    real3 hairSpec1 = hairData.specularTint * D_KajiyaKay(t1, H, specularExponent);
    real3 hairSpec2 = hairData.secondarySpecularTint * D_KajiyaKay(t2, H, specularExponent);

    //real3 F = F_Schlick(brdfData.specular, LdotH) * PI;
    //real3 f0 = 0.0466h + brdfData.diffuse; //0.16 * 0.54 * 0.54 = 0.046656
    real f0 = 0.5 + (perceptualRoughness + perceptualRoughness * LdotV);
    real3 F = F_Schlick(f0, LdotH) * INV_PI;

    // Yibing's and Morten's hybrid scatter model hack.
    real scatterFresnel1 = pow(saturate(-LdotV), 9.0) * pow(saturate(1.0 - NdotV * NdotV), 12.0) * hairData.transmissionIntensity;
    real scatterFresnel2 = saturate(PositivePow((1.0 - NdotV), 20.0));
    
    specR = 0.25h * F * (hairSpec1 + hairSpec2) * NdotL * saturate(NdotV * FLT_MAX);
    specT = hairData.transmissionColor * (scatterFresnel1 + hairData.transmissionIntensity * scatterFresnel2);
}

real3 HairLighting(BRDFData brdfData, HairData hairData, Light light, real3 normalWS, real3 geomNormalWS, real3 tangentWS, real3 viewDirectionWS, bool specularHighlightsOff)
{
    real3 lightAttenuation = light.color * light.distanceAttenuation * light.shadowAttenuation;
    real NdotL = saturate(dot(normalWS, light.direction));
    real3 radiance = NdotL * lightAttenuation;

    real3 brdf = brdfData.diffuse * radiance;
    real3 specularR, specularT;
#ifndef _SPECULARHIGHLIGHTS_OFF
    [branch] if (!specularHighlightsOff)
    {
        HairSpecularWithSingleRoughness(brdfData, hairData, normalWS, geomNormalWS, viewDirectionWS, tangentWS, light.direction, NdotL, specularR, specularT);
        brdf += saturate(specularR + specularT) * lightAttenuation;
    }
#endif // _SPECULARHIGHLIGHTS_OFF
    return brdf;
}

// Backwards compatibility
half3 HairLighting(BRDFData brdfData, HairData hairData, Light light, real3 normalWS, real3 geomNormalWS, real3 tangentWS, real3 viewDirectionWS)
{
#ifdef _SPECULARHIGHLIGHTS_OFF
    bool specularHighlightsOff = true;
#else
    bool specularHighlightsOff = false;
#endif
    return HairLighting(brdfData, hairData, light, normalWS, geomNormalWS, tangentWS, viewDirectionWS, specularHighlightsOff);
}

half3 VertexLighting(float3 positionWS, half3 normalWS)
{
    half3 vertexLightColor = half3(0.0, 0.0, 0.0);

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    uint lightsCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS);
        half3 lightColor = light.color * light.distanceAttenuation;
        vertexLightColor += LightingLambert(lightColor, light.direction, normalWS);
    }
#endif

    return vertexLightColor;
}

///////////////////////////////////////////////////////////////////////////////
//                      Fragment Functions                                   //
//       Used by ShaderGraph and others builtin renderers                    //
///////////////////////////////////////////////////////////////////////////////
half4 HairFragment(InputData inputData, SurfaceData surfaceData, half3 bitangent)
{
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif

    BRDFData brdfData;
    HairData hairData;

    // NOTE: can modify alpha
    InitializeBRDFData(surfaceData.albedo, 0.0, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
    InitializeHairData(surfaceData, hairData);
    hairData.specularTint *= surfaceData.perceptualSmoothness;
    hairData.secondarySpecularTint *= surfaceData.perceptualSmoothness;

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

    lightingData.giColor = GlobalIllumination(brdfData, inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor = HairLighting(brdfData, hairData, mainLight, inputData.normalWS, surfaceData.geomNormalWS, bitangent, inputData.viewDirectionWS, specularHighlightsOff);
    }

    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_CLUSTERED_LIGHTING
    for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += HairLighting(brdfData, hairData, light, inputData.normalWS, surfaceData.geomNormalWS, bitangent, inputData.viewDirectionWS, specularHighlightsOff);
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += HairLighting(brdfData, hairData, light, inputData.normalWS, surfaceData.geomNormalWS, bitangent, inputData.viewDirectionWS, specularHighlightsOff);
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}
#endif
