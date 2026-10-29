#ifndef black_wand_PROCEDURAL_HATCH_GLUE_FXH
#define black_wand_PROCEDURAL_HATCH_GLUE_FXH

#include "black_wand_Primitive_Hatch.fxh"
#include "black_wand_Procedural_Pattern.fxh"
#include "black_wand_Procedural_Color.fxh"

float black_wand_Proc_InputHatch(float hatchSource, float2 uv, float depthValue, float lumaValue, float phaseValue) { return black_wand_Primitive_InputHatchValue(int(hatchSource), uv, depthValue, lumaValue, phaseValue); }
float black_wand_Proc_HatchWeight(float hatchValue, float influenceValue) { return black_wand_Primitive_HatchWeightValue(hatchValue, influenceValue); }
float3 black_wand_Proc_HatchInk(float3 colorValue, float hatchValue, float strengthValue) { return black_wand_Primitive_HatchInkColor(colorValue, hatchValue, strengthValue); }
float3 black_wand_Proc_HatchDebug(float hatchValue) { return black_wand_Primitive_HatchDebugColor(hatchValue); }
float black_wand_Proc_HatchProceduralCross(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return black_wand_Proc_PatternCross(uv, frequencyValue, phaseValue, thicknessValue); }
float black_wand_Proc_HatchProceduralDiagonal(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return max(black_wand_Proc_PatternDiagonalA(uv, frequencyValue, phaseValue, thicknessValue), black_wand_Proc_PatternDiagonalB(uv, frequencyValue, phaseValue, thicknessValue)); }
float3 black_wand_Proc_HatchLumaInk(float3 colorValue, float hatchValue, float lumaValue, float strengthValue) { return lerp(colorValue, colorValue * saturate(1.0 - hatchValue * lumaValue), saturate(strengthValue)); }

#endif
