#ifndef black_wand_PRIMITIVE_SOURCE_FXH
#define black_wand_PRIMITIVE_SOURCE_FXH

#include "black_wand_Primitive_Safe.fxh"

float3 black_wand_Primitive_ReadBackBufferColor(float2 inputUV)
{
    return tex2Dlod(ReShade::BackBuffer, float4(black_wand_Primitive_SaturateUV(inputUV), 0.0, 0.0)).rgb;
}

float4 black_wand_Primitive_ReadBackBufferColorAlpha(float2 inputUV)
{
    return tex2Dlod(ReShade::BackBuffer, float4(black_wand_Primitive_SaturateUV(inputUV), 0.0, 0.0));
}

float3 black_wand_Primitive_PassthroughColor(float3 inputColor)
{
    return saturate(inputColor);
}

float3 black_wand_Primitive_DebugFallbackColor()
{
    return float3(0.125, 0.125, 0.125);
}

#endif
