#ifndef HEXING_EYE_FXH
#define HEXING_EYE_FXH
#include "MIXSR_API_LoopSafe.fxh"

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

// Standalone hatch server with analytic, multi-stage, and Fibonacci-driven hatch helpers.
// Include ReShade.fxh before this file in consumer shaders.

#include "miXSR_shared_core.fxh"
#include "miXSR_shared_depth.fxh"
#include "miXSR_shared_fibonacci.fxh"
#include "miXSR_shared_pattern.fxh"

#define HEXING_EYE_HATCH_OFF 0
#define HEXING_EYE_HATCH_DIAGONAL_A 1
#define HEXING_EYE_HATCH_DIAGONAL_B 2
#define HEXING_EYE_HATCH_CROSS 3
#define HEXING_EYE_HATCH_THIN_DIAGONAL 4
#define HEXING_EYE_HATCH_SPARSE 5
#define HEXING_EYE_HATCH_ORGANIC_SKETCH 6
#define HEXING_EYE_HATCH_EDGE_INK 7
#define HEXING_EYE_HATCH_TECHNICAL 8
#define HEXING_EYE_HATCH_FAR_DETAIL 9
#define HEXING_EYE_HATCH_ANIMATED 10
#define HEXING_EYE_HATCH_ORCHESTRATOR 11
#define HEXING_EYE_HATCH_FIVE_STAGE_SMALL 12
#define HEXING_EYE_HATCH_FIVE_STAGE_MED_SMALL 13
#define HEXING_EYE_HATCH_FIVE_STAGE_VERY_SMALL 14
#define HEXING_EYE_HATCH_FIVE_STAGE_BLENDED 15
#define HEXING_EYE_HATCH_FIVE_STAGE_NEAR 16
#define HEXING_EYE_HATCH_FIVE_STAGE_FORWARD 17
#define HEXING_EYE_HATCH_FIVE_STAGE_CENTER 18
#define HEXING_EYE_HATCH_FIVE_STAGE_BACK 19
#define HEXING_EYE_HATCH_FIVE_STAGE_FAR 20
#define HEXING_EYE_HATCH_FIBONACCI_BIO 21
#define HEXING_EYE_HATCH_PROCEDURAL_BIO 22
#define HEXING_EYE_HATCH_CENTERED_FIBONACCI 23
#define HEXING_EYE_HATCH_LOG_SPIRAL 24
#define HEXING_EYE_HATCH_LOG_SPIRAL_CROSS 25

#define HEXING_EYE_MASK_OFF 0
#define HEXING_EYE_MASK_LUMA_BANDS 1
#define HEXING_EYE_MASK_EDGE 2
#define HEXING_EYE_MASK_DEPTH_EDGE 3
#define HEXING_EYE_MASK_FAR_DEPTH 4
#define HEXING_EYE_MASK_DEPTH_REJECT 5
#define HEXING_EYE_MASK_RADIUS_RING 6
#define HEXING_EYE_MASK_GOLDEN21_DETAIL 7
#define HEXING_EYE_MASK_HATCH_BANDS 8

#define HEXING_EYE_FIB_TAP_LIMIT 89
#define HEXING_EYE_FIB_REDUCTION_STAGGERED 0
#define HEXING_EYE_FIB_REDUCTION_SEQUENTIAL 1

float2 HEXING_EYE_PixelSize()
{
    return MIXSR_SHARED_PixelSize();
}

float HEXING_EYE_RawDepth(float2 uv)
{
    return MIXSR_SHARED_RawDepth(uv);
}

float HEXING_EYE_LinearDepth(float2 uv)
{
    return MIXSR_SHARED_LinearDepth(uv, HEXING_EYE_DepthLinearizationMode, HEXING_EYE_DepthInvert);
}

float HEXING_EYE_DepthAvailability(float2 uv)
{
    return MIXSR_SHARED_DepthAvailability(
        uv,
        HEXING_EYE_DepthLinearizationMode,
        HEXING_EYE_DepthInvert,
        HEXING_EYE_DepthTraceScale,
        HEXING_EYE_DepthAvailabilityThreshold);
}

