#ifndef black_wand_PROCEDURAL_GATE_GLUE_FXH
#define black_wand_PROCEDURAL_GATE_GLUE_FXH

#include "black_wand_Primitive_Gate.fxh"
#include "black_wand_Procedural_SafeMath.fxh"

float black_wand_Proc_DepthGate(int gateMode, float centerDepth, float sampleDepth, float depthAvailable, float rejectThreshold, float rejectSoftness, float farStart, float farFeather, float nearEnd, float nearFeather, int depthMissingMode) { return black_wand_Primitive_DepthGateValue(gateMode, centerDepth, sampleDepth, depthAvailable, rejectThreshold, rejectSoftness, farStart, farFeather, nearEnd, nearFeather, depthMissingMode); }
float black_wand_Proc_GateAccept(float gateValue) { return black_wand_Primitive_GateAccepted(gateValue); }
float black_wand_Proc_GateReject(float gateValue) { return black_wand_Primitive_GateRejected(gateValue); }
float black_wand_Proc_GateWeight(float gateValue, float weightValue) { return saturate(gateValue) * saturate(weightValue); }
float3 black_wand_Proc_GateDebug(float gateValue, float acceptedValue, float depthAvailable) { return float3(saturate(gateValue), saturate(acceptedValue), saturate(depthAvailable)); }

#endif
