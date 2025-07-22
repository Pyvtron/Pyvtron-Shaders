#version 460 compatibility

/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


layout(location = 0) out vec4 compositeOutput2;


#include "/Lib/Uniforms.glsl"

const bool		colortex1MipmapEnabled  = true;


in vec4 texcoord;

vec3 LinearToGamma(vec3 c)
{
    return pow(c, vec3(1.0 / 2.2));
}

vec3 GammaToLinear(vec3 c)
{
    return pow(c, vec3(2.2));
}

vec3 GrabBlurH(vec2 coord, const float octave, const vec2 offset)
{
	float scale = exp2(octave);

	coord += offset;
	coord *= scale;

	vec2 texel = scale * pixelSize;

	vec2 lowBound  = texel * vec2(-10.0f);
	vec2 highBound = texel * vec2( 10.0f) + vec2(1.0f);

	if (coord.x < lowBound.x || coord.x > highBound.x || coord.y < lowBound.y || coord.y > highBound.y)
	{
		return vec3(0.0);
	}

	vec3 color = vec3(0.0);

	float weights[5] = float[5](0.27343750, 0.21875000, 0.10937500, 0.03125000, 0.00390625);
	float offsets[5] = float[5](0.00000000, 1.00000000, 2.00000000, 3.00000000, 4.00000000);

	color += GammaToLinear(textureLod(colortex1, coord, octave).rgb) * weights[0];

	for (int i = 1; i < 5; i++)
	{
		color += GammaToLinear(textureLod(colortex1, texel * vec2(offsets[i], 0.0) + coord, octave).rgb) * weights[i];
		color += GammaToLinear(textureLod(colortex1, -texel * vec2(offsets[i], 0.0) + coord, octave).rgb) * weights[i];
	}

	return color;
}


vec2 CalcOffset(float octave)
{
    vec2 offset = vec2(0.0);

    vec2 padding = vec2(30.0) * pixelSize;

    offset.x = -min(3.0, floor(octave / 2.0)) * (0.25 + padding.x);
    offset.y = -(1.0 - (1.0 / exp2(octave))) - padding.y * octave;
	offset.y += min(3.0, floor(octave / 2.0)) * 0.25;

 	return offset;
}



/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {
	vec3 color = vec3(0.0);

	color += GrabBlurH(texcoord.st, 1.0, vec2(0.0, 0.0));
	color += GrabBlurH(texcoord.st, 2.0, CalcOffset(1.0));
	color += GrabBlurH(texcoord.st, 3.0, CalcOffset(2.0));
	color += GrabBlurH(texcoord.st, 4.0, CalcOffset(3.0));
	color += GrabBlurH(texcoord.st, 5.0, CalcOffset(4.0));
	color += GrabBlurH(texcoord.st, 6.0, CalcOffset(5.0));
	color += GrabBlurH(texcoord.st, 7.0, CalcOffset(6.0));
	color += GrabBlurH(texcoord.st, 8.0, CalcOffset(7.0));
	color += GrabBlurH(texcoord.st, 9.0, CalcOffset(8.0));

	color = LinearToGamma(color);

	compositeOutput2 = vec4(color.rgb, 0.0);
}

/* DRAWBUFFERS:2 */
