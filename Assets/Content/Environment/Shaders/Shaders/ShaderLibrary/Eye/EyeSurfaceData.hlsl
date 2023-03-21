#ifndef UNIVERSAL_SURFACE_DATA_INCLUDED
#define UNIVERSAL_SURFACE_DATA_INCLUDED
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half  surfaceMask;
    half clearCoatMask;
    half clearCoatSmoothness;
};
#endif
