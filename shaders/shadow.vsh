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

uniform vec3 cameraPosition;

uniform mat4 shadowProjectionInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowModelView;

attribute vec4 mc_midTexCoord;
attribute vec4 mc_Entity;

#ifdef WINDY_TERRAIN

  uniform float frameTimeCounter;
  uniform float rainStrength;

  const float MC_SAPLINGS = 10006.0;
  const float MC_OAK_LEAVES = 10018.0;
  const float MC_GRASS = 10031.0;
  const float MC_YELLOW_FLOWER = 10037.0;
  const float MC_RED_FLOWER = 10038.0;
  const float MC_WHEAT_CROPS = 10059.0;
  const float MC_CARROTS = 10141.0;
  const float MC_POTATOES = 10142.0;
  const float MC_ACACIA_LEAVES = 10161.0;
  const float MC_TALL_GRASS_LOWER = 10175.0;
  const float MC_TALL_GRASS_UPPER = 10176.0;
  const float MC_BEETROOT = 10207.0;

  vec3 calcMovement(vec3 pos, float posRes) {
      float speed = 3.0 * WIND_SPEED;
      return vec3(
          sin(frameTimeCounter * speed + pos.z * posRes + cameraPosition.z * posRes),
          sin(frameTimeCounter * speed + pos.z * posRes + cameraPosition.z * posRes),
          sin(frameTimeCounter * speed + pos.x * posRes + cameraPosition.x * posRes)
      );
  }

  float calcWindfall(float posRes, vec3 pos) {
      float random = max(sin(frameTimeCounter * 0.2) * cos(frameTimeCounter * 0.3), 0.0);
      float windfallX = (1.0 + sin(frameTimeCounter * 6.0 * WIND_SPEED + pos.z * posRes + cameraPosition.z * posRes)) * 5.0 * random;
      float windfallZ = sin(frameTimeCounter * 6.0 * WIND_SPEED + pos.x * posRes + cameraPosition.x * posRes) * 2.0 * random;
      return windfallX + windfallZ;
  }

  vec3 calcMove(vec3 pos, float mcID, bool isWeldedToGround, float strength, float posRes) {
      bool onGround = gl_MultiTexCoord0.t < mc_midTexCoord.t;
      vec3 movement = calcMovement(pos, posRes);
      float windfall = calcWindfall(posRes, pos);

      if (isWeldedToGround && mc_Entity.x == mcID && onGround) {
          pos.x += (movement.z + windfall) * strength;
          pos.y += movement.y * strength;
          pos.z += movement.x * strength;
      } else if (mc_Entity.x == mcID) {
          pos.x += (movement.z + windfall) * strength;
          pos.y += movement.y * strength;
          pos.z += movement.x * strength;
      }

      strength += strength * rainStrength;
      return pos;
  }

#endif

void main() {
  texcoord = gl_MultiTexCoord0.st;

  vec4 position = ftransform();
  position = shadowProjectionInverse * position;
  position = shadowModelViewInverse * position;

  #ifdef WINDY_TERRAIN
      position.xyz = calcMove(position.xyz, MC_SAPLINGS, true, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_OAK_LEAVES, false, 0.005, 10.0);
      position.xyz = calcMove(position.xyz, MC_GRASS, true, 0.05, 5.0);
      position.xyz = calcMove(position.xyz, MC_YELLOW_FLOWER, true, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_RED_FLOWER, true, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_WHEAT_CROPS, true, 0.02, 5.0);
      position.xyz = calcMove(position.xyz, MC_CARROTS, true, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_POTATOES, true, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_ACACIA_LEAVES, false, 0.005, 10.0);
      position.xyz = calcMove(position.xyz, MC_TALL_GRASS_LOWER, true, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_TALL_GRASS_UPPER, false, 0.01, 5.0);
      position.xyz = calcMove(position.xyz, MC_BEETROOT, true, 0.01, 5.0);	
  #endif

  position = shadowProjection * shadowModelView * position;

  float distortion = ((1.0 - SHADOW_MAP_BIAS) + length(position.xy * 1.165) * SHADOW_MAP_BIAS) * 0.97;
  position.xy /= distortion;
  position.z /= 2.5;

  worldPosition = (gl_ModelViewMatrix * gl_Vertex).xyz;
  normal = normalize(gl_NormalMatrix * gl_Normal);
  eyeDirection = normalize(cameraPosition - worldPosition);

  gl_Position = position;
  gl_FrontColor = gl_Color;
}
