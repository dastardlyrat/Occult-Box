#ifndef black_wand_COMPLEX_HELPER_AO_FXH
#define black_wand_COMPLEX_HELPER_AO_FXH

#include "black_wand_Helper_All.fxh"

float black_wand_Complex_AO_FirstTapDepth(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees, int depthMode)
{
    float2 sampleUV = black_wand_Helper_FirstTap_UV(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return black_wand_Primitive_DepthValue(sampleUV, depthMode);
}

float black_wand_Complex_AO_DepthDelta(float centerDepth, float sampleDepth, float depthDeltaGain)
{
    return saturate(abs(centerDepth - sampleDepth) * max(0.0, depthDeltaGain));
}

float black_wand_Complex_AO_NearOcclusion(float centerDepth, float sampleDepth, float depthBias, float occlusionGain)
{
    return saturate((centerDepth - sampleDepth - max(0.0, depthBias)) * max(0.0, occlusionGain));
}

float black_wand_Complex_AO_ContactWeight(float depthDeltaValue, float inputMaskValue, float depthAvailableValue)
{
    return saturate(depthDeltaValue) * saturate(inputMaskValue) * saturate(depthAvailableValue);
}

float3 black_wand_Complex_AO_Apply(float3 inputColor, float occlusionValue, float occlusionStrength)
{
    float occlusionAmount = saturate(occlusionValue * occlusionStrength);
    return saturate(inputColor * (1.0 - occlusionAmount));
}

float3 black_wand_Complex_AO_DebugColor(float occlusionValue, float depthAvailableValue)
{
    return float3(saturate(occlusionValue), saturate(depthAvailableValue), saturate(1.0 - occlusionValue));
}

#endif
