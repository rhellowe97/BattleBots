#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

#if defined(_NORMALMAP) || defined(_PIXEL_DISPLACEMENT) || defined(_DETAIL)
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

#include "LitDisplacement.hlsl"

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

    return output;
}
#else
struct Attributes
{
    float4 positionOS   : POSITION;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float3 normal       : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD1;
    float3 normalWS     : TEXCOORD2;

    float3 positionWS  : TEXCOORD3;

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS    : TEXCOORD4;
    #endif

    half3 viewDirWS    : TEXCOORD5;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv         = TRANSFORM_TEX(input.texcoord, _BaseMap);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
    #if defined(_VERTEX_DISPLACEMENT)
        half3 height = ComputePerVertexDisplacement(_HeightMap, sampler_HeightMap, output.uv, 1);
        vertexInput.positionWS += normalInput.normalWS * height;
    #endif  
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    output.positionCS = TransformWorldToHClip(vertexInput.positionWS);

    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
        float sign = input.tangentOS.w * float(GetOddNegativeScale());
        half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
        output.tangentWS = tangentWS;
    #endif

    output.positionWS = vertexInput.positionWS;

    return output;
}
#endif

void DepthNormalsFragment(Varyings input, out float4 outColor : SV_TARGET
#if defined(_SHADER_QUALITY_HIGH_QUALITY_DEPTH_NORMALS) && defined(_PIXEL_DISPLACEMENT) && defined(_DEPTHOFFSET_ON)
    , out float outputDepth : SV_Depth
#endif
)
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
#ifdef SHADOW_CUTOFF
    half shadowCutoff = _AlphaCutoffShadow;
#else
    half shadowCutoff = _Cutoff;
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
        #ifdef _PIXEL_DISPLACEMENT
            half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
            half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, viewDirWS);
            half depthOffset = ApplyPerPixelDisplacement(viewDirTS, input.uv);
            #if defined(_DEPTHOFFSET_ON)
                input.positionWS += depthOffset * (-viewDirWS);
                outputDepth = ComputeNormalizedDeviceCoordinatesWithZ(input.positionWS, GetWorldToHClipMatrix()).z;
            #endif
        #endif

        #if defined(_NORMALMAP) || defined(_DETAIL)
            float sgn = input.tangentWS.w;      // should be either +1 or -1
            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
            float3 normalTS = SampleNormal(input.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

            #if defined(_DETAIL)
                half detailMask = 1.0h;
                #ifdef _MASKMAP
                    detailMask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, input.uv).b;
                #endif
                real2   detailUV = TRANSFORM_TEX(input.uv, _DetailMap);
                half2   detail = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, detailUV).ga;
                half3   detailNormal = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detail.r, detail.g, 1.0h, 1.0h))), _DetailNormalScale);
                normalTS = DetailNormal(normalTS, detailNormal, detailMask);
            #endif
            float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
        #else
            float3 normalWS = input.normalWS;
        #endif

        outColor = half4(NormalizeNormalPerPixel(normalWS), 0.0);
    #else
        float3 normalWS = input.normalWS;
        outColor = half4(NormalizeNormalPerPixel(normalWS), 0.0);
    #endif
#endif

}
#endif
