#ifndef AMBIENT_OCCLUSION_FXH
#define AMBIENT_OCCLUSION_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"
#include "shared_fibonacci.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define AO_LENS_OFF 0
#define AO_LENS_ORGANIC55 1
#define AO_LENS_GOLDEN_SWEEP 2
#define AO_LENS_STAGGERED55 3
#define AO_LENS_RING9 4
#define AO_LENS_SPIRAL13 5
#define AO_LENS_RECT_H15 6
#define AO_LENS_RECT_V15 7
#define AO_LENS_DIAMOND13 8
#define AO_LENS_BOX25 9

#define AO_MASK_OFF 0
#define AO_MASK_FOG 1
#define AO_MASK_LIGHT 2
#define AO_MASK_DEPTH 3
#define AO_MASK_FAR_DETAIL 4
#define AO_MASK_CONTRAST 5
#define AO_MASK_COMPOSITE 6

#define AO_EPS 0.00001

float3 AO_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
}

float AO_Luma(float3 c)
{
    return SHARED_Luma(c);
}

float AO_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), AO_DepthMode, AO_DepthInvert);
}

float AO_DepthConfidence(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), AO_DepthMode, AO_DepthInvert, AO_DepthTraceScale, AO_DepthAvailabilityThreshold);
}

float AO_DepthEdge(float2 uv)
{
    return SHARED_DepthEdgeMask(saturate(uv), AO_DepthMode, AO_DepthInvert, AO_DepthTraceScale, AO_DepthAvailabilityThreshold, AO_DepthEdgeThreshold);
}

float AO_DebugScalar(float v)
{
    return AO_DebugShape(v);
}

float AO_PlotMarker(float2 p, float2 center, float radius)
{
    return 1.0 - smoothstep(radius, radius * 1.9, length(p - center));
}

float2 AO_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, AO_DebugPatternTiles);
    return frac(uv * tiles) - 0.5;
}

float AO_DebugTapMarker(float2 localUV, float2 tapOffset)
{
    float2 plotted = tapOffset * AO_DebugPatternScale;
    float dist = length(localUV - plotted);
    float outer = AO_DebugMarkerSize + AO_DebugPatternSoftness;
    return 1.0 - smoothstep(AO_DebugMarkerSize, outer, dist);
}

float AO_DebugGuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - AO_DebugPatternScale);
    return 1.0 - smoothstep(0.0, AO_DebugPatternSoftness * 1.25, dist);
}

int AO_QualityTapCap()
{
    if (AO_QualityTier == 0) return 9;
    if (AO_QualityTier == 1) return 21;
    if (AO_QualityTier == 2) return 34;
    return 55;
}

float2 AO_RotateField(float2 p)
{
    return SHARED_Rotate(p, AO_FieldRotation);
}

int AO_CanonicalTapCount(int lensMode)
{
    if (lensMode == AO_LENS_RING9) return 9;
    if (lensMode == AO_LENS_SPIRAL13) return 13;
    if (lensMode == AO_LENS_RECT_H15 || lensMode == AO_LENS_RECT_V15) return 15;
    if (lensMode == AO_LENS_DIAMOND13) return 13;
    if (lensMode == AO_LENS_BOX25) return 25;
    return SHARED_LENS55_TAP_COUNT;
}

int AO_ActiveTapCountForBudget(int lensMode, int requestedBudget)
{
    int requested = min(requestedBudget, AO_QualityTapCap());
    return clamp(requested, 1, AO_CanonicalTapCount(lensMode));
}

int AO_CanonicalIndex(int lensMode, int logicalIndex, int requestedBudget)
{
    return SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        AO_ActiveTapCountForBudget(lensMode, requestedBudget),
        AO_CanonicalTapCount(lensMode),
        AO_ReductionMode,
        0,
        AO_CanonicalTapCount(lensMode));
}

