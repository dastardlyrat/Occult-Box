#ifndef black_wand_PRIMITIVE_DEPTH_FXH
#define black_wand_PRIMITIVE_DEPTH_FXH

#include "black_wand_Primitive_Safe.fxh"

#ifndef black_wand_PRIMITIVE_DEPTH_MODE_RAW
#define black_wand_PRIMITIVE_DEPTH_MODE_RAW 0
#endif
#ifndef black_wand_PRIMITIVE_DEPTH_MODE_RAW_INVERTED
#define black_wand_PRIMITIVE_DEPTH_MODE_RAW_INVERTED 1
#endif

float black_wand_Primitive_DepthRaw(float2 inputUV)
{
    return tex2Dlod(ReShade::DepthBuffer, float4(black_wand_Primitive_SaturateUV(inputUV), 0.0, 0.0)).r;
}

float black_wand_Primitive_DepthValue(float2 inputUV, int depthMode)
{
    float rawDepth = black_wand_Primitive_DepthRaw(inputUV);

    if (depthMode == black_wand_PRIMITIVE_DEPTH_MODE_RAW_INVERTED)
    {
        return saturate(1.0 - rawDepth);
    }

    return saturate(rawDepth);
}

float black_wand_Primitive_DepthAvailable(float2 inputUV, int depthMode, float thresholdValue)
{
    float centerDepth = black_wand_Primitive_DepthValue(inputUV, depthMode);
    float2 pixelStep = ReShade::PixelSize * 2.0;
    float sampleA = black_wand_Primitive_DepthValue(inputUV + float2(pixelStep.x, 0.0), depthMode);
    float sampleB = black_wand_Primitive_DepthValue(inputUV + float2(0.0, pixelStep.y), depthMode);
    float traceValue = abs(centerDepth - sampleA) + abs(centerDepth - sampleB);
    return step(max(0.00001, thresholdValue), traceValue);
}

float black_wand_Primitive_DepthNearMask(float depthValue, float nearEnd, float nearFeather)
{
    return 1.0 - smoothstep(max(0.0, nearEnd), max(0.0, nearEnd + nearFeather), saturate(depthValue));
}

float black_wand_Primitive_DepthFarMask(float depthValue, float farStart, float farFeather)
{
    return smoothstep(saturate(farStart), saturate(farStart + farFeather), saturate(depthValue));
}

float black_wand_Primitive_DepthSameLayerWeight(float centerDepth, float sampleDepth, float thresholdValue, float softnessValue)
{
    float deltaValue = abs(centerDepth - sampleDepth);
    return 1.0 - smoothstep(max(0.000001, thresholdValue), max(0.000001, thresholdValue + softnessValue), deltaValue);
}

#endif
