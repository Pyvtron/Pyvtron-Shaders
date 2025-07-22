
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


#define TEMPERATURE 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define TORCHLIGHT_TEMPERATURE 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

float sunOffset = abs(sunAngle - 0.25) * 4.0;
float sunFactor = clamp(1.0 - pow(sunOffset, 2.0 / max(sunOffset, 0.0001)), 0.0, 1.0);

vec3 ambientColor = mix(vec3(0.78, 0.87, 1.0) * 0.4, vec3(0.55, 0.72, 1.0), sunFactor) * (1.0 - time[5]);  
ambientColor += vec3(0.45, 0.65, 0.85) * 0.2 * time[5]; 
ambientColor *= 1.0 - rainStrength;  

ambientColor += vec3(0.9, 0.95, 1.0) * 0.9 * rainStrength * (1.0 - time[5]); 
ambientColor += vec3(0.6, 0.73, 1.0) * 0.3 * rainStrength * time[5];

ambientColor = mix(ambientColor, normalize(ambientColor), nightVision * time[5]);
ambientColor = mix(ambientColor, vec3(0.0, 0.5, 1.0), (1.0 - TEMPERATURE) * 0.25);

ambientColor *= vec3(1.0, 1.0, 1.0) - pow(time[5], 2.0) * 0.5;  
ambientColor *= 1.0 - 0.2 * (1.0 - rainStrength);  
ambientColor *= 1.0 + 0.3 * pow(sin(time[0] * 0.1), 2.0);  


vec3 sunColor = mix(vec3(1.0, 0.8, 0.4), vec3(1.0, 1.0, 0.9), sunFactor) * (1.0 - time[6]);
sunColor += vec3(0.8, 0.8, 1.0) * 0.1 * time[5]; 
sunColor *= 1.0 - rainStrength;

vec3 waterColor = vec3(0.1, 0.8, 1.0); 

vec3 lavaColor = vec3(1.0, 0.35, 0.05); 

vec3 torchColor = vec3(1.0, 0.36, 0.18);


 





