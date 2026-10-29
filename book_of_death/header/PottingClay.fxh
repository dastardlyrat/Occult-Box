#ifndef POTTING_CLAY_FXH
#define POTTING_CLAY_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"
#include "shared_fibonacci.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define POTTERY_LENS_OFF 0
#define POTTERY_LENS_ORGANIC55 1
#define POTTERY_LENS_GOLDEN_SWEEP 2
#define POTTERY_LENS_STAGGERED55 3
#define POTTERY_LENS_RING9 4
#define POTTERY_LENS_SPIRAL13 5
#define POTTERY_LENS_RECT_H15 6
#define POTTERY_LENS_RECT_V15 7
#define POTTERY_LENS_DIAMOND13 8
#define POTTERY_LENS_BOX25 9

#define POTTERY_MASK_OFF 0
#define POTTERY_MASK_FOG 1
#define POTTERY_MASK_LIGHT 2
#define POTTERY_MASK_DEPTH 3
#define POTTERY_MASK_FAR_DETAIL 4
#define POTTERY_MASK_CONTRAST 5
#define POTTERY_MASK_COMPOSITE 6

#define POTTERY_EPS 0.00001

float3 POTTERY_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
}

float POTTERY_Luma(float3 color)
{
    return SHARED_Luma(color);
}

float2 POTTERY_Pixel()
{
    return SHARED_PixelSize();
}

float POTTERY_DebugScalar(float v)
{
    return POTTERY_DebugShape(v);
}

float POTTERY_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), POTTERY_DepthMode, POTTERY_DepthInvert);
}

float POTTERY_DepthConfidence(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), POTTERY_DepthMode, POTTERY_DepthInvert, POTTERY_DepthTraceScale, POTTERY_DepthAvailabilityThreshold);
}

float POTTERY_DepthEdge(float2 uv)
{
    return SHARED_DepthEdgeMask(saturate(uv), POTTERY_DepthMode, POTTERY_DepthInvert, POTTERY_DepthTraceScale, POTTERY_DepthAvailabilityThreshold, POTTERY_DepthEdgeThreshold);
}

float2 POTTERY_RotateField(float2 p)
{
    return SHARED_Rotate(p, POTTERY_FieldRotation);
}

int POTTERY_QualityTapCap()
{
    if (POTTERY_QualityTier == 0) return 9;
    if (POTTERY_QualityTier == 1) return 21;
    if (POTTERY_QualityTier == 2) return 34;
    return 55;
}

int POTTERY_CanonicalTapCount()
{
    if (POTTERY_OrganicLensMode == POTTERY_LENS_RING9) return 9;
    if (POTTERY_OrganicLensMode == POTTERY_LENS_SPIRAL13) return 13;
    if (POTTERY_OrganicLensMode == POTTERY_LENS_RECT_H15 || POTTERY_OrganicLensMode == POTTERY_LENS_RECT_V15) return 15;
    if (POTTERY_OrganicLensMode == POTTERY_LENS_DIAMOND13) return 13;
    if (POTTERY_OrganicLensMode == POTTERY_LENS_BOX25) return 25;
    return SHARED_LENS55_TAP_COUNT;
}

int POTTERY_ActiveTapCount()
{
    int requested = min(POTTERY_OrganicTapBudget, POTTERY_QualityTapCap());
    return clamp(requested, 1, POTTERY_CanonicalTapCount());
}

int POTTERY_CanonicalIndex(int logicalIndex)
{
    return SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        POTTERY_ActiveTapCount(),
        POTTERY_CanonicalTapCount(),
        POTTERY_ReductionMode,
        0,
        POTTERY_CanonicalTapCount());
}

