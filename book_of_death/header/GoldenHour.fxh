#ifndef GOLDEN_HOUR_FXH
#define GOLDEN_HOUR_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"
#include "shared_fibonacci.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define GOLDEN_LENS_OFF 0
#define GOLDEN_LENS_ORGANIC55 1
#define GOLDEN_LENS_GOLDEN_SWEEP 2
#define GOLDEN_LENS_STAGGERED55 3
#define GOLDEN_LENS_RING9 4
#define GOLDEN_LENS_SPIRAL13 5
#define GOLDEN_LENS_RECT_H15 6
#define GOLDEN_LENS_RECT_V15 7
#define GOLDEN_LENS_DIAMOND13 8
#define GOLDEN_LENS_BOX25 9

#define GOLDEN_MASK_OFF 0
#define GOLDEN_MASK_FOG 1
#define GOLDEN_MASK_LIGHT 2
#define GOLDEN_MASK_DEPTH 3
#define GOLDEN_MASK_FAR_DETAIL 4
#define GOLDEN_MASK_CONTRAST 5
#define GOLDEN_MASK_COMPOSITE 6

#define GOLDEN_BREAKUP_OFF 0
#define GOLDEN_BREAKUP_BIO 1
#define GOLDEN_BREAKUP_FIVE_STAGE 2
#define GOLDEN_BREAKUP_CROSS 3

#define GOLDEN_EPS 0.00001

float3 GOLDEN_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
}

float GOLDEN_Luma(float3 c)
{
    return SHARED_Luma(c);
}

float GOLDEN_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), GOLDEN_DepthMode, GOLDEN_DepthInvert);
}

float GOLDEN_DepthConfidence(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), GOLDEN_DepthMode, GOLDEN_DepthInvert, GOLDEN_DepthTraceScale, GOLDEN_DepthAvailabilityThreshold);
}

float GOLDEN_DepthEdge(float2 uv)
{
    return SHARED_DepthEdgeMask(saturate(uv), GOLDEN_DepthMode, GOLDEN_DepthInvert, GOLDEN_DepthTraceScale, GOLDEN_DepthAvailabilityThreshold, GOLDEN_DepthEdgeThreshold);
}

float GOLDEN_DebugScalar(float v)
{
    return GOLDEN_DebugShape(v);
}

float GOLDEN_PlotMarker(float2 p, float2 center, float radius)
{
    return 1.0 - smoothstep(radius, radius * 1.9, length(p - center));
}

float2 GOLDEN_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, GOLDEN_DebugPatternTiles);
    return frac(uv * tiles) - 0.5;
}

float GOLDEN_DebugTapMarker(float2 localUV, float2 tapOffset)
{
    float2 plotted = tapOffset * GOLDEN_DebugPatternScale;
    float dist = length(localUV - plotted);
    float outer = GOLDEN_DebugMarkerSize + GOLDEN_DebugPatternSoftness;
    return 1.0 - smoothstep(GOLDEN_DebugMarkerSize, outer, dist);
}

float GOLDEN_DebugGuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - GOLDEN_DebugPatternScale);
    return 1.0 - smoothstep(0.0, GOLDEN_DebugPatternSoftness * 1.25, dist);
}

float3 GOLDEN_SaturateAroundLuma(float3 color, float amount)
{
    float luma = GOLDEN_Luma(color);
    return lerp(luma.xxx, color, amount);
}

int GOLDEN_QualityTapCap()
{
    if (GOLDEN_QualityTier == 0) return 9;
    if (GOLDEN_QualityTier == 1) return 21;
    if (GOLDEN_QualityTier == 2) return 34;
    return 55;
}

float2 GOLDEN_RotateField(float2 p)
{
    return SHARED_Rotate(p, GOLDEN_FieldRotation);
}

int GOLDEN_CanonicalTapCount(int lensMode)
{
    if (lensMode == GOLDEN_LENS_RING9) return 9;
    if (lensMode == GOLDEN_LENS_SPIRAL13) return 13;
    if (lensMode == GOLDEN_LENS_RECT_H15 || lensMode == GOLDEN_LENS_RECT_V15) return 15;
    if (lensMode == GOLDEN_LENS_DIAMOND13) return 13;
    if (lensMode == GOLDEN_LENS_BOX25) return 25;
    return SHARED_LENS55_TAP_COUNT;
}

