// BW BlackWand ready-filter common helper.
// Additive generated artifact. Source archives are unchanged.
#ifndef BLACK_WAND_BWT_COMMON_FXH
#define BLACK_WAND_BWT_COMMON_FXH 1

#include "ReShade.fxh"
#include "black_wand_Procedural_All.fxh"
#include "black_wand_Complex_Helper_All.fxh"

#ifndef BLACK_WAND_BWT_LENS_ITEMS
#define BLACK_WAND_BWT_LENS_ITEMS "Off\0Point1\0Horizontal Pair2\0Vertical Pair2\0Diagonal Pair2 A\0Diagonal Pair2 B\0Cross5\0X5\0CrossX9\0Box4\0Box9\0Box25\0Rect Horizontal15\0Rect Vertical15\0Diamond9\0Diamond13\0Ring4\0Ring8\0Ring9\0Ring12\0Radial13\0Spiral13\0Golden21\0Bounded55\0Fibonacci55\0Fibonacci89\0"
#endif
#ifndef BLACK_WAND_BWT_MASK_ITEMS
#define BLACK_WAND_BWT_MASK_ITEMS "Off\0Always\0Never\0Luma Dark\0Luma Bright\0Luma Mid\0Saturation High\0Saturation Low\0Hue Warm\0Hue Cool\0Hue Green\0Contrast\0Depth Available\0Depth Near\0Depth Far\0Depth Edge\0Depth Reject\0Ring Contrast\0Spiral Detail\0Box Variance\0Directional\0Hatch Diagonal\0Cross Hatch\0Hatch Bands\0Line Guard\0Pixel Guard\0Highlight Protect\0Foreground Protect\0Silhouette Protect\0Stable Surface\0"
#endif
#ifndef BLACK_WAND_BWT_HATCH_ITEMS
#define BLACK_WAND_BWT_HATCH_ITEMS "Off\0Diagonal A\0Diagonal B\0Cross\0Thin Diagonal\0Sparse\0Organic Sketch\0Edge Ink\0Technical\0Far Detail\0Fibonacci Bio\0Log Spiral\0Log Spiral Cross\0"
#endif

float black_wand_BWT_Luma(float3 colorValue)
{
    return black_wand_Proc_ColorLuma(colorValue);
}

float black_wand_BWT_SoftMask(float value, float thresholdValue, float softnessValue)
{
    return smoothstep(thresholdValue - max(softnessValue, 0.000001), thresholdValue + max(softnessValue, 0.000001), value);
}

float3 black_wand_BWT_ReapplyLuma(float3 sourceColor, float shapedLuma, float preserveColor)
{
    float sourceLuma = max(black_wand_BWT_Luma(sourceColor), 0.000001);
    float3 chromaScaled = saturate(sourceColor * (shapedLuma / sourceLuma));
    return saturate(lerp(shapedLuma.xxx, chromaScaled, saturate(preserveColor)));
}

float3 black_wand_BWT_ShadowLiftProtect(float3 sourceColor, float liftAmount, float shadowStart, float shadowSoftness, float highlightProtect)
{
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float shadowMask = 1.0 - black_wand_BWT_SoftMask(lumaValue, shadowStart, shadowSoftness);
    float highlightMask = 1.0 - black_wand_BWT_SoftMask(lumaValue, highlightProtect, 0.08);
    return saturate(sourceColor + shadowMask * highlightMask * liftAmount);
}

float3 black_wand_BWT_CelBand(float3 sourceColor, float bandCount, float softnessValue, float preserveColor)
{
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float safeBands = max(bandCount, 2.0);
    float stepped = floor(lumaValue * safeBands) / max(safeBands - 1.0, 1.0);
    float smoothBand = lerp(stepped, lumaValue, saturate(softnessValue));
    return black_wand_BWT_ReapplyLuma(sourceColor, saturate(smoothBand), preserveColor);
}

float3 black_wand_BWT_WarmBloomColor(float3 sourceColor, float warmthAmount, float saturationAmount)
{
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float3 warmValue = sourceColor * lerp(float3(1.0, 1.0, 1.0), float3(1.12, 1.04, 0.84), saturate(warmthAmount));
    return black_wand_Proc_ColorSaturateAmount(max(warmValue, lumaValue.xxx * 0.35), saturationAmount);
}

