#ifndef KALEIDOSCOPE_FXH
#define KALEIDOSCOPE_FXH

// Standalone mask server with modular color, depth, spatial, and hatch-derived masks.
// Include ReShade.fxh and declare KALEIDOSCOPE_* uniforms before including this file.

#include "miXSR_shared_core.fxh"
#include "miXSR_shared_depth.fxh"
#include "miXSR_shared_fibonacci.fxh"
#include "miXSR_shared_pattern.fxh"

#define KALEIDOSCOPE_MASK_OFF 0
#define KALEIDOSCOPE_MASK_ALWAYS 1
#define KALEIDOSCOPE_MASK_NEVER 2
#define KALEIDOSCOPE_MASK_LUMA_DARK 3
#define KALEIDOSCOPE_MASK_LUMA_BRIGHT 4
#define KALEIDOSCOPE_MASK_LUMA_MID 5
#define KALEIDOSCOPE_MASK_SATURATION_HIGH 6
#define KALEIDOSCOPE_MASK_SATURATION_LOW 7
#define KALEIDOSCOPE_MASK_HUE_WARM 8
#define KALEIDOSCOPE_MASK_HUE_COOL 9
#define KALEIDOSCOPE_MASK_HUE_GREEN 10
#define KALEIDOSCOPE_MASK_CONTRAST 11
#define KALEIDOSCOPE_MASK_DEPTH_AVAILABLE 12
#define KALEIDOSCOPE_MASK_DEPTH_NEAR 13
#define KALEIDOSCOPE_MASK_DEPTH_FAR 14
#define KALEIDOSCOPE_MASK_DEPTH_EDGE 15
#define KALEIDOSCOPE_MASK_DEPTH_REJECT 16
#define KALEIDOSCOPE_MASK_RING_CONTRAST 17
#define KALEIDOSCOPE_MASK_SPIRAL_DETAIL 18
#define KALEIDOSCOPE_MASK_BOX_VARIANCE 19
#define KALEIDOSCOPE_MASK_DIRECTIONAL 20
#define KALEIDOSCOPE_MASK_HATCH_DIAGONAL 21
#define KALEIDOSCOPE_MASK_CROSS_HATCH 22
#define KALEIDOSCOPE_MASK_HATCH_BANDS 23
#define KALEIDOSCOPE_MASK_LINE_GUARD 24
#define KALEIDOSCOPE_MASK_PIXEL_GUARD 25
#define KALEIDOSCOPE_MASK_HIGHLIGHT_PROTECT 26
#define KALEIDOSCOPE_MASK_FOREGROUND_PROTECT 27
#define KALEIDOSCOPE_MASK_SILHOUETTE_PROTECT 28
#define KALEIDOSCOPE_MASK_STABLE_SURFACE 29

#define KALEIDOSCOPE_COMBINE_MULTIPLY 0
#define KALEIDOSCOPE_COMBINE_MIN 1
#define KALEIDOSCOPE_COMBINE_MAX 2
#define KALEIDOSCOPE_COMBINE_ADD 3
#define KALEIDOSCOPE_COMBINE_DIFFERENCE 4
#define KALEIDOSCOPE_COMBINE_SAMPLE_ONLY 5
#define KALEIDOSCOPE_COMBINE_FINAL_ONLY 6

float2 KALEIDOSCOPE_PixelSize()
{
    return MIXSR_SHARED_PixelSize();
}

float KALEIDOSCOPE_SafeRcp(float v)
{
    return MIXSR_SHARED_SafeRcp(v);
}

float KALEIDOSCOPE_Luma(float3 c)
{
    return MIXSR_SHARED_Luma(c);
}

float KALEIDOSCOPE_Saturation(float3 c)
{
    return MIXSR_SHARED_Saturation(c);
}

float KALEIDOSCOPE_Hue(float3 c)
{
    return MIXSR_SHARED_Hue(c);
}

float KALEIDOSCOPE_RawDepth(float2 uv)
{
    return MIXSR_SHARED_RawDepth(uv);
}