float2 AO_LensOffset(int lensMode, int logicalIndex, int requestedBudget)
{
    if (lensMode == AO_LENS_OFF)
        return 0.0.xx;

    int canonicalIndex = AO_CanonicalIndex(lensMode, logicalIndex, requestedBudget);
    canonicalIndex = clamp(canonicalIndex, 0, AO_CanonicalTapCount(lensMode) - 1);

    if (lensMode == AO_LENS_RING9)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(canonicalIndex - 1)) / 8.0;
        return AO_RotateField(float2(cos(angle), sin(angle)) * AO_FieldScale);
    }

    if (lensMode == AO_LENS_SPIRAL13)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float sampleIndex = float(canonicalIndex - 1);
        float radial = sqrt((sampleIndex + 1.0) / 12.0);
        float2 dir = SHARED_GoldenDirection(sampleIndex + 0.5 + AO_FibonacciAnchor);
        return AO_RotateField(dir * radial * AO_FieldScale);
    }

    if (lensMode == AO_LENS_RECT_H15)
    {
        return AO_RotateField(float2((float(canonicalIndex) - 7.0) / 7.0, 0.0) * AO_FieldScale);
    }

    if (lensMode == AO_LENS_RECT_V15)
    {
        return AO_RotateField(float2(0.0, (float(canonicalIndex) - 7.0) / 7.0) * AO_FieldScale);
    }

    if (lensMode == AO_LENS_DIAMOND13)
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
        return AO_RotateField(offset * AO_FieldScale);
    }

    if (lensMode == AO_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        float2 offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
        return AO_RotateField(offset * AO_FieldScale);
    }

    if (lensMode == AO_LENS_GOLDEN_SWEEP)
    {
        float2 dir = SHARED_GoldenDirection(float(canonicalIndex) + AO_FibonacciAnchor);
        float growth = SHARED_Lens55FibonacciGrowth(canonicalIndex, AO_ActiveTapCountForBudget(lensMode, requestedBudget));
        return AO_RotateField(dir * growth * 0.95 * AO_FieldScale);
    }

    return AO_RotateField(SHARED_Lens55Offset(canonicalIndex) * AO_FieldScale);
}

float AO_LensField(float2 uv, int lensMode, int requestedBudget, float radiusPixels)
{
    if (lensMode == AO_LENS_OFF)
        return 1.0;

    int tapCount = min(AO_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float2 px = SHARED_PixelSize() * radiusPixels;
    float centerDepth = AO_Depth(uv);
    float centerLuma = AO_Luma(AO_Source(uv));
    float confidence = AO_DepthConfidence(uv);
    float sum = 0.0;
    float weightSum = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 sampleUv = saturate(uv + AO_LensOffset(lensMode, i, requestedBudget) * px);
        float3 sampleColor = AO_Source(sampleUv);
        float sampleDepth = AO_Depth(sampleUv);
        float sampleLuma = AO_Luma(sampleColor);
        float depthWeight = 1.0 - smoothstep(0.0, max(0.0001, AO_BroadRejectEnd), abs(sampleDepth - centerDepth) * max(1.0, AO_DepthTraceScale));
        depthWeight = saturate(lerp(1.0, depthWeight, confidence));
        float contrast = abs(sampleLuma - centerLuma);
        sum += contrast * depthWeight;
        weightSum += depthWeight;
    }

    float field = (weightSum > AO_EPS) ? (sum / weightSum) : 0.0;
    return saturate(field * 10.0);
}

float3 AO_TiledFieldView(float2 uv, int lensMode, int requestedBudget)
{
    if (lensMode == AO_LENS_OFF)
        return 0.0.xxx;

    float2 localUV = AO_LocalPreviewUV(uv);
    int tapCount = min(AO_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float marker = AO_DebugTapMarker(localUV, 0.0.xx);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        marker = max(marker, AO_DebugTapMarker(localUV, AO_LensOffset(lensMode, i, requestedBudget)));
    }

    marker = saturate(marker + AO_DebugGuideRing(localUV) * 0.35);
    return AO_DebugShape3(lerp(float3(0.05, 0.07, 0.10), float3(0.92, 0.97, 1.0), marker));
}

