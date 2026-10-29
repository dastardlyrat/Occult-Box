#ifndef black_wand_PROCEDURAL_COLOR_FXH
#define black_wand_PROCEDURAL_COLOR_FXH

#include "black_wand_Procedural_SafeMath.fxh"

float black_wand_Proc_ColorLuma(float3 colorValue) { return dot(colorValue, float3(0.2126, 0.7152, 0.0722)); }
float black_wand_Proc_ColorLuma601(float3 colorValue) { return dot(colorValue, float3(0.299, 0.587, 0.114)); }
float black_wand_Proc_ColorChromaSpan(float3 colorValue) { return black_wand_Proc_Span3(colorValue); }
float black_wand_Proc_ColorSaturationApprox(float3 colorValue) { return black_wand_Proc_SafeDivide(black_wand_Proc_ColorChromaSpan(colorValue), max(black_wand_Proc_Max3(colorValue), 0.000001)); }
float black_wand_Proc_ColorWarmBias(float3 colorValue) { return saturate(colorValue.r - colorValue.b + 0.5); }
float black_wand_Proc_ColorCoolBias(float3 colorValue) { return saturate(colorValue.b - colorValue.r + 0.5); }
float black_wand_Proc_ColorGreenBias(float3 colorValue) { return saturate(colorValue.g - max(colorValue.r, colorValue.b) + 0.5); }
float3 black_wand_Proc_ColorToLuma(float3 colorValue) { float l = black_wand_Proc_ColorLuma(colorValue); return float3(l, l, l); }
float3 black_wand_Proc_ColorSaturateAmount(float3 colorValue, float amount) { float l = black_wand_Proc_ColorLuma(colorValue); return saturate(lerp(float3(l, l, l), colorValue, amount)); }
float3 black_wand_Proc_ColorContrastAmount(float3 colorValue, float amount) { return saturate(float3(0.5, 0.5, 0.5) + (colorValue - float3(0.5, 0.5, 0.5)) * amount); }
float3 black_wand_Proc_ColorAddSignedDetail(float3 colorValue, float3 detailValue, float strengthValue) { return saturate(colorValue + detailValue * strengthValue); }
float3 black_wand_Proc_ColorDeltaAbs(float3 a, float3 b, float gainValue) { return saturate(abs(a - b) * gainValue); }
float black_wand_Proc_ColorLumaDeltaAbs(float3 a, float3 b) { return abs(black_wand_Proc_ColorLuma(a) - black_wand_Proc_ColorLuma(b)); }
float3 black_wand_Proc_ColorHeat(float value) { float v = saturate(value); return saturate(float3(v * 2.0, 1.0 - abs(v * 2.0 - 1.0), (1.0 - v) * 2.0)); }
float3 black_wand_Proc_ColorMaskTint(float3 colorValue, float maskValue, float strengthValue) { return saturate(lerp(colorValue, float3(maskValue, 0.0, 1.0 - maskValue), saturate(strengthValue))); }
float3 black_wand_Proc_ColorFloor(float3 colorValue, float floorValue) { return max(saturate(colorValue), saturate(floorValue).xxx); }

#endif
