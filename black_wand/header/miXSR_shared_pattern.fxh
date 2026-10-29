#ifndef MIXSR_SHARED_PATTERN_FXH
#define MIXSR_SHARED_PATTERN_FXH

#include "miXSR_shared_core.fxh"

float MIXSR_SHARED_SineHatchLine(float2 p, float2 direction, float density, float phase, float edgeLo, float edgeHi)
{
    float line = sin(dot(p, direction) * density + phase);
    return smoothstep(edgeLo, edgeHi, line);
}

float MIXSR_SHARED_CoordStripe(float coord, float thickness, float softness)
{
    float stripe = abs(frac(coord) - 0.5);
    float halfWidth = saturate(thickness) * 0.5;
    return 1.0 - smoothstep(0.5 - halfWidth, 0.5 - halfWidth + max(0.0001, softness), stripe);
}

#endif
