#ifndef black_wand_MASK_ADAPTER_FXH
#define black_wand_MASK_ADAPTER_FXH

// black wand additive mask adapter. Defines hidden Kaleidoscope compatibility constants, then wraps ../kaleidoscope/kaleidoscope.fxh.
#define KALEIDOSCOPE_CAT_DEBUG "black wand / internal hidden mask helper / 00 Debug"
#define KALEIDOSCOPE_CAT_MAIN "black wand / internal hidden mask helper / 01 Source Mask Stack"
#define KALEIDOSCOPE_CAT_SUB_COLOR "black wand / internal hidden mask helper / 02 Mask Field Controls / Color"
#define KALEIDOSCOPE_CAT_SUB_DEPTH "black wand / internal hidden mask helper / 02 Mask Field Controls / Depth"
#define KALEIDOSCOPE_CAT_SUB_SPATIAL "black wand / internal hidden mask helper / 02 Mask Field Controls / Spatial"
#define KALEIDOSCOPE_CAT_SUB_HATCH "black wand / internal hidden mask helper / 02 Mask Field Controls / Hatch"
#define KALEIDOSCOPE_CAT_SUB_PROTECTION "black wand / internal hidden mask helper / 02 Mask Field Controls / Protection"

static const int KALEIDOSCOPE_DebugView = 0; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DebugExposure = 1.000000; // hidden internal helper constant; not exposed in ReShade menu

static const int KALEIDOSCOPE_SampleMaskMode = 12; // hidden internal helper constant; not exposed in ReShade menu

static const int KALEIDOSCOPE_FinalMaskMode = 3; // hidden internal helper constant; not exposed in ReShade menu

static const int KALEIDOSCOPE_CombineMode = 4; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_MaskStrength = 1.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SceneMix = 0.477000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaDarkStart = 0.450000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaDarkFeather = 0.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaBrightStart = 0.620000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaBrightFeather = 0.160000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaMidCenter = 0.500000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaMidWidth = 0.120000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LumaMidFeather = 0.080000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SaturationHighStart = 0.450000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SaturationHighFeather = 0.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SaturationLowStart = 0.320000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SaturationLowFeather = 0.140000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HueWidth = 0.100000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HueFeather = 0.050000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_ContrastThreshold = 0.035000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_ContrastGain = 2.400000; // hidden internal helper constant; not exposed in ReShade menu

static const int KALEIDOSCOPE_DepthMode = 1; // hidden internal helper constant; not exposed in ReShade menu

static const int KALEIDOSCOPE_DepthInvert = 1; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthTraceScale = 42.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthAvailabilityThreshold = 0.002500; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthNearEnd = 0.260000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthNearFeather = 0.120000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthFarStart = 0.580000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthFarFeather = 0.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthEdgeThreshold = 0.010000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthRejectRadius = 1.500000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DepthRejectThreshold = 0.018000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SpatialRadiusPixels = 2.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SpatialGain = 2.200000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_BoxVarianceGain = 18.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DirectionalAngle = 0.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DirectionalGain = 3.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DirectionalThreshold = 0.080000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_DirectionalFeather = 0.080000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchScale = 40.599998; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchThickness = 0.220000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchSoftness = 0.040000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchAngleA = 35.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchAngleB = -35.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchBandA = 0.720000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchBandB = 0.480000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HatchBandC = 0.240000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LineGuardThreshold = 0.018000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_LineGuardStrength = 0.850000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_PixelGuardThreshold = 0.700000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_PixelGuardSaturation = 0.250000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_PixelGuardStrength = 0.900000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HighlightProtectStart = 0.680000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HighlightProtectFeather = 0.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HighlightProtectSaturation = 0.220000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_HighlightProtectColorBias = 0.350000; // hidden internal helper constant; not exposed in ReShade menu

static const float KALEIDOSCOPE_SilhouetteContrastBias = 0.850000; // hidden internal helper constant; not exposed in ReShade menu

#include "kaleidoscope.fxh"

