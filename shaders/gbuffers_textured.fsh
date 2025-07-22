#version 460 compatibility
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/HDR.glsl"
#include "/Lib/Settings.glsl"

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 tangent;
varying vec4 normal;
varying vec3 binormal;
varying vec4 viewVector;
varying vec4 worldposition;
varying vec4 color;

uniform sampler2DShadow shadowtex0;
uniform sampler2D texture;
uniform sampler2D normals;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform vec3 shadowLightPosition;

uniform ivec2 eyeBrightness;

uniform int isEyeInWater;
uniform int worldTime;

uniform float rainStrength;
uniform float sunAngle;
uniform float screenBrightness;
uniform float nightVision;
uniform float viewWidth;
uniform float viewHeight;

#if defined POM || defined AUTO_BUMP
  varying vec4 vtexcoordam;
  varying vec4 vtexcoord;
#endif


const int shadowMapResolution = 2048; // [256 512 1024 1536 2048 3172 4096 6344 8192 16384]
const float shadowDistance = 128.0; // [32.0 64.0 80.0 96.0 112.0 128.0 144.0 160.0 176.0 192.0 208.0 224.0 240.0 256.0 272.0 288.0 304.0 320.0 336.0 352.0 368.0 384.0 512.0 768.0 1024.0 1536.0 2048.0 4096.0 8192.0]
const bool shadowHardwareFiltering = true;

#include "/Lib/TimeArray.glsl"

vec2 dcdx = dFdx(texcoord);
vec2 dcdy = dFdy(texcoord);

float luma(vec3 clr) {
    return dot(clr, vec3(0.3333));
}

float encodeLightmap(vec2 a) {

  ivec2 bf = ivec2(a * 255.0);
  return float(bf.x | (bf.y << 8)) / 65535.0;

}

vec2 encodeNormal(vec3 normal) {

  return normal.xy * inversesqrt(normal.z * 8.0 + 8.0) + 0.5;

}

bool material(float id) {

    if (normal.a > id - 0.01 && normal.a < id + 0.01) {
        return true;
    } else {
        return false;
    }

}

mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                                            tangent.y, binormal.y, normal.y,
                                            tangent.z, binormal.z, normal.z);



#include "/Lib/TorchLightmap.glsl"
#include "/Lib/EmissiveLight.glsl"

#ifdef TORCH_NORMALS

    float torchLambertian(vec3 viewNormal, float lightmap) {

        vec3 Q1 = dFdx(viewVector.xyz);
        vec3 Q2 = dFdy(viewVector.xyz);
        float st1 = dFdx(lightmap);
        float st2 = dFdy(lightmap);

        st1 /= luma(fwidth(viewVector.xyz));
        st2 /= luma(fwidth(viewVector.xyz));
        vec3 T = Q1 * st2 - Q2 * st1;
        T = normalize(T + normal.xyz * 0.0002);
        T = -cross(T, normal.xyz);

        T = normalize(T + normal.xyz * 0.01);
        T = normalize(T + normal.xyz * 0.85 * lightmap);


        float torchLambert  = pow(clamp(dot(T, viewNormal.xyz) * 1.0 + 0.0, 0.0, 1.0), 1.0);
                    torchLambert += pow(clamp(dot(T, viewNormal.xyz) * 0.4 + 0.6, 0.0, 1.0), 1.0) * 0.5;

        if (dot(T, normal.xyz) > 0.99) torchLambert = pow(torchLambert, 2.0) * 0.45;

        return torchLambert;

    }

#endif

