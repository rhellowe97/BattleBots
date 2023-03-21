#ifndef UNIVERSAL_SURFACE_DATA_INCLUDED
#define UNIVERSAL_SURFACE_DATA_INCLUDED
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half  anisotropy;
    half3 normalTS;
    half3 bentNormalTS;
    half3 tangentTS;
    half  clearCoatMask;
    half  clearCoatSmoothness;
    half3 coatNormalTS;

    half3 iridescenceTMS; // Iridescence Thickness/Mask/Shift

    half  thickness;
    half  curvature;

    half3 scatteringColor;
    half3 scatteringShadowsColor;
    half  transmissionScale;

    half  translucencyPower;
    half  translucencyScale;
    half  translucencyAmbient;
    half  translucencyDistortion;
    half  translucencyShadows;

    half3 emission;
    half  occlusion;
    half  alpha;

    half3 geomNormalWS;
    half  horizonFade;

    half giOcclusionBias;
};
#endif
