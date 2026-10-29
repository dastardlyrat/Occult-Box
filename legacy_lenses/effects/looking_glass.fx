// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: RC-4
// Capability: Standalone lens server for previewing sampling layouts, reductions, and analysis masks.

#include "ReShade.fxh"
#include "../header/looking_glass.fxh"

#define LOOKING_GLASS_MASK_OFF 0
#define LOOKING_GLASS_MASK_COVERAGE 1
#define LOOKING_GLASS_MASK_VORONOI 2
#define LOOKING_GLASS_MASK_VORONOI_EDGE 3
#define LOOKING_GLASS_MASK_RADIAL_ORDER 4
#define LOOKING_GLASS_MASK_SEQUENCE_ORDER 5
#define LOOKING_GLASS_MASK_GAP_HEAT 6
#define LOOKING_GLASS_MASK_ANGULAR_SECTOR 7

#define LOOKING_GLASS_CAT_DEBUG "looking glass / 00 Debug"
#define LOOKING_GLASS_CAT_MAIN "looking glass / 01 Main Settings"
#define LOOKING_GLASS_CAT_SUB_PREVIEW "looking glass / 02 Sub Main Settings / Preview"
#define LOOKING_GLASS_CAT_SUB_SAMPLING "looking glass / 02 Sub Main Settings / Sampling"
#define LOOKING_GLASS_CAT_SUB_FIBONACCI "looking glass / 02 Sub Main Settings / Fibonacci"
#define LOOKING_GLASS_CAT_SUB_ANALYSIS "looking glass / 02 Sub Main Settings / Analysis"

uniform int LOOKING_GLASS_DebugView <
    ui_type = "combo";
    ui_label = "Debug View";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final (Passthrough)\0Lens Pattern\0Tap Index\0Sample Footprint Overlay\0Sample Average\0Sample Delta\0Analysis Mask\0Analysis Applied Overlay\0";
    ui_tooltip = "Chooses which lens debug output to show. Pattern and Tap Index visualize placement, Sample views show image response, Analysis Mask shows raw spatial diagnostics, and Analysis Applied Overlay shows the selected analysis mask applied over the live image.";
> = 0;

uniform float LOOKING_GLASS_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens dim debug views so sparse taps, weak overlays, and low-contrast analysis fields are easier to inspect. Does not change sampling or final image output.";
> = 1.0;

uniform float LOOKING_GLASS_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.70;

