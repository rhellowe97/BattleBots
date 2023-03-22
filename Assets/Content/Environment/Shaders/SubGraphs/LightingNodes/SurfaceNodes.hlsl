real RoughnessToPerceptualSmoothness(real roughness)
{
    return 1.0 - sqrt(roughness);
}

real PerceptualSmoothnessToRoughness(real perceptualSmoothness)
{
    return (1.0 - perceptualSmoothness) * (1.0 - perceptualSmoothness);
}

float NormalFiltering(float perceptualSmoothness, float variance, float threshold)
{
    float roughness = PerceptualSmoothnessToRoughness(perceptualSmoothness);
    // Ref: Geometry into Shading - http://graphics.pixar.com/library/BumpRoughness/paper.pdf - equation (3)
    float squaredRoughness = saturate(roughness * roughness + min(2.0 * variance, threshold * threshold)); // threshold can be really low, square the value for easier control

    return RoughnessToPerceptualSmoothness(sqrt(squaredRoughness));
}

float ProjectedSpaceNormalFiltering(float perceptualSmoothness, float variance, float threshold)
{
    float roughness = PerceptualSmoothnessToRoughness(perceptualSmoothness);
    // Ref: Stable Geometric Specular Antialiasing with Projected-Space NDF Filtering - https://yusuketokuyoshi.com/papers/2021/Tokuyoshi2021SAA.pdf
    float squaredRoughness = roughness * roughness;
    float projRoughness2 = squaredRoughness / (1.0 - squaredRoughness);
    float filteredProjRoughness2 = saturate(projRoughness2 + min(2.0 * variance, threshold * threshold));
    squaredRoughness = filteredProjRoughness2 / (filteredProjRoughness2 + 1.0f);

    return RoughnessToPerceptualSmoothness(sqrt(squaredRoughness));
}

// Reference: Error Reduction and Simplification for Shading Anti-Aliasing
// Specular antialiasing for geometry-induced normal (and NDF) variations: Tokuyoshi / Kaplanyan et al.'s method.
// This is the deferred approximation, which works reasonably well so we keep it for forward too for now.
// screenSpaceVariance should be at most 0.5^2 = 0.25, as that corresponds to considering
// a gaussian pixel reconstruction kernel with a standard deviation of 0.5 of a pixel, thus 2 sigma covering the whole pixel.
float GeometricNormalVariance(float3 geometricNormalWS, float screenSpaceVariance)
{
    float3 deltaU = ddx(geometricNormalWS);
    float3 deltaV = ddy(geometricNormalWS);

    return screenSpaceVariance * (dot(deltaU, deltaU) + dot(deltaV, deltaV));
}

// Return modified perceptualSmoothness
void GeometricNormalFiltering_half(real perceptualSmoothness, real3 geometricNormalWS, real screenSpaceVariance, real threshold, out real Out)
{
    real variance = GeometricNormalVariance(geometricNormalWS, screenSpaceVariance);
    Out = NormalFiltering(perceptualSmoothness, variance, threshold);
}

void ProjectedSpaceGeometricNormalFiltering_half(real perceptualSmoothness, real3 geometricNormalWS, real screenSpaceVariance, real threshold, out real Out)
{
    real variance = GeometricNormalVariance(geometricNormalWS, screenSpaceVariance);
    Out = ProjectedSpaceNormalFiltering(perceptualSmoothness, variance, threshold);
}