#ifndef black_wand_PROCEDURAL_SAFEMATH_FXH
#define black_wand_PROCEDURAL_SAFEMATH_FXH

float black_wand_Proc_Saturate(float value) { return saturate(value); }
float2 black_wand_Proc_Saturate2(float2 value) { return saturate(value); }
float3 black_wand_Proc_Saturate3(float3 value) { return saturate(value); }
float black_wand_Proc_Abs(float value) { return abs(value); }
float3 black_wand_Proc_Abs3(float3 value) { return abs(value); }
float black_wand_Proc_MaxEpsilon(float value) { return max(abs(value), 0.000001); }
float black_wand_Proc_SafeDivide(float numeratorValue, float denominatorValue) { return numeratorValue / black_wand_Proc_MaxEpsilon(denominatorValue); }
float black_wand_Proc_Remap01(float value, float lowValue, float highValue) { return saturate((value - lowValue) / black_wand_Proc_MaxEpsilon(highValue - lowValue)); }
float black_wand_Proc_SmoothRange(float value, float lowValue, float highValue) { return smoothstep(lowValue, highValue, value); }
float black_wand_Proc_Invert01(float value) { return 1.0 - saturate(value); }
float black_wand_Proc_Max3(float3 value) { return max(max(value.r, value.g), value.b); }
float black_wand_Proc_Min3(float3 value) { return min(min(value.r, value.g), value.b); }
float black_wand_Proc_Span3(float3 value) { return black_wand_Proc_Max3(value) - black_wand_Proc_Min3(value); }
float black_wand_Proc_SafePow01(float baseValue, float exponentValue) { return pow(saturate(baseValue), max(0.000001, exponentValue)); }
float black_wand_Proc_SignedTo01(float value) { return saturate(value * 0.5 + 0.5); }
float black_wand_Proc_ThresholdHard(float value, float thresholdValue) { return step(thresholdValue, value); }
float black_wand_Proc_ThresholdSoft(float value, float thresholdValue, float featherValue) { return smoothstep(thresholdValue - featherValue, thresholdValue + featherValue, value); }
float3 black_wand_Proc_Lerp3(float3 a, float3 b, float amount) { return lerp(a, b, saturate(amount)); }
float black_wand_Proc_Multiply01(float a, float b) { return saturate(a) * saturate(b); }
float black_wand_Proc_Union01(float a, float b) { return max(saturate(a), saturate(b)); }
float black_wand_Proc_Intersect01(float a, float b) { return min(saturate(a), saturate(b)); }
float black_wand_Proc_Exclude01(float sourceValue, float rejectValue) { return saturate(sourceValue) * (1.0 - saturate(rejectValue)); }

#endif
