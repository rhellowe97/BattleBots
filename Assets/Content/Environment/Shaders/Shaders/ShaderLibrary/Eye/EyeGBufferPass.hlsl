#ifndef UNIVERSAL_LIT_GBUFFER_PASS_INCLUDED
#define UNIVERSAL_LIT_GBUFFER_PASS_INCLUDED

#include "ShaderLibrary/EyeLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

// keep this file in sync with LitForwardPass.hlsl

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD1;
#endif

    half3 normalWS                  : TEXCOORD2;
#if defined(_NORMALMAP)
    half4 tangentWS                 : TEXCOORD3;    // xyz: tangent, w: sign
#endif
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    half3 vertexLighting            : TEXCOORD4;    // xyz: vertex lighting
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD5;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV       : TEXCOORD8; // Dynamic lightmap UVs
#endif

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, half3 specularNormalTS, out half3 specularNormalWS, out InputData inputData)
{
    inputData = (InputData)0;

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
        inputData.positionWS = input.positionWS;
    #endif

    inputData.positionCS = input.positionCS;
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
#if defined(_NORMALMAP)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
    specularNormalWS = TransformTangentToWorld(specularNormalTS, tangentToWorld);
#else
    inputData.normalWS = input.normalWS;
    specularNormalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    specularNormalWS = NormalizeNormalPerPixel(specularNormalWS);
    inputData.viewDirectionWS = viewDirWS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif

    inputData.fogCoord = 0.0; // we don't apply fog in the guffer pass

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.vertexLighting = input.vertexLighting.xyz;
    #else
        inputData.vertexLighting = half3(0, 0, 0);
    #endif

#if defined(DYNAMICLIGHTMAP_ON)
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
#else
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
#endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitGBufferPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

    half fogFactor = 0;
    #if !defined(_FOG_FRAGMENT)
        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif

    output.uv = input.texcoord;

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
#ifdef _NORMALMAP
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;
#endif

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.vertexLighting = vertexLight;
    #endif

    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
        output.positionWS = vertexInput.positionWS;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    output.positionCS = vertexInput.positionCS;

    return output;
}

// Used in Standard (Physically Based) shader
FragmentOutput LitGBufferPassFragment(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    real3 positionOS, viewDirOS, normalOS;
    positionOS = TransformWorldToObject(input.positionWS);
    viewDirOS = GetObjectSpaceNormalizeViewDir(positionOS);
    normalOS = TransformWorldToObjectDir(normalize(input.normalWS));

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);

    // From HDRP Eye ShaderGraph shader 
    //Iris Calculation
    real3 refractedPosOS = CorneaRefraction(positionOS, viewDirOS, normalOS, 1.333h, 0.02h);
    real2 irisUV = IrisUVLocation(refractedPosOS, 0.225h);

    //SurfaceMask
    half irisRadius = 0.225h;
    half osRadius = length(positionOS.xy);
    half innerBlendRegionRadius = irisRadius - 0.02;
    half outerBlendRegionRadius = irisRadius + 0.02;
    half irisFactor = osRadius - irisRadius;
    half blendLerpFactor = 1.0 - irisFactor / (0.04);
    blendLerpFactor = pow(blendLerpFactor, 8.0);
    blendLerpFactor = 1.0 - blendLerpFactor;
    half surfaceMask = (osRadius > outerBlendRegionRadius) ? 0.0 : ((osRadius < irisRadius) ? 1.0 : (lerp(1.0, 0.0, blendLerpFactor)));
    
    //Mydriasis
    half mydriasisK = 1.0;
