#ifndef UNIVERSAL_LAYERED_LIT_DISPLACEMENT_PASS_INCLUDED
#define UNIVERSAL_LAYERED_LIT_DISPLACEMENT_PASS_INCLUDED

#include "ShaderLibrary/LayeredLit/LayeredSurfaceInput.hlsl"

#define LAYERS_HEIGHTMAP_ENABLE (defined(_HEIGHTMAP) || defined(_HEIGHTMAP1) || (_LAYER_COUNT > 2 && defined(_HEIGHTMAP2)) || (_LAYER_COUNT > 3 && defined(_HEIGHTMAP3)))

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

real GetMaxDisplacement()
{
    real maxDisplacement = 0.0;

    // _HeightAmplitudeX can be negative if min and max are inverted, but the max displacement must be positive, take abs()
#if defined(_HEIGHTMAP)
    maxDisplacement = abs(_HeightAmplitude);
#endif

#if defined(_HEIGHTMAP1)
    maxDisplacement = max(  abs(_HeightAmplitude1)
                            #if defined(_MAIN_LAYER_INFLUENCE_MODE)
                            + abs(_HeightAmplitude) * _InheritBaseHeight1
                            #endif
                            , maxDisplacement);
#endif

#if _LAYER_COUNT >= 3
#if defined(_HEIGHTMAP2)
    maxDisplacement = max(  abs(_HeightAmplitude2)
                            #if defined(_MAIN_LAYER_INFLUENCE_MODE)
                            + abs(_HeightAmplitude) * _InheritBaseHeight2
                            #endif
                            , maxDisplacement);
#endif
#endif

#if _LAYER_COUNT >= 4
#if defined(_HEIGHTMAP3)
    maxDisplacement = max(  abs(_HeightAmplitude3)
                            #if defined(_MAIN_LAYER_INFLUENCE_MODE)
                            + abs(_HeightAmplitude) * _InheritBaseHeight3
                            #endif
                            , maxDisplacement);
#endif
#endif

    return maxDisplacement;
}

float2 GetMinUvSize(LayerTexCoord layerTexCoord)
{
    float2 minUvSize = float2(FLT_MAX, FLT_MAX);

#if defined(_HEIGHTMAP)
    minUvSize = min(layerTexCoord.baseUV0 * _HeightMap_TexelSize.zw, minUvSize);
#endif

#if defined(_HEIGHTMAP1)
    minUvSize = min(layerTexCoord.baseUV1 * _HeightMap1_TexelSize.zw, minUvSize);
#endif

#if _LAYER_COUNT >= 3
#if defined(_HEIGHTMAP2)
    minUvSize = min(layerTexCoord.baseUV2 * _HeightMap2_TexelSize.zw, minUvSize);
#endif
#endif

#if _LAYER_COUNT >= 4
#if defined(_HEIGHTMAP3)
    minUvSize = min(layerTexCoord.baseUV3 * _HeightMap3_TexelSize.zw, minUvSize);
#endif
#endif

    return minUvSize;
}


struct PerPixelHeightDisplacementParam
{
    real4 blendMasks;
    float2 uv[4];
    //float2 uvSpaceScale[4];
#if defined(_MAIN_LAYER_INFLUENCE_MODE) && defined(_HEIGHTMAP)
    real heightInfluence[4];
#endif
};

void SetEnabledHeightByLayer(inout real height0, inout real height1, inout real height2, inout real height3)
{
#ifndef _HEIGHTMAP
    height0 = 0.0;
#endif
#ifndef _HEIGHTMAP1
    height1 = 0.0;
#endif
#ifndef _HEIGHTMAP2
    height2 = 0.0;
#endif
#ifndef _HEIGHTMAP3
    height3 = 0.0;
#endif

#if _LAYER_COUNT < 4
    height3 = 0.0;
#endif
#if _LAYER_COUNT < 3
    height2 = 0.0;
#endif
}

