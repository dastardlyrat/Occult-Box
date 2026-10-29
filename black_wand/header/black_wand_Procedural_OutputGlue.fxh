#ifndef black_wand_PROCEDURAL_OUTPUT_GLUE_FXH
#define black_wand_PROCEDURAL_OUTPUT_GLUE_FXH

#include "black_wand_Helper_Output.fxh"
#include "black_wand_Procedural_Color.fxh"

float4 black_wand_Proc_OutColor(float3 colorValue, float visibleFloor) { return black_wand_Helper_OutputColor(colorValue, visibleFloor); }
float4 black_wand_Proc_OutScalar(float scalarValue, float gainValue, float visibleFloor) { return black_wand_Helper_OutputScalar(scalarValue, gainValue, visibleFloor); }
float4 black_wand_Proc_OutSigned(float signedValue, float gainValue, float visibleFloor) { return black_wand_Helper_OutputSignedDelta(signedValue, gainValue, visibleFloor); }
float4 black_wand_Proc_OutDelta(float3 a, float3 b, float gainValue, float visibleFloor) { return black_wand_Helper_OutputColorDelta(a, b, gainValue, visibleFloor); }
float4 black_wand_Proc_OutMaskOverlay(float3 colorValue, float maskValue, float strengthValue, float visibleFloor) { return black_wand_Helper_OutputMaskOverlay(colorValue, maskValue, strengthValue, visibleFloor); }
float4 black_wand_Proc_OutHeat(float value, float visibleFloor) { return float4(max(black_wand_Proc_ColorHeat(value), float3(visibleFloor, visibleFloor, visibleFloor)), 1.0); }
float4 black_wand_Proc_OutFallback() { return float4(0.05, 0.0, 0.08, 1.0); }

#endif