float2 POTTERY_OrganicLensOffset(int logicalIndex)
{
    if (POTTERY_OrganicLensMode == POTTERY_LENS_OFF)
        return 0.0.xx;

    int canonicalIndex = POTTERY_CanonicalIndex(logicalIndex);
    canonicalIndex = clamp(canonicalIndex, 0, POTTERY_CanonicalTapCount() - 1);

    if (POTTERY_OrganicLensMode == POTTERY_LENS_RING9)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(canonicalIndex - 1)) / 8.0;
        return POTTERY_RotateField(float2(cos(angle), sin(angle)) * POTTERY_FieldScale);
    }

    if (POTTERY_OrganicLensMode == POTTERY_LENS_SPIRAL13)
    {
        if (canonicalIndex <= 0) return 0.0.xx;
        float sampleIndex = float(canonicalIndex - 1);
        float radial = sqrt((sampleIndex + 1.0) / 12.0);
        float2 dir = SHARED_GoldenDirection(sampleIndex + 0.5 + POTTERY_FibonacciAnchor);
        return POTTERY_RotateField(dir * radial * POTTERY_FieldScale);
    }

    if (POTTERY_OrganicLensMode == POTTERY_LENS_RECT_H15)
    {
        return POTTERY_RotateField(float2((float(canonicalIndex) - 7.0) / 7.0, 0.0) * POTTERY_FieldScale);
    }

    if (POTTERY_OrganicLensMode == POTTERY_LENS_RECT_V15)
    {
        return POTTERY_RotateField(float2(0.0, (float(canonicalIndex) - 7.0) / 7.0) * POTTERY_FieldScale);
    }

    if (POTTERY_OrganicLensMode == POTTERY_LENS_DIAMOND13)
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
        return POTTERY_RotateField(offset * POTTERY_FieldScale);
    }

    if (POTTERY_OrganicLensMode == POTTERY_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        float2 offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
        return POTTERY_RotateField(offset * POTTERY_FieldScale);
    }

    if (POTTERY_OrganicLensMode == POTTERY_LENS_GOLDEN_SWEEP)
    {
        float2 dir = SHARED_GoldenDirection(float(canonicalIndex) + POTTERY_FibonacciAnchor);
        float growth = SHARED_Lens55FibonacciGrowth(canonicalIndex, POTTERY_ActiveTapCount());
        return POTTERY_RotateField(dir * growth * 0.95 * POTTERY_FieldScale);
    }

    return POTTERY_RotateField(SHARED_Lens55Offset(canonicalIndex) * POTTERY_FieldScale);
}

float2 POTTERY_OrganicRecursiveOffset(float2 uv, float2 edgeDir)
{
    float phase = dot(uv, float2(173.31, 91.77));
    float2 seedDir = normalize(SHARED_GoldenDirection(1.0 + phase + POTTERY_FibonacciAnchor));
    float2 dir0 = normalize(lerp(seedDir, edgeDir, saturate(POTTERY_OrganicEdgeBias)));
    float2 perp0 = float2(-dir0.y, dir0.x);
    float2 dir1 = normalize(dir0 * 0.6180339 + perp0 * 0.3819660);
    float2 perp1 = float2(-dir1.y, dir1.x);
    float2 dir2 = normalize(dir1 * 0.6180339 + perp1 * 0.3819660);
    float2 dir3 = normalize(lerp(dir2, edgeDir, 0.5));
    float2 mixedDir = (dir0 * 1.0) + (dir1 * 0.6180339) + (dir2 * 0.3819660) + (dir3 * 0.2360680);
    return normalize(mixedDir + 0.00001.xx);
}

float POTTERY_EdgeRange(float lCenter, float lN, float lS, float lW, float lE)
{
    float lMin = min(lCenter, min(min(lN, lS), min(lW, lE)));
    float lMax = max(lCenter, max(max(lN, lS), max(lW, lE)));
    return lMax - lMin;
}

float2 POTTERY_EdgeDirection(float lNW, float lNE, float lSW, float lSE)
{
    float dirX = -((lNW + lNE) - (lSW + lSE));
    float dirY =  ((lNW + lSW) - (lNE + lSE));
    return normalize(float2(dirX, dirY) + 0.00001.xx);
}

float3 POTTERY_DirectionalColor(float2 uv, float2 edgeDir)
{
    float2 pixel = POTTERY_Pixel();
    float2 recursiveDir = POTTERY_OrganicRecursiveOffset(uv, edgeDir);
    float2 span = edgeDir * (POTTERY_DirectionalSpanPixels * (0.4 + 0.6 * POTTERY_DirectionalSubpixel)) * pixel;
    float2 stepA = span * (1.0 / 3.0) + recursiveDir * (0.25 * POTTERY_OrganicRadiusPixels) * pixel;
    float2 stepB = span * (2.0 / 3.0) + recursiveDir * (0.50 * POTTERY_OrganicRadiusPixels) * pixel;

    float3 p1 = POTTERY_Source(saturate(uv + stepA));
    float3 n1 = POTTERY_Source(saturate(uv - stepA));
    float3 p2 = POTTERY_Source(saturate(uv + stepB));
    float3 n2 = POTTERY_Source(saturate(uv - stepB));
    return (p1 + n1 + p2 + n2) * 0.25;
}

