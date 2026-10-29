#ifndef black_wand_GATE_SERVER_FXH
#define black_wand_GATE_SERVER_FXH

#include "black_wand_Depth_Adapter.fxh"

#ifndef black_wand_GATE_NONE
#define black_wand_GATE_NONE 0
#endif
#ifndef black_wand_GATE_DEPTH_REJECT
#define black_wand_GATE_DEPTH_REJECT 1
#endif
#ifndef black_wand_GATE_DEPTH_WEIGHTED
#define black_wand_GATE_DEPTH_WEIGHTED 2
#endif
#ifndef black_wand_GATE_FAR_ONLY
#define black_wand_GATE_FAR_ONLY 3
#endif
#ifndef black_wand_GATE_NEAR_SUPPRESS
#define black_wand_GATE_NEAR_SUPPRESS 4
#endif
#ifndef black_wand_GATE_DEPTH_MISSING_REJECT
#define black_wand_GATE_DEPTH_MISSING_REJECT 0
#endif
#ifndef black_wand_GATE_DEPTH_MISSING_PASS
#define black_wand_GATE_DEPTH_MISSING_PASS 1
#endif

float black_wand_Gate_DepthMissingFallback(int depthMissingMode)
{
    if (depthMissingMode == black_wand_GATE_DEPTH_MISSING_PASS)
    {
        return 1.0;
    }

    return 0.0;
}

float black_wand_Gate_SameLayerHard(float centerDepth, float sampleDepth, float rejectThreshold)
{
    float depthDelta = abs(centerDepth - sampleDepth);
    return 1.0 - step(max(0.000001, rejectThreshold), depthDelta);
}

float black_wand_Gate_SameLayerSoft(float centerDepth, float sampleDepth, float rejectThreshold, float rejectSoftness)
{
    return black_wand_Depth_SampleSameLayerWeight(centerDepth, sampleDepth, rejectThreshold, rejectSoftness);
}

float black_wand_Gate_DepthSampleEx(
    int gateMode,
    float centerDepth,
    float sampleDepth,
    float depthAvailable,
    float rejectThreshold,
    float rejectSoftness,
    float farStart,
    float farFeather,
    float nearEnd,
    float nearFeather,
    int depthMissingMode)
{
    if (gateMode == black_wand_GATE_NONE)
    {
        return 1.0;
    }

    float depthAvailableSafe = saturate(depthAvailable);

    if (depthAvailableSafe <= 0.0001)
    {
        return black_wand_Gate_DepthMissingFallback(depthMissingMode);
    }

    float sameLayerHard = black_wand_Gate_SameLayerHard(centerDepth, sampleDepth, rejectThreshold);
    float sameLayerSoft = black_wand_Gate_SameLayerSoft(centerDepth, sampleDepth, rejectThreshold, rejectSoftness);
    float farMask = black_wand_Depth_FarMask(centerDepth, farStart, farFeather);
    float nearMask = black_wand_Depth_NearMask(centerDepth, nearEnd, nearFeather);

    if (gateMode == black_wand_GATE_DEPTH_REJECT)
    {
        return sameLayerHard;
    }

    if (gateMode == black_wand_GATE_DEPTH_WEIGHTED)
    {
        return sameLayerSoft;
    }

    if (gateMode == black_wand_GATE_FAR_ONLY)
    {
        return farMask * sameLayerSoft;
    }

    if (gateMode == black_wand_GATE_NEAR_SUPPRESS)
    {
        return (1.0 - nearMask) * sameLayerSoft;
    }

    return 1.0;
}

float black_wand_Gate_DepthSample(
    int gateMode,
    float centerDepth,
    float sampleDepth,
    float depthAvailable,
    float rejectThreshold,
    float rejectSoftness,
    float farStart,
    float farFeather,
    float nearEnd,
    float nearFeather)
{
    return black_wand_Gate_DepthSampleEx(
        gateMode,
        centerDepth,
        sampleDepth,
        depthAvailable,
        rejectThreshold,
        rejectSoftness,
        farStart,
        farFeather,
        nearEnd,
        nearFeather,
        black_wand_GATE_DEPTH_MISSING_REJECT);
}

#endif