#ifdef _ENABLE_MYDRIASIS_MIOSIS
    half3 mydriasisVector = normalize(half3(0.0, 0.0, positionOS.z));
    half3 mainLightDirection = half3(_MainLightPosition.xyz);
    mydriasisK = _SunSensitivity * max(max(_MainLightColor.r, _MainLightColor.g), _MainLightColor.b) * saturate(dot(TransformObjectToWorldDir(mydriasisVector), mainLightDirection));
    #if defined(_ENABLE_LIGHT_SENSITIVITY) && defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
        {
            Light light = GetAdditionalLight(lightIndex, input.positionWS);
            half lightPower = _LightSensitivity * max(max(light.color.r, light.color.g), light.color.b);
            mydriasisK += lightPower * saturate(dot(TransformObjectToWorldDir(mydriasisVector), light.direction)) * light.distanceAttenuation;
        }
    #endif
    mydriasisK = lerp(_PupilFactorMax, _PupilFactorMin, saturate(mydriasisK));
#endif

    real2 circlePupilAnim = CirclePupilAnimation(irisUV, _PupilRadius, saturate(mydriasisK * _PupilAperture), _MinimalPupilAperture, _MaximalPupilAperture);
    real2 irisOffset = IrisOffset(circlePupilAnim, half2(_IrisOffset, 0.0h));

    half3 irisSource = SAMPLE_TEXTURE2D(_IrisMap, sampler_IrisMap, irisOffset).rgb;
    half3 irisNormal = SampleNormal(irisOffset, TEXTURE2D_ARGS(_IrisNormalMap, sampler_IrisNormalMap), _IrisNormalScale);

    half irisLimbalRing = IrisLimbalRing(irisUV, viewDirOS, _LimbalRingSizeIris, _LimbalRingFade, _LimbalRingIntensity);
    half3 irisColor = IrisOutOfBoundColorClamp(irisOffset, irisSource, _IrisClampColor.rgb) * irisLimbalRing;

    //Sclera Calculation
    real2 scleraUV = ScleraUVLocation(positionOS);
    half scleraLimbalRing = ScleraLimbalRing(positionOS, viewDirOS, 0.225h, _LimbalRingSizeSclera, _LimbalRingFade, _LimbalRingIntensity);

    half3 scleraSource = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, scleraUV).rgb * scleraLimbalRing;
    half3 scleraNormalSource = SampleNormal(scleraUV, TEXTURE2D_ARGS(_ScleraNormalMap, sampler_ScleraNormalMap), _ScleraNormalScale);

    //Output calculation
    surfaceData.albedo = lerp(scleraSource, irisColor, surfaceMask);
    surfaceData.normalTS = lerp(scleraNormalSource, irisNormal, surfaceMask);
    half3 specularNormal = lerp(scleraNormalSource, real3(0.0, 0.0, 1.0), surfaceMask);
    surfaceData.surfaceMask = surfaceMask;
    surfaceData.smoothness = lerp(_ScleraSmoothness, _CorneaSmoothness, surfaceMask);
#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
    surfaceData.smoothness = GeometricNormalFiltering(surfaceData.smoothness, input.normalWS.xyz, _SpecularAAScreenSpaceVariance, _SpecularAAThreshold);
#endif

#ifdef _EMISSION
    surfaceData.emission = _EmissionScale * SampleEmission(irisOffset, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    surfaceData.emission = lerp(0.0, surfaceData.emission, surfaceMask.x * irisLimbalRing);
    #ifdef _EMISSION_WITH_BASE
        surfaceData.emission *= surfaceData.albedo;
    #endif
#endif

    InputData inputData;
    real3 specularNormalWS;
    InitializeInputData(input, surfaceData.normalTS, specularNormal, specularNormalWS, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    // Stripped down version of UniversalFragmentPBR().

    // in LitForwardPass GlobalIllumination (and temporarily LightingPhysicallyBased) are called inside UniversalFragmentPBR
    // in Deferred rendering we store the sum of these values (and of emission as well) in the GBuffer
    BRDFData brdfData;
    InitializeBRDFData(surfaceData, brdfData);

#ifndef _ENABLE_MYDRIASIS_MIOSIS
    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
#endif
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surfaceData.occlusion, specularNormalWS, inputData.viewDirectionWS);

    return BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color, surfaceData.occlusion);
}
#endif
