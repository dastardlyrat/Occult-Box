#ifndef black_wand_PRIMITIVE_HATCH_FXH
#define black_wand_PRIMITIVE_HATCH_FXH

#include "black_wand_Hatch_Adapter.fxh"
#include "black_wand_Primitive_Color.fxh"

float black_wand_Primitive_InputHatchValue(int inputHatchPatternSource, float2 inputUV, float depthValue, float lumaValue, float phaseValue)
{
    return saturate(black_wand_Hatch_Evaluate(inputHatchPatternSource, inputUV, depthValue, lumaValue, phaseValue));
}

float black_wand_Primitive_HatchWeightValue(float hatchValue, float influenceValue)
{
    return saturate(black_wand_Hatch_AsWeight(saturate(hatchValue), saturate(influenceValue)));
}

float3 black_wand_Primitive_HatchInkColor(float3 inputColor, float hatchValue, float inkStrength)
{
    float inkAmount = saturate(hatchValue * inkStrength);
    return saturate(lerp(inputColor, inputColor * 0.20, inkAmount));
}

float3 black_wand_Primitive_HatchDebugColor(float hatchValue)
{
    return float3(saturate(hatchValue), saturate(hatchValue), saturate(hatchValue));
}

#endif
