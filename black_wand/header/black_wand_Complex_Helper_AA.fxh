#ifndef black_wand_COMPLEX_HELPER_AA_FXH
#define black_wand_COMPLEX_HELPER_AA_FXH

#include "black_wand_Helper_All.fxh"

float black_wand_Complex_AA_FirstTapEdge(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees, float edgeGain)
{
    float lumaDelta = black_wand_Helper_FirstTap_LumaDelta(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return saturate(lumaDelta * max(0.0, edgeGain));
}

float black_wand_Complex_AA_EdgeMask(float firstTapEdgeValue, float thresholdValue, float featherValue)
{
    return smoothstep(saturate(thresholdValue), saturate(thresholdValue + max(0.0001, featherValue)), saturate(firstTapEdgeValue));
}

float3 black_wand_Complex_AA_FirstTapBlend(float2 inputUV, int inputLensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees, float blendAmount)
{
    float3 centerColor = black_wand_Primitive_ReadBackBufferColor(inputUV);
    float3 sampleColor = black_wand_Helper_FirstTap_Color(inputUV, inputLensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees);
    return saturate(lerp(centerColor, sampleColor, saturate(blendAmount)));
}

float3 black_wand_Complex_AA_ApplyEdgeBlend(float3 inputColor, float3 blendedColor, float edgeMaskValue, float antiAliasStrength)
{
    return saturate(lerp(inputColor, blendedColor, saturate(edgeMaskValue * antiAliasStrength)));
}

float3 black_wand_Complex_AA_DebugColor(float edgeMaskValue, float firstTapEdgeValue)
{
    return float3(saturate(edgeMaskValue), saturate(firstTapEdgeValue), saturate(1.0 - edgeMaskValue));
}

#endif