#ifndef black_wand_MASK_OFF
#define black_wand_MASK_OFF KALEIDOSCOPE_MASK_OFF
#endif
#ifndef black_wand_MASK_ALWAYS
#define black_wand_MASK_ALWAYS KALEIDOSCOPE_MASK_ALWAYS
#endif
#ifndef black_wand_MASK_NEVER
#define black_wand_MASK_NEVER KALEIDOSCOPE_MASK_NEVER
#endif
#ifndef black_wand_MASK_LUMA_DARK
#define black_wand_MASK_LUMA_DARK KALEIDOSCOPE_MASK_LUMA_DARK
#endif
#ifndef black_wand_MASK_LUMA_BRIGHT
#define black_wand_MASK_LUMA_BRIGHT KALEIDOSCOPE_MASK_LUMA_BRIGHT
#endif
#ifndef black_wand_MASK_LUMA_MID
#define black_wand_MASK_LUMA_MID KALEIDOSCOPE_MASK_LUMA_MID
#endif
#ifndef black_wand_MASK_SATURATION_HIGH
#define black_wand_MASK_SATURATION_HIGH KALEIDOSCOPE_MASK_SATURATION_HIGH
#endif
#ifndef black_wand_MASK_SATURATION_LOW
#define black_wand_MASK_SATURATION_LOW KALEIDOSCOPE_MASK_SATURATION_LOW
#endif
#ifndef black_wand_MASK_HUE_WARM
#define black_wand_MASK_HUE_WARM KALEIDOSCOPE_MASK_HUE_WARM
#endif
#ifndef black_wand_MASK_HUE_COOL
#define black_wand_MASK_HUE_COOL KALEIDOSCOPE_MASK_HUE_COOL
#endif
#ifndef black_wand_MASK_HUE_GREEN
#define black_wand_MASK_HUE_GREEN KALEIDOSCOPE_MASK_HUE_GREEN
#endif
#ifndef black_wand_MASK_CONTRAST
#define black_wand_MASK_CONTRAST KALEIDOSCOPE_MASK_CONTRAST
#endif
#ifndef black_wand_MASK_DEPTH_AVAILABLE
#define black_wand_MASK_DEPTH_AVAILABLE KALEIDOSCOPE_MASK_DEPTH_AVAILABLE
#endif
#ifndef black_wand_MASK_DEPTH_NEAR
#define black_wand_MASK_DEPTH_NEAR KALEIDOSCOPE_MASK_DEPTH_NEAR
#endif
#ifndef black_wand_MASK_DEPTH_FAR
#define black_wand_MASK_DEPTH_FAR KALEIDOSCOPE_MASK_DEPTH_FAR
#endif
#ifndef black_wand_MASK_DEPTH_EDGE
#define black_wand_MASK_DEPTH_EDGE KALEIDOSCOPE_MASK_DEPTH_EDGE
#endif
#ifndef black_wand_MASK_DEPTH_REJECT
#define black_wand_MASK_DEPTH_REJECT KALEIDOSCOPE_MASK_DEPTH_REJECT
#endif
#ifndef black_wand_MASK_RING_CONTRAST
#define black_wand_MASK_RING_CONTRAST KALEIDOSCOPE_MASK_RING_CONTRAST
#endif
#ifndef black_wand_MASK_SPIRAL_DETAIL
#define black_wand_MASK_SPIRAL_DETAIL KALEIDOSCOPE_MASK_SPIRAL_DETAIL
#endif
#ifndef black_wand_MASK_BOX_VARIANCE
#define black_wand_MASK_BOX_VARIANCE KALEIDOSCOPE_MASK_BOX_VARIANCE
#endif
#ifndef black_wand_MASK_DIRECTIONAL
#define black_wand_MASK_DIRECTIONAL KALEIDOSCOPE_MASK_DIRECTIONAL
#endif
#ifndef black_wand_MASK_HATCH_DIAGONAL
#define black_wand_MASK_HATCH_DIAGONAL KALEIDOSCOPE_MASK_HATCH_DIAGONAL
#endif
#ifndef black_wand_MASK_CROSS_HATCH
#define black_wand_MASK_CROSS_HATCH KALEIDOSCOPE_MASK_CROSS_HATCH
#endif
#ifndef black_wand_MASK_HATCH_BANDS
#define black_wand_MASK_HATCH_BANDS KALEIDOSCOPE_MASK_HATCH_BANDS
#endif
#ifndef black_wand_MASK_LINE_GUARD
#define black_wand_MASK_LINE_GUARD KALEIDOSCOPE_MASK_LINE_GUARD
#endif
#ifndef black_wand_MASK_PIXEL_GUARD
#define black_wand_MASK_PIXEL_GUARD KALEIDOSCOPE_MASK_PIXEL_GUARD
#endif
#ifndef black_wand_MASK_HIGHLIGHT_PROTECT
#define black_wand_MASK_HIGHLIGHT_PROTECT KALEIDOSCOPE_MASK_HIGHLIGHT_PROTECT
#endif
#ifndef black_wand_MASK_FOREGROUND_PROTECT
#define black_wand_MASK_FOREGROUND_PROTECT KALEIDOSCOPE_MASK_FOREGROUND_PROTECT
#endif
#ifndef black_wand_MASK_SILHOUETTE_PROTECT
#define black_wand_MASK_SILHOUETTE_PROTECT KALEIDOSCOPE_MASK_SILHOUETTE_PROTECT
#endif
#ifndef black_wand_MASK_STABLE_SURFACE
#define black_wand_MASK_STABLE_SURFACE KALEIDOSCOPE_MASK_STABLE_SURFACE
#endif

