#version 330 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/HDR.glsl"
#include "/Lib/Settings.glsl"

varying vec2 texcoord;

uniform sampler2D colortex1;
uniform sampler2D colortex7;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform vec3 sunPosition;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform int worldTime;
uniform int isEyeInWater;

uniform ivec2 eyeBrightness;

uniform float near;
uniform float far;
uniform float sunAngle;
uniform float rainStrength;
uniform float nightVision;
uniform float blindness;
uniform float sunColor;
uniform float biome;
uniform float frameTimeCounter;


#include "/Lib/TimeArray.glsl"

#ifdef DIRTY_LENS
    uniform sampler2D noisetex;
#endif

#if (LIGHT_SCATTERING > 0)

    #if (LIGHT_SCATTERING == 2)

        uniform sampler2DShadow shadow;
        uniform mat4 shadowProjection;
        uniform mat4 shadowModelView;
        uniform mat4 gbufferModelViewInverse;

        float linearDepth(float depth){
            return 2.0 * (near * far) / (far + near - (depth) * (far - near));
        }

        float depthX(float x){
            return ((far * (x - near)) / (x * (far - near)));
        }

    #endif

    float ditherGradNoise() {
            return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y +0.00623715));
    }

    float rand(vec2 n) {
        return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
    }

    vec3 lightScattering(vec3 fragpos, vec2 lightPos, vec3 color, vec3 sunColor) {

        float sunVector = max(dot(normalize(fragpos), normalize(sunPosition)), 0.0);
        float sun	= pow(sunVector, 12.0) * (1.0 - time[6]);

        float moonVector = max(dot(normalize(fragpos), normalize(-sunPosition)), 0.0);
        float moon	= pow(moonVector, 12.0) * time[5];

        float sample = 0.0;
        float dirtyLens = 0.0;

        // Godrays
        #if (LIGHT_SCATTERING == 1)

                const float godraysSamples = VOLUMETRIC_LIGHT_SAMPLES;
                const float noiseAmount    = 0.2;


            vec2 grCoord = texcoord.st;
            vec2 deltaTextCoord	 = texcoord.st - lightPos.xy;
                     deltaTextCoord	/= float(godraysSamples);

            for (int i = 0; i < godraysSamples; i++) {

                grCoord	-= deltaTextCoord * (1.0 - noiseAmount + rand(grCoord) * noiseAmount);
                sample += texture2D(colortex4, grCoord).a;

            }

            sample /= float(godraysSamples);

        // Volumetric Light
        #elif (LIGHT_SCATTERING == 2)


            float vlRenderQuality = VOLUMETRIC_LIGHT_RENDER_QUALITY;

            if (isEyeInWater == 1) vlRenderQuality *= 0.1;

            float i = ditherGradNoise() * vlRenderQuality - 0.1;

            while (i < distance(texcoord.x, VOLUMETRIC_LIGHT_RENDERDISTANCE)) {

                if (linearDepth(texture2D(depthtex1, texcoord).x * 2.0 - 1.0) < i) break;

                vec4 vlFragpos = gbufferProjectionInverse * vec4(vec3(texcoord.st * 2.0 - 1.0, depthX(i) * 2.0 - 1.0), 1.0);
                         vlFragpos /= vlFragpos.w;

                vec4 worldPos = gbufferModelViewInverse * vec4(vlFragpos.xyz, 1.0);

                worldPos = shadowModelView * worldPos;
                worldPos = shadowProjection * worldPos;
                worldPos /= worldPos.w;

                float distortion = ((1.0 - 0.8) + length(worldPos.xy * 1.165) * 0.8) * 0.97;
                worldPos.xy /= distortion;

                float bias = distortion * distortion * (0.0015 * tan(acos(pow(1.0, 1.1))));
                worldPos.xyz = worldPos.xyz * vec3(0.5, 0.5, 0.2) + vec3(0.5, 0.5, 0.5 - bias);

                sample += shadow2D(shadow, vec3(worldPos.st, worldPos.z)).x * pow(0.9, i);

                i += vlRenderQuality;

            }

            sample /= VOLUMETRIC_LIGHT_RENDERDISTANCE / vlRenderQuality;
            sample *= 4.0;

            // Adjust sample for underwater
            if (isEyeInWater == 1) sample *= 0.5;

        #endif

        #ifdef DIRTY_LENS
            dirtyLens = texture2D(noisetex, texcoord).g;
        #endif

        if (isEyeInWater == 1) sample *= eyeBrightness.y / 240.0;

        return color + sample * (sun + moon) * pow(sunColor, vec3(2.2)) * (0.5 + dirtyLens);

    }

