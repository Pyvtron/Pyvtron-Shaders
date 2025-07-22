#define VOLUMETRIC_FOG true // [false true] 
#define FOG_STRENGTH 7.0 // [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0]
#define MAX_STEPS 100
#define STEP_SIZE 0.2

vec3 renderFog(vec3 fragpos, vec3 color, vec3 ambientColor) {
    if (!VOLUMETRIC_FOG) return color;

    // In Weltkoordinaten umrechnen
    vec3 worldPos = (gbufferModelViewInverse * vec4(fragpos, 1.0)).xyz + cameraPosition;
    vec3 eyePos = cameraPosition;
    vec3 rayDir = normalize(worldPos - eyePos); // Sichtstrahl vom Auge zum Punkt

    bool isUnderwater = eyePos.y < -0.2;

    vec3 skyColor           = vec3(0.5, 0.7, 1.0);       
    vec3 fogBaseColor       = vec3(0.6, 0.65, 0.7);      
    vec3 underwaterFogColor = vec3(0.2, 0.4, 0.6);     

    float fogDensity = 0.001 * FOG_STRENGTH;
    fogDensity += fogDensity * rainStrength;

    vec3 accumulatedColor = vec3(0.0);
    float accumulatedTransmittance = 1.0;

    for (int i = 0; i < MAX_STEPS; i++) {
        float t = STEP_SIZE * float(i);
        vec3 samplePos = eyePos + rayDir * t;
        float sampleY = samplePos.y;

        // Höhe relativ zu Meereshöhe oder 64
        float heightFalloff = exp(-max(sampleY - 64.0, 0.0) * 0.04);
        float sampleFogDensity = fogDensity * heightFalloff;

        float transStep = exp(-sampleFogDensity * STEP_SIZE);
        accumulatedTransmittance *= transStep;

        vec3 fogColor = mix(fogBaseColor, skyColor, heightFalloff);

        if (sampleY < -0.2) {
            fogColor = mix(underwaterFogColor, fogColor, clamp(sampleY * -0.02, 0.0, 1.0));
        }

        fogColor = mix(ambientColor * (1.0 - rainStrength * time[5]), fogColor, 1.0 - transStep);

        accumulatedColor += fogColor * (1.0 - transStep) * accumulatedTransmittance;

        if (accumulatedTransmittance < 0.01) break;
    }

    float fogFactor = 1.0 - accumulatedTransmittance;

    vec3 finalFogColor = isUnderwater ? underwaterFogColor : fogBaseColor;
    color = mix(color, finalFogColor, fogFactor);
    color = mix(color, accumulatedColor, fogFactor);

    return color;
}
