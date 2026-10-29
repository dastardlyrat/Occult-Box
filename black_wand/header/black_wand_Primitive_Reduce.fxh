#ifndef black_wand_PRIMITIVE_REDUCE_FXH
#define black_wand_PRIMITIVE_REDUCE_FXH

#include "black_wand_Reduce_Server.fxh"

float3 black_wand_Primitive_ReduceCenterMinusAverage(float3 centerColor, float3 averageColor, float strengthValue)
{
    return saturate(centerColor + (centerColor - averageColor) * max(0.0, strengthValue));
}

float3 black_wand_Primitive_ReduceAverageMix(float3 centerColor, float3 averageColor, float mixValue)
{
    return saturate(lerp(centerColor, averageColor, saturate(mixValue)));
}

float black_wand_Primitive_ReduceLumaDelta(float3 centerColor, float3 sampleColor)
{
    return saturate(abs(black_wand_Reduce_Luma(centerColor) - black_wand_Reduce_Luma(sampleColor)));
}

float3 black_wand_Primitive_ReduceDeltaColor(float3 colorA, float3 colorB, float gainValue)
{
    return saturate(abs(colorA - colorB) * max(0.0, gainValue));
}

#endif
