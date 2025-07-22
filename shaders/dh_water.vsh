#version 460 compatibility

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texCoord0;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelMatrix;
uniform float time;
uniform float waveStrength;

out vec2 texCoord;
out vec3 fragPosition;

void main() {
    vec3 pos = position;
    
    float wave = sin(pos.x * 10.0 + time * 0.5) * 0.02;
    wave += sin(pos.z * 15.0 + time * 0.3) * 0.015;
    pos.y += wave * waveStrength;
    
    fragPosition = (modelMatrix * vec4(pos, 1.0)).xyz;
    texCoord = texCoord0;
    
    texCoord = mod(texCoord, 1.0);
    
    gl_Position = modelViewProjectionMatrix * vec4(pos, 1.0);
}