float HEXING_EYE_PatternSpan()
{
    return MIXSR_SHARED_PatternSpan();
}

float HEXING_EYE_Luma(float3 c)
{
    return MIXSR_SHARED_Luma(c);
}

float HEXING_EYE_SafeRcp(float v)
{
    return MIXSR_SHARED_SafeRcp(v);
}

int HEXING_EYE_GCD(int a, int b)
{
    return MIXSR_SHARED_GCD(a, b);
}

int HEXING_EYE_FindPermutationStride(int count)
{
    return MIXSR_SHARED_FindPermutationStride(count, HEXING_EYE_FIB_TAP_LIMIT);
}

int HEXING_EYE_GetFibonacciCanonicalIndex(int logicalIndex, int activeTapCount, int reductionMode)
{
    return MIXSR_SHARED_GetFibonacciCanonicalIndex(
        logicalIndex,
        activeTapCount,
        HEXING_EYE_FIB_TAP_LIMIT,
        reductionMode,
        HEXING_EYE_FIB_REDUCTION_SEQUENTIAL,
        HEXING_EYE_FIB_TAP_LIMIT);
}

int HEXING_EYE_GetFibonacciReductionStride(int activeTapCount, int reductionMode)
{
    if (reductionMode == HEXING_EYE_FIB_REDUCTION_SEQUENTIAL || activeTapCount >= HEXING_EYE_FIB_TAP_LIMIT)
    {
        return 1;
    }

    return HEXING_EYE_FindPermutationStride(HEXING_EYE_FIB_TAP_LIMIT - 1);
}

int HEXING_EYE_GetFibonacciCanonicalIndexFast(
    int logicalIndex,
    int activeTapCount,
    int reductionMode,
    int reductionStride)
{
    int clampedIndex = clamp(logicalIndex, 0, max(0, activeTapCount - 1));

    if (clampedIndex <= 0 || activeTapCount <= 1)
    {
        return 0;
    }

    if (reductionMode == HEXING_EYE_FIB_REDUCTION_SEQUENTIAL || activeTapCount >= HEXING_EYE_FIB_TAP_LIMIT)
    {
        return min(HEXING_EYE_FIB_TAP_LIMIT - 1, clampedIndex);
    }

    int ringCanonicalCount = HEXING_EYE_FIB_TAP_LIMIT - 1;
    return BW_CLEAN_DEPS_IntModuloNoWarn((clampedIndex - 1) * reductionStride, ringCanonicalCount) + 1;
}


float2 HEXING_EYE_SafeNormalize2(float2 v)
{
    float len = max(0.000010, length(v));
    return v / len;
}

float2 HEXING_EYE_Rotate(float2 v, float angleDegrees)
{
    return MIXSR_SHARED_Rotate(v, angleDegrees);
}

