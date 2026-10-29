#ifndef LOOKING_GLASS_FXH
#define LOOKING_GLASS_FXH

// Standalone lens server with higher-tap Fibonacci families and reduction-aware utilities.
// Include ReShade.fxh before this file in consumer shaders.

#include "miXSR_shared_core.fxh"
#include "miXSR_shared_fibonacci.fxh"
#include "miXSR_shared_lens55.fxh"
#include "MIXSR_API_LoopSafe.fxh"

#define LOOKING_GLASS_LENS_OFF 0
#define LOOKING_GLASS_LENS_POINT1 1
#define LOOKING_GLASS_LENS_HORIZONTALPAIR2 2
#define LOOKING_GLASS_LENS_VERTICALPAIR2 3
#define LOOKING_GLASS_LENS_DIAGONALPAIR2A 4
#define LOOKING_GLASS_LENS_DIAGONALPAIR2B 5
#define LOOKING_GLASS_LENS_CROSS5 6
#define LOOKING_GLASS_LENS_X5 7
#define LOOKING_GLASS_LENS_CROSSX9 8
#define LOOKING_GLASS_LENS_BOX4 9
#define LOOKING_GLASS_LENS_BOX9 10
#define LOOKING_GLASS_LENS_BOX25 11
#define LOOKING_GLASS_LENS_RECTHORIZONTAL15 12
#define LOOKING_GLASS_LENS_RECTVERTICAL15 13
#define LOOKING_GLASS_LENS_DIAMOND9 14
#define LOOKING_GLASS_LENS_DIAMOND13 15
#define LOOKING_GLASS_LENS_RING4 16
#define LOOKING_GLASS_LENS_RING8 17
#define LOOKING_GLASS_LENS_RING9 18
#define LOOKING_GLASS_LENS_RING12 19
#define LOOKING_GLASS_LENS_RADIAL13 20
#define LOOKING_GLASS_LENS_SPIRAL13 21
#define LOOKING_GLASS_LENS_GOLDEN21 22
#define LOOKING_GLASS_LENS_BOUNDED55 23
#define LOOKING_GLASS_LENS_FIBONACCI55 24
#define LOOKING_GLASS_LENS_FIBONACCI89 25

#define LOOKING_GLASS_MAX_TAPS 89
#define LOOKING_GLASS_REDUCTION_STAGGERED 0
#define LOOKING_GLASS_REDUCTION_SEQUENTIAL 1

float2 LOOKING_GLASS_PixelSize()
{
    return MIXSR_SHARED_PixelSize();
}

float2 LOOKING_GLASS_Rotate(float2 v, float angleDegrees)
{
    float angle = radians(angleDegrees);
    float s = sin(angle);
    float c = cos(angle);
    return float2(v.x * c - v.y * s, v.x * s + v.y * c);
}

float2 LOOKING_GLASS_GoldenDirection(float sampleIndex)
{
    return MIXSR_SHARED_GoldenDirection(sampleIndex);
}

void LOOKING_GLASS_GetRotationBasis(float rotationDegrees, out float2 basisX, out float2 basisY)
{
    if (abs(rotationDegrees) <= 0.00001)
    {
        basisX = float2(1.0, 0.0);
        basisY = float2(0.0, 1.0);
        return;
    }

    float angle = radians(rotationDegrees);
    float s = sin(angle);
    float c = cos(angle);
    basisX = float2(c, s);
    basisY = float2(-s, c);
}

float2 LOOKING_GLASS_ApplyRotationBasis(float2 v, float2 basisX, float2 basisY)
{
    return float2(v.x * basisX.x + v.y * basisY.x, v.x * basisX.y + v.y * basisY.y);
}

int LOOKING_GLASS_GCD(int a, int b)
{
    return MIXSR_SHARED_GCD(a, b);
}

int LOOKING_GLASS_FindPermutationStride(int count)
{
    return MIXSR_SHARED_FindPermutationStride(count, LOOKING_GLASS_MAX_TAPS);
}

