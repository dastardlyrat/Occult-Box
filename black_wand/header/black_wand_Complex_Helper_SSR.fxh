#ifndef black_wand_COMPLEX_HELPER_SSR_FXH
#define black_wand_COMPLEX_HELPER_SSR_FXH

#include "black_wand_Helper_All.fxh"

float2 black_wand_Complex_SSR_DepthGradient(float2 inputUV, int depthMode, float gradientScale)
{
    float2 pixelStep = ReShade::PixelSize * max(1.0, gradientScale);
    float centerDepth = black_wand_Primitive_DepthValue(inputUV, depthMode);
    float rightDepth = black_wand_Primitive_DepthValue(inputUV + float2(pixelStep.x, 0.0), depthMode);
    float downDepth = black_wand_Primitive_DepthValue(inputUV + float2(0.0, pixelStep.y), depthMode);
    return float2(rightDepth - centerDepth, downDepth - centerDepth);
}

float2 black_wand_Complex_SSR_ReflectDirection(float2 depthGradientValue, float fallbackAngle)
{
    float gradientEnergy = dot(depthGradientValue, depthGradientValue);
    float2 gradientDirection = normalize(depthGradientValue + float2(0.000001, 0.0));
    float2 fallbackDirection = float2(cos(fallbackAngle), sin(fallbackAngle));
    return normalize(lerp(fallbackDirection, -gradientDirection, step(0.0000001, gradientEnergy)));
}

float2 black_wand_Complex_SSR_ReflectionUV(float2 inputUV, float2 reflectDirection, float rayDistancePixels)
{
    return black_wand_Primitive_SaturateUV(inputUV + reflectDirection * ReShade::PixelSize * max(0.0, rayDistancePixels));
}

float black_wand_Complex_SSR_ScreenConfidence(float2 reflectionUV)
{
    float2 cleanUV = saturate(reflectionUV);
    float2 deltaUV = abs(reflectionUV - cleanUV);
    return 1.0 - saturate((deltaUV.x + deltaUV.y) * 4096.0);
}

float black_wand_Complex_SSR_DepthConfidence(float centerDepth, float reflectedDepth, float depthTolerance)
{
    float depthDelta = abs(centerDepth - reflectedDepth);
    return 1.0 - smoothstep(max(0.000001, depthTolerance), max(0.000001, depthTolerance * 2.0), depthDelta);
}

float3 black_wand_Complex_SSR_Composite(float3 inputColor, float3 reflectedColor, float confidenceValue, float reflectionStrength)
{
    return saturate(lerp(inputColor, reflectedColor, saturate(confidenceValue * reflectionStrength)));
}

float3 black_wand_Complex_SSR_DebugColor(float confidenceValue, float2 reflectDirection)
{
    return float3(saturate(confidenceValue), saturate(reflectDirection.x * 0.5 + 0.5), saturate(reflectDirection.y * 0.5 + 0.5));
}

#endif
