#include "ShaderLibrary/TessStructures.hlsl"
#if defined(META_PASS_VARYINGS)
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
#endif

//ref: https://catlikecoding.com/unity/tutorials/advanced-rendering/surface-displacement/
//ref: https://catlikecoding.com/unity/tutorials/advanced-rendering/tessellation/
//ref: https://gist.github.com/NedMakesGames/808a04367e60947a7966976f918081b2

#if defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
// AMD recommand this value for GCN http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/05/GCNPerformanceTweets.pdf
#define MAX_TESSELLATION_FACTORS 15.0
#else
#define MAX_TESSELLATION_FACTORS 64.0
#endif

#if defined(SHADOW_PASS_VARYINGS)
    real3 _LightDirection;
#endif

struct TessellationFactors
{
    real edge[3] : SV_TessFactor;
    real inside : SV_InsideTessFactor;
};

bool TriangleIsBelowClipPlane (real3 p0, real3 p1, real3 p2, int planeIndex, real bias) 
{
	real4 plane = unity_CameraWorldClipPlanes[planeIndex];
	return
		dot(real4(p0, 1), plane) < bias &&
		dot(real4(p1, 1), plane) < bias &&
		dot(real4(p2, 1), plane) < bias;
}

bool TriangleIsCulled (real3 p0, real3 p1, real3 p2, real bias) 
{
	return
		TriangleIsBelowClipPlane(p0, p1, p2, 0, bias) ||
		TriangleIsBelowClipPlane(p0, p1, p2, 1, bias) ||
		TriangleIsBelowClipPlane(p0, p1, p2, 2, bias) ||
		TriangleIsBelowClipPlane(p0, p1, p2, 3, bias);
}

real3 GetDistanceBasedTessFactor(real3 p0, real3 p1, real3 p2, real3 cameraPosWS, real tessMinDist, real tessMaxDist)
{
    real3 edgePosition0 = 0.5 * (p1 + p2);
    real3 edgePosition1 = 0.5 * (p0 + p2);
    real3 edgePosition2 = 0.5 * (p0 + p1);

    // In case camera-relative rendering is enabled, 'cameraPosWS' is statically known to be 0,
    // so the compiler will be able to optimize distance() to length().
    real dist0 = distance(edgePosition0, cameraPosWS);
    real dist1 = distance(edgePosition1, cameraPosWS);
    real dist2 = distance(edgePosition2, cameraPosWS);

    // The saturate will handle the produced NaN in case min == max
    real fadeDist = tessMaxDist - tessMinDist;
    real3 tessFactor;
    tessFactor.x = saturate(1.0 - (dist0 - tessMinDist) / fadeDist);
    tessFactor.y = saturate(1.0 - (dist1 - tessMinDist) / fadeDist);
    tessFactor.z = saturate(1.0 - (dist2 - tessMinDist) / fadeDist);

    return tessFactor;
}

real TessellationEdgeFactor(real3 p0, real3 p1) 
{
	real edgeLength = distance(p0, p1);
	real3 edgeCenter = (p0 + p1) * 0.5;
	real viewDistance = distance(edgeCenter, _WorldSpaceCameraPos);
	real tessFactor = edgeLength * _ScreenParams.y / (_TessellationEdgeLength * viewDistance);
    return min(tessFactor, _TessellationFactor);
}

real3 ProjectPointOnPlane(real3 position, real3 planePosition, real3 planeNormal)
{
    return position - (dot(position - planePosition, planeNormal) * planeNormal);
}

real3 PhongTessellation(real3 positionWS, real3 p0, real3 p1, real3 p2, real3 n0, real3 n1, real3 n2, real3 baryCoords, real shape)
{
    real3 c0 = ProjectPointOnPlane(positionWS, p0, n0);
    real3 c1 = ProjectPointOnPlane(positionWS, p1, n1);
    real3 c2 = ProjectPointOnPlane(positionWS, p2, n2);

    real3 phongPositionWS = baryCoords.x * c0 + baryCoords.y * c1 + baryCoords.z * c2;

    return lerp(positionWS, phongPositionWS, shape);
}

