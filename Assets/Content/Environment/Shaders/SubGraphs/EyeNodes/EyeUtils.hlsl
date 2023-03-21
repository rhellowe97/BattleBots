#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

void ScleraUVLocation_float(real3 positionOS, out real2 Out)
{
    Out = positionOS.xy + real2(0.5h, 0.5h);
}

void IrisUVLocation_float(real3 positionOS, half irisRadius, out real2 Out)
{
    real2 irisUVCentered = positionOS.xy / irisRadius;
    Out = (irisUVCentered * 0.5h + real2(0.5h, 0.5h));
}

void ScleraOrIris(real3 positionOS, half irisRadius, out half surfaceType)
{
    half osRadius2 = (positionOS.x * positionOS.x + positionOS.y * positionOS.y);
    surfaceType = osRadius2 > (irisRadius * irisRadius) ? 0.0 : 1.0;
}

void CirclePupilAnimation_float(real2 irisUV, half pupilRadius, half pupilAperture, half minimalPupilAperture, half maximalPupilAperture, out real2 Out)
{
    // Compute the normalized iris position
    real2 irisUVCentered = (irisUV - 0.5f) * 2.0f;

    // Compute the radius of the point inside the eye
    half localIrisRadius = length(irisUVCentered);

    // First based on the pupil aperture, let's define the new position of the pupil
    half newPupilRadius = pupilAperture > 0.5 ? lerp(pupilRadius, maximalPupilAperture, (pupilAperture - 0.5) * 2.0) : lerp(minimalPupilAperture, pupilRadius, pupilAperture * 2.0);

    // If we are inside the pupil
    half newIrisRadius = localIrisRadius < newPupilRadius ? ((pupilRadius / newPupilRadius) * localIrisRadius) : 1.0 - ((1.0 - pupilRadius) / (1.0 - newPupilRadius)) * (1.0 - localIrisRadius);
    real2 animatedIrisUV = irisUVCentered / localIrisRadius * newIrisRadius;

    // Convert it back to UV space.
    Out = (animatedIrisUV * 0.5h + half2(0.5h, 0.5h));
}

void CorneaRefraction_float(real3 positionOS, real3 viewDirectionOS, real3 corneaNormalOS, half corneaIOR, half irisPlaneOffset, out real3 Out)
{
    // Compute the refracted
    half eta = 1.0 / (corneaIOR);
    corneaNormalOS = normalize(corneaNormalOS);
    viewDirectionOS = -normalize(viewDirectionOS);
    real3 refractedViewDirectionOS = refract(viewDirectionOS, corneaNormalOS, eta);

    // Find the distance to intersection point
    half t = -(positionOS.z + irisPlaneOffset) / refractedViewDirectionOS.z;

    // Output the refracted point in OS
    Out = real3(refractedViewDirectionOS.z < 0 ? positionOS.xy + refractedViewDirectionOS.xy * t: half2(1.5h, 1.5h), 0.0h);
}

void IrisOutOfBoundColorClamp_float(real2 irisUV, half3 irisColor, half3 colorClamp, out real3 Out)
{
    Out = (irisUV.x < 0.0 || irisUV.y < 0.0 || irisUV.x > 1.0 || irisUV.y > 1.0) ? colorClamp : irisColor;
}

void IrisLimbalRing_half(real2 irisUV, real3 viewOS, half limbalRingSize, half limbalRingFade, half limbalRingItensity, out half Out)
{
    half NdotV = dot(real3(0.0, 0.0, 1.0), viewOS);

    // Compute the normalized iris position
    half2 irisUVCentered = (irisUV - 0.5f) * 2.0f;

    // Compute the radius of the point inside the eye
    half localIrisRadius = length(irisUVCentered);
    half limbalRingFactor = localIrisRadius > (1.0 - limbalRingSize) ? lerp(0.1, 1.0, saturate(1.0 - localIrisRadius) / limbalRingSize) : 1.0;
    limbalRingFactor = PositivePow(limbalRingFactor, limbalRingItensity);
    Out = lerp(limbalRingFactor, PositivePow(limbalRingFactor, limbalRingFade), 1.0 - NdotV);
}

void ScleraLimbalRing_half(real3 positionOS, real3 viewOS, half irisRadius, half limbalRingSize, half limbalRingFade, half limbalRingItensity, out half Out)
{
    half NdotV = dot(real3(0.0, 0.0, 1.0), viewOS);
    // Compute the radius of the point inside the eye
    half scleraRadius = length(positionOS.xy);
    half limbalRingFactor = scleraRadius > irisRadius ? (scleraRadius > (limbalRingSize + irisRadius) ? 1.0 : lerp(0.5, 1.0, (scleraRadius - irisRadius) / (limbalRingSize))) : 1.0;
    limbalRingFactor = PositivePow(limbalRingFactor, limbalRingItensity);
    Out = lerp(limbalRingFactor, PositivePow(limbalRingFactor, limbalRingFade), 1.0 - NdotV);
}

void ScleraIrisBlend_half(half3 scleraColor, half3 scleraNormal, half scleraSmoothness,
                            half3 irisColor, half3 irisNormal, half corneaSmoothness,
                            half irisRadius,
                            real3 positionOS,
                            out half3 eyeColor, out half surfaceMask,
                            out half3 diffuseNormal, out half3 specularNormal, out half eyeSmoothness)
{
    half osRadius = length(positionOS.xy);
    half innerBlendRegionRadius = irisRadius - 0.02;
    half outerBlendRegionRadius = irisRadius + 0.02;
    half blendLerpFactor = 1.0 - (osRadius - irisRadius) / (0.04);
    blendLerpFactor = pow(blendLerpFactor, 8.0);
    blendLerpFactor = 1.0 - blendLerpFactor;
    surfaceMask = (osRadius > outerBlendRegionRadius) ? 0.0 : ((osRadius < irisRadius) ? 1.0 : (lerp(1.0, 0.0, blendLerpFactor)));
    eyeColor = lerp(scleraColor, irisColor, surfaceMask);
    diffuseNormal = lerp(scleraNormal, irisNormal, surfaceMask);
    specularNormal = lerp(scleraNormal, real3(0.0, 0.0, 1.0), surfaceMask);
    eyeSmoothness = lerp(scleraSmoothness, corneaSmoothness, surfaceMask);
}

void DebugSurfaceType_half(half3 positionOS, half3 eyeColor, half irisRadius, half pupilRadius, bool active, out half3 surfaceColor)
{
    half pixelRadius = length(positionOS.xy);
    bool isSclera = pixelRadius > irisRadius;
    bool isPupil = !isSclera && length(positionOS.xy / irisRadius) < pupilRadius;
    surfaceColor = active ? (isSclera ? 0.0 : (isPupil ? 1.0 : eyeColor)) : eyeColor;
}