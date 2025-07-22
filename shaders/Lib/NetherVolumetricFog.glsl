
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#define NETHER_FOG_STRENGTH 2.0 // [0.0 1.0 2.0 3.0 4.0 5.0 10.0 15.0 20.0]
#define MAX_STEPS 100
#define STEP_SIZE 0.2
#define NETHER_VOLUMETRIC_FOG true // [false true] 

vec3 renderFog(vec3 fragpos, vec3 color, vec3 ambientColor) {
    const bool colortex6MipmapEnabled = true;

    vec4 worldPos = gbufferModelViewInverse * vec4(fragpos, 1.0);

    float height = pow(max(1.0 - ((worldPos.y + cameraPosition.y) * 2.0 - 240), 0.0), 2.0) * 0.00004;

    float fogDensity = 0.002 * NETHER_FOG_STRENGTH;
    fogDensity += fogDensity * rainStrength;
    fogDensity += height * fogDensity;

    vec3 rayDirection = normalize(fragpos - cameraPosition);

    vec3 rayOrigin = cameraPosition;

    vec3 accumulatedColor = vec3(0.0);
    float accumulatedTransmittance = 1.0;

    if (NETHER_VOLUMETRIC_FOG) {
        for (int i = 0; i < MAX_STEPS; i++) {
            // Current ray position
            vec3 samplePos = rayOrigin + rayDirection * STEP_SIZE * float(i);

            float sampleHeight = pow(max(1.0 - ((samplePos.y + cameraPosition.y) * 2.0 - 240), 0.0), 2.0) * 0.00004;
            float sampleFogDensity = fogDensity + sampleHeight * fogDensity;

            float transmittanceStep = exp(-sampleFogDensity * STEP_SIZE);
            accumulatedTransmittance *= transmittanceStep;

            vec3 skyColor = vec3(0.5, 0.7, 1.0); 
            vec3 fogColor = mix(vec3(0.5, 0.5, 0.5), skyColor, sampleHeight);

            fogColor = mix(
                ambientColor * (1.0 - rainStrength * time[5]), 
                fogColor, 
                1.0 - transmittanceStep
            );

            accumulatedColor += fogColor * (1.0 - transmittanceStep) * accumulatedTransmittance;

            if (accumulatedTransmittance < 0.01) break;
        }
    }

    float fogFactor = 1.0 - accumulatedTransmittance;
    color = mix(color, vec3(0.5, 0.5, 0.5), fogFactor); 

    color = mix(color, accumulatedColor, fogFactor);

    return color;
}