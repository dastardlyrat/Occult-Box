#ifndef OBSIDIAN_MIRROR_FXH
#define OBSIDIAN_MIRROR_FXH

#include "shared_core.fxh"
#include "shared_fibonacci.fxh"
#include "shared_lens55.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define OBSIDIAN_LENS_OFF 0
#define OBSIDIAN_LENS_ORGANIC55 1
#define OBSIDIAN_LENS_GOLDEN_SWEEP 2
#define OBSIDIAN_LENS_STAGGERED55 3
#define OBSIDIAN_LENS_RING9 4
#define OBSIDIAN_LENS_SPIRAL13 5
#define OBSIDIAN_LENS_RECT_H15 6
#define OBSIDIAN_LENS_RECT_V15 7
#define OBSIDIAN_LENS_DIAMOND13 8
#define OBSIDIAN_LENS_BOX25 9

float2 OBSIDIAN_RotateField(float2 p)
{
    return SHARED_Rotate(p, OBSIDIAN_FieldRotation);
}

int OBSIDIAN_CanonicalTapCount()
{
    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_RING9)
        return 9;

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_SPIRAL13)
        return 13;

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_RECT_H15 || OBSIDIAN_LensMode == OBSIDIAN_LENS_RECT_V15)
        return 15;

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_DIAMOND13)
        return 13;

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_BOX25)
        return 25;

    return SHARED_LENS55_TAP_COUNT;
}

int OBSIDIAN_ActiveTapCount()
{
    return clamp(OBSIDIAN_TapBudget, 1, OBSIDIAN_CanonicalTapCount());
}

int OBSIDIAN_CanonicalIndex(int logicalIndex)
{
    return SHARED_GetFibonacciCanonicalIndex(logicalIndex, OBSIDIAN_ActiveTapCount(), OBSIDIAN_CanonicalTapCount(), OBSIDIAN_ReductionMode, 0, OBSIDIAN_CanonicalTapCount());
}

float2 OBSIDIAN_GetOffset(int logicalIndex)
{
    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_OFF)
        return 0.0.xx;

    int canonicalIndex = OBSIDIAN_CanonicalIndex(logicalIndex);
    canonicalIndex = clamp(canonicalIndex, 0, OBSIDIAN_CanonicalTapCount() - 1);

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_RING9)
    {
        if (canonicalIndex <= 0)
            return 0.0.xx;

        float angle = (6.2831853 * float(canonicalIndex - 1)) / 8.0;
        return OBSIDIAN_RotateField(float2(cos(angle), sin(angle)) * OBSIDIAN_FieldScale);
    }

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_SPIRAL13)
    {
        if (canonicalIndex <= 0)
            return 0.0.xx;

        float sampleIndex = float(canonicalIndex - 1);
        float radial = sqrt((sampleIndex + 1.0) / 12.0);
        float2 dir = SHARED_GoldenDirection(sampleIndex + 0.5 + OBSIDIAN_FibonacciAnchor);
        return OBSIDIAN_RotateField(dir * radial * OBSIDIAN_FieldScale);
    }

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_RECT_H15)
    {
        return OBSIDIAN_RotateField(float2((float(canonicalIndex) - 7.0) / 7.0, 0.0) * OBSIDIAN_FieldScale);
    }

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_RECT_V15)
    {
        return OBSIDIAN_RotateField(float2(0.0, (float(canonicalIndex) - 7.0) / 7.0) * OBSIDIAN_FieldScale);
    }

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_DIAMOND13)
    {
        float2 offset = 0.0.xx;
        if (canonicalIndex == 1) offset = float2(0.0, -0.5);
        else if (canonicalIndex == 2) offset = float2(0.5, 0.0);
        else if (canonicalIndex == 3) offset = float2(0.0, 0.5);
        else if (canonicalIndex == 4) offset = float2(-0.5, 0.0);
        else if (canonicalIndex == 5) offset = float2(0.0, -1.0);
        else if (canonicalIndex == 6) offset = float2(1.0, 0.0);
        else if (canonicalIndex == 7) offset = float2(0.0, 1.0);
        else if (canonicalIndex == 8) offset = float2(-1.0, 0.0);
        else if (canonicalIndex == 9) offset = float2(-0.5, -0.5);
        else if (canonicalIndex == 10) offset = float2(0.5, -0.5);
        else if (canonicalIndex == 11) offset = float2(0.5, 0.5);
        else if (canonicalIndex == 12) offset = float2(-0.5, 0.5);
        return OBSIDIAN_RotateField(offset * OBSIDIAN_FieldScale);
    }

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        float2 offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
        return OBSIDIAN_RotateField(offset * OBSIDIAN_FieldScale);
    }

    if (OBSIDIAN_LensMode == OBSIDIAN_LENS_GOLDEN_SWEEP)
    {
        float2 dir = SHARED_GoldenDirection(float(canonicalIndex) + OBSIDIAN_FibonacciAnchor);
        float growth = SHARED_Lens55FibonacciGrowth(canonicalIndex, OBSIDIAN_ActiveTapCount());
        return OBSIDIAN_RotateField(dir * growth * 0.95 * OBSIDIAN_FieldScale);
    }

    return OBSIDIAN_RotateField(SHARED_Lens55Offset(canonicalIndex) * OBSIDIAN_FieldScale);
}

