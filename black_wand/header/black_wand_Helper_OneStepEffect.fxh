#ifndef black_wand_HELPER_ONE_STEP_EFFECT_FXH
#define black_wand_HELPER_ONE_STEP_EFFECT_FXH

#include "black_wand_Primitive_All.fxh"
#include "black_wand_Helper_FirstTap.fxh"

float3 black_wand_Helper_OneStepDetailBoost(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees, float strengthValue)
{
    float3 centerColor = black_wand_Primitive_ReadBackBufferColor(inputUV);
    float3 firstTapColor = black_wand_Helper_FirstTap_Color(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return black_wand_Primitive_ReduceCenterMinusAverage(centerColor, firstTapColor, strengthValue);
}

float3 black_wand_Helper_OneStepAverageMix(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees, float mixValue)
{
    float3 centerColor = black_wand_Primitive_ReadBackBufferColor(inputUV);
    float3 firstTapColor = black_wand_Helper_FirstTap_Color(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return black_wand_Primitive_ReduceAverageMix(centerColor, firstTapColor, mixValue);
}

float3 black_wand_Helper_OneStepHatchInk(float2 inputUV, int inputHatchPatternSource, int depthMode, float hatchPhase, float inkStrength)
{
    float3 centerColor = black_wand_Primitive_ReadBackBufferColor(inputUV);
    float centerLuma = black_wand_Primitive_ColorLuma(centerColor);
    float centerDepth = black_wand_Primitive_DepthValue(inputUV, depthMode);
    float hatchValue = black_wand_Primitive_InputHatchValue(inputHatchPatternSource, inputUV, centerDepth, centerLuma, hatchPhase);
    return black_wand_Primitive_HatchInkColor(centerColor, hatchValue, inkStrength);
}

#endif
