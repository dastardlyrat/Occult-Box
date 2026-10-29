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
// @BlackWand clean user-menu filter: @BlackWand - Bloom Burst / Corona. Primitive-based transpile from BlackWand BloomBurst and Corona variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Burst_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Bloom Burst / Corona"; ui_category = "@BlackWand - Bloom Burst / Corona / 99 Advanced / Debug";
 ui_items = "Final Image\0Highlight Source\0Core Bloom\0Corona Bloom\0Apply Mask\0"; ui_tooltip = "Final Image shows the bloom result. Diagnostics show highlight extraction, core bloom, corona spread, and apply mask.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Burst_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Bloom Burst / Corona / 01 Controls"; ui_min = 0.0; ui_max = 3.0; ui_step = 0.001; ui_tooltip = "Overall bloom burst strength."; > = 0.85;
uniform float BWBlackWandX_Burst_Threshold < ui_type = "slider"; ui_label = "Highlight Threshold"; ui_category = "@BlackWand - Bloom Burst / Corona / 01 Controls"; ui_min = 0.0; ui_max = 1.5; ui_step = 0.001; ui_tooltip = "Brightness where bloom extraction begins."; > = 0.72;
uniform float BWBlackWandX_Burst_Softness <
    ui_type = "slider";
    ui_label = "Burst Feather";
    ui_category = "@BlackWand - Bloom Burst / Corona / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softens bloom burst activation.";
    ui_category_closed = true;
> = 0.22;
uniform float BWBlackWandX_Burst_CoreRadius < ui_type = "slider"; ui_label = "Core Radius (px)"; ui_category = "@BlackWand - Bloom Burst / Corona / 01 Controls";
 ui_min = 0.5; ui_max = 24.0; ui_step = 0.05; ui_tooltip = "Small-radius bloom body around bright highlights."; > = 2.0;
uniform float BWBlackWandX_Burst_CoronaRadius < ui_type = "slider"; ui_label = "Corona Radius (px)"; ui_category = "@BlackWand - Bloom Burst / Corona / 01 Controls";
 ui_min = 1.0; ui_max = 80.0; ui_step = 0.05; ui_tooltip = "Wide-radius bloom halo/corona around bright highlights."; > = 11.0;
uniform float BWBlackWandX_Burst_CoreStrength <
    ui_type = "slider";
    ui_label = "Burst Core Amount";
    ui_category = "@BlackWand - Bloom Burst / Corona / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Intensity of the tight burst core.";
    ui_category_closed = true;
> = 0.72;
uniform float BWBlackWandX_Burst_CoronaStrength <
    ui_type = "slider";
    ui_label = "Burst Corona Amount";
    ui_category = "@BlackWand - Bloom Burst / Corona / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Intensity of the wide burst corona.";
    ui_category_closed = true;
> = 0.46;
uniform float BWBlackWandX_Burst_Warmth < ui_type = "slider"; ui_label = "Bloom Warmth"; ui_category = "@BlackWand - Bloom Burst / Corona / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Warms the bloom contribution."; > = 0.30;
static const int BWBlackWandX_Burst_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Burst_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Burst_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Burst_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float highlightMask = BWBlackWandX_HighlightMask(lumaValue, BWBlackWandX_Burst_Threshold, BWBlackWandX_Burst_Softness);
    float3 highlightSource = sourceColor * highlightMask;
    float3 coreSample = BWBlackWandX_WideSoftSample(uv, BWBlackWandX_Burst_CoreRadius) * highlightMask;
    float3 coronaSample = BWBlackWandX_WideSoftSample(uv, BWBlackWandX_Burst_CoronaRadius) * highlightMask;
    float3 bloomColor = BWBlackWandX_WarmColor(coreSample * BWBlackWandX_Burst_CoreStrength + coronaSample * BWBlackWandX_Burst_CoronaStrength, BWBlackWandX_Burst_Warmth);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Burst_ApplyMask, uv, sourceColor, BWBlackWandX_Burst_ApplyMaskStrength);
    float3 outputColor = BWBlackWandX_ScreenBlend(sourceColor, bloomColor, BWBlackWandX_Burst_Strength * applyMask);
    if (BWBlackWandX_Burst_DebugView == 1) return black_wand_Proc_OutColor(highlightSource, BWBlackWandX_Burst_DebugFloor);
    if (BWBlackWandX_Burst_DebugView == 2) return black_wand_Proc_OutColor(coreSample, BWBlackWandX_Burst_DebugFloor);
    if (BWBlackWandX_Burst_DebugView == 3) return black_wand_Proc_OutColor(coronaSample, BWBlackWandX_Burst_DebugFloor);
    if (BWBlackWandX_Burst_DebugView == 4) return black_wand_Proc_OutScalar(applyMask, 1.0, BWBlackWandX_Burst_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Burst_DebugFloor);
}

technique BlackWand_BloomBurst_Corona < ui_label = "@BlackWand - Bloom Burst / Corona"; ui_tooltip = "Highlight bloom with tight core and broad corona controls, derived from the BlackWand bloom variant family."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Burst_PS; }
}

