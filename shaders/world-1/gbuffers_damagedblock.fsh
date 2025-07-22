#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


varying vec2 texcoord;
varying vec4 color;

uniform sampler2D texture;

void main() {

  vec4 baseColor = texture2D(texture, texcoord) * color;

/* DRAWBUFFERS:0 */

  gl_FragData[0] = baseColor;

}
