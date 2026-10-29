#ifndef black_wand_PRIMITIVE_COLOR_FXH
#define black_wand_PRIMITIVE_COLOR_FXH

#include "black_wand_Primitive_Safe.fxh"

float black_wand_Primitive_ColorLuma(float3 inputColor)
{
    return dot(saturate(inputColor), float3(0.2126, 0.7152, 0.0722));
}

float black_wand_Primitive_ColorChromaSpan(float3 inputColor)
{
    float3 cleanColor = saturate(inputColor);
    float maxChannel = max(max(cleanColor.r, cleanColor.g), cleanColor.b);
    float minChannel = min(min(cleanColor.r, cleanColor.g), cleanColor.b);
    return saturate(maxChannel - minChannel);
}

float black_wand_Primitive_ColorWarmth(float3 inputColor)
{
    float3 cleanColor = saturate(inputColor);
    return saturate(cleanColor.r - cleanColor.b + 0.5);
}

float black_wand_Primitive_ColorGreenBias(float3 inputColor)
{
    float3 cleanColor = saturate(inputColor);
    return saturate(cleanColor.g - max(cleanColor.r, cleanColor.b) + 0.5);
}

float3 black_wand_Primitive_ColorLumaOutput(float3 inputColor)
{
    float lumaValue = black_wand_Primitive_ColorLuma(inputColor);
    return float3(lumaValue, lumaValue, lumaValue);
}

float3 black_wand_Primitive_ColorDeltaOutput(float3 colorA, float3 colorB, float gainValue)
{
    return saturate(abs(colorA - colorB) * max(0.0, gainValue));
}

#endif