uniform float LOOKING_GLASS_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float LOOKING_GLASS_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float LOOKING_GLASS_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int LOOKING_GLASS_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = LOOKING_GLASS_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float LOOKING_GLASS_DebugShape(float value)
{
    float debugLow = min(LOOKING_GLASS_DebugBlackPoint, LOOKING_GLASS_DebugWhitePoint - 0.0001);
    float debugHigh = max(LOOKING_GLASS_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, LOOKING_GLASS_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, LOOKING_GLASS_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, LOOKING_GLASS_DebugGamma));
    if (LOOKING_GLASS_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 LOOKING_GLASS_DebugShape3(float3 value)
{
    return float3(LOOKING_GLASS_DebugShape(value.r), LOOKING_GLASS_DebugShape(value.g), LOOKING_GLASS_DebugShape(value.b));
}


uniform int LOOKING_GLASS_LensMode <
    ui_type = "combo";
    ui_label = "Lens";
    ui_category = LOOKING_GLASS_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Point1\0Horizontal Pair2\0Vertical Pair2\0Diagonal Pair2 A\0Diagonal Pair2 B\0Cross5\0X5\0CrossX9\0Box4\0Box9\0Box25\0Rect Horizontal15\0Rect Vertical15\0Diamond9\0Diamond13\0Ring4\0Ring8\0Ring9\0Ring12\0Radial13\0Spiral13\0Golden21\0Bounded55\0Fibonacci55\0Fibonacci89\0";
    ui_tooltip = "Selects the tap layout used by all previews and sample-based debug modes. Pair, box, diamond, and ring lenses are useful for oriented analysis, while bounded and Fibonacci families give broader organic coverage.";
> = 21;

uniform int LOOKING_GLASS_AnalysisMaskMode <
    ui_type = "combo";
    ui_label = "Analysis Mask";
    ui_category = LOOKING_GLASS_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Coverage\0Voronoi Cells\0Voronoi Edge\0Radial Order\0Sequence Order\0Gap Heat\0Angular Sector\0";
    ui_tooltip = "Selects the analysis coloring used by Analysis Mask. These modes help inspect coverage gaps, ordering, Voronoi ownership, and how reduced tap counts distribute across the lens.";
> = 2;

uniform float LOOKING_GLASS_SampleRadiusPixels <
    ui_type = "slider";
    ui_label = "Sample Radius";
    ui_category = LOOKING_GLASS_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 24.0; ui_step = 0.01;
    ui_tooltip = "Controls how far each tap samples from the center in pixel space. Higher values widen the true sampling footprint and make Sample Average and Sample Delta respond more strongly.";
> = 2.0;

uniform float LOOKING_GLASS_RotationDegrees <
    ui_type = "slider";
    ui_label = "Rotation";
    ui_category = LOOKING_GLASS_CAT_MAIN; ui_category_closed = false;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the active tap layout around the center without changing tap count or relative spacing. Use it to inspect directional bias or align a lens with scene structure.";
> = 0.0;

uniform float LOOKING_GLASS_PreviewRadius <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = LOOKING_GLASS_CAT_SUB_PREVIEW; ui_category_closed = true;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales the on-screen debug layout for Lens Pattern, Tap Index, Analysis Mask, and the tiled portion of Sample Footprint Overlay. It does not change the real sample radius used for image fetches.";
> = 0.24;

uniform float LOOKING_GLASS_PreviewTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = LOOKING_GLASS_CAT_SUB_PREVIEW; ui_category_closed = true;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the debug pattern across the screen. Higher values show more copies of the lens layout, which is useful when comparing spacing and rotation at a glance.";
> = 4.0;

uniform float LOOKING_GLASS_MarkerSize <
    ui_type = "slider";
    ui_label = "Marker Size";
    ui_category = LOOKING_GLASS_CAT_SUB_PREVIEW; ui_category_closed = true;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Changes how large each tap appears in debug previews and overlays. Larger values make individual taps easier to read, especially in dense Fibonacci layouts.";
> = 0.016;

uniform float LOOKING_GLASS_PatternSoftness <
    ui_type = "slider";
    ui_label = "Pattern Softness";
    ui_category = LOOKING_GLASS_CAT_SUB_PREVIEW; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens the edges of debug markers and guide rings. Lower values give crisp dots and rings, while higher values create broader, more blended previews.";
> = 0.012;

uniform float LOOKING_GLASS_DeltaBoost <
    ui_type = "slider";
    ui_label = "Delta Boost";
    ui_category = LOOKING_GLASS_CAT_SUB_SAMPLING; ui_category_closed = true;
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.1;
    ui_tooltip = "Amplifies the difference image in Sample Delta. Raise it when the lens effect is subtle and you want to see which areas the current layout changes the most.";
> = 4.0;

uniform float LOOKING_GLASS_AverageMix <
    ui_type = "slider";
    ui_label = "Average Mix";
    ui_category = LOOKING_GLASS_CAT_SUB_SAMPLING; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between the untouched image and the lens-averaged image in Sample Average. Lower values keep more of the source; higher values reveal the full averaging effect.";
> = 1.0;

uniform int LOOKING_GLASS_FibActiveTapCount <
    ui_type = "slider";
    ui_label = "Fibonacci Active Taps";
    ui_category = LOOKING_GLASS_CAT_SUB_FIBONACCI; ui_category_closed = true;
    ui_min = 1; ui_max = LOOKING_GLASS_MAX_TAPS; ui_step = 1;
    ui_tooltip = "Sets how many taps are active for Fibonacci lens families. Lower values reduce cost and simplify the layout while trying to keep coverage spread across the full lens.";
> = 55;

uniform int LOOKING_GLASS_FibReductionMode <
    ui_type = "combo";
    ui_label = "Reduction Mode";
    ui_category = LOOKING_GLASS_CAT_SUB_FIBONACCI; ui_category_closed = true;
    ui_items = "Staggered\0Sequential\0";
    ui_tooltip = "Controls how reduced Fibonacci tap counts are chosen. Staggered keeps taps spread over the full pattern, while Sequential fills from the earliest canonical taps first.";
> = 0;

uniform float LOOKING_GLASS_AnalysisContrast <
    ui_type = "slider";
    ui_label = "Analysis Contrast";
    ui_category = LOOKING_GLASS_CAT_SUB_ANALYSIS; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Increases contrast in Analysis Mask views so boundaries, ownership changes, and gap differences are easier to see.";
> = 2.0;

uniform float LOOKING_GLASS_AnalysisBlend <
    ui_type = "slider";
    ui_label = "Analysis Blend";
    ui_category = LOOKING_GLASS_CAT_SUB_ANALYSIS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Controls how strongly some analysis coloring is blended into the debug output. Higher values make categorical analysis views read more boldly.";
> = 1.0;


uniform float LOOKING_GLASS_AnalysisApplyStrength <
    ui_type = "slider";
    ui_label = "Analysis Apply Strength";
    ui_category = LOOKING_GLASS_CAT_SUB_ANALYSIS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Controls how strongly the Analysis Applied Overlay debug view applies the selected analysis mask over the live image. This affects debug visualization only.";
> = 0.65;

float LOOKING_GLASS_DebugScalar(float value)
{
    return LOOKING_GLASS_DebugShape(value);
}

float3 LOOKING_GLASS_IndexColor(float t)
{
    float3 phase = float3(0.0, 0.3333333, 0.6666667);
    return saturate(0.55 + 0.45 * cos(6.2831853 * (t + phase)));
}

float LOOKING_GLASS_PixelMarker(float2 uv, float2 centerUv, float markerPixels, float softnessPixels)
{
    float2 pixelDelta = (uv - centerUv) / LOOKING_GLASS_PixelSize();
    float distPixels = length(pixelDelta);
    return 1.0 - smoothstep(markerPixels, markerPixels + max(0.25, softnessPixels), distPixels);
}

float2 LOOKING_GLASS_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, LOOKING_GLASS_PreviewTiles);
    return frac(uv * tiles) - 0.5;
}