real ComputePerPixelHeightDisplacement(float2 texOffsetCurrent, real lod, real4 blendMasks, LayerTexCoord layerTexCoord)
{
    // See function ComputePerVertexDisplacement() for comment about the weights/influenceMask/BlendMask

    // Note: Amplitude is handled in uvSpaceScale, no need to multiply by it here.
    real height0 = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, layerTexCoord.baseUV0 + texOffsetCurrent * _BaseMap_ST.xy, lod).r;
    real height1 = SAMPLE_TEXTURE2D_LOD(_HeightMap1, sampler_HeightMap, layerTexCoord.baseUV1 + texOffsetCurrent * _BaseMap1_ST.xy, lod).r;
    real height2 = SAMPLE_TEXTURE2D_LOD(_HeightMap2, sampler_HeightMap, layerTexCoord.baseUV2 + texOffsetCurrent * _BaseMap2_ST.xy, lod).r;
    real height3 = SAMPLE_TEXTURE2D_LOD(_HeightMap3, sampler_HeightMap, layerTexCoord.baseUV3 + texOffsetCurrent * _BaseMap3_ST.xy, lod).r;

    SetEnabledHeightByLayer(height0, height1, height2, height3);

#if defined(_HEIGHT_BASED_BLEND)
    // Modify blendMask to take into account the height of the layer. Higher height should be more visible.
    blendMasks = ApplyHeightBlend(half4(height0, height1, height2, height3), blendMasks, _HeightTransition);
#endif

    real weights[_MAX_LAYER];
    ComputeMaskWeights(blendMasks, weights);

#if defined(_MAIN_LAYER_INFLUENCE_MODE) && defined(_HEIGHTMAP)
    real influenceMask = blendMasks.a;
    #ifdef _INFLUENCEMASK_MAP
    influenceMask *= SAMPLE_TEXTURE2D_LOD(_LayerInfluenceMaskMap, sampler_BaseMap, layerTexCoord.baseUV0, lod).r;
    #endif
    height1 += height0 * _InheritBaseHeight1 * influenceMask;
    height2 += height0 * _InheritBaseHeight2 * influenceMask;
    height3 += height0 * _InheritBaseHeight3 * influenceMask;
#endif

    return BlendLayeredScalar(height0, height1, height2, height3, weights);
}

void ApplyDisplacementTileScale(inout real height0, inout real height1, inout real height2, inout real height3)
{
    // When we change the tiling, we have want to conserve the ratio with the displacement (and this is consistent with per pixel displacement)
#ifdef _DISPLACEMENT_LOCK_TILING_SCALE
    real tileObjectScale = 1.0;
    #ifdef _LAYER_TILING_COUPLED_WITH_UNIFORM_OBJECT_SCALE
    // Extract scaling from world transform
    float4x4 worldTransform = GetObjectToWorldMatrix();
    // assuming uniform scaling, take only the first column
    tileObjectScale = length(real3(worldTransform._m00, worldTransform._m01, worldTransform._m02));
    #endif

    // TODO: precompute all these scaling factors!
    height0 *= _InvTilingScale0;
    #if !defined(_MAIN_LAYER_INFLUENCE_MODE)
    height0 /= tileObjectScale;  // We only affect layer0 in case we are not in influence mode (i.e we should not change the base object)
    #endif
    height1 = (height1 / tileObjectScale) * _InvTilingScale1;
    height2 = (height2 / tileObjectScale) * _InvTilingScale2;
    height3 = (height3 / tileObjectScale) * _InvTilingScale3;
#endif
}

