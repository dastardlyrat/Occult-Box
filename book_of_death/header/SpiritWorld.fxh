#ifndef SPIRIT_WORLD_FXH
#define SPIRIT_WORLD_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"
#include "shared_fibonacci.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define SPIRIT_LENS_ORGANIC55 0
#define SPIRIT_LENS_STAGGERED55 1
#define SPIRIT_LENS_DIAMOND13 2
#define SPIRIT_LENS_BOX25 3

#define SPIRIT_MASK_OFF 0
#define SPIRIT_MASK_FOG 1
#define SPIRIT_MASK_LIGHT 2
#define SPIRIT_MASK_DEPTH 3
#define SPIRIT_MASK_FAR_DETAIL 4
#define SPIRIT_MASK_CONTRAST 5
#define SPIRIT_MASK_COMPOSITE 6

float SPIRIT_Luma(float3 c)
{
    return SHARED_Luma(c);
}

float SPIRIT_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), SPIRIT_DepthMode, SPIRIT_DepthInvert);
}

float SPIRIT_DepthConfidence(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), SPIRIT_DepthMode, SPIRIT_DepthInvert, SPIRIT_DepthTraceScale, SPIRIT_DepthAvailabilityThreshold);
}

float SPIRIT_DepthDiscontinuity(float2 uv)
{
    return SHARED_DepthEdgeMask(saturate(uv), SPIRIT_DepthMode, SPIRIT_DepthInvert, SPIRIT_DepthTraceScale, SPIRIT_DepthAvailabilityThreshold, SPIRIT_DepthEdgeThreshold);
}

int SPIRIT_CanonicalTapCount()
{
    if (SPIRIT_LensMode == SPIRIT_LENS_DIAMOND13)
        return 13;
    if (SPIRIT_LensMode == SPIRIT_LENS_BOX25)
        return 25;
    return SHARED_LENS55_TAP_COUNT;
}

int SPIRIT_ActiveTapCount()
{
    return clamp(SPIRIT_TapBudget, 1, SPIRIT_CanonicalTapCount());
}

int SPIRIT_CoarseFieldTapCount()
{
    return clamp(SPIRIT_CoarseFieldTapBudget, 3, SHARED_LENS55_TAP_COUNT);
}

int SPIRIT_CanonicalIndex(int logicalIndex)
{
    return SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        SPIRIT_ActiveTapCount(),
        SPIRIT_CanonicalTapCount(),
        SPIRIT_ReductionMode,
        0,
        SPIRIT_CanonicalTapCount());
}

float2 SPIRIT_RotateField(float2 p)
{
    return SHARED_Rotate(p, SPIRIT_LensFieldRotation);
}

float2 SPIRIT_LensOffset(int logicalIndex)
{
    int canonicalIndex = SPIRIT_CanonicalIndex(logicalIndex);
    canonicalIndex = clamp(canonicalIndex, 0, SPIRIT_CanonicalTapCount() - 1);
    float2 offset = SHARED_Lens55Offset(canonicalIndex);

    if (SPIRIT_LensMode == SPIRIT_LENS_DIAMOND13)
    {
        offset = 0.0.xx;
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
    }
    else if (SPIRIT_LensMode == SPIRIT_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(canonicalIndex, 5);
        int y = int(uint(canonicalIndex) / 5u);
        offset = float2((float(x) - 2.0) * 0.5, (float(y) - 2.0) * 0.5);
    }

    return SPIRIT_RotateField(offset * SPIRIT_LensFieldScale);
}

float3 SPIRIT_LensAverage(float2 uv)
{
    float3 accum = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    float weight = 1.0;
    float2 px = SHARED_PixelSize() * SPIRIT_LensRadiusPixels;
    int activeTapCount = SPIRIT_ActiveTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= activeTapCount) break;
        accum += tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + SPIRIT_LensOffset(i) * px), 0.0, 0.0)).rgb;
        weight += 1.0;
    }

    return accum / max(0.00001, weight);
}

float SPIRIT_ToneShadowMask(float luma)
{
    float darkness = 1.0 - smoothstep(SPIRIT_CoarseShadowStart, SPIRIT_CoarseShadowEnd, luma);
    return saturate(darkness);
}

