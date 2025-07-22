
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


float getTorchLightmap(vec3 normal, float lightmap, float skyLightmap, bool translucent) {
    float tRadius = 3.0;
    float tBrightness = 0.08;

    tBrightness *= 1.0 - (skyLightmap * (1.0 - time[5])) * 0.3;

    float NdotL = translucent ? 1.0 : clamp(dot(normal, normalize(upPosition)), 0.0, 1.0) + clamp(dot(normal, normalize(-upPosition)), 0.0, 1.0);

    float materialFactor = 0.9;

    float torchLightmap = max(exp(pow(lightmap + 0.6, tRadius)) - 1.0, 0.0) * tBrightness * (1.0 + NdotL * 0.5);

    torchLightmap *= materialFactor;

    float distanceFactor = 1.0 / (1.0 + length(normal) * 0.05);
    torchLightmap *= distanceFactor;

    torchLightmap *= mix(color.a, 1.0, torchLightmap);

    torchLightmap = clamp(torchLightmap, 0.0, 1.0);

    return torchLightmap;
}