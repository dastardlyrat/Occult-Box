#ifndef black_wand_COMPLEX_HELPER_DETAIL_FXH
#define black_wand_COMPLEX_HELPER_DETAIL_FXH

#include "black_wand_Helper_All.fxh"

float3 black_wand_Complex_Detail_FirstTapDifference(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees)
{
    float3 centerColor = black_wand_Primitive_ReadBackBufferColor(inputUV);
    float3 sampleColor = black_wand_Helper_FirstTap_Color(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return centerColor - sampleColor;
}

float3 black_wand_Complex_Detail_Sharpen(float3 inputColor, float3 detailDelta, float sharpenStrength)
{
    return saturate(inputColor + detailDelta * max(0.0, sharpenStrength));
}

float3 black_wand_Complex_Detail_SoftBlur(float3 inputColor, float3 sampleColor, float blurStrength)
{
    return saturate(lerp(inputColor, sampleColor, saturate(blurStrength)));
}

float3 black_wand_Complex_Detail_EdgeLight(float3 inputColor, float edgeValue, float edgeStrength)
{
    return saturate(inputColor + saturate(edgeValue * edgeStrength).xxx);
}

#endif