float SPIRIT_CelLuma(float luma, float contrastScale)
{
    float shaped = pow(abs(saturate(luma)), max(0.25, contrastScale));
    float bands = max(2.0, float(SPIRIT_BaseBands));
    return saturate(floor(shaped * bands) / max(1.0, bands - 1.0));
}

float3 SPIRIT_CelColor(float3 sourceColor)
{
    float luma = SPIRIT_Luma(sourceColor);
    float celLuma = SPIRIT_CelLuma(luma, SPIRIT_BaseBandContrast);
    float safeLuma = max(0.00001, luma);
    float3 chroma = sourceColor / safeLuma;
    return saturate(chroma * celLuma);
}

float SPIRIT_EdgeField(float2 uv)
{
    float2 px = SHARED_PixelSize() * SPIRIT_EdgeRadiusPixels;
    float centerDepth = SPIRIT_Depth(uv);
    float centerLuma = SPIRIT_Luma(tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb);

    float lumaEdge =
        abs(centerLuma - SPIRIT_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(px.x, 0.0)), 0.0, 0.0)).rgb)) +
        abs(centerLuma - SPIRIT_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(px.x, 0.0)), 0.0, 0.0)).rgb)) +
        abs(centerLuma - SPIRIT_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, px.y)), 0.0, 0.0)).rgb)) +
        abs(centerLuma - SPIRIT_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(0.0, px.y)), 0.0, 0.0)).rgb));

    float depthEdge =
        abs(centerDepth - SPIRIT_Depth(saturate(uv + float2(px.x, 0.0)))) +
        abs(centerDepth - SPIRIT_Depth(saturate(uv - float2(px.x, 0.0)))) +
        abs(centerDepth - SPIRIT_Depth(saturate(uv + float2(0.0, px.y)))) +
        abs(centerDepth - SPIRIT_Depth(saturate(uv - float2(0.0, px.y))));

    float combined = lumaEdge * SPIRIT_EdgeLumaGain + depthEdge * SPIRIT_EdgeDepthGain;
    return smoothstep(SPIRIT_EdgeThreshold, SPIRIT_EdgeThreshold + SPIRIT_EdgeSoftness, combined);
}

float SPIRIT_DepthGate(float2 uv, float centerDepth)
{
    float2 px = SHARED_PixelSize();
    float dR = SPIRIT_Depth(saturate(uv + float2(px.x, 0.0)));
    float dL = SPIRIT_Depth(saturate(uv - float2(px.x, 0.0)));
    float dU = SPIRIT_Depth(saturate(uv + float2(0.0, px.y)));
    float dD = SPIRIT_Depth(saturate(uv - float2(0.0, px.y)));

    float continuity = 1.0 - saturate((abs(centerDepth - dR) + abs(centerDepth - dL) + abs(centerDepth - dU) + abs(centerDepth - dD)) * (SPIRIT_DepthTraceScale * 0.5));
    float confidence = SPIRIT_DepthConfidence(uv);
    return saturate(lerp(1.0, continuity, 0.65) * lerp(0.65, 1.0, confidence));
}

float2 SPIRIT_OrganicDirection(float2 lensOffset, float fibIndex, float2 uv, float tapNorm)
{
    float2 lensDir = normalize(float2(0.23 - lensOffset.y, 0.17 + lensOffset.x + frac(fibIndex * 0.000618)));
    float armAngle = (6.2831853 * frac(fibIndex * 0.61803398875)) + dot(uv * (SPIRIT_CoarseDensity * 18.0), float2(0.1618, 0.2718));
    float2 branchDir = normalize(SHARED_Rotate(lensDir, degrees(armAngle + tapNorm * 1.08)));
    return normalize(lerp(lensDir, branchDir, 0.65));
}

float SPIRIT_HatchLine(float2 p, float2 dir, float phase, float density, float lo, float hi)
{
    float v = sin(dot(p, dir) * density + phase);
    return smoothstep(lo, hi, v);
}

