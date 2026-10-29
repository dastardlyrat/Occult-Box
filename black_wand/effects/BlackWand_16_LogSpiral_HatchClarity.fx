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
// @BlackWand clean user-menu filter: @BlackWand - Log-Spiral Hatch Clarity. Primitive-based transpile from BlackWand log-spiral hatch variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Log_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Log-Spiral Hatch Clarity"; ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 99 Advanced / Debug";
 ui_items = "Final Image\0Hatch Pattern\0Edge Support\0Detail Support\0Apply Mask\0"; ui_tooltip = "Final Image shows hatch clarity. Diagnostics isolate hatch pattern, edges, detail, and apply region.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Log_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall amount of log-spiral hatch clarity."; > = 0.65;
uniform float BWBlackWandX_Log_InkAmount < ui_type = "slider"; ui_label = "Ink Amount"; ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 01 Controls"; ui_min = 0.0; ui_max = 3.0; ui_step = 0.001; ui_tooltip = "How dark the hatch/edge ink becomes."; > = 0.75;
uniform float BWBlackWandX_Log_DetailAmount < ui_type = "slider"; ui_label = "Detail Return"; ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Adds source detail back through the hatch field."; > = 0.35;
static const int BWBlackWandX_Log_HatchSource = black_wand_HATCH_LOG_SPIRAL_CROSS; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Log_Phase <
    ui_type = "slider";
    ui_label = "Hatch Phase";
    ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 99 Advanced / Pattern";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Offsets the log-spiral hatch pattern.";
    ui_category_closed = true;
> = 0.0;
uniform float BWBlackWandX_Log_EdgeGain < ui_type = "slider"; ui_label = "Edge Sensitivity"; ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 01 Controls";
 ui_min = 0.0; ui_max = 96.0; ui_step = 0.01; ui_tooltip = "Image edge sensitivity used to reinforce hatch clarity."; > = 16.0;
uniform float BWBlackWandX_Log_HatchThreshold < ui_type = "slider"; ui_label = "Hatch Threshold"; ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Minimum hatch value before ink contributes strongly."; > = 0.38;
uniform float BWBlackWandX_Log_HatchSoftness <
    ui_type = "slider";
    ui_label = "Hatch Feather";
    ui_category = "@BlackWand - Log-Spiral Hatch Clarity / 99 Advanced / Pattern";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softens log-spiral hatch activation.";
    ui_category_closed = true;
> = 0.16;
static const int BWBlackWandX_Log_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Log_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Log_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Log_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float hatchRaw = black_wand_Proc_InputHatch(BWBlackWandX_Log_HatchSource, uv, 0.5, lumaValue, BWBlackWandX_Log_Phase);
    float hatchMask = BWBlackWandX_HighlightMask(hatchRaw, BWBlackWandX_Log_HatchThreshold, BWBlackWandX_Log_HatchSoftness);
    float edgeSupport = black_wand_BWT_LumaEdge(uv, BWBlackWandX_Log_EdgeGain);
    float3 detailDelta = BWBlackWandX_DetailDelta(uv, 1.0);
    float detailSupport = saturate(abs(black_wand_BWT_Luma(detailDelta)) * 8.0);
    float inkMask = saturate(max(hatchMask, edgeSupport) + detailSupport * 0.35);
    float3 detailColor = saturate(sourceColor + detailDelta * BWBlackWandX_Log_DetailAmount);
    float3 inkedColor = black_wand_Proc_HatchInk(detailColor, inkMask, BWBlackWandX_Log_InkAmount);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Log_ApplyMask, uv, sourceColor, BWBlackWandX_Log_ApplyMaskStrength);
    float3 outputColor = lerp(sourceColor, inkedColor, saturate(BWBlackWandX_Log_Strength) * applyMask);
    if (BWBlackWandX_Log_DebugView == 1) return black_wand_Proc_OutScalar(hatchRaw, 1.0, BWBlackWandX_Log_DebugFloor);
    if (BWBlackWandX_Log_DebugView == 2) return black_wand_Proc_OutScalar(edgeSupport, 1.0, BWBlackWandX_Log_DebugFloor);
    if (BWBlackWandX_Log_DebugView == 3) return black_wand_Proc_OutScalar(detailSupport, 1.0, BWBlackWandX_Log_DebugFloor);
    if (BWBlackWandX_Log_DebugView == 4) return black_wand_Proc_OutScalar(applyMask, 1.0, BWBlackWandX_Log_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Log_DebugFloor);
}

technique BlackWand_LogSpiral_HatchClarity < ui_label = "@BlackWand - Log-Spiral Hatch Clarity"; ui_tooltip = "Log-spiral hatch clarity and ink pass with edge/detail support for stylized texture readability."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Log_PS; }
}

