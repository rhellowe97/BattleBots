void InitializeLayeredData(LayerTexCoord layerTexCoord, out LayeredData layeredData)
{
    layeredData.baseColor0 = _BaseColor * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, layerTexCoord.baseUV0);
    layeredData.baseColor1 = _BaseColor1 * SAMPLE_TEXTURE2D(_BaseMap1, sampler_BaseMap, layerTexCoord.baseUV1);
    layeredData.baseColor2 = _BaseColor2 * SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap, layerTexCoord.baseUV2);
    layeredData.baseColor3 = _BaseColor3 * SAMPLE_TEXTURE2D(_BaseMap3, sampler_BaseMap, layerTexCoord.baseUV3);

    layeredData.maskMap0 = half4(_Metallic, 1.0, 1.0, _Smoothness);
    layeredData.maskMap1 = half4(_Metallic1, 1.0, 1.0, _Smoothness1);
    layeredData.maskMap2 = half4(_Metallic2, 1.0, 1.0, _Smoothness2);
    layeredData.maskMap3 = half4(_Metallic3, 1.0, 1.0, _Smoothness3);

    layeredData.normalMap0 = half3(0.0h, 0.0h, 1.0h);
    layeredData.normalMap1 = half3(0.0h, 0.0h, 1.0h);
    layeredData.normalMap2 = half3(0.0h, 0.0h, 1.0h);
    layeredData.normalMap3 = half3(0.0h, 0.0h, 1.0h);
    
    layeredData.bentNormalMap0 = half3(0.0h, 0.0h, 1.0h);
    layeredData.bentNormalMap1 = half3(0.0h, 0.0h, 1.0h);
    layeredData.bentNormalMap2 = half3(0.0h, 0.0h, 1.0h);
    layeredData.bentNormalMap3 = half3(0.0h, 0.0h, 1.0h);

#ifdef _MASKMAP
    layeredData.maskMap0 = LayeredMaskMapping(TEXTURE2D_ARGS(_MaskMap, sampler_MaskMap), layerTexCoord.baseUV0, half2(_MetallicRemapMin, _MetallicRemapMax), half2(_AORemapMin, _AORemapMax), half2(_SmoothnessRemapMin, _SmoothnessRemapMax));
#endif

#ifdef _MASKMAP1
    layeredData.maskMap1 = LayeredMaskMapping(TEXTURE2D_ARGS(_MaskMap1, sampler_MaskMap1), layerTexCoord.baseUV1, half2(_MetallicRemapMin1, _MetallicRemapMax1), half2(_AORemapMin1, _AORemapMax1), half2(_SmoothnessRemapMin1, _SmoothnessRemapMax1));
#endif

#ifdef _MASKMAP2
    layeredData.maskMap2 = LayeredMaskMapping(TEXTURE2D_ARGS(_MaskMap2, sampler_MaskMap2), layerTexCoord.baseUV2, half2(_MetallicRemapMin2, _MetallicRemapMax2), half2(_AORemapMin2, _AORemapMax2), half2(_SmoothnessRemapMin2, _SmoothnessRemapMax2));
#endif

#ifdef _MASKMAP3
    layeredData.maskMap3 = LayeredMaskMapping(TEXTURE2D_ARGS(_MaskMap3, sampler_MaskMap3), layerTexCoord.baseUV3, half2(_MetallicRemapMin3, _MetallicRemapMax3), half2(_AORemapMin1, _AORemapMax3), half2(_SmoothnessRemapMin3, _SmoothnessRemapMax3));
#endif

    layeredData.heightMap0 = (SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, layerTexCoord.baseUV0, 1).r - _HeightCenter) * _HeightAmplitude;
    layeredData.heightMap1 = (SAMPLE_TEXTURE2D_LOD(_HeightMap1, sampler_HeightMap, layerTexCoord.baseUV0, 1).r - _HeightCenter1) * _HeightAmplitude1;
    layeredData.heightMap2 = (SAMPLE_TEXTURE2D_LOD(_HeightMap2, sampler_HeightMap, layerTexCoord.baseUV0, 1).r - _HeightCenter2) * _HeightAmplitude2;
    layeredData.heightMap3 = (SAMPLE_TEXTURE2D_LOD(_HeightMap3, sampler_HeightMap, layerTexCoord.baseUV0, 1).r - _HeightCenter3) * _HeightAmplitude3;

#ifdef _NORMALMAP
    layeredData.normalMap0 = SampleNormal(layerTexCoord.baseUV0, TEXTURE2D_ARGS(_NormalMap, sampler_NormalMap), _NormalScale);
#endif
#ifdef _NORMALMAP1
    layeredData.normalMap1 = SampleNormal(layerTexCoord.baseUV1, TEXTURE2D_ARGS(_NormalMap1, sampler_NormalMap1), _NormalScale1);   
