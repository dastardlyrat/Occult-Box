#ifndef black_wand_DEPTH_ADAPTER_FXH
#define black_wand_DEPTH_ADAPTER_FXH

// Additive Book of Life depth adapter. Wraps shared depth primitives with explicit parameters.
#include "miXSR_shared_depth.fxh"

#ifndef black_wand_DEPTH_MODE_LINEARIZED
#define black_wand_DEPTH_MODE_LINEARIZED 0
#endif
#ifndef black_wand_DEPTH_MODE_RAW
#define black_wand_DEPTH_MODE_RAW 1
#endif
#ifndef black_wand_DEPTH_MODE_RAW_INVERTED
#define black_wand_DEPTH_MODE_RAW_INVERTED 2
#endif

float black_wand_Depth_Raw(float2 uv)
{
    return tex2Dlod(ReShade::DepthBuffer, float4(saturate(uv), 0.0, 0.0)).r;
}

float black_wand_Depth_Linear(float2 uv, int depthMode, int depthInvert)
{
    float rawDepth = black_wand_Depth_Raw(uv);
    float depthValue = saturate(rawDepth);

    if (depthMode == black_wand_DEPTH_MODE_RAW_INVERTED)
    {
        depthValue = saturate(1.0 - rawDepth);
    }

    if (depthInvert != 0)
    {
        depthValue = 1.0 - depthValue;
    }

    return saturate(depthValue);
}

float black_wand_Depth_Available(float2 uv, int depthMode, int depthInvert, float traceScale, float threshold)
{
    float2 px = MIXSR_SHARED_PixelSize();
    float rawCenter = black_wand_Depth_Raw(uv);
    float rawR = black_wand_Depth_Raw(uv + float2(px.x, 0.0));
    float rawL = black_wand_Depth_Raw(uv + float2(-px.x, 0.0));
    float rawU = black_wand_Depth_Raw(uv + float2(0.0, px.y));
    float rawD = black_wand_Depth_Raw(uv + float2(0.0, -px.y));

    float linCenter = black_wand_Depth_Linear(uv, depthMode, depthInvert);
    float linR = black_wand_Depth_Linear(uv + float2(px.x, 0.0), depthMode, depthInvert);
    float linL = black_wand_Depth_Linear(uv + float2(-px.x, 0.0), depthMode, depthInvert);
    float linU = black_wand_Depth_Linear(uv + float2(0.0, px.y), depthMode, depthInvert);
    float linD = black_wand_Depth_Linear(uv + float2(0.0, -px.y), depthMode, depthInvert);

    float rawSpan = max(max(abs(rawCenter - rawR), abs(rawCenter - rawL)), max(abs(rawCenter - rawU), abs(rawCenter - rawD)));
    float linSpan = max(max(abs(linCenter - linR), abs(linCenter - linL)), max(abs(linCenter - linU), abs(linCenter - linD)));
    float activity = max(rawSpan, linSpan * max(1.0, traceScale));
    float clampedThreshold = max(0.00001, threshold);
    float availability = smoothstep(clampedThreshold, clampedThreshold * 4.0, activity);
    float validRange = step(0.000001, rawCenter) * step(rawCenter, 0.999999);
    return saturate(availability * validRange);
}

float black_wand_Depth_Edge(float2 uv, int depthMode, int depthInvert, float traceScale, float availabilityThreshold, float edgeThreshold)
{
    float2 px = MIXSR_SHARED_PixelSize();
    float c = black_wand_Depth_Linear(uv, depthMode, depthInvert);
    float dxP = abs(c - black_wand_Depth_Linear(uv + float2(px.x, 0.0), depthMode, depthInvert));
    float dxN = abs(c - black_wand_Depth_Linear(uv + float2(-px.x, 0.0), depthMode, depthInvert));
    float dyP = abs(c - black_wand_Depth_Linear(uv + float2(0.0, px.y), depthMode, depthInvert));
    float dyN = abs(c - black_wand_Depth_Linear(uv + float2(0.0, -px.y), depthMode, depthInvert));
    float depthEdge = max(max(dxP, dxN), max(dyP, dyN)) * max(1.0, traceScale);
    float edgeMask = smoothstep(edgeThreshold, edgeThreshold * 4.0, depthEdge);
    float available = black_wand_Depth_Available(uv, depthMode, depthInvert, traceScale, availabilityThreshold);
    return saturate(edgeMask * available);
}

float black_wand_Depth_RejectCross(float2 uv, int depthMode, int depthInvert, float traceScale, float availabilityThreshold, float radiusPixels, float threshold)
{
    float2 px = MIXSR_SHARED_PixelSize() * max(0.0, radiusPixels);
    float centerDepth = black_wand_Depth_Linear(uv, depthMode, depthInvert);
    float rightDepth = black_wand_Depth_Linear(uv + float2(px.x, 0.0), depthMode, depthInvert);
    float leftDepth = black_wand_Depth_Linear(uv + float2(-px.x, 0.0), depthMode, depthInvert);
    float upDepth = black_wand_Depth_Linear(uv + float2(0.0, px.y), depthMode, depthInvert);
    float downDepth = black_wand_Depth_Linear(uv + float2(0.0, -px.y), depthMode, depthInvert);
    float maxDelta = max(max(abs(centerDepth - rightDepth), abs(centerDepth - leftDepth)), max(abs(centerDepth - upDepth), abs(centerDepth - downDepth)));
    float reject = 1.0 - smoothstep(threshold, threshold * 4.0, maxDelta);
    float available = black_wand_Depth_Available(uv, depthMode, depthInvert, traceScale, availabilityThreshold);
    return saturate(reject * available);
}

float black_wand_Depth_FarMask(float depth, float farStart, float farFeather)
{
    return smoothstep(farStart, min(1.0, farStart + max(0.0001, farFeather)), saturate(depth));
}

float black_wand_Depth_NearMask(float depth, float nearEnd, float nearFeather)
{
    return 1.0 - smoothstep(nearEnd, min(1.0, nearEnd + max(0.0001, nearFeather)), saturate(depth));
}

float black_wand_Depth_SampleRejectWeight(float centerDepth, float sampleDepth, float threshold, float softness)
{
    float depthDelta = abs(centerDepth - sampleDepth);
    return 1.0 - smoothstep(max(0.000001, threshold), max(0.000002, threshold + softness), depthDelta);
}

float black_wand_Depth_SampleSameLayerWeight(float centerDepth, float sampleDepth, float threshold, float softness)
{
    return saturate(black_wand_Depth_SampleRejectWeight(centerDepth, sampleDepth, threshold, softness));
}

#endif
