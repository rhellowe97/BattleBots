//From: CommonLighting.hlsl

// Ref: Horizon Occlusion for Normal Mapped Reflections: http://marmosetco.tumblr.com/post/81245981087
void GetHorizonOcclusion_half(real3 V, real3 normalWS, real3 vertexNormal, real horizonFade, out real Out)
{
    real3 R = reflect(-V, normalWS);
    real specularOcclusion = saturate(1.0 + horizonFade * dot(R, vertexNormal));
    // smooth it
    Out = specularOcclusion * specularOcclusion;
}

// Ref: Moving Frostbite to PBR - Gotanda siggraph 2011
// Return specular occlusion based on ambient occlusion (usually get from SSAO) and view/roughness info
void GetSpecularOcclusionFromAmbientOcclusion_half(real NdotV, real ambientOcclusion, real roughness, out real Out)
{
    Out = saturate(PositivePow(NdotV + ambientOcclusion, exp2(-16.0 * roughness - 1.0)) - 1.0 + ambientOcclusion);
}

void GetSpecularOcclusionFromBentAO_half(half3 V, half3 bentNormalWS, half3 normalWS, half ambientOcclusion, half roughness, out real Out)
{
    half vs = -1.0f / min(sqrt(1.0f - ambientOcclusion) - 1.0f, -0.001f);
    half us = 0.8f;
    // 3. Compute warped SG Axis of GGX distribution
    // Ref: All-Frequency Rendering of Dynamic, Spatially-Varying Reflectance
    // https://www.microsoft.com/en-us/research/wp-content/uploads/2009/12/sg.pdf
    half NoV = dot(V, normalWS);
    half3 NDFAxis = (2 * NoV * normalWS - V) * (0.5f / max(roughness * roughness * NoV, 0.001f));

    half umLength1 = length(NDFAxis + vs * bentNormalWS);
    half umLength2 = length(NDFAxis + us * normalWS);
    half d1 = 1 - exp(-2 * umLength1);
    half d2 = 1 - exp(-2 * umLength2);

    half expFactor1 = exp(umLength1 - umLength2 + us - vs);

    Out = saturate(expFactor1 * (d1 * umLength2) / (d2 * umLength1));
}

// Ref: Steve McAuley - Energy-Conserving Wrapped Diffuse
void ComputeWrappedDiffuseLighting_half(half NdotL, half w, out half Out)
{
    Out = saturate((NdotL + w) / ((1.0 + w) * (1.0 + w)));
}

// Ref: Stephen McAuley - Advances in Rendering: Graphics Research and Video Game Production
half3 ComputeWrappedNormal(half3 N, half3 L, half w)
{
    half NdotL = dot(N, L);
    half wrappedNdotL = saturate((NdotL + w) / (1 + w));
    half sinPhi = lerp(w, 0.f, wrappedNdotL);
    half cosPhi = sqrt(1.0f - sinPhi * sinPhi);
    return normalize(cosPhi * N + sinPhi * cross(cross(N, L), N));
}

// Jimenez variant for eye
void ComputeWrappedPowerDiffuseLighting_half(real NdotL, real w, real p, out real Out)
{
    Out = pow(saturate((NdotL + w) / (1.0 + w)), p) * (p + 1) / (w * 2.0 + 2.0);
}

// Ref: The Technical Art of Uncharted 4 - Brinck and Maximov 2016
void ComputeMicroShadowing_half(real AO, real NdotL, real opacity, out real Out)
{
    real aperture = 2.0 * AO * AO;
    real microshadow = saturate(NdotL + aperture - 1.0);
    Out = lerp(1.0, microshadow, opacity);
}

void ComputeFresnelAO_half(half AO, half3 normalWS, half3 viewDirWS, out half Out)
{
    Out = lerp(1.0, AO, saturate(dot(normalize(normalWS), normalize(viewDirWS))));
}
