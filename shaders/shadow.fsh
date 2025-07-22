#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/Settings.glsl"

varying vec2 texcoord;
varying vec3 normal;
varying vec3 worldPosition;
varying vec3 eyeDirection;
varying vec3 lightColor; 

uniform sampler2D texture;

void main() {
    vec4 color = texture2D(texture, texcoord);

    color.rgb += lightColor;

    gl_FragColor = color;
}