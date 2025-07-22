#version 330 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 color;
varying vec4 position2;
varying vec4 worldposition;
varying vec3 tangent;
varying vec4 normal;
varying vec3 binormal;
varying vec3 viewDir;
varying vec3 worldNormal;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

uniform float frameTimeCounter;
uniform float waveSpeed;
uniform float waveHeight;
uniform float waveSize;

vec3 calcWavingWater(vec3 pos) {
    pos.y += sin(frameTimeCounter * waveSpeed + (pos.x + cameraPosition.x) * waveSize) * waveHeight;
    pos.y += cos(frameTimeCounter * waveSpeed + (pos.z + cameraPosition.z) * 0.3 * waveSize) * waveHeight;
    return pos;
}

void main() {
    color = gl_Color;
    texcoord = gl_MultiTexCoord0.st;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    normal = vec4(normalize(gl_NormalMatrix * gl_Normal), 0.15);

    vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

    if (mc_Entity.x == 10008.0) {
        normal.a = 0.1;
        position.xyz = calcWavingWater(position.xyz);
    } else if (mc_Entity.x == 10090.0) {
        normal.a = 0.17;
    } else if (mc_Entity.x == 10079.0 || mc_Entity.x == 10095.0 || mc_Entity.x == 10165.0) {
        normal.a = 0.19;
    }

    position2 = gl_ModelViewMatrix * gl_Vertex;
    worldposition = position + vec4(cameraPosition.xyz, 0.0);

    vec3 worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;
    viewDir = normalize(cameraPosition - worldPos);
    worldNormal = normalize((gbufferModelViewInverse * vec4(normal.xyz, 0.0)).xyz);

    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

    tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
    binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));
}