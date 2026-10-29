#ifndef SCREEN_SPACE_REFLECTION_FXH
#define SCREEN_SPACE_REFLECTION_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"
#include "shared_fibonacci.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define SSR_LENS_OFF 0
#define SSR_LENS_ORGANIC55 1
#define SSR_LENS_GOLDEN_SWEEP 2
#define SSR_LENS_STAGGERED55 3
#define SSR_LENS_RING9 4
#define SSR_LENS_SPIRAL13 5
#define SSR_LENS_RECT_H15 6
#define SSR_LENS_RECT_V15 7
#define SSR_LENS_DIAMOND13 8
#define SSR_LENS_BOX25 9

#define SSR_MASK_OFF 0
#define SSR_MASK_FOG 1
#define SSR_MASK_LIGHT 2
#define SSR_MASK_DEPTH 3
#define SSR_MASK_FAR_DETAIL 4
#define SSR_MASK_CONTRAST 5
#define SSR_MASK_COMPOSITE 6

#define SSR_EPS 0.00001

float3 SSR_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
}

float SSR_Luma(float3 c)
{
    return SHARED_Luma(c);
}

float SSR_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), SSR_DepthMode, SSR_DepthInvert);
}

float SSR_DepthConfidence(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), SSR_DepthMode, SSR_DepthInvert, SSR_DepthTraceScale, SSR_DepthAvailabilityThreshold);
}

float SSR_DepthEdge(float2 uv)
{
    return SHARED_DepthEdgeMask(saturate(uv), SSR_DepthMode, SSR_DepthInvert, SSR_DepthTraceScale, SSR_DepthAvailabilityThreshold, SSR_DepthEdgeThreshold);
}

float SSR_DebugScalar(float v)
{
    return SSR_DebugShape(v);
}

float SSR_PlotMarker(float2 p, float2 center, float radius)
{
    return 1.0 - smoothstep(radius, radius * 1.9, length(p - center));
}

float2 SSR_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, SSR_DebugPatternTiles);
    return frac(uv * tiles) - 0.5;
}

float SSR_DebugTapMarker(float2 localUV, float2 tapOffset)
{
    float2 plotted = tapOffset * SSR_DebugPatternScale;
    float dist = length(localUV - plotted);
    float outer = SSR_DebugMarkerSize + SSR_DebugPatternSoftness;
    return 1.0 - smoothstep(SSR_DebugMarkerSize, outer, dist);
}

float SSR_DebugGuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - SSR_DebugPatternScale);
    return 1.0 - smoothstep(0.0, SSR_DebugPatternSoftness * 1.25, dist);
}

int SSR_QualityTapCap()
{
    if (SSR_QualityTier == 0) return 9;
    if (SSR_QualityTier == 1) return 21;
    if (SSR_QualityTier == 2) return 34;
    return 55;
}

float2 SSR_RotateField(float2 p)
{
    return SHARED_Rotate(p, SSR_FieldRotation);
}

int SSR_CanonicalTapCount(int lensMode)
{
    if (lensMode == SSR_LENS_RING9) return 9;
    if (lensMode == SSR_LENS_SPIRAL13) return 13;
    if (lensMode == SSR_LENS_RECT_H15 || lensMode == SSR_LENS_RECT_V15) return 15;
    if (lensMode == SSR_LENS_DIAMOND13) return 13;
    if (lensMode == SSR_LENS_BOX25) return 25;
    return SHARED_LENS55_TAP_COUNT;
}

int SSR_ActiveTapCountForBudget(int lensMode, int requestedBudget)
{
    int requested = min(requestedBudget, SSR_QualityTapCap());
    return clamp(requested, 1, SSR_CanonicalTapCount(lensMode));
}

int SSR_CanonicalIndex(int lensMode, int logicalIndex, int requestedBudget)
{
    return SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        SSR_ActiveTapCountForBudget(lensMode, requestedBudget),
        SSR_CanonicalTapCount(lensMode),
        SSR_ReductionMode,
        0,
        SSR_CanonicalTapCount(lensMode));
}