float LOOKING_GLASS_TapMarker(float2 localUV, float2 tapOffset)
{
    float dist = length(localUV - tapOffset * LOOKING_GLASS_PreviewRadius);
    float outer = LOOKING_GLASS_MarkerSize + LOOKING_GLASS_PatternSoftness;
    return 1.0 - smoothstep(LOOKING_GLASS_MarkerSize, outer, dist);
}

float LOOKING_GLASS_GuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - LOOKING_GLASS_PreviewRadius);
    return 1.0 - smoothstep(0.0, LOOKING_GLASS_PatternSoftness * 1.25, dist);
}

int LOOKING_GLASS_CurrentActiveTapCount()
{
    return LOOKING_GLASS_GetActiveTapCount(LOOKING_GLASS_LensMode, LOOKING_GLASS_FibActiveTapCount);
}

float LOOKING_GLASS_LensPattern(float2 uv)
{
    int tapCount = LOOKING_GLASS_CurrentActiveTapCount();
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(LOOKING_GLASS_LensMode);
    if (tapCount <= 0)
    {
        return 0.0;
    }

    int reductionStride = LOOKING_GLASS_GetReductionStride(
        LOOKING_GLASS_LensMode,
        tapCount,
        canonicalTapCount,
        LOOKING_GLASS_FibReductionMode);
    float2 localUV = LOOKING_GLASS_LocalPreviewUV(uv);
    float sum = 0.0;
    float2 rotationBasisX = 0.0.xx;
    float2 rotationBasisY = 0.0.xx;
    LOOKING_GLASS_GetRotationBasis(LOOKING_GLASS_RotationDegrees, rotationBasisX, rotationBasisY);

    [loop]
    for (int i = 0; i < LOOKING_GLASS_MAX_TAPS; ++i)
    {
        if (i >= tapCount) break;

        int canonicalIndex = LOOKING_GLASS_GetCanonicalIndexFast(
            LOOKING_GLASS_LensMode,
            i,
            tapCount,
            canonicalTapCount,
            LOOKING_GLASS_FibReductionMode,
            reductionStride);
        float2 tapOffset = LOOKING_GLASS_ApplyRotationBasis(
            LOOKING_GLASS_GetCanonicalOffset(LOOKING_GLASS_LensMode, canonicalIndex),
            rotationBasisX,
            rotationBasisY);
        sum += LOOKING_GLASS_TapMarker(localUV, tapOffset);
    }

    return saturate(sum + LOOKING_GLASS_GuideRing(localUV) * 0.35);
}

