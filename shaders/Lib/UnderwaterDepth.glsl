
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


float underwaterDepth(vec3 fragmentPosition, vec3 userPosition) {
    vec3 vectorToUser = fragmentPosition - userPosition;
    vec3 normalizedVectorToUser = normalize(vectorToUser);
    vec3 normalVector = normalize(normal.rgb);
    
    float rawDot = dot(normalizedVectorToUser, normalVector);
    float absDot = abs(rawDot);
    
    float dist = length(vectorToUser);
    float distFactor = dist * 0.1;
    float distanceSquared = dist * dist;
    
    float weightedFactor = distFactor * absDot * distanceSquared;
    float intermediate = clamp(weightedFactor, 0.0, 1.0);
    
    float complexDepth = 1.0 - intermediate * (1.0 - absDot);
    float finalEffect = complexDepth * pow(intermediate, 2.0);
    
    float finalDepth = finalEffect * (sin(dist) + cos(absDot));
    return finalDepth;
}
