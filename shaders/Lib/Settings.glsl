
/*
====================================================================================================

    Copyright (C) 2025 Pyvtron Shaders - Pyvtron

    All Rights Reserved unless otherwise explicitly stated.

====================================================================================================
*/


//#define DEPTH_OF_FIELD
//#define DIRTY_LENS
#define LIGHT_SCATTERING 1 // [0 1 2]
//#define DISTANCE_BLUR
#define VOLUMETRIC_LIGHT_SAMPLES 10.0 // [5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0]
#define VOLUMETRIC_LIGHT_RENDERDISTANCE 50.0 // [10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0 90.0 100.0 110.0 120.0 130.0 140.0 150.0 160.0 170.0 180.0 190.0 200.0]
#define VOLUMETRIC_LIGHT_RENDER_QUALITY 5.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0]
//#define RAINDROP_REFRACTION
//#define HEATWAVE
#define HEATWAVE_SPEED 2.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0]
#define HEATWAVE_SIZE 2.0 // [0.0 1.0 2.0 3.0 4.0 5.0 6.0 8.0 10.0]
#define NETHER_HEATWAVE
#define NETHER_HEATWAVE_SPEED 5.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0]
#define NETHER_HEATWAVE_SIZE 2.0 // [0.0 2.0 4.0 6.0 8.0 10.0]
//#define END_HEATWAVE
#define END_HEATWAVE_SPEED 5.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0]
#define END_HEATWAVE_SIZE 2.0 // [0.0 2.0 4.0 6.0 8.0 10.0]


//#define MOTIONBLUR
#define MOTIONBLUR_AMOUNT 1.0 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define MOTION_BLUR_STRENGTH 1.0 // [1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0]
#define MOTION_BLUR_DITHER
#define MOTION_BLUR_QUALITY 3 // [2 3 5 10 20 30 50 100]
#define MOTION_BLUR_SUTTER_ANGLE 180.0 // [45.0 90.0 135.0 180.0 270.0 360.0]



#define SSR_METHOD 1 // [0 1]
//#define PBR
//#define RAIN_PUDDLES
#define TONEMAPPING	
#define SATURATION 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define EXPOSURE 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define BRIGHTNESS 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CONTRAST 1.0 // [0.1 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define WHITESCALE 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
//#define CHROMATIC_ABERRATION
//#define VIGNETTE
#define VIGNETTE_STRENGTH 1.0 // [0.5 1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
#define VIGNETTE_SHARPNESS 5.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0]
#define LENS_POWER 0.2 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define LENS_FLARE



//#define BLOOM
#define BLOOM_KEEP_BRIGHTNESS
#define BLOOM_DARK_SCENE_BOOSTING
#define BLOOM_BOOSTING_MULTIPLIER 1.5 // [0.5 0.7 1.0 1.5 2.0 3.0 4.0 5.0 7.0 10.0 15.0 20.0 30.0 50.0]







//#define DEPTH_OF_FIELD
//#define FILM_GRAIN
//#define CINEMATIC_MODE
#define TEMPERATURE 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SHADOW_MAP_BIAS 0.8
#define SOFT_SHADOWS
#define FIX_SUNLIGHT_LEAK
#define NORMAL_MAP_BUMPMULT 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
//#define AUTO_BUMP
#define TEXTURE_RESOLUTION 64 // [16 32 64 128 256 512]
//#define TORCH_NORMALS
//#define POM
#define POM_DEPTH 7.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0]
//#define PBR
//#define RAIN_PUDDLES
#define WATER_REFRACTION_STRENGTH 0.3 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define BLOOM_SAMPLES 32 // [4 8 16 32 64 128]
#define SSR_SAMPLES 450 // [50 100 150 200 250 300 350 400 450 500 550 600]
#define AMBIENT_LIGHT_BRIGHTNESS 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SUNLIGHT_BRIGHTNESS 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define RIPPLE_SPEED 0.8 // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define OVERRIDE_FOLIAGE_COLOR
#define POM_QUALITY 128 // [8 16 32 64 128 256 512 1024 2048 3072 4096]
#define SHADOW_BRIGHTNESS 0.08 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WINDY_TERRAIN
#define WIND_SPEED 1.0 // [0.1 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define WATER_WAVE_SPEED 0.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_WAVE_SCALE 0.4 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_WAVES_AMOUNT 0.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WATER_CAUSTICS
#define WATER_CAUSTICS_AMOUNT 0.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define DEPTH_OF_FIELD_AMOUNT 0.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
#define DEPTH_OF_FIELD_RANGE 0.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]


