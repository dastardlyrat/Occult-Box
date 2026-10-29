#ifndef black_wand_PRIMITIVE_WEIGHT_FXH
#define black_wand_PRIMITIVE_WEIGHT_FXH

#include "black_wand_Weight_Server.fxh"

float black_wand_Primitive_TapWeightValue(int tapWeightMode, float2 canonicalOffset, int tapIndex, int activeTapCount, float centerWeight, float falloffPower)
{
    int safeActiveTapCount = max(1, activeTapCount);
    int safeTapIndex = clamp(tapIndex, 0, safeActiveTapCount - 1);
    return saturate(black_wand_Weight_Evaluate(tapWeightMode, canonicalOffset, safeTapIndex, safeActiveTapCount, centerWeight, falloffPower));
}

float black_wand_Primitive_CombineGateMaskHatchWeight(float gateValue, float maskWeightValue, float hatchWeightValue, float tapWeightValue)
{
    return saturate(gateValue) * saturate(maskWeightValue) * saturate(hatchWeightValue) * saturate(tapWeightValue);
}

#endif
