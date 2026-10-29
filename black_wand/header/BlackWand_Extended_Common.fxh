// BW BlackWand extended ready-filter common helper.
// Additive generated artifact. Source archives are unchanged.
#ifndef BLACK_WANDX_EXTENDED_COMMON_FXH
#define BLACK_WANDX_EXTENDED_COMMON_FXH 1

#include "BlackWand_Common.fxh"

float BWBlackWandX_HighlightMask(float lumaValue, float thresholdValue, float softnessValue)
{
    return smoothstep(thresholdValue - max(softnessValue, 0.000001), thresholdValue + max(softnessValue, 0.000001), lumaValue);
}

float BWBlackWandX_ShadowMask(float lumaValue, float thresholdValue, float softnessValue)
{
    return 1.0 - BWBlackWandX_HighlightMask(lumaValue, thresholdValue, softnessValue);
}

float BWBlackWandX_LocalContrast(float2 uv, float radiusPixels, float gainValue)
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float3 averageColor = black_wand_BWT_LocalAverage4(uv, max(radiusPixels, 0.25));
    return saturate(abs(black_wand_BWT_Luma(sourceColor) - black_wand_BWT_Luma(averageColor)) * gainValue);
}

float3 BWBlackWandX_CrossBlur(float2 uv, float radiusPixels)
{
    float3 centerColor = black_wand_Proc_SourceColor(uv);
    float3 plusColor = black_wand_BWT_LocalAverage4(uv, max(radiusPixels, 0.25));
    return saturate(centerColor * 0.50 + plusColor * 0.50);
}

float3 BWBlackWandX_WideSoftSample(float2 uv, float radiusPixels)
{
    float3 centerColor = black_wand_Proc_SourceColor(uv);
    float3 a = black_wand_BWT_LocalAverage4(uv, max(radiusPixels, 0.50));
    float3 b = black_wand_BWT_LocalAverage8(uv, max(radiusPixels * 2.0, 1.00));
    return saturate(centerColor * 0.25 + a * 0.45 + b * 0.30);
}

float2 BWBlackWandX_DepthGradient(float2 uv, int depthMode, float radiusPixels, float gainValue)
{
    float r = max(radiusPixels, 1.0);
    float depthLeft = black_wand_Proc_DepthValue(black_wand_Proc_UVStepLeft(uv, r), depthMode);
    float depthRight = black_wand_Proc_DepthValue(black_wand_Proc_UVStepRight(uv, r), depthMode);
    float depthUp = black_wand_Proc_DepthValue(black_wand_Proc_UVStepUp(uv, r), depthMode);
    float depthDown = black_wand_Proc_DepthValue(black_wand_Proc_UVStepDown(uv, r), depthMode);
    return float2(depthRight - depthLeft, depthDown - depthUp) * gainValue;
}

float2 BWBlackWandX_LumaGradient(float2 uv, float radiusPixels, float gainValue)
{
    float r = max(radiusPixels, 1.0);
    float l = black_wand_BWT_Luma(black_wand_Proc_SourceOffsetColor(uv, float2(-r, 0.0)));
    float rr = black_wand_BWT_Luma(black_wand_Proc_SourceOffsetColor(uv, float2(r, 0.0)));
    float u = black_wand_BWT_Luma(black_wand_Proc_SourceOffsetColor(uv, float2(0.0, -r)));
    float d = black_wand_BWT_Luma(black_wand_Proc_SourceOffsetColor(uv, float2(0.0, r)));
    return float2(rr - l, d - u) * gainValue;
}

float3 BWBlackWandX_PseudoNormalFromGradient(float2 gradientValue, float normalStrength)
{
    return normalize(float3(-gradientValue.x * normalStrength, -gradientValue.y * normalStrength, 1.0));
}

float3 BWBlackWandX_NormalDebugColor(float3 normalValue)
{
    return saturate(normalValue * 0.5 + 0.5);
}

float BWBlackWandX_DepthWindow(float depthValue, float startValue, float endValue, float softnessValue)
{
    float enterValue = smoothstep(startValue - softnessValue, startValue + softnessValue, depthValue);
    float exitValue = 1.0 - smoothstep(endValue - softnessValue, endValue + softnessValue, depthValue);
    return saturate(enterValue * exitValue);
}

float3 BWBlackWandX_WarmColor(float3 colorValue, float warmthAmount)
{
    return saturate(colorValue * lerp(float3(1.0, 1.0, 1.0), float3(1.14, 1.055, 0.84), saturate(warmthAmount)));
}

float3 BWBlackWandX_CoolColor(float3 colorValue, float coolAmount)
{
    return saturate(colorValue * lerp(float3(1.0, 1.0, 1.0), float3(0.82, 0.94, 1.16), saturate(coolAmount)));
}

float3 BWBlackWandX_ScreenBlend(float3 sourceColor, float3 addColor, float amount)
{
    float3 oneValue = float3(1.0, 1.0, 1.0);
    float3 screened = oneValue - (oneValue - sourceColor) * (oneValue - saturate(addColor));
    return saturate(lerp(sourceColor, screened, saturate(amount)));
}

float BWBlackWandX_ApplyMask(int maskSource, float2 uv, float3 sourceColor, float maskInfluence)
{
    return black_wand_BWT_OutputRoleMask(maskSource, uv, sourceColor, maskInfluence);
}

float3 BWBlackWandX_DetailDelta(float2 uv, float radiusPixels)
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float3 averageColor = black_wand_BWT_LocalAverage8(uv, max(radiusPixels, 0.25));
    return sourceColor - averageColor;
}

#endif
