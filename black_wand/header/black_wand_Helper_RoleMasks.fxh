#ifndef black_wand_HELPER_ROLE_MASKS_FXH
#define black_wand_HELPER_ROLE_MASKS_FXH

#include "black_wand_Primitive_All.fxh"
#include "black_wand_Helper_FirstTap.fxh"

float black_wand_Helper_InputMask(float inputMaskSource, float2 inputUV, float3 inputColor)
{
    return black_wand_Primitive_InputMaskValue(int(inputMaskSource), inputUV, inputColor);
}

float black_wand_Helper_SampleWeightMaskFromFirstTap(int sampleWeightMaskSource, float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees)
{
    float2 sampleUV = black_wand_Helper_FirstTap_UV(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    float3 sampleColor = black_wand_Primitive_ReadBackBufferColor(sampleUV);
    return black_wand_Primitive_SampleWeightMaskValue(sampleWeightMaskSource, sampleUV, sampleColor);
}

float black_wand_Helper_OutputBlendMask(float outputBlendMaskSource, float2 inputUV, float3 inputColor)
{
    return black_wand_Primitive_OutputBlendMaskValue(int(outputBlendMaskSource), inputUV, inputColor);
}

float black_wand_Helper_DebugMask(float debugMaskSource, float2 inputUV, float3 inputColor)
{
    return black_wand_Primitive_DebugMaskValue(int(debugMaskSource), inputUV, inputColor);
}

#endif