float3 POTTERY_NeighborhoodColor(float3 n, float3 s, float3 w, float3 e, float3 nw, float3 ne, float3 sw, float3 se,
    float hEdge, float vEdge, float dEdge)
{
    float sumEdge = hEdge + vEdge + dEdge + POTTERY_EPS;
    float wH = hEdge / sumEdge;
    float wV = vEdge / sumEdge;
    float wD = (dEdge / sumEdge) * POTTERY_NeighborhoodDiagonalWeight;
    float norm = max(POTTERY_EPS, wH + wV + wD);

    float3 hBlend = (w + e) * 0.5;
    float3 vBlend = (n + s) * 0.5;
    float3 dBlend = (nw + ne + sw + se) * 0.25;
    return ((hBlend * wH) + (vBlend * wV) + (dBlend * wD)) / norm;
}

float3 POTTERY_OrganicColor(float2 uv, float3 centerColor, float2 edgeDir)
{
    if (POTTERY_OrganicLensMode == POTTERY_LENS_OFF)
        return centerColor;

    int tapCount = POTTERY_ActiveTapCount();
    float2 px = POTTERY_Pixel() * POTTERY_OrganicRadiusPixels;
    float3 accum = centerColor * POTTERY_OrganicCenterWeight;
    float weight = POTTERY_OrganicCenterWeight;
    float2 recursiveDir = POTTERY_OrganicRecursiveOffset(uv, edgeDir);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 lensOffset = POTTERY_OrganicLensOffset(i);
        float2 lensDir = (length(lensOffset) > POTTERY_EPS) ? normalize(lensOffset) : recursiveDir;
        float alignment = saturate((dot(lensDir, edgeDir) * 0.5 + 0.5));
        float edgeBias = lerp(1.0, alignment, POTTERY_OrganicEdgeBias);
        float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
        float distanceWeight = MIXSR_SafePowNonNegative(abs(1.0 - saturate(growth)), max(0.01, POTTERY_OrganicDistanceFalloff));
        float tapWeight = max(0.05, edgeBias * distanceWeight);
        float2 sampleUv = saturate(uv + lensOffset * px);
        accum += POTTERY_Source(sampleUv) * tapWeight;
        weight += tapWeight;
    }

    return accum / max(POTTERY_EPS, weight);
}