float black_wand_Mask_Luma(float3 sourceColor)
{
    return KALEIDOSCOPE_Luma(sourceColor);
}

float black_wand_Mask_Evaluate(int maskMode, float2 uv, float3 sourceColor)
{
    return saturate(KALEIDOSCOPE_EvaluateMask(maskMode, uv, sourceColor));
}

float black_wand_Mask_CombineByMode(float sampleMask, float finalMask, int combineMode)
{
    if (combineMode == KALEIDOSCOPE_COMBINE_MULTIPLY) return saturate(sampleMask * finalMask);
    if (combineMode == KALEIDOSCOPE_COMBINE_MIN) return saturate(min(sampleMask, finalMask));
    if (combineMode == KALEIDOSCOPE_COMBINE_MAX) return saturate(max(sampleMask, finalMask));
    if (combineMode == KALEIDOSCOPE_COMBINE_ADD) return saturate(sampleMask + finalMask);
    if (combineMode == KALEIDOSCOPE_COMBINE_DIFFERENCE) return saturate(abs(sampleMask - finalMask));
    if (combineMode == KALEIDOSCOPE_COMBINE_SAMPLE_ONLY) return saturate(sampleMask);
    if (combineMode == KALEIDOSCOPE_COMBINE_FINAL_ONLY) return saturate(finalMask);
    return saturate(sampleMask * finalMask);
}

float black_wand_Mask_Invert(float maskValue)
{
    return saturate(1.0 - maskValue);
}

float black_wand_Mask_Intersection(float maskA, float maskB)
{
    return saturate(maskA * maskB);
}

float black_wand_Mask_Union(float maskA, float maskB)
{
    return saturate(max(maskA, maskB));
}

float black_wand_Mask_Exclusion(float includeMask, float excludeMask)
{
    return saturate(includeMask * (1.0 - excludeMask));
}

float black_wand_Mask_SourceSample(float2 uv, float3 sourceColor)
{
    return black_wand_Mask_Evaluate(KALEIDOSCOPE_SampleMaskMode, uv, sourceColor);
}

float black_wand_Mask_SourceFinal(float2 uv, float3 sourceColor)
{
    return black_wand_Mask_Evaluate(KALEIDOSCOPE_FinalMaskMode, uv, sourceColor);
}

float black_wand_Mask_SourceCombined(float2 uv, float3 sourceColor)
{
    float sampleMask = black_wand_Mask_SourceSample(uv, sourceColor);
    float finalMask = black_wand_Mask_SourceFinal(uv, sourceColor);
    return black_wand_Mask_CombineByMode(sampleMask, finalMask, KALEIDOSCOPE_CombineMode);
}

float black_wand_Mask_SourceWeighted(float2 uv, float3 sourceColor)
{
    return saturate(black_wand_Mask_SourceCombined(uv, sourceColor) * KALEIDOSCOPE_MaskStrength);
}

float black_wand_Mask_SourceDisagreement(float2 uv, float3 sourceColor)
{
    float sampleMask = black_wand_Mask_SourceSample(uv, sourceColor);
    float finalMask = black_wand_Mask_SourceFinal(uv, sourceColor);
    return saturate(abs(sampleMask - finalMask));
}

float3 black_wand_Mask_SourceMaskedScene(float2 uv, float3 sourceColor)
{
    float weightedMask = black_wand_Mask_SourceWeighted(uv, sourceColor);
    float3 maskColor = lerp(sourceColor * 0.25, sourceColor, weightedMask);
    return saturate(lerp(sourceColor, maskColor, KALEIDOSCOPE_SceneMix));
}

#endif

