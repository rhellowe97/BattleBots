#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

#if defined(_PIXEL_DISPLACEMENT) && !defined(SHADER_API_GLES)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if defined(_NORMALMAP) || defined(_NORMALMAP1) || defined(_NORMALMAP2) || defined(_NORMALMAP3)
#define _NORMAL
#endif

#if defined(_DETAIL_MAP) || defined(_DETAIL_MAP1) || defined(_DETAIL_MAP2) || defined(_DETAIL_MAP3)
#define _DETAIL
#endif

#if (defined(_NORMAL) || (defined(_PIXEL_DISPLACEMENT) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL) || (defined(_BENTNORMAL_SPECULAR_OCCLUSION) && defined(BENTNORMALMAP))
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

#if defined(_LAYER_MASK_VERTEX_COLOR_MUL) || (_LAYER_MASK_VERTEX_COLOR_ADD)
#define _VERTEX_COLOR
#endif

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "LayeredLitDisplacement.hlsl"

#ifdef TESSELLATION_ON
TessellationControlPoint DepthNormalsVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.tangentOS = input.tangentOS;
    output.texcoord = input.texcoord;
#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
#endif

    return output;
}
#else
struct Attributes
{
    float4 positionOS   : POSITION;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float3 normal       : NORMAL;
#if defined(_VERTEX_COLOR)
    half4  vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD1;
    float3 normalWS     : TEXCOORD2;

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS     : TEXCOORD4;
    #endif

    half3 viewDirWS     : TEXCOORD5;

    #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    float3 viewDirTS    : TEXCOORD8;
    #endif

#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = input.texcoord;
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
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

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    output.normalWS = half3(normalInput.normalWS);
    output.positionCS = TransformWorldToHClip(vertexInput.positionWS);

#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    float sign = input.tangentOS.w * float(GetOddNegativeScale());
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif

#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
    output.viewDirTS = viewDirTS;
#endif

    return output;
}
#endif

float4 DepthNormalsFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
#ifdef SHADOW_CUTOFF
    half shadowCutoff = _AlphaCutoffShadow;
#else
    half shadowCutoff = _Cutoff;
#endif

#if defined(_VERTEX_COLOR)
    half4 vertexColor = input.vertexColor;
#else
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
#endif
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, shadowCutoff);

#if defined(_GBUFFER_NORMALS_OCT)
    float3 normalWS = normalize(input.normalWS);
    float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
    float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
    half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
    return half4(packedNormalWS, 0.0);
#else
    #if defined(_SHADER_QUALITY_HIGH_QUALITY_DEPTH_NORMALS)
        LayerTexCoord layerTexCoord;
        InitializeTexCoordinates(input.uv, layerTexCoord);

        real weights[_MAX_LAYER];
        half4 blendMasks = GetBlendMask(_LayerMaskMap, sampler_LayerMaskMap, layerTexCoord.layerMaskUV, vertexColor);
        #ifdef _PIXEL_DISPLACEMENT
        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
            half3 viewDirTS = input.viewDirTS;
        #else
            half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, input.viewDirWS);
        #endif
            ApplyPerPixelDisplacement(viewDirTS, layerTexCoord, blendMasks);
        #endif

        LayeredData layeredData;
        InitializeLayeredData(layerTexCoord, layeredData);

        ComputeLayerWeights(_LayerCount, half4(layeredData.heightMap0, layeredData.heightMap1, layeredData.heightMap2, layeredData.heightMap3),
                             half4(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a), blendMasks, _HeightTransition, weights);

        #if defined(_NORMAL) || defined(_DETAIL)
            float sgn = input.tangentWS.w;      // should be either +1 or -1
            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
            half3 normalTS;
            #if defined(_MAIN_LAYER_INFLUENCE_MODE)
                #ifdef _INFLUENCEMASK_MAP
                float influenceMask = GetInfluenceMask(layerTexCoord);
                #else
                float influenceMask = 1.0;
                #endif

                if (influenceMask > 0.0f)
                {
                    normalTS = ComputeMainNormalInfluence(influenceMask, layeredData.normalMap0, layeredData.normalMap1, layeredData.normalMap2, layeredData.normalMap3,
                                                                    blendMasks.a, half3(_InheritBaseNormal1, _InheritBaseNormal2, _InheritBaseNormal3), weights);
                }
                else
            #endif
                {
                    normalTS = BlendLayeredVector3(layeredData.normalMap0, layeredData.normalMap1, layeredData.normalMap2, layeredData.normalMap3, weights);
                }

            #ifdef _DETAIL_MAP
                half4   detailMap0 = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, layerTexCoord.detailUV0);
                half3   detailNormal0 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap0.g, detailMap0.a, 1.0h, 1.0h))), _DetailNormalScale);
                normalTS = DetailNormals(normalTS, detailNormal0, layeredData.maskMap0.b * weights[0]);
            #endif
            #ifdef _DETAIL_MAP1
                half4   detailMap1 = SAMPLE_TEXTURE2D(_DetailMap1, sampler_DetailMap1, layerTexCoord.detailUV1);
                half3   detailNormal1 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap1.g, detailMap1.a, 1.0h, 1.0h))), _DetailNormalScale1);
                normalTS = DetailNormals(normalTS, detailNormal1, layeredData.maskMap1.b * weights[1]);
            #endif
            #ifdef _DETAIL_MAP2
                half4   detailMap2 = SAMPLE_TEXTURE2D(_DetailMap2, sampler_DetailMap2, layerTexCoord.detailUV2);
                half3   detailNormal2 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap2.g, detailMap2.a, 1.0h, 1.0h))), _DetailNormalScale2);
                normalTS = DetailNormals(normalTS, detailNormal2, layeredData.maskMap2.b * weights[2]);
            #endif
            #ifdef _DETAIL_MAP3
                half4   detailMap3 = SAMPLE_TEXTURE2D(_DetailMap3, sampler_DetailMap3, layerTexCoord.detailUV3);
                half3   detailNormal3 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap3.g, detailMap3.a, 1.0h, 1.0h))), _DetailNormalScale3);
                normalTS = DetailNormals(normalTS, detailNormal3, layeredData.maskMap3.b * weights[3]);
            #endif
            float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
        #else
            float3 normalWS = input.normalWS;
        #endif
    #else
        float3 normalWS = input.normalWS;
        return half4(NormalizeNormalPerPixel(normalWS), 0.0);
    #endif
#endif

    return float4(PackNormalOctRectEncode(TransformWorldToViewDir(normalWS, true)), 0.0, 0.0);
}
#endif