#endif
#ifdef _NORMALMAP2
    layeredData.normalMap2 = SampleNormal(layerTexCoord.baseUV2, TEXTURE2D_ARGS(_NormalMap2, sampler_NormalMap2), _NormalScale2);
#endif
#ifdef _NORMALMAP3
    layeredData.normalMap3 = SampleNormal(layerTexCoord.baseUV3, TEXTURE2D_ARGS(_NormalMap3, sampler_NormalMap3), _NormalScale3);
#endif

#if defined(_NORMALMAP)  && defined(_BENTNORMALMAP) 
    layeredData.bentNormalMap0 = SampleNormal(layerTexCoord.baseUV0, TEXTURE2D_ARGS(_BentNormalMap, sampler_NormalMap), _NormalScale);
#endif
#if defined(_NORMALMAP1)  && defined(_BENTNORMALMAP1) 
    layeredData.bentNormalMap1 = SampleNormal(layerTexCoord.baseUV1, TEXTURE2D_ARGS(_BentNormalMap1, sampler_NormalMap1), _NormalScale1);
#endif
#if defined(_NORMALMAP2)  && defined(_BENTNORMALMAP2) 
    layeredData.bentNormalMap2 = SampleNormal(layerTexCoord.baseUV2, TEXTURE2D_ARGS(_BentNormalMap2, sampler_NormalMap2), _NormalScale2); 
#endif
#if defined(_NORMALMAP3)  && defined(_BENTNORMALMAP3) 
    layeredData.bentNormalMap3 = SampleNormal(layerTexCoord.baseUV3, TEXTURE2D_ARGS(_BentNormalMap3, sampler_NormalMap3), _NormalScale3);
#endif
}


void CalculateLayeredDetailMap(LayeredData layeredData, LayerTexCoord layerTexCoord, inout half3 albedo, inout half3 normalTS, inout half smoothness, real weights[_MAX_LAYER])
{
    #ifdef _DETAIL_MAP
        half4   detailMap0 = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, layerTexCoord.detailUV0);
        half3   detailNormal0 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap0.g, detailMap0.a, 1.0h, 1.0h))), _DetailNormalScale);

        albedo = DetailAlbedo(albedo, detailMap0.r, layeredData.maskMap0.b * weights[0], _DetailAlbedoScale);
        normalTS = DetailNormals(normalTS, detailNormal0, layeredData.maskMap0.b * weights[0]);
        smoothness = DetailSmoothness(smoothness, detailMap0.b, _DetailSmoothnessScale, layeredData.maskMap0.b * weights[0]);
    #endif

    #ifdef _DETAIL_MAP1
        half4   detailMap1 = SAMPLE_TEXTURE2D(_DetailMap1, sampler_DetailMap1, layerTexCoord.detailUV1);
        half3   detailNormal1 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap1.g, detailMap1.a, 1.0h, 1.0h))), _DetailNormalScale1);

        albedo = DetailAlbedo(albedo, detailMap1.r, layeredData.maskMap0.b * weights[1], _DetailAlbedoScale1);
        normalTS = DetailNormals(normalTS, detailNormal1, layeredData.maskMap1.b * weights[1]);
        smoothness = DetailSmoothness(smoothness, detailMap1.b, _DetailSmoothnessScale1, layeredData.maskMap0.b * weights[1]);
    #endif

    #ifdef _DETAIL_MAP2
        half4   detailMap2 = SAMPLE_TEXTURE2D(_DetailMap2, sampler_DetailMap2, layerTexCoord.detailUV2);
        half3   detailNormal2 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap2.g, detailMap2.a, 1.0h, 1.0h))), _DetailNormalScale2);

        albedo = DetailAlbedo(albedo, detailMap2.r, layeredData.maskMap0.b * weights[2], _DetailAlbedoScale2);
        normalTS = DetailNormals(normalTS, detailNormal2, layeredData.maskMap2.b * weights[2]);
        smoothness = DetailSmoothness(smoothness, detailMap2.b, _DetailSmoothnessScale2, layeredData.maskMap0.b * weights[2]);
    #endif

    #ifdef _DETAIL_MAP3
        half4   detailMap3 = SAMPLE_TEXTURE2D(_DetailMap3, sampler_DetailMap3, layerTexCoord.detailUV3);
        half3   detailNormal3 = BumpStrength(normalize(UnpackNormalmapRGorAG(half4(detailMap3.g, detailMap3.a, 1.0h, 1.0h))), _DetailNormalScale3);

        albedo = DetailAlbedo(albedo, detailMap3.r, layeredData.maskMap0.b * weights[3], _DetailAlbedoScale3);
        normalTS = DetailNormals(normalTS, detailNormal3, layeredData.maskMap3.b * weights[3]);
        smoothness = DetailSmoothness(smoothness, detailMap3.b, _DetailSmoothnessScale3, layeredData.maskMap0.b * weights[3]);
    #endif
}