float HEXING_EYE_Hash21(float2 p)
{
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

float2 HEXING_EYE_GoldenDirection(float sampleIndex)
{
    return MIXSR_SHARED_GoldenDirection(sampleIndex);
}

float2 HEXING_EYE_FibonacciOffsetFromCanonical(int resolvedIndex, float anchor)
{
    float tapNorm = (HEXING_EYE_FIB_TAP_LIMIT > 1) ? (float(resolvedIndex) * HEXING_EYE_SafeRcp(float(HEXING_EYE_FIB_TAP_LIMIT - 1))) : 0.0;
    float2 direction = HEXING_EYE_GoldenDirection(anchor + float(resolvedIndex));
    float radial = (resolvedIndex == 0) ? 0.0 : sqrt(saturate(tapNorm));
    return direction * (0.18 + 0.82 * radial);
}

float2 HEXING_EYE_FibonacciOffset(int canonicalIndex, int activeTapCount, float anchor, int reductionMode)
{
    int resolvedIndex = HEXING_EYE_GetFibonacciCanonicalIndex(canonicalIndex, activeTapCount, reductionMode);
    return HEXING_EYE_FibonacciOffsetFromCanonical(resolvedIndex, anchor);
}

float2 HEXING_EYE_LogSpiralDirection(float2 lensOffset, float fibIndex, float2 uv, float tapNorm, float flow)
{
    float2 lensDir = HEXING_EYE_SafeNormalize2(float2(0.23 - lensOffset.y, 0.17 + lensOffset.x + frac(fibIndex * 0.000618)));
    int branchCount = max(2, HEXING_EYE_SpiralBranchCount);
    float branchId = floor(frac(fibIndex * 0.61803398875) * float(branchCount));
    float baseArmAngle = (6.28318530718 * (branchId / float(branchCount))) + dot(uv * (HEXING_EYE_FibonacciDensity * 10.0), float2(0.1618, 0.2718));

    float2 recursiveDir = 0.0.xx;
    float recursiveWeight = 0.00001;
    int activeLevels = max(1, min(4, HEXING_EYE_SpiralRecursiveLevels));

    [unroll]
    for (int level = 0; level < 4; ++level)
    {
        float active = step(float(level), float(activeLevels - 1));
        float levelF = float(level) + tapNorm;
        float growth = MIXSR_SafePowNonNegative(max(1.02, HEXING_EYE_SpiralGrowth), levelF);
        float spiralAngle = baseArmAngle + fibIndex * 0.013 + flow * 0.22;
        spiralAngle += levelF * HEXING_EYE_SpiralTightness * 1.57079632679;
        float spiralAngleDegrees = spiralAngle * 57.2957795131;
        float2 branchDir = HEXING_EYE_SafeNormalize2(HEXING_EYE_Rotate(lensDir, spiralAngleDegrees));
        float branchWeight = active * (1.0 / growth);
        recursiveDir += branchDir * branchWeight;
        recursiveWeight += branchWeight;
    }

    float2 normalizedRecursive = HEXING_EYE_SafeNormalize2(recursiveDir / recursiveWeight);
    return HEXING_EYE_SafeNormalize2(lerp(lensDir, normalizedRecursive, saturate(HEXING_EYE_SpiralBranchBlend)));
}

float HEXING_EYE_HatchLine(float2 p, float2 direction, float density, float phase, float edgeLo, float edgeHi)
{
    return MIXSR_SHARED_SineHatchLine(p, direction, density, phase, edgeLo, edgeHi);
}

float HEXING_EYE_LineMask(float2 uv, float angleDegrees, float spacing, float thickness, float phase)
{
    float2 dir = HEXING_EYE_Rotate(float2(1.0, 0.0), angleDegrees);
    float coord = dot(uv - 0.5, dir) * HEXING_EYE_PatternSpan() * HEXING_EYE_SafeRcp(max(0.5, spacing)) + phase;
    float stripe = abs(frac(coord) - 0.5);
    float halfWidth = saturate(thickness) * 0.5;
    return 1.0 - smoothstep(0.5 - halfWidth, 0.5, stripe);
}

float HEXING_EYE_LocalContrast(float2 uv, float3 sourceColor)
{
    return MIXSR_SHARED_LocalContrast(uv, sourceColor);
}

float HEXING_EYE_EdgeMask(float2 uv, float3 sourceColor, float edgeThreshold)
{
    float localContrast = HEXING_EYE_LocalContrast(uv, sourceColor);
    return smoothstep(edgeThreshold, edgeThreshold * 4.0, localContrast);
}

float HEXING_EYE_DepthEdgeMask(float2 uv, float edgeThreshold)
{
    return MIXSR_SHARED_DepthEdgeMask(
        uv,
        HEXING_EYE_DepthLinearizationMode,
        HEXING_EYE_DepthInvert,
        HEXING_EYE_DepthTraceScale,
        HEXING_EYE_DepthAvailabilityThreshold,
        edgeThreshold);
}

float HEXING_EYE_FarDepthMask(float depth, float start, float feather)
{
    float depthSignal = saturate(pow(max(0.0, depth), 0.85));
    return smoothstep(start, min(1.0, start + max(0.0001, feather)), depthSignal);
}

float HEXING_EYE_DepthRejectMask(float2 uv, float radiusPixels, float threshold)
{
    return MIXSR_SHARED_DepthRejectMask(
        uv,
        HEXING_EYE_DepthLinearizationMode,
        HEXING_EYE_DepthInvert,
        HEXING_EYE_DepthTraceScale,
        HEXING_EYE_DepthAvailabilityThreshold,
        radiusPixels,
        threshold);
}

float HEXING_EYE_RadiusRingMask(float2 uv, float radius, float thickness)
{
    float2 p = uv - 0.5;
    float ringDist = abs(length(p) - radius);
    return 1.0 - smoothstep(0.0, max(0.0001, thickness), ringDist);
}

float HEXING_EYE_Golden21Detail(float2 uv, float radiusPixels)
{
    float2 px = HEXING_EYE_PixelSize() * radiusPixels;
    float center = HEXING_EYE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb);
    float sum = 0.0;

    [loop]
    for (int i = 0; i < 21; ++i)
    {
        float sampleIndex = float(i);
        float radial = (i == 0) ? 0.0 : sqrt(sampleIndex / 20.0);
        float2 offset = HEXING_EYE_GoldenDirection(sampleIndex + 0.5) * radial * px;
        float tap = HEXING_EYE_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + offset), 0.0, 0.0)).rgb);
        sum += abs(center - tap);
    }

    return saturate(sum / 7.0);
}

