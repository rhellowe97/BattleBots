#define _MAX_LAYER 4
#if defined(_LAYEREDLIT_4_LAYERS)
    #define _LAYER_COUNT 4
#elif defined(_LAYEREDLIT_3_LAYERS)
    #define _LAYER_COUNT 3
#else
    #define _LAYER_COUNT 2
#endif

real BlendLayeredScalar(real x0, real x1, real x2, real x3, real weight[_MAX_LAYER])
{
    real result = 0.0;

    result = x0 * weight[0] + x1 * weight[1];
#if _LAYER_COUNT >= 3
    result += x2 * weight[2];
#endif
#if _LAYER_COUNT >= 4
    result += x3 * weight[3];
#endif

    return result;
}


real2 BlendLayeredVector2(real2 x0, real2 x1, real2 x2, real2 x3, real weight[_MAX_LAYER])
{
    real2 result = real2(0.0, 0.0);

    result = x0 * weight[0] + x1 * weight[1];
#if _LAYER_COUNT >= 3
    result += (x2 * weight[2]);
#endif
#if _LAYER_COUNT >= 4
    result += x3 * weight[3];
#endif

    return result;
}

real3 BlendLayeredVector3(real3 x0, real3 x1, real3 x2, real3 x3, real weight[_MAX_LAYER])
{
    real3 result = real3(0.0, 0.0, 0.0);

    result = x0 * weight[0] + x1 * weight[1];
#if _LAYER_COUNT >= 3
    result += (x2 * weight[2]);
#endif
#if _LAYER_COUNT >= 4
    result += x3 * weight[3];
#endif

    return result;
}

half4 GetBlendMask(Texture2D layerMaskMap, SamplerState samplerState, real2 uv, half4 vertexColor)
{
    half4 blendMasks = SAMPLE_TEXTURE2D_LOD(layerMaskMap, samplerState, uv, 1);
#if defined(_LAYER_MASK_VERTEX_COLOR_MUL)
    blendMasks *= saturate(vertexColor);
#elif defined(_LAYER_MASK_VERTEX_COLOR_ADD)
    blendMasks = saturate(blendMasks + vertexColor * 2.0 - 1.0);
#endif

    return blendMasks;
}

float GetInfluenceMask(LayerTexCoord layerTexCoord, bool useLodSampling = false, float lod = 0)
{
    // Sample influence mask with same mapping as Main layer
    return useLodSampling ? SAMPLE_TEXTURE2D_LOD(_LayerInfluenceMaskMap, sampler_LayerInfluenceMaskMap, layerTexCoord.baseUV0, lod).r : SAMPLE_TEXTURE2D(_LayerInfluenceMaskMap, sampler_LayerInfluenceMaskMap, layerTexCoord.baseUV0).r;
}

half GetMaxHeight(half4 heights)
{
    half maxHeight = max(heights.r, heights.g);
#ifdef _LAYEREDLIT_4_LAYERS
    maxHeight = max(Max3(heights.r, heights.g, heights.b), heights.a);
#endif
#ifdef _LAYEREDLIT_3_LAYERS
    maxHeight = Max3(heights.r, heights.g, heights.b);
#endif

    return maxHeight;
}

half GetMinHeight(half4 heights)
{
    half minHeight = min(heights.r, heights.g);
#ifdef _LAYEREDLIT_4_LAYERS
    minHeight = min(Min3(heights.r, heights.g, heights.b), heights.a);
#endif
#ifdef _LAYEREDLIT_3_LAYERS
    minHeight = Min3(heights.r, heights.g, heights.b);
#endif

    return minHeight;
}

void ComputeMaskWeights(half4 inputMasks, out float outWeights[_MAX_LAYER])
{
    half4 masks;
    masks.r = inputMasks.a;

    masks.g = inputMasks.r;

    #if (_LAYER_COUNT > 2)
        masks.b = inputMasks.g;
    #else
        masks.b = 0.0;
    #endif

    #if (_LAYER_COUNT == 4)
        masks.a = inputMasks.b;
    #else
        masks.a = 0.0;
    #endif

    half weightsSum = 0.0;

    UNITY_UNROLL
    for (int i = _LAYER_COUNT - 1; i >= 0; --i)
    {
        outWeights[i] = min(masks[i], (1.0 - weightsSum));
        weightsSum = saturate(weightsSum + masks[i]);
    }
}