float OBSIDIAN_PlotMarker(float2 p, float2 center, float radius)
{
    return 1.0 - smoothstep(radius, radius * 1.9, length(p - center));
}

float2 OBSIDIAN_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, OBSIDIAN_DebugPatternTiles);
    return frac(uv * tiles) - 0.5;
}

float OBSIDIAN_DebugTapMarker(float2 localUV, float2 tapOffset)
{
    float2 plotted = tapOffset * OBSIDIAN_DebugPatternScale;
    float dist = length(localUV - plotted);
    float outer = OBSIDIAN_DebugMarkerSize + OBSIDIAN_DebugPatternSoftness;
    return 1.0 - smoothstep(OBSIDIAN_DebugMarkerSize, outer, dist);
}

float OBSIDIAN_DebugGuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - OBSIDIAN_DebugPatternScale);
    return 1.0 - smoothstep(0.0, OBSIDIAN_DebugPatternSoftness * 1.25, dist);
}

float3 OBSIDIAN_IndexColor(float t)
{
    float x = frac(t);
    float3 a = float3(0.90, 0.28, 0.18);
    float3 b = float3(0.96, 0.84, 0.24);
    float3 c = float3(0.18, 0.82, 0.58);
    float3 d = float3(0.20, 0.48, 0.96);

    if (x < 0.3333) return lerp(a, b, x / 0.3333);
    if (x < 0.6666) return lerp(b, c, (x - 0.3333) / 0.3333);
    return lerp(c, d, (x - 0.6666) / 0.3334);
}

float3 OBSIDIAN_TiledLensPattern(float2 uv)
{
    float2 localUV = OBSIDIAN_LocalPreviewUV(uv);
    float marker = OBSIDIAN_DebugTapMarker(localUV, 0.0.xx);
    int activeTapCount = OBSIDIAN_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;
        marker = max(marker, OBSIDIAN_DebugTapMarker(localUV, OBSIDIAN_GetOffset(i)));
    }

    marker = saturate(marker + OBSIDIAN_DebugGuideRing(localUV) * 0.35);
    return OBSIDIAN_DebugShape3(lerp(float3(0.05, 0.07, 0.10), float3(0.92, 0.97, 1.0), marker));
}