float SPIRIT_BioPattern(float2 uv)
{
    float2 p = uv * SPIRIT_CoarsePatternScale;
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int tapCount = SPIRIT_CoarseFieldTapCount();

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 o = SHARED_Lens55Offset(i);
        float fi = SPIRIT_FibonacciAnchor + float(i);
        float tapNorm = (float(i) + 0.5) / 55.0;
        float2 dir = SPIRIT_OrganicDirection(o, fi, uv, tapNorm);
        float phase = fi * 0.013 + SPIRIT_CoarseFlow * 0.15 + dot(uv * (SPIRIT_CoarseDensity * 48.0), float2(0.754, 0.569));
        float hatch = SPIRIT_HatchLine(p + o * SPIRIT_CoarseTapSpread, dir, phase, SPIRIT_CoarseDensity, 0.72, 0.96);
        sumValue += hatch;
        sumWeight += 1.0;
    }

    return saturate(sumValue / max(0.00001, sumWeight));
}

float SPIRIT_FiveStagePattern(float2 uv, float depth, float localContrast)
{
    float smallScale = SPIRIT_CoarsePatternScale * 1.30;
    float medScale = SPIRIT_CoarsePatternScale * 1.00;
    float verySmallScale = SPIRIT_CoarsePatternScale * 1.70;

    float small = saturate((sin((uv.x + uv.y) * smallScale + depth * 21.0) * sin((uv.x - uv.y) * (smallScale * 0.825) - depth * 17.0) * 0.5 + 0.5));
    float med = saturate((sin((uv.x + uv.y) * medScale + depth * 19.0) * sin((uv.x - uv.y) * (medScale * 0.810) - depth * 15.0) * 0.5 + 0.5));
    float tiny = saturate((sin((uv.x + uv.y) * verySmallScale + depth * 23.0) * sin((uv.x - uv.y) * (verySmallScale * 0.840) - depth * 19.0) * 0.5 + 0.5));

    float stagePos = saturate(depth);
    float wNear = 1.0 - saturate(abs(stagePos - 0.10) / 0.30);
    float wForward = 1.0 - saturate(abs(stagePos - 0.32) / 0.30);
    float wCenter = 1.0 - saturate(abs(stagePos - 0.50) / 0.30);
    float wBack = 1.0 - saturate(abs(stagePos - 0.68) / 0.30);
    float wFar = 1.0 - saturate(abs(stagePos - 0.90) / 0.30);

    float blended = (small * wNear + med * wForward + tiny * wCenter + med * wBack + small * wFar) / max(0.00001, wNear + wForward + wCenter + wBack + wFar);
    return saturate(lerp(blended, blended * (0.6 + localContrast * 0.4), 0.5));
}

float SPIRIT_CrossPattern(float2 uv, float3 sourceColor)
{
    float2 p = uv * SPIRIT_CoarsePatternScale;
    float luma = SPIRIT_Luma(sourceColor);
    float darkness = 1.0 - smoothstep(0.18, 0.88, luma);
    float diagA = SPIRIT_HatchLine(p, normalize(float2(1.0, 1.0)), SPIRIT_CoarseFlow, SPIRIT_CoarseDensity, 0.72, 0.96);
    float diagB = SPIRIT_HatchLine(p, normalize(float2(1.0, -1.0)), SPIRIT_CoarseFlow * 1.17 + 1.3, SPIRIT_CoarseDensity * 0.92, 0.70, 0.95);
    float layerA = diagA * smoothstep(0.10, 0.75, darkness);
    float layerB = diagB * smoothstep(0.42, 0.98, darkness);
    return saturate(max(layerA, layerB));
}

