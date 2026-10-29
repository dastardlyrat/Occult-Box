#ifndef black_wand_PRIMITIVE_GATE_FXH
#define black_wand_PRIMITIVE_GATE_FXH

#include "black_wand_Gate_Server.fxh"

float black_wand_Primitive_DepthGateValue(int depthGateMode, float centerDepth, float sampleDepth, float depthAvailable, float rejectThreshold, float rejectSoftness, float farStart, float farFeather, float nearEnd, float nearFeather, int depthMissingMode)
{
    return saturate(black_wand_Gate_DepthSampleEx(depthGateMode, centerDepth, sampleDepth, depthAvailable, rejectThreshold, rejectSoftness, farStart, farFeather, nearEnd, nearFeather, depthMissingMode));
}

float black_wand_Primitive_GateAccepted(float gateValue)
{
    return step(0.0001, saturate(gateValue));
}

float black_wand_Primitive_GateRejected(float gateValue)
{
    return 1.0 - black_wand_Primitive_GateAccepted(gateValue);
}

#endif