float3 OBSIDIAN_TiledTapIndexField(float2 uv)
{
    float2 localUV = OBSIDIAN_LocalPreviewUV(uv);
    int activeTapCount = OBSIDIAN_ActiveTapCount();
    float nearestDist = 1e6;
    int nearestLogicalIndex = 0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;
        float dist = length(localUV - OBSIDIAN_GetOffset(i) * OBSIDIAN_DebugPatternScale);
        if (dist < nearestDist)
        {
            nearestDist = dist;
            nearestLogicalIndex = i;
        }
    }

    float marker = OBSIDIAN_DebugTapMarker(localUV, 0.0.xx);
    [loop]
    for (int j = 0; j < SHARED_LENS55_TAP_COUNT; ++j)
    {
        if (j >= activeTapCount) break;
        marker = max(marker, OBSIDIAN_DebugTapMarker(localUV, OBSIDIAN_GetOffset(j)));
    }

    float logicalNorm = (activeTapCount > 1) ? (float(nearestLogicalIndex) / float(activeTapCount - 1)) : 0.0;
    float3 tapColor = OBSIDIAN_IndexColor(logicalNorm);
    float visibility = saturate(marker + OBSIDIAN_DebugGuideRing(localUV) * 0.20);
    float3 outColor = lerp(float3(0.05, 0.07, 0.10), tapColor, visibility);
    return OBSIDIAN_DebugShape3(outColor);
}

float3 OBSIDIAN_SampleAverage(float2 uv)
{
    float3 source = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    float3 accum = source;
    float weight = 1.0;
    int activeTapCount = OBSIDIAN_ActiveTapCount();
    float2 px = SHARED_PixelSize() * OBSIDIAN_SampleRadius;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;
        accum += tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + OBSIDIAN_GetOffset(i) * px), 0.0, 0.0)).rgb;
        weight += 1.0;
    }

    return lerp(source, accum / max(0.00001, weight), OBSIDIAN_AverageMix);
}

float3 OBSIDIAN_SampleDelta(float2 uv)
{
    float3 source = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    return OBSIDIAN_DebugShape3(abs(OBSIDIAN_SampleAverage(uv) - source) * 6.0);
}

float3 OBSIDIAN_TiledCoverageMask(float2 uv)
{
    float2 localUV = OBSIDIAN_LocalPreviewUV(uv);
    float coverage = 0.0;
    int activeTapCount = OBSIDIAN_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;
        float2 plotted = OBSIDIAN_GetOffset(i) * OBSIDIAN_DebugPatternScale;
        coverage = max(coverage, 1.0 - smoothstep(OBSIDIAN_DebugMarkerSize * 2.0, OBSIDIAN_DebugMarkerSize * 8.0, length(localUV - plotted)));
    }

    coverage = saturate(max(coverage, OBSIDIAN_DebugGuideRing(localUV) * 0.25));
    return OBSIDIAN_DebugShape3(float3(coverage, coverage * 0.8, coverage * 0.5));
}

float3 OBSIDIAN_AnalysisMaskColor(float2 uv)
{
    float2 localUV = OBSIDIAN_LocalPreviewUV(uv);
    int activeTapCount = OBSIDIAN_ActiveTapCount();
    int canonicalTapCount = OBSIDIAN_CanonicalTapCount();

    float nearestDist = 1e6;
    float secondDist = 1e6;
    int nearestLogicalIndex = 0;
    int nearestCanonicalIndex = 0;
    float2 nearestPos = 0.0.xx;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;

        int canonicalIndex = OBSIDIAN_CanonicalIndex(i);
        float2 tapOffset = OBSIDIAN_GetOffset(i) * OBSIDIAN_DebugPatternScale;
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

    float radial = saturate(length(nearestPos) / max(0.0001, OBSIDIAN_DebugPatternScale));
    float angle = atan2(nearestPos.y, nearestPos.x);
    float angleNorm = frac(angle / 6.2831853 + 1.0);
    float coverage = 1.0 - smoothstep(0.0, OBSIDIAN_DebugPatternScale * 0.90, nearestDist);
    float edge = 1.0 - saturate((secondDist - nearestDist) * 20.0 / max(0.1, OBSIDIAN_AnalysisContrast));
    float gapHeat = saturate(nearestDist / max(0.005, OBSIDIAN_DebugPatternScale * 0.85));
    float canonicalNorm = (canonicalTapCount > 1) ? (float(nearestCanonicalIndex) / float(canonicalTapCount - 1)) : 0.0;
    float logicalNorm = (activeTapCount > 1) ? (float(nearestLogicalIndex) / float(activeTapCount - 1)) : 0.0;

    if (OBSIDIAN_AnalysisMode == 0)
    {
        float v = pow(abs(saturate(coverage)), 1.0 / max(0.5, OBSIDIAN_AnalysisContrast));
        return float3(v, v * 0.85, v * 0.65);
    }
    if (OBSIDIAN_AnalysisMode == 1)
    {
        return OBSIDIAN_IndexColor(canonicalNorm) * OBSIDIAN_AnalysisBlend;
    }
    if (OBSIDIAN_AnalysisMode == 2)
    {
        float e = saturate(edge * OBSIDIAN_AnalysisContrast);
        return float3(e * 0.35, e * 0.8, e);
    }
    if (OBSIDIAN_AnalysisMode == 3)
    {
        float r = saturate(radial * OBSIDIAN_AnalysisContrast);
        return float3(r * 0.4, r, 1.0 - r * 0.35);
    }
    if (OBSIDIAN_AnalysisMode == 4)
    {
        return lerp(OBSIDIAN_IndexColor(logicalNorm), OBSIDIAN_IndexColor(canonicalNorm), 0.65);
    }
    if (OBSIDIAN_AnalysisMode == 5)
    {
        float g = saturate(gapHeat * OBSIDIAN_AnalysisContrast);
        return float3(g, g * g * 0.45, 0.15 + (1.0 - g) * 0.65);
    }

    return OBSIDIAN_IndexColor(angleNorm);
}

