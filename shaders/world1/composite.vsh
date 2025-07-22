#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyhtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


varying vec2 texcoord;

void main() {

  texcoord = gl_MultiTexCoord0.st;
  gl_Position = ftransform();

}