int GOLDEN_ActiveTapCount(int lensMode)
{
    int requested = min(GOLDEN_TapBudget, GOLDEN_QualityTapCap());
    return clamp(requested, 1, GOLDEN_CanonicalTapCount(lensMode));
}

int GOLDEN_ActiveTapCountForBudget(int lensMode, int requestedBudget)
{
    int requested = min(requestedBudget, GOLDEN_QualityTapCap());
    return clamp(requested, 1, GOLDEN_CanonicalTapCount(lensMode));
}

int GOLDEN_CanonicalIndex(int lensMode, int logicalIndex)
{
    return SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        GOLDEN_ActiveTapCount(lensMode),
        GOLDEN_CanonicalTapCount(lensMode),
        GOLDEN_ReductionMode,
        0,
        GOLDEN_CanonicalTapCount(lensMode));
}

float2 GOLDEN_LensOffset(int lensMode, int logicalIndex)
{
    if (lensMode == GOLDEN_LENS_OFF)
        return 0.0.xx;

    int canonicalIndex = GOLDEN_CanonicalIndex(lensMode, logicalIndex);
    canonicalIndex = clamp(canonicalIndex, 0, GOLDEN_CanonicalTapCount(lensMode) - 1);

    if (lensMode == GOLDEN_LENS_RING9)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(canonicalIndex - 1)) / 8.0;
        return GOLDEN_RotateField(float2(cos(angle), sin(angle)) * GOLDEN_FieldScale);
    }

    if (lensMode == GOLDEN_LENS_SPIRAL13)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float sampleIndex = float(canonicalIndex - 1);
        float radial = sqrt((sampleIndex + 1.0) / 12.0);
        float2 dir = SHARED_GoldenDirection(sampleIndex + 0.5 + GOLDEN_FibonacciAnchor);
        return GOLDEN_RotateField(dir * radial * GOLDEN_FieldScale);
    }

    if (lensMode == GOLDEN_LENS_RECT_H15)
    {
        return GOLDEN_RotateField(float2((float(canonicalIndex) - 7.0) / 7.0, 0.0) * GOLDEN_FieldScale);
    }

    if (lensMode == GOLDEN_LENS_RECT_V15)
    {
        return GOLDEN_RotateField(float2(0.0, (float(canonicalIndex) - 7.0) / 7.0) * GOLDEN_FieldScale);
    }

    if (lensMode == GOLDEN_LENS_DIAMOND13)
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
        return GOLDEN_RotateField(offset * GOLDEN_FieldScale);
    }

    if (lensMode == GOLDEN_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        float2 offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
        return GOLDEN_RotateField(offset * GOLDEN_FieldScale);
    }

    if (lensMode == GOLDEN_LENS_GOLDEN_SWEEP)
    {
        float2 dir = SHARED_GoldenDirection(float(canonicalIndex) + GOLDEN_FibonacciAnchor);
        float growth = SHARED_Lens55FibonacciGrowth(canonicalIndex, GOLDEN_ActiveTapCount(lensMode));
        return GOLDEN_RotateField(dir * growth * 0.95 * GOLDEN_FieldScale);
    }

    return GOLDEN_RotateField(SHARED_Lens55Offset(canonicalIndex) * GOLDEN_FieldScale);
}

float GOLDEN_DepthRejectWeight(float centerDepth, float sampleDepth, float confidence)
{
    float delta = abs(sampleDepth - centerDepth) * max(1.0, GOLDEN_DepthTraceScale);
    float strict = 1.0 - smoothstep(GOLDEN_DepthRejectStart, GOLDEN_DepthRejectEnd, delta);
    return saturate(lerp(1.0, strict, confidence));
}

