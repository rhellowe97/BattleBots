half3 GetViewDirectionTangentSpace(half4 tangentWS, half3 normalWS, half3 viewDirWS)
{
    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    half3 unnormalizedNormalWS = normalWS;
    const half renormFactor = 1.0 / length(unnormalizedNormalWS);

    // use bitangent on the fly like in hdrp
    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
    half crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0); // we do not need to multiple GetOddNegativeScale() here, as it is done in vertex shader
    half3 bitang = crossSign * cross(normalWS.xyz, tangentWS.xyz);

    half3 WorldSpaceNormal = renormFactor * normalWS.xyz;       // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    half3 WorldSpaceTangent = renormFactor * tangentWS.xyz;
    half3 WorldSpaceBiTangent = renormFactor * bitang;

    half3x3 tangentSpaceTransform = half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
    half3 viewDirTS = mul(tangentSpaceTransform, viewDirWS);

    return viewDirTS;
}

real3 GetDisplacementObjectScale(bool vertexDisplacement)
{
    real3 objectScale = real3(1.0, 1.0, 1.0);

    real4x4 worldTransform;
    if (vertexDisplacement)
    {
        worldTransform = GetObjectToWorldMatrix();
    }

    else
    {
        worldTransform = GetWorldToObjectMatrix();
    }

    objectScale.x = length(real3(worldTransform._m00, worldTransform._m01, worldTransform._m02));
#if !defined(_PIXEL_DISPLACEMENT) || (defined(_PIXEL_DISPLACEMENT_LOCK_OBJECT_SCALE))
    objectScale.y = length(real3(worldTransform._m10, worldTransform._m11, worldTransform._m12));
#endif
    objectScale.z = length(real3(worldTransform._m20, worldTransform._m21, worldTransform._m22));

    return objectScale;
}

real3 ComputePerVertexDisplacement(TEXTURE2D_PARAM(heightMap, sampler_heightMap), real2 uv, float lod)
{
#ifdef _HEIGHTMAP
    real height = (SAMPLE_TEXTURE2D_LOD(heightMap, sampler_heightMap, uv, lod).r - _HeightCenter) * _HeightAmplitude;
#else
    real height = 0.0;
#endif

#ifdef _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
    real3 objectScale = GetDisplacementObjectScale(true);
    return height.xxx * objectScale;
#else
    return height.xxx;
#endif
}

float GetMaxDisplacement()
{
    float maxDisplacement = 0.0;
#if defined(_HEIGHTMAP)
    maxDisplacement = abs(_HeightAmplitude); // _HeightAmplitude can be negative if min and max are inverted, but the max displacement must be positive
#endif
    return maxDisplacement;
}

float2 GetMinUvSize(real2 uv)
{
    float2 minUvSize = float2(FLT_MAX, FLT_MAX);

#if defined(_HEIGHTMAP)
    minUvSize = min(uv * _HeightMap_TexelSize.zw, minUvSize);
#endif

    return minUvSize;
}
void ApplyDisplacementTileScale(inout float height)
{
    // Inverse tiling scale = 2 / (abs(_BaseColorMap_ST.x) + abs(_BaseColorMap_ST.y)
    // Inverse tiling scale *= (1 / _TexWorldScale) if planar or triplanar
#ifdef _DISPLACEMENT_LOCK_TILING_SCALE
    height *= _InvTilingScale;
#endif
}

#if defined(_PIXEL_DISPLACEMENT) 
real2 ParallaxOcclusionMapping(real lod, real lodThreshold, int numSteps, real3 viewDirTS, real2 uv, out real outHeight)
{
    real stepSize = 1.0 / (real)numSteps;

    real2 parallaxMaxOffsetTS = (viewDirTS.xy / -viewDirTS.z);
    real2 texOffsetPerStep = stepSize * parallaxMaxOffsetTS;

    // Do a first step before the loop to init all value correctly
    real2 texOffsetCurrent = real2(0.0, 0.0);
    real prevHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, uv, lod).r;
    texOffsetCurrent += texOffsetPerStep;
    real currHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, uv + texOffsetCurrent, lod).r;
    real rayHeight = 1.0 - stepSize; // Start at top less one sample

    // Linear search
    for (int stepIndex = 0; stepIndex < numSteps; ++stepIndex)
    {
        // Have we found a height below our ray height ? then we have an intersection
        if (currHeight > rayHeight)
            break; // end the loop

        prevHeight = currHeight;
        rayHeight -= stepSize;
        texOffsetCurrent += texOffsetPerStep;

        // Sample height map which in this case is stored in the alpha channel of the normal map:
        currHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, uv + texOffsetCurrent, lod).r;
    }

    // Found below and above points, now perform line interesection (ray) with piecewise linear heightfield approximation

    // Refine the search with secant method
