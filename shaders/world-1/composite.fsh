#version 460 compatibility

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
uniform sampler2D depthtex0;  

uniform mat4 gbufferProjectionInverse; 

uniform float near;
uniform float far;  


/* Optfifine
const int colortex0Format = R11F_G11F_B10F;
const int colortex1Format = RGBA16;
const int colortex2Format = RGBA8;
const int colortex3Format = RGBA8;
const int colortex4Format = RGBA16;
const int colortex5Format = RGBA16;
const int colortex6Format = R11F_G11F_B10F;
*/

const float		sunPathRotation				= -30; // [-90 -89 -88 -87 -86 -85 -84 -83 -82 -81 -80 -79 -78 -77 -76 -75 -74 -73 -72 -71 -70 -69 -68 -67 -66 -65 -64 -63 -62 -61 -60 -59 -58 -57 -56 -55 -54 -53 -52 -51 -50 -49 -48 -47 -46 -45 -44 -43 -42 -41 -40 -39 -38 -37 -36 -35 -34 -33 -32 -31 -30 -29 -28 -27 -26 -25 -24 -23 -22 -21 -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90]

const float shadowDistanceRenderMul = 1.0; // [-1.0 1.0]
const int noiseTextureResolution = 1;

#ifdef DEPTH_OF_FIELD
const float centerDepthHalflife = 2.0;	// [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0] 
#endif

#ifdef DIRTY_LENS
    uniform sampler2D colortex1; 
#endif

#if (LIGHT_SCATTERING == 1)

uniform sampler2D depthtex1; 
uniform mat4 gbufferProjection; 
uniform vec3 sunPosition; 

float prerenderGodrays(vec3 fragpos, float comp) {
    float grSample = 0.0;

    vec4 tpos = vec4(sunPosition, 1.0) * gbufferProjection;
    tpos = vec4(tpos.xyz / tpos.w, 1.0);
    vec2 pos = tpos.xy / tpos.z;
    vec2 lightPos = pos * 0.5 + 0.5;

    vec2 grCoord = texcoord.st;
    vec2 deltaTextCoord = texcoord.st - lightPos.xy;

    deltaTextCoord /= float(256); 

    for (int i = 0; i < 256; i++) {
        grCoord -= deltaTextCoord * 0.7;

        if (grCoord.y < 1.0 && grCoord.x > 0.0 && grCoord.x < 1.0) {
            float depth = texture2D(depthtex1, grCoord).x;

            if (depth > comp) {
                grSample += 1.0;
            }
        }
    }

    grSample /= float(256);

    grSample = smoothstep(0.0, 1.0, grSample);

    return grSample;
}

#endif

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;
    
    vec4 fragposition0  = gbufferProjectionInverse * (vec4(texcoord.st, texture2D(depthtex0, texcoord).x, 1.0) * 2.0 - 1.0);
    fragposition0 /= fragposition0.w;

    float comp = 1.0 - near / far / far;

    /* DRAWBUFFERS:42 */

    #if (LIGHT_SCATTERING == 1)
        gl_FragData[0] = vec4(color, prerenderGodrays(fragposition0.xyz, comp));
    #else
        gl_FragData[0] = vec4(color, 1.0); 
    #endif

    #ifdef DIRTY_LENS
        bool emissive = texture2D(colortex1, texcoord).a > 0.29 && texture2D(colortex1, texcoord).a < 0.31;
        gl_FragData[1] = vec4(color * float(emissive), texture2D(colortex1, texcoord).a);
    #endif
}