float black_wand_BWT_DepthEdge(float2 uv, int depthMode, float gainValue)
{
    float centerDepth = black_wand_Proc_DepthValue(uv, depthMode);
    float rightDepth = black_wand_Proc_DepthValue(black_wand_Proc_UVStepRight(uv, 1.0), depthMode);
    float downDepth = black_wand_Proc_DepthValue(black_wand_Proc_UVStepDown(uv, 1.0), depthMode);
    return saturate((abs(centerDepth - rightDepth) + abs(centerDepth - downDepth)) * gainValue);
}

float black_wand_BWT_LumaEdge(float2 uv, float gainValue)
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float3 rightColor = black_wand_Proc_SourceOffsetColor(uv, float2(1.0, 0.0));
    float3 downColor = black_wand_Proc_SourceOffsetColor(uv, float2(0.0, 1.0));
    return saturate((abs(black_wand_BWT_Luma(sourceColor) - black_wand_BWT_Luma(rightColor)) + abs(black_wand_BWT_Luma(sourceColor) - black_wand_BWT_Luma(downColor))) * gainValue);
}

float3 black_wand_BWT_LocalAverage4(float2 uv, float radiusPixels)
{
    float3 a = black_wand_Proc_SourceOffsetColor(uv, float2( radiusPixels, 0.0));
    float3 b = black_wand_Proc_SourceOffsetColor(uv, float2(-radiusPixels, 0.0));
    float3 c = black_wand_Proc_SourceOffsetColor(uv, float2(0.0,  radiusPixels));
    float3 d = black_wand_Proc_SourceOffsetColor(uv, float2(0.0, -radiusPixels));
    return (a + b + c + d) * 0.25;
}

float3 black_wand_BWT_LocalAverage8(float2 uv, float radiusPixels)
{
    float r = radiusPixels;
    float3 cardinal = black_wand_BWT_LocalAverage4(uv, r);
    float3 a = black_wand_Proc_SourceOffsetColor(uv, float2( r,  r));
    float3 b = black_wand_Proc_SourceOffsetColor(uv, float2(-r,  r));
    float3 c = black_wand_Proc_SourceOffsetColor(uv, float2( r, -r));
    float3 d = black_wand_Proc_SourceOffsetColor(uv, float2(-r, -r));
    return (cardinal * 4.0 + a + b + c + d) * 0.125;
}

float black_wand_BWT_TapGate(float activeTapCount, float thresholdValue)
{
    return step(thresholdValue, activeTapCount);
}

float3 black_wand_BWT_LensTapColorSafe(float2 uv, int lensSource, int logicalTapIndex, int activeTapCount, float radiusPixels, float rotationDegrees)
{
    return black_wand_Proc_LensTapColor(uv, lensSource, logicalTapIndex, max(activeTapCount, 1), black_wand_LENS_REDUCTION_STAGGERED, radiusPixels, rotationDegrees);
}

float black_wand_BWT_LensTapDepthSafe(float2 uv, int lensSource, int logicalTapIndex, int activeTapCount, float radiusPixels, float rotationDegrees, int depthMode)
{
    float2 sampleUV = black_wand_Proc_LensTapUV(uv, lensSource, logicalTapIndex, max(activeTapCount, 1), black_wand_LENS_REDUCTION_STAGGERED, radiusPixels, rotationDegrees);
    return black_wand_Proc_DepthValue(sampleUV, depthMode);
}

float3 black_wand_BWT_LensAverageColor(float2 uv, int lensSource, float requestedTapsUI, float radiusPixels, float rotationDegrees)
{
    int requestedTaps = int(round(requestedTapsUI));
    int activeTaps = black_wand_Proc_LensActiveCount(lensSource, requestedTaps, black_wand_LENS_ACTIVE_CONSUMER_CLAMP);
    float activeTapCount = float(max(activeTaps, 1));
    float3 accumColor = black_wand_Proc_SourceColor(uv);
    float accumWeight = 1.0;

    float w0 = black_wand_BWT_TapGate(activeTapCount, 1.0);
    float w1 = black_wand_BWT_TapGate(activeTapCount, 2.0);
    float w2 = black_wand_BWT_TapGate(activeTapCount, 3.0);
    float w3 = black_wand_BWT_TapGate(activeTapCount, 5.0);
    float w4 = black_wand_BWT_TapGate(activeTapCount, 8.0);
    float w5 = black_wand_BWT_TapGate(activeTapCount, 13.0);
    float w6 = black_wand_BWT_TapGate(activeTapCount, 21.0);
    float w7 = black_wand_BWT_TapGate(activeTapCount, 34.0);

    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 0, activeTaps, radiusPixels, rotationDegrees) * w0;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 1, activeTaps, radiusPixels, rotationDegrees) * w1;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 2, activeTaps, radiusPixels, rotationDegrees) * w2;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 3, activeTaps, radiusPixels, rotationDegrees) * w3;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 4, activeTaps, radiusPixels, rotationDegrees) * w4;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 5, activeTaps, radiusPixels, rotationDegrees) * w5;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 6, activeTaps, radiusPixels, rotationDegrees) * w6;
    accumColor += black_wand_BWT_LensTapColorSafe(uv, lensSource, 7, activeTaps, radiusPixels, rotationDegrees) * w7;
    accumWeight += w0 + w1 + w2 + w3 + w4 + w5 + w6 + w7;

    return saturate(accumColor / max(accumWeight, 0.000001));
}

