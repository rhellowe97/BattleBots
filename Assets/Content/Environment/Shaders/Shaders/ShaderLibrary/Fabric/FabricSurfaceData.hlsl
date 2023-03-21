#ifndef UNIVERSAL_SURFACE_DATA_INCLUDED
#define UNIVERSAL_SURFACE_DATA_INCLUDED
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  anisotropy;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half  clearCoatMask;
    half  clearCoatSmoothness;

    half3 sheenColor;
    half  sheenSmoothness;
    half  thickness;
    half3 translucencyColor;
    half  translucencyPower;
    half  translucencyScale;
    half  translucencyAmbient;
    half  translucencyDistortion;
    half  translucencyShadows;
};
#endif
