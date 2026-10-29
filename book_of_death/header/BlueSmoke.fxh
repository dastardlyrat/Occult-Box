#ifndef DEEP_TONE_FXH
#define DEEP_TONE_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"
#include "shared_fibonacci.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define DEEP_LENS_OFF 0
#define DEEP_LENS_ORGANIC55 1
#define DEEP_LENS_GOLDEN_SWEEP 2
#define DEEP_LENS_STAGGERED55 3
#define DEEP_LENS_RING9 4
#define DEEP_LENS_SPIRAL13 5
#define DEEP_LENS_RECT_H15 6
#define DEEP_LENS_RECT_V15 7
#define DEEP_LENS_DIAMOND13 8
#define DEEP_LENS_BOX25 9

#define DEEP_MASK_OFF 0
#define DEEP_MASK_FOG 1
#define DEEP_MASK_LIGHT 2
#define DEEP_MASK_DEPTH 3
#define DEEP_MASK_FAR_DETAIL 4
#define DEEP_MASK_CONTRAST 5
#define DEEP_MASK_COMPOSITE 6

#define DEEP_EPS 0.00001

float3 DEEP_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
}

float DEEP_Luma(float3 color)
{
    return SHARED_Luma(color);
}

float DEEP_Saturation(float3 color)
{
    return SHARED_Saturation(color);
}

float2 DEEP_Pixel()
{
    return SHARED_PixelSize();
}

float DEEP_DebugScalar(float v)
{
    return DEEP_DebugShape(v);
}

float DEEP_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), DEEP_DepthMode, DEEP_DepthInvert);
}

float DEEP_DepthConfidence(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), DEEP_DepthMode, DEEP_DepthInvert, DEEP_DepthTraceScale, DEEP_DepthAvailabilityThreshold);
}

float2 DEEP_RotateField(float2 p)
{
    return SHARED_Rotate(p, DEEP_FieldRotation);
}

int DEEP_QualityTapCap()
{
    if (DEEP_QualityTier == 0) return 9;
    if (DEEP_QualityTier == 1) return 21;
    if (DEEP_QualityTier == 2) return 34;
    return 55;
}

int DEEP_CanonicalTapCount()
{
    if (DEEP_LensMode == DEEP_LENS_RING9) return 9;
    if (DEEP_LensMode == DEEP_LENS_SPIRAL13) return 13;
    if (DEEP_LensMode == DEEP_LENS_RECT_H15 || DEEP_LensMode == DEEP_LENS_RECT_V15) return 15;
    if (DEEP_LensMode == DEEP_LENS_DIAMOND13) return 13;
    if (DEEP_LensMode == DEEP_LENS_BOX25) return 25;
    return SHARED_LENS55_TAP_COUNT;
}

int DEEP_ActiveTapCount()
{
    int requested = min(DEEP_TapBudget, DEEP_QualityTapCap());
    return clamp(requested, 1, DEEP_CanonicalTapCount());
}

int DEEP_CanonicalIndex(int logicalIndex)
{
    return SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        DEEP_ActiveTapCount(),
        DEEP_CanonicalTapCount(),
        DEEP_ReductionMode,
        0,
        DEEP_CanonicalTapCount());
}

float2 DEEP_FibonacciDirection(float fibIndex)
{
    return SHARED_GoldenDirection(fibIndex);
}

float2 DEEP_OrganicDirection(float2 lensOffset, float fibIndex, float2 uv, float tapNorm)
{
    float2 fibDir = DEEP_FibonacciDirection(fibIndex);
    float2 lensDir = normalize(float2(0.23 - lensOffset.y, 0.17 + lensOffset.x + frac(fibIndex * 0.000618)));
    float2 baseDir = normalize(lerp(lensDir, fibDir, 0.45 + 0.24 * tapNorm));
    float phase = fibIndex * 0.013 + DEEP_OrganicFlow * 0.18 + dot(uv * 72.0, float2(0.754, 0.569));
    return normalize(SHARED_Rotate(baseDir, degrees(phase)));
}

