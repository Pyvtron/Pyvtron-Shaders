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

vec3 toNDC(vec3 pos) {
    vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2.0 - 1.0;
    vec4 fragpos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

void main() {
    vec4 baseColor = texture2D(texture, texcoord) * color;
    vec3 fragposition = toNDC(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z));

    float sunFactor = clamp(1.0 - pow(abs(-0.25 + sunAngle) * 4.0, 2.0 / (abs(-0.25 + sunAngle) * 4.0)), 0.0, 1.0);

    float sunVector = max(dot(normalize(fragposition), normalize(sunPosition)), 0.0);
    float moonVector = max(dot(normalize(fragposition), normalize(moonPosition)), 0.0);

    float sun = pow(sunVector, 500.0) * 0.35 + smoothstep(0.9995, 1.0, sunVector) * 8.5;
    vec3 sunColorDay = vec3(1.0, 0.4, 0.05); 
    vec3 sunColorSunset = vec3(1.0, 0.4, 0.05); 
    vec3 sunColor = mix(sunColorDay, sunColorSunset, sunFactor); 

    float moon = pow(moonVector, 600.0) * 0.25 + smoothstep(0.9998, 1.0, moonVector) * 1.5;
    vec3 moonColor = vec3(0.8, 0.9, 1.0); 

    if (sunVector > 0.0) baseColor.rgb *= 0.0;
    if (moonVector > 0.0) baseColor.rgb *= 0.0;

    baseColor.rgb += sun * sunColor;
    baseColor.rgb += moon * moonColor;

    baseColor.rgb /= MAX_COLOR_RANGE;

    gl_FragData[0] = baseColor;
}