float3 LOOKING_GLASS_TapIndexView(float2 uv)
{
    int tapCount = LOOKING_GLASS_CurrentActiveTapCount();
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(LOOKING_GLASS_LensMode);

    if (tapCount <= 0 || canonicalTapCount <= 0)
    {
        return 0.0.xxx;
    }

    float2 localUV = LOOKING_GLASS_LocalPreviewUV(uv);
    int reductionStride = LOOKING_GLASS_GetReductionStride(
        LOOKING_GLASS_LensMode,
        tapCount,
        canonicalTapCount,
        LOOKING_GLASS_FibReductionMode);
    float2 rotationBasisX = 0.0.xx;
    float2 rotationBasisY = 0.0.xx;
    LOOKING_GLASS_GetRotationBasis(LOOKING_GLASS_RotationDegrees, rotationBasisX, rotationBasisY);
    float bestMarker = 0.0;
    float3 bestColor = 0.0.xxx;

    [loop]
    for (int i = 0; i < LOOKING_GLASS_MAX_TAPS; ++i)
    {
        if (i >= tapCount) break;

        int canonicalIndex = LOOKING_GLASS_GetCanonicalIndexFast(
            LOOKING_GLASS_LensMode,
            i,
            tapCount,
            canonicalTapCount,
            LOOKING_GLASS_FibReductionMode,
            reductionStride);
        float2 tapOffset = LOOKING_GLASS_ApplyRotationBasis(
            LOOKING_GLASS_GetCanonicalOffset(LOOKING_GLASS_LensMode, canonicalIndex),
            rotationBasisX,
            rotationBasisY);
        float marker = LOOKING_GLASS_TapMarker(localUV, tapOffset);
        float normalizedIndex = (canonicalTapCount > 1) ? (float(canonicalIndex) / max(1.0, float(canonicalTapCount - 1))) : 0.0;
        float3 color = (canonicalIndex == 0) ? 1.0.xxx : LOOKING_GLASS_IndexColor(normalizedIndex);
        if (marker > bestMarker)
        {
            bestMarker = marker;
            bestColor = color;
        }
    }

    return saturate(bestColor + LOOKING_GLASS_GuideRing(localUV) * 0.18);
}

float3 LOOKING_GLASS_AnalysisMaskColor(float2 uv)
{
    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_OFF)
    {
        return 0.0.xxx;
    }

    int tapCount = LOOKING_GLASS_CurrentActiveTapCount();
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(LOOKING_GLASS_LensMode);

    if (tapCount <= 0 || canonicalTapCount <= 0)
    {
        return 0.0.xxx;
    }

    float2 localUV = LOOKING_GLASS_LocalPreviewUV(uv);
    int reductionStride = LOOKING_GLASS_GetReductionStride(
        LOOKING_GLASS_LensMode,
        tapCount,
        canonicalTapCount,
        LOOKING_GLASS_FibReductionMode);
    float2 rotationBasisX = 0.0.xx;
    float2 rotationBasisY = 0.0.xx;
    LOOKING_GLASS_GetRotationBasis(LOOKING_GLASS_RotationDegrees, rotationBasisX, rotationBasisY);
    float nearestDist = 1e6;
    float secondDist = 1e6;
    int nearestLogicalIndex = 0;
    int nearestCanonicalIndex = 0;
    float2 nearestPos = 0.0.xx;

    [loop]
    for (int i = 0; i < LOOKING_GLASS_MAX_TAPS; ++i)
    {
        if (i >= tapCount) break;

        int canonicalIndex = LOOKING_GLASS_GetCanonicalIndexFast(
            LOOKING_GLASS_LensMode,
            i,
            tapCount,
            canonicalTapCount,
            LOOKING_GLASS_FibReductionMode,
            reductionStride);
        float2 tapOffset = LOOKING_GLASS_ApplyRotationBasis(
            LOOKING_GLASS_GetCanonicalOffset(LOOKING_GLASS_LensMode, canonicalIndex),
            rotationBasisX,
            rotationBasisY) * LOOKING_GLASS_PreviewRadius;
        float dist = length(localUV - tapOffset);

        if (dist < nearestDist)
        {
            secondDist = nearestDist;
            nearestDist = dist;
            nearestLogicalIndex = i;
            nearestCanonicalIndex = canonicalIndex;
            nearestPos = tapOffset;
        }
        else if (dist < secondDist)
        {
            secondDist = dist;
        }
    }

    float radial = saturate(length(nearestPos) / max(0.0001, LOOKING_GLASS_PreviewRadius));
    float angle = atan2(nearestPos.y, nearestPos.x);
    float angleNorm = frac(angle / 6.2831853 + 1.0);
    float coverage = 1.0 - smoothstep(0.0, LOOKING_GLASS_PreviewRadius * 0.90, nearestDist);
    float edge = 1.0 - saturate((secondDist - nearestDist) * 20.0 / max(0.1, LOOKING_GLASS_AnalysisContrast));
    float gapHeat = saturate(nearestDist / max(0.005, LOOKING_GLASS_PreviewRadius * 0.85));
    float canonicalNorm = (canonicalTapCount > 1) ? (float(nearestCanonicalIndex) / max(1.0, float(canonicalTapCount - 1))) : 0.0;
    float logicalNorm = (tapCount > 1) ? (float(nearestLogicalIndex) / max(1.0, float(tapCount - 1))) : 0.0;

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_COVERAGE)
    {
        float v = LOOKING_GLASS_DebugScalar(pow(abs(coverage), 1.0 / max(0.5, LOOKING_GLASS_AnalysisContrast)));
        return float3(v, v * 0.85, v * 0.65);
    }

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_VORONOI)
    {
        return LOOKING_GLASS_IndexColor(canonicalNorm) * LOOKING_GLASS_AnalysisBlend;
    }

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_VORONOI_EDGE)
    {
        float e = LOOKING_GLASS_DebugScalar(edge);
        return float3(e * 0.35, e * 0.8, e);
    }

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_RADIAL_ORDER)
    {
        float r = LOOKING_GLASS_DebugScalar(radial * LOOKING_GLASS_AnalysisContrast);
        return float3(r * 0.4, r, 1.0 - r * 0.35);
    }

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_SEQUENCE_ORDER)
    {
        return lerp(LOOKING_GLASS_IndexColor(logicalNorm), LOOKING_GLASS_IndexColor(canonicalNorm), 0.65);
    }

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_GAP_HEAT)
    {
        float g = LOOKING_GLASS_DebugScalar(gapHeat * LOOKING_GLASS_AnalysisContrast);
        return float3(g, g * g * 0.45, 0.15 + (1.0 - g) * 0.65);
    }

    if (LOOKING_GLASS_AnalysisMaskMode == LOOKING_GLASS_MASK_ANGULAR_SECTOR)
    {
        return LOOKING_GLASS_IndexColor(angleNorm);
    }

    return 0.0.xxx;
}


