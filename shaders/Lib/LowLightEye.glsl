
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


vec3 lowlightEye(vec3 color, vec3 ambientLightmap) {
    float colorLuma = luma(color);
    float ambientLuma = max(1.0 - luma(ambientLightmap), 0.0);
    return mix(color, vec3(colorLuma), pow(ambientLuma, 4.0));
}
