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
// @BlackWand clean user-menu filter: @BlackWand - Micro Detail Clarity. Primitive-based transpile from BlackWand detail/richness and sharp clarity variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Micro_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Micro Detail Clarity"; ui_category = "@BlackWand - Micro Detail Clarity / 99 Advanced / Debug";
 ui_items = "Final Image\0Detail Delta\0Protected Edges\0Apply Mask\0Clarity Candidate\0"; ui_tooltip = "Final Image shows the clarity pass. Diagnostics isolate detail, protected edges, apply mask, and candidate output.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Micro_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Micro Detail Clarity / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall mix of the micro-detail clarity result into the image."; > = 0.75;
uniform float BWBlackWandX_Micro_DetailAmount < ui_type = "slider"; ui_label = "Micro Detail Amount"; ui_category = "@BlackWand - Micro Detail Clarity / 01 Controls"; ui_min = 0.0; ui_max = 4.0; ui_step = 0.001; ui_tooltip = "Strength of fine detail enhancement."; > = 0.95;
uniform float BWBlackWandX_Micro_LocalContrast < ui_type = "slider"; ui_label = "Local Contrast"; ui_category = "@BlackWand - Micro Detail Clarity / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Small contrast lift applied after detail recovery."; > = 0.25;
uniform float BWBlackWandX_Micro_Radius < ui_type = "slider"; ui_label = "Detail Radius (px)"; ui_category = "@BlackWand - Micro Detail Clarity / 01 Controls"; ui_min = 0.25; ui_max = 8.0; ui_step = 0.05; ui_tooltip = "Radius used to isolate micro detail from the local average."; > = 1.0;
uniform float BWBlackWandX_Micro_EdgeProtect < ui_type = "slider"; ui_label = "Protect Harsh Edges"; ui_category = "@BlackWand - Micro Detail Clarity / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Reduces clarity on strong edges to avoid halos."; > = 0.65;
uniform float BWBlackWandX_Micro_EdgeGain <
    ui_type = "slider";
    ui_label = "Micro Edge Sensitivity";
    ui_category = "@BlackWand - Micro Detail Clarity / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 48.0;
    ui_step = 0.01;
    ui_tooltip = "Amplifies small local edges before clarity is applied.";
    ui_category_closed = true;
> = 14.0;
static const int BWBlackWandX_Micro_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Micro_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Micro_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Micro_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float3 detailDelta = BWBlackWandX_DetailDelta(uv, BWBlackWandX_Micro_Radius);
    float edgeMask = black_wand_BWT_LumaEdge(uv, BWBlackWandX_Micro_EdgeGain);
    float protectMask = lerp(1.0, 1.0 - edgeMask, saturate(BWBlackWandX_Micro_EdgeProtect));
    float3 detailColor = saturate(sourceColor + detailDelta * BWBlackWandX_Micro_DetailAmount * protectMask);
    float3 contrastColor = black_wand_Proc_ToneContrast(detailColor, 1.0 + BWBlackWandX_Micro_LocalContrast);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Micro_ApplyMask, uv, sourceColor, BWBlackWandX_Micro_ApplyMaskStrength);
    float3 outputColor = lerp(sourceColor, contrastColor, saturate(BWBlackWandX_Micro_Strength) * applyMask);
    if (BWBlackWandX_Micro_DebugView == 1) return black_wand_Proc_OutSigned(black_wand_BWT_Luma(detailDelta), 8.0, BWBlackWandX_Micro_DebugFloor);
    if (BWBlackWandX_Micro_DebugView == 2) return black_wand_Proc_OutScalar(edgeMask, 1.0, BWBlackWandX_Micro_DebugFloor);
    if (BWBlackWandX_Micro_DebugView == 3) return black_wand_Proc_OutScalar(applyMask, 1.0, BWBlackWandX_Micro_DebugFloor);
    if (BWBlackWandX_Micro_DebugView == 4) return black_wand_Proc_OutColor(contrastColor, BWBlackWandX_Micro_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Micro_DebugFloor);
}

technique BlackWand_MicroDetail_Clarity < ui_label = "@BlackWand - Micro Detail Clarity"; ui_tooltip = "Fine detail clarity pass with edge protection, intended for texture readability without heavy haloing."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Micro_PS; }
}