real2 ParallaxOcclusionMapping(real lod, real lodThreshold, int numSteps, real3 viewDirTS, real4 blendMasks, LayerTexCoord layerTexCoord)
{
    // Convention: 1.0 is top, 0.0 is bottom - POM is always inward, no extrusion
    real stepSize = 1.0 / (real)numSteps;

    // View vector is from the point to the camera, but we want to raymarch from camera to point, so reverse the sign
    // The length of viewDirTS vector determines the furthest amount of displacement:
    // real parallaxLimit = -length(viewDirTS.xy) / viewDirTS.z;
    // real2 parallaxDir = normalize(Out.viewDirTS.xy);
    // real2 parallaxMaxOffsetTS = parallaxDir * parallaxLimit;
    // Above code simplify to
    real2 parallaxMaxOffsetTS = (viewDirTS.xy / -viewDirTS.z);
    real2 texOffsetPerStep = stepSize * parallaxMaxOffsetTS;

    // Do a first step before the loop to init all value correctly
    real2 texOffsetCurrent = real2(0.0, 0.0);
    real prevHeight = ComputePerPixelHeightDisplacement(texOffsetCurrent, lod, blendMasks, layerTexCoord);
    texOffsetCurrent += texOffsetPerStep;
    real currHeight = ComputePerPixelHeightDisplacement(texOffsetCurrent, lod, blendMasks, layerTexCoord);
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
        currHeight = ComputePerPixelHeightDisplacement(texOffsetCurrent, lod, blendMasks, layerTexCoord);
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

        currHeight = ComputePerPixelHeightDisplacement(offset, lod, blendMasks, layerTexCoord);

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

    //real pt0 = rayHeight + stepSize;
    //real pt1 = rayHeight;
    //real delta0 = pt0 - prevHeight;
    //real delta1 = pt1 - currHeight;
    //real intersectionHeight = (pt0 * delta1 - pt1 * delta0) / (delta1 - delta0);
    //real2 offset = (1 - intersectionHeight) * texOffsetPerStep * numSteps;

    // A bit more optimize
    real delta0 = currHeight - rayHeight;
    real delta1 = (rayHeight + stepSize) - prevHeight;
    real ratio = delta0 / (delta0 + delta1);
    real2 offset = texOffsetCurrent - ratio * texOffsetPerStep;

    currHeight = ComputePerPixelHeightDisplacement(offset, lod, layerTexCoord);

#endif

    // Fade the effect with lod (allow to avoid pop when switching to a discrete LOD mesh)
    offset *= (1.0 - saturate(lod - lodThreshold));

    return offset;
}

real clampNdotV(real NdotV)
{
    return max(NdotV, 0.0001); // Approximately 0.0057 degree bias
}