float SPIRIT_CenteredFibonacciPattern(float2 uv, float localContrast)
{
    int tapCount = SPIRIT_CoarseFieldTapCount();
    float2 p = uv * (SPIRIT_CoarseTapSpread * 6.5);
    float sumValue = 0.0;
    float sumWeight = 0.0;

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;

        int canonicalIndex = SHARED_GetFibonacciCanonicalIndex(
            i,
            tapCount,
            SHARED_LENS55_TAP_COUNT,
            SPIRIT_ReductionMode,
            0,
            SHARED_LENS55_TAP_COUNT);

        float tapNorm = (tapCount > 1) ? (float(canonicalIndex) / max(1.0, float(tapCount - 1))) : 0.0;
        float radial = (canonicalIndex == 0) ? 0.0 : sqrt(saturate(tapNorm));
        float2 offset = SHARED_GoldenDirection(SPIRIT_FibonacciAnchor + float(canonicalIndex)) * (0.18 + 0.82 * radial);
        offset = SPIRIT_RotateField(offset * SPIRIT_LensFieldScale);

        float fibIndex = SPIRIT_FibonacciAnchor + float(canonicalIndex);
        float2 direction = normalize(float2(0.23 - offset.y, 0.17 + offset.x + frac(fibIndex * 0.000618)));
        float phase = fibIndex * 0.013 + dot(uv * 128.0, float2(0.754, 0.569));
        float hatch = SPIRIT_HatchLine(p + offset * SPIRIT_CoarseTapSpread, direction, phase, SPIRIT_CoarseDensity, 0.62, 0.94);
        sumValue += hatch;
        sumWeight += 1.0;
    }

    float mask = sumValue / max(0.00001, sumWeight);
    float centered = abs(mask - 0.5) * 2.0;
    float centeredContrast = 0.65 + SPIRIT_CoarseCenterContrast * 1.85 + localContrast * 0.35;
    return saturate(pow(abs(centered), max(0.10, centeredContrast)));
}

float SPIRIT_CoarsePattern(float2 uv, float3 sourceColor, float depth)
{
    float contrast = saturate(SHARED_LocalContrast(uv, sourceColor) * 2.0);
    float centeredFib = SPIRIT_CenteredFibonacciPattern(uv, contrast);
    float stage = SPIRIT_FiveStagePattern(uv, depth, contrast);
    return saturate(lerp(centeredFib, max(centeredFib, stage), SPIRIT_CoarseStageBlend));
}

float SPIRIT_FogEvidence(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = SPIRIT_DepthConfidence(uv);
    float depth = SPIRIT_Depth(uv);
    float depthBias = smoothstep(max(SPIRIT_DepthStart, 0.08), max(SPIRIT_FarDetailStart, 0.35), depth);
    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(SPIRIT_FogBrightnessFloor, SPIRIT_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(SPIRIT_FogDesaturation, min(1.0, SPIRIT_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(SPIRIT_FogLowContrast, max(SPIRIT_FogLowContrast + 0.01, SPIRIT_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(SPIRIT_LineThreshold, SPIRIT_LineThreshold * 4.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(SPIRIT_LightThreshold, SPIRIT_LightThreshold + SPIRIT_LightSoftness, luma);
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);
    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float SPIRIT_LightShield(float3 source)
{
    float luma = SHARED_Luma(source);
    float maxv = max(source.r, max(source.g, source.b));
    float minv = min(source.r, min(source.g, source.b));
    float sat = (maxv <= 0.00001) ? 0.0 : ((maxv - minv) / maxv);
    float satMask = smoothstep(0.22, 1.0, sat);
    float lumaMask = smoothstep(SPIRIT_LightThreshold, SPIRIT_LightThreshold + SPIRIT_LightSoftness, luma);
    float peakMask = smoothstep(SPIRIT_LightThreshold, SPIRIT_LightThreshold + SPIRIT_LightSoftness, maxv);
    return saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
}

float SPIRIT_DepthWindow(float2 uv)
{
    float availability = SPIRIT_DepthConfidence(uv);
    float depth = SPIRIT_Depth(uv);
    float d0 = min(SPIRIT_DepthStart, SPIRIT_DepthEnd);
    float d1 = max(SPIRIT_DepthStart, SPIRIT_DepthEnd);
    float soft = 0.01;
    float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
    float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
    return saturate(beginMask * endMask * availability);
}

float SPIRIT_FarDetail(float2 uv, float3 source)
{
    float depthValid = SPIRIT_DepthConfidence(uv);
    float depth = SPIRIT_Depth(uv);
    float farMask = smoothstep(SPIRIT_FarDetailStart, SPIRIT_FarDetailEnd, depth);
    float detailMask = smoothstep(SPIRIT_ContrastThreshold, SPIRIT_ContrastThreshold * max(1.25, SPIRIT_ContrastGain), SHARED_LocalContrast(uv, source) * SPIRIT_ContrastGain);
    return saturate(depthValid * farMask * detailMask);
}

float SPIRIT_ContrastMask(float2 uv, float3 source)
{
    float contrast = SHARED_LocalContrast(uv, source);
    return smoothstep(SPIRIT_ContrastThreshold, SPIRIT_ContrastThreshold * max(1.25, SPIRIT_ContrastGain), contrast * SPIRIT_ContrastGain);
}

float SPIRIT_MaskGate(float2 uv, float3 source)
{
    if (SPIRIT_MaskMode == SPIRIT_MASK_OFF)
        return 1.0;
    if (SPIRIT_MaskMode == SPIRIT_MASK_FOG)
        return SPIRIT_FogEvidence(uv, source);
    if (SPIRIT_MaskMode == SPIRIT_MASK_LIGHT)
        return SPIRIT_LightShield(source);
    if (SPIRIT_MaskMode == SPIRIT_MASK_DEPTH)
        return SPIRIT_DepthWindow(uv);
    if (SPIRIT_MaskMode == SPIRIT_MASK_FAR_DETAIL)
        return SPIRIT_FarDetail(uv, source);
    if (SPIRIT_MaskMode == SPIRIT_MASK_CONTRAST)
        return SPIRIT_ContrastMask(uv, source);

    float fog = SPIRIT_FogEvidence(uv, source);
    float light = SPIRIT_LightShield(source);
    float depth = SPIRIT_DepthWindow(uv);
    float farDetail = SPIRIT_FarDetail(uv, source);
    float contrast = SPIRIT_ContrastMask(uv, source);
    return saturate(max(max(fog, light), max(farDetail, contrast)) * depth);
}

float3 SPIRIT_LocalSupport(float2 uv, float radiusPixels)
{
    float2 px = SHARED_PixelSize() * radiusPixels;
    float3 c = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    float3 r = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(px.x, 0.0)), 0.0, 0.0)).rgb;
    float3 l = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(px.x, 0.0)), 0.0, 0.0)).rgb;
    float3 u = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, px.y)), 0.0, 0.0)).rgb;
    float3 d = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(0.0, px.y)), 0.0, 0.0)).rgb;
    return (c + r + l + u + d) / 5.0;
}

