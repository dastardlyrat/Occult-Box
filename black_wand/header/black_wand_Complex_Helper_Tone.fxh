#ifndef black_wand_COMPLEX_HELPER_TONE_FXH
#define black_wand_COMPLEX_HELPER_TONE_FXH

#include "black_wand_Helper_All.fxh"

float3 black_wand_Complex_Tone_LumaProtect(float3 inputColor, float protectMaskValue, float strengthValue)
{
    float lumaValue = black_wand_Primitive_ColorLuma(inputColor);
    float3 protectedColor = lerp(inputColor, lumaValue.xxx, saturate(strengthValue));
    return saturate(lerp(inputColor, protectedColor, saturate(protectMaskValue)));
}

float3 black_wand_Complex_Tone_Contrast(float3 inputColor, float contrastStrength)
{
    return saturate(0.5.xxx + (inputColor - 0.5.xxx) * (1.0 + max(0.0, contrastStrength)));
}

float3 black_wand_Complex_Tone_Saturation(float3 inputColor, float saturationStrength)
{
    float lumaValue = black_wand_Primitive_ColorLuma(inputColor);
    return saturate(lerp(lumaValue.xxx, inputColor, max(0.0, saturationStrength)));
}

#endif
