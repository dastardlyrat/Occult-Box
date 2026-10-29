#ifndef black_wand_PROCEDURAL_COMPLEX_GLUE_FXH
#define black_wand_PROCEDURAL_COMPLEX_GLUE_FXH

#include "black_wand_Complex_Helper_All.fxh"
#include "black_wand_Procedural_Color.fxh"

float black_wand_Proc_AOFromDepthDelta(float centerDepth, float sampleDepth, float depthBias, float occlusionGain) { return black_wand_Complex_AO_NearOcclusion(centerDepth, sampleDepth, depthBias, occlusionGain); }
float3 black_wand_Proc_AOApply(float3 colorValue, float occlusionValue, float strengthValue) { return black_wand_Complex_AO_Apply(colorValue, occlusionValue, strengthValue); }
float black_wand_Proc_AAEdgeFromDelta(float firstTapEdgeValue, float thresholdValue, float featherValue) { return black_wand_Complex_AA_EdgeMask(firstTapEdgeValue, thresholdValue, featherValue); }
float3 black_wand_Proc_AAApply(float3 inputColor, float3 blendedColor, float edgeMaskValue, float strengthValue) { return black_wand_Complex_AA_ApplyEdgeBlend(inputColor, blendedColor, edgeMaskValue, strengthValue); }
float2 black_wand_Proc_SSRReflectDir(float2 depthGradientValue, float fallbackAngle) { return black_wand_Complex_SSR_ReflectDirection(depthGradientValue, fallbackAngle); }
float2 black_wand_Proc_SSRReflectionUV(float2 inputUV, float2 reflectDirection, float rayDistancePixels) { return black_wand_Complex_SSR_ReflectionUV(inputUV, reflectDirection, rayDistancePixels); }
float3 black_wand_Proc_SSRComposite(float3 inputColor, float3 reflectedColor, float confidenceValue, float strengthValue) { return black_wand_Complex_SSR_Composite(inputColor, reflectedColor, confidenceValue, strengthValue); }
float3 black_wand_Proc_DetailSharpen(float3 inputColor, float3 detailDelta, float strengthValue) { return black_wand_Complex_Detail_Sharpen(inputColor, detailDelta, strengthValue); }
float3 black_wand_Proc_ToneContrast(float3 inputColor, float strengthValue) { return black_wand_Complex_Tone_Contrast(inputColor, strengthValue); }
float3 black_wand_Proc_ToneSaturation(float3 inputColor, float strengthValue) { return black_wand_Complex_Tone_Saturation(inputColor, strengthValue); }

#endif
