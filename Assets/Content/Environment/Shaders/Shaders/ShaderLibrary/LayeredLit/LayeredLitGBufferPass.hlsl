#ifndef UNIVERSAL_LIT_GBUFFER_PASS_INCLUDED
#define UNIVERSAL_LIT_GBUFFER_PASS_INCLUDED

#define LIT

#include "ShaderLibrary/LitLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

// TODO: Currently we support viewDirTS caclulated in vertex shader and in fragments shader.
// As both solutions have their advantages and disadvantages (etc. shader target 2.0 has only 8 interpolators).
// We need to find out if we can stick to one solution, which we needs testing.
// So keeping this until I get manaul QA pass.
// GLES2 has limited amount of interpolators
#if defined(_PIXEL_DISPLACEMENT) && !defined(SHADER_API_GLES)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if defined(_DETAIL_MAP) || defined(_DETAIL_MAP1) || defined(_DETAIL_MAP2) || defined(_DETAIL_MAP3)
#define _DETAIL
#endif

#if defined(_BENTNORMALMAP) || defined(_BENTNORMALMAP1) || defined(_BENTNORMALMAP2) || defined(_BENTNORMALMAP3)
#define BENTNORMALMAP
#endif

#if defined(_NORMAL) || defined(_DETAIL) || defined(_DOUBLESIDED_ON) || (defined(_PIXEL_DISPLACEMENT) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))  || (defined(_BENTNORMAL_SPECULAR_OCCLUSION) && defined(BENTNORMALMAP))
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

#if defined(_LAYER_MASK_VERTEX_COLOR_MUL) || (_LAYER_MASK_VERTEX_COLOR_ADD)
#define _VERTEX_COLOR
#endif

#include "ShaderLibrary/LayeredLit/LayeredLitDisplacement.hlsl"

// keep this file in sync with LitForwardPass.hlsl
#if !defined(TESSELLATION_ON)
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD1;
#endif

    half3 normalWS                  : TEXCOORD2;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS                 : TEXCOORD3;    // xyz: tangent, w: sign
#endif
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    half3 vertexLighting            : TEXCOORD4;    // xyz: vertex lighting
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD5;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS                 : TEXCOORD6;
#endif

#if defined(_VERTEX_COLOR)
    half4 vertexColor               : COLOR;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV       : TEXCOORD8; // Dynamic lightmap UVs
#endif

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
#endif

void InitializeInputData(Varyings input, SurfaceData surfaceData, out real3 bentNormalWS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

    inputData.positionCS = input.positionCS;
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
#endif

#if defined(_NORMAL) || defined(_DETAIL) || defined(_DOUBLESIDED_ON)
    inputData.normalWS = TransformTangentToWorld(surfaceData.normalTS, tangentToWorld);
#else
    inputData.normalWS = input.normalWS;
#endif

#if defined(_BENTNORMAL_SPECULAROCCLUSION)
    #if defined(_BENTNORMALMAP)
    bentNormalWS = NormalizeNormalPerPixel(TransformTangentToWorld(surfaceData.bentNormalTS, tangentToWorld));
    #else
    bentNormalWS = NormalizeNormalPerPixel(input.normalWS);
    #endif
#else
    bentNormalWS = 0.0;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
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
#if !defined(TESSELLATION_ON)
// Used in Standard (Physically Based) shader
Varyings LitGBufferPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    output.uv = input.texcoord;
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    #if defined(_VERTEX_COLOR)
        half4 vertexColor = input.vertexColor;
    #else
        half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
    #endif

    #ifdef _VERTEX_DISPLACEMENT
        LayerTexCoord layerTexCoord;
        InitializeTexCoordinates(output.uv, layerTexCoord);
        half3 positionRWS = TransformObjectToWorld(input.positionOS.xyz);
        half3 height = ComputePerVertexDisplacement(layerTexCoord, vertexColor, 1);
        positionRWS += normalInput.normalWS * height;
        input.positionOS = mul(unity_WorldToObject, half4(positionRWS, 1.0));
    #endif
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
        real sign = input.tangentOS.w * GetOddNegativeScale();
        half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        output.tangentWS = tangentWS;
    #endif

    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
        half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
        half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
        output.viewDirTS = viewDirTS;
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
    
    #if defined(_VERTEX_COLOR)
        output.vertexColor = vertexColor;
    #endif

    output.positionCS = vertexInput.positionCS;

    return output;
}
#else
TessellationControlPoint LitGBufferPassVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // already normalized from normal transform to WS.
    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.texcoord = input.texcoord;

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
#ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif

#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
#endif

    return output;
}
#endif

void ApplyDoubleSidedFlipOrMirror(inout SurfaceData input, half faceSign)
{
    input.normalTS =  faceSign > 0 ? input.normalTS : input.normalTS * _DoubleSidedConstants.xyz;
}

// Used in Standard (Physically Based) shader
FragmentOutput LitGBufferPassFragment(Varyings input, half faceSign : VFACE)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.uv, layerTexCoord);

#if defined(_VERTEX_COLOR)
    half4 vertexColor = input.vertexColor;
#else
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
#endif

#ifdef _PIXEL_DISPLACEMENT
#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = input.viewDirTS;
#else
    half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, input.viewDirWS);
#endif
    float4 blendMasks = GetBlendMask(_LayerMaskMap, sampler_LayerMaskMap, layerTexCoord.layerMaskUV, vertexColor);
    ApplyPerPixelDisplacement(viewDirTS, layerTexCoord, blendMasks);
#endif

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(layerTexCoord, vertexColor, surfaceData);
    surfaceData.geomNormalWS = input.normalWS;

#ifdef _DOUBLESIDED_ON
    ApplyDoubleSidedFlipOrMirror(faceSign, surfaceData.normalTS);
#endif

#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
    surfaceData.smoothness = GeometricNormalFiltering(surfaceData.smoothness, input.normalWS, _SpecularAAScreenSpaceVariance, _SpecularAAThreshold);
#endif

    InputData inputData;
    real3 bentNormalWS;
    InitializeInputData(input, surfaceData, bentNormalWS, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

#ifdef _DBUFFER
    ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
#endif

    // Stripped down version of UniversalFragmentPBR().

    // in LitForwardPass GlobalIllumination (and temporarily LightingPhysicallyBased) are called inside UniversalFragmentPBR
    // in Deferred rendering we store the sum of these values (and of emission as well) in the GBuffer
    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);
    VectorsData vectorsData;
    InitializeVectorsData(vectorsData, surfaceData.geomNormalWS, inputData.normalWS, 0.0, bentNormalWS, inputData.viewDirectionWS, 0.0);
    
    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
    half3 color = GlobalIllumination(brdfData, vectorsData, inputData.bakedGI, surfaceData.occlusion, surfaceData.horizonFade, surfaceData.giOcclusionBias);

    return BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color);
}

#endif
