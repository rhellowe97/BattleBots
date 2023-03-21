#ifndef UNIVERSAL_SURFACE_DATA_INCLUDED
#define UNIVERSAL_SURFACE_DATA_INCLUDED
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  smoothness;
    half metallic;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half3 specularTint;
    half3 secondarySpecularTint;
    half specularShift;
    half secondarySpecularShift;
    half perceptualSmoothness;
    half secondaryPerceptualSmoothness;
    half3 transmissionColor;
    half transmissionIntensity;

    half clearCoatMask;
    half clearCoatSmoothness;

    half3 geomNormalWS;
};
#endif
