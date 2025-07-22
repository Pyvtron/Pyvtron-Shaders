#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/

#include "/Lib/HDR.glsl"

#define TEMPERATURE 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

varying vec4 position;
uniform float worldTime;

#include "/Lib/TimeArray.glsl"

float starIntensity(vec3 pos) {
    float noise = fract(sin(dot(pos.xy, vec2(12.9898, 78.233))) * 43758.5453);
    return step(0.995, noise) * 1.0; 
}

void main() {
  vec3 skybox = vec3(1.0, 0.0, 0.0); 
  


  /* DRAWBUFFERS:061 */
  gl_FragData[0] = vec4(1.0, 0.0, 0.0, 1.0);
}