half4 ApplyHeightBlend(half4 heights, half4 blendMask, half heightTransition)
{
    half4 maskedHeights = (heights - GetMinHeight(heights)) * blendMask.argb;

    half maxHeight = GetMaxHeight(maskedHeights);
    half transition = max(heightTransition, 1e-5);

    maskedHeights = maskedHeights - maxHeight.xxxx;

    maskedHeights = (max(0, maskedHeights + transition) + 1e-6) * blendMask.argb;

    maxHeight = GetMaxHeight(maskedHeights);
    maskedHeights = maskedHeights / max(maxHeight.xxxx, 1e-6);

    return saturate(maskedHeights.yzwx);
}


half ApplyScalarHeightBlend(half2 heights, half blendMask, half heightTransition)
{
    half2 maskedHeights = (heights.rg - min(heights.r, heights.g)) * blendMask.xx;

    half maxHeight = max(maskedHeights.r, maskedHeights.g);
    half transition = max(heightTransition, 1e-5);

    maskedHeights = maskedHeights - maxHeight.xx;
    maskedHeights = (max(0, maskedHeights + transition) + 1e-6) * blendMask.xx;


    return saturate(1.0 - maskedHeights.r);
}


void ComputeLayerWeights(half layerCount, half4 heightLayers, half4 inputAlphaMask, half4 blendMasks, half heightTransition, out float outWeights[_MAX_LAYER])
{
    heightTransition *= 0.01;
#if defined(_DENSITY_MODE)
    half4 opacityAsDensity = saturate((inputAlphaMask - (half4(1.0, 1.0, 1.0, 1.0) - blendMasks.argb)) * 20.0); // 20.0 is the number of steps in inputAlphaMask (Density mask. We decided 20 empirically)
    half4 useOpacityAsDensityParam = half4(_OpacityAsDensity0, _OpacityAsDensity1, _OpacityAsDensity2, _OpacityAsDensity3);
    blendMasks.argb = lerp(blendMasks.argb, opacityAsDensity, useOpacityAsDensityParam);
#endif

#if defined(_HEIGHT_BASED_BLEND)
    blendMasks = ApplyHeightBlend(half4(heightLayers.r, heightLayers.g, heightLayers.b, heightLayers.a), blendMasks, heightTransition);
#endif

    ComputeMaskWeights(blendMasks, outWeights);
}

half3 ComputeMainBaseColorInfluence(half influenceMask, half3 baseColor0, half3 baseColor1, half3 baseColor2, half3 baseColor3, 
                                half3 baseMeanColor0, half3 baseMeanColor1, half3 baseMeanColor2, half3 baseMeanColor3, half inputMainLayerMask, half3 baseColorInherit, real weights[_MAX_LAYER])
{
    half3 baseColor = BlendLayeredVector3(baseColor0, baseColor1, baseColor2, baseColor3, weights);

    half influenceFactor = BlendLayeredScalar(0.0, baseColorInherit.x, baseColorInherit.y, baseColorInherit.z, weights) * influenceMask * inputMainLayerMask;

    half3 meanColor = BlendLayeredVector3(baseMeanColor0, baseMeanColor1, baseMeanColor2, baseMeanColor3, weights);

    half3 factor = baseColor > meanColor ? (baseColor0 - meanColor) : (baseColor0 * baseColor / max(meanColor, 0.001) - baseColor);
    
    return influenceFactor * factor + baseColor;
}

half3 ComputeMainNormalInfluence(half influenceMask, half3 normalTS0, half3 normalTS1, half3 normalTS2, half3 normalTS3, half inputMainLayerMask, half3 normalsInherit, real weights[_MAX_LAYER])
{
    half3 normalTS = BlendLayeredVector3(normalTS0, normalTS1, normalTS2, normalTS3, weights);

    half influenceFactor = BlendLayeredScalar(0.0, normalsInherit.x, normalsInherit.y, normalsInherit.z, weights) * influenceMask;

    half3 neutralNormalTS = half3(0.0, 0.0, 1.0);

    half3 mainNormalTS = lerp(neutralNormalTS, normalTS0, influenceFactor);

    return lerp(normalTS, BlendNormalRNM(normalTS, mainNormalTS), influenceFactor * inputMainLayerMask);
}