float2 SSR_LensOffset(int lensMode, int logicalIndex, int requestedBudget)
{
    if (lensMode == SSR_LENS_OFF)
        return 0.0.xx;

    int canonicalIndex = SSR_CanonicalIndex(lensMode, logicalIndex, requestedBudget);
    canonicalIndex = clamp(canonicalIndex, 0, SSR_CanonicalTapCount(lensMode) - 1);

    if (lensMode == SSR_LENS_RING9)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(canonicalIndex - 1)) / 8.0;
        return SSR_RotateField(float2(cos(angle), sin(angle)) * SSR_FieldScale);
    }

    if (lensMode == SSR_LENS_SPIRAL13)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float sampleIndex = float(canonicalIndex - 1);
        float radial = sqrt((sampleIndex + 1.0) / 12.0);
        float2 dir = SHARED_GoldenDirection(sampleIndex + 0.5 + SSR_FibonacciAnchor);
        return SSR_RotateField(dir * radial * SSR_FieldScale);
    }

    if (lensMode == SSR_LENS_RECT_H15)
    {
        return SSR_RotateField(float2((float(canonicalIndex) - 7.0) / 7.0, 0.0) * SSR_FieldScale);
    }

    if (lensMode == SSR_LENS_RECT_V15)
    {
        return SSR_RotateField(float2(0.0, (float(canonicalIndex) - 7.0) / 7.0) * SSR_FieldScale);
    }

    if (lensMode == SSR_LENS_DIAMOND13)
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
        return SSR_RotateField(offset * SSR_FieldScale);
    }

    if (lensMode == SSR_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        float2 offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
        return SSR_RotateField(offset * SSR_FieldScale);
    }

    if (lensMode == SSR_LENS_GOLDEN_SWEEP)
    {
        float2 dir = SHARED_GoldenDirection(float(canonicalIndex) + SSR_FibonacciAnchor);
        float growth = SHARED_Lens55FibonacciGrowth(canonicalIndex, SSR_ActiveTapCountForBudget(lensMode, requestedBudget));
        return SSR_RotateField(dir * growth * 0.95 * SSR_FieldScale);
    }

    return SSR_RotateField(SHARED_Lens55Offset(canonicalIndex) * SSR_FieldScale);
}

float3 SSR_PseudoNormal(float2 uv)
{
    float2 px = SHARED_PixelSize();
    float dR = SSR_Depth(uv + float2(px.x, 0.0));
    float dL = SSR_Depth(uv - float2(px.x, 0.0));
    float dU = SSR_Depth(uv + float2(0.0, px.y));
    float dD = SSR_Depth(uv - float2(0.0, px.y));
    float zScale = max(px.x, px.y) * 64.0 + 0.05;
    return normalize(float3(dL - dR, dD - dU, zScale));
}

float2 SSR_ReflectionDirection(float2 uv)
{
    float3 normal = SSR_PseudoNormal(uv);
    float3 viewDir = float3(0.0, 0.0, -1.0);
    float3 reflected = reflect(viewDir, normal);
    float2 dir = reflected.xy;
    float len2 = dot(dir, dir);
    if (len2 <= SSR_EPS)
        dir = float2(0.0, -1.0);
    else
        dir *= rsqrt(len2);
    return dir;
}

float SSR_LensField(float2 uv, int lensMode, int requestedBudget, float radiusPixels)
{
    if (lensMode == SSR_LENS_OFF)
        return 1.0;

    int tapCount = min(SSR_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float2 px = SHARED_PixelSize() * radiusPixels;
    float centerDepth = SSR_Depth(uv);
    float centerLuma = SSR_Luma(SSR_Source(uv));
    float confidence = SSR_DepthConfidence(uv);
    float sum = 0.0;
    float weightSum = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 sampleUv = saturate(uv + SSR_LensOffset(lensMode, i, requestedBudget) * px);
        float3 sampleColor = SSR_Source(sampleUv);
        float sampleDepth = SSR_Depth(sampleUv);
        float sampleLuma = SSR_Luma(sampleColor);
        float depthWeight = 1.0 - smoothstep(0.0, max(0.0001, SSR_BaseDepthRejectEnd), abs(sampleDepth - centerDepth) * max(1.0, SSR_DepthTraceScale));
        depthWeight = saturate(lerp(1.0, depthWeight, confidence));
        float contrast = abs(sampleLuma - centerLuma);
        sum += contrast * depthWeight;
        weightSum += depthWeight;
    }

    float field = (weightSum > SSR_EPS) ? (sum / weightSum) : 0.0;
    return saturate(field * 10.0);
}

float3 SSR_TiledFieldView(float2 uv, int lensMode, int requestedBudget)
{
    if (lensMode == SSR_LENS_OFF)
        return 0.0.xxx;

    float2 localUV = SSR_LocalPreviewUV(uv);
    int tapCount = min(SSR_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float marker = SSR_DebugTapMarker(localUV, 0.0.xx);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        marker = max(marker, SSR_DebugTapMarker(localUV, SSR_LensOffset(lensMode, i, requestedBudget)));
    }

    marker = saturate(marker + SSR_DebugGuideRing(localUV) * 0.35);
    return SSR_DebugShape3(lerp(float3(0.05, 0.07, 0.10), float3(0.92, 0.97, 1.0), marker));
}