float LOOKING_GLASS_AnalysisMaskScalar(float3 analysisColor)
{
    return saturate(max(max(analysisColor.r, analysisColor.g), analysisColor.b));
}

float3 LOOKING_GLASS_AnalysisAppliedOverlay(float3 sourceColor, float3 analysisColor)
{
    float applyAmount = saturate(LOOKING_GLASS_AnalysisApplyStrength * LOOKING_GLASS_AnalysisMaskScalar(analysisColor));
    float3 overlayColor = saturate(lerp(sourceColor, analysisColor, LOOKING_GLASS_AnalysisApplyStrength));
    return lerp(sourceColor, overlayColor, applyAmount);
}

float3 LOOKING_GLASS_SampleFootprintOverlay(float2 uv, float3 sourceColor)
{
    int tapCount = LOOKING_GLASS_CurrentActiveTapCount();
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(LOOKING_GLASS_LensMode);

    if (tapCount <= 0 || canonicalTapCount <= 0 || LOOKING_GLASS_SampleRadiusPixels <= 0.0)
    {
        return sourceColor;
    }

    int reductionStride = LOOKING_GLASS_GetReductionStride(
        LOOKING_GLASS_LensMode,
        tapCount,
        canonicalTapCount,
        LOOKING_GLASS_FibReductionMode);
    float2 rotationBasisX = 0.0.xx;
    float2 rotationBasisY = 0.0.xx;
    LOOKING_GLASS_GetRotationBasis(LOOKING_GLASS_RotationDegrees, rotationBasisX, rotationBasisY);

    float2 centerUv = 0.5.xx;
    float2 localUV = LOOKING_GLASS_LocalPreviewUV(uv);
    float markerPixels = max(0.75, LOOKING_GLASS_MarkerSize * min(BUFFER_WIDTH, BUFFER_HEIGHT) * 0.18);
    float markerSoftnessPixels = max(0.35, LOOKING_GLASS_PatternSoftness * min(BUFFER_WIDTH, BUFFER_HEIGHT) * 0.10);
    float guide = LOOKING_GLASS_GuideRing(localUV);
    float footprintWeight = saturate(LOOKING_GLASS_SampleRadiusPixels / 24.0);

    float3 overlay = sourceColor;
    overlay = lerp(overlay, saturate(sourceColor + float3(0.12, 0.08, 0.02)), guide * (0.20 + 0.25 * footprintWeight));

    [loop]
    for (int i = 0; i < LOOKING_GLASS_MAX_TAPS; ++i)
    {
        if (i >= tapCount) break;

        int canonicalIndex = LOOKING_GLASS_GetCanonicalIndexFast(
            LOOKING_GLASS_LensMode,
            i,
            tapCount,
            canonicalTapCount,
            LOOKING_GLASS_FibReductionMode,
            reductionStride);
        float2 tapOffset = LOOKING_GLASS_ApplyRotationBasis(
            LOOKING_GLASS_GetCanonicalOffset(LOOKING_GLASS_LensMode, canonicalIndex),
            rotationBasisX,
            rotationBasisY);
        float marker = LOOKING_GLASS_TapMarker(localUV, tapOffset);
        float normalizedIndex = (canonicalTapCount > 1) ? (float(canonicalIndex) / max(1.0, float(canonicalTapCount - 1))) : 0.0;
        float3 markerColor = (canonicalIndex == 0) ? 1.0.xxx : LOOKING_GLASS_IndexColor(normalizedIndex);

        // Add a small center-screen marker too so the real sample anchor remains visible.
        float2 tapUv = centerUv + tapOffset * LOOKING_GLASS_SampleRadiusPixels * LOOKING_GLASS_PixelSize();
        float realMarker = LOOKING_GLASS_PixelMarker(uv, tapUv, markerPixels, markerSoftnessPixels);
        float overlayMarker = max(marker, realMarker);
        overlay = lerp(overlay, markerColor, overlayMarker * 0.90);
    }

    float centerMarker = max(
        LOOKING_GLASS_TapMarker(localUV, 0.0.xx),
        LOOKING_GLASS_PixelMarker(uv, centerUv, markerPixels + 0.75, markerSoftnessPixels + 0.75));
    overlay = lerp(overlay, 1.0.xxx, centerMarker * 0.65);
    return overlay;
}

