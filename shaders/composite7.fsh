#version 460 compatibility
#extension GL_ARB_gpu_shader5 : enable

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron VX Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#include "/Lib/Uniforms.glsl"

in vec4 texcoord;

#include "/Lib/FXAA.glsl"

vec3 LinearToGamma(vec3 c)
{
    return pow(c, vec3(1.0 / 2.2));
}

vec3 GammaToLinear(vec3 c)
{
    return pow(c, vec3(2.2));
}


void main() {

	vec4 col = vec4(0.0);

	#if FINAL_FXAA > 1
		col = vec4(DoFXAASimple(colortex0, texcoord.st, ScreenTexel * 1.0).rgb, texture2DLod(colortex0, texcoord.st, 0).a);
	#else
		col = texture2DLod(colortex0, texcoord.st, 0);
	#endif

	gl_FragData[0] = col;
}

/* DRAWBUFFERS:0 */
