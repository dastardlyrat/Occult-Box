#ifndef black_wand_PROCEDURAL_SOURCE_FXH
#define black_wand_PROCEDURAL_SOURCE_FXH

#include "black_wand_Procedural_UV.fxh"

float3 black_wand_Proc_SourceColor(float2 uv) { return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb; }
float4 black_wand_Proc_SourceColorAlpha(float2 uv) { return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)); }
float3 black_wand_Proc_SourceColorLOD(float2 uv) { return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb; }
float3 black_wand_Proc_SourceOffsetColor(float2 uv, float2 pixelOffset) { return black_wand_Proc_SourceColor(black_wand_Proc_UVAddPixels(uv, pixelOffset)); }
float3 black_wand_Proc_SourceOffsetColorLOD(float2 uv, float2 pixelOffset) { return black_wand_Proc_SourceColorLOD(black_wand_Proc_UVAddPixels(uv, pixelOffset)); }
float3 black_wand_Proc_SourceHorizontalPairAverage(float2 uv, float pixels) { return 0.5 * (black_wand_Proc_SourceOffsetColor(uv, float2(-pixels, 0.0)) + black_wand_Proc_SourceOffsetColor(uv, float2(pixels, 0.0))); }
float3 black_wand_Proc_SourceVerticalPairAverage(float2 uv, float pixels) { return 0.5 * (black_wand_Proc_SourceOffsetColor(uv, float2(0.0, -pixels)) + black_wand_Proc_SourceOffsetColor(uv, float2(0.0, pixels))); }
float3 black_wand_Proc_SourceSafeVisible(float3 colorValue) { return max(saturate(colorValue), float3(0.003, 0.003, 0.003)); }

#endif