float KALEIDOSCOPE_LinearDepth(float2 uv)
{
    return MIXSR_SHARED_LinearDepth(uv, KALEIDOSCOPE_DepthMode, KALEIDOSCOPE_DepthInvert);
}

float KALEIDOSCOPE_DepthAvailability(float2 uv)
{
    return MIXSR_SHARED_DepthAvailability(
        uv,
        KALEIDOSCOPE_DepthMode,
        KALEIDOSCOPE_DepthInvert,
        KALEIDOSCOPE_DepthTraceScale,
        KALEIDOSCOPE_DepthAvailabilityThreshold);
}

float KALEIDOSCOPE_LocalContrast(float2 uv, float3 sourceColor)
{
    return MIXSR_SHARED_LocalContrast(uv, sourceColor);
}

float KALEIDOSCOPE_LumaDarkMask(float luma)
{
    return 1.0 - smoothstep(
        KALEIDOSCOPE_LumaDarkStart,
        min(1.0, KALEIDOSCOPE_LumaDarkStart + max(0.0001, KALEIDOSCOPE_LumaDarkFeather)),
        luma);
}

float KALEIDOSCOPE_LumaBrightMask(float luma)
{
    return smoothstep(
        KALEIDOSCOPE_LumaBrightStart,
        min(1.0, KALEIDOSCOPE_LumaBrightStart + max(0.0001, KALEIDOSCOPE_LumaBrightFeather)),
        luma);
}

float KALEIDOSCOPE_LumaMidMask(float luma)
{
    float dist = abs(luma - KALEIDOSCOPE_LumaMidCenter);
    return 1.0 - smoothstep(
        max(0.0001, KALEIDOSCOPE_LumaMidWidth),
        max(0.0002, KALEIDOSCOPE_LumaMidWidth + KALEIDOSCOPE_LumaMidFeather),
        dist);
}

float KALEIDOSCOPE_SaturationHighMask(float saturation)
{
    return smoothstep(
        KALEIDOSCOPE_SaturationHighStart,
        min(1.0, KALEIDOSCOPE_SaturationHighStart + max(0.0001, KALEIDOSCOPE_SaturationHighFeather)),
        saturation);
}

float KALEIDOSCOPE_SaturationLowMask(float saturation)
{
    return 1.0 - smoothstep(
        KALEIDOSCOPE_SaturationLowStart,
        min(1.0, KALEIDOSCOPE_SaturationLowStart + max(0.0001, KALEIDOSCOPE_SaturationLowFeather)),
        saturation);
}

float KALEIDOSCOPE_HueSectorMask(float hue, float center, float width, float feather)
{
    float delta = abs(frac(hue - center + 0.5) - 0.5);
    return 1.0 - smoothstep(
        max(0.0001, width),
        max(0.0002, width + feather),
        delta);
}

float KALEIDOSCOPE_ContrastMask(float2 uv, float3 sourceColor)
{
    float contrast = KALEIDOSCOPE_LocalContrast(uv, sourceColor);
    return smoothstep(
        KALEIDOSCOPE_ContrastThreshold,
        KALEIDOSCOPE_ContrastThreshold * max(1.25, KALEIDOSCOPE_ContrastGain),
        contrast * KALEIDOSCOPE_ContrastGain);
}

float KALEIDOSCOPE_DepthNearMask(float depth)
{
    return 1.0 - smoothstep(
        KALEIDOSCOPE_DepthNearEnd,
        min(1.0, KALEIDOSCOPE_DepthNearEnd + max(0.0001, KALEIDOSCOPE_DepthNearFeather)),
        depth);
}

float KALEIDOSCOPE_DepthFarMask(float depth)
{
    return smoothstep(
        KALEIDOSCOPE_DepthFarStart,
        min(1.0, KALEIDOSCOPE_DepthFarStart + max(0.0001, KALEIDOSCOPE_DepthFarFeather)),
        depth);
}

