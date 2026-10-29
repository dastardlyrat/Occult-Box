/*
    black_wand_DO_LumaFallback.fxh
    Luma surrogate fallback primitives for Depth Oracle v0.9.

    Boundary:
    - This does not create a true depth buffer.
    - This does not override working official depth by default.
    - Luma is used as a diagnostic/surrogate occlusion-detail layer when forced or when depth confidence fails.
    - Original project code synthesized from project design patterns; no source shader text is copied.
*/
#ifndef BLACK_WAND_DO_LUMA_FALLBACK_FXH
#define BLACK_WAND_DO_LUMA_FALLBACK_FXH

float black_wand_DO_SourceLumaAt(float2 uv)
{
    return black_wand_DO_Luma(tex2Dlod(ReShade::BackBuffer, float4((uv), 0.0, 0.0)).rgb);
}

float black_wand_DO_LumaMean9(float2 uv, float radiusPixels)
{
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c  = black_wand_DO_SourceLumaAt(uv);
    float e  = black_wand_DO_SourceLumaAt(uv + float2(s.x, 0.0));
    float w  = black_wand_DO_SourceLumaAt(uv - float2(s.x, 0.0));
    float n  = black_wand_DO_SourceLumaAt(uv - float2(0.0, s.y));
    float so = black_wand_DO_SourceLumaAt(uv + float2(0.0, s.y));
    float ne = black_wand_DO_SourceLumaAt(uv + float2(s.x, -s.y));
    float nw = black_wand_DO_SourceLumaAt(uv + float2(-s.x, -s.y));
    float se = black_wand_DO_SourceLumaAt(uv + float2(s.x, s.y));
    float sw = black_wand_DO_SourceLumaAt(uv + float2(-s.x, s.y));
    return (c + e + w + n + so + ne + nw + se + sw) * 0.11111111;
}

float black_wand_DO_LumaRange9(float2 uv, float radiusPixels)
{
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c  = black_wand_DO_SourceLumaAt(uv);
    float e  = black_wand_DO_SourceLumaAt(uv + float2(s.x, 0.0));
    float w  = black_wand_DO_SourceLumaAt(uv - float2(s.x, 0.0));
    float n  = black_wand_DO_SourceLumaAt(uv - float2(0.0, s.y));
    float so = black_wand_DO_SourceLumaAt(uv + float2(0.0, s.y));
    float ne = black_wand_DO_SourceLumaAt(uv + float2(s.x, -s.y));
    float nw = black_wand_DO_SourceLumaAt(uv + float2(-s.x, -s.y));
    float se = black_wand_DO_SourceLumaAt(uv + float2(s.x, s.y));
    float sw = black_wand_DO_SourceLumaAt(uv + float2(-s.x, s.y));
    float minV = min(c, min(min(e, w), min(min(n, so), min(min(ne, nw), min(se, sw)))));
    float maxV = max(c, max(max(e, w), max(max(n, so), max(max(ne, nw), max(se, sw)))));
    return max(maxV - minV, 0.0);
}

float black_wand_DO_LumaDeviation9(float2 uv, float radiusPixels)
{
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c  = black_wand_DO_SourceLumaAt(uv);
    float e  = black_wand_DO_SourceLumaAt(uv + float2(s.x, 0.0));
    float w  = black_wand_DO_SourceLumaAt(uv - float2(s.x, 0.0));
    float n  = black_wand_DO_SourceLumaAt(uv - float2(0.0, s.y));
    float so = black_wand_DO_SourceLumaAt(uv + float2(0.0, s.y));
    float ne = black_wand_DO_SourceLumaAt(uv + float2(s.x, -s.y));
    float nw = black_wand_DO_SourceLumaAt(uv + float2(-s.x, -s.y));
    float se = black_wand_DO_SourceLumaAt(uv + float2(s.x, s.y));
    float sw = black_wand_DO_SourceLumaAt(uv + float2(-s.x, s.y));
    float mean = (c + e + w + n + so + ne + nw + se + sw) * 0.11111111;
    return (abs(c - mean) + abs(e - mean) + abs(w - mean) + abs(n - mean) + abs(so - mean) + abs(ne - mean) + abs(nw - mean) + abs(se - mean) + abs(sw - mean)) * 0.11111111;
}

float black_wand_DO_LumaContrastScore(float2 uv, float radiusPixels, float contrastGain)
{
    float rangeScore = black_wand_DO_LumaRange9(uv, radiusPixels);
    float deviationScore = black_wand_DO_LumaDeviation9(uv, radiusPixels);
    return saturate((rangeScore * 0.55 + deviationScore * 0.45) * max(contrastGain, 0.0));
}

