#ifndef black_wand_PROCEDURAL_DEPTH_GLUE_FXH
#define black_wand_PROCEDURAL_DEPTH_GLUE_FXH

#include "black_wand_Primitive_Depth.fxh"
#include "black_wand_Procedural_SafeMath.fxh"

float black_wand_Proc_DepthRaw(float2 uv) { return black_wand_Primitive_DepthRaw(uv); }
float black_wand_Proc_DepthValue(float2 uv, int depthMode) { return black_wand_Primitive_DepthValue(uv, depthMode); }
float black_wand_Proc_DepthAvailable(float2 uv, int depthMode, float thresholdValue) { return black_wand_Primitive_DepthAvailable(uv, depthMode, thresholdValue); }
float black_wand_Proc_DepthNear(float2 uv, int depthMode, float nearEnd, float nearFeather) { return black_wand_Primitive_DepthNearMask(black_wand_Proc_DepthValue(uv, depthMode), nearEnd, nearFeather); }
float black_wand_Proc_DepthFar(float2 uv, int depthMode, float farStart, float farFeather) { return black_wand_Primitive_DepthFarMask(black_wand_Proc_DepthValue(uv, depthMode), farStart, farFeather); }
float black_wand_Proc_DepthDelta(float centerDepth, float sampleDepth, float gainValue) { return saturate(abs(centerDepth - sampleDepth) * gainValue); }
float black_wand_Proc_DepthSameLayer(float centerDepth, float sampleDepth, float thresholdValue, float softnessValue) { return black_wand_Primitive_DepthSameLayerWeight(centerDepth, sampleDepth, thresholdValue, softnessValue); }
float3 black_wand_Proc_DepthDebugColor(float depthValue, float availableValue) { return float3(depthValue, availableValue, 1.0 - depthValue); }

#endif
