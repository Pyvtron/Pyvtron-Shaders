
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


vec3 emissiveLight(vec3 clr, vec3 originalClr, bool emissive) {
    const float cover = 0.5;
    const float intensityBoost = 70.0;
    const float exposure = 0.1; 
    
    if (emissive) {
        // Calculate the luminance of the original color
        float luminance = max(dot(originalClr.rgb, vec3(0.299, 0.587, 0.114)) - cover, 0.0);
        
        clr += intensityBoost * luminance * originalClr;
        
        clr = pow(clr, vec3(exposure));
    }
    
    // Clamp the final color to ensure it stays within valid range
    return clamp(clr, 0.0, 1.0);
}