float POTTERY_EvaluateMask(float2 uv, float3 source)
{
    if (POTTERY_MaskMode == POTTERY_MASK_OFF)
        return 1.0;

    float fog = 0.0;
    {
        float luma = SHARED_Luma(source);
        float saturation = SHARED_Saturation(source);
        float desaturation = 1.0 - saturation;
        float contrast = SHARED_LocalContrast(uv, source);
        float depthAvailability = POTTERY_DepthConfidence(uv);
        float depth = POTTERY_Depth(uv);
        float depthBias = smoothstep(max(POTTERY_DepthStart, 0.08), max(POTTERY_FarDetailStart, 0.35), depth);
        float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
        float brightMask = smoothstep(POTTERY_FogBrightnessFloor, POTTERY_FogBrightnessFloor + 0.08, luma);
        float desatMask = smoothstep(POTTERY_FogDesaturation, min(1.0, POTTERY_FogDesaturation + 0.20), desaturation);
        float lowContrastMask = 1.0 - smoothstep(POTTERY_FogLowContrast, max(POTTERY_FogLowContrast + 0.01, POTTERY_FogLowContrast * 3.0), contrast);
        float edgeSuppress = 1.0 - smoothstep(POTTERY_LineThreshold, POTTERY_LineThreshold * 4.0, lumaGrad);
        float lightSuppress = 1.0 - smoothstep(POTTERY_LightThreshold, POTTERY_LightThreshold + POTTERY_LightSoftness, luma);
        float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
        fog = saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
    }

    float light = 0.0;
    {
        float luma = SHARED_Luma(source);
        float maxv = max(source.r, max(source.g, source.b));
        float minv = min(source.r, min(source.g, source.b));
        float sat = (maxv <= POTTERY_EPS) ? 0.0 : ((maxv - minv) / maxv);
        float satMask = smoothstep(0.22, 1.0, sat);
        float lumaMask = smoothstep(POTTERY_LightThreshold, POTTERY_LightThreshold + POTTERY_LightSoftness, luma);
        float peakMask = smoothstep(POTTERY_LightThreshold, POTTERY_LightThreshold + POTTERY_LightSoftness, maxv);
        light = saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
    }

    float depthWindow = 0.0;
    {
        float availability = POTTERY_DepthConfidence(uv);
        float depth = POTTERY_Depth(uv);
        float d0 = min(POTTERY_DepthStart, POTTERY_DepthEnd);
        float d1 = max(POTTERY_DepthStart, POTTERY_DepthEnd);
        float soft = 0.01;
        float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
        float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
        depthWindow = saturate(beginMask * endMask * availability);
    }

    float farDetail = 0.0;
    {
        float depthValid = POTTERY_DepthConfidence(uv);
        float depth = POTTERY_Depth(uv);
        float farMask = smoothstep(POTTERY_FarDetailStart, POTTERY_FarDetailEnd, depth);
        float detail = abs(SHARED_Luma(source) - SHARED_Luma(POTTERY_OrganicColor(uv, source, float2(1.0, 0.0)))) * max(1.0, POTTERY_DetailScale);
        float detailMask = smoothstep(POTTERY_DetailLow, POTTERY_DetailHigh, detail);
        farDetail = saturate(depthValid * farMask * detailMask);
    }

    float contrastMask = 0.0;
    {
        float contrast = SHARED_LocalContrast(uv, source);
        contrastMask = smoothstep(
            POTTERY_ContrastThreshold,
            POTTERY_ContrastThreshold * max(1.25, POTTERY_ContrastGain),
            contrast * POTTERY_ContrastGain);
    }

    if (POTTERY_MaskMode == POTTERY_MASK_FOG) return fog;
    if (POTTERY_MaskMode == POTTERY_MASK_LIGHT) return light;
    if (POTTERY_MaskMode == POTTERY_MASK_DEPTH) return depthWindow;
    if (POTTERY_MaskMode == POTTERY_MASK_FAR_DETAIL) return farDetail;
    if (POTTERY_MaskMode == POTTERY_MASK_CONTRAST) return contrastMask;
    return saturate(max(max(fog, light), max(farDetail, contrastMask)) * depthWindow);
}

