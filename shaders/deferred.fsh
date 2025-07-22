#version 460 compatibility
#extension GL_EXT_gpu_shader4 : enable

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/Settings.glsl"
#include "/Lib/HDR.glsl"

varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform float near;
uniform float far;

float ditherNoise() {
    return fract(52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y));
}

vec3 decodeNormal(vec2 enc) {
    vec2 fenc = enc * 4.0 - 2.0;
    float f = dot(fenc, fenc);
    float g = sqrt(1.0 - f / 4.0);
    vec3 n;
    n.xy = fenc * g;
    n.z = 1.0 - f / 2.0;
    return n;
}

vec3 cameraToScreen(vec3 fragpos) {
    vec4 pos = gbufferProjection * vec4(fragpos, 1.0);
    pos /= pos.w;
    return pos.xyz * 0.5 + 0.5;
}

vec3 cameraToWorld(vec3 fragpos) {
    vec4 pos = gbufferProjectionInverse * vec4(fragpos, 1.0);
    pos /= pos.w;
    return pos.xyz;
}

vec4 raytrace(vec3 fragpos, vec3 normal) {
    const int samples = 40;
    const float stepSize = 1.2;
    const float stepRefine = 0.15;
    const float stepIncrease = 1.6;

    vec3 col = vec3(0.0);
    vec3 rayStart = fragpos;
    vec3 rayDir = reflect(normalize(fragpos), normal);
    vec3 rayStep = (stepSize + ditherNoise() - 0.5) * rayDir;
    vec3 rayPos = rayStart + rayStep;
    vec3 rayRefine = rayStep;

    int refine = 0;
    vec3 pos = vec3(0.0);
    float edge = 0.0;

    for (int i = 0; i < samples; i++) {
        pos = cameraToScreen(rayPos);
        if (pos.x < 0.0 || pos.x > 1.0 || pos.y < 0.0 || pos.y > 1.0 || pos.z < 0.0 || pos.z > 1.0) break;
        
        vec3 screenPos = vec3(pos.xy, texture2D(depthtex0, pos.xy).x);
        screenPos = cameraToWorld(screenPos * 2.0 - 1.0);

        float dist = distance(rayPos, screenPos);
        if (dist < pow(length(rayStep) * pow(length(rayRefine), 0.15), 1.2) * 1.1) {
            refine++;
            if (refine >= 10) break;
            rayRefine -= rayStep;
            rayStep *= stepRefine;
        }
        rayStep *= stepIncrease;
        rayRefine += rayStep;
        rayPos = rayStart + rayRefine;
    }

    if (pos.z < 1.0 - 1e-5) {
        float depth = texture2D(depthtex0, pos.xy).x;
        if (depth < 1.0 - near / far / far) {
            col = texture2D(colortex0, pos.xy).rgb * MAX_COLOR_RANGE;
            edge = clamp(1.0 - length(pos.st - 0.5), 0.0, 1.0);
        }
    }

    return vec4(col, clamp(edge * 2.0, 0.0, 1.0));
}

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb * MAX_COLOR_RANGE;
    vec3 normal = decodeNormal(texture2D(colortex1, texcoord).yz);
    float depth = texture2D(depthtex0, texcoord).x;

    vec4 fragposition0 = gbufferProjectionInverse * (vec4(texcoord.st, depth, 1.0) * 2.0 - 1.0);
    fragposition0 /= fragposition0.w;

    gl_FragData[0] = vec4(color / MAX_COLOR_RANGE, 1.0);
    gl_FragData[1] = raytrace(fragposition0.xyz, normal);
}