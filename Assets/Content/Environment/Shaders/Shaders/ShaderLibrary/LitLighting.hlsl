#ifndef UNIVERSAL_LIGHTING_INCLUDED
#define UNIVERSAL_LIGHTING_INCLUDED

struct VectorsData
{
    real3 geomNormalWS;
    real3 normalWS;
    real3 coatNormalWS;
    real3 bentNormalWS;
    real3 viewDirectionWS;
    real4 tangentWS;
};

inline void InitializeVectorsData(inout VectorsData vectorsData, real3 geomNormalWS, real3 normalWS, real3 coatNormalWS, real3 bentNormalWS, real3 viewDirWS, real4 tangentWS)
{
    vectorsData.geomNormalWS     = geomNormalWS;
    vectorsData.normalWS         = normalWS;
    vectorsData.coatNormalWS     = coatNormalWS;
    vectorsData.bentNormalWS    = bentNormalWS;
    vectorsData.viewDirectionWS  = viewDirWS;
    vectorsData.tangentWS        = tangentWS;
}

#include "ShaderLibrary/BRDF.hlsl"
#include "ShaderLibrary/UniversalGlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "ShaderLibrary/BSDF.hlsl"
#include "ShaderLibrary/LightingFunctions.hlsl"

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

half4 SimpleLitFragment(InputData inputData, SurfaceData surfaceData)
{
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif
    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(surfaceData, brdfData);

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

    lightingData.giColor = GlobalIllumination(brdfData, inputData.bakedGI, inputData.positionWS, surfaceData.geomNormalWS, inputData.normalWS, inputData.viewDirectionWS, aoFactor.indirectAmbientOcclusion, surfaceData.horizonFade);

    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor = SimpleLitLighting(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS, specularHighlightsOff);
    }

    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_CLUSTERED_LIGHTING
    for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += SimpleLitLighting(brdfData, light, inputData.normalWS, inputData.viewDirectionWS, specularHighlightsOff);
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += SimpleLitLighting(brdfData, light, inputData.normalWS, inputData.viewDirectionWS, specularHighlightsOff);
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}

half4 LitFragment(InputData inputData, SurfaceData surfaceData, real3 coatNormalWS, real3 bentNormalWS)
{
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif
    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(surfaceData, brdfData);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    // Clear-coat calculation...
    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    VectorsData vectorsData;
    InitializeVectorsData(vectorsData, surfaceData.geomNormalWS, inputData.normalWS, coatNormalWS, bentNormalWS, inputData.viewDirectionWS, 0.0);

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);

    half giOcclusionBias = 0.0;
    #ifdef _GI_SPECULAR_OCCLUSION
    giOcclusionBias = surfaceData.giOcclusionBias;
    #endif
    
    lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, vectorsData, inputData.positionWS, inputData.bakedGI, surfaceData.clearCoatMask, aoFactor.indirectAmbientOcclusion, surfaceData.horizonFade, giOcclusionBias);
    
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor = LitLighting(brdfData, brdfDataClearCoat, vectorsData, mainLight, surfaceData.clearCoatMask, surfaceData.occlusion, specularHighlightsOff);
    }

    #if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_CLUSTERED_LIGHTING
    for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += LitLighting(brdfData, brdfDataClearCoat, vectorsData, light, surfaceData.clearCoatMask, surfaceData.occlusion, specularHighlightsOff);
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += LitLighting(brdfData, brdfDataClearCoat, vectorsData, light, surfaceData.clearCoatMask, surfaceData.occlusion, specularHighlightsOff);
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}

half4 ComplexLitFragment(InputData inputData, SurfaceData surfaceData, real3 coatNormalWS, real3 bentNormalWS, real4 tangentWS)
{
    #if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
    #else
    bool specularHighlightsOff = false;
    #endif
    BRDFData brdfData;

    // NOTE: can modify "surfaceData"...
    InitializeBRDFData(surfaceData, brdfData);

    BSDFData bsdfData;
        half3 iridescence = half3(0.2, 0.2, 0.2);
    #ifdef _MATERIAL_FEATURE_IRIDESCENCE
        iridescence = IridescenceSpecular(inputData.normalWS, inputData.viewDirectionWS, brdfData.specular, surfaceData.iridescenceTMS, surfaceData.clearCoatMask);
    #endif
    InitializeBSDFData(bsdfData, surfaceData, iridescence);

    #if defined(DEBUG_DISPLAY)
    half4 debugColor;

    if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
    {
        return debugColor;
    }
    #endif

    // Clear-coat calculation...
    BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
    
    VectorsData vectorsData;
    InitializeVectorsData(vectorsData, surfaceData.geomNormalWS, inputData.normalWS, coatNormalWS, bentNormalWS, inputData.viewDirectionWS, tangentWS);

    // NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);

    half giOcclusionBias = 0.0;
    #ifdef _GI_SPECULAR_OCCLUSION
    giOcclusionBias = surfaceData.giOcclusionBias;
    #endif
    
    lightingData.giColor = GlobalIllumination(brdfData, brdfDataClearCoat, bsdfData, vectorsData, inputData.positionWS, inputData.bakedGI, aoFactor.indirectAmbientOcclusion, surfaceData.horizonFade, giOcclusionBias);
    
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor = ComplexLitLighting(brdfData, brdfDataClearCoat, bsdfData, vectorsData, mainLight, surfaceData.occlusion, specularHighlightsOff);
        #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
        lightingData.mainLightColor += Translucency(bsdfData, mainLight, brdfData.diffuse, inputData.normalWS, inputData.viewDirectionWS);
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
            lightingData.additionalLightsColor += ComplexLitLighting(brdfData, brdfDataClearCoat, bsdfData, vectorsData, light, surfaceData.occlusion, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
            lightingData.additionalLightsColor += Translucency(bsdfData, light, brdfData.diffuse, inputData.normalWS, inputData.viewDirectionWS);
            #endif
        }
    }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);

        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += ComplexLitLighting(brdfData, brdfDataClearCoat, bsdfData, vectorsData, light, surfaceData.occlusion, specularHighlightsOff);
            #ifdef _MATERIAL_FEATURE_TRANSLUCENCY
            lightingData.additionalLightsColor += Translucency(bsdfData, light, brdfData.diffuse, inputData.normalWS, inputData.viewDirectionWS);
            #endif
        }
    LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
    lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif

    return CalculateFinalColor(lightingData, surfaceData.alpha);
}

void ApplyDoubleSidedFlipOrMirror(half faceSign, inout half3 normalTS)
{
    normalTS = faceSign > 0 ? normalTS : normalTS * _DoubleSidedConstants.xyz;
}
#endif