real ApplyPerPixelDisplacement(real3 viewDirTS, inout LayerTexCoord layerTexCoord, real4 blendMasks)
{
    float2 minUvSize = GetMinUvSize(layerTexCoord);
    real lod = ComputeTextureLOD(minUvSize);

    real  maxHeight0 = abs(_HeightAmplitude);
    real  maxHeight1 = abs(_HeightAmplitude1);
    real  maxHeight2 = abs(_HeightAmplitude2);
    real  maxHeight3 = abs(_HeightAmplitude3);

    ApplyDisplacementTileScale(maxHeight0, maxHeight1, maxHeight2, maxHeight3);
#if defined(_MAIN_LAYER_INFLUENCE_MODE) && defined(_HEIGHTMAP)
    maxHeight1 += abs(_HeightAmplitude) * _InheritBaseHeight1;
    maxHeight2 += abs(_HeightAmplitude) * _InheritBaseHeight2;
    maxHeight3 += abs(_HeightAmplitude) * _InheritBaseHeight3;
#endif

    real weights[_MAX_LAYER];
    ComputeMaskWeights(blendMasks, weights);
    real maxHeight = BlendLayeredScalar(maxHeight0, maxHeight1, maxHeight2, maxHeight3, weights);

    /*float2 worldScale0 = (isPlanar || isTriplanar) ? _TexWorldScale0.xx : _InvPrimScale.xy;
    float2 worldScale1 = (isPlanar || isTriplanar) ? _TexWorldScale1.xx : _InvPrimScale.xy;
    float2 worldScale2 = (isPlanar || isTriplanar) ? _TexWorldScale2.xx : _InvPrimScale.xy;
    float2 worldScale3 = (isPlanar || isTriplanar) ? _TexWorldScale3.xx : _InvPrimScale.xy;*/

    /*ppdParam.uvSpaceScale[0] = _BaseMap_ST.xy /* worldScale0;// *maxHeight0;
    ppdParam.uvSpaceScale[1] = _BaseMap1_ST.xy /* worldScale1;// *maxHeight1;
    ppdParam.uvSpaceScale[2] = _BaseMap2_ST.xy /* worldScale2;// *maxHeight2;
    ppdParam.uvSpaceScale[3] = _BaseMap3_ST.xy /* worldScale3;// *maxHeight3;*/

    float2 uvSpaceScale = BlendLayeredVector2(_BaseMap_ST.xy, _BaseMap1_ST.xy, _BaseMap2_ST.xy, _BaseMap3_ST.xy, weights);

    float2 scaleOffsetDetails0 = _DetailMap_ST.xy;
    float2 scaleOffsetDetails1 = _DetailMap1_ST.xy;
    float2 scaleOffsetDetails2 = _DetailMap2_ST.xy;
    float2 scaleOffsetDetails3 = _DetailMap3_ST.xy;

    real height;
    real NdotV;

    NdotV = viewDirTS.z;

    real3 viewDirUV = normalize(real3(viewDirTS.xy * maxHeight, viewDirTS.z));
    real  unitAngle = saturate(FastACosPos(viewDirUV.z) * INV_HALF_PI);            // TODO: optimize
    int    numSteps = (int)lerp(_PPDMinSamples, _PPDMaxSamples, unitAngle);
    float2 offset = ParallaxOcclusionMapping(lod, _PPDLodThreshold, numSteps, viewDirUV, blendMasks, layerTexCoord);
    offset *= uvSpaceScale;

    layerTexCoord.baseUV0 += offset;
    layerTexCoord.baseUV1 += offset;
    layerTexCoord.baseUV2 += offset;
    layerTexCoord.baseUV3 += offset;

    layerTexCoord.detailUV0 += offset * scaleOffsetDetails0;
    layerTexCoord.detailUV1 += offset * scaleOffsetDetails1;
    layerTexCoord.detailUV2 += offset * scaleOffsetDetails2;
    layerTexCoord.detailUV3 += offset * scaleOffsetDetails3;

    // Since POM "pushes" geometry inwards (rather than extrude it), { height = height - 1 }.
    // Since the result is used as a 'depthOffsetVS', it needs to be positive, so we flip the sign. { height = -height + 1 }.

    real verticalDisplacement = maxHeight - height * maxHeight;
    return verticalDisplacement / clampNdotV(NdotV);
}

// Calculate displacement for per vertex displacement mapping
real3 ComputePerVertexDisplacement(LayerTexCoord layerTexCoord, real4 vertexColor, real lod)
{
    real height0 = (SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, layerTexCoord.baseUV0, lod).r - _HeightCenter) * _HeightAmplitude;
    real height1 = (SAMPLE_TEXTURE2D_LOD(_HeightMap1, sampler_HeightMap, layerTexCoord.baseUV1, lod).r - _HeightCenter1) * _HeightAmplitude1;
    real height2 = (SAMPLE_TEXTURE2D_LOD(_HeightMap2, sampler_HeightMap, layerTexCoord.baseUV2, lod).r - _HeightCenter2) * _HeightAmplitude2;
    real height3 = (SAMPLE_TEXTURE2D_LOD(_HeightMap3, sampler_HeightMap, layerTexCoord.baseUV3, lod).r - _HeightCenter3) * _HeightAmplitude3;

    // Scale by lod factor to ensure tessellated displacement influence is fully removed by the time we transition LODs
