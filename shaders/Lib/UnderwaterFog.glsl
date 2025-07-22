
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#define UNDERWATER_FOG_STRENGTH 0.1 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5]
#define UNDERWATER_FOG 1 // [0 1]
#define UNDERWATER_FOG_BRIGHTNESS 0.2 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]


vec3 underwaterFog(vec3 fragpos, vec3 color, vec3 waterColor, vec3 lavaColor) {
    float distance = length(fragpos);
    
#if UNDERWATER_FOG
    float fogFactor = exp(-pow(distance * UNDERWATER_FOG_STRENGTH, 1.0));
#else
    float fogFactor = 1.0;
#endif

    float underwaterVolumetricFog = 1.0 - exp(-distance * UNDERWATER_FOG_STRENGTH * UNDERWATER_FOG_BRIGHTNESS); 

    vec3 baseTurquoise = vec3(0.1, 0.8, 1.0);
    vec3 blendBlue     = vec3(0.0, 0.3, 1.0);

    // Mischung von Türkis mit Blau
    vec3 underwaterFogColor = mix(baseTurquoise, blendBlue, 0.5); 

    if (isEyeInWater == 1) {
        vec3 fogBlend = mix(color, waterColor, (1.0 - fogFactor) * underwaterVolumetricFog);
        return mix(fogBlend, underwaterFogColor, 0.4 * underwaterVolumetricFog); 
    } else if (isEyeInWater == 2) {
        return mix(color, lavaColor, (1.0 - exp(-pow(distance, 1.0))) * underwaterVolumetricFog);
    } else {
        return color;
    }
}