bool LOOKING_GLASS_IsFibonacciLens(int lensMode)
{
    return lensMode == LOOKING_GLASS_LENS_SPIRAL13
        || lensMode == LOOKING_GLASS_LENS_GOLDEN21
        || lensMode == LOOKING_GLASS_LENS_FIBONACCI55
        || lensMode == LOOKING_GLASS_LENS_FIBONACCI89;
}

int LOOKING_GLASS_GetTapCount(int lensMode)
{
    if (lensMode == LOOKING_GLASS_LENS_POINT1) return 1;
    if (lensMode == LOOKING_GLASS_LENS_HORIZONTALPAIR2) return 2;
    if (lensMode == LOOKING_GLASS_LENS_VERTICALPAIR2) return 2;
    if (lensMode == LOOKING_GLASS_LENS_DIAGONALPAIR2A) return 2;
    if (lensMode == LOOKING_GLASS_LENS_DIAGONALPAIR2B) return 2;
    if (lensMode == LOOKING_GLASS_LENS_CROSS5) return 5;
    if (lensMode == LOOKING_GLASS_LENS_X5) return 5;
    if (lensMode == LOOKING_GLASS_LENS_CROSSX9) return 9;
    if (lensMode == LOOKING_GLASS_LENS_BOX4) return 4;
    if (lensMode == LOOKING_GLASS_LENS_BOX9) return 9;
    if (lensMode == LOOKING_GLASS_LENS_BOX25) return 25;
    if (lensMode == LOOKING_GLASS_LENS_RECTHORIZONTAL15) return 15;
    if (lensMode == LOOKING_GLASS_LENS_RECTVERTICAL15) return 15;
    if (lensMode == LOOKING_GLASS_LENS_DIAMOND9) return 9;
    if (lensMode == LOOKING_GLASS_LENS_DIAMOND13) return 13;
    if (lensMode == LOOKING_GLASS_LENS_RING4) return 4;
    if (lensMode == LOOKING_GLASS_LENS_RING8) return 8;
    if (lensMode == LOOKING_GLASS_LENS_RING9) return 9;
    if (lensMode == LOOKING_GLASS_LENS_RING12) return 12;
    if (lensMode == LOOKING_GLASS_LENS_RADIAL13) return 13;
    if (lensMode == LOOKING_GLASS_LENS_SPIRAL13) return 13;
    if (lensMode == LOOKING_GLASS_LENS_GOLDEN21) return 21;
    if (lensMode == LOOKING_GLASS_LENS_BOUNDED55) return MIXSR_SHARED_LENS55_TAP_COUNT;
    if (lensMode == LOOKING_GLASS_LENS_FIBONACCI55) return 55;
    if (lensMode == LOOKING_GLASS_LENS_FIBONACCI89) return 89;
    return 0;
}

int LOOKING_GLASS_GetActiveTapCount(int lensMode, int requestedTapCount)
{
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(lensMode);

    if (canonicalTapCount <= 0)
    {
        return 0;
    }

    if (!LOOKING_GLASS_IsFibonacciLens(lensMode))
    {
        return canonicalTapCount;
    }

    return clamp(requestedTapCount, 1, canonicalTapCount);
}

int LOOKING_GLASS_MapFibonacciLogicalToCanonical(int logicalIndex, int activeTapCount, int canonicalTapCount, int reductionMode)
{
    if (logicalIndex <= 0 || activeTapCount <= 1 || canonicalTapCount <= 1)
    {
        return 0;
    }

    int ringCanonicalCount = max(1, canonicalTapCount - 1);

    if (reductionMode == LOOKING_GLASS_REDUCTION_SEQUENTIAL)
    {
        return min(canonicalTapCount - 1, logicalIndex);
    }

    int stride = LOOKING_GLASS_FindPermutationStride(ringCanonicalCount);
    int permutedRingIndex = MIXSR_IntModNoWarn((logicalIndex - 1) * stride, ringCanonicalCount);
    return permutedRingIndex + 1;
}

