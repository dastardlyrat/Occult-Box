#ifndef black_wand_PROCEDURAL_LENS_GLUE_FXH
#define black_wand_PROCEDURAL_LENS_GLUE_FXH

#include "black_wand_Primitive_Lens.fxh"
#include "black_wand_Procedural_Source.fxh"
#include "black_wand_Procedural_Color.fxh"

int black_wand_Proc_LensActiveCount(int lensSource, int requestedTapCount, int activeTapWiring) { return black_wand_Primitive_LensActiveTapCount(lensSource, requestedTapCount, activeTapWiring); }
int black_wand_Proc_LensFirstMovingTap(int activeTapCount) { return min(max(activeTapCount - 1, 0), 1); }
float2 black_wand_Proc_LensTapUV(float2 uv, int lensSource, int tapIndex, int tapCount, int reductionMode, float radiusPixels, float rotationDegrees) { return black_wand_Primitive_LensSampleUV(uv, lensSource, tapIndex, tapCount, reductionMode, radiusPixels, rotationDegrees); }
float3 black_wand_Proc_LensTapColor(float2 uv, int lensSource, int tapIndex, int tapCount, int reductionMode, float radiusPixels, float rotationDegrees) { return black_wand_Proc_SourceColor(black_wand_Proc_LensTapUV(uv, lensSource, tapIndex, tapCount, reductionMode, radiusPixels, rotationDegrees)); }
float3 black_wand_Proc_LensFirstColor(float2 uv, int lensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees) { int c = black_wand_Proc_LensActiveCount(lensSource, requestedTapCount, activeTapWiring); int t = black_wand_Proc_LensFirstMovingTap(c); return black_wand_Proc_LensTapColor(uv, lensSource, t, c, reductionMode, radiusPixels, rotationDegrees); }
float black_wand_Proc_LensFirstLumaDelta(float2 uv, int lensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees) { float3 c = black_wand_Proc_SourceColor(uv); float3 s = black_wand_Proc_LensFirstColor(uv, lensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees); return black_wand_Proc_ColorLumaDeltaAbs(c, s); }
float3 black_wand_Proc_LensFirstDeltaColor(float2 uv, int lensSource, int requestedTapCount, int activeTapWiring, int reductionMode, float radiusPixels, float rotationDegrees, float gainValue) { return black_wand_Proc_ColorDeltaAbs(black_wand_Proc_SourceColor(uv), black_wand_Proc_LensFirstColor(uv, lensSource, requestedTapCount, activeTapWiring, reductionMode, radiusPixels, rotationDegrees), gainValue); }
float black_wand_Proc_LensTapRadius01(int lensSource, int tapIndex) { return black_wand_Primitive_LensOffsetRadius01(lensSource, tapIndex); }

#endif