float2 DEEP_LensOffset(int logicalIndex)
{
    if (DEEP_LensMode == DEEP_LENS_OFF)
        return 0.0.xx;

    int canonicalIndex = DEEP_CanonicalIndex(logicalIndex);
    canonicalIndex = clamp(canonicalIndex, 0, DEEP_CanonicalTapCount() - 1);

    if (DEEP_LensMode == DEEP_LENS_RING9)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(canonicalIndex - 1)) / 8.0;
        return DEEP_RotateField(float2(cos(angle), sin(angle)) * DEEP_FieldScale);
    }

    if (DEEP_LensMode == DEEP_LENS_SPIRAL13)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float sampleIndex = float(canonicalIndex - 1);
        float radial = sqrt((sampleIndex + 1.0) / 12.0);
        float2 dir = SHARED_GoldenDirection(sampleIndex + 0.5 + DEEP_FibonacciAnchor);
        return DEEP_RotateField(dir * radial * DEEP_FieldScale);
    }

    if (DEEP_LensMode == DEEP_LENS_RECT_H15)
    {
        return DEEP_RotateField(float2((float(canonicalIndex) - 7.0) / 7.0, 0.0) * DEEP_FieldScale);
    }

    if (DEEP_LensMode == DEEP_LENS_RECT_V15)
    {
        return DEEP_RotateField(float2(0.0, (float(canonicalIndex) - 7.0) / 7.0) * DEEP_FieldScale);
    }

    if (DEEP_LensMode == DEEP_LENS_DIAMOND13)
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
        return DEEP_RotateField(offset * DEEP_FieldScale);
    }

    if (DEEP_LensMode == DEEP_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        float2 offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
        return DEEP_RotateField(offset * DEEP_FieldScale);
    }

    if (DEEP_LensMode == DEEP_LENS_GOLDEN_SWEEP)
    {
        float2 dir = SHARED_GoldenDirection(float(canonicalIndex) + DEEP_FibonacciAnchor);
        float growth = SHARED_Lens55FibonacciGrowth(canonicalIndex, DEEP_ActiveTapCount());
        return DEEP_RotateField(dir * growth * 0.95 * DEEP_FieldScale);
    }

    return DEEP_RotateField(SHARED_Lens55Offset(canonicalIndex) * DEEP_FieldScale);
}

void DEEP_AccumulateSupportTap(
    float2 uv,
    float centerDepth,
    int index,
    int tapCount,
    inout float lumaSum,
    inout float weightSum,
    inout float chromaSum)
{
    if (index >= tapCount)
        return;

    float2 offset = DEEP_LensOffset(index);
    float tapNorm = (float(index) + 0.5) / max(1.0, float(tapCount));
    float fibIndex = DEEP_FibonacciAnchor + float(index);
    float2 dir = DEEP_OrganicDirection(offset, fibIndex, uv, tapNorm);
    float growth = SHARED_Lens55FibonacciGrowth(index, tapCount);
    float2 sampleUv = uv + dir * DEEP_Pixel() * DEEP_RadiusPixels * growth;
    float3 sampleColor = DEEP_Source(sampleUv);
    float sampleDepth = DEEP_Depth(sampleUv);
    float depthWeight = exp(-abs(sampleDepth - centerDepth) * 48.0);
    lumaSum += DEEP_Luma(sampleColor) * depthWeight;
    chromaSum += DEEP_Saturation(sampleColor) * depthWeight;
    weightSum += depthWeight;
}

float DEEP_DepthStabilityGate(float2 uv, float centerDepth)
{
    float2 px = DEEP_Pixel();
    float dR = DEEP_Depth(uv + float2(px.x, 0.0));
    float dL = DEEP_Depth(uv - float2(px.x, 0.0));
    float dU = DEEP_Depth(uv + float2(0.0, px.y));
    float dD = DEEP_Depth(uv - float2(0.0, px.y));
    float slope = abs(dR - dL) + abs(dU - dD);
    float fit = abs(dR - centerDepth) + abs(dL - centerDepth) + abs(dU - centerDepth) + abs(dD - centerDepth);
    float continuity = 1.0 - saturate((slope + fit * 0.25) * 32.0);
    return saturate(lerp(1.0, continuity, DEEP_DepthGate));
}

float DEEP_ToneRegionMask(float sourceLuma)
{
    return 1.0 - saturate(abs(sourceLuma - DEEP_TonePivot) / max(DEEP_EPS, DEEP_ToneWidth));
}

float3 DEEP_ApplyShapedLuma(float3 sourceColor, float sourceLuma, float shadedLuma)
{
    float3 chromaPreserved = saturate(sourceColor * (shadedLuma / max(DEEP_EPS, sourceLuma)));
    float3 lumaOnly = shadedLuma.xxx;
    return lerp(lumaOnly, chromaPreserved, 0.92);
}