float KALEIDOSCOPE_DepthEdgeMask(float2 uv)
{
    return MIXSR_SHARED_DepthEdgeMask(
        uv,
        KALEIDOSCOPE_DepthMode,
        KALEIDOSCOPE_DepthInvert,
        KALEIDOSCOPE_DepthTraceScale,
        KALEIDOSCOPE_DepthAvailabilityThreshold,
        KALEIDOSCOPE_DepthEdgeThreshold);
}

float KALEIDOSCOPE_DepthRejectMask(float2 uv)
{
    return MIXSR_SHARED_DepthRejectMask(
        uv,
        KALEIDOSCOPE_DepthMode,
        KALEIDOSCOPE_DepthInvert,
        KALEIDOSCOPE_DepthTraceScale,
        KALEIDOSCOPE_DepthAvailabilityThreshold,
        KALEIDOSCOPE_DepthRejectRadius,
        KALEIDOSCOPE_DepthRejectThreshold);
}

float KALEIDOSCOPE_RingMask(float2 uv, float radius, float thickness)
{
    float ringDist = abs(length(uv - 0.5) - radius);
    return 1.0 - smoothstep(0.0, max(0.0001, thickness), ringDist);
}

float2 KALEIDOSCOPE_GoldenDirection(float sampleIndex)
{
    return MIXSR_SHARED_GoldenDirection(sampleIndex);
}

float KALEIDOSCOPE_RingContrastMask(float2 uv, float3 sourceColor)
{
    float2 px = KALEIDOSCOPE_PixelSize() * KALEIDOSCOPE_SpatialRadiusPixels;
    float center = KALEIDOSCOPE_Luma(sourceColor);
    float sum = 0.0;

    [loop]
    for (int i = 0; i < 8; ++i)
    {
        float angle = 6.2831853 * (float(i) / 8.0);
        float2 offset = float2(cos(angle), sin(angle)) * px;
        float tap = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + offset), 0.0, 0.0)).rgb);
        sum += abs(center - tap);
    }

    return saturate((sum / 4.0) * KALEIDOSCOPE_SpatialGain);
}

float KALEIDOSCOPE_SpiralDetailMask(float2 uv, float3 sourceColor)
{
    float2 px = KALEIDOSCOPE_PixelSize() * KALEIDOSCOPE_SpatialRadiusPixels;
    float center = KALEIDOSCOPE_Luma(sourceColor);
    float sum = 0.0;

    [loop]
    for (int i = 0; i < 13; ++i)
    {
        float sampleIndex = float(i);
        float radial = (i == 0) ? 0.0 : sqrt(sampleIndex / 12.0);
        float2 offset = KALEIDOSCOPE_GoldenDirection(sampleIndex + 0.5) * radial * px;
        float tap = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + offset), 0.0, 0.0)).rgb);
        sum += abs(center - tap);
    }

    return saturate((sum / 4.0) * KALEIDOSCOPE_SpatialGain);
}

float KALEIDOSCOPE_BoxVarianceMask(float2 uv, float3 sourceColor)
{
    float2 px = KALEIDOSCOPE_PixelSize() * KALEIDOSCOPE_SpatialRadiusPixels;
    float mean = 0.0;
    float moments = 0.0;

    [loop]
    for (int y = -1; y <= 1; ++y)
    {
        [loop]
        for (int x = -1; x <= 1; ++x)
        {
            float tap = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(float(x), float(y)) * px), 0.0, 0.0)).rgb);
            mean += tap;
            moments += tap * tap;
        }
    }

    mean /= 9.0;
    moments /= 9.0;
    float variance = max(0.0, moments - mean * mean);
    return saturate(variance * KALEIDOSCOPE_BoxVarianceGain);
}

