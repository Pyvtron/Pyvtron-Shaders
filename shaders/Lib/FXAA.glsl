
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron VX Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#define FXAA_REDUCE_MIN   (1.0 / 256.0) 
#define FXAA_REDUCE_MUL   (1.0 / 8.0)   
#define FXAA_SPAN_MAX     8.0                 

vec4 fxaa(sampler2D tex, vec2 fragCoord, vec2 resolution) {
    vec2 inverseVP = vec2(1.0) / resolution;  

    vec3 rgbNW = texture2D(tex, fragCoord + vec2(-1.0, -1.0) * inverseVP).xyz;
    vec3 rgbNE = texture2D(tex, fragCoord + vec2( 1.0, -1.0) * inverseVP).xyz;
    vec3 rgbSW = texture2D(tex, fragCoord + vec2(-1.0,  1.0) * inverseVP).xyz;
    vec3 rgbSE = texture2D(tex, fragCoord + vec2( 1.0,  1.0) * inverseVP).xyz;
    vec4 texColor = texture2D(tex, fragCoord);
    vec3 rgbM  = texColor.xyz; 

    vec3 lumaVec = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, lumaVec);
    float lumaNE = dot(rgbNE, lumaVec);
    float lumaSW = dot(rgbSW, lumaVec);
    float lumaSE = dot(rgbSE, lumaVec);
    float lumaM  = dot(rgbM,  lumaVec);

    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));  
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE)); 

    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);

    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = clamp(dir * rcpDirMin, -FXAA_SPAN_MAX, FXAA_SPAN_MAX) * inverseVP;

    vec3 rgbA = 0.5 * (
        texture2D(tex, fragCoord + dir * (1.0 / 3.0 - 0.5)).xyz +
        texture2D(tex, fragCoord + dir * (2.0 / 3.0 - 0.5)).xyz);
    vec3 rgbB = rgbA * 0.5 + 0.25 * (
        texture2D(tex, fragCoord + dir * -0.5).xyz +
        texture2D(tex, fragCoord + dir * 0.5).xyz);

    float lumaB = dot(rgbB, lumaVec);

    return ((lumaB < lumaMin) || (lumaB > lumaMax)) ? vec4(rgbA, texColor.a) : vec4(rgbB, texColor.a);
}