float GOLDEN_DepthAcceptField(float2 uv, int lensMode)
{
    if (lensMode == GOLDEN_LENS_OFF)
        return 0.0;

    int tapCount = GOLDEN_ActiveTapCount(lensMode);
    float2 px = SHARED_PixelSize() * GOLDEN_GatherRadiusPixels;
    float centerDepth = GOLDEN_Depth(uv);
    float confidence = GOLDEN_DepthConfidence(uv);
    float accepted = 0.0;
    float count = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
        float2 sampleUv = saturate(uv + GOLDEN_LensOffset(lensMode, i) * px * growth);
        float sampleDepth = GOLDEN_Depth(sampleUv);
        accepted += GOLDEN_DepthRejectWeight(centerDepth, sampleDepth, confidence);
        count += 1.0;
    }

    return (count > 0.0) ? saturate(accepted / count) : 0.0;
}

float GOLDEN_LensField(float2 uv, int lensMode, float radiusPixels)
{
    if (lensMode == GOLDEN_LENS_OFF)
        return 1.0;

    int tapCount = min(GOLDEN_ActiveTapCountForBudget(lensMode, GOLDEN_ApplicationTapBudget), 21);
    float2 px = SHARED_PixelSize() * radiusPixels;
    float centerDepth = GOLDEN_Depth(uv);
    float centerLuma = GOLDEN_Luma(GOLDEN_Source(uv));
    float confidence = GOLDEN_DepthConfidence(uv);
    float sum = 0.0;
    float weightSum = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 sampleUv = saturate(uv + GOLDEN_LensOffset(lensMode, i) * px);
        float3 sampleColor = GOLDEN_Source(sampleUv);
        float sampleDepth = GOLDEN_Depth(sampleUv);
        float sampleLuma = GOLDEN_Luma(sampleColor);
        float depthWeight = GOLDEN_DepthRejectWeight(centerDepth, sampleDepth, confidence);
        float contrast = abs(sampleLuma - centerLuma);
        sum += contrast * depthWeight;
        weightSum += depthWeight;
    }

    float field = (weightSum > GOLDEN_EPS) ? (sum / weightSum) : 0.0;
    return saturate(field * 10.0);
}

float3 GOLDEN_TiledFieldView(float2 uv, int lensMode, int requestedBudget)
{
    if (lensMode == GOLDEN_LENS_OFF)
        return 0.0.xxx;

    float2 localUV = GOLDEN_LocalPreviewUV(uv);
    int tapCount = min(GOLDEN_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float marker = GOLDEN_DebugTapMarker(localUV, 0.0.xx);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        marker = max(marker, GOLDEN_DebugTapMarker(localUV, GOLDEN_LensOffset(lensMode, i)));
    }

    marker = saturate(marker + GOLDEN_DebugGuideRing(localUV) * 0.35);
    return GOLDEN_DebugShape3(lerp(float3(0.05, 0.07, 0.10), float3(0.92, 0.97, 1.0), marker));
}

float3 GOLDEN_CenterFieldFootprintOverlay(float2 uv, float3 source, int lensMode, int requestedBudget, float radiusPixels, bool applyGrowth)
{
    if (lensMode == GOLDEN_LENS_OFF)
        return source;

    float2 px = SHARED_PixelSize() * radiusPixels;
    int tapCount = min(GOLDEN_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float marker = GOLDEN_PlotMarker(uv, 0.5.xx, GOLDEN_DebugMarkerSize * 0.5);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float growth = applyGrowth ? SHARED_Lens55FibonacciGrowth(i, tapCount) : 1.0;
        float2 sampleUv = saturate(0.5.xx + GOLDEN_LensOffset(lensMode, i) * px * growth);
        marker = max(marker, GOLDEN_PlotMarker(uv, sampleUv, GOLDEN_DebugMarkerSize * 0.5));
    }

    float3 overlayColor = lerp(source, float3(0.98, 0.96, 0.82), saturate(marker));
    return GOLDEN_DebugShape3(overlayColor);
}

float GOLDEN_PatternLine(float2 p, float2 dir, float phase, float density, float lo, float hi)
{
    float v = sin(dot(p, dir) * density + phase);
    return smoothstep(lo, hi, v);
}