float KALEIDOSCOPE_DirectionalMask(float2 uv, float3 sourceColor)
{
    float2 dir = float2(cos(radians(KALEIDOSCOPE_DirectionalAngle)), sin(radians(KALEIDOSCOPE_DirectionalAngle)));
    float2 perp = float2(-dir.y, dir.x);
    float2 px = KALEIDOSCOPE_PixelSize() * KALEIDOSCOPE_SpatialRadiusPixels;

    float alongA = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + dir * px), 0.0, 0.0)).rgb);
    float alongB = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - dir * px), 0.0, 0.0)).rgb);
    float crossA = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + perp * px), 0.0, 0.0)).rgb);
    float crossB = KALEIDOSCOPE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - perp * px), 0.0, 0.0)).rgb);

    float along = abs(alongA - alongB);
    float cross = abs(crossA - crossB);
    float response = saturate((along - cross) * KALEIDOSCOPE_DirectionalGain);
    return smoothstep(
        KALEIDOSCOPE_DirectionalThreshold,
        min(1.0, KALEIDOSCOPE_DirectionalThreshold + max(0.0001, KALEIDOSCOPE_DirectionalFeather)),
        response);
}

float KALEIDOSCOPE_HatchLine(float coord, float thickness, float softness)
{
    return MIXSR_SHARED_CoordStripe(coord, thickness, softness);
}

float KALEIDOSCOPE_HatchDiagonalMask(float2 uv)
{
    float2 dir = float2(cos(radians(KALEIDOSCOPE_HatchAngleA)), sin(radians(KALEIDOSCOPE_HatchAngleA)));
    float coord = dot(uv - 0.5, dir) * min(BUFFER_WIDTH, BUFFER_HEIGHT) * KALEIDOSCOPE_SafeRcp(max(0.5, KALEIDOSCOPE_HatchScale));
    return KALEIDOSCOPE_HatchLine(coord, KALEIDOSCOPE_HatchThickness, KALEIDOSCOPE_HatchSoftness);
}

float KALEIDOSCOPE_CrossHatchMask(float2 uv)
{
    float2 dirA = float2(cos(radians(KALEIDOSCOPE_HatchAngleA)), sin(radians(KALEIDOSCOPE_HatchAngleA)));
    float2 dirB = float2(cos(radians(KALEIDOSCOPE_HatchAngleB)), sin(radians(KALEIDOSCOPE_HatchAngleB)));
    float scale = min(BUFFER_WIDTH, BUFFER_HEIGHT) * KALEIDOSCOPE_SafeRcp(max(0.5, KALEIDOSCOPE_HatchScale));
    float lineA = KALEIDOSCOPE_HatchLine(dot(uv - 0.5, dirA) * scale, KALEIDOSCOPE_HatchThickness, KALEIDOSCOPE_HatchSoftness);
    float lineB = KALEIDOSCOPE_HatchLine(dot(uv - 0.5, dirB) * scale, KALEIDOSCOPE_HatchThickness, KALEIDOSCOPE_HatchSoftness);
    return saturate(max(lineA, lineB));
}

float KALEIDOSCOPE_HatchBandsMask(float luma)
{
    float bands = 0.0;
    bands += step(luma, KALEIDOSCOPE_HatchBandA);
    bands += step(luma, KALEIDOSCOPE_HatchBandB);
    bands += step(luma, KALEIDOSCOPE_HatchBandC);
    return bands / 3.0;
}

float KALEIDOSCOPE_LineGuardMask(float3 sourceColor)
{
    float luma = KALEIDOSCOPE_Luma(sourceColor);
    float grad = abs(ddx(luma)) + abs(ddy(luma));
    return smoothstep(KALEIDOSCOPE_LineGuardThreshold, KALEIDOSCOPE_LineGuardThreshold * 3.0, grad) * KALEIDOSCOPE_LineGuardStrength;
}

float KALEIDOSCOPE_PixelGuardMask(float3 sourceColor)
{
    float luma = KALEIDOSCOPE_Luma(sourceColor);
    float sat = KALEIDOSCOPE_Saturation(sourceColor);
    float brightMask = smoothstep(KALEIDOSCOPE_PixelGuardThreshold, 1.0, luma);
    float satMask = smoothstep(KALEIDOSCOPE_PixelGuardSaturation, 1.0, sat);
    return saturate(max(brightMask, satMask) * KALEIDOSCOPE_PixelGuardStrength);
}