float HEXING_EYE_LumaBandMask(float luma, float thresholdA, float thresholdC)
{
    return 1.0 - smoothstep(min(thresholdC, thresholdA), max(thresholdC, thresholdA), luma);
}

float HEXING_EYE_HatchBandCount(float luma, float thresholdA, float thresholdB, float thresholdC)
{
    float bands = 0.0;
    bands += step(luma, thresholdA);
    bands += step(luma, thresholdB);
    bands += step(luma, thresholdC);
    return bands / 3.0;
}

float HEXING_EYE_OrchestratorHatch(float2 uv, float depth, float contrast)
{
    float waveA = sin((uv.x + uv.y) * 860.0 + depth * 21.0);
    float waveB = sin((uv.x - uv.y) * 710.0 - depth * 17.0);
    float pattern = saturate(waveA * waveB * 0.5 + 0.5);
    return saturate((pattern - 0.5) * max(0.10, contrast) + 0.5);
}

float HEXING_EYE_FiveStageHatch(float2 uv, float depth, float baseScale, float contrast, int stageBand)
{
    float scaleMul = 1.30;
    float phaseA = 21.0;
    float phaseB = 17.0;
    float axisMul = 0.825;

    if (stageBand == 1)
    {
        scaleMul = 1.00;
        phaseA = 19.0;
        phaseB = 15.0;
        axisMul = 0.810;
    }
    else if (stageBand == 2)
    {
        scaleMul = 1.70;
        phaseA = 23.0;
        phaseB = 19.0;
        axisMul = 0.840;
    }

    float scale = baseScale * scaleMul;
    float waveA = sin((uv.x + uv.y) * scale + depth * phaseA);
    float waveB = sin((uv.x - uv.y) * (scale * axisMul) - depth * phaseB);
    float pattern = saturate(waveA * waveB * 0.5 + 0.5);
    return saturate((pattern - 0.5) * max(0.10, contrast) + 0.5);
}

