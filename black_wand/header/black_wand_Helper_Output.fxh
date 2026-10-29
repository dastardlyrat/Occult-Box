#ifndef black_wand_HELPER_OUTPUT_FXH
#define black_wand_HELPER_OUTPUT_FXH

#include "black_wand_Primitive_All.fxh"

float black_wand_Helper_VisibleFloor(float visibleFloor)
{
    return saturate(visibleFloor);
}

float3 black_wand_Helper_ApplyVisibleFloorToColor(float3 inputColor, float visibleFloor)
{
    float floorValue = black_wand_Helper_VisibleFloor(visibleFloor);
    return saturate(max(inputColor, float3(floorValue, floorValue, floorValue)));
}

float black_wand_Helper_ApplyVisibleFloorToScalar(float inputScalar, float visibleFloor)
{
    return saturate(max(saturate(inputScalar), black_wand_Helper_VisibleFloor(visibleFloor)));
}

float4 black_wand_Helper_OutputColor(float3 outputColor, float visibleFloor)
{
    return float4(black_wand_Helper_ApplyVisibleFloorToColor(outputColor, visibleFloor), 1.0);
}

float4 black_wand_Helper_OutputScalar(float outputScalar, float outputGain, float visibleFloor)
{
    float visibleScalar = black_wand_Helper_ApplyVisibleFloorToScalar(outputScalar * max(0.0, outputGain), visibleFloor);
    return float4(visibleScalar, visibleScalar, visibleScalar, 1.0);
}

float4 black_wand_Helper_OutputSignedDelta(float signedDeltaValue, float outputGain, float visibleFloor)
{
    float positiveValue = saturate(max(0.0, signedDeltaValue) * max(0.0, outputGain));
    float negativeValue = saturate(max(0.0, -signedDeltaValue) * max(0.0, outputGain));
    float neutralValue = black_wand_Helper_VisibleFloor(visibleFloor);
    return float4(max(positiveValue, neutralValue), neutralValue, max(negativeValue, neutralValue), 1.0);
}

float4 black_wand_Helper_OutputColorDelta(float3 colorA, float3 colorB, float outputGain, float visibleFloor)
{
    float3 deltaColor = saturate(abs(colorA - colorB) * max(0.0, outputGain));
    return black_wand_Helper_OutputColor(deltaColor, visibleFloor);
}

float4 black_wand_Helper_OutputMaskOverlay(float3 inputColor, float maskValue, float overlayStrength, float visibleFloor)
{
    float3 overlayColor = black_wand_Primitive_MaskOverlayColor(inputColor, maskValue, overlayStrength);
    return black_wand_Helper_OutputColor(overlayColor, visibleFloor);
}

#endif
