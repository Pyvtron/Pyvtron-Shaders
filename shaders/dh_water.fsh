#version 460 compatibility

uniform sampler2D waterTexture;
uniform sampler2D noiseTexture;
uniform vec3 sunDirection;
uniform vec3 cameraPosition;
uniform float time;
uniform float waveStrength;

in vec2 texCoord;
in vec3 fragPosition;
out vec4 fragColor;

void main() {
    vec2 uv = texCoord;
    vec2 noise = texture(noiseTexture, uv * 4.0 + time * 0.02).xy * 2.0 - 1.0;
    
    float wave = sin(uv.x * 10.0 + time * 0.5) * 0.02;
    wave += sin(uv.y * 15.0 + time * 0.3) * 0.015;
    uv += noise * 0.01 * waveStrength;
    
    uv = mod(uv, 1.0);
    
    vec4 waterColor = texture(waterTexture, uv);
    
    vec3 viewDir = normalize(cameraPosition - fragPosition);
    float fresnel = clamp(dot(viewDir, sunDirection), 0.0, 1.0);
    fresnel = pow(1.0 - fresnel, 5.0);
    
    vec3 reflectedLight = mix(vec3(0.0, 0.1, 0.2), vec3(0.3, 0.5, 0.8), fresnel);
    
    float distanceFactor = clamp(length(fragPosition - cameraPosition) / 500.0, 0.0, 1.0);
    vec3 finalColor = mix(waterColor.rgb, reflectedLight, distanceFactor * 0.3);
    
    fragColor = vec4(finalColor, waterColor.a);
}