#endif

#include "/Lib/UnderwaterFog.glsl"

vec3 blindnessFog(vec3 fragpos, vec3 color) {

  float fogFactor = 1.0 - exp(-pow(length(fragpos) * 0.4, 1.0));

  return color * (1.0 - blindness * fogFactor);

}

#ifdef DISTANCE_BLUR

    vec3 distanceBlur(vec2 coord, vec3 fragpos) {

        const bool colortex4MipmapEnabled = true;

        float depth = 1.0 - exp(-pow(length(fragpos.xyz) * 0.005, 2.0));

      return texture2DLod(colortex4, coord, depth).rgb * MAX_COLOR_RANGE;

    }

#endif


void main() {

  // x = 0; y = 1
    vec2 depth = vec2(texture2D(depthtex0, texcoord).x, texture2D(depthtex1, texcoord).x);

  float mat = texture2D(colortex1, texcoord).a;


  vec4 fragposition0  = gbufferProjectionInverse * (vec4(texcoord.st, depth.x, 1.0) * 2.0 - 1.0);
         fragposition0 /= fragposition0.w;

    vec4 fragposition1  = gbufferProjectionInverse * (vec4(texcoord.st, depth.y, 1.0) * 2.0 - 1.0);
         fragposition1 /= fragposition1.w;

  float comp = 1.0 - near / far / far;

  bool sky = depth.y > comp;
  bool land = depth.y < comp;

    bool hand = depth.x < 0.56;

  bool water = mat > 0.09 && mat < 0.11;
    bool gbuffers_water = mat > 0.09 && mat < 0.2;

    vec4 raindrops = texture2D(colortex7, texcoord);
    vec2 refraction = vec2(0.0);

    #ifdef HEATWAVE

        float	refractionMultiplier = 0.0005;
        float	refractionSpeed	= HEATWAVE_SPEED;
        float refractionSize = HEATWAVE_SIZE;
        float refractionStart = 75.0;

        float fogFactor = (1.0 - exp(-pow(length(fragposition1.xyz) / refractionStart, 2.0)));

        refraction += vec2(sin(frameTimeCounter * refractionSpeed + texcoord.x * 50.0 * refractionSize + texcoord.y * 25.0 * refractionSize)) * refractionMultiplier * fogFactor;

    #endif



    #ifdef RAINDROP_REFRACTION
        refraction = vec2(0.0, 0.015 * raindrops.a);
    #endif

  vec3 color = texture2D(colortex4, texcoord + refraction).rgb * MAX_COLOR_RANGE;

  #ifdef DISTANCE_BLUR
       color = distanceBlur(texcoord + refraction, fragposition1.xyz);
  #endif


    vec4 tpos = vec4(sunPosition, 1.0) * gbufferProjection;
             tpos = vec4(tpos.xyz / tpos.w, 1.0);
    vec2 pos = tpos.xy / tpos.z;
    vec2 lightPos = pos * 0.5 + 0.5;

  #include "/Lib/Colors.glsl"

    if (gbuffers_water) color = underwaterFog(fragposition0.xyz, color, waterColor * ambientColor * vec3(0.6, 1.0, 0.8) * 0.2, lavaColor);

    #if (LIGHT_SCATTERING > 0)
        color = pow(color, vec3(2.2));
        color = lightScattering(fragposition1.xyz, lightPos, color, sunColor);
        color = pow(color, vec3(1.0 / 2.2));
    #endif

    if (!hand) color += raindrops.rgb * 0.2;

    color = blindnessFog(fragposition1.xyz, color);

/* DRAWBUFFERS:4 */

  gl_FragData[0] = vec4(color / MAX_COLOR_RANGE, float(texture2D(depthtex1, lightPos).x > comp));

}