#ifndef SHARED_DEPTH_FXH
#define SHARED_DEPTH_FXH

#include "shared_core.fxh"

float SHARED_RawDepth(float2 uv)
{
    return tex2Dlod(ReShade::DepthBuffer, float4(saturate(uv), 0.0, 0.0)).r;
}

float SHARED_LinearDepth(float2 uv, int depthMode, int depthInvert)
{
    float rawDepth = SHARED_RawDepth(uv);
    float depthValue = saturate(ReShade::GetLinearizedDepth(saturate(uv)));

    if (depthMode == 1)
    {
        depthValue = saturate(rawDepth);
    }
    else if (depthMode == 2)
    {
        depthValue = saturate(1.0 - rawDepth);
    }

    if (depthInvert != 0)
    {
        depthValue = 1.0 - depthValue;
    }

    return saturate(depthValue);
}

float SHARED_DepthAvailability(float2 uv, int depthMode, int depthInvert, float traceScale, float threshold)
{
    float2 px = SHARED_PixelSize();
    float rawCenter = SHARED_RawDepth(uv);
    float rawR = SHARED_RawDepth(uv + float2(px.x, 0.0));
    float rawL = SHARED_RawDepth(uv + float2(-px.x, 0.0));
    float rawU = SHARED_RawDepth(uv + float2(0.0, px.y));
    float rawD = SHARED_RawDepth(uv + float2(0.0, -px.y));

    float linCenter = SHARED_LinearDepth(uv, depthMode, depthInvert);
    float linR = SHARED_LinearDepth(uv + float2(px.x, 0.0), depthMode, depthInvert);
    float linL = SHARED_LinearDepth(uv + float2(-px.x, 0.0), depthMode, depthInvert);
    float linU = SHARED_LinearDepth(uv + float2(0.0, px.y), depthMode, depthInvert);
    float linD = SHARED_LinearDepth(uv + float2(0.0, -px.y), depthMode, depthInvert);

    float rawSpan = max(max(abs(rawCenter - rawR), abs(rawCenter - rawL)), max(abs(rawCenter - rawU), abs(rawCenter - rawD)));
    float linSpan = max(max(abs(linCenter - linR), abs(linCenter - linL)), max(abs(linCenter - linU), abs(linCenter - linD)));
    float activity = max(rawSpan, linSpan * max(1.0, traceScale));
    float clampedThreshold = max(0.00001, threshold);
    float availability = smoothstep(clampedThreshold, clampedThreshold * 4.0, activity);
    float validRange = step(0.000001, rawCenter) * step(rawCenter, 0.999999);
    return saturate(availability * validRange);
}

float SHARED_DepthEdgeMask(float2 uv, int depthMode, int depthInvert, float traceScale, float availabilityThreshold, float edgeThreshold)
{
    float2 px = SHARED_PixelSize();
    float c = SHARED_LinearDepth(uv, depthMode, depthInvert);
    float dxP = abs(c - SHARED_LinearDepth(uv + float2(px.x, 0.0), depthMode, depthInvert));
    float dxN = abs(c - SHARED_LinearDepth(uv + float2(-px.x, 0.0), depthMode, depthInvert));
    float dyP = abs(c - SHARED_LinearDepth(uv + float2(0.0, px.y), depthMode, depthInvert));
    float dyN = abs(c - SHARED_LinearDepth(uv + float2(0.0, -px.y), depthMode, depthInvert));
    float depthEdge = max(max(dxP, dxN), max(dyP, dyN)) * max(1.0, traceScale);
    float edgeMask = smoothstep(edgeThreshold, edgeThreshold * 4.0, depthEdge);
    float availability = SHARED_DepthAvailability(uv, depthMode, depthInvert, traceScale, availabilityThreshold);
    return edgeMask * availability;
}

float SHARED_DepthRejectMask(float2 uv, int depthMode, int depthInvert, float traceScale, float availabilityThreshold, float radiusPixels, float threshold)
{
    float2 px = SHARED_PixelSize() * radiusPixels;
    float center = SHARED_LinearDepth(uv, depthMode, depthInvert);
    float d1 = abs(center - SHARED_LinearDepth(uv + float2(px.x, 0.0), depthMode, depthInvert));
    float d2 = abs(center - SHARED_LinearDepth(uv + float2(-px.x, 0.0), depthMode, depthInvert));
    float d3 = abs(center - SHARED_LinearDepth(uv + float2(0.0, px.y), depthMode, depthInvert));
    float d4 = abs(center - SHARED_LinearDepth(uv + float2(0.0, -px.y), depthMode, depthInvert));
    float maxDelta = max(max(d1, d2), max(d3, d4)) * max(1.0, traceScale);
    float rejectMask = 1.0 - smoothstep(threshold, threshold * 2.5, maxDelta);
    float availability = SHARED_DepthAvailability(uv, depthMode, depthInvert, traceScale, availabilityThreshold);
    return rejectMask * availability;
}

#endif