float HEXING_EYE_FibonacciBioHatch(
    float2 uv,
    float patternScale,
    float tapSpread,
    float fibAnchor,
    float fibFlow,
    float density,
    float contrast,
    int tapCount,
    int reductionMode)
{
    int clampedTaps = clamp(tapCount, 1, HEXING_EYE_FIB_TAP_LIMIT);
    float2 p = uv * patternScale;
    float phaseShift = fibFlow * 0.125;
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int reductionStride = HEXING_EYE_GetFibonacciReductionStride(clampedTaps, reductionMode);

    [loop]
    for (int i = 0; i < HEXING_EYE_FIB_TAP_LIMIT; ++i)
    {
        if (i < clampedTaps)
        {
            int canonicalIndex = HEXING_EYE_GetFibonacciCanonicalIndexFast(i, clampedTaps, reductionMode, reductionStride);
            float2 offset = HEXING_EYE_FibonacciOffsetFromCanonical(canonicalIndex, fibAnchor);
            float fibIndex = fibAnchor + float(canonicalIndex);
            float2 direction = HEXING_EYE_SafeNormalize2(float2(0.23 - offset.y, 0.17 + offset.x + frac(fibIndex * 0.000618)));
            float phase = fibIndex * 0.013 + phaseShift * (0.8 + frac(fibIndex * 0.019));
            float hatch = HEXING_EYE_HatchLine(p + offset * tapSpread, direction, density, phase, 0.72, 0.96);
            sumValue += hatch;
            sumWeight += 1.0;
        }
    }

    float mask = sumValue * HEXING_EYE_SafeRcp(sumWeight);
    return saturate((mask - 0.5) * max(0.10, contrast) + 0.5);
}

float HEXING_EYE_ProceduralBioSynthesisHatch(
    float2 uv,
    float patternScale,
    float tapSpread,
    float fibAnchor,
    float fibFlow,
    float density,
    float contrast,
    int tapCount,
    int reductionMode)
{
    int clampedTaps = clamp(tapCount, 1, HEXING_EYE_FIB_TAP_LIMIT);
    float2 p = uv * patternScale;
    float t = fibFlow * 0.125;
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int reductionStride = HEXING_EYE_GetFibonacciReductionStride(clampedTaps, reductionMode);

    [loop]
    for (int i = 0; i < HEXING_EYE_FIB_TAP_LIMIT; ++i)
    {
        if (i < clampedTaps)
        {
            int canonicalIndex = HEXING_EYE_GetFibonacciCanonicalIndexFast(i, clampedTaps, reductionMode, reductionStride);
            float2 offset = HEXING_EYE_FibonacciOffsetFromCanonical(canonicalIndex, fibAnchor);
            float fibIndex = fibAnchor + float(canonicalIndex);
            float2 direction = HEXING_EYE_SafeNormalize2(float2(0.23 - offset.y, 0.17 + offset.x + frac(fibIndex * 0.000618)));
            float phase = fibIndex * 0.013 + t * (0.8 + frac(fibIndex * 0.019));
            float hatch = HEXING_EYE_HatchLine(p + offset * tapSpread, direction, density, phase, 0.72, 0.96);
            sumValue += hatch;
            sumWeight += 1.0;
        }
    }

    float organicField = saturate(sumValue * HEXING_EYE_SafeRcp(sumWeight));
    return saturate((organicField - 0.5) * max(0.10, contrast * 1.15) + 0.5);
}

float HEXING_EYE_FibonacciTAAHatch(
    float2 uv,
    float tapSpread,
    float density,
    float contrast,
    float fibAnchor,
    int tapCount,
    int reductionMode)
{
    int clampedTaps = clamp(tapCount, 1, HEXING_EYE_FIB_TAP_LIMIT);
    float2 p = uv * (tapSpread * 6.5);
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int reductionStride = HEXING_EYE_GetFibonacciReductionStride(clampedTaps, reductionMode);

    [loop]
    for (int i = 0; i < HEXING_EYE_FIB_TAP_LIMIT; ++i)
    {
        if (i < clampedTaps)
        {
            int canonicalIndex = HEXING_EYE_GetFibonacciCanonicalIndexFast(i, clampedTaps, reductionMode, reductionStride);
            float2 offset = HEXING_EYE_FibonacciOffsetFromCanonical(canonicalIndex, fibAnchor);
            float fibIndex = fibAnchor + float(canonicalIndex);
            float2 direction = HEXING_EYE_SafeNormalize2(float2(0.23 - offset.y, 0.17 + offset.x + frac(fibIndex * 0.000618)));
            float phase = fibIndex * 0.013 + dot(uv * 128.0, float2(0.754, 0.569));
            float hatch = HEXING_EYE_HatchLine(p + offset * tapSpread, direction, density, phase, 0.62, 0.94);
            sumValue += hatch;
            sumWeight += 1.0;
        }
    }

    float mask = sumValue * HEXING_EYE_SafeRcp(sumWeight);
    float centered = abs(mask - 0.5) * 2.0;
    return saturate(pow(max(centered, 0.0), max(0.10, contrast)));
}