float DEEP_FogEvidence(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = DEEP_DepthConfidence(uv);
    float depth = DEEP_Depth(uv);
    float depthBias = smoothstep(max(DEEP_DepthStart, 0.08), max(DEEP_FarDetailStart, 0.35), depth);
    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(DEEP_FogBrightnessFloor, DEEP_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(DEEP_FogDesaturation, min(1.0, DEEP_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(DEEP_FogLowContrast, max(DEEP_FogLowContrast + 0.01, DEEP_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(DEEP_LineThreshold, DEEP_LineThreshold * 4.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(DEEP_LightThreshold, DEEP_LightThreshold + DEEP_LightSoftness, luma);
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float DEEP_SelectedMask(float2 uv, float3 source)
{
    if (DEEP_MaskMode == DEEP_MASK_OFF)
        return 1.0;

    float fog = DEEP_FogEvidence(uv, source);

    float light = 0.0;
    {
        float luma = SHARED_Luma(source);
        float maxv = max(source.r, max(source.g, source.b));
        float minv = min(source.r, min(source.g, source.b));
        float sat = (maxv <= DEEP_EPS) ? 0.0 : ((maxv - minv) / maxv);
        float satMask = smoothstep(0.22, 1.0, sat);
        float lumaMask = smoothstep(DEEP_LightThreshold, DEEP_LightThreshold + DEEP_LightSoftness, luma);
        float peakMask = smoothstep(DEEP_LightThreshold, DEEP_LightThreshold + DEEP_LightSoftness, maxv);
        light = saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
    }

    float depthWindow = 0.0;
    {
        float availability = DEEP_DepthConfidence(uv);
        float depth = DEEP_Depth(uv);
        float d0 = min(DEEP_DepthStart, DEEP_DepthEnd);
        float d1 = max(DEEP_DepthStart, DEEP_DepthEnd);
        float soft = 0.01;
        float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
        float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
        depthWindow = saturate(beginMask * endMask * availability);
    }

    float farDetail = 0.0;
    {
        float depthValid = DEEP_DepthConfidence(uv);
        float depth = DEEP_Depth(uv);
        float farMask = smoothstep(DEEP_FarDetailStart, DEEP_FarDetailEnd, depth);
        float detail = SHARED_LocalContrast(uv, source) * max(1.0, DEEP_DetailScale);
        float detailMask = smoothstep(DEEP_DetailLow, DEEP_DetailHigh, detail);
        farDetail = saturate(depthValid * farMask * detailMask);
    }

    float contrastMask = 0.0;
    {
        float contrast = SHARED_LocalContrast(uv, source);
        contrastMask = smoothstep(
            DEEP_ContrastThreshold,
            DEEP_ContrastThreshold * max(1.25, DEEP_ContrastGain),
            contrast * DEEP_ContrastGain);
    }

    if (DEEP_MaskMode == DEEP_MASK_FOG) return fog;
    if (DEEP_MaskMode == DEEP_MASK_LIGHT) return light;
    if (DEEP_MaskMode == DEEP_MASK_DEPTH) return depthWindow;
    if (DEEP_MaskMode == DEEP_MASK_FAR_DETAIL) return farDetail;
    if (DEEP_MaskMode == DEEP_MASK_CONTRAST) return contrastMask;
    return saturate(max(max(fog, light), max(farDetail, contrastMask)) * depthWindow);
}

float2 DEEP_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, DEEP_DebugPatternTiles);
    return frac(uv * tiles) - 0.5;
}

float DEEP_DebugTapMarker(float2 localUV, float2 tapOffset)
{
    float2 plotted = tapOffset * DEEP_DebugPatternScale;
    float dist = length(localUV - plotted);
    float outer = DEEP_DebugMarkerSize + DEEP_DebugPatternSoftness;
    return 1.0 - smoothstep(DEEP_DebugMarkerSize, outer, dist);
}

float DEEP_DebugGuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - DEEP_DebugPatternScale);
    return 1.0 - smoothstep(0.0, DEEP_DebugPatternSoftness * 1.25, dist);
}

float3 DEEP_TiledOrganicField(float2 uv)
{
    float2 localUV = DEEP_LocalPreviewUV(uv);
    float marker = DEEP_DebugTapMarker(localUV, 0.0.xx);
    int tapCount = DEEP_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        marker = max(marker, DEEP_DebugTapMarker(localUV, DEEP_LensOffset(i)));
    }

    marker = saturate(marker + DEEP_DebugGuideRing(localUV) * 0.35);
    return DEEP_DebugShape3(lerp(float3(0.05, 0.07, 0.10), float3(0.92, 0.97, 1.0), marker));
}

float DEEP_PlotMarker(float2 p, float2 center, float radius)
{
    return 1.0 - smoothstep(radius, radius * 1.9, length(p - center));
}

float3 DEEP_CenterOrganicFootprint(float2 uv, float3 source)
{
    float2 px = DEEP_Pixel() * DEEP_RadiusPixels;
    float marker = DEEP_PlotMarker(uv, 0.5.xx, DEEP_DebugMarkerSize * 0.5);
    int tapCount = DEEP_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 sampleUv = saturate(0.5.xx + DEEP_LensOffset(i) * px);
        marker = max(marker, DEEP_PlotMarker(uv, sampleUv, DEEP_DebugMarkerSize * 0.5));
    }

    float3 overlayColor = lerp(source, float3(0.98, 0.96, 0.82), saturate(marker));
    return DEEP_DebugShape3(overlayColor);
}

float DEEP_OrganicFieldStrength()
{
    int tapCount = DEEP_ActiveTapCount();
    float sum = 0.0;
    float weight = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
        sum += 1.0 - saturate(growth);
        weight += 1.0;
    }

    return (weight > 0.0) ? saturate(sum / weight) : 0.0;
}