float KALEIDOSCOPE_HighlightProtectMask(float3 sourceColor)
{
    float luma = KALEIDOSCOPE_Luma(sourceColor);
    float sat = KALEIDOSCOPE_Saturation(sourceColor);
    float bright = smoothstep(KALEIDOSCOPE_HighlightProtectStart, min(1.0, KALEIDOSCOPE_HighlightProtectStart + KALEIDOSCOPE_HighlightProtectFeather), luma);
    float satBoost = smoothstep(KALEIDOSCOPE_HighlightProtectSaturation, 1.0, sat);
    return saturate(lerp(bright, max(bright, satBoost), KALEIDOSCOPE_HighlightProtectColorBias));
}

float KALEIDOSCOPE_ForegroundProtectMask(float2 uv, float depth)
{
    return KALEIDOSCOPE_DepthNearMask(depth) * KALEIDOSCOPE_DepthAvailability(uv);
}

float KALEIDOSCOPE_SilhouetteProtectMask(float2 uv, float3 sourceColor)
{
    float contrastEdge = KALEIDOSCOPE_ContrastMask(uv, sourceColor);
    float depthEdge = KALEIDOSCOPE_DepthEdgeMask(uv);
    return saturate(max(depthEdge, contrastEdge * KALEIDOSCOPE_SilhouetteContrastBias));
}

float KALEIDOSCOPE_StableSurfaceMask(float2 uv, float3 sourceColor)
{
    float stableDepth = KALEIDOSCOPE_DepthRejectMask(uv);
    float silhouette = KALEIDOSCOPE_SilhouetteProtectMask(uv, sourceColor);
    return saturate(stableDepth * (1.0 - silhouette));
}