float bouncedLight(vec3 normal, float lightmap) {
    float bouncedLightStrength = SHADOW_BRIGHTNESS;

    float shadowLength = 1.0 - abs(-0.25 + sunAngle) * 4.0;

    // Multiple bounce calculations for more complex reflections
    float bounce0 = max(dot(normal, -normalize(shadowLightPosition)), 0.0);
    float bounce1 = max(dot(normal, normalize(shadowLightPosition)), 0.0);
    float bounce2 = max(dot(normal, normalize(shadowLightPosition)), 0.0); 
    float bounce3 = max(dot(normal, normalize(shadowLightPosition)), 0.0);  
    float bounce4 = max(dot(normal, normalize(shadowLightPosition)), 0.0);
    float bounce5 = max(dot(normal, normalize(shadowLightPosition)), 0.0);
    float bounce6 = max(dot(normal, normalize(shadowLightPosition)), 0.0);
    float bounce7 = max(dot(normal, normalize(shadowLightPosition)), 0.0);
    float bounce8 = max(dot(normal, normalize(shadowLightPosition)), 0.0);
    float bounce9 = max(dot(normal, normalize(shadowLightPosition)), 0.0);

    // Ground reflection to simulate light bounce from surfaces
    float ground = max(dot(normal, normalize(upPosition)), 0.0);

    // Calculate light intensity from multiple bounces
    float light = mix(
        bounce0 * 0.5,
        bounce1 * (1.0 - ground) * shadowLength * 3.0,
        1.0 - lightmap
    ) * smoothstep(0.5, 1.0, color.a);

    // Add multiple bounce strength
    return light * lightmap * bouncedLightStrength
           + bounce1 * bouncedLightStrength * 0.5 * smoothstep(0.8, 1.0, lightmap)
           + bounce2 * bouncedLightStrength * 0.25 * smoothstep(0.6, 1.0, lightmap)
           + bounce3 * bouncedLightStrength * 0.2 * smoothstep(0.6, 1.0, lightmap)
           + bounce4 * bouncedLightStrength * 0.15 * smoothstep(0.7, 1.0, lightmap)
           + bounce5 * bouncedLightStrength * 0.1 * smoothstep(0.7, 1.0, lightmap)
           + bounce6 * bouncedLightStrength * 0.05 * smoothstep(0.8, 1.0, lightmap)
           + bounce7 * bouncedLightStrength * 0.04 * smoothstep(0.8, 1.0, lightmap)
           + bounce8 * bouncedLightStrength * 0.03 * smoothstep(0.9, 1.0, lightmap)
           + bounce9 * bouncedLightStrength * 0.02 * smoothstep(0.9, 1.0, lightmap);
}

#include "/Lib/LowLightEye.glsl"

float subsurfaceScattering(vec3 fragpos, bool translucent) {

  const float strength = 5.0;

  float sunVector = max(dot(normalize(fragpos), normalize(sunPosition)), 0.0);
    float light	= pow(sunVector, 2.0) * float(translucent);

  return light * strength;

}

float calcShadows(vec3 fragpos, float NdotL, bool translucent) {

    float shadowSmoothnessFactor = 1.0 / shadowMapResolution * 0.7;

    float diffuse = translucent? 0.75 : NdotL;
    float shading = 1.0;

    float dist = length(fragpos.xyz);
    float shadowDistanceScale = shadowDistance * (1.0 + (128.0 / shadowDistance));
    float shadowFade = clamp((1.0 - dist / shadowDistanceScale) * 12.0, 0.0, 1.0);

    if (diffuse > 0.001 && dist < shadowDistanceScale) {

        vec4 worldPos = gbufferModelViewInverse * vec4(fragpos, 1.0);
                 worldPos = shadowModelView * worldPos;
             	 worldPos = shadowProjection * worldPos;

        float distortion = ((1.0 - SHADOW_MAP_BIAS) + length(worldPos.xy * 1.165) * SHADOW_MAP_BIAS) * 0.97;
        worldPos.xy /= distortion;

        float shadowAcneFix = 2048.0 / shadowMapResolution;

        float bias = translucent? 0.00025 : distortion * distortion * (0.0015 * tan(acos(pow(diffuse, 1.1)))) * shadowAcneFix;
        worldPos.xyz = worldPos.xyz * vec3(0.5, 0.5, 0.2) + vec3(0.5, 0.5, 0.5 - bias);

        #ifdef SOFT_SHADOWS

            shading = 0.0;

            vec2 offsets[4] = vec2[4](vec2(1.0, 0.0), vec2(0.0, 1.0), vec2(-1.0, 0.0), vec2(0.0, -1.0));

            for (int i = 0; i < 4; i++) {

                shading += shadow2D(shadowtex0, vec3(worldPos.xy + offsets[i] * shadowSmoothnessFactor, worldPos.z)).x * 0.25;

            }

        #else

            shading = shadow2D(shadowtex0, worldPos.xyz).x;

        #endif

    }

    #ifdef FIX_SUNLIGHT_LEAK
        shading *= (lmcoord.y < 0.1? eyeBrightness.y / 240.0 : 1.0);
    #endif

    return mix(NdotL, shading * diffuse, shadowFade);

}