float4 DEEP_MainPS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = DEEP_Source(uv);
    if (DEEP_Enable == 0)
        return float4(sourceColor, 1.0);

    int tapCount = DEEP_ActiveTapCount();
    float sourceLuma = DEEP_Luma(sourceColor);
    float sourceSaturation = DEEP_Saturation(sourceColor);
    float centerDepth = DEEP_Depth(uv);
    float depthGate = DEEP_DepthStabilityGate(uv, centerDepth);

    float lumaSum = sourceLuma;
    float chromaSum = sourceSaturation;
    float weightSum = 1.0;

    [loop]
    for (int tapIndex = 0; tapIndex < SHARED_LENS55_TAP_COUNT; ++tapIndex)
    {
        if (tapIndex >= tapCount) break;
        DEEP_AccumulateSupportTap(uv, centerDepth, tapIndex, tapCount, lumaSum, weightSum, chromaSum);
    }

    float supportLuma = lumaSum / max(DEEP_EPS, weightSum);
    float supportSaturation = chromaSum / max(DEEP_EPS, weightSum);
    float localShade = sourceLuma - supportLuma;
    float toneMask = DEEP_ToneRegionMask(sourceLuma);
    float shadowTerm = min(localShade, 0.0) * (1.0 - DEEP_ShadowLift);
    float highlightTerm = -max(localShade, 0.0) * DEEP_HighlightCompression;
    float shapedShade = (shadowTerm + highlightTerm) * toneMask * DEEP_LocalContrast;

    float selectedMask = DEEP_SelectedMask(uv, sourceColor);
    float fogEvidence = DEEP_FogEvidence(uv, sourceColor);
    float finalGate = saturate(depthGate * lerp(1.0, selectedMask, DEEP_MaskInfluence) * (1.0 - fogEvidence * DEEP_FogInfluence));
    float computedWeight = saturate(abs(shapedShade) * DEEP_RichnessStrength * DEEP_MasterIntensity * finalGate);
    float shadedLuma = saturate(sourceLuma + shapedShade * DEEP_RichnessStrength * DEEP_MasterIntensity * finalGate);
    float3 effectColor = DEEP_ApplyShapedLuma(sourceColor, sourceLuma, shadedLuma);

    float vibranceGate = 1.0 - saturate(sourceSaturation / 1.75);
    float colorfulness = DEEP_ColorfulnessStrength * DEEP_MasterIntensity * finalGate * toneMask * lerp(1.0, vibranceGate, 0.65);
    float3 centered = effectColor - DEEP_Luma(effectColor).xxx;
    effectColor = saturate(DEEP_Luma(effectColor).xxx + centered * (1.0 + colorfulness * max(0.25, supportSaturation + 0.25)));

    float3 outColor = effectColor;
    if (DEEP_DebugView == 1) outColor = DEEP_DebugShape3((saturate(shapedShade * 4.0 + 0.5)).xxx);
    else if (DEEP_DebugView == 2) outColor = DEEP_DebugShape3((supportLuma).xxx);
    else if (DEEP_DebugView == 3) outColor = DEEP_DebugShape3((toneMask).xxx);
    else if (DEEP_DebugView == 4) outColor = DEEP_DebugShape3((depthGate).xxx);
    else if (DEEP_DebugView == 5) outColor = DEEP_DebugShape3((sourceSaturation).xxx);
    else if (DEEP_DebugView == 6) outColor = DEEP_DebugShape3((computedWeight).xxx);
    else if (DEEP_DebugView == 7) outColor = DEEP_TiledOrganicField(uv);
    else if (DEEP_DebugView == 8) outColor = DEEP_CenterOrganicFootprint(uv, sourceColor);
    else if (DEEP_DebugView == 9) outColor = DEEP_DebugShape3((DEEP_OrganicFieldStrength()).xxx);
    else if (DEEP_DebugView == 10) outColor = DEEP_DebugShape3((selectedMask).xxx);
    else if (DEEP_DebugView == 11) outColor = DEEP_DebugShape3((fogEvidence).xxx);
    else if (DEEP_DebugView == 12) outColor = DEEP_DebugShape3((finalGate).xxx);

    return float4(saturate(outColor), 1.0);
}

#endif