float3 SSR_CenterFieldFootprintOverlay(float2 uv, float3 source, int lensMode, int requestedBudget, float radiusPixels, bool applyGrowth)
{
    if (lensMode == SSR_LENS_OFF)
        return source;

    float2 px = SHARED_PixelSize() * radiusPixels;
    int tapCount = min(SSR_ActiveTapCountForBudget(lensMode, requestedBudget), 21);
    float marker = SSR_PlotMarker(uv, 0.5.xx, SSR_DebugMarkerSize * 0.5);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float growth = applyGrowth ? SHARED_Lens55FibonacciGrowth(i, tapCount) : 1.0;
        float2 sampleUv = saturate(0.5.xx + SSR_LensOffset(lensMode, i, requestedBudget) * px * growth);
        marker = max(marker, SSR_PlotMarker(uv, sampleUv, SSR_DebugMarkerSize * 0.5));
    }

    float3 overlayColor = lerp(source, float3(0.98, 0.96, 0.82), saturate(marker));
    return SSR_DebugShape3(overlayColor);
}

float SSR_FogEvidence(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = SSR_DepthConfidence(uv);
    float depth = SSR_Depth(uv);
    float depthBias = smoothstep(max(SSR_DepthStart, 0.08), max(SSR_FarDetailStart, 0.35), depth);
    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(SSR_FogBrightnessFloor, SSR_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(SSR_FogDesaturation, min(1.0, SSR_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(SSR_FogLowContrast, max(SSR_FogLowContrast + 0.01, SSR_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(SSR_ContrastThreshold, SSR_ContrastThreshold * 6.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(SSR_LightThreshold, SSR_LightThreshold + SSR_LightSoftness, luma);
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float SSR_LightShield(float3 source)
{
    float luma = SHARED_Luma(source);
    float maxv = max(source.r, max(source.g, source.b));
    float minv = min(source.r, min(source.g, source.b));
    float sat = (maxv <= SSR_EPS) ? 0.0 : ((maxv - minv) / maxv);
    float satMask = smoothstep(0.22, 1.0, sat);
    float lumaMask = smoothstep(SSR_LightThreshold, SSR_LightThreshold + SSR_LightSoftness, luma);
    float peakMask = smoothstep(SSR_LightThreshold, SSR_LightThreshold + SSR_LightSoftness, maxv);
    return saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
}

float SSR_DepthWindow(float2 uv)
{
    float availability = SSR_DepthConfidence(uv);
    float depth = SSR_Depth(uv);
    float d0 = min(SSR_DepthStart, SSR_DepthEnd);
    float d1 = max(SSR_DepthStart, SSR_DepthEnd);
    float soft = 0.01;
    float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
    float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
    return saturate(beginMask * endMask * availability);
}

float SSR_ContrastMask(float2 uv, float3 source)
{
    float contrast = SHARED_LocalContrast(uv, source);
    return smoothstep(
        SSR_ContrastThreshold,
        SSR_ContrastThreshold * max(1.25, SSR_ContrastGain),
        contrast * SSR_ContrastGain);
}

float SSR_FarDetailStack(float2 uv, float3 source)
{
    float depthValid = SSR_DepthConfidence(uv);
    float depth = SSR_Depth(uv);
    float farMask = smoothstep(SSR_FarDetailStart, SSR_FarDetailEnd, depth);
    float edgeMask = SSR_DepthEdge(uv);
    float edgeSuppress = 1.0 - saturate(edgeMask);
    float detailMask = SSR_ContrastMask(uv, source);
    return saturate(depthValid * farMask * edgeSuppress * detailMask);
}

float SSR_SelectedMask(float2 uv, float3 sourceColor)
{
    float selected = 1.0;

    if (SSR_MaskMode == SSR_MASK_FOG)
        selected = 1.0 - SSR_FogEvidence(uv, sourceColor);
    else if (SSR_MaskMode == SSR_MASK_LIGHT)
        selected = 1.0 - SSR_LightShield(sourceColor);
    else if (SSR_MaskMode == SSR_MASK_DEPTH)
        selected = SSR_DepthWindow(uv);
    else if (SSR_MaskMode == SSR_MASK_FAR_DETAIL)
        selected = SSR_FarDetailStack(uv, sourceColor);
    else if (SSR_MaskMode == SSR_MASK_CONTRAST)
        selected = SSR_ContrastMask(uv, sourceColor);
    else if (SSR_MaskMode == SSR_MASK_COMPOSITE)
    {
        float allow = max(SSR_DepthWindow(uv), max(SSR_FarDetailStack(uv, sourceColor), SSR_ContrastMask(uv, sourceColor)));
        float protect = max(SSR_FogEvidence(uv, sourceColor), SSR_LightShield(sourceColor));
        selected = saturate(allow * (1.0 - protect * 0.85));
    }

    return saturate(selected * SSR_MaskStrength);
}

float SSR_FinalGate(float selectedMask, float applicationField, float depthConfidence)
{
    return
        saturate(lerp(1.0, selectedMask, SSR_MaskInfluence)) *
        saturate(lerp(1.0, applicationField, SSR_ApplicationLensStrength)) *
        saturate(0.35 + 0.65 * depthConfidence);
}

int SSR_RepresentativeSamplingTapBudget()
{
    int requested = 0;
    if (SSR_EnableHighlight != 0) requested = max(requested, SSR_HighlightTapBudget);
    if (SSR_EnableBase != 0) requested = max(requested, SSR_BaseTapBudget);
    if (SSR_EnableGloss != 0) requested = max(requested, SSR_GlossTapBudget);
    if (requested <= 0) requested = SSR_BaseTapBudget;
    return requested;
}

float SSR_RepresentativeSamplingRadius()
{
    float radius = 0.0;
    if (SSR_EnableHighlight != 0) radius = max(radius, SSR_HighlightRadiusPixels);
    if (SSR_EnableBase != 0) radius = max(radius, SSR_BaseRadiusPixels);
    if (SSR_EnableGloss != 0) radius = max(radius, SSR_GlossRadiusPixels);
    if (radius <= 0.0) radius = SSR_BaseRadiusPixels;
    return radius;
}

float3 SSR_GatherPass(float2 uv, int tapBudget, float radiusPixels, float rejectStart, float rejectEnd, float distanceFalloff, float brightStart, float brightEnd, float glossBlend, float highlightBias)
{
    float3 sourceColor = SSR_Source(uv);
    float3 result = sourceColor;

    if (SSR_SamplingLensMode != SSR_LENS_OFF)
    {
        int tapCount = SSR_ActiveTapCountForBudget(SSR_SamplingLensMode, tapBudget);
        float centerDepth = SSR_Depth(uv);
        float confidence = SSR_DepthConfidence(uv);
        float centerLuma = SSR_Luma(sourceColor);
        float2 px = SHARED_PixelSize() * radiusPixels;
        float2 reflectDir = SSR_ReflectionDirection(uv);
        float3 sumColor = sourceColor;
        float weightSum = 1.0;

        [loop]
        for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
        {
            if (i >= tapCount) break;

            float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
            float2 offset = SSR_LensOffset(SSR_SamplingLensMode, i, tapBudget);
            float2 reflectedOffset = reflectDir * growth + offset * 0.55;
            float2 sampleUv = saturate(uv + reflectedOffset * px);
            float3 sampleColor = SSR_Source(sampleUv);
            float sampleDepth = SSR_Depth(sampleUv);
            float sampleLuma = SSR_Luma(sampleColor);

            float reject = 1.0 - smoothstep(rejectStart, rejectEnd, abs(sampleDepth - centerDepth) * max(1.0, SSR_DepthTraceScale));
            float depthWeight = saturate(lerp(1.0, reject, confidence));
            float distanceWeight = SHARED_SafeRcp(1.0 + length(reflectedOffset) * distanceFalloff);
            float brightWeight = smoothstep(brightStart, brightEnd, sampleLuma + highlightBias * max(0.0, sampleLuma - centerLuma));
            float weight = saturate(depthWeight * distanceWeight * lerp(1.0, brightWeight, highlightBias));

            sumColor += sampleColor * weight;
            weightSum += weight;
        }

        float3 gathered = sumColor / max(SSR_EPS, weightSum);
        result = lerp(gathered, lerp(sourceColor, gathered, 0.55), glossBlend);
    }

    return result;
}

float4 SSR_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = SSR_Source(uv);
    if (SSR_Enable == 0)
        return float4(sourceColor, 1.0);

    float3 highlightColor = (SSR_EnableHighlight != 0) ? SSR_GatherPass(uv, SSR_HighlightTapBudget, SSR_HighlightRadiusPixels, SSR_BaseDepthRejectStart * 0.75, SSR_BaseDepthRejectEnd * 0.75, 0.55, SSR_HighlightBrightStart, SSR_HighlightBrightEnd, 0.0, 1.0) : sourceColor;
    float3 baseColor = (SSR_EnableBase != 0) ? SSR_GatherPass(uv, SSR_BaseTapBudget, SSR_BaseRadiusPixels, SSR_BaseDepthRejectStart, SSR_BaseDepthRejectEnd, SSR_BaseDistanceFalloff, 0.15, 0.85, 0.0, 0.35) : sourceColor;
    float3 glossColor = (SSR_EnableGloss != 0) ? SSR_GatherPass(uv, SSR_GlossTapBudget, SSR_GlossRadiusPixels, SSR_GlossDepthRejectStart, SSR_GlossDepthRejectEnd, SSR_GlossDistanceFalloff, 0.10, 0.75, SSR_GlossBlend, 0.15) : sourceColor;

    float3 highlightContribution = max(highlightColor - sourceColor, 0.0.xxx) * SSR_HighlightStrength;
    float3 baseContribution = max(baseColor - sourceColor, 0.0.xxx) * SSR_BaseStrength;
    float3 glossContribution = max(glossColor - sourceColor, 0.0.xxx) * SSR_GlossStrength;
    float3 combinedReflection = highlightContribution + baseContribution + glossContribution;

    float selectedMask = SSR_SelectedMask(uv, sourceColor);
    float fogEvidence = SSR_FogEvidence(uv, sourceColor);
    float applicationField = SSR_LensField(uv, SSR_ApplicationLensMode, SSR_ApplicationTapBudget, SSR_ApplicationRadiusPixels);
    float samplingField = SSR_LensField(uv, SSR_SamplingLensMode, SSR_BaseTapBudget, SSR_BaseRadiusPixels * 0.55 + SSR_GlossRadiusPixels * 0.12);
    float confidence = SSR_DepthConfidence(uv);
    float finalGate = SSR_FinalGate(selectedMask, applicationField, confidence);

    float3 finalColor = saturate(sourceColor + combinedReflection * finalGate * SSR_MasterIntensity);

    if (SSR_DebugView == 1) return float4(SSR_DebugShape3(highlightContribution), 1.0);
    if (SSR_DebugView == 2) return float4(SSR_DebugShape3(baseContribution), 1.0);
    if (SSR_DebugView == 3) return float4(SSR_DebugShape3(glossContribution), 1.0);
    if (SSR_DebugView == 4) return float4(SSR_DebugShape3(combinedReflection), 1.0);
    if (SSR_DebugView == 5)
    {
        float2 dir = SSR_ReflectionDirection(uv);
        return float4(0.5 + 0.5 * dir.x, 0.5 + 0.5 * dir.y, 0.5 + 0.5 * confidence, 1.0);
    }
    if (SSR_DebugView == 6) return float4(SSR_TiledFieldView(uv, SSR_SamplingLensMode, SSR_RepresentativeSamplingTapBudget()), 1.0);
    if (SSR_DebugView == 7) return float4(SSR_CenterFieldFootprintOverlay(uv, sourceColor, SSR_SamplingLensMode, SSR_RepresentativeSamplingTapBudget(), SSR_RepresentativeSamplingRadius(), true), 1.0);
    if (SSR_DebugView == 8) return float4(SSR_DebugScalar(samplingField).xxx, 1.0);
    if (SSR_DebugView == 9) return float4(SSR_TiledFieldView(uv, SSR_ApplicationLensMode, SSR_ApplicationTapBudget), 1.0);
    if (SSR_DebugView == 10) return float4(SSR_CenterFieldFootprintOverlay(uv, sourceColor, SSR_ApplicationLensMode, SSR_ApplicationTapBudget, SSR_ApplicationRadiusPixels, false), 1.0);
    if (SSR_DebugView == 11) return float4(SSR_DebugScalar(applicationField).xxx, 1.0);
    if (SSR_DebugView == 12) return float4(SSR_DebugScalar(selectedMask).xxx, 1.0);
    if (SSR_DebugView == 13) return float4(SSR_DebugScalar(fogEvidence).xxx, 1.0);
    if (SSR_DebugView == 14) return float4(SSR_DebugScalar(finalGate).xxx, 1.0);
    return float4(finalColor, 1.0);
}

#endif