#define POM_SECANT_METHOD 1
#if POM_SECANT_METHOD

    real pt0 = rayHeight + stepSize;
    real pt1 = rayHeight;
    real delta0 = pt0 - prevHeight;
    real delta1 = pt1 - currHeight;

    real delta;
    real2 offset;

    // Secant method to affine the search
    // Ref: Faster Relief Mapping Using the Secant Method - Eric Risser
    for (int i = 0; i < 3; ++i)
    {
        // intersectionHeight is the height [0..1] for the intersection between view ray and heightfield line
        real intersectionHeight = (pt0 * delta1 - pt1 * delta0) / (delta1 - delta0);
        // Retrieve offset require to find this intersectionHeight
        offset = (1 - intersectionHeight) * texOffsetPerStep * numSteps;

        currHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, uv + offset, lod).r;

        delta = intersectionHeight - currHeight;

        if (abs(delta) <= 0.01)
            break;

        // intersectionHeight < currHeight => new lower bounds
        if (delta < 0.0)
        {
            delta1 = delta;
            pt1 = intersectionHeight;
        }
        else
        {
            delta0 = delta;
            pt0 = intersectionHeight;
        }
    }

#else // regular POM intersection

    real delta0 = currHeight - rayHeight;
    real delta1 = (rayHeight + stepSize) - prevHeight;
    real ratio = delta0 / (delta0 + delta1);
    real2 offset = texOffsetCurrent - ratio * texOffsetPerStep;

    currHeight = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, uv + offset, lod).r;

#endif

    outHeight = currHeight;

    // Fade the effect with lod (allow to avoid pop when switching to a discrete LOD mesh)
    offset *= (1.0 - saturate(lod - lodThreshold));

    return offset;
}

float ApplyPerPixelDisplacement(half3 viewDirTS, inout float2 uv)
{
#if defined(_HEIGHTMAP)
    viewDirTS *= GetDisplacementObjectScale(false).xzy;
    
    half  maxHeight = GetMaxDisplacement();
    ApplyDisplacementTileScale(maxHeight);
    real2 minUvSize = GetMinUvSize(uv);
    half lod = ComputeTextureLOD(minUvSize);

    // TODO: precompute uvSpaceScale
    /*float2 invPrimScale = (isPlanar || isTriplanar) ? float2(1.0, 1.0) : _InvPrimScale.xy;
    float  worldScale   = (isPlanar || isTriplanar) ? _TexWorldScale : 1.0;
    float2 uvSpaceScale = invPrimScale * _BaseMap_ST.xy * (worldScale * maxHeight);*/
    float2 uvSpaceScale = _InvPrimScale.xy * _BaseMap_ST.xy * maxHeight;

    half height = 0;

    real3 viewDirUV  = real3(viewDirTS.xy * uvSpaceScale, viewDirTS.z);
    real   unitAngle = saturate(FastACosPos(viewDirUV.z) * INV_HALF_PI);
    int    numSteps  = (int)lerp(_PPDMinSamples, _PPDMaxSamples, unitAngle);
    float2 offset    = ParallaxOcclusionMapping(lod, _PPDLodThreshold, numSteps, viewDirUV, uv, height);

    uv += offset;

    float verticalDisplacement = maxHeight - height * maxHeight;
    return verticalDisplacement / max(viewDirTS.z, 0.0001);
#else
    return 0.0;
#endif
}
#endif

#ifdef TESSELLATION_ON
#include "ShaderLibrary/Tessellation.hlsl"
#endif