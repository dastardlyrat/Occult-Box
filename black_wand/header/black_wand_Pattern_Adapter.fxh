#ifndef black_wand_PATTERN_ADAPTER_FXH
#define black_wand_PATTERN_ADAPTER_FXH

#include "miXSR_shared_core.fxh"
#include "miXSR_shared_pattern.fxh"

float black_wand_Pattern_PixelSpan()
{
    return MIXSR_SHARED_PatternSpan();
}

float2 black_wand_Pattern_Rotate(float2 v, float angleDegrees)
{
    return MIXSR_SHARED_Rotate(v, angleDegrees);
}

float black_wand_Pattern_StripeCoord(float2 uv, float angleDegrees, float spacingPixels, float phase)
{
    float2 dir = black_wand_Pattern_Rotate(float2(1.0, 0.0), angleDegrees);
    float coord = dot(uv - 0.5, dir) * black_wand_Pattern_PixelSpan() * MIXSR_SHARED_SafeRcp(max(0.5, spacingPixels));
    return coord + phase;
}

float black_wand_Pattern_Line(float2 uv, float angleDegrees, float spacingPixels, float thickness, float softness, float phase)
{
    float coord = black_wand_Pattern_StripeCoord(uv, angleDegrees, spacingPixels, phase);
    return MIXSR_SHARED_CoordStripe(coord, thickness, softness);
}

float black_wand_Pattern_Cross(float2 uv, float angleA, float angleB, float spacingPixels, float thickness, float softness, float phase)
{
    float a = black_wand_Pattern_Line(uv, angleA, spacingPixels, thickness, softness, phase);
    float b = black_wand_Pattern_Line(uv, angleB, spacingPixels, thickness, softness, phase * -0.61803398875);
    return saturate(max(a, b));
}

#endif
