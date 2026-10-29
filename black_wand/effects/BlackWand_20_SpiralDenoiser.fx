#ifndef BW_RESTORE_XCOM_HOTFIX_SAFE_NUMERIC_FXH
#define BW_RESTORE_XCOM_HOTFIX_SAFE_NUMERIC_FXH 1
float BW_RESTORE_XCOM_SafePow(float baseValue, float exponentValue)
{
    float safeBase = max(abs(baseValue), 0.0);
    return (safeBase <= 0.0) ? 0.0 : exp(log(safeBase) * exponentValue);
}
int BW_RESTORE_XCOM_IntDivNoWarn(int value, int divisor)
{
    float safeDivisor = max(abs(float(divisor)), 1.0);
    float quotient = floor(float(value) / safeDivisor);
    return int(quotient);
}
int BW_RESTORE_XCOM_IntModuloNoWarn(int value, int modulus)
{
    float safeModulus = max(abs(float(modulus)), 1.0);
    float quotient = floor(float(value) / safeModulus);
    return int(float(value) - safeModulus * quotient);
}
#define pow BW_RESTORE_XCOM_SafePow
#endif
// @BlackWand clean user-menu filter: @BlackWand - Spiral Denoiser. Primitive-based transpile from BlackWand binary-tree/spiral denoiser queue.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Denoise_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Spiral Denoiser"; ui_category = "@BlackWand - Spiral Denoiser / 99 Advanced / Debug";
 ui_items = "Final Image\0Denoised Candidate\0Noise Estimate\0Edge Protect\0Blend Amount\0"; ui_tooltip = "Final Image shows denoising. Diagnostics show candidate color, noise estimate, protected edges, and final blend amount.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Denoise_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Spiral Denoiser / 01 Controls"; ui_min = 0.0; ui_max = 1.5; ui_step = 0.001; ui_tooltip = "Overall amount of denoising applied."; > = 0.52;
uniform float BWBlackWandX_Denoise_DetailReturn < ui_type = "slider"; ui_label = "Return Fine Detail"; ui_category = "@BlackWand - Spiral Denoiser / 01 Controls"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Adds some original detail back after denoising to avoid plastic blur."; > = 0.28;
uniform float BWBlackWandX_Denoise_Radius < ui_type = "slider"; ui_label = "Spiral Radius (px)"; ui_category = "@BlackWand - Spiral Denoiser / 01 Controls";
 ui_min = 0.25; ui_max = 16.0; ui_step = 0.05; ui_tooltip = "Base radius for the fixed spiral sample set."; > = 1.4;
uniform float BWBlackWandX_Denoise_Rotation <
    ui_type = "slider";
    ui_label = "Denoise Rotation";
    ui_category = "@BlackWand - Spiral Denoiser / 99 Advanced / Sampling";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Rotates the spiral denoise sample pattern.";
    ui_category_closed = true;
> = 0.0;
uniform float BWBlackWandX_Denoise_NoiseGain < ui_type = "slider"; ui_label = "Noise Sensitivity"; ui_category = "@BlackWand - Spiral Denoiser / 01 Controls";
 ui_min = 0.0; ui_max = 32.0; ui_step = 0.01; ui_tooltip = "Amplifies the local difference used to decide where denoising is useful."; > = 7.0;
uniform float BWBlackWandX_Denoise_EdgeGain <
    ui_type = "slider";
    ui_label = "Edge Preserve Sensitivity";
    ui_category = "@BlackWand - Spiral Denoiser / 99 Advanced / Edge";
    ui_min = 0.0;
    ui_max = 48.0;
    ui_step = 0.01;
    ui_tooltip = "Raises edge preservation during denoise. Higher values protect more edges from smoothing.";
    ui_category_closed = true;
> = 12.0;
uniform float BWBlackWandX_Denoise_EdgeProtect < ui_type = "slider"; ui_label = "Protect Edges"; ui_category = "@BlackWand - Spiral Denoiser / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Reduces denoising across protected edges."; > = 0.80;
static const float BWBlackWandX_Denoise_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float2 BWBlackWandX_Denoise_Rot(float2 v, float degreesValue)
{
    float a = radians(degreesValue);
    float s = sin(a);
    float c = cos(a);
    return float2(v.x * c - v.y * s, v.x * s + v.y * c);
}

float4 BWBlackWandX_Denoise_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float r = BWBlackWandX_Denoise_Radius;
    float2 o1 = BWBlackWandX_Denoise_Rot(float2( 0.754,  0.000) * r, BWBlackWandX_Denoise_Rotation);
    float2 o2 = BWBlackWandX_Denoise_Rot(float2(-0.612,  0.560) * r, BWBlackWandX_Denoise_Rotation);
    float2 o3 = BWBlackWandX_Denoise_Rot(float2( 0.140, -1.044) * r, BWBlackWandX_Denoise_Rotation);
    float2 o4 = BWBlackWandX_Denoise_Rot(float2( 0.924,  0.852) * r, BWBlackWandX_Denoise_Rotation);
    float2 o5 = BWBlackWandX_Denoise_Rot(float2(-1.284, -0.228) * r, BWBlackWandX_Denoise_Rotation);
    float2 o6 = BWBlackWandX_Denoise_Rot(float2( 0.512, -1.416) * r, BWBlackWandX_Denoise_Rotation);
    float3 s1 = black_wand_Proc_SourceOffsetColor(uv, o1);
    float3 s2 = black_wand_Proc_SourceOffsetColor(uv, o2);
    float3 s3 = black_wand_Proc_SourceOffsetColor(uv, o3);
    float3 s4 = black_wand_Proc_SourceOffsetColor(uv, o4);
    float3 s5 = black_wand_Proc_SourceOffsetColor(uv, o5);
    float3 s6 = black_wand_Proc_SourceOffsetColor(uv, o6);
    float3 denoised = saturate((sourceColor * 2.0 + s1 + s2 + s3 + s4 + s5 + s6) * 0.125);
    float3 detailDelta = sourceColor - denoised;
    float noiseEstimate = saturate(abs(black_wand_BWT_Luma(detailDelta)) * BWBlackWandX_Denoise_NoiseGain);
    float edgeProtect = black_wand_BWT_LumaEdge(uv, BWBlackWandX_Denoise_EdgeGain);
    float blendAmount = saturate(BWBlackWandX_Denoise_Strength * noiseEstimate * lerp(1.0, 1.0 - edgeProtect, BWBlackWandX_Denoise_EdgeProtect));
    float3 candidate = saturate(denoised + detailDelta * BWBlackWandX_Denoise_DetailReturn);
    float3 outputColor = lerp(sourceColor, candidate, blendAmount);
    if (BWBlackWandX_Denoise_DebugView == 1) return black_wand_Proc_OutColor(candidate, BWBlackWandX_Denoise_DebugFloor);
    if (BWBlackWandX_Denoise_DebugView == 2) return black_wand_Proc_OutScalar(noiseEstimate, 1.0, BWBlackWandX_Denoise_DebugFloor);
    if (BWBlackWandX_Denoise_DebugView == 3) return black_wand_Proc_OutScalar(edgeProtect, 1.0, BWBlackWandX_Denoise_DebugFloor);
    if (BWBlackWandX_Denoise_DebugView == 4) return black_wand_Proc_OutScalar(blendAmount, 1.0, BWBlackWandX_Denoise_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Denoise_DebugFloor);
}

technique BlackWand_SpiralDenoiser < ui_label = "@BlackWand - Spiral Denoiser"; ui_tooltip = "Fixed-tap spiral denoiser with edge protection and detail return; no dynamic sample loops."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Denoise_PS; }
}

