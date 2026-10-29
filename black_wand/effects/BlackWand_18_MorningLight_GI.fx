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
// @BlackWand clean user-menu filter: @BlackWand - Morning Light GI. Primitive-based transpile from BlackWand morning/global illumination variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Morning_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Morning Light GI"; ui_category = "@BlackWand - Morning Light GI / 99 Advanced / Debug";
 ui_items = "Final Image\0Indirect Color\0Shadow Receiver Mask\0Warmth Field\0Apply Mask\0"; ui_tooltip = "Final Image shows the warm indirect-light result. Diagnostics isolate indirect sample, receiver mask, warmth field, and apply region.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Morning_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Morning Light GI / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall warm indirect-light contribution."; > = 0.60;
uniform float BWBlackWandX_Morning_Warmth < ui_type = "slider"; ui_label = "Morning Warmth"; ui_category = "@BlackWand - Morning Light GI / 01 Controls"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Warm color bias applied to the indirect light."; > = 0.55;
uniform float BWBlackWandX_Morning_ShadowLift < ui_type = "slider"; ui_label = "Lift Shadows"; ui_category = "@BlackWand - Morning Light GI / 01 Controls"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "How much warm indirect light enters darker receiver areas."; > = 0.42;
static const int BWBlackWandX_Morning_Lens = black_wand_LENS_GOLDEN21; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Morning_TapCount <
    ui_type = "slider";
    ui_label = "Sample Budget";
    ui_category = "@BlackWand - Morning Light GI / 99 Advanced / Sampling";
    ui_min = 1.0;
    ui_max = 55.0;
    ui_step = 1.0;
    ui_tooltip = "Maximum donor samples used by the morning-light GI lens.";
    ui_category_closed = true;
> = 21.0;
uniform float BWBlackWandX_Morning_Radius < ui_type = "slider"; ui_label = "Indirect Radius (px)"; ui_category = "@BlackWand - Morning Light GI / 01 Controls";
 ui_min = 0.25; ui_max = 96.0; ui_step = 0.05; ui_tooltip = "Distance used to gather neighboring indirect color."; > = 9.0;
uniform float BWBlackWandX_Morning_Rotation <
    ui_type = "slider";
    ui_label = "Sample Rotation";
    ui_category = "@BlackWand - Morning Light GI / 99 Advanced / Sampling";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Rotates the warm GI sampling direction.";
    ui_category_closed = true;
> = -18.0;
uniform float BWBlackWandX_Morning_ShadowStart < ui_type = "slider"; ui_label = "Receiver Shadow Target"; ui_category = "@BlackWand - Morning Light GI / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Below this luma, pixels receive more indirect warmth."; > = 0.48;
static const int BWBlackWandX_Morning_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Morning_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Morning_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Morning_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float3 indirectColor = black_wand_BWT_FirstLensAverage(uv, BWBlackWandX_Morning_Lens, BWBlackWandX_Morning_TapCount, BWBlackWandX_Morning_Radius, BWBlackWandX_Morning_Rotation, 0.35);
    indirectColor = BWBlackWandX_WarmColor(black_wand_Proc_ColorSaturateAmount(indirectColor, 1.10), BWBlackWandX_Morning_Warmth);
    float receiverMask = BWBlackWandX_ShadowMask(lumaValue, BWBlackWandX_Morning_ShadowStart, 0.18);
    float warmthField = saturate(receiverMask * BWBlackWandX_Morning_ShadowLift);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Morning_ApplyMask, uv, sourceColor, BWBlackWandX_Morning_ApplyMaskStrength);
    float3 giColor = BWBlackWandX_ScreenBlend(sourceColor, indirectColor * warmthField, BWBlackWandX_Morning_Strength * applyMask);
    if (BWBlackWandX_Morning_DebugView == 1) return black_wand_Proc_OutColor(indirectColor, BWBlackWandX_Morning_DebugFloor);
    if (BWBlackWandX_Morning_DebugView == 2) return black_wand_Proc_OutScalar(receiverMask, 1.0, BWBlackWandX_Morning_DebugFloor);
    if (BWBlackWandX_Morning_DebugView == 3) return black_wand_Proc_OutScalar(warmthField, 1.0, BWBlackWandX_Morning_DebugFloor);
    if (BWBlackWandX_Morning_DebugView == 4) return black_wand_Proc_OutScalar(applyMask, 1.0, BWBlackWandX_Morning_DebugFloor);
    return black_wand_Proc_OutColor(giColor, BWBlackWandX_Morning_DebugFloor);
}

technique BlackWand_MorningLight_GI < ui_label = "@BlackWand - Morning Light GI"; ui_tooltip = "Warm indirect-light pass for shadow lift and gentle color bleed using the primitive sampling lens."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Morning_PS; }
}

