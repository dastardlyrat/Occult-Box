#ifndef SHARED_FIBONACCI_FXH
#define SHARED_FIBONACCI_FXH

#include "shared_core.fxh"
#include "MIXSR_API_LoopSafe.fxh"

int SHARED_GCD(int a, int b)
{
    uint aa = (uint)abs(a);
    uint bb = (uint)abs(b);
    uint result = max(1u, aa);

    [loop]
    for (int i = 0; i < 16; ++i)
    {
        if (bb == 0u)
        {
            result = max(1u, aa);
            break;
        }

        uint t = MIXSR_UIntModNoWarn(aa, bb);
        aa = bb;
        bb = t;
        result = max(1u, aa);
    }

    return (int)result;
}

int SHARED_FindPermutationStride(int count, int iterationLimit)
{
    int safeCount = max(1, count);
    int stride = max(1, safeCount - 1);

    if (safeCount == 12) stride = 7;
    if (safeCount == 20) stride = 13;
    if (safeCount == 54) stride = 35;
    if (safeCount == 88) stride = 57;

    return max(1, stride);
}

float2 SHARED_GoldenDirection(float sampleIndex)
{
    const float goldenAngle = 2.39996323;
    float angle = sampleIndex * goldenAngle;
    return float2(cos(angle), sin(angle));
}

int SHARED_GetFibonacciCanonicalIndex(
    int logicalIndex,
    int activeTapCount,
    int canonicalTapCount,
    int reductionMode,
    int sequentialMode,
    int iterationLimit)
{
    int clampedIndex = clamp(logicalIndex, 0, max(0, activeTapCount - 1));
    int result = 0;

    if (clampedIndex <= 0 || activeTapCount <= 1 || canonicalTapCount <= 1)
    {
        result = 0;
    }
    else if (reductionMode == sequentialMode || activeTapCount >= canonicalTapCount)
    {
        result = min(canonicalTapCount - 1, clampedIndex);
    }
    else
    {
        uint ringCanonicalCount = (uint)max(1, canonicalTapCount - 1);
        uint stride = (uint)SHARED_FindPermutationStride((int)ringCanonicalCount, iterationLimit);
        uint logicalRingIndex = (uint)max(0, clampedIndex - 1);
        result = MIXSR_IntModNoWarn(logicalRingIndex * stride, ringCanonicalCount) + 1;
    }

    return result;
}

#endif