float POTTERY_FogField(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = POTTERY_DepthConfidence(uv);
    float depth = POTTERY_Depth(uv);
    float depthBias = smoothstep(max(POTTERY_DepthStart, 0.08), max(POTTERY_FarDetailStart, 0.35), depth);
    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(POTTERY_FogBrightnessFloor, POTTERY_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(POTTERY_FogDesaturation, min(1.0, POTTERY_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(POTTERY_FogLowContrast, max(POTTERY_FogLowContrast + 0.01, POTTERY_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(POTTERY_LineThreshold, POTTERY_LineThreshold * 4.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(POTTERY_LightThreshold, POTTERY_LightThreshold + POTTERY_LightSoftness, luma);
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float POTTERY_OrganicFieldStrength(float2 uv)
{
    if (POTTERY_OrganicLensMode == POTTERY_LENS_OFF)
        return 0.0;

    int tapCount = POTTERY_ActiveTapCount();
    float sum = 0.0;
    float weight = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float growth = SHARED_Lens55FibonacciGrowth(i, tapCount);
        float contribution = MIXSR_SafePowNonNegative(abs(1.0 - saturate(growth)), max(0.01, POTTERY_OrganicDistanceFalloff));
        sum += contribution;
        weight += 1.0;
    }

    return (weight > 0.0) ? saturate(sum / weight) : 0.0;
}

float2 POTTERY_LocalPreviewUV(float2 uv)
{
    float tiles = max(1.0, POTTERY_DebugPatternTiles);
    return frac(uv * tiles) - 0.5;
}

float POTTERY_DebugTapMarker(float2 localUV, float2 tapOffset)
{
    float2 plotted = tapOffset * POTTERY_DebugPatternScale;
    float dist = length(localUV - plotted);
    float outer = POTTERY_DebugMarkerSize + POTTERY_DebugPatternSoftness;
    return 1.0 - smoothstep(POTTERY_DebugMarkerSize, outer, dist);
}

float POTTERY_DebugGuideRing(float2 localUV)
{
    float dist = abs(length(localUV) - POTTERY_DebugPatternScale);
    return 1.0 - smoothstep(0.0, POTTERY_DebugPatternSoftness * 1.25, dist);
}

float3 POTTERY_TiledOrganicField(float2 uv)
{
    float2 localUV = POTTERY_LocalPreviewUV(uv);
    float marker = POTTERY_DebugTapMarker(localUV, 0.0.xx);
    int tapCount = POTTERY_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        marker = max(marker, POTTERY_DebugTapMarker(localUV, POTTERY_OrganicLensOffset(i)));
    }

    marker = saturate(marker + POTTERY_DebugGuideRing(localUV) * 0.35);
    return POTTERY_DebugShape3(lerp(float3(0.05, 0.07, 0.10), float3(0.92, 0.97, 1.0), marker));
}

float POTTERY_PlotMarker(float2 p, float2 center, float radius)
{
    return 1.0 - smoothstep(radius, radius * 1.9, length(p - center));
}

float3 POTTERY_CenterOrganicFootprint(float2 uv, float3 source)
{
    float2 px = POTTERY_Pixel() * POTTERY_OrganicRadiusPixels;
    float marker = POTTERY_PlotMarker(uv, 0.5.xx, POTTERY_DebugMarkerSize * 0.5);
    int tapCount = POTTERY_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 sampleUv = saturate(0.5.xx + POTTERY_OrganicLensOffset(i) * px);
        marker = max(marker, POTTERY_PlotMarker(uv, sampleUv, POTTERY_DebugMarkerSize * 0.5));
    }

    float3 overlayColor = lerp(source, float3(0.98, 0.96, 0.82), saturate(marker));
    return POTTERY_DebugShape3(overlayColor);
}

float4 POTTERY_MainPS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float2 pixel = POTTERY_Pixel();
    float2 uvN = saturate(uv + float2(0.0, -pixel.y));
    float2 uvS = saturate(uv + float2(0.0,  pixel.y));
    float2 uvW = saturate(uv + float2(-pixel.x, 0.0));
    float2 uvE = saturate(uv + float2( pixel.x, 0.0));
    float2 uvNW = saturate(uv + float2(-pixel.x, -pixel.y));
    float2 uvNE = saturate(uv + float2( pixel.x, -pixel.y));
    float2 uvSW = saturate(uv + float2(-pixel.x,  pixel.y));
    float2 uvSE = saturate(uv + float2( pixel.x,  pixel.y));

    float3 c = POTTERY_Source(uv);
    if (POTTERY_Enable == 0)
        return float4(c, 1.0);

    float3 n = POTTERY_Source(uvN);
    float3 s = POTTERY_Source(uvS);
    float3 w = POTTERY_Source(uvW);
    float3 e = POTTERY_Source(uvE);
    float3 nw = POTTERY_Source(uvNW);
    float3 ne = POTTERY_Source(uvNE);
    float3 sw = POTTERY_Source(uvSW);
    float3 se = POTTERY_Source(uvSE);

    float lC = POTTERY_Luma(c);
    float lN = POTTERY_Luma(n);
    float lS = POTTERY_Luma(s);
    float lW = POTTERY_Luma(w);
    float lE = POTTERY_Luma(e);
    float lNW = POTTERY_Luma(nw);
    float lNE = POTTERY_Luma(ne);
    float lSW = POTTERY_Luma(sw);
    float lSE = POTTERY_Luma(se);

    float edgeRange = POTTERY_EdgeRange(lC, lN, lS, lW, lE);
    float edgeMask = smoothstep(POTTERY_EdgeThreshold, POTTERY_EdgeThreshold + max(0.0001, POTTERY_EdgeSoftness), edgeRange);
    float2 edgeDir = POTTERY_EdgeDirection(lNW, lNE, lSW, lSE);

    float3 directionalColor = POTTERY_DirectionalColor(uv, edgeDir);
    float hEdge = abs(lN - lS);
    float vEdge = abs(lW - lE);
    float dEdge = (abs(lNW - lSE) + abs(lNE - lSW)) * 0.5;
    float neighborhoodEdge = max(hEdge, max(vEdge, dEdge));
    float neighborhoodMask = smoothstep(POTTERY_NeighborhoodContrastThreshold, POTTERY_NeighborhoodContrastThreshold + max(0.0001, POTTERY_EdgeSoftness), neighborhoodEdge);
    float3 neighborhoodColor = POTTERY_NeighborhoodColor(n, s, w, e, nw, ne, sw, se, hEdge, vEdge, dEdge);
    float3 organicColor = POTTERY_OrganicColor(uv, c, edgeDir);

    float directionalBlend = (POTTERY_EnableDirectional != 0) ? saturate(edgeMask * POTTERY_DirectionalStrength) : 0.0;
    float neighborhoodBlend = (POTTERY_EnableNeighborhood != 0) ? saturate(edgeMask * neighborhoodMask * POTTERY_NeighborhoodStrength) : 0.0;
    float organicBlend = (POTTERY_EnableOrganic != 0 && POTTERY_OrganicLensMode != POTTERY_LENS_OFF) ? saturate(edgeMask * POTTERY_OrganicStrength * (0.35 + 0.65 * neighborhoodMask)) : 0.0;

    float3 hybridAA = c;
    hybridAA = lerp(hybridAA, directionalColor, directionalBlend);
    hybridAA = lerp(hybridAA, neighborhoodColor, neighborhoodBlend);
    hybridAA = lerp(hybridAA, organicColor, organicBlend);

    float enabledCount = 0.0;
    enabledCount += (POTTERY_EnableDirectional != 0) ? 1.0 : 0.0;
    enabledCount += (POTTERY_EnableNeighborhood != 0) ? 1.0 : 0.0;
    enabledCount += (POTTERY_EnableOrganic != 0 && POTTERY_OrganicLensMode != POTTERY_LENS_OFF) ? 1.0 : 0.0;
    float combinedWeight = (enabledCount > 0.0) ? saturate((directionalBlend + neighborhoodBlend + organicBlend) / enabledCount) : 0.0;

    float selectedMask = POTTERY_EvaluateMask(uv, c);
    float fogEvidence = POTTERY_FogField(uv, c);
    float finalGate = saturate(combinedWeight * lerp(1.0, selectedMask, POTTERY_MaskInfluence) * (1.0 - fogEvidence * POTTERY_FogInfluence));
    float computedWeight = saturate(finalGate * POTTERY_MasterIntensity);
    float3 finalColor = lerp(c, hybridAA, computedWeight);

    float3 outColor = finalColor;
    if (POTTERY_DebugView == 1) outColor = POTTERY_DebugScalar(edgeRange).xxx;
    else if (POTTERY_DebugView == 2) outColor = POTTERY_DebugScalar(directionalBlend).xxx;
    else if (POTTERY_DebugView == 3) outColor = POTTERY_DebugScalar(neighborhoodBlend).xxx;
    else if (POTTERY_DebugView == 4) outColor = POTTERY_DebugScalar(organicBlend).xxx;
    else if (POTTERY_DebugView == 5) outColor = POTTERY_DebugScalar(combinedWeight).xxx;
    else if (POTTERY_DebugView == 6) outColor = POTTERY_DebugScalar(computedWeight).xxx;
    else if (POTTERY_DebugView == 7) outColor = POTTERY_TiledOrganicField(uv);
    else if (POTTERY_DebugView == 8) outColor = POTTERY_CenterOrganicFootprint(uv, c);
    else if (POTTERY_DebugView == 9) outColor = POTTERY_DebugScalar(POTTERY_OrganicFieldStrength(uv)).xxx;
    else if (POTTERY_DebugView == 10) outColor = POTTERY_DebugScalar(selectedMask).xxx;
    else if (POTTERY_DebugView == 11) outColor = POTTERY_DebugScalar(fogEvidence).xxx;
    else if (POTTERY_DebugView == 12) outColor = POTTERY_DebugScalar(finalGate).xxx;
    else if (POTTERY_DebugView == 13) outColor = directionalColor;
    else if (POTTERY_DebugView == 14) outColor = neighborhoodColor;
    else if (POTTERY_DebugView == 15) outColor = organicColor;

    return float4(saturate(outColor), 1.0);
}

#endif
