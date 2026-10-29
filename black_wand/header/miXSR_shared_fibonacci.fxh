#ifndef MIXSR_SHARED_FIBONACCI_FXH
#define MIXSR_SHARED_FIBONACCI_FXH

#include "miXSR_shared_core.fxh"
#ifndef BW_CLEAN_DEPS_SAFE_INT_HELPERS_FXH
#define BW_CLEAN_DEPS_SAFE_INT_HELPERS_FXH 1
int BW_CLEAN_DEPS_IntDivNoWarn(int value, int divisor)
{
    float safeDivisor = max(abs(float(divisor)), 1.0);
    float quotient = floor(float(value) / safeDivisor);
    return int(quotient);
}
int BW_CLEAN_DEPS_IntModuloNoWarn(int value, int modulus)
{
    float safeModulus = max(abs(float(modulus)), 1.0);
    float quotient = floor(float(value) / safeModulus);
    return int(float(value) - safeModulus * quotient);
}
#endif


int MIXSR_SHARED_GCD(int a, int b)
{
    int aa = abs(a);
    int bb = abs(b);

    [loop]
    for (int i = 0; i < 16; ++i)
    {
        if (bb == 0)
        {
            return max(1, aa);
        }

        int t = BW_CLEAN_DEPS_IntModuloNoWarn(aa, bb);
        aa = bb;
        bb = t;
    }

    return max(1, aa);
}

int MIXSR_SHARED_FindPermutationStride(int count, int iterationLimit)
{
    // Fixed lookup for the canonical ring counts used by this stack.
    // Keeps V7 staggered distribution without the runtime stride-search loop.
    int safeCount = max(1, count);
    int stride = max(1, safeCount - 1);

    if (safeCount == 12) stride = 7;
    if (safeCount == 20) stride = 13;
    if (safeCount == 54) stride = 35;
    if (safeCount == 88) stride = 57;

    return max(1, stride);
}

float2 MIXSR_SHARED_GoldenDirection(float sampleIndex)
{
    const float goldenAngle = 2.39996323;
    float angle = sampleIndex * goldenAngle;
    return float2(cos(angle), sin(angle));
}

int MIXSR_SHARED_GetFibonacciCanonicalIndex(
    int logicalIndex,
    int activeTapCount,
    int canonicalTapCount,
    int reductionMode,
    int sequentialMode,
    int iterationLimit)
{
    int clampedIndex = clamp(logicalIndex, 0, max(0, activeTapCount - 1));

    if (clampedIndex <= 0 || activeTapCount <= 1 || canonicalTapCount <= 1)
    {
        return 0;
    }

    if (reductionMode == sequentialMode || activeTapCount >= canonicalTapCount)
    {
        return min(canonicalTapCount - 1, clampedIndex);
    }

    int ringCanonicalCount = max(1, canonicalTapCount - 1);
    int stride = MIXSR_SHARED_FindPermutationStride(ringCanonicalCount, iterationLimit);
    return BW_CLEAN_DEPS_IntModuloNoWarn((clampedIndex - 1) * stride, ringCanonicalCount) + 1;
}

#endif

