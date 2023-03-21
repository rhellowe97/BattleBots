#ifndef EYE_UTILS_HLSL
#define EYE_UTILS_HLSL

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

real2 ScleraUVLocation(real3 positionOS)
{
    return positionOS.xy + real2(0.5h, 0.5h);
}

real2 IrisUVLocation(real3 positionOS, half irisRadius)
{
    real2 irisUVCentered = positionOS.xy / irisRadius;
    return (irisUVCentered * 0.5h + real2(0.5h, 0.5h));
}

void ScleraOrIris(real3 positionOS, half irisRadius, out half surfaceType)
{
    half osRadius2 = (positionOS.x * positionOS.x + positionOS.y * positionOS.y);
    surfaceType = osRadius2 > (irisRadius * irisRadius) ? 0.0 : 1.0;
}

real2 CirclePupilAnimation(real2 irusUV, half pupilRadius, half pupilAperture, half minimalPupilAperture, half maximalPupilAperture)
{
    // Compute the normalized iris position
    real2 irisUVCentered = (irusUV - 0.5f) * 2.0f;

    // Compute the radius of the point inside the eye
    half localIrisRadius = length(irisUVCentered);

    // First based on the pupil aperture, let's define the new position of the pupil
    half newPupilRadius = pupilAperture > 0.5 ? lerp(pupilRadius, maximalPupilAperture, (pupilAperture - 0.5) * 2.0) : lerp(minimalPupilAperture, pupilRadius, pupilAperture * 2.0);

    // If we are inside the pupil
    half newIrisRadius = localIrisRadius < newPupilRadius ? ((pupilRadius / newPupilRadius) * localIrisRadius) : 1.0 - ((1.0 - pupilRadius) / (1.0 - newPupilRadius)) * (1.0 - localIrisRadius);
    real2 animatedIrisUV = irisUVCentered / localIrisRadius * newIrisRadius;

    // Convert it back to UV space.
    return (animatedIrisUV * 0.5h + half2(0.5h, 0.5h));
}

real3 CorneaRefraction(real3 positionOS, real3 viewDirectionOS, real3 corneaNormalOS, half corneaIOR, half irisPlaneOffset)
{
    // Compute the refracted
    half eta = 1.0 / (corneaIOR);
    corneaNormalOS = normalize(corneaNormalOS);
    viewDirectionOS = -normalize(viewDirectionOS);
    real3 refractedViewDirectionOS = refract(viewDirectionOS, corneaNormalOS, eta);

    // Find the distance to intersection point
    half t = -(positionOS.z + irisPlaneOffset) / refractedViewDirectionOS.z;

    // Output the refracted point in OS
    return real3(refractedViewDirectionOS.z < 0 ? positionOS.xy + refractedViewDirectionOS.xy * t: half2(1.5h, 1.5h), 0.0h);
}

real3 IrisOutOfBoundColorClamp(half2 irisUV, half3 irisColor, half3 colorClamp)
{
    return (irisUV.x < 0.0 || irisUV.y < 0.0 || irisUV.x > 1.0 || irisUV.y > 1.0) ? colorClamp : irisColor;
}

real2 IrisOffset(half2 irisUV, half2 irisOffset)
{
    return irisUV + irisOffset;
}

half IrisLimbalRing(half2 irisUV, real3 viewOS, half limbalRingSize, half limbalRingFade, half limbalRingItensity)
{
    half NdotV = dot(real3(0.0, 0.0, 1.0), viewOS);

    // Compute the normalized iris position
    half2 irisUVCentered = (irisUV - 0.5f) * 2.0f;

    // Compute the radius of the point inside the eye
    half localIrisRadius = length(irisUVCentered);
    half limbalRingFactor = localIrisRadius > (1.0 - limbalRingSize) ? lerp(0.1, 1.0, saturate(1.0 - localIrisRadius) / limbalRingSize) : 1.0;
    limbalRingFactor = PositivePow(limbalRingFactor, limbalRingItensity);
    return lerp(limbalRingFactor, PositivePow(limbalRingFactor, limbalRingFade), 1.0 - NdotV);
}

half ScleraLimbalRing(real3 positionOS, real3 viewOS, half irisRadius, half limbalRingSize, half limbalRingFade, half limbalRingItensity)
{
    half NdotV = dot(real3(0.0, 0.0, 1.0), viewOS);
    // Compute the radius of the point inside the eye
    half scleraRadius = length(positionOS.xy);
    half limbalRingFactor = scleraRadius > irisRadius ? (scleraRadius > (limbalRingSize + irisRadius) ? 1.0 : lerp(0.5, 1.0, (scleraRadius - irisRadius) / (limbalRingSize))) : 1.0;
    limbalRingFactor = PositivePow(limbalRingFactor, limbalRingItensity);
    return lerp(limbalRingFactor, PositivePow(limbalRingFactor, limbalRingFade), 1.0 - NdotV);
}
#endif // EYE_UTILS_HLSL