float HEXING_EYE_LogSpiralHatch(
    float2 uv,
    float patternScale,
    float tapSpread,
    float fibAnchor,
    float fibFlow,
    float density,
    float contrast,
    int tapCount,
    int reductionMode,
    float crossMix)
{
    int clampedTaps = clamp(tapCount, 1, HEXING_EYE_FIB_TAP_LIMIT);
    float2 p = uv * patternScale;
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int reductionStride = HEXING_EYE_GetFibonacciReductionStride(clampedTaps, reductionMode);

    [loop]
    for (int i = 0; i < HEXING_EYE_FIB_TAP_LIMIT; ++i)
    {
        if (i < clampedTaps)
        {
            int canonicalIndex = HEXING_EYE_GetFibonacciCanonicalIndexFast(i, clampedTaps, reductionMode, reductionStride);
            float2 offset = HEXING_EYE_FibonacciOffsetFromCanonical(canonicalIndex, fibAnchor);
            float tapNorm = (float(i) + 0.5) * HEXING_EYE_SafeRcp(float(HEXING_EYE_FIB_TAP_LIMIT));
            float fibIndex = fibAnchor + float(canonicalIndex);
            float2 directionA = HEXING_EYE_LogSpiralDirection(offset, fibIndex, uv, tapNorm, fibFlow);
            float2 directionB = HEXING_EYE_SafeNormalize2(float2(-directionA.y, directionA.x));
            float phaseA = fibIndex * 0.013 + fibFlow * 0.15 + dot(uv * (density * 48.0), float2(0.754, 0.569));
            float phaseB = phaseA + 1.57079632679;
            float hatchA = HEXING_EYE_HatchLine(p + offset * tapSpread, directionA, density, phaseA, 0.72, 0.96);
            float hatchB = HEXING_EYE_HatchLine(p - offset * tapSpread, directionB, density * 0.92, phaseB, 0.70, 0.95);
            float hatch = lerp(hatchA, max(hatchA, hatchB), saturate(crossMix));
            sumValue += hatch;
            sumWeight += 1.0;
        }
    }

    float mask = sumValue * HEXING_EYE_SafeRcp(sumWeight);
    return saturate((mask - 0.5) * max(0.10, contrast) + 0.5);
}

float HEXING_EYE_FiveStageBlendHatch(float2 uv, float depth, float baseScale, float contrast, int stageView)
{
    if (stageView == 1) return HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 0);
    if (stageView == 2) return HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 1);
    if (stageView == 3) return HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 2);
    if (stageView == 4) return HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 1);
    if (stageView == 5) return HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 0);

    float nearPattern = HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 0);
    float forwardPattern = HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 1);
    float centerPattern = HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 2);
    float backPattern = HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 1);
    float farPattern = HEXING_EYE_FiveStageHatch(uv, depth, baseScale, contrast, 0);

    float stagePos = saturate(depth);
    float blendWidth = max(0.05, HEXING_EYE_FiveStageBlendWidth);
    float wNear = 1.0 - saturate(abs(stagePos - 0.00) / blendWidth);
    float wForward = 1.0 - saturate(abs(stagePos - 0.25) / blendWidth);
    float wCenter = 1.0 - saturate(abs(stagePos - 0.50) / blendWidth);
    float wBack = 1.0 - saturate(abs(stagePos - 0.75) / blendWidth);
    float wFar = 1.0 - saturate(abs(stagePos - 1.00) / blendWidth);
    float wSum = max(0.00001, wNear + wForward + wCenter + wBack + wFar);
    return saturate((nearPattern * wNear + forwardPattern * wForward + centerPattern * wCenter + backPattern * wBack + farPattern * wFar) / wSum);
}