#if defined(LOD_FADE_CROSSFADE) && defined(_TESSELLATION_DISPLACEMENT)
    height0 *= unity_LODFade.x;
    height1 *= unity_LODFade.x;
    height2 *= unity_LODFade.x;
    height3 *= unity_LODFade.x;
#endif

    // Height is affected by tiling property and by object scale (depends on option).
    // Apply scaling from tiling properties (TexWorldScale and tiling from BaseColor)
    ApplyDisplacementTileScale(height0, height1, height2, height3);
    // Nullify height that are not used, so compiler can remove unused case
    SetEnabledHeightByLayer(height0, height1, height2, height3);

    real4 blendMasks = GetBlendMask(_LayerMaskMap, sampler_LayerMaskMap, layerTexCoord.layerMaskUV, vertexColor);

    #if defined(_HEIGHT_BASED_BLEND)
    // Modify blendMask to take into account the height of the layer. Higher height should be more visible.
    blendMasks = ApplyHeightBlend(half4(height0, height1, height2, height3), blendMasks, _HeightTransition);
    #endif

    real weights[_MAX_LAYER];
    ComputeMaskWeights(blendMasks, weights);

    // _MAIN_LAYER_INFLUENCE_MODE is a pure visual mode that doesn't contribute to the weights of a layer
    // The motivation is like this: if a layer is visible, then we will apply influence on top of it (so it is only visual).
    // This is what is done for normal and baseColor and we do the same for height.
    // Note that if we apply influence before ApplyHeightBlend, then have a different behavior.
#if defined(_MAIN_LAYER_INFLUENCE_MODE) && defined(_HEIGHTMAP)
    // Add main layer influence if any (simply add main layer add on other layer)
    // We multiply by the input mask for the first layer (blendMask.a) because if the mask here is black it means that the layer
    // is not actually underneath any visible layer so we don't want to inherit its height.
    real influenceMask = blendMasks.a;
    #ifdef _INFLUENCEMASK_MAP
    influenceMask *= GetInfluenceMask(layerTexCoord, true, lod);
    #endif
    height1 += height0 * _InheritBaseHeight1 * influenceMask;
    height2 += height0 * _InheritBaseHeight2 * influenceMask;
    height3 += height0 * _InheritBaseHeight3 * influenceMask;
#endif

    real heightResult = BlendLayeredScalar(height0, height1, height2, height3, weights);

   // Applying scaling of the object if requested
    #ifdef _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
    real3 objectScale = GetDisplacementObjectScale(true);
    // Reminder: mappingType is know statically, so code below is optimize by the compiler
    // Planar and Triplanar are in world space thus it is independent of object scale
    return heightResult.xxx * objectScale;
    #else
    return heightResult.xxx;
    #endif
}

inline void InitializeTexCoordinates(in real2 uv, out LayerTexCoord layerTexCoord)
{
    layerTexCoord.layerMaskUV = TRANSFORM_TEX(uv, _LayerMaskMap);
    layerTexCoord.baseUV0     = TRANSFORM_TEX(uv, _BaseMap);
    layerTexCoord.baseUV1     = TRANSFORM_TEX(uv, _BaseMap1);
    layerTexCoord.baseUV2     = TRANSFORM_TEX(uv, _BaseMap2);
    layerTexCoord.baseUV3     = TRANSFORM_TEX(uv, _BaseMap3);

    layerTexCoord.detailUV0   = TRANSFORM_TEX(uv, _DetailMap);
    layerTexCoord.detailUV1   = TRANSFORM_TEX(uv, _DetailMap1);
    layerTexCoord.detailUV2   = TRANSFORM_TEX(uv, _DetailMap2);
    layerTexCoord.detailUV3   = TRANSFORM_TEX(uv, _DetailMap3);

    layerTexCoord.emissionUV  = TRANSFORM_TEX(uv, _EmissionMap);
}

#ifdef TESSELLATION_ON
#include "ShaderLibrary/Tessellation.hlsl"
#endif

#endif