/*
    black_wand_DO_RMProbe.fxh
    Fixed-step screen-space probe with v0.8 mid-coverage shaping. This is not a default depth normalizer; it is a diagnostic
    continuity probe for RM-SSR preflight. It is deliberately unrolled and shallow.
*/
#ifndef BLACK_WAND_DO_RMPROBE_FXH
#define BLACK_WAND_DO_RMPROBE_FXH

float black_wand_DO_DepthDelta(float a, float b, float tolerance)
{
    return saturate(abs(a - b) / max(tolerance, 0.000001));
}

float3 black_wand_DO_RMProbeOfficial(float2 uv, float2 dirPixels, float tolerance)
{
    float2 stepUV = dirPixels * BUFFER_PIXEL_SIZE;
    float d0 = black_wand_DO_OfficialDepthAt(uv);
    float d1 = black_wand_DO_OfficialDepthAt(uv + stepUV * 1.0);
    float d2 = black_wand_DO_OfficialDepthAt(uv + stepUV * 2.0);
    float d3 = black_wand_DO_OfficialDepthAt(uv + stepUV * 3.0);
    float d4 = black_wand_DO_OfficialDepthAt(uv + stepUV * 4.0);

    float c1 = black_wand_DO_DepthDelta(d0, d1, tolerance);
    float c2 = black_wand_DO_DepthDelta(d1, d2, tolerance);
    float c3 = black_wand_DO_DepthDelta(d2, d3, tolerance);
    float c4 = black_wand_DO_DepthDelta(d3, d4, tolerance);
    float continuity = 1.0 - saturate((c1 + c2 + c3 + c4) * 0.25);
    float firstBreak = max(max(c1, c2), max(c3, c4));
    float depthMean = saturate((d0 + d1 + d2 + d3 + d4) * 0.2);
    return float3(continuity, firstBreak, depthMean);
}


float black_wand_DO_RawDepthDeltaScore(float2 uv, float2 dirPixels, float gain)
{
    float2 stepUV = dirPixels * BUFFER_PIXEL_SIZE;
    float d0 = black_wand_DO_OfficialDepthAt(uv);
    float d1 = black_wand_DO_OfficialDepthAt(uv + stepUV * 1.0);
    float d2 = black_wand_DO_OfficialDepthAt(uv + stepUV * 2.0);
    float d3 = black_wand_DO_OfficialDepthAt(uv + stepUV * 3.0);
    float d4 = black_wand_DO_OfficialDepthAt(uv + stepUV * 4.0);
    float a = abs(d0 - d1);
    float b = abs(d1 - d2);
    float c = abs(d2 - d3);
    float d = abs(d3 - d4);
    float meanDelta = (a + b + c + d) * 0.25;
    float maxDelta = max(max(a, b), max(c, d));
    return (meanDelta * 0.70 + maxDelta * 0.30) * max(gain, 0.0);
}

float3 black_wand_DO_RMProbeOfficialShaped(float2 uv, float2 dirPixels, float gain, float thresholdValue, float softnessValue, float midCenter, float midWidth)
{
    float score = black_wand_DO_RawDepthDeltaScore(uv, dirPixels, gain);
    float breakMask = black_wand_DO_SoftCoverageFromScore(score, thresholdValue, softnessValue);
    float continuity = 1.0 - breakMask;
    float mid = black_wand_DO_MidCoverageMask(breakMask, midCenter, midWidth);
    return saturate(float3(continuity, breakMask, mid));
}


#endif
