#ifndef UNIVERSAL_LIT_META_PASS_INCLUDED
#define UNIVERSAL_LIT_META_PASS_INCLUDED

#if defined(_LAYER_MASK_VERTEX_COLOR_MUL) || (_LAYER_MASK_VERTEX_COLOR_ADD)
#define _VERTEX_COLOR
#endif

#include "ShaderLibrary/UniversalMetaInput.hlsl"
#include "LayeredLitDisplacement.hlsl"

#ifdef TESSELLATION_ON
TessellationControlPoint UniversalVertexMeta(Attributes input)
{
    TessellationControlPoint output = (TessellationControlPoint)0;
    output.positionOS = input.positionOS;
    output.uv0 = input.uv0;
    output.uv1 = input.uv1;
    output.uv2 = input.uv2;
#ifdef _TANGENT_TO_WORLD
    output.tangentOS = input.tangentOS;
#endif
#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
#endif
    return output;
}
#else
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 uv0          : TEXCOORD0;
    float2 uv1          : TEXCOORD1;
    float2 uv2          : TEXCOORD2;
#ifdef _TANGENT_TO_WORLD
    float4 tangentOS    : TANGENT;
#endif
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
#ifdef EDITOR_VISUALIZATION
    float2 VizUV        : TEXCOORD1;
    float4 LightCoord   : TEXCOORD2;
#endif
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
};

Varyings UniversalVertexMeta(Attributes input)
{
    Varyings output;
    output.positionCS = MetaVertexPosition(input.positionOS, input.uv1, input.uv2, unity_LightmapST, unity_DynamicLightmapST);
    output.uv = TRANSFORM_TEX(input.uv0, _BaseMap);
#ifdef EDITOR_VISUALIZATION
    UnityEditorVizData(input.positionOS.xyz, input.uv0, input.uv1, input.uv2, output.VizUV, output.LightCoord);
#endif
#if defined(_VERTEX_COLOR)
    output.vertexColor = input.vertexColor;
#endif
    return output;
}
#endif

half4 UniversalFragmentMeta(Varyings fragIn, MetaInput metaInput)
{
#ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = fragIn.VizUV;
    metaInput.LightCoord = fragIn.LightCoord;
#endif

    return UnityMetaFragment(metaInput);
}

half4 UniversalFragmentMetaLit(Varyings input) : SV_Target
{
    LayerTexCoord layerTexCoord;
    InitializeTexCoordinates(input.uv, layerTexCoord);
    SurfaceData surfaceData;
#if defined(_VERTEX_COLOR)
    half4 vertexColor = input.vertexColor;
#else
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
#endif
    InitializeStandardLitSurfaceData(layerTexCoord, vertexColor, surfaceData);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.Emission = surfaceData.emission;

    return UniversalFragmentMeta(input, metaInput);
}
#endif