vec3 toNDC(vec3 pos){
    vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2. - 1.;
    vec4 fragpos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

#if defined PBR || defined RAIN_PUDDLES

    uniform sampler2D specular;

#ifdef RAIN_PUDDLES

        uniform sampler2D noisetex;
        uniform float frameTimeCounter;

        float wetnessMap = smoothstep(0.9, 0.95, lmcoord.y);

        float puddleMap = min(max(texture2D(noisetex, worldposition.xz * 0.05).a - 0.5, 0.0) * 10.0, 1.0) * wetnessMap;

        float getRippleEffect(vec3 worldPos) {

            const float rippleSpeed = RIPPLE_SPEED;

            float phase1 = sin(frameTimeCounter * rippleSpeed);
            float phase2 = cos(frameTimeCounter * rippleSpeed);
            float ripple = 0.0;

            if (phase1 > 0.0) {
                ripple += texture2D(noisetex, worldPos.xz * 0.5).b * 0.05 * abs(phase1);
            } else {
                ripple += texture2D(noisetex, worldPos.xz * 0.5 + vec2(0.5)).b * 0.05 * abs(phase1);
            }

            if (phase2 > 0.0) {
                ripple += texture2D(noisetex, worldPos.xz * 0.7).b * 0.05 * abs(phase2);
            } else {
                ripple += texture2D(noisetex, worldPos.xz * 0.7 + vec2(0.2)).b * 0.05 * abs(phase2);
            }

          return ripple;

        }

        vec3 textureToNormal(vec3 pos) {

          float deltaPos = 0.2;
            float h0 = getRippleEffect(pos.xyz);
            float h1 = getRippleEffect(pos.xyz + vec3(deltaPos, 0.0, 0.0));
            float h2 = getRippleEffect(pos.xyz + vec3(-deltaPos, 0.0, 0.0));
            float h3 = getRippleEffect(pos.xyz + vec3(0.0, 0.0, deltaPos));
            float h4 = getRippleEffect(pos.xyz + vec3(0.0, 0.0, -deltaPos));

            float xDelta = ((h1 - h0) + (h0 - h2)) / deltaPos;
            float yDelta = ((h3 - h0) + (h0 - h4)) / deltaPos;

            return normalize(vec3(xDelta, yDelta, 1.0 - xDelta * xDelta - yDelta * yDelta));

        }

    #endif


vec3 PBRData(float NdotUp, bool translucent) {

        vec4 spec = texture2D(specular, texcoord);

        float roughness = 2.0;
        float metallic = 1.0;
        float specularity = luma(spec.rgb);







    

        #ifdef RAIN_PUDDLES

            specularity = mix(specularity + 0.25 * rainStrength * NdotUp * wetnessMap, 1.0, puddleMap * NdotUp * rainStrength);
            if (translucent) specularity = 0.0;
            roughness = mix(roughness, 0.0, puddleMap * NdotUp * rainStrength);
            //metallic = mix(metallic, 0.0, puddleMap * NdotUp);

        #endif

        return vec3(roughness, metallic, specularity);

    }

#endif

vec3 getNormals(vec2 coord) {

    vec3 bump  = texture2DGradARB(normals, coord, dcdx, dcdy).rgb * 2.0 - 1.0;

    #ifdef AUTO_BUMP

        float offset = 1.0 / TEXTURE_RESOLUTION;

        float M = abs(luma(texture2D(texture, fract(vtexcoord.st + vec2(0.0, 0.0)) * vtexcoordam.pq + vtexcoordam.xy).rgb));
        float L = abs(luma(texture2D(texture, fract(vtexcoord.st + vec2(offset, 0.0)) * vtexcoordam.pq + vtexcoordam.xy).rgb));
        float R = abs(luma(texture2D(texture, fract(vtexcoord.st + vec2(-offset, 0.0)) * vtexcoordam.pq + vtexcoordam.xy).rgb));
        float U = abs(luma(texture2D(texture, fract(vtexcoord.st + vec2(0.0, offset)) * vtexcoordam.pq + vtexcoordam.xy).rgb));
        float D = abs(luma(texture2D(texture, fract(vtexcoord.st + vec2(0.0, -offset)) * vtexcoordam.pq + vtexcoordam.xy).rgb));
        float X = (R - M) + (M - L);
        float Y = (D - M) + (M - U);

        bump = vec3(X, Y, 0.3);

    #endif

    #ifdef RAIN_PUDDLES
         bump  = mix(bump, textureToNormal(worldposition.xyz), puddleMap * rainStrength);
    #endif

    bump *= vec3(NORMAL_MAP_BUMPMULT) + vec3(0.0, 0.0, 1.0 - NORMAL_MAP_BUMPMULT);

    return normalize(bump * tbnMatrix);

}

#ifdef POM

    float readAlpha(in vec2 coord) {
        return texture2DGradARB(normals, fract(coord) * vtexcoordam.pq + vtexcoordam.st, dcdx, dcdy).a;
    }

    vec2 parallaxMapping(vec2 coord, vec3 fragpos) {

        const float pomQuality = POM_QUALITY;
        const float maxOcclusionDistance = 32.0;
        const float mixOcclusionDistance = 28.0;
        const int   maxOcclusionPoints = 256;

        vec2 newCoord = coord;

        vec3 vwVector = normalize(tbnMatrix * viewVector.xyz);

        vec3 intervalMult = vec3(1.0, 1.0, 10.0 - POM_DEPTH) / pomQuality;

        float dist = length(fragpos.xyz);

        if (dist < maxOcclusionDistance) {

            if (vwVector.z < 0.0 && readAlpha(vtexcoord.xy) < 0.99 && readAlpha(vtexcoord.xy) > 0.01) {
                vec3 interval = vwVector.xyz * intervalMult;
                vec3 coord = vec3(vtexcoord.xy, 1.0);

                for (int loopCount = 0; (loopCount < maxOcclusionPoints) && (readAlpha(coord.st) < coord.p); ++loopCount) {
                    coord = coord + interval;
                }

                float mincoord = 1.0 / 4096.0;

                // Don't wrap around top of tall grass/flower
                if (coord.t < mincoord) {
                    if (readAlpha(vec2(coord.s, mincoord)) == 0.0) {
                        coord.t = mincoord;
                        discard;
                    }
                }

                newCoord = mix(fract(coord.st) * vtexcoordam.pq + vtexcoordam.xy, newCoord, max(dist - mixOcclusionDistance, 0.0) / (maxOcclusionDistance - mixOcclusionDistance));

            }

        }

        return newCoord;

    }

#endif


void main() {

    bool hand = gl_FragCoord.z < 0.56;
    bool translucent = material(0.2);
    bool emissive = material(0.3);

    vec3 fragposition = toNDC(vec3(gl_FragCoord.xy / vec2(viewWidth,viewHeight), hand? gl_FragCoord.z + 0.38 : gl_FragCoord.z));

    vec2 newTexcoord = texcoord;
  #ifdef POM
    newTexcoord = parallaxMapping(texcoord, fragposition);
  #endif

    vec4 albedo = texture2D(texture, newTexcoord);
    #ifdef OVERRIDE_FOLIAGE_COLOR
        albedo *= mix(color, color * vec4(1.8, 1.4, 1.0, 1.0), 1.0 - luma(color.rgb));
    #else
        albedo *= color;
    #endif

    vec4 baseColor = albedo;
    vec3 newNormal = hand? normal.rgb : getNormals(newTexcoord);

    float NdotL = clamp(dot(newNormal, normalize(shadowLightPosition)), 0.0, 1.0);
    float NdotUp = clamp(dot(newNormal, normalize(upPosition)), float(translucent), 1.0);

    #include "/Lib/Colors.glsl"

    const float ambientStrength = 0.4;
    const float skyLight = 0.2;
    const float sunlightStrength = 0.7;

    float shading = calcShadows(fragposition.xyz, NdotL, translucent);
    float minLight = 0.03 + screenBrightness * 0.06;

    if (isEyeInWater == 1) shading *= lmcoord.y;

    float smoothLighting = 0.3 + color.a * 0.7;
    vec3 torchlight = getTorchLightmap(normal.xyz, lmcoord.x, lmcoord.y, translucent) * torchColor;
    #ifdef TORCH_NORMALS
             torchlight *= torchLambertian(newNormal, lmcoord.x);
    #endif

    vec3 ambientLightmap = (minLight + ambientColor * ambientStrength * AMBIENT_LIGHT_BRIGHTNESS * mix(lmcoord.y, 1.0, min(nightVision + shading, 1.0)) * (1.0 + NdotUp * skyLight)) * smoothLighting + (shading * (sunlightStrength * SUNLIGHT_BRIGHTNESS + subsurfaceScattering(fragposition.xyz, translucent)) + bouncedLight(newNormal, lmcoord.y)) * sunColor;
             ambientLightmap *= 1.0 - smoothstep(0.9, 0.95, lmcoord.y) * rainStrength * 0.25 * NdotUp;
             ambientLightmap += torchlight;
             ambientLightmap = emissiveLight(ambientLightmap, baseColor.rgb * torchColor, emissive);

    baseColor.rgb = lowlightEye(baseColor.rgb, ambientLightmap);

    baseColor.rgb *= ambientLightmap;

    if (isEyeInWater == 1) {

        baseColor.rgb *= mix(vec3(2.0), mix(waterColor * ambientColor, vec3(0.1, 0.8, 1.0), pow(max(lmcoord.y, 0.0), 1.5)), (1.0 - pow(lmcoord.y, 4.0)) * (1.0 - lmcoord.x));

    }



/* DRAWBUFFERS:0124 */

  gl_FragData[0] = vec4(baseColor.rgb / MAX_COLOR_RANGE, baseColor.a);
  gl_FragData[1] = vec4(encodeLightmap(lmcoord), encodeNormal(newNormal), normal.a);
    gl_FragData[3] = vec4(albedo.rgb, shading);

    #if defined PBR || defined RAIN_PUDDLES
        gl_FragData[2] = vec4(hand? vec3(0.0) : PBRData(NdotUp, translucent), 1.0);
    #endif

}