float HEXING_EYE_HatchPattern(
    int hatchMode,
    float2 uv,
    float depth,
    float luma,
    float spacing,
    float thickness,
    float contrast,
    float advancedPatternScale,
    float angleA,
    float angleB,
    float angleC,
    float phase,
    float jitter,
    float fibAnchor,
    float fibFlow,
    float fibDensity,
    float fibTapSpread,
    int fibTapCount,
    int fibReductionMode,
    float fiveStageBlendWidth,
    float spiralGrowth,
    float spiralTightness,
    int spiralBranchCount,
    int spiralRecursiveLevels,
    float spiralBranchBlend,
    float thresholdA,
    float thresholdB,
    float thresholdC)
{
    if (hatchMode == HEXING_EYE_HATCH_OFF)
    {
        return 0.0;
    }

    if (hatchMode == HEXING_EYE_HATCH_ORCHESTRATOR)
    {
        return HEXING_EYE_OrchestratorHatch(uv, depth, contrast);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_SMALL)
    {
        return HEXING_EYE_FiveStageHatch(uv, depth, advancedPatternScale, contrast, 0);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_MED_SMALL)
    {
        return HEXING_EYE_FiveStageHatch(uv, depth, advancedPatternScale, contrast, 1);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_VERY_SMALL)
    {
        return HEXING_EYE_FiveStageHatch(uv, depth, advancedPatternScale, contrast, 2);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_BLENDED)
    {
        return HEXING_EYE_FiveStageBlendHatch(uv, depth, advancedPatternScale, contrast, 0);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_NEAR)
    {
        return HEXING_EYE_FiveStageBlendHatch(uv, depth, advancedPatternScale, contrast, 1);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_FORWARD)
    {
        return HEXING_EYE_FiveStageBlendHatch(uv, depth, advancedPatternScale, contrast, 2);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_CENTER)
    {
        return HEXING_EYE_FiveStageBlendHatch(uv, depth, advancedPatternScale, contrast, 3);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_BACK)
    {
        return HEXING_EYE_FiveStageBlendHatch(uv, depth, advancedPatternScale, contrast, 4);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIVE_STAGE_FAR)
    {
        return HEXING_EYE_FiveStageBlendHatch(uv, depth, advancedPatternScale, contrast, 5);
    }

    if (hatchMode == HEXING_EYE_HATCH_FIBONACCI_BIO)
    {
        return HEXING_EYE_FibonacciBioHatch(uv, advancedPatternScale, fibTapSpread, fibAnchor, fibFlow, fibDensity, contrast, fibTapCount, fibReductionMode);
    }

    if (hatchMode == HEXING_EYE_HATCH_PROCEDURAL_BIO)
    {
        return HEXING_EYE_ProceduralBioSynthesisHatch(uv, advancedPatternScale, fibTapSpread, fibAnchor, fibFlow, fibDensity, contrast, fibTapCount, fibReductionMode);
    }

    if (hatchMode == HEXING_EYE_HATCH_CENTERED_FIBONACCI)
    {
        return HEXING_EYE_FibonacciTAAHatch(uv, fibTapSpread, fibDensity, contrast, fibAnchor, fibTapCount, fibReductionMode);
    }

    if (hatchMode == HEXING_EYE_HATCH_LOG_SPIRAL)
    {
        return HEXING_EYE_LogSpiralHatch(uv, advancedPatternScale, fibTapSpread, fibAnchor, fibFlow, fibDensity, contrast, fibTapCount, fibReductionMode, 0.0);
    }

    if (hatchMode == HEXING_EYE_HATCH_LOG_SPIRAL_CROSS)
    {
        return HEXING_EYE_LogSpiralHatch(uv, advancedPatternScale, fibTapSpread, fibAnchor, fibFlow, fibDensity, contrast, fibTapCount, fibReductionMode, 1.0);
    }

    float2 p = uv;
    float noise = HEXING_EYE_Hash21(floor(uv * 512.0) + phase);
    float2 warp = float2(noise - 0.5, frac(noise * 7.13) - 0.5) * jitter * 0.0015;
    p += warp;

    float lineA = HEXING_EYE_LineMask(p, angleA, spacing, thickness, phase * 0.17);
    float lineB = HEXING_EYE_LineMask(p, angleB, spacing * 0.92, thickness * 0.92, phase * -0.11 + depth * 0.3);
    float lineC = HEXING_EYE_LineMask(p, angleC, spacing * 0.85, thickness * 0.85, phase * 0.09 + depth * 0.45);

    if (hatchMode == HEXING_EYE_HATCH_DIAGONAL_A)
    {
        return saturate(pow(max(0.0, lineA), max(0.1, contrast)));
    }

    if (hatchMode == HEXING_EYE_HATCH_DIAGONAL_B)
    {
        return saturate(pow(max(0.0, lineB), max(0.1, contrast)));
    }

    if (hatchMode == HEXING_EYE_HATCH_THIN_DIAGONAL)
    {
        return saturate(pow(max(0.0, HEXING_EYE_LineMask(p, angleA, spacing * 1.15, thickness * 0.55, phase * 0.13)), max(0.1, contrast)));
    }

    if (hatchMode == HEXING_EYE_HATCH_SPARSE)
    {
        return saturate(pow(max(0.0, HEXING_EYE_LineMask(p, angleA, spacing * 1.45, thickness * 0.75, phase * 0.09)), max(0.1, contrast)) * (0.65 + 0.35 * (1.0 - luma)));
    }

    if (hatchMode == HEXING_EYE_HATCH_ORGANIC_SKETCH)
    {
        float organic = max(lineA, lineB * 0.85);
        float scribble = HEXING_EYE_LineMask(p + warp.yx * 2.0, angleC + 17.0, spacing * 1.35, thickness * 0.72, phase * 0.31);
        return saturate(pow(max(0.0, lerp(organic, max(organic, scribble), 0.45)), max(0.1, contrast * 0.9)));
    }

    if (hatchMode == HEXING_EYE_HATCH_ANIMATED)
    {
        float animated = HEXING_EYE_LineMask(p + float2(phase * 0.01, 0.0), angleA, spacing, thickness, phase * 0.4);
        return saturate(pow(max(0.0, animated), max(0.1, contrast)));
    }

    float bandA = step(luma, thresholdA);
    float bandB = step(luma, thresholdB);
    float bandC = step(luma, thresholdC);
    float layered = lineA * bandA;
    layered = max(layered, lineB * bandB);
    layered = max(layered, lineC * bandC);

    if (hatchMode == HEXING_EYE_HATCH_CROSS)
    {
        return saturate(pow(max(0.0, layered), max(0.1, contrast)));
    }

    if (hatchMode == HEXING_EYE_HATCH_EDGE_INK)
    {
        return saturate(pow(max(lineA, lineB), max(0.1, contrast)));
    }

    if (hatchMode == HEXING_EYE_HATCH_TECHNICAL)
    {
        float tech = max(HEXING_EYE_LineMask(p, angleA, spacing * 1.4, thickness * 0.5, phase * 0.07),
                         HEXING_EYE_LineMask(p, angleB, spacing * 1.65, thickness * 0.45, phase * -0.05));
        return saturate(pow(max(0.0, tech), max(0.1, contrast * 1.1)));
    }

    if (hatchMode == HEXING_EYE_HATCH_FAR_DETAIL)
    {
        float farPattern = max(lineA * 0.7, HEXING_EYE_LineMask(p, angleC, spacing * 0.55, thickness * 0.65, phase * 0.03));
        return saturate(pow(max(0.0, farPattern), max(0.1, contrast)));
    }

    return saturate(pow(max(0.0, layered), max(0.1, contrast)));
}

#endif