TessellationFactors HullConstant(InputPatch<TessellationControlPoint, 3> input)
{
    real3 p0 = mul(unity_ObjectToWorld, input[0].positionOS).xyz;
    real3 p1 = mul(unity_ObjectToWorld, input[1].positionOS).xyz;
    real3 p2 = mul(unity_ObjectToWorld, input[2].positionOS).xyz;

    TessellationFactors f;
    real bias = 0;
    #ifdef _TESSELLATION_DISPLACEMENT
		bias = _TessellationBackFaceCullEpsilon * _HeightAmplitude;
	#endif
	if (TriangleIsCulled(p0, p1, p2, bias)) 
    {
        f.edge[0] = f.edge[1] = f.edge[2] = f.inside = 0; // Cull the input
    } 
    else 
    {
        real3 tf = real3(_TessellationFactor, _TessellationFactor, _TessellationFactor);
        #if defined(_TESSELLATION_EDGE)
            tf = real3(TessellationEdgeFactor(p1, p2), TessellationEdgeFactor(p2, p0), TessellationEdgeFactor(p0, p1));
        #elif defined(_TESSELLATION_DISTANCE)
            real3 distFactor = GetDistanceBasedTessFactor(p0, p1, p2, _WorldSpaceCameraPos, _TessellationFactorMinDistance, _TessellationFactorMaxDistance);
            tf *= distFactor * distFactor;
        #endif
        tf = max(tf, real3(1.0, 1.0, 1.0));

        f.edge[0] = min(tf.x, MAX_TESSELLATION_FACTORS);
        f.edge[1] = min(tf.y, MAX_TESSELLATION_FACTORS);
        f.edge[2] = min(tf.z, MAX_TESSELLATION_FACTORS);

        f.inside = (f.edge[0] + f.edge[1] + f.edge[2]) / 3.0;
    }
    
	return f;
}

// ref: http://reedbeta.com/blog/tess-quick-ref/
[maxtessfactor(MAX_TESSELLATION_FACTORS)]
[domain("tri")]
[partitioning("fractional_odd")]
[outputtopology("triangle_cw")]
[patchconstantfunc("HullConstant")]
[outputcontrolpoints(3)]
TessellationControlPoint Hull(InputPatch<TessellationControlPoint, 3> input, uint id : SV_OutputControlPointID)
{
    // Pass-through
    return input[id];
}

#define BARYCENTRIC_INTERPOLATE(fieldName) \
        input[0].fieldName * baryCoords.x + \
        input[1].fieldName * baryCoords.y + \
        input[2].fieldName * baryCoords.z

