#version 460 compatibility
#extension GL_EXT_gpu_shader4 : enable

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/HDR.glsl"
#include "/Lib/Settings.glsl"

varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;

uniform vec3 upPosition;
uniform vec3 cameraPosition;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform int isEyeInWater;
uniform int worldTime;

uniform float near;
uniform float far;
uniform float sunAngle;
uniform float rainStrength;
uniform float nightVision;

#include "/Lib/TimeArray.glsl"

vec2 decodeLightmap(float a) {

  int bf = int(a * 65535.0);
  return vec2(bf % 256, bf >> 8) / 255.0;

}

vec3 decodeNormal(vec2 enc) {

  vec2 fenc = enc*4-2;
  float f = dot(fenc,fenc);
  float g = sqrt(1-f/4.0);
  vec3 n;
  n.xy = fenc*g;
  n.z = 1-f/2;
  return n;

}

#include "/Lib/NetherVolumetricFog.glsl"
#include "/Lib/UnderwaterFog.glsl"
#include "/Lib/UnderwaterColor.glsl"

#if defined PBR || defined RAIN_PUDDLES

	uniform sampler2D colortex2;
	uniform sampler2D colortex4;
	uniform sampler2D colortex5;
	uniform vec3 sunPosition;
	uniform float viewWidth;
	uniform float viewHeight;

	const bool colortex5MipmapEnabled = true;

	float ditherGradNoise() {
	  return fract(52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y));
	}

	vec3 drawSun(vec3 fragpos, vec3 sunColor, float roughness) {

		float sunVector = max(dot(normalize(fragpos), normalize(sunPosition)), 0.0);
		return (pow(sunVector, 1.0 + 100.0 * roughness) * 0.5 + smoothstep(0.997 - pow(roughness, 2.0) * 0.997, 1.0, sunVector)) * (1.0 - time[6]) * sunColor * 5.0 * (1.0 - roughness);

	}

	vec3 renderPBR(vec3 fragpos, vec3 normal, vec3 color, vec3 ambientColor, vec3 sunColor, vec4 albedo) {

		vec3 specular = texture2D(colortex2, texcoord).rgb;

		float roughness = specular.r;
		float metallic = specular.g;
		float specularity = specular.b;

		float dist = 1.0 + length(fragpos) * 0.1;
		float lodding = pow(roughness, 0.4);

		vec4 reflection = texture2DLod(colortex5, texcoord, (lodding * 12.0 * (0.5 + ditherGradNoise() * 0.5)) / dist);

		vec3 reflectedVector = reflect(normalize(fragpos), normal) * 300.0;

		float normalDotEye = dot(normal.rgb, normalize(fragpos));
		float fresnel = clamp(pow(1.0 + normalDotEye + metallic, 3.0), 0.0, 1.0);

    ambientColor = ambientColor * (1.0 - rainStrength * time[5] * 0.9);

		reflection.rgb = mix(ambientColor, reflection.rgb, reflection.a);
		reflection.rgb = mix(reflection.rgb, reflection.rgb * albedo.rgb, metallic);

		return mix(color * (1.0 - metallic), reflection.rgb, fresnel * specularity) + drawSun(reflectedVector, sunColor, roughness) * (1.0 - reflection.a) * specularity * albedo.a;

	}

#endif


void main() {

  vec3 color = texture2D(colortex0, texcoord).rgb * MAX_COLOR_RANGE;
	vec3 normal = decodeNormal(texture2D(colortex1, texcoord).yz);

	float depth = texture2D(depthtex0, texcoord).x;

  float skyLightmap = decodeLightmap(texture2D(colortex1, texcoord).x).y;
	float torchLightmap = decodeLightmap(texture2D(colortex1, texcoord).x).x;

  float comp = 1.0 - near / far / far;
  bool sky = depth > comp;
  bool land = depth < comp;

  vec4 fragposition0  = gbufferProjectionInverse * (vec4(texcoord.st, depth, 1.0) * 2.0 - 1.0);
	     fragposition0 /= fragposition0.w;

  #include "/Lib/NetherColors.glsl"

	#if defined PBR || defined RAIN_PUDDLES
		vec4 albedo = texture2D(colortex4, texcoord);
		if (land) color = renderPBR(fragposition0.xyz, normal, color, mix(ambientColor * skyLightmap, torchColor, torchLightmap * (1.0 - skyLightmap)), sunColor, albedo);
	#endif

	vec3 underwaterColor = calcUnderwaterColor(color, waterColor * ambientColor, skyLightmap);

	float position = dot(normalize(fragposition0.xyz) + vec3(0.0, 0.2, 0.0), upPosition);
	if (sky) underwaterColor = calcUnderwaterColor(color, waterColor * ambientColor, clamp(position * 0.05, 0.0, 1.0));

	if (land) color.rgb = renderFog(fragposition0.xyz, color.rgb, ambientColor);
  color = underwaterFog(fragposition0.xyz, color, waterColor * ambientColor * vec3(0.6, 1.0, 0.8) * 0.2, lavaColor);

/* DRAWBUFFERS:045 */

  gl_FragData[0] = vec4(color / MAX_COLOR_RANGE, 1.0);
	gl_FragData[1] = vec4(underwaterColor / MAX_COLOR_RANGE, 1.0);
  gl_FragData[2] = vec4(color / MAX_COLOR_RANGE, 1.0);

}
