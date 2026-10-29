#ifndef black_wand_HELPER_FIRST_TAP_FXH
#define black_wand_HELPER_FIRST_TAP_FXH

#include "black_wand_Primitive_All.fxh"

int black_wand_Helper_FirstTap_ActiveCount(int inputLensSource, int requestedTapCount, int activeTapWiring)
{
    return black_wand_Primitive_LensActiveTapCount(inputLensSource, requestedTapCount, activeTapWiring);
}

int black_wand_Helper_FirstTap_Index(int activeTapCount)
{
    return min(1, max(0, activeTapCount - 1));
}

float2 black_wand_Helper_FirstTap_UV(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees)
{
    int activeTapCount = black_wand_Helper_FirstTap_ActiveCount(inputLensSource, requestedTapCount, activeTapWiring);
    int tapIndex = black_wand_Helper_FirstTap_Index(activeTapCount);
    return black_wand_Primitive_LensSampleUV(inputUV, inputLensSource, tapIndex, activeTapCount, reductionMode, radiusPixels, rotationDegrees);
}

float3 black_wand_Helper_FirstTap_Color(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees)
{
    float2 sampleUV = black_wand_Helper_FirstTap_UV(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return black_wand_Primitive_ReadBackBufferColor(sampleUV);
}

float black_wand_Helper_FirstTap_LumaDelta(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees)
{
    float3 centerColor = black_wand_Primitive_ReadBackBufferColor(inputUV);
    float3 sampleColor = black_wand_Helper_FirstTap_Color(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return black_wand_Primitive_ReduceLumaDelta(centerColor, sampleColor);
}

#endif
