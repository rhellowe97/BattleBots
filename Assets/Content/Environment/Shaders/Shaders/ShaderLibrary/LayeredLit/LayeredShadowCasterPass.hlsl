#ifndef UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED
#define UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED

#if defined(_LAYER_MASK_VERTEX_COLOR_MUL) || (_LAYER_MASK_VERTEX_COLOR_ADD)
#define _VERTEX_COLOR
#endif

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "LayeredLitDisplacement.hlsl"

#ifdef TESSELLATION_ON
TessellationControlPoint ShadowPassVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    UNITY_SETUP_INSTANCE_ID(input);

    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.texcoord = input.texcoord;
#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
#endif
    return output;
}
#else
float3 _LightDirection;
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

#if defined(_VERTEX_COLOR)
    half4 vertexColor = input.vertexColor;
#else
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
#endif

#ifdef _VERTEX_DISPLACEMENT
    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.texcoord, layerTexCoord);
    half3 positionRWS = TransformObjectToWorld(input.positionOS.xyz);
    half3 height = ComputePerVertexDisplacement(layerTexCoord, vertexColor, 1);
    positionRWS += normalWS * height;
    input.positionOS = mul(unity_WorldToObject, half4(positionRWS, 1.0));
#endif

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
#endif
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}
#endif

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
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

    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.uv, layerTexCoord);
    LayeredData layeredData;
    InitializeLayeredData(layerTexCoord, layeredData);
    real weights[_MAX_LAYER];
    half4 blendMasks = GetBlendMask(_LayerMaskMap, sampler_LayerMaskMap, layerTexCoord.layerMaskUV, vertexColor);
    ComputeLayerWeights(_LayerCount, half4(layeredData.heightMap0, layeredData.heightMap1, layeredData.heightMap2, layeredData.heightMap3),
                         half4(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a), blendMasks, _HeightTransition, weights);
    LayeredAlpha(BlendLayeredScalar(layeredData.baseColor0.a, layeredData.baseColor1.a, layeredData.baseColor2.a, layeredData.baseColor3.a, weights), shadowCutoff);
    return 0;
}

#endif
