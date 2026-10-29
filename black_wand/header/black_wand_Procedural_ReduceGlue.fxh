#ifndef black_wand_PROCEDURAL_REDUCE_GLUE_FXH
#define black_wand_PROCEDURAL_REDUCE_GLUE_FXH

#include "black_wand_Primitive_Reduce.fxh"
#include "black_wand_Procedural_Color.fxh"

float3 black_wand_Proc_ReduceDetail(float3 centerColor, float3 averageColor, float strengthValue) { return black_wand_Primitive_ReduceCenterMinusAverage(centerColor, averageColor, strengthValue); }
float3 black_wand_Proc_ReduceAverageMix(float3 centerColor, float3 averageColor, float mixValue) { return black_wand_Primitive_ReduceAverageMix(centerColor, averageColor, mixValue); }
float black_wand_Proc_ReduceLumaDelta(float3 centerColor, float3 sampleColor) { return black_wand_Primitive_ReduceLumaDelta(centerColor, sampleColor); }
float3 black_wand_Proc_ReduceDeltaColor(float3 a, float3 b, float gainValue) { return black_wand_Primitive_ReduceDeltaColor(a, b, gainValue); }
float3 black_wand_Proc_ReduceMinMaxSpan(float3 minColor, float3 maxColor, float gainValue) { return saturate(abs(maxColor - minColor) * gainValue); }
float black_wand_Proc_ReduceVarianceApprox(float meanValue, float momentValue) { return max(0.0, momentValue - meanValue * meanValue); }
float3 black_wand_Proc_ReduceSharpenFromSample(float3 centerColor, float3 sampleColor, float strengthValue) { return saturate(centerColor + (centerColor - sampleColor) * strengthValue); }
float3 black_wand_Proc_ReduceBlurFromSample(float3 centerColor, float3 sampleColor, float mixValue) { return saturate(lerp(centerColor, sampleColor, saturate(mixValue))); }

#endif
