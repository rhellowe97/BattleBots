//BasePass Tessellation Structures
#if defined(BASE_PASS_VARYINGS)
struct Attributes
{
    float4 positionOS         : POSITION;
    float3 normalOS           : NORMAL;
    float4 tangentOS          : TANGENT;
    float2 texcoord           : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
#if defined(_VERTEX_COLOR)
    half4 vertexColor         : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct TessellationControlPoint
{
    float4 positionOS         : INTERNALTESSPOS;
    float3 normalOS           : NORMAL;
    float4 tangentOS          : TANGENT;
    float2 texcoord           : TEXCOORD0;
    float2 staticLightmapUV   : TEXCOORD1;
    float2 dynamicLightmapUV  : TEXCOORD2;
#if defined(_VERTEX_COLOR)
    half4 vertexColor         : COLOR;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS               : TEXCOORD1;
#endif

    half3 normalWS                 : TEXCOORD2;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
#endif
    float3 viewDirWS                : TEXCOORD4;

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    half4 fogFactorAndVertexLight   : TEXCOORD5; // x: fogFactor, yzw: vertex light
#else
    half  fogFactor                 : TEXCOORD5;
#endif

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD6;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS                : TEXCOORD7;
#endif

#if defined(_VERTEX_COLOR)
    half4 vertexColor               : COLOR;
#endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
#ifdef DYNAMICLIGHTMAP_ON
    float2  dynamicLightmapUV : TEXCOORD9; // Dynamic lightmap UVs
#endif

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
#endif

//ShadowPass Tessellation Structures
#if defined(SHADOW_PASS_VARYINGS)
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
#if defined(_VERTEX_COLOR)
    half4 vertexColor               : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct TessellationControlPoint
{
    float4 positionOS : INTERNALTESSPOS;
    float3 normalOS   : NORMAL;
    float2 texcoord   : TEXCOORD0;
    float4 positionCS : SV_POSITION;
#if defined(_VERTEX_COLOR)
    half4 vertexColor : COLOR;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct Varyings
{
    float2 uv                       : TEXCOORD0;
    float4 positionCS               : SV_POSITION;
#if defined(_VERTEX_COLOR)
    half4 vertexColor               : COLOR;
#endif
};
#endif

//DepthPass Tessellation Structures
#if defined(DEPTH_PASS_VARYINGS)
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

struct TessellationControlPoint
{
    float4 positionOS : INTERNALTESSPOS;
    float3 normalOS   : NORMAL;
    float2 texcoord   : TEXCOORD0;
#if defined(_VERTEX_COLOR)
    half4 vertexColor : COLOR;
#endif
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
#endif

//DepthNormalsPass Tessellation Structures
#if defined(DEPTH_NORMALS_PASS_VARYINGS)
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct TessellationControlPoint
{
    float4 positionOS : INTERNALTESSPOS;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float2 texcoord   : TEXCOORD0;
#if defined(_VERTEX_COLOR)
    half4 vertexColor : COLOR;
#endif
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
    float3 normalWS     : TEXCOORD2;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    half4 tangentWS     : TEXCOORD4;    // xyz: tangent, w: sign
#endif
#if defined(_VERTEX_COLOR)
    half4 vertexColor   : COLOR;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
#endif

//MetaPass Tessellation Structures
#if defined(META_PASS_VARYINGS)
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

struct TessellationControlPoint
{
    float4 positionOS   : INTERNALTESSPOS;
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
#endif