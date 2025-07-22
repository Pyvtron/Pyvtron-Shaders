#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


layout(location = 0) out vec4 compositeOutput1;

#include "/Lib/Uniforms.glsl"
#include "/Lib/Settings.glsl"

in vec4 texcoord;

const int Bayer16Size = 16;
const int Bayer16Matrix[256] = int[256](
    0,128,32,160,8,136,40,168,2,130,34,162,10,138,42,170,
    64,192,96,224,72,200,104,232,66,194,98,226,74,202,106,234,
    16,144,48,176,24,152,56,184,18,146,50,178,26,154,58,186,
    80,208,112,240,88,216,120,248,82,210,114,242,90,218,122,250,
    4,132,36,164,12,140,44,172,6,134,38,166,14,142,46,174,
    68,196,100,228,76,204,108,236,70,198,102,230,78,206,110,238,
    20,148,52,180,28,156,60,188,22,150,54,182,30,158,62,190,
    84,212,116,244,92,220,124,252,86,214,118,246,94,222,126,254,
    1,129,33,161,9,137,41,169,3,131,35,163,11,139,43,171,
    65,193,97,225,73,201,105,233,67,195,99,227,75,203,107,235,
    17,145,49,177,25,153,57,185,19,147,51,179,27,155,59,187,
    81,209,113,241,89,217,121,249,83,211,115,243,91,219,123,251,
    5,133,37,165,13,141,45,173,7,135,39,167,15,143,47,175,
    69,197,101,229,77,205,109,237,71,199,103,231,79,207,111,239,
    21,149,53,181,29,157,61,189,23,151,55,183,31,159,63,191,
    85,213,117,245,93,221,125,253,87,215,119,247,95,223,127,255
);

vec3 GammaToLinear(vec3 c)
{
    return pow(c, vec3(2.2));
}

float bayer16(vec2 fragCoord) {
    int x = int(mod(fragCoord.x, Bayer16Size));
    int y = int(mod(fragCoord.y, Bayer16Size));
    int index = y * Bayer16Size + x;
    float threshold = float(Bayer16Matrix[index]) / 255.0;
    return threshold;
}

vec3 GetColorTexture(vec2 coord) {
    return GammaToLinear(texture(colortex7, coord).rgb);
}

vec3 MotionBlur() {
    float depth = texture(depthtex1, texcoord.st).x;

    vec4 currentPosition = vec4(texcoord.x * 2.0 - 1.0, texcoord.y * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
    vec4 fragposition = gbufferProjectionInverse * currentPosition;
    fragposition = gbufferModelViewInverse * fragposition;
    fragposition /= fragposition.w;
    fragposition.xyz += cameraPosition;

    vec4 previousPosition = fragposition;
    previousPosition.xyz -= previousCameraPosition;
    previousPosition = gbufferPreviousModelView * previousPosition;
    previousPosition = gbufferPreviousProjection * previousPosition;
    previousPosition /= previousPosition.w;

    vec2 velocity = (currentPosition - previousPosition).st * 0.25 * (MOTION_BLUR_SUTTER_ANGLE / 360.0);
    float maxVelocity = 0.1;
    velocity = clamp(velocity, vec2(-maxVelocity), vec2(maxVelocity));

    if (depth < 0.7) {
        velocity = vec2(0.0);
    }

    int steps = MOTION_BLUR_QUALITY;
    int samples = 0;
    vec3 color = vec3(0.0);

    float dither = 0.0;
    #ifdef MOTION_BLUR_DITHER
        dither = bayer16(gl_FragCoord.xy);
    #endif

    for (int i = -steps; i <= steps; ++i) {
        vec2 coord = texcoord.st + velocity * ((float(i) + dither) / (steps + 1.0));
        if (coord.x >= 0.0 && coord.x <= 1.0 && coord.y >= 0.0 && coord.y <= 1.0) {
            color += GetColorTexture(coord);
            samples++;
        }
    }

    if (samples > 0) {
        color /= float(samples);
    }
    return LinearToGamma(color);
}

void main() {
    vec3 color = texture(colortex1, texcoord.st).rgb;
    #ifdef MOTION_BLUR
        color = MotionBlur();
    #endif
    compositeOutput1 = vec4(color, 1.0);
}

/* DRAWBUFFERS:1 */