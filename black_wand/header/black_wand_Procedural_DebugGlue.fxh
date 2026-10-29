#ifndef black_wand_PROCEDURAL_DEBUG_GLUE_FXH
#define black_wand_PROCEDURAL_DEBUG_GLUE_FXH

#include "black_wand_Procedural_OutputGlue.fxh"
#include "black_wand_Procedural_Color.fxh"

float3 black_wand_Proc_DebugScalarGray(float value) { return saturate(value).xxx; }
float3 black_wand_Proc_DebugScalarHeat(float value) { return black_wand_Proc_ColorHeat(value); }
float3 black_wand_Proc_DebugSigned(float value) { return float3(saturate(value), 0.0, saturate(-value)); }
float3 black_wand_Proc_DebugMaskRoles(float inputMask, float sampleWeightMask, float outputBlendMask) { return saturate(float3(inputMask, sampleWeightMask, outputBlendMask)); }
float3 black_wand_Proc_DebugGateWeightDepth(float gateValue, float weightValue, float depthAvailable) { return saturate(float3(gateValue, weightValue, depthAvailable)); }
float3 black_wand_Proc_DebugLensDelta(float3 centerColor, float3 tapColor, float gainValue) { return black_wand_Proc_ColorDeltaAbs(centerColor, tapColor, gainValue); }
float4 black_wand_Proc_DebugOut(float3 colorValue, float visibleFloor) { return black_wand_Proc_OutColor(colorValue, visibleFloor); }

#endif
