#ifndef black_wand_SAMPLER_SERVER_FXH
#define black_wand_SAMPLER_SERVER_FXH

#include "black_wand_Lens_Adapter.fxh"
#include "black_wand_Depth_Adapter.fxh"
#include "black_wand_Weight_Server.fxh"
#include "black_wand_Gate_Server.fxh"
#include "black_wand_Reduce_Server.fxh"

struct black_wand_SampleStats
{
    float3 centerColor;
    float centerDepth;
    float3 averageColor;
    float3 minColor;
    float3 maxColor;
    float lumaAverage;
    float lumaMin;
    float lumaMax;
    float lumaVariance;
    float maxDelta;
    float weightSum;
    float gateSum;
    float acceptedCount;
    float rejectedCount;
    float activeCount;
    float depthAvailable;
};

black_wand_SampleStats black_wand_Sampler_Collect(
    float2 uv,
    int lensMode,
    int requestedTapCount,
    int activeTapWiring,
    int reductionMode,
    float radiusPixels,
    float rotationDegrees,
    int weightMode,
    float centerWeight,
    float falloffPower,
    int gateMode,
    int depthMissingMode,
    int depthMode,
    int depthInvert,
    float depthTraceScale,
    float depthAvailabilityThreshold,
    float depthRejectThreshold,
    float depthRejectSoftness,
    float farStart,
    float farFeather,
    float nearEnd,
    float nearFeather)
{
    black_wand_SampleStats stats;
    stats.centerColor = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
    stats.centerDepth = black_wand_Depth_Linear(uv, depthMode, depthInvert);
    stats.averageColor = 0.0.xxx;
    stats.minColor = 1.0.xxx;
    stats.maxColor = 0.0.xxx;
    stats.lumaAverage = 0.0;
    stats.lumaMin = 1.0;
    stats.lumaMax = 0.0;
    stats.lumaVariance = 0.0;
    stats.maxDelta = 0.0;
    stats.weightSum = 0.0;
    stats.gateSum = 0.0;
    stats.acceptedCount = 0.0;
    stats.rejectedCount = 0.0;
    stats.depthAvailable = 0.0;

    int activeTapCount = clamp(black_wand_Lens_ActiveTapCount(lensMode, requestedTapCount, activeTapWiring), 0, black_wand_LENS_MAX_TAPS);
    stats.activeCount = float(activeTapCount);

    float depthAvailable = black_wand_Depth_Available(uv, depthMode, depthInvert, depthTraceScale, depthAvailabilityThreshold);
    stats.depthAvailable = depthAvailable;
    float lumaMoment = 0.0;

    [loop]
    for (int i = 0; i < activeTapCount; ++i)
    {
        int canonicalIndex = black_wand_Lens_CanonicalIndex(lensMode, i, activeTapCount, reductionMode);
        float2 canonicalOffset = black_wand_Lens_CanonicalOffset(lensMode, canonicalIndex);
        float2 sampleUV = black_wand_Lens_UV(uv, lensMode, i, activeTapCount, reductionMode, radiusPixels, rotationDegrees);
        float3 sampleColor = tex2Dlod(ReShade::BackBuffer, float4(saturate(sampleUV), 0.0, 0.0)).rgb;
        float sampleDepth = black_wand_Depth_Linear(sampleUV, depthMode, depthInvert);
        float sampleGate = black_wand_Gate_DepthSampleEx(gateMode, stats.centerDepth, sampleDepth, depthAvailable, depthRejectThreshold, depthRejectSoftness, farStart, farFeather, nearEnd, nearFeather, depthMissingMode);
        float baseSampleWeight = black_wand_Weight_Evaluate(weightMode, canonicalOffset, i, activeTapCount, centerWeight, falloffPower);
        float sampleWeight = baseSampleWeight * sampleGate;
        float sampleLuma = black_wand_Reduce_Luma(sampleColor);
        float centerLuma = black_wand_Reduce_Luma(stats.centerColor);

        stats.averageColor += sampleColor * sampleWeight;
        stats.lumaAverage += sampleLuma * sampleWeight;
        lumaMoment += sampleLuma * sampleLuma * sampleWeight;
        stats.minColor = min(stats.minColor, sampleColor);
        stats.maxColor = max(stats.maxColor, sampleColor);
        stats.lumaMin = min(stats.lumaMin, sampleLuma);
        stats.lumaMax = max(stats.lumaMax, sampleLuma);
        stats.maxDelta = max(stats.maxDelta, abs(centerLuma - sampleLuma));
        stats.weightSum += sampleWeight;
        stats.gateSum += sampleGate;
        stats.acceptedCount += step(0.0001, sampleGate);
        stats.rejectedCount += 1.0 - step(0.0001, sampleGate);
    }

    float safeWeight = max(0.0001, stats.weightSum);
    stats.averageColor /= safeWeight;
    stats.lumaAverage /= safeWeight;
    lumaMoment /= safeWeight;
    stats.lumaVariance = black_wand_Reduce_VarianceFromMoments(stats.lumaAverage, lumaMoment);

    if (activeTapCount <= 0)
    {
        stats.averageColor = stats.centerColor;
        stats.lumaAverage = black_wand_Reduce_Luma(stats.centerColor);
        stats.lumaMin = stats.lumaAverage;
        stats.lumaMax = stats.lumaAverage;
        stats.weightSum = 1.0;
        stats.gateSum = 1.0;
        stats.acceptedCount = 1.0;
        stats.rejectedCount = 0.0;
    }

    return stats;
}

#endif
