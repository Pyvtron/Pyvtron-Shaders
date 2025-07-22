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

uniform sampler2D texture;  
uniform sampler2D glintTexture;  

void main() {
    vec4 baseColor = texture2D(texture, texcoord) * color;

    vec4 glint = texture2D(glintTexture, texcoord);

    glint.rgb *= glintIntensity * 3.0;  

    vec4 finalColor = baseColor + glint; 

    gl_FragColor = finalColor;
}