float3 AO_CenterFieldFootprintOverlay(float2 uv, float3 source, int lensMode, int requestedBudget, float radiusPixels, bool applyGrowth)
{
    if (lensMode == AO_LENS_OFF)
        return source;

    float2 px = SHARED_PixelSize() * radiusPixels;
    int tapCount = min(AO_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float marker = AO_PlotMarker(uv, 0.5.xx, AO_DebugMarkerSize * 0.5);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float growth = applyGrowth ? SHARED_Lens55FibonacciGrowth(i, tapCount) : 1.0;
        float2 sampleUv = saturate(0.5.xx + AO_LensOffset(lensMode, i, requestedBudget) * px * growth);
        marker = max(marker, AO_PlotMarker(uv, sampleUv, AO_DebugMarkerSize * 0.5));
    }

    float3 overlayColor = lerp(source, float3(0.98, 0.96, 0.82), saturate(marker));
    return AO_DebugShape3(overlayColor);
}

float AO_FogEvidence(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = AO_DepthConfidence(uv);
    float depth = AO_Depth(uv);
    float depthBias = smoothstep(max(AO_DepthStart, 0.08), max(AO_FarDetailStart, 0.35), depth);
    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(AO_FogBrightnessFloor, AO_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(AO_FogDesaturation, min(1.0, AO_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(AO_FogLowContrast, max(AO_FogLowContrast + 0.01, AO_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(AO_ContrastThreshold, AO_ContrastThreshold * 6.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(AO_LightThreshold, AO_LightThreshold + AO_LightSoftness, luma);
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float AO_LightShield(float3 source)
{
    float luma = SHARED_Luma(source);
    float maxv = max(source.r, max(source.g, source.b));
    float minv = min(source.r, min(source.g, source.b));
    float sat = (maxv <= AO_EPS) ? 0.0 : ((maxv - minv) / maxv);
    float satMask = smoothstep(0.22, 1.0, sat);
    float lumaMask = smoothstep(AO_LightThreshold, AO_LightThreshold + AO_LightSoftness, luma);
    float peakMask = smoothstep(AO_LightThreshold, AO_LightThreshold + AO_LightSoftness, maxv);
    return saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
}

float AO_DepthWindow(float2 uv)
{
    float availability = AO_DepthConfidence(uv);
    float depth = AO_Depth(uv);
    float d0 = min(AO_DepthStart, AO_DepthEnd);
    float d1 = max(AO_DepthStart, AO_DepthEnd);
    float soft = 0.01;
    float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
    float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
    return saturate(beginMask * endMask * availability);
}

float AO_ContrastMask(float2 uv, float3 source)
{
    float contrast = SHARED_LocalContrast(uv, source);
    return smoothstep(
        AO_ContrastThreshold,
        AO_ContrastThreshold * max(1.25, AO_ContrastGain),
        contrast * AO_ContrastGain);
}

float AO_FarDetailStack(float2 uv, float3 source)
{
    float depthValid = AO_DepthConfidence(uv);
    float depth = AO_Depth(uv);
    float farMask = smoothstep(AO_FarDetailStart, AO_FarDetailEnd, depth);
    float edgeMask = AO_DepthEdge(uv);
    float edgeSuppress = 1.0 - saturate(edgeMask);
    float detailMask = AO_ContrastMask(uv, source);
    return saturate(depthValid * farMask * edgeSuppress * detailMask);
}

float AO_SelectedMask(float2 uv, float3 sourceColor)
{
    float selected = 1.0;

    if (AO_MaskMode == AO_MASK_FOG)
        selected = 1.0 - AO_FogEvidence(uv, sourceColor);
    else if (AO_MaskMode == AO_MASK_LIGHT)
        selected = 1.0 - AO_LightShield(sourceColor);
    else if (AO_MaskMode == AO_MASK_DEPTH)
        selected = AO_DepthWindow(uv);
    else if (AO_MaskMode == AO_MASK_FAR_DETAIL)
        selected = AO_FarDetailStack(uv, sourceColor);
    else if (AO_MaskMode == AO_MASK_CONTRAST)
        selected = AO_ContrastMask(uv, sourceColor);
    else if (AO_MaskMode == AO_MASK_COMPOSITE)
    {
        float allow = max(AO_DepthWindow(uv), max(AO_FarDetailStack(uv, sourceColor), AO_ContrastMask(uv, sourceColor)));
        float protect = max(AO_FogEvidence(uv, sourceColor), AO_LightShield(sourceColor));
        selected = saturate(allow * (1.0 - protect * 0.85));
    }

    return saturate(selected * AO_MaskStrength);
}

float AO_FinalGate(float selectedMask, float applicationField, float depthConfidence)
{
    return
        saturate(lerp(1.0, selectedMask, AO_MaskInfluence)) *
        saturate(lerp(1.0, applicationField, AO_ApplicationLensStrength)) *
        saturate(0.35 + 0.65 * depthConfidence);
}

int AO_RepresentativeSamplingTapBudget()
{
    int requested = 0;
    if (AO_EnableBase != 0) requested = max(requested, AO_BaseTapBudget);
    if (AO_EnableBroad != 0) requested = max(requested, AO_BroadTapBudget);
    if (AO_EnableSuperfine != 0) requested = max(requested, AO_SuperfineTapBudget);
    if (requested <= 0) requested = AO_BaseTapBudget;
    return requested;
}

float AO_RepresentativeSamplingRadius()
{
    float radius = 0.0;
    if (AO_EnableBase != 0) radius = max(radius, AO_BaseRadiusPixels);
    if (AO_EnableBroad != 0) radius = max(radius, AO_BroadRadiusPixels);
    if (AO_EnableSuperfine != 0) radius = max(radius, AO_SuperfineRadiusPixels);
    if (radius <= 0.0) radius = AO_BaseRadiusPixels;
    return radius;
}

float AO_PassOcclusion(float2 uv, int tapBudget, float radiusPixels, float rejectStart, float rejectEnd, float passStrength, float distanceFalloff, float contrastLow, float contrastGain)
{
    if (AO_SamplingLensMode == AO_LENS_OFF)
        return 0.0;

    int tapCount = AO_ActiveTapCountForBudget(AO_SamplingLensMode, tapBudget);
    float2 px = SHARED_PixelSize() * radiusPixels;
    float centerDepth = AO_Depth(uv);
    float confidence = AO_DepthConfidence(uv);
    float localContrast = SHARED_LocalContrast(uv, AO_Source(uv));
    float contrastMask = smoothstep(contrastLow, contrastLow * max(1.25, contrastGain), localContrast * contrastGain);
    float occlusionSum = 0.0;
    float weightSum = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;

        float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
        float2 offset = AO_LensOffset(AO_SamplingLensMode, i, tapBudget);
        float2 sampleUv = saturate(uv + offset * px * growth);
        float sampleDepth = AO_Depth(sampleUv);

        float forwardDelta = max(0.0, centerDepth - sampleDepth) * max(1.0, AO_DepthTraceScale);
        float occluder = smoothstep(rejectStart, rejectEnd, forwardDelta);
        float continuity = 1.0 - smoothstep(rejectEnd, rejectEnd * 4.0, abs(centerDepth - sampleDepth) * max(1.0, AO_DepthTraceScale));
        float distanceWeight = SHARED_SafeRcp(1.0 + length(offset) * distanceFalloff);
        float weight = saturate(occluder * continuity * distanceWeight);

        occlusionSum += weight;
        weightSum += distanceWeight;
    }

    float occlusion = (weightSum > AO_EPS) ? (occlusionSum / weightSum) : 0.0;
    occlusion *= lerp(0.55, 1.0, confidence);
    occlusion *= lerp(0.65, 1.0, contrastMask);
    return saturate(occlusion * passStrength);
}

float4 AO_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = AO_Source(uv);
    if (AO_Enable == 0)
        return float4(sourceColor, 1.0);

    float baseOcclusion = (AO_EnableBase != 0) ? AO_PassOcclusion(uv, AO_BaseTapBudget, AO_BaseRadiusPixels, AO_BaseRejectStart, AO_BaseRejectEnd, AO_BaseStrength, 0.65, 0.008, 1.6) : 0.0;
    float broadOcclusion = (AO_EnableBroad != 0) ? AO_PassOcclusion(uv, AO_BroadTapBudget, AO_BroadRadiusPixels, AO_BroadRejectStart, AO_BroadRejectEnd, AO_BroadStrength, AO_BroadDistanceFalloff, 0.012, 1.4) : 0.0;
    float superfineOcclusion = (AO_EnableSuperfine != 0) ? AO_PassOcclusion(uv, AO_SuperfineTapBudget, AO_SuperfineRadiusPixels, AO_SuperfineRejectStart, AO_SuperfineRejectEnd, AO_SuperfineStrength, 0.35, AO_SuperfineContrastThreshold, AO_SuperfineContrastGain) : 0.0;

    float combinedOcclusion = saturate(baseOcclusion + broadOcclusion * 0.85 + superfineOcclusion * 0.70);
    float selectedMask = AO_SelectedMask(uv, sourceColor);
    float fogEvidence = AO_FogEvidence(uv, sourceColor);
    float applicationField = AO_LensField(uv, AO_ApplicationLensMode, AO_ApplicationTapBudget, AO_ApplicationRadiusPixels);
    float samplingField = AO_LensField(uv, AO_SamplingLensMode, AO_BaseTapBudget, AO_BaseRadiusPixels * 0.55 + AO_BroadRadiusPixels * 0.20);
    float confidence = AO_DepthConfidence(uv);
    float finalGate = AO_FinalGate(selectedMask, applicationField, confidence);

    float finalOcclusion = saturate(combinedOcclusion * finalGate * AO_MasterIntensity);
    float3 finalColor = saturate(sourceColor * (1.0 - finalOcclusion));

    if (AO_DebugView == 1) return float4(AO_DebugScalar(baseOcclusion).xxx, 1.0);
    if (AO_DebugView == 2) return float4(AO_DebugScalar(broadOcclusion).xxx, 1.0);
    if (AO_DebugView == 3) return float4(AO_DebugScalar(superfineOcclusion).xxx, 1.0);
    if (AO_DebugView == 4) return float4(AO_DebugScalar(combinedOcclusion).xxx, 1.0);
    if (AO_DebugView == 5) return float4(AO_TiledFieldView(uv, AO_SamplingLensMode, AO_RepresentativeSamplingTapBudget()), 1.0);
    if (AO_DebugView == 6) return float4(AO_CenterFieldFootprintOverlay(uv, sourceColor, AO_SamplingLensMode, AO_RepresentativeSamplingTapBudget(), AO_RepresentativeSamplingRadius(), true), 1.0);
    if (AO_DebugView == 7) return float4(AO_DebugScalar(samplingField).xxx, 1.0);
    if (AO_DebugView == 8) return float4(AO_TiledFieldView(uv, AO_ApplicationLensMode, AO_ApplicationTapBudget), 1.0);
    if (AO_DebugView == 9) return float4(AO_CenterFieldFootprintOverlay(uv, sourceColor, AO_ApplicationLensMode, AO_ApplicationTapBudget, AO_ApplicationRadiusPixels, false), 1.0);
    if (AO_DebugView == 10) return float4(AO_DebugScalar(applicationField).xxx, 1.0);
    if (AO_DebugView == 11) return float4(AO_DebugScalar(selectedMask).xxx, 1.0);
    if (AO_DebugView == 12) return float4(AO_DebugScalar(fogEvidence).xxx, 1.0);
    if (AO_DebugView == 13) return float4(AO_DebugScalar(finalGate).xxx, 1.0);
    return float4(finalColor, 1.0);
}

#endif
