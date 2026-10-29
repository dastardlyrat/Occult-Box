#ifndef black_wand_PRIMITIVE_MASK_FXH
#define black_wand_PRIMITIVE_MASK_FXH

#include "black_wand_Mask_Adapter.fxh"
#include "black_wand_Primitive_Safe.fxh"

float black_wand_Primitive_InputMaskValue(int inputMaskSource, float2 inputUV, float3 inputColor)
{
    return saturate(black_wand_Mask_Evaluate(inputMaskSource, inputUV, inputColor));
}

float black_wand_Primitive_SampleWeightMaskValue(int sampleWeightMaskSource, float2 sampleUV, float3 sampleColor)
{
    return saturate(black_wand_Mask_Evaluate(sampleWeightMaskSource, sampleUV, sampleColor));
}

float black_wand_Primitive_OutputBlendMaskValue(int outputBlendMaskSource, float2 inputUV, float3 inputColor)
{
    return saturate(black_wand_Mask_Evaluate(outputBlendMaskSource, inputUV, inputColor));
}

float black_wand_Primitive_DebugMaskValue(int debugMaskSource, float2 inputUV, float3 inputColor)
{
    return saturate(black_wand_Mask_Evaluate(debugMaskSource, inputUV, inputColor));
}

float black_wand_Primitive_MaskApplyInfluence(float baseWeight, float maskValue, float influenceValue)
{
    return saturate(baseWeight * lerp(1.0, saturate(maskValue), saturate(influenceValue)));
}

float3 black_wand_Primitive_MaskOverlayColor(float3 inputColor, float maskValue, float overlayStrength)
{
    float3 maskColor = float3(saturate(maskValue), 0.0, saturate(1.0 - maskValue));
    return saturate(lerp(inputColor, maskColor, saturate(overlayStrength)));
}

#endif
