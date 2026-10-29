#ifndef black_wand_PROCEDURAL_MASK_GLUE_FXH
#define black_wand_PROCEDURAL_MASK_GLUE_FXH

#include "black_wand_Primitive_Mask.fxh"
#include "black_wand_Procedural_SafeMath.fxh"
#include "black_wand_Procedural_Color.fxh"

float black_wand_Proc_InputMask(float inputMaskSource, float2 uv, float3 colorValue) { return black_wand_Primitive_InputMaskValue(int(inputMaskSource), uv, colorValue); }
float black_wand_Proc_SampleWeightMask(float sampleWeightMaskSource, float2 uv, float3 colorValue) { return black_wand_Primitive_SampleWeightMaskValue(int(sampleWeightMaskSource), uv, colorValue); }
float black_wand_Proc_OutputBlendMask(float outputBlendMaskSource, float2 uv, float3 colorValue) { return black_wand_Primitive_OutputBlendMaskValue(int(outputBlendMaskSource), uv, colorValue); }
float black_wand_Proc_DebugMask(float debugMaskSource, float2 uv, float3 colorValue) { return black_wand_Primitive_DebugMaskValue(int(debugMaskSource), uv, colorValue); }
float black_wand_Proc_MaskInfluence(float baseWeight, float maskValue, float influenceValue) { return black_wand_Primitive_MaskApplyInfluence(baseWeight, maskValue, influenceValue); }
float black_wand_Proc_MaskAnd(float a, float b) { return black_wand_Proc_Intersect01(a, b); }
float black_wand_Proc_MaskOr(float a, float b) { return black_wand_Proc_Union01(a, b); }
float black_wand_Proc_MaskExclude(float sourceMask, float rejectMask) { return black_wand_Proc_Exclude01(sourceMask, rejectMask); }
float black_wand_Proc_MaskInvert(float maskValue) { return black_wand_Proc_Invert01(maskValue); }
float3 black_wand_Proc_MaskTint(float3 colorValue, float maskValue, float strengthValue) { return black_wand_Proc_ColorMaskTint(colorValue, maskValue, strengthValue); }
float3 black_wand_Proc_MaskOverlay(float3 colorValue, float maskValue, float overlayStrength) { return black_wand_Primitive_MaskOverlayColor(colorValue, maskValue, overlayStrength); }

#endif
