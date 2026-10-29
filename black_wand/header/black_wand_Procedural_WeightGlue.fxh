#ifndef black_wand_PROCEDURAL_WEIGHT_GLUE_FXH
#define black_wand_PROCEDURAL_WEIGHT_GLUE_FXH

#include "black_wand_Primitive_Weight.fxh"
#include "black_wand_Procedural_SafeMath.fxh"

float black_wand_Proc_TapWeight(int weightMode, float2 canonicalOffset, int tapIndex, int activeTapCount, float centerWeight, float falloffPower) { return black_wand_Primitive_TapWeightValue(weightMode, canonicalOffset, tapIndex, activeTapCount, centerWeight, falloffPower); }
float black_wand_Proc_CombineWeights(float gateValue, float maskWeightValue, float hatchWeightValue, float tapWeightValue) { return black_wand_Primitive_CombineGateMaskHatchWeight(gateValue, maskWeightValue, hatchWeightValue, tapWeightValue); }
float black_wand_Proc_NormalizeWeight(float weightValue, float weightSum) { return black_wand_Proc_SafeDivide(weightValue, weightSum); }
float black_wand_Proc_WeightDebugScalar(float weightValue, float gainValue) { return saturate(weightValue * gainValue); }
float3 black_wand_Proc_WeightDebugColor(float tapWeight, float gateWeight, float maskWeight) { return saturate(float3(tapWeight, gateWeight, maskWeight)); }

#endif