float2 LOOKING_GLASS_GetCanonicalOffset(int lensMode, int index)
{
    if (lensMode == LOOKING_GLASS_LENS_POINT1)
    {
        return 0.0.xx;
    }

    if (lensMode == LOOKING_GLASS_LENS_HORIZONTALPAIR2)
    {
        return (index <= 0) ? float2(-1.0, 0.0) : float2(1.0, 0.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_VERTICALPAIR2)
    {
        return (index <= 0) ? float2(0.0, -1.0) : float2(0.0, 1.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_DIAGONALPAIR2A)
    {
        const float d = 0.70710678;
        return (index <= 0) ? float2(-d, -d) : float2(d, d);
    }

    if (lensMode == LOOKING_GLASS_LENS_DIAGONALPAIR2B)
    {
        const float d = 0.70710678;
        return (index <= 0) ? float2(d, -d) : float2(-d, d);
    }

    if (lensMode == LOOKING_GLASS_LENS_CROSS5)
    {
        if (index <= 0) return 0.0.xx;
        if (index == 1) return float2(0.0, -1.0);
        if (index == 2) return float2(1.0, 0.0);
        if (index == 3) return float2(0.0, 1.0);
        return float2(-1.0, 0.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_X5)
    {
        const float d = 0.70710678;
        if (index <= 0) return 0.0.xx;
        if (index == 1) return float2(-d, -d);
        if (index == 2) return float2(d, -d);
        if (index == 3) return float2(d, d);
        return float2(-d, d);
    }

    if (lensMode == LOOKING_GLASS_LENS_CROSSX9 || lensMode == LOOKING_GLASS_LENS_BOX9)
    {
        int x = MIXSR_IntModNoWarn(index, 3) - 1;
        int y = int(uint(max(0, index)) / 3u) - 1;
        return float2(float(x), float(y)) * 0.70710678;
    }

    if (lensMode == LOOKING_GLASS_LENS_BOX4)
    {
        const float d = 0.70710678;
        if (index == 0) return float2(-d, -d);
        if (index == 1) return float2(d, -d);
        if (index == 2) return float2(d, d);
        return float2(-d, d);
    }

    if (lensMode == LOOKING_GLASS_LENS_BOX25)
    {
        int x = MIXSR_IntModNoWarn(index, 5) - 2;
        int y = int(uint(max(0, index)) / 5u) - 2;
        return float2(float(x), float(y)) * 0.35355339;
    }

    if (lensMode == LOOKING_GLASS_LENS_RECTHORIZONTAL15)
    {
        return float2((float(index) - 7.0) / 7.0, 0.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_RECTVERTICAL15)
    {
        return float2(0.0, (float(index) - 7.0) / 7.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_DIAMOND9)
    {
        if (index == 0) return 0.0.xx;
        if (index == 1) return float2(0.0, -0.5);
        if (index == 2) return float2(0.5, 0.0);
        if (index == 3) return float2(0.0, 0.5);
        if (index == 4) return float2(-0.5, 0.0);
        if (index == 5) return float2(0.0, -1.0);
        if (index == 6) return float2(1.0, 0.0);
        if (index == 7) return float2(0.0, 1.0);
        return float2(-1.0, 0.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_DIAMOND13)
    {
        if (index == 0) return 0.0.xx;
        if (index == 1) return float2(0.0, -0.5);
        if (index == 2) return float2(0.5, 0.0);
        if (index == 3) return float2(0.0, 0.5);
        if (index == 4) return float2(-0.5, 0.0);
        if (index == 5) return float2(0.0, -1.0);
        if (index == 6) return float2(1.0, 0.0);
        if (index == 7) return float2(0.0, 1.0);
        if (index == 8) return float2(-1.0, 0.0);
        if (index == 9) return float2(-0.5, -0.5);
        if (index == 10) return float2(0.5, -0.5);
        if (index == 11) return float2(0.5, 0.5);
        return float2(-0.5, 0.5);
    }

    if (lensMode == LOOKING_GLASS_LENS_RING4)
    {
        if (index == 0) return float2(0.0, -1.0);
        if (index == 1) return float2(1.0, 0.0);
        if (index == 2) return float2(0.0, 1.0);
        return float2(-1.0, 0.0);
    }

    if (lensMode == LOOKING_GLASS_LENS_RING8)
    {
        float angle = (6.2831853 * float(index)) / 8.0;
        return float2(cos(angle), sin(angle));
    }

    if (lensMode == LOOKING_GLASS_LENS_RING9)
    {
        if (index <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(index - 1)) / 8.0;
        return float2(cos(angle), sin(angle));
    }

    if (lensMode == LOOKING_GLASS_LENS_RING12)
    {
        float angle = (6.2831853 * float(index)) / 12.0;
        return float2(cos(angle), sin(angle));
    }

    if (lensMode == LOOKING_GLASS_LENS_RADIAL13)
    {
        if (index <= 0) return 0.0.xx;

        if (index < 5)
        {
            if (index == 1) return float2(0.0, -0.45);
            if (index == 2) return float2(0.45, 0.0);
            if (index == 3) return float2(0.0, 0.45);
            return float2(-0.45, 0.0);
        }

        float angle = (6.2831853 * float(index - 5)) / 8.0;
        return float2(cos(angle), sin(angle));
    }

    if (LOOKING_GLASS_IsFibonacciLens(lensMode))
    {
        int canonicalTapCount = LOOKING_GLASS_GetTapCount(lensMode);

        if (index <= 0)
        {
            return 0.0.xx;
        }

        float sampleIndex = float(index - 1);
        float radial = sqrt((sampleIndex + 1.0) / max(1.0, float(canonicalTapCount - 1)));
        return LOOKING_GLASS_GoldenDirection(sampleIndex + 0.5) * radial;
    }

    if (lensMode == LOOKING_GLASS_LENS_BOUNDED55)
    {
        return MIXSR_SHARED_Lens55Offset(clamp(index, 0, MIXSR_SHARED_LENS55_TAP_COUNT - 1));
    }

    return 0.0.xx;
}

int LOOKING_GLASS_GetCanonicalIndex(int lensMode, int logicalIndex, int requestedTapCount, int reductionMode)
{
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(lensMode);
    int activeTapCount = LOOKING_GLASS_GetActiveTapCount(lensMode, requestedTapCount);

    if (canonicalTapCount <= 0)
    {
        return 0;
    }

    int clampedIndex = clamp(logicalIndex, 0, activeTapCount - 1);

    if (!LOOKING_GLASS_IsFibonacciLens(lensMode))
    {
        return clampedIndex;
    }

    return LOOKING_GLASS_MapFibonacciLogicalToCanonical(clampedIndex, activeTapCount, canonicalTapCount, reductionMode);
}

int LOOKING_GLASS_GetReductionStride(int lensMode, int activeTapCount, int canonicalTapCount, int reductionMode)
{
    if (!LOOKING_GLASS_IsFibonacciLens(lensMode))
    {
        return 1;
    }

    if (reductionMode == LOOKING_GLASS_REDUCTION_SEQUENTIAL || activeTapCount <= 1 || canonicalTapCount <= 1)
    {
        return 1;
    }

    return LOOKING_GLASS_FindPermutationStride(max(1, canonicalTapCount - 1));
}

int LOOKING_GLASS_GetCanonicalIndexFast(
    int lensMode,
    int logicalIndex,
    int activeTapCount,
    int canonicalTapCount,
    int reductionMode,
    int reductionStride)
{
    int clampedIndex = clamp(logicalIndex, 0, max(0, activeTapCount - 1));

    if (!LOOKING_GLASS_IsFibonacciLens(lensMode))
    {
        return clampedIndex;
    }

    if (clampedIndex <= 0 || activeTapCount <= 1 || canonicalTapCount <= 1)
    {
        return 0;
    }

    if (reductionMode == LOOKING_GLASS_REDUCTION_SEQUENTIAL)
    {
        return min(canonicalTapCount - 1, clampedIndex);
    }

    int ringCanonicalCount = max(1, canonicalTapCount - 1);
    return (int)MIXSR_UIntModNoWarn((uint)max(0, clampedIndex - 1) * (uint)max(1, reductionStride), (uint)max(1, ringCanonicalCount)) + 1;
}

float2 LOOKING_GLASS_GetOffset(int lensMode, int logicalIndex, int requestedTapCount, int reductionMode)
{
    int canonicalIndex = LOOKING_GLASS_GetCanonicalIndex(lensMode, logicalIndex, requestedTapCount, reductionMode);
    return LOOKING_GLASS_GetCanonicalOffset(lensMode, canonicalIndex);
}

float2 LOOKING_GLASS_GetRotatedOffset(int lensMode, int logicalIndex, int requestedTapCount, int reductionMode, float rotationDegrees)
{
    return LOOKING_GLASS_Rotate(LOOKING_GLASS_GetOffset(lensMode, logicalIndex, requestedTapCount, reductionMode), rotationDegrees);
}

float3 LOOKING_GLASS_SampleAverage(
    sampler2D sourceSampler,
    float2 uv,
    int lensMode,
    int requestedTapCount,
    int reductionMode,
    float radiusPixels,
    float rotationDegrees)
{
    int activeTapCount = LOOKING_GLASS_GetActiveTapCount(lensMode, requestedTapCount);
    int canonicalTapCount = LOOKING_GLASS_GetTapCount(lensMode);
    float3 result = 0.0.xxx;

    if (activeTapCount <= 0)
    {
        result = tex2Dlod(sourceSampler, float4(saturate(uv), 0.0, 0.0)).rgb;
    }
    else
    {
        int reductionStride = LOOKING_GLASS_GetReductionStride(lensMode, activeTapCount, canonicalTapCount, reductionMode);
        float2 pixelSize = LOOKING_GLASS_PixelSize();
        float3 sum = 0.0.xxx;
        float weightSum = 0.0;
        float2 rotationBasisX = 0.0.xx;
        float2 rotationBasisY = 0.0.xx;
        LOOKING_GLASS_GetRotationBasis(rotationDegrees, rotationBasisX, rotationBasisY);

        [loop]
        for (int i = 0; i < LOOKING_GLASS_MAX_TAPS; ++i)
        {
            if (i >= activeTapCount) break;

            int canonicalIndex = LOOKING_GLASS_GetCanonicalIndexFast(
                lensMode,
                i,
                activeTapCount,
                canonicalTapCount,
                reductionMode,
                reductionStride);
            float2 offset = LOOKING_GLASS_ApplyRotationBasis(
                LOOKING_GLASS_GetCanonicalOffset(lensMode, canonicalIndex),
                rotationBasisX,
                rotationBasisY) * radiusPixels * pixelSize;
            float3 tap = tex2Dlod(sourceSampler, float4(saturate(uv + offset), 0.0, 0.0)).rgb;
            sum += tap;
            weightSum += 1.0;
        }

        result = sum / max(1.0, weightSum);
    }

    return result;
}

float LOOKING_GLASS_SampleLumaAverage(
    sampler2D sourceSampler,
    float2 uv,
    int lensMode,
    int requestedTapCount,
    int reductionMode,
    float radiusPixels,
    float rotationDegrees)
{
    float3 c = LOOKING_GLASS_SampleAverage(sourceSampler, uv, lensMode, requestedTapCount, reductionMode, radiusPixels, rotationDegrees);
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

#endif

