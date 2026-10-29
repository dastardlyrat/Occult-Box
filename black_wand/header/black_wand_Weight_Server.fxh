#ifndef black_wand_WEIGHT_SERVER_FXH
#define black_wand_WEIGHT_SERVER_FXH

#include "black_wand_Lens_Adapter.fxh"

#ifndef black_wand_WEIGHT_UNIFORM
#define black_wand_WEIGHT_UNIFORM 0
#endif
#ifndef black_wand_WEIGHT_CENTER_SOFT
#define black_wand_WEIGHT_CENTER_SOFT 1
#endif
#ifndef black_wand_WEIGHT_CENTER_STRONG
#define black_wand_WEIGHT_CENTER_STRONG 2
#endif
#ifndef black_wand_WEIGHT_OUTER_RING
#define black_wand_WEIGHT_OUTER_RING 3
#endif
#ifndef black_wand_WEIGHT_RADIAL_FALLOFF
#define black_wand_WEIGHT_RADIAL_FALLOFF 4
#endif

float black_wand_Weight_Evaluate(int weightMode, float2 canonicalOffset, int logicalIndex, int activeTapCount, float centerStrength, float falloffPower)
{
    if (weightMode == black_wand_WEIGHT_UNIFORM) return 1.0;

    float radius = saturate(length(canonicalOffset));
    float centerMask = (logicalIndex <= 0) ? 1.0 : 0.0;
    float nonCenterMask = 1.0 - centerMask;

    if (weightMode == black_wand_WEIGHT_CENTER_SOFT)
    {
        return max(0.0001, lerp(1.0 - radius * 0.65, centerStrength, centerMask));
    }

    if (weightMode == black_wand_WEIGHT_CENTER_STRONG)
    {
        return max(0.0001, lerp(pow(saturate(1.0 - radius * 0.75), max(0.25, falloffPower)), centerStrength, centerMask));
    }

    if (weightMode == black_wand_WEIGHT_OUTER_RING)
    {
        return max(0.0001, lerp(0.25, max(0.0001, pow(saturate(radius), max(0.25, falloffPower))), nonCenterMask));
    }

    if (weightMode == black_wand_WEIGHT_RADIAL_FALLOFF)
    {
        return max(0.0001, pow(saturate(1.0 - radius * 0.75), max(0.25, falloffPower)));
    }

    return 1.0;
}

#endif
