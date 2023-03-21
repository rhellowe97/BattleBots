#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShaderLibrary/LitDisplacement.hlsl"

#ifdef TESSELLATION_ON
TessellationControlPoint DepthOnlyVertex(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.texcoord = input.texcoord;
    output.normalOS = input.normalOS;
    output.positionOS = input.positionOS;
    return output;
}
#else
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
#if defined(_VERTEX_DISPLACEMENT)
    half3 positionRWS = TransformObjectToWorld(input.positionOS.xyz);
    half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    half3 height = ComputePerVertexDisplacement(_HeightMap, sampler_HeightMap, output.uv, 1);
    positionRWS += normalWS * height;
    input.positionOS = mul(unity_WorldToObject, half4(positionRWS, 1.0));
#endif
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    return output;
}
#endif

half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
#ifdef SHADOW_CUTOFF
    half shadowCutoff = _AlphaCutoffShadow;
#else
    half shadowCutoff = _Cutoff;
#endif

    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, shadowCutoff);
    return 0;
}
#endif