[domain("tri")]
Varyings Domain(TessellationFactors tessFactors, const OutputPatch<TessellationControlPoint, 3> input, real3 baryCoords : SV_DomainLocation)
{
    Varyings output = (Varyings)0;
    Attributes data = (Attributes)0;

    UNITY_SETUP_INSTANCE_ID(input[0]);
#if defined(BASE_PASS_VARYINGS) || defined(DEPTH_PASS_VARYINGS) || defined(DEPTH_NORMALS_PASS_VARYINGS)
    UNITY_TRANSFER_INSTANCE_ID(input[0], output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
#endif

    data.positionOS = BARYCENTRIC_INTERPOLATE(positionOS); 
    data.normalOS = BARYCENTRIC_INTERPOLATE(normalOS);
#if !defined(META_PASS_VARYINGS)
    data.texcoord = BARYCENTRIC_INTERPOLATE(texcoord);
#else
    data.uv0 = BARYCENTRIC_INTERPOLATE(uv0);
    data.uv1 = BARYCENTRIC_INTERPOLATE(uv1);
    data.uv2 = BARYCENTRIC_INTERPOLATE(uv2);
#endif

#if defined(BASE_PASS_VARYINGS) || defined(DEPTH_NORMALS_PASS_VARYINGS) || (defined(META_PASS_VARYINGS) && defined(_TANGENT_TO_WORLD))
    data.tangentOS = BARYCENTRIC_INTERPOLATE(tangentOS);
#endif

#if defined(BASE_PASS_VARYINGS)
    data.staticLightmapUV = BARYCENTRIC_INTERPOLATE(staticLightmapUV);
    #ifdef DYNAMICLIGHTMAP_ON
    data.dynamicLightmapUV = BARYCENTRIC_INTERPOLATE(dynamicLightmapUV);
    #endif
#endif

#if defined(_VERTEX_COLOR)
    data.vertexColor = BARYCENTRIC_INTERPOLATE(vertexColor);
#endif

#if defined(_TESSELLATION_PHONG)
    real3 p0 = TransformObjectToWorld(input[0].positionOS.xyz);
    real3 p1 = TransformObjectToWorld(input[1].positionOS.xyz);
    real3 p2 = TransformObjectToWorld(input[2].positionOS.xyz);

    real3 n0 = TransformObjectToWorldNormal(input[0].normalOS);
    real3 n1 = TransformObjectToWorldNormal(input[1].normalOS);
    real3 n2 = TransformObjectToWorldNormal(input[2].normalOS);
    real3 positionWS = TransformObjectToWorld(data.positionOS.xyz);

    positionWS = PhongTessellation(positionWS, p0, p1, p2, n0, n1, n2, baryCoords, _TessellationShapeFactor);
    data.positionOS = mul(unity_WorldToObject, real4(positionWS, 1.0));
#endif

#if defined(META_PASS_VARYINGS)
    real2 uv = TRANSFORM_TEX(data.uv0, _BaseMap);
#else
    real2 uv = TRANSFORM_TEX(data.texcoord, _BaseMap);
#endif

    VertexPositionInputs vertexInput = GetVertexPositionInputs(data.positionOS.xyz);
#if defined(BASE_PASS_VARYINGS) || defined(DEPTH_NORMALS_PASS_VARYINGS)
    VertexNormalInputs normalInput = GetVertexNormalInputs(data.normalOS, data.tangentOS);
#else
    VertexNormalInputs normalInput = GetVertexNormalInputs(data.normalOS);
#endif

#if defined(_VERTEX_COLOR)
    half4 vertexColor = data.vertexColor;
#else
    half4 vertexColor = half4(1.0, 1.0, 1.0, 1.0);
#endif

#ifdef _TESSELLATION_DISPLACEMENT
    #if defined(LAYERED_LIT)
    LayerTexCoord layerTexCoord;
        #if !defined(META_PASS_VARYINGS)
        InitializeTexCoordinates(data.texcoord, layerTexCoord);
        #else
        InitializeTexCoordinates(data.uv0, layerTexCoord);
        #endif

    half3 height = ComputePerVertexDisplacement(layerTexCoord, vertexColor, 1);
    #else
    half3 height = ComputePerVertexDisplacement(_HeightMap, sampler_HeightMap, uv, 1);
    #endif

    vertexInput.positionWS += normalInput.normalWS * height;
#endif

#if defined(LAYERED_LIT) && !defined(META_PASS_VARYINGS)
    output.uv = data.texcoord;
#else
    output.uv = uv;
#endif

#if defined(BASE_PASS_VARYINGS)
    output.normalWS = normalInput.normalWS;
    real3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
    output.viewDirWS = viewDirWS;
    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
    #endif
#endif

//BasePass positionСS
#if defined(BASE_PASS_VARYINGS)
    output.positionCS = TransformWorldToHClip(vertexInput.positionWS);
#endif

//ShadowPass positionСS
#if defined(SHADOW_PASS_VARYINGS)
    output.positionCS = TransformWorldToHClip(ApplyShadowBias(vertexInput.positionWS, normalInput.normalWS, _LightDirection));
    #if UNITY_REVERSED_Z
        output.positionCS.z = min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        output.positionCS.z = max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif
#endif

//DepthPass positionСS
#if defined(DEPTH_PASS_VARYINGS)
    output.positionCS = TransformWorldToHClip(vertexInput.positionWS);
#endif

//DepthNormalsPass positionСS
#if defined(DEPTH_NORMALS_PASS_VARYINGS)
    output.positionCS = TransformWorldToHClip(vertexInput.positionWS);
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
#endif

//MetaPass positionСS
#if defined(META_PASS_VARYINGS)
    output.positionCS = MetaVertexPosition(data.positionOS, data.uv1, data.uv2,
            unity_LightmapST, unity_DynamicLightmapST);
#endif

#if defined(BASE_PASS_VARYINGS) || defined(DEPTH_NORMALS_PASS_VARYINGS)
    #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    real sign = data.tangentOS.w * GetOddNegativeScale();
    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif
#endif

#if defined(_VERTEX_COLOR)
    output.vertexColor = data.vertexColor;
#endif

#if defined(BASE_PASS_VARYINGS)
    #if defined(LIGHTMAP_ON)
    output.staticLightmapUV = data.staticLightmapUV;
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
    output.dynamicLightmapUV = data.dynamicLightmapUV;
    #endif
    OUTPUT_SH(output.normalWS, output.vertexSH);

    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = 0;
    #if !defined(_FOG_FRAGMENT)
    fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
    output.fogFactor = fogFactor;
    #endif
#endif

    return output;
}