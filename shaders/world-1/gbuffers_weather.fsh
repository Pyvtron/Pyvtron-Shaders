#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec4 color;

uniform sampler2D texture;

uniform vec3 upPosition;

uniform int worldTime;
uniform float sunAngle;
uniform float rainStrength;
uniform float screenBrightness;
uniform float nightVision;
uniform float frameTimeCounter;

#include "/Lib/TimeArray.glsl"

float luma(vec3 clr) {
	return dot(clr, vec3(0.3333));
}

#include "/Lib/TorchLightmap.glsl"
#include "/Lib/LowLightEye.glsl"

void main() {

  vec4 baseColor = texture2D(texture, texcoord) * color;
  baseColor.rgb = vec3(luma(baseColor.rgb));

	#include "/Lib/NetherColors.glsl"



	float minLight = 0.03 + screenBrightness * 0.06;

	vec3 ambientLightmap = minLight + luma(ambientColor) * mix(lmcoord.y, 1.0, nightVision) + getTorchLightmap(normal.rgb, lmcoord.x, lmcoord.y, false) * torchColor;

	baseColor.rgb = lowlightEye(baseColor.rgb, ambientLightmap);
	baseColor.rgb *= ambientLightmap;

/* DRAWBUFFERS:7 */

  gl_FragData[0] = baseColor;

}
