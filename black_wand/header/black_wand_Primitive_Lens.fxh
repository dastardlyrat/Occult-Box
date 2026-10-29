#ifndef black_wand_PRIMITIVE_LENS_FXH
#define black_wand_PRIMITIVE_LENS_FXH

#include "black_wand_Lens_Adapter.fxh"
#include "black_wand_Primitive_Safe.fxh"

float2 black_wand_Primitive_LensPixelOffset(int inputLensSource, int inputTapIndex, int inputTapCount, int inputReductionMode, float inputRadiusPixels, float inputRotationDegrees)
{
    int safeTapCount = clamp(inputTapCount, 1, black_wand_LENS_MAX_TAPS);
    int safeTapIndex = clamp(inputTapIndex, 0, safeTapCount - 1);
    float2 offsetUV = black_wand_Lens_UV(0.5.xx, inputLensSource, safeTapIndex, safeTapCount, inputReductionMode, inputRadiusPixels, inputRotationDegrees) - 0.5.xx;
    return offsetUV / max(ReShade::PixelSize, float2(0.000001, 0.000001));
}

float2 black_wand_Primitive_LensSampleUV(float2 inputUV, int inputLensSource, int inputTapIndex, int inputTapCount, int inputReductionMode, float inputRadiusPixels, float inputRotationDegrees)
{
    int safeTapCount = clamp(inputTapCount, 1, black_wand_LENS_MAX_TAPS);
    int safeTapIndex = clamp(inputTapIndex, 0, safeTapCount - 1);
    return black_wand_Primitive_SaturateUV(black_wand_Lens_UV(inputUV, inputLensSource, safeTapIndex, safeTapCount, inputReductionMode, inputRadiusPixels, inputRotationDegrees));
}

int black_wand_Primitive_LensActiveTapCount(int inputLensSource, int requestedTapCount, int activeTapWiring)
{
    return clamp(black_wand_Lens_ActiveTapCount(inputLensSource, requestedTapCount, activeTapWiring), 1, black_wand_LENS_MAX_TAPS);
}

float black_wand_Primitive_LensOffsetRadius01(int inputLensSource, int inputTapIndex)
{
    int safeTapCount = max(black_wand_Lens_CanonicalTapCount(inputLensSource), 1);
    int safeTapIndex = clamp(inputTapIndex, 0, safeTapCount - 1);
    float2 offsetValue = black_wand_Lens_CanonicalOffset(inputLensSource, safeTapIndex);
    return saturate(black_wand_Lens_OffsetRadius(offsetValue));
}

#endif