float3 SPIRIT_ChromaSafeDetail(float3 detailColor, float stability)
{
    float detailLuma = dot(detailColor, float3(0.2126, 0.7152, 0.0722));
    float3 lumaOnly = detailLuma.xxx;
    float3 safe = lerp(detailColor, lumaOnly, saturate(SPIRIT_SuperfineChromaSafety * stability));
    return clamp(safe, -SPIRIT_SuperfineClamp, SPIRIT_SuperfineClamp);
}

float3 SPIRIT_BasePass(float2 uv, float3 sourceColor, float depthGate, float edgeField)
{
    float3 supportColor = SPIRIT_LensAverage(uv);
    float3 celColor = SPIRIT_CelColor(supportColor);
    float3 shadedColor = lerp(sourceColor, celColor, saturate(SPIRIT_BaseStrength * SPIRIT_MasterIntensity * depthGate));
    return lerp(shadedColor, float3(0.0, 0.0, 0.0), saturate(edgeField * SPIRIT_BaseEdgeStrength * SPIRIT_MasterIntensity * depthGate));
}

float3 SPIRIT_CoarsePass(float2 uv, float3 sourceColor, float3 inputColor, float depthGate, float maskGate)
{
    float luma = SPIRIT_Luma(sourceColor);
    float coarsePattern = SPIRIT_CoarsePattern(uv, sourceColor, SPIRIT_Depth(uv));
    float coarseMask = SPIRIT_ToneShadowMask(luma) * depthGate * maskGate;
    float ink = coarsePattern * coarseMask * SPIRIT_CoarseStrength * SPIRIT_MasterIntensity;
    return saturate(inputColor * (1.0 - ink * 0.85));
}

