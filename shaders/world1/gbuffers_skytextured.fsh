#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/HDR.glsl"

varying vec2 texcoord;
varying vec4 color;

uniform sampler2D texture;
uniform sampler2D gaux4;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform float viewWidth;
uniform float viewHeight;
uniform float sunAngle;
uniform float frameTimeCounter;


vec3 toNDC(vec3 pos) {
    vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2.0 - 1.0;
    vec4 fragpos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

// Simple noise function for stars
float starNoise(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Star effect
vec3 starEffect(vec2 uv, float sunFactor) {
    float noise = starNoise(uv * 300.0); // Scale UV to create more stars
    float starIntensity = smoothstep(1.0, 1.1, noise); // Only show brightest points as stars
    starIntensity *= pow(9.0 - sunFactor, 9.0); // Fade stars during the day
    return vec3(1.0, 1.0, 1.0) * starIntensity; // White stars
}

// Aurora Effekt
vec3 auroraEffect(vec3 position) {
    float noise = sin(position.x * 10.0 + frameTimeCounter * 0.2) *
                  cos(position.y * 15.0 + frameTimeCounter * 0.3);
    float intensity = smoothstep(0.3, 0.8, noise);
    return vec3(0.2, 0.8, 1.0) * intensity;
}

void main() {
    vec4 baseColor = texture2D(texture, texcoord) * color;
    vec3 fragposition = toNDC(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z));

    float sunFactor = clamp(1.0 - pow(abs(-0.25 + sunAngle) * 4.0, 2.0 / (abs(-0.25 + sunAngle) * 4.0)), 0.0, 1.0);

    float sunVector = max(dot(normalize(fragposition), normalize(sunPosition)), 0.0);
    float moonVector = max(dot(normalize(fragposition), normalize(moonPosition)), 0.0);

    // Sun rendering
    float sun = pow(sunVector, 1500.0) * 2.10 + smoothstep(0.9995, 1.0, sunVector) * 9.5;
    vec3 sunColor = vec3(1.0, 1.0, 1.0);

    // Moon rendering
    float moon = pow(moonVector, 250.0) * 1.0;
    vec3 moonColor = vec3(0.6, 0.6, 0.7);

    if (sunVector > 0.0) baseColor.rgb *= 0.0;
    if (moonVector > 0.0) baseColor.rgb *= 0.0;

    vec3 skyColor = mix(vec3(0.2, 0.1, 0.1), vec3(0.0, 0.0, 0.1), sunFactor);

    baseColor.rgb += sun * sunColor;
    baseColor.rgb += moon * moonColor;

    // Add stars
    vec3 stars = starEffect(texcoord * viewWidth, sunFactor); // Scale texcoord for better distribution
    baseColor.rgb += stars;

    // Aurora hinzufügen
    vec3 aurora = auroraEffect(fragposition);
    baseColor.rgb += aurora * (1.0 - sunFactor);

    // Blend sky color into base color
    baseColor.rgb = mix(baseColor.rgb, skyColor, 0.25);

    baseColor.rgb /= MAX_COLOR_RANGE;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = baseColor;
}