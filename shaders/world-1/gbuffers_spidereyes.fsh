#version 460 compatibility
#extension GL_EXT_gpu_shader4 : enable

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/HDR.glsl"

uniform sampler2D texture;          
uniform float glowThreshold;       
uniform vec3 glowColor;           
uniform float glowIntensity;      

varying vec2 texcoord;         
varying vec3 normal;             
varying vec4 color;      
varying vec2 lmcoord;             

float encodeLightmap(vec2 a) {
    ivec2 bf = ivec2(a * 255.0);
    return float(bf.x | (bf.y << 8)) / 65535.0;
}

vec2 encodeNormal(vec3 normal) {
    return normal.xy * inversesqrt(normal.z * 8.0 + 8.0) + 0.5;
}

void main() {
    vec4 baseColor = texture2D(texture, texcoord) * color;

    if (length(baseColor.rgb) < 0.01) {
        gl_FragData[0] = vec4(0.0);
        gl_FragData[1] = vec4(encodeLightmap(lmcoord), encodeNormal(normal.rgb), 1.0);
        gl_FragData[2] = vec4(0.0);
        return;
    }

    float intensity = length(baseColor.rgb);

    vec4 glowEffect = vec4(0.0);
    if (intensity > glowThreshold) {
        glowEffect.rgb = glowColor * (intensity - glowThreshold) * glowIntensity;
    }

    vec4 finalColor = baseColor + glowEffect;

    /* DRAWBUFFERS:012 */
    gl_FragData[0] = vec4(finalColor.rgb * 2.0 / MAX_COLOR_RANGE, finalColor.a);
    gl_FragData[1] = vec4(encodeLightmap(lmcoord), encodeNormal(normal.rgb), 1.0);
    gl_FragData[2] = vec4(glowEffect.rgb, 1.0);
}