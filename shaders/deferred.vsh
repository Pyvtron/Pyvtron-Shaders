#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


varying vec2 texcoord;

attribute vec4 at_tangent;

void main() {

  texcoord = gl_MultiTexCoord0.st;
  gl_Position = ftransform();

}
