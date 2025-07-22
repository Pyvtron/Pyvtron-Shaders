#version 120

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/HDR.glsl"

varying vec4 color;

void main() {

  vec4 baseColor = color;

/* DRAWBUFFERS:0 */

  gl_FragData[0] = vec4(baseColor.rgb / MAX_COLOR_RANGE, baseColor.a);

}
