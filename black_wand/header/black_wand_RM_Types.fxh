#ifndef BLACK_WAND_RM_TYPES_FXH
#define BLACK_WAND_RM_TYPES_FXH 1

#ifndef BLACK_WAND_RM_COMPILE_MAX_STEPS
#define BLACK_WAND_RM_COMPILE_MAX_STEPS 8
#endif
#ifndef BLACK_WAND_RM_REFINE_STEPS
#define BLACK_WAND_RM_REFINE_STEPS 2
#endif
#ifndef BLACK_WAND_RM_AO_STEPS
#define BLACK_WAND_RM_AO_STEPS 2
#endif
#ifndef BLACK_WAND_RM_SHADOW_STEPS
#define BLACK_WAND_RM_SHADOW_STEPS 3
#endif
#ifndef BLACK_WAND_RM_PI
#define BLACK_WAND_RM_PI 3.14159265358979323846
#endif
#ifndef BLACK_WAND_RM_TAU
#define BLACK_WAND_RM_TAU 6.28318530717958647692
#endif
#ifndef BLACK_WAND_RM_GOLDEN_ANGLE
#define BLACK_WAND_RM_GOLDEN_ANGLE 2.39996322972865332223
#endif

struct black_wand_RM_Ray
{
    float3 origin;
    float3 direction;
    float  tMin;
    float  tMax;
};

struct black_wand_RM_Field
{
    float distanceValue;
    float materialId;
    float localBound;
};

struct black_wand_RM_Hit
{
    float hitFlag;
    float missCode;
    float t;
    float3 position;
    float distanceValue;
    float materialId;
    float stepCount;
    float lastStep;
    float travel01;
};

black_wand_RM_Field black_wand_RM_MakeField(float distanceValue, float materialId)
{
    black_wand_RM_Field f;
    f.distanceValue = distanceValue;
    f.materialId = materialId;
    f.localBound = abs(distanceValue);
    return f;
}

black_wand_RM_Hit black_wand_RM_MakeMiss(float missCode, float t, float3 position, float stepCount)
{
    black_wand_RM_Hit h;
    h.hitFlag = 0.0;
    h.missCode = missCode;
    h.t = t;
    h.position = position;
    h.distanceValue = 0.0;
    h.materialId = 0.0;
    h.stepCount = stepCount;
    h.lastStep = 0.0;
    h.travel01 = 0.0;
    return h;
}

#endif