float black_wand_DO_LumaFallbackAORaw(float2 uv, float radiusPixels, float contrastGain, float toneGain)
{
    float c = black_wand_DO_SourceLumaAt(uv);
    float mean = black_wand_DO_LumaMean9(uv, radiusPixels);
    float contrast = black_wand_DO_LumaContrastScore(uv, radiusPixels, contrastGain);
    float darkAgainstNeighborhood = saturate((mean - c) * max(toneGain, 0.0));
    float darkTone = saturate((1.0 - c) * 0.65);
    return saturate(max(darkAgainstNeighborhood, contrast * 0.65) * 0.80 + darkTone * contrast * 0.20);
}

float black_wand_DO_LumaSurrogateDepthScalar(float2 uv, float radiusPixels, float contrastGain, bool brightIsNear, float gammaValue, float contrastMix)
{
    float l = black_wand_DO_SourceLumaAt(uv);
    float tone = brightIsNear ? l : (1.0 - l);
    tone = pow(saturate(tone), 1.0 / max(gammaValue, 0.0001));
    float contrast = black_wand_DO_LumaContrastScore(uv, radiusPixels, contrastGain);
    return saturate(lerp(tone, contrast, saturate(contrastMix)));
}

float black_wand_DO_OfficialDepthActivityScore(float2 uv, float activityGain)
{
    float2 s = black_wand_DO_PixelStep(1.0);
    float c = black_wand_DO_OfficialDepthAt(uv);
    float e = black_wand_DO_OfficialDepthAt(uv + float2(s.x, 0.0));
    float w = black_wand_DO_OfficialDepthAt(uv - float2(s.x, 0.0));
    float n = black_wand_DO_OfficialDepthAt(uv - float2(0.0, s.y));
    float so = black_wand_DO_OfficialDepthAt(uv + float2(0.0, s.y));
    float local = (abs(c - e) + abs(c - w) + abs(c - n) + abs(c - so)) * 0.25;
    return saturate(local * max(activityGain, 0.0));
}

float black_wand_DO_DepthReliabilityForFallback(float2 uv, float endpointMargin, float activityGain)
{
    float raw = black_wand_DO_RawDepthAt(uv);
    float official = black_wand_DO_OfficialDepthAt(uv);
    float rawInterior = black_wand_DO_InteriorDepth(raw, endpointMargin);
    float officialInterior = black_wand_DO_InteriorDepth(official, endpointMargin);
    float activity = black_wand_DO_OfficialDepthActivityScore(uv, activityGain);
    return saturate(max(max(rawInterior, officialInterior), activity));
}

float black_wand_DO_LumaFallbackActivation(float2 uv, int mode, float radiusPixels, float contrastGain, float toneGain, float endpointMargin, float activityGain, float depthThreshold, float lumaThreshold)
{
    float active = 0.0;

    if (mode == 3)
    {
        active = 1.0;
    }
    else if (mode != 0)
    {
        float depthReliability = black_wand_DO_DepthReliabilityForFallback(uv, endpointMargin, activityGain);
        float lumaReady = smoothstep(lumaThreshold, lumaThreshold + 0.250, black_wand_DO_LumaContrastScore(uv, radiusPixels, contrastGain));
        float missing = 1.0 - smoothstep(depthThreshold, depthThreshold + 0.250, depthReliability);

        if (mode == 1)
        {
            active = missing * lumaReady;
        }
        else if (mode == 2)
        {
            active = (1.0 - depthReliability) * lumaReady;
        }
    }

    return saturate(active);
}

float3 black_wand_DO_LumaLocalContrastView(float2 uv, float radiusPixels, float contrastGain)
{
    float c = black_wand_DO_LumaContrastScore(uv, radiusPixels, contrastGain);
    float l = black_wand_DO_SourceLumaAt(uv);
    float rangeV = black_wand_DO_LumaRange9(uv, radiusPixels);
    return saturate(float3(c, rangeV * max(contrastGain, 0.0), l));
}

float3 black_wand_DO_LumaSurrogateDepthView(float2 uv, float radiusPixels, float contrastGain, bool brightIsNear, float surrogateGamma, float contrastMix, float blackPoint, float whitePoint, float displayGamma, float displayContrast, float displayExposure, bool displayInvert, bool liftDark, float floorValue)
{
    float d = black_wand_DO_LumaSurrogateDepthScalar(uv, radiusPixels, contrastGain, brightIsNear, surrogateGamma, contrastMix);
    return black_wand_DO_ShapeGray(d, blackPoint, whitePoint, displayGamma, displayContrast, displayExposure, displayInvert, liftDark, floorValue);
}