float3 SPIRIT_SuperfinePass(float2 uv, float3 sourceColor, float3 inputColor, float depthGate, float edgeField, float maskGate)
{
    float3 organicSupport = SPIRIT_LensAverage(uv);
    float3 localDetail = sourceColor - SPIRIT_LocalSupport(uv, SPIRIT_SuperfineRadius);
    float3 organicDetail = sourceColor - organicSupport;
    float detailMask = saturate((length(localDetail) + length(organicDetail)) * 4.0 + edgeField * 0.50);
    float3 detailColor = localDetail * 1.10 + organicDetail * 0.65;
    detailColor = SPIRIT_ChromaSafeDetail(detailColor, depthGate * edgeField);
    return saturate(inputColor + detailColor * detailMask * SPIRIT_SuperfineStrength * SPIRIT_MasterIntensity * depthGate * maskGate);
}

float SPIRIT_CoarseContribution(float2 uv, float3 sourceColor, float depthGate, float maskGate)
{
    float luma = SPIRIT_Luma(sourceColor);
    float coarsePattern = SPIRIT_CoarsePattern(uv, sourceColor, SPIRIT_Depth(uv));
    float coarseMask = SPIRIT_ToneShadowMask(luma) * depthGate * maskGate;
    return saturate(coarsePattern * coarseMask * SPIRIT_CoarseStrength * SPIRIT_MasterIntensity);
}

float3 SPIRIT_SuperfineContribution(float2 uv, float3 sourceColor, float depthGate, float edgeField, float maskGate)
{
    float3 organicSupport = SPIRIT_LensAverage(uv);
    float3 localDetail = sourceColor - SPIRIT_LocalSupport(uv, SPIRIT_SuperfineRadius);
    float3 organicDetail = sourceColor - organicSupport;
    float detailMask = saturate((length(localDetail) + length(organicDetail)) * 4.0 + edgeField * 0.50);
    float3 detailColor = localDetail * 1.10 + organicDetail * 0.65;
    detailColor = SPIRIT_ChromaSafeDetail(detailColor, depthGate * edgeField);
    return detailColor * detailMask * SPIRIT_SuperfineStrength * SPIRIT_MasterIntensity * depthGate * maskGate;
}

float4 SPIRIT_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    if (SPIRIT_Enable == 0)
        return float4(sourceColor, 1.0);

    float centerDepth = SPIRIT_Depth(uv);
    float depthGate = SPIRIT_DepthGate(uv, centerDepth);
    float edgeField = SPIRIT_EdgeField(uv);
    float rawMaskGate = saturate(SPIRIT_MaskGate(uv, sourceColor) * SPIRIT_MaskStrength);
    float maskGate = lerp(1.0, rawMaskGate, SPIRIT_MaskInfluence);

    float3 basePass = sourceColor;
    if (SPIRIT_EnableBase != 0)
        basePass = SPIRIT_BasePass(uv, sourceColor, depthGate, edgeField);

    float3 coarsePass = basePass;
    if (SPIRIT_EnableCoarse != 0)
        coarsePass = SPIRIT_CoarsePass(uv, sourceColor, basePass, depthGate, maskGate);

    float3 superfinePass = coarsePass;
    if (SPIRIT_EnableSuperfine != 0)
        superfinePass = SPIRIT_SuperfinePass(uv, sourceColor, coarsePass, depthGate, edgeField, maskGate);

    if (SPIRIT_DebugView == 1) return float4(saturate(basePass), 1.0);
    if (SPIRIT_DebugView == 2) return float4(SPIRIT_DebugShape3(SPIRIT_CoarseContribution(uv, sourceColor, depthGate, maskGate).xxx), 1.0);
    if (SPIRIT_DebugView == 3) return float4(SPIRIT_DebugShape3(SPIRIT_SuperfineContribution(uv, sourceColor, depthGate, edgeField, maskGate) * 4.0 + 0.5), 1.0);
    if (SPIRIT_DebugView == 4) return float4(SPIRIT_DebugShape3((edgeField).xxx), 1.0);
    if (SPIRIT_DebugView == 5) return float4(SPIRIT_DebugShape3((depthGate).xxx), 1.0);
    if (SPIRIT_DebugView == 6) return float4(SPIRIT_DebugShape3((maskGate).xxx), 1.0);
    return float4(saturate(superfinePass), 1.0);
}

#endif