float2 GOLDEN_OrganicDirection(float2 lensOffset, float fibIndex, float2 uv, float tapNorm)
{
    float2 lensDir = normalize(float2(0.23 - lensOffset.y, 0.17 + lensOffset.x + frac(fibIndex * 0.000618)));
    float armAngle = (6.2831853 * frac(fibIndex * 0.61803398875)) + dot(uv * (GOLDEN_BreakupDensity * 18.0), float2(0.1618, 0.2718));
    float2 branchDir = normalize(SHARED_Rotate(lensDir, degrees(armAngle + tapNorm * 1.08)));
    return normalize(lerp(lensDir, branchDir, 0.65));
}

float GOLDEN_ProceduralBioBreakup(float2 uv)
{
    float2 p = uv * GOLDEN_BreakupScale;
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int tapCount = clamp(GOLDEN_BreakupTapBudget, 3, 34);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 o = SHARED_Lens55Offset(i);
        float fi = GOLDEN_FibonacciAnchor + float(i);
        float tapNorm = (float(i) + 0.5) / 55.0;
        float2 dir = GOLDEN_OrganicDirection(o, fi, uv, tapNorm);
        float phase = fi * 0.013 + GOLDEN_BreakupFlow * 0.15 + dot(uv * (GOLDEN_BreakupDensity * 48.0), float2(0.754, 0.569));
        float hatch = GOLDEN_PatternLine(p + o * GOLDEN_BreakupTapSpread, dir, phase, GOLDEN_BreakupDensity, 0.72, 0.96);
        sumValue += hatch;
        sumWeight += 1.0;
    }

    return saturate(sumValue / max(GOLDEN_EPS, sumWeight));
}

float GOLDEN_FiveStageBreakup(float2 uv, float depth, float localContrast)
{
    float smallScale = GOLDEN_BreakupScale * 1.30;
    float medScale = GOLDEN_BreakupScale * 1.00;
    float verySmallScale = GOLDEN_BreakupScale * 1.70;

    float small = saturate((sin((uv.x + uv.y) * smallScale + depth * 21.0) * sin((uv.x - uv.y) * (smallScale * 0.825) - depth * 17.0) * 0.5 + 0.5));
    float med = saturate((sin((uv.x + uv.y) * medScale + depth * 19.0) * sin((uv.x - uv.y) * (medScale * 0.810) - depth * 15.0) * 0.5 + 0.5));
    float tiny = saturate((sin((uv.x + uv.y) * verySmallScale + depth * 23.0) * sin((uv.x - uv.y) * (verySmallScale * 0.840) - depth * 19.0) * 0.5 + 0.5));

    float stagePos = saturate(depth);
    float wNear = 1.0 - saturate(abs(stagePos - 0.10) / 0.30);
    float wForward = 1.0 - saturate(abs(stagePos - 0.32) / 0.30);
    float wCenter = 1.0 - saturate(abs(stagePos - 0.50) / 0.30);
    float wBack = 1.0 - saturate(abs(stagePos - 0.68) / 0.30);
    float wFar = 1.0 - saturate(abs(stagePos - 0.90) / 0.30);

    float blended = (small * wNear + med * wForward + tiny * wCenter + med * wBack + small * wFar) / max(GOLDEN_EPS, wNear + wForward + wCenter + wBack + wFar);
    return saturate(lerp(blended, blended * (0.6 + localContrast * 0.4), 0.5));
}

float GOLDEN_CrossBreakup(float2 uv, float3 sourceColor)
{
    float2 p = uv * GOLDEN_BreakupScale;
    float luma = GOLDEN_Luma(sourceColor);
    float darkness = 1.0 - smoothstep(0.18, 0.88, luma);
    float diagA = GOLDEN_PatternLine(p, normalize(float2(1.0, 1.0)), GOLDEN_BreakupFlow, GOLDEN_BreakupDensity, 0.72, 0.96);
    float diagB = GOLDEN_PatternLine(p, normalize(float2(1.0, -1.0)), GOLDEN_BreakupFlow * 1.17 + 1.3, GOLDEN_BreakupDensity * 0.92, 0.70, 0.95);
    float layerA = diagA * smoothstep(0.10, 0.75, darkness);
    float layerB = diagB * smoothstep(0.42, 0.98, darkness);
    return saturate(max(layerA, layerB));
}