float3 black_wand_DO_LumaFallbackActiveView(float2 uv, int mode, float radiusPixels, float contrastGain, float toneGain, float endpointMargin, float activityGain, float depthThreshold, float lumaThreshold)
{
    float active = black_wand_DO_LumaFallbackActivation(uv, mode, radiusPixels, contrastGain, toneGain, endpointMargin, activityGain, depthThreshold, lumaThreshold);
    float ao = black_wand_DO_LumaFallbackAORaw(uv, radiusPixels, contrastGain, toneGain);
    float confidence = black_wand_DO_DepthReliabilityForFallback(uv, endpointMargin, activityGain);
    return saturate(float3(active, confidence, ao));
}

float3 black_wand_DO_OfficialLumaHybridConfidenceView(float2 uv, int mode, float radiusPixels, float contrastGain, float toneGain, float endpointMargin, float activityGain, float depthThreshold, float lumaThreshold)
{
    float active = black_wand_DO_LumaFallbackActivation(uv, mode, radiusPixels, contrastGain, toneGain, endpointMargin, activityGain, depthThreshold, lumaThreshold);
    float confidence = black_wand_DO_DepthReliabilityForFallback(uv, endpointMargin, activityGain);
    float lumaReady = smoothstep(lumaThreshold, lumaThreshold + 0.250, black_wand_DO_LumaContrastScore(uv, radiusPixels, contrastGain));
    return saturate(float3(active, confidence, lumaReady));
}

float3 black_wand_DO_DepthMissingPolicyBars(float2 uv, int mode, float radiusPixels, float contrastGain, float toneGain, float endpointMargin, float activityGain, float depthThreshold, float lumaThreshold)
{
    float confidence = black_wand_DO_DepthReliabilityForFallback(uv, endpointMargin, activityGain);
    float lumaReady = smoothstep(lumaThreshold, lumaThreshold + 0.250, black_wand_DO_LumaContrastScore(uv, radiusPixels, contrastGain));
    float active = black_wand_DO_LumaFallbackActivation(uv, mode, radiusPixels, contrastGain, toneGain, endpointMargin, activityGain, depthThreshold, lumaThreshold);
    return black_wand_DO_Bars(uv, float3(confidence, lumaReady, active));
}

float3 black_wand_DO_LumaFallbackOverlay(float3 source, float2 uv, int mode, float radiusPixels, float contrastGain, float toneGain, float fallbackStrength, float endpointMargin, float activityGain, float depthThreshold, float lumaThreshold)
{
    float active = black_wand_DO_LumaFallbackActivation(uv, mode, radiusPixels, contrastGain, toneGain, endpointMargin, activityGain, depthThreshold, lumaThreshold);
    float ao = black_wand_DO_LumaFallbackAORaw(uv, radiusPixels, contrastGain, toneGain);
    float amount = saturate(active * ao * fallbackStrength);
    float3 shaded = source * (1.0 - amount);
    float3 marker = lerp(shaded, float3(1.0, 0.74, 0.18), active * 0.20);
    return saturate(marker);
}

float black_wand_DO_LumaRMDeltaScore(float2 uv, float2 dirPixels, float gain)
{
    float2 stepUV = dirPixels * BUFFER_PIXEL_SIZE;
    float l0 = black_wand_DO_SourceLumaAt(uv);
    float l1 = black_wand_DO_SourceLumaAt(uv + stepUV * 1.0);
    float l2 = black_wand_DO_SourceLumaAt(uv + stepUV * 2.0);
    float l3 = black_wand_DO_SourceLumaAt(uv + stepUV * 3.0);
    float l4 = black_wand_DO_SourceLumaAt(uv + stepUV * 4.0);
    float a = abs(l0 - l1);
    float b = abs(l1 - l2);
    float c = abs(l2 - l3);
    float d = abs(l3 - l4);
    float meanDelta = (a + b + c + d) * 0.25;
    float maxDelta = max(max(a, b), max(c, d));
    return (meanDelta * 0.70 + maxDelta * 0.30) * max(gain, 0.0);
}

float3 black_wand_DO_LumaRMSupportView(float2 uv, float2 dirPixels, float gain, float thresholdValue, float softnessValue, float midCenter, float midWidth)
{
    float score = black_wand_DO_LumaRMDeltaScore(uv, dirPixels, gain);
    float breakMask = black_wand_DO_SoftCoverageFromScore(score, thresholdValue, softnessValue);
    float continuity = 1.0 - breakMask;
    float mid = black_wand_DO_MidCoverageMask(breakMask, midCenter, midWidth);
    return saturate(float3(continuity, breakMask, mid));
}

#endif