float KALEIDOSCOPE_EvaluateMask(int maskMode, float2 uv, float3 sourceColor)
{
    if (maskMode == KALEIDOSCOPE_MASK_OFF) return 0.0;
    if (maskMode == KALEIDOSCOPE_MASK_ALWAYS) return 1.0;
    if (maskMode == KALEIDOSCOPE_MASK_NEVER) return 0.0;

    if (maskMode == KALEIDOSCOPE_MASK_LUMA_DARK)
    {
        return KALEIDOSCOPE_LumaDarkMask(KALEIDOSCOPE_Luma(sourceColor));
    }
    if (maskMode == KALEIDOSCOPE_MASK_LUMA_BRIGHT)
    {
        return KALEIDOSCOPE_LumaBrightMask(KALEIDOSCOPE_Luma(sourceColor));
    }
    if (maskMode == KALEIDOSCOPE_MASK_LUMA_MID)
    {
        return KALEIDOSCOPE_LumaMidMask(KALEIDOSCOPE_Luma(sourceColor));
    }
    if (maskMode == KALEIDOSCOPE_MASK_SATURATION_HIGH)
    {
        return KALEIDOSCOPE_SaturationHighMask(KALEIDOSCOPE_Saturation(sourceColor));
    }
    if (maskMode == KALEIDOSCOPE_MASK_SATURATION_LOW)
    {
        return KALEIDOSCOPE_SaturationLowMask(KALEIDOSCOPE_Saturation(sourceColor));
    }
    if (maskMode == KALEIDOSCOPE_MASK_HUE_WARM)
    {
        return KALEIDOSCOPE_HueSectorMask(KALEIDOSCOPE_Hue(sourceColor), 0.06, KALEIDOSCOPE_HueWidth, KALEIDOSCOPE_HueFeather);
    }
    if (maskMode == KALEIDOSCOPE_MASK_HUE_COOL)
    {
        return KALEIDOSCOPE_HueSectorMask(KALEIDOSCOPE_Hue(sourceColor), 0.62, KALEIDOSCOPE_HueWidth, KALEIDOSCOPE_HueFeather);
    }
    if (maskMode == KALEIDOSCOPE_MASK_HUE_GREEN)
    {
        return KALEIDOSCOPE_HueSectorMask(KALEIDOSCOPE_Hue(sourceColor), 0.33, KALEIDOSCOPE_HueWidth, KALEIDOSCOPE_HueFeather);
    }
    if (maskMode == KALEIDOSCOPE_MASK_CONTRAST) return KALEIDOSCOPE_ContrastMask(uv, sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_DEPTH_AVAILABLE) return KALEIDOSCOPE_DepthAvailability(uv);
    if (maskMode == KALEIDOSCOPE_MASK_DEPTH_NEAR)
    {
        return KALEIDOSCOPE_DepthNearMask(KALEIDOSCOPE_LinearDepth(uv)) * KALEIDOSCOPE_DepthAvailability(uv);
    }
    if (maskMode == KALEIDOSCOPE_MASK_DEPTH_FAR)
    {
        return KALEIDOSCOPE_DepthFarMask(KALEIDOSCOPE_LinearDepth(uv)) * KALEIDOSCOPE_DepthAvailability(uv);
    }
    if (maskMode == KALEIDOSCOPE_MASK_DEPTH_EDGE) return KALEIDOSCOPE_DepthEdgeMask(uv);
    if (maskMode == KALEIDOSCOPE_MASK_DEPTH_REJECT) return KALEIDOSCOPE_DepthRejectMask(uv);
    if (maskMode == KALEIDOSCOPE_MASK_RING_CONTRAST) return KALEIDOSCOPE_RingContrastMask(uv, sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_SPIRAL_DETAIL) return KALEIDOSCOPE_SpiralDetailMask(uv, sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_BOX_VARIANCE) return KALEIDOSCOPE_BoxVarianceMask(uv, sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_DIRECTIONAL) return KALEIDOSCOPE_DirectionalMask(uv, sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_HATCH_DIAGONAL) return KALEIDOSCOPE_HatchDiagonalMask(uv);
    if (maskMode == KALEIDOSCOPE_MASK_CROSS_HATCH) return KALEIDOSCOPE_CrossHatchMask(uv);
    if (maskMode == KALEIDOSCOPE_MASK_HATCH_BANDS) return KALEIDOSCOPE_HatchBandsMask(KALEIDOSCOPE_Luma(sourceColor));
    if (maskMode == KALEIDOSCOPE_MASK_LINE_GUARD) return KALEIDOSCOPE_LineGuardMask(sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_PIXEL_GUARD) return KALEIDOSCOPE_PixelGuardMask(sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_HIGHLIGHT_PROTECT) return KALEIDOSCOPE_HighlightProtectMask(sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_FOREGROUND_PROTECT) return KALEIDOSCOPE_ForegroundProtectMask(uv, KALEIDOSCOPE_LinearDepth(uv));
    if (maskMode == KALEIDOSCOPE_MASK_SILHOUETTE_PROTECT) return KALEIDOSCOPE_SilhouetteProtectMask(uv, sourceColor);
    if (maskMode == KALEIDOSCOPE_MASK_STABLE_SURFACE) return KALEIDOSCOPE_StableSurfaceMask(uv, sourceColor);
    return 0.0;
}

float KALEIDOSCOPE_CombineMasks(float sampleMask, float finalMask)
{
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_MULTIPLY) return sampleMask * finalMask;
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_MIN) return min(sampleMask, finalMask);
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_MAX) return max(sampleMask, finalMask);
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_ADD) return saturate(sampleMask + finalMask);
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_DIFFERENCE) return abs(sampleMask - finalMask);
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_SAMPLE_ONLY) return sampleMask;
    if (KALEIDOSCOPE_CombineMode == KALEIDOSCOPE_COMBINE_FINAL_ONLY) return finalMask;
    return sampleMask * finalMask;
}

#endif