float4 LOOKING_GLASS_MainPS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;

    if (LOOKING_GLASS_DebugView == 0)
    {
        return float4(sourceColor, 1.0);
    }

    if (LOOKING_GLASS_DebugView == 1)
    {
        float lensPattern = LOOKING_GLASS_DebugScalar(LOOKING_GLASS_LensPattern(uv));
        float3 patternColor = float3(lensPattern, lensPattern * 0.82, lensPattern * 0.68);
        return float4(patternColor, 1.0);
    }

    if (LOOKING_GLASS_DebugView == 2)
    {
        return float4(LOOKING_GLASS_TapIndexView(uv), 1.0);
    }

    if (LOOKING_GLASS_DebugView == 3)
    {
        return float4(LOOKING_GLASS_SampleFootprintOverlay(uv, sourceColor), 1.0);
    }

    if (LOOKING_GLASS_DebugView == 6)
    {
        return float4(saturate(LOOKING_GLASS_AnalysisMaskColor(uv)), 1.0);
    }

    if (LOOKING_GLASS_DebugView == 7)
    {
        float3 analysisColor = saturate(LOOKING_GLASS_AnalysisMaskColor(uv));
        return float4(LOOKING_GLASS_AnalysisAppliedOverlay(sourceColor, analysisColor), 1.0);
    }

    float3 averageColor = LOOKING_GLASS_SampleAverage(
        ReShade::BackBuffer,
        uv,
        LOOKING_GLASS_LensMode,
        LOOKING_GLASS_FibActiveTapCount,
        LOOKING_GLASS_FibReductionMode,
        LOOKING_GLASS_SampleRadiusPixels,
        LOOKING_GLASS_RotationDegrees);

    if (LOOKING_GLASS_DebugView == 4)
    {
        float3 mixedAverage = lerp(sourceColor, averageColor, LOOKING_GLASS_AverageMix);
        return float4(mixedAverage, 1.0);
    }

    if (LOOKING_GLASS_DebugView == 5)
    {
        float3 deltaColor = abs(averageColor - sourceColor) * LOOKING_GLASS_DeltaBoost;
        return float4(saturate(deltaColor), 1.0);
    }

    return float4(sourceColor, 1.0);
}

technique looking_glass < ui_label = "looking glass :: standalone lens server"; ui_tooltip = "Standalone lens host for inspecting tap layouts, true sample footprints, reduced Fibonacci subsets, and spatial analysis masks."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = LOOKING_GLASS_MainPS;
    }
}

