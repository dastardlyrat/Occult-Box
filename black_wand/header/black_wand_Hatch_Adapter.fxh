#ifndef black_wand_HATCH_ADAPTER_FXH
#define black_wand_HATCH_ADAPTER_FXH

// black wand additive hatch adapter. Defines hidden Hexing Eye compatibility constants, then wraps ../hexing_eye/hexing_eye.fxh.
#define HEXING_EYE_CAT_DEBUG "black wand / internal hidden hatch helper / 00 Debug"
#define HEXING_EYE_CAT_MAIN "black wand / internal hidden hatch helper / 01 Main Settings"
#define HEXING_EYE_CAT_SUB_PATTERN "black wand / internal hidden hatch helper / 02 Pattern"
#define HEXING_EYE_CAT_SUB_BANDS "black wand / internal hidden hatch helper / 02 Bands"
#define HEXING_EYE_CAT_SUB_MASKS "black wand / internal hidden hatch helper / 02 Masks"
#define HEXING_EYE_CAT_SUB_DETAIL "black wand / internal hidden hatch helper / 02 Detail"

static const float HEXING_EYE_Time = 0.0; // hidden internal helper constant; not exposed in ReShade menu

static const int HEXING_EYE_DebugView = 0; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DebugExposure = 5.000000; // hidden internal helper constant; not exposed in ReShade menu

static const int HEXING_EYE_HatchMode = 23; // hidden internal helper constant; not exposed in ReShade menu

static const int HEXING_EYE_ApplicationMask = 7; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchStrength = 0.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchSpacing = 8.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchThickness = 0.220000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchContrast = 1.250000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_AdvancedPatternScale = 860.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchAngleA = 35.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchAngleB = -35.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_HatchAngleC = 90.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_Jitter = 1.100000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_AnimationSpeed = 0.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FibonacciTapCount_UI = 55.000000; // hidden internal helper constant; not exposed in ReShade menu
#define HEXING_EYE_FibonacciTapCount int(round(HEXING_EYE_FibonacciTapCount_UI))

static const int HEXING_EYE_FibonacciReductionMode = 0; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FibonacciAnchor = 2584.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FibonacciFlow = 1.500000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FibonacciDensity = 2.050000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FibonacciTapSpread = 96.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FiveStageBlendWidth = 0.300000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_SpiralGrowth = 1.180000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_SpiralTightness = 1.050000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_SpiralBranchCount_UI = 5.000000; // hidden internal helper constant; not exposed in ReShade menu
#define HEXING_EYE_SpiralBranchCount int(round(HEXING_EYE_SpiralBranchCount_UI))

static const float HEXING_EYE_SpiralRecursiveLevels_UI = 3.000000; // hidden internal helper constant; not exposed in ReShade menu
#define HEXING_EYE_SpiralRecursiveLevels int(round(HEXING_EYE_SpiralRecursiveLevels_UI))

static const float HEXING_EYE_SpiralBranchBlend = 0.700000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_LumaThresholdA = 0.720000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_LumaThresholdB = 0.480000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_LumaThresholdC = 0.240000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_EdgeThreshold = 0.028000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DepthEdgeThreshold = 0.010000; // hidden internal helper constant; not exposed in ReShade menu

static const int HEXING_EYE_DepthInvert = 0; // hidden internal helper constant; not exposed in ReShade menu

static const int HEXING_EYE_DepthLinearizationMode = 0; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DepthTraceScale = 512.000000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DepthAvailabilityThreshold = 0.002500; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FarDepthStart = 0.580000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_FarDepthFeather = 0.200000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DepthRejectRadius = 1.500000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DepthRejectThreshold = 0.018000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_RadiusRing = 0.280000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_RadiusRingThickness = 0.020000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DetailRadiusPixels = 1.600000; // hidden internal helper constant; not exposed in ReShade menu

static const float HEXING_EYE_DetailGain = 2.200000; // hidden internal helper constant; not exposed in ReShade menu

#include "hexing_eye.fxh"