float GOLDEN_BreakupField(float2 uv, float3 sourceColor)
{
    if (GOLDEN_BreakupMode == GOLDEN_BREAKUP_OFF)
        return 1.0;

    if (GOLDEN_BreakupMode == GOLDEN_BREAKUP_BIO)
        return saturate(0.65 + 0.35 * GOLDEN_ProceduralBioBreakup(uv));

    if (GOLDEN_BreakupMode == GOLDEN_BREAKUP_FIVE_STAGE)
    {
        float depth = GOLDEN_Depth(uv);
        float contrast = saturate(SHARED_LocalContrast(uv, sourceColor) * 2.0);
        return saturate(0.65 + 0.35 * GOLDEN_FiveStageBreakup(uv, depth, contrast));
    }

    return saturate(0.65 + 0.35 * GOLDEN_CrossBreakup(uv, sourceColor));
}

float GOLDEN_FogEvidence(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = GOLDEN_DepthConfidence(uv);
    float depth = GOLDEN_Depth(uv);
    float depthBias = smoothstep(max(GOLDEN_DepthStart, 0.08), max(GOLDEN_FarDetailStart, 0.35), depth);
    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(GOLDEN_FogBrightnessFloor, GOLDEN_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(GOLDEN_FogDesaturation, min(1.0, GOLDEN_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(GOLDEN_FogLowContrast, max(GOLDEN_FogLowContrast + 0.01, GOLDEN_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(GOLDEN_ContrastThreshold, GOLDEN_ContrastThreshold * 6.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(GOLDEN_LightThreshold, GOLDEN_LightThreshold + GOLDEN_LightSoftness, luma);
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float GOLDEN_LightShield(float3 source)
{
    float luma = SHARED_Luma(source);
    float maxv = max(source.r, max(source.g, source.b));
    float minv = min(source.r, min(source.g, source.b));
    float sat = (maxv <= GOLDEN_EPS) ? 0.0 : ((maxv - minv) / maxv);
    float satMask = smoothstep(0.22, 1.0, sat);
    float lumaMask = smoothstep(GOLDEN_LightThreshold, GOLDEN_LightThreshold + GOLDEN_LightSoftness, luma);
    float peakMask = smoothstep(GOLDEN_LightThreshold, GOLDEN_LightThreshold + GOLDEN_LightSoftness, maxv);
    return saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
}

float GOLDEN_DepthWindow(float2 uv)
{
    float availability = GOLDEN_DepthConfidence(uv);
    float depth = GOLDEN_Depth(uv);
    float d0 = min(GOLDEN_DepthStart, GOLDEN_DepthEnd);
    float d1 = max(GOLDEN_DepthStart, GOLDEN_DepthEnd);
    float soft = 0.01;
    float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
    float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
    return saturate(beginMask * endMask * availability);
}

float GOLDEN_ContrastMask(float2 uv, float3 source)
{
    float contrast = SHARED_LocalContrast(uv, source);
    return smoothstep(
        GOLDEN_ContrastThreshold,
        GOLDEN_ContrastThreshold * max(1.25, GOLDEN_ContrastGain),
        contrast * GOLDEN_ContrastGain);
}

float GOLDEN_FarDetailStack(float2 uv, float3 source)
{
    float depthValid = GOLDEN_DepthConfidence(uv);
    float depth = GOLDEN_Depth(uv);
    float farMask = smoothstep(GOLDEN_FarDetailStart, GOLDEN_FarDetailEnd, depth);
    float edgeMask = GOLDEN_DepthEdge(uv);
    float edgeSuppress = 1.0 - saturate(edgeMask);
    float detailMask = GOLDEN_ContrastMask(uv, source);
    return saturate(depthValid * farMask * edgeSuppress * detailMask);
}

float GOLDEN_SelectedMask(float2 uv, float3 sourceColor)
{
    float selected = 1.0;

    if (GOLDEN_MaskMode == GOLDEN_MASK_FOG)
        selected = 1.0 - GOLDEN_FogEvidence(uv, sourceColor);
    else if (GOLDEN_MaskMode == GOLDEN_MASK_LIGHT)
        selected = 1.0 - GOLDEN_LightShield(sourceColor);
    else if (GOLDEN_MaskMode == GOLDEN_MASK_DEPTH)
        selected = GOLDEN_DepthWindow(uv);
    else if (GOLDEN_MaskMode == GOLDEN_MASK_FAR_DETAIL)
        selected = GOLDEN_FarDetailStack(uv, sourceColor);
    else if (GOLDEN_MaskMode == GOLDEN_MASK_CONTRAST)
        selected = GOLDEN_ContrastMask(uv, sourceColor);
    else if (GOLDEN_MaskMode == GOLDEN_MASK_COMPOSITE)
    {
        float allow = max(GOLDEN_DepthWindow(uv), max(GOLDEN_FarDetailStack(uv, sourceColor), GOLDEN_ContrastMask(uv, sourceColor)));
        float protect = max(GOLDEN_FogEvidence(uv, sourceColor), GOLDEN_LightShield(sourceColor));
        selected = saturate(allow * (1.0 - protect * 0.85));
    }

    return saturate(selected * GOLDEN_MaskStrength);
}

float GOLDEN_FinalApplicationGate(float applicationMask, float applicationField, float breakupField, float depthAccept, float hitCoverage)
{
    return
        saturate(lerp(1.0, applicationMask, GOLDEN_MaskInfluence)) *
        saturate(lerp(1.0, applicationField, GOLDEN_ApplicationLensStrength)) *
        saturate(lerp(1.0, breakupField, GOLDEN_BreakupInfluence)) *
        saturate(0.35 + 0.65 * depthAccept) *
        saturate(0.35 + 0.65 * hitCoverage);
}

float3 GOLDEN_LocalIndirect(float2 uv, out float hitCoverage, out float samplingField, out float applicationField, out float depthAccept, out float selectedMask, out float fogEvidence, out float breakupField)
{
    float3 sourceColor = GOLDEN_Source(uv);
    int tapCount = GOLDEN_ActiveTapCount(GOLDEN_SamplingLensMode);
    float3 result = sourceColor;

    hitCoverage = 0.0;
    samplingField = 1.0;
    applicationField = GOLDEN_LensField(uv, GOLDEN_ApplicationLensMode, GOLDEN_ApplicationRadiusPixels);
    depthAccept = 1.0;
    selectedMask = GOLDEN_SelectedMask(uv, sourceColor);
    fogEvidence = GOLDEN_FogEvidence(uv, sourceColor);
    breakupField = GOLDEN_BreakupField(uv, sourceColor);

    if (GOLDEN_SamplingLensMode != GOLDEN_LENS_OFF && tapCount > 0)
    {
        float2 px = SHARED_PixelSize() * GOLDEN_GatherRadiusPixels;
        float centerDepth = GOLDEN_Depth(uv);
        float centerLuma = GOLDEN_Luma(sourceColor);
        float confidence = GOLDEN_DepthConfidence(uv);
        float3 sumColor = sourceColor;
        float weightSum = 1.0;
        float accepted = 0.0;

        [loop]
        for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
        {
            if (i >= tapCount) break;

            float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
            float2 sampleUv = saturate(uv + GOLDEN_LensOffset(GOLDEN_SamplingLensMode, i) * px * growth);
            float3 sampleColor = GOLDEN_Source(sampleUv);
            float sampleLuma = GOLDEN_Luma(sampleColor);
            float sampleDepth = GOLDEN_Depth(sampleUv);
            float depthWeight = GOLDEN_DepthRejectWeight(centerDepth, sampleDepth, confidence);
            float distanceWeight = SHARED_SafeRcp(1.0 + length(GOLDEN_LensOffset(GOLDEN_SamplingLensMode, i)) * GOLDEN_DistanceFalloff);
            float lightDelta = max(0.0, sampleLuma - centerLuma + GOLDEN_BrightSampleBias);
            float lightWeight = smoothstep(0.0, 0.40, lightDelta + 0.05);
            float contrastWeight = 0.75 + 0.25 * saturate(abs(sampleLuma - centerLuma) * 4.0);
            float w = saturate(depthWeight * distanceWeight * (0.35 + 0.65 * lightWeight) * contrastWeight);

            sumColor += sampleColor * w;
            weightSum += w;
            accepted += depthWeight;
        }

        hitCoverage = saturate(weightSum / max(1.0, float(tapCount)));
        depthAccept = saturate(accepted / max(1.0, float(tapCount)));
        samplingField = GOLDEN_LensField(uv, GOLDEN_SamplingLensMode, GOLDEN_GatherRadiusPixels * 0.55);

        float3 indirect = sumColor / max(GOLDEN_EPS, weightSum);
        result = GOLDEN_SaturateAroundLuma(indirect, GOLDEN_BounceSaturation);
    }

    return result;
}

float4 GOLDEN_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = GOLDEN_Source(uv);
    if (GOLDEN_Enable == 0)
        return float4(sourceColor, 1.0);

    float hitCoverage = 0.0;
    float samplingField = 1.0;
    float applicationField = 1.0;
    float depthAccept = 1.0;
    float selectedMask = 1.0;
    float fogEvidence = 0.0;
    float breakupField = 1.0;
    float3 localIndirect = GOLDEN_LocalIndirect(uv, hitCoverage, samplingField, applicationField, depthAccept, selectedMask, fogEvidence, breakupField);

    float centerLuma = GOLDEN_Luma(sourceColor);
    float shadowBias = pow(abs(saturate(1.0 - centerLuma)), max(0.25, GOLDEN_ShadowPreference));
    float3 bounce = max(localIndirect - sourceColor * GOLDEN_SourceRetention, 0.0.xxx);
    float effectiveMask = GOLDEN_FinalApplicationGate(selectedMask, applicationField, breakupField, depthAccept, hitCoverage);

    float3 bounceContribution = bounce * shadowBias * GOLDEN_GIStrength * GOLDEN_MasterIntensity * GOLDEN_MaxContribution * effectiveMask;
    float3 finalColor = saturate(sourceColor + bounceContribution);

    if (GOLDEN_DebugView == 1) return float4(saturate(localIndirect), 1.0);
    if (GOLDEN_DebugView == 2) return float4(GOLDEN_DebugShape3(abs(bounceContribution)), 1.0);
    if (GOLDEN_DebugView == 3) return float4(GOLDEN_TiledFieldView(uv, GOLDEN_SamplingLensMode, GOLDEN_TapBudget), 1.0);
    if (GOLDEN_DebugView == 4) return float4(GOLDEN_CenterFieldFootprintOverlay(uv, sourceColor, GOLDEN_SamplingLensMode, GOLDEN_TapBudget, GOLDEN_GatherRadiusPixels, true), 1.0);
    if (GOLDEN_DebugView == 5) return float4(GOLDEN_DebugScalar(samplingField).xxx, 1.0);
    if (GOLDEN_DebugView == 6) return float4(GOLDEN_TiledFieldView(uv, GOLDEN_ApplicationLensMode, GOLDEN_ApplicationTapBudget), 1.0);
    if (GOLDEN_DebugView == 7) return float4(GOLDEN_CenterFieldFootprintOverlay(uv, sourceColor, GOLDEN_ApplicationLensMode, GOLDEN_ApplicationTapBudget, GOLDEN_ApplicationRadiusPixels, false), 1.0);
    if (GOLDEN_DebugView == 8) return float4(GOLDEN_DebugScalar(applicationField).xxx, 1.0);
    if (GOLDEN_DebugView == 9) return float4(GOLDEN_DebugScalar(depthAccept).xxx, 1.0);
    if (GOLDEN_DebugView == 10) return float4(GOLDEN_DebugScalar(selectedMask).xxx, 1.0);
    if (GOLDEN_DebugView == 11) return float4(GOLDEN_DebugScalar(fogEvidence).xxx, 1.0);
    if (GOLDEN_DebugView == 12) return float4(GOLDEN_DebugScalar(effectiveMask).xxx, 1.0);
    if (GOLDEN_DebugView == 13) return float4(GOLDEN_DebugScalar(breakupField).xxx, 1.0);
    return float4(finalColor, 1.0);
}

#endif
