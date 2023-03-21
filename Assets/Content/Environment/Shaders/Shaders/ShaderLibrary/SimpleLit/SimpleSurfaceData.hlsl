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
    half horizonFade;
    half  alpha;
    half  clearCoatMask;
    half  clearCoatSmoothness;

    half3 geomNormalWS;
};
#endif