#ifndef black_wand_HATCH_OFF
#define black_wand_HATCH_OFF HEXING_EYE_HATCH_OFF
#endif
#ifndef black_wand_HATCH_DIAGONAL_A
#define black_wand_HATCH_DIAGONAL_A HEXING_EYE_HATCH_DIAGONAL_A
#endif
#ifndef black_wand_HATCH_DIAGONAL_B
#define black_wand_HATCH_DIAGONAL_B HEXING_EYE_HATCH_DIAGONAL_B
#endif
#ifndef black_wand_HATCH_CROSS
#define black_wand_HATCH_CROSS HEXING_EYE_HATCH_CROSS
#endif
#ifndef black_wand_HATCH_THIN_DIAGONAL
#define black_wand_HATCH_THIN_DIAGONAL HEXING_EYE_HATCH_THIN_DIAGONAL
#endif
#ifndef black_wand_HATCH_SPARSE
#define black_wand_HATCH_SPARSE HEXING_EYE_HATCH_SPARSE
#endif
#ifndef black_wand_HATCH_ORGANIC_SKETCH
#define black_wand_HATCH_ORGANIC_SKETCH HEXING_EYE_HATCH_ORGANIC_SKETCH
#endif
#ifndef black_wand_HATCH_EDGE_INK
#define black_wand_HATCH_EDGE_INK HEXING_EYE_HATCH_EDGE_INK
#endif
#ifndef black_wand_HATCH_TECHNICAL
#define black_wand_HATCH_TECHNICAL HEXING_EYE_HATCH_TECHNICAL
#endif
#ifndef black_wand_HATCH_FAR_DETAIL
#define black_wand_HATCH_FAR_DETAIL HEXING_EYE_HATCH_FAR_DETAIL
#endif
#ifndef black_wand_HATCH_FIBONACCI_BIO
#define black_wand_HATCH_FIBONACCI_BIO HEXING_EYE_HATCH_FIBONACCI_BIO
#endif
#ifndef black_wand_HATCH_LOG_SPIRAL
#define black_wand_HATCH_LOG_SPIRAL HEXING_EYE_HATCH_LOG_SPIRAL
#endif
#ifndef black_wand_HATCH_LOG_SPIRAL_CROSS
#define black_wand_HATCH_LOG_SPIRAL_CROSS HEXING_EYE_HATCH_LOG_SPIRAL_CROSS
#endif

float black_wand_Hatch_Evaluate(int hatchMode, float2 uv, float depth, float luma, float phase)
{
    return saturate(HEXING_EYE_HatchPattern(
        hatchMode,
        uv,
        depth,
        luma,
        HEXING_EYE_HatchSpacing,
        HEXING_EYE_HatchThickness,
        HEXING_EYE_HatchContrast,
        HEXING_EYE_AdvancedPatternScale,
        HEXING_EYE_HatchAngleA,
        HEXING_EYE_HatchAngleB,
        HEXING_EYE_HatchAngleC,
        phase,
        HEXING_EYE_Jitter,
        HEXING_EYE_FibonacciAnchor,
        HEXING_EYE_FibonacciFlow,
        HEXING_EYE_FibonacciDensity,
        HEXING_EYE_FibonacciTapSpread,
        HEXING_EYE_FibonacciTapCount,
        HEXING_EYE_FibonacciReductionMode,
        HEXING_EYE_FiveStageBlendWidth,
        HEXING_EYE_SpiralGrowth,
        HEXING_EYE_SpiralTightness,
        HEXING_EYE_SpiralBranchCount,
        HEXING_EYE_SpiralRecursiveLevels,
        HEXING_EYE_SpiralBranchBlend,
        HEXING_EYE_LumaThresholdA,
        HEXING_EYE_LumaThresholdB,
        HEXING_EYE_LumaThresholdC));
}

float black_wand_Hatch_DiagonalA(float2 uv, float phase)
{
    return HEXING_EYE_LineMask(uv, HEXING_EYE_HatchAngleA, HEXING_EYE_HatchSpacing, HEXING_EYE_HatchThickness, phase);
}

float black_wand_Hatch_DiagonalB(float2 uv, float phase)
{
    return HEXING_EYE_LineMask(uv, HEXING_EYE_HatchAngleB, HEXING_EYE_HatchSpacing, HEXING_EYE_HatchThickness, phase);
}

float black_wand_Hatch_Cross(float2 uv, float phase)
{
    return saturate(max(black_wand_Hatch_DiagonalA(uv, phase), black_wand_Hatch_DiagonalB(uv, phase * -0.61803398875)));
}

float black_wand_Hatch_AsWeight(float hatchValue, float strength)
{
    return saturate(lerp(1.0, hatchValue, saturate(strength)));
}

#endif