float black_wand_BWT_LensAverageDepth(float2 uv, int lensSource, float requestedTapsUI, float radiusPixels, float rotationDegrees, int depthMode)
{
    int requestedTaps = int(round(requestedTapsUI));
    int activeTaps = black_wand_Proc_LensActiveCount(lensSource, requestedTaps, black_wand_LENS_ACTIVE_CONSUMER_CLAMP);
    float activeTapCount = float(max(activeTaps, 1));
    float accumDepth = black_wand_Proc_DepthValue(uv, depthMode);
    float accumWeight = 1.0;

    float w0 = black_wand_BWT_TapGate(activeTapCount, 1.0);
    float w1 = black_wand_BWT_TapGate(activeTapCount, 2.0);
    float w2 = black_wand_BWT_TapGate(activeTapCount, 3.0);
    float w3 = black_wand_BWT_TapGate(activeTapCount, 5.0);
    float w4 = black_wand_BWT_TapGate(activeTapCount, 8.0);
    float w5 = black_wand_BWT_TapGate(activeTapCount, 13.0);
    float w6 = black_wand_BWT_TapGate(activeTapCount, 21.0);
    float w7 = black_wand_BWT_TapGate(activeTapCount, 34.0);

    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 0, activeTaps, radiusPixels, rotationDegrees, depthMode) * w0;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 1, activeTaps, radiusPixels, rotationDegrees, depthMode) * w1;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 2, activeTaps, radiusPixels, rotationDegrees, depthMode) * w2;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 3, activeTaps, radiusPixels, rotationDegrees, depthMode) * w3;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 4, activeTaps, radiusPixels, rotationDegrees, depthMode) * w4;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 5, activeTaps, radiusPixels, rotationDegrees, depthMode) * w5;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 6, activeTaps, radiusPixels, rotationDegrees, depthMode) * w6;
    accumDepth += black_wand_BWT_LensTapDepthSafe(uv, lensSource, 7, activeTaps, radiusPixels, rotationDegrees, depthMode) * w7;
    accumWeight += w0 + w1 + w2 + w3 + w4 + w5 + w6 + w7;

    return accumDepth / max(accumWeight, 0.000001);
}

float black_wand_BWT_LensAverageLumaDelta(float2 uv, int lensSource, float requestedTapsUI, float radiusPixels, float rotationDegrees, float gainValue)
{
    float3 centerColor = black_wand_Proc_SourceColor(uv);
    float3 averageColor = black_wand_BWT_LensAverageColor(uv, lensSource, requestedTapsUI, radiusPixels, rotationDegrees);
    return saturate(abs(black_wand_BWT_Luma(centerColor) - black_wand_BWT_Luma(averageColor)) * max(0.0, gainValue));
}

float3 black_wand_BWT_FirstLensAverage(float2 uv, int lensSource, float requestedTapsUI, float radiusPixels, float rotationDegrees, float fallbackMix)
{
    float3 lensAverage = black_wand_BWT_LensAverageColor(uv, lensSource, requestedTapsUI, radiusPixels, rotationDegrees);
    float3 plusColor = black_wand_BWT_LocalAverage4(uv, radiusPixels * 0.5);
    return saturate(lerp(lensAverage, plusColor, saturate(fallbackMix)));
}

float black_wand_BWT_OutputRoleMask(float maskSource, float2 uv, float3 sourceColor, float influenceValue)
{
    float maskValue = black_wand_Proc_OutputBlendMask(maskSource, uv, sourceColor);
    return black_wand_Proc_MaskInfluence(1.0, maskValue, influenceValue);
}

#endif
