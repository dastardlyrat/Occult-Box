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
// @BlackWand clean user-menu filter: @BlackWand - Deep Color Grade. Primitive-based transpile from BlackWand deep tone/deep color variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Color_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Deep Color Grade"; ui_category = "@BlackWand - Deep Color Grade / 99 Advanced / Debug";
 ui_items = "Final Image\0Tone Candidate\0Shadow Mask\0Highlight Protect\0Apply Mask\0"; ui_tooltip = "Final Image shows the color grade. Diagnostics isolate tone candidate, shadow target, highlight protection, and apply region.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Color_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Deep Color Grade / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall mix of the deep color grade."; > = 0.80;
uniform float BWBlackWandX_Color_Contrast < ui_type = "slider"; ui_label = "Contrast"; ui_category = "@BlackWand - Deep Color Grade / 01 Controls"; ui_min = 0.5; ui_max = 2.5; ui_step = 0.001; ui_tooltip = "Midpoint contrast of the graded image."; > = 1.14;
uniform float BWBlackWandX_Color_Saturation < ui_type = "slider"; ui_label = "Saturation"; ui_category = "@BlackWand - Deep Color Grade / 01 Controls"; ui_min = 0.0; ui_max = 2.5; ui_step = 0.001; ui_tooltip = "Color saturation after contrast shaping."; > = 1.12;
uniform float BWBlackWandX_Color_WarmCool < ui_type = "slider"; ui_label = "Warm / Cool Balance"; ui_category = "@BlackWand - Deep Color Grade / 01 Controls"; ui_min = -1.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Negative cools the grade; positive warms it."; > = 0.12;
uniform float BWBlackWandX_Color_ShadowDepth < ui_type = "slider"; ui_label = "Deepen Shadows"; ui_category = "@BlackWand - Deep Color Grade / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Adds depth to darker tones without directly crushing highlights."; > = 0.22;
uniform float BWBlackWandX_Color_ShadowStart <
    ui_type = "slider";
    ui_label = "Shadow Color Start";
    ui_category = "@BlackWand - Deep Color Grade / 99 Advanced / Tonal Shape";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Brightness point where shadow color treatment begins.";
    ui_category_closed = true;
> = 0.38;
uniform float BWBlackWandX_Color_HighlightProtect < ui_type = "slider"; ui_label = "Protect Highlights"; ui_category = "@BlackWand - Deep Color Grade / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Reduces grading strength in bright highlights."; > = 0.55;
uniform float BWBlackWandX_Color_GrainlessFloor <
    ui_type = "slider";
    ui_label = "Grainless Floor";
    ui_category = "@BlackWand - Deep Color Grade / 99 Advanced / Tonal Shape";
    ui_min = 0.0;
    ui_max = 0.1;
    ui_step = 0.0005;
    ui_tooltip = "Minimum floor used to avoid noisy color math in very dark regions.";
    ui_category_closed = true;
> = 0.006;
static const int BWBlackWandX_Color_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Color_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Color_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Color_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float shadowMask = BWBlackWandX_ShadowMask(lumaValue, BWBlackWandX_Color_ShadowStart, 0.16);
    float highlightMask = BWBlackWandX_HighlightMask(lumaValue, 0.78, 0.14);
    float3 graded = black_wand_Proc_ToneContrast(sourceColor, BWBlackWandX_Color_Contrast);
    graded = black_wand_Proc_ToneSaturation(graded, BWBlackWandX_Color_Saturation);
    graded = (BWBlackWandX_Color_WarmCool >= 0.0) ? BWBlackWandX_WarmColor(graded, BWBlackWandX_Color_WarmCool) : BWBlackWandX_CoolColor(graded, -BWBlackWandX_Color_WarmCool);
    graded = saturate(graded * (1.0 - shadowMask * BWBlackWandX_Color_ShadowDepth));
    graded = max(graded, BWBlackWandX_Color_GrainlessFloor.xxx);
    float protect = lerp(1.0, 1.0 - highlightMask, BWBlackWandX_Color_HighlightProtect);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Color_ApplyMask, uv, sourceColor, BWBlackWandX_Color_ApplyMaskStrength);
    float3 outputColor = lerp(sourceColor, graded, saturate(BWBlackWandX_Color_Strength) * protect * applyMask);
    if (BWBlackWandX_Color_DebugView == 1) return black_wand_Proc_OutColor(graded, BWBlackWandX_Color_DebugFloor);
    if (BWBlackWandX_Color_DebugView == 2) return black_wand_Proc_OutScalar(shadowMask, 1.0, BWBlackWandX_Color_DebugFloor);
    if (BWBlackWandX_Color_DebugView == 3) return black_wand_Proc_OutScalar(highlightMask, 1.0, BWBlackWandX_Color_DebugFloor);
    if (BWBlackWandX_Color_DebugView == 4) return black_wand_Proc_OutScalar(applyMask, 1.0, BWBlackWandX_Color_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Color_DebugFloor);
}

technique BlackWand_DeepColor_Grade < ui_label = "@BlackWand - Deep Color Grade"; ui_tooltip = "Deep tone/color grade with shadow deepening, highlight protection, saturation, and warm/cool balance."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Color_PS; }
}

