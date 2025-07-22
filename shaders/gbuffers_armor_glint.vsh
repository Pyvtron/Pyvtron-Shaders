#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


varying vec2 texcoord;
varying vec4 color;
varying float glintIntensity;  

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform float frameTimeCounter;  

void main() {

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

    color = gl_Color;

    glintIntensity = abs(sin(frameTimeCounter * 10.0));  

    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

    gl_Position = gl_ProjectionMatrix * position;
}
