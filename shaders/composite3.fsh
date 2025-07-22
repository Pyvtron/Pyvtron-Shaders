#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/Settings.glsl"

#define MAX_RAY_DISTANCE 10.0
#define BLOOM_INTENSITY 0.6

varying vec2 texcoord;

uniform sampler2D colortex4;
uniform sampler2D depthtex1;
uniform sampler2D normaltex; 

uniform float aspectRatio;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

vec3 reconstructWorldPosition(vec2 uv) {
    float depth = texture2D(depthtex1, uv).r * 2.0 - 1.0;
    vec4 clipSpacePos = vec4(uv * 2.0 - 1.0, depth, 1.0);
    vec4 viewSpacePos = gbufferProjectionInverse * clipSpacePos;
    viewSpacePos /= viewSpacePos.w;
    return (gbufferModelViewInverse * viewSpacePos).xyz + cameraPosition;
}

vec3 raytraceReflection(vec3 viewDir, vec3 normal, vec2 uv) {
    vec3 startPos = reconstructWorldPosition(uv);
    vec3 reflectDir = reflect(viewDir, normal);

    vec3 stepSize = reflectDir * (MAX_RAY_DISTANCE / float(BLOOM_SAMPLES));
    vec3 currentPos = startPos;

    for (int i = 0; i < BLOOM_SAMPLES; i++) {
        vec4 projPos = gbufferProjectionInverse * vec4(currentPos - cameraPosition, 1.0);
        projPos /= projPos.w;
        vec2 screenUV = projPos.xy * 0.5 + 0.5;

        if (screenUV.x < 0.0 || screenUV.x > 1.0 || screenUV.y < 0.0 || screenUV.y > 1.0)
            break;

        float sceneDepth = texture2D(depthtex1, screenUV).r * 2.0 - 1.0;
        if (sceneDepth < projPos.z) {
            return texture2D(colortex4, screenUV).rgb;
        }
        currentPos += stepSize;
    }
    return vec3(0.0);
}

vec3 bloomPass() {
    vec3 bloomSample = vec3(0.0);
    vec2 offsets[9] = vec2[9](
        vec2(-1.0, -1.0), vec2(0.0, -1.0), vec2(1.0, -1.0),
        vec2(-1.0,  0.0), vec2(0.0,  0.0), vec2(1.0,  0.0),
        vec2(-1.0,  1.0), vec2(0.0,  1.0), vec2(1.0,  1.0)
    );
    vec2 aspectCorrect = vec2(1.0, aspectRatio);

    for (int i = 0; i < 9; i++) {
        bloomSample += texture2DLod(colortex4, texcoord + offsets[i] * aspectCorrect * 0.01, 4.0).rgb;
    }
    bloomSample *= (1.0 / 9.0) * BLOOM_INTENSITY;
    return bloomSample;
}

void main() {
    vec3 color = texture2D(colortex4, texcoord).rgb;
    
    vec3 viewDir = normalize(reconstructWorldPosition(texcoord) - cameraPosition);
    vec3 normal = normalize(texture2D(normaltex, texcoord).rgb * 2.0 - 1.0); 

    vec3 reflection = raytraceReflection(viewDir, normal, texcoord);
    color = mix(color, reflection, 0.5);
    
    color += bloomPass();

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}