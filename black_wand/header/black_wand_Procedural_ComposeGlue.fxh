#ifndef black_wand_PROCEDURAL_COMPOSE_GLUE_FXH
#define black_wand_PROCEDURAL_COMPOSE_GLUE_FXH

#include "black_wand_Procedural_SafeMath.fxh"
#include "black_wand_Procedural_Color.fxh"

float black_wand_Proc_ComposeBlendAmount(float blendStrength, float outputBlendMask, float hatchFinalWeight) { return saturate(blendStrength * lerp(1.0, outputBlendMask, saturate(outputBlendMask)) * hatchFinalWeight); }
float3 black_wand_Proc_ComposeMaskedBlend(float3 sourceColor, float3 effectColor, float blendStrength, float outputBlendMask) { return saturate(lerp(sourceColor, effectColor, saturate(blendStrength * outputBlendMask))); }
float3 black_wand_Proc_ComposeAdditive(float3 sourceColor, float3 addColor, float amount) { return saturate(sourceColor + addColor * saturate(amount)); }
float3 black_wand_Proc_ComposeMultiply(float3 sourceColor, float3 multiplyColor, float amount) { return saturate(lerp(sourceColor, sourceColor * multiplyColor, saturate(amount))); }
float3 black_wand_Proc_ComposeScreen(float3 sourceColor, float3 screenColor, float amount) { float3 oneValue = float3(1.0, 1.0, 1.0); float3 screenResult = oneValue - (oneValue - sourceColor) * (oneValue - screenColor); return saturate(lerp(sourceColor, screenResult, saturate(amount))); }
float3 black_wand_Proc_ComposeDebugSplit(float a, float b, float c) { return saturate(float3(a, b, c)); }

#endif