float OBSIDIAN_AnalysisMaskScalar(float3 analysisColor)
{
    return saturate(max(max(analysisColor.r, analysisColor.g), analysisColor.b));
}

float3 OBSIDIAN_AnalysisAppliedOverlay(float3 sourceColor, float3 analysisColor)
{
    float applyAmount = saturate(OBSIDIAN_AnalysisApplyStrength * OBSIDIAN_AnalysisMaskScalar(analysisColor));
    float3 overlayColor = saturate(lerp(sourceColor, analysisColor, OBSIDIAN_AnalysisApplyStrength));
    return lerp(sourceColor, overlayColor, applyAmount);
}

float3 OBSIDIAN_CenterSampleFootprintOverlay(float2 uv, float3 source)
{
    float2 px = SHARED_PixelSize() * OBSIDIAN_SampleRadius;
    float marker = OBSIDIAN_PlotMarker(uv, 0.5.xx, OBSIDIAN_DebugMarkerSize * 0.5);
    int activeTapCount = OBSIDIAN_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;
        float2 sampleUv = saturate(0.5.xx + OBSIDIAN_GetOffset(i) * px);
        marker = max(marker, OBSIDIAN_PlotMarker(uv, sampleUv, OBSIDIAN_DebugMarkerSize * 0.5));
    }

    float3 overlayColor = lerp(source, float3(0.98, 0.96, 0.82), saturate(marker));
    return OBSIDIAN_DebugShape3(overlayColor);
}

float4 OBSIDIAN_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 source = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    if (OBSIDIAN_Enable == 0 || OBSIDIAN_DebugView == 0 || OBSIDIAN_LensMode == OBSIDIAN_LENS_OFF)
        return float4(source, 1.0);

    float3 outColor = source;
    if (OBSIDIAN_DebugView == 1) outColor = OBSIDIAN_TiledLensPattern(uv);
    else if (OBSIDIAN_DebugView == 2) outColor = OBSIDIAN_TiledTapIndexField(uv);
    else if (OBSIDIAN_DebugView == 3) outColor = OBSIDIAN_CenterSampleFootprintOverlay(uv, source);
    else if (OBSIDIAN_DebugView == 4) outColor = OBSIDIAN_TiledCoverageMask(uv);
    else if (OBSIDIAN_DebugView == 5) outColor = OBSIDIAN_DebugShape3(OBSIDIAN_AnalysisMaskColor(uv));
    else if (OBSIDIAN_DebugView == 6) outColor = OBSIDIAN_AnalysisAppliedOverlay(source, OBSIDIAN_AnalysisMaskColor(uv));
    else if (OBSIDIAN_DebugView == 7) outColor = OBSIDIAN_SampleAverage(uv);
    else outColor = OBSIDIAN_SampleDelta(uv);

    return float4(saturate(outColor), 1.0);
}

#endif
