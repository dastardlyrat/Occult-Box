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
// @BlackWand clean user-menu filter: @BlackWand - Fog / Light Guard. Primitive-based transpile from BlackWand Other/Fog Gate and Light Shield family.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Guard_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Fog / Light Guard"; ui_category = "@BlackWand - Fog / Light Guard / 99 Advanced / Debug";
 ui_items = "Final Image\0Protected Area\0Fog Estimate\0Light Estimate\0Local Contrast\0Depth Window\0"; ui_tooltip = "Final Image shows the guarded result. Diagnostic views show the protected fog/light region and the inputs used to build it.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Guard_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Fog / Light Guard / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall amount of the fog/light guard applied to the source image."; > = 1.0;
uniform float BWBlackWandX_Guard_ShadeOutside <
    ui_type = "slider";
    ui_label = "Outside Shade";
    ui_category = "@BlackWand - Fog / Light Guard / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Amount of shading applied outside the protected fog/light area.";
    ui_category_closed = true;
> = 0.18;
uniform float BWBlackWandX_Guard_ProtectAmount < ui_type = "slider"; ui_label = "Protection Amount"; ui_category = "@BlackWand - Fog / Light Guard / 01 Controls"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "How strongly detected fog and light return to the original source color."; > = 0.85;
uniform float BWBlackWandX_Guard_FogSensitivity < ui_type = "slider"; ui_label = "Fog Sensitivity"; ui_category = "@BlackWand - Fog / Light Guard / 01 Controls";
 ui_min = 0.0; ui_max = 4.0; ui_step = 0.001; ui_tooltip = "Raises detection of low-contrast desaturated far-field haze."; > = 1.15;
uniform float BWBlackWandX_Guard_LightThreshold < ui_type = "slider"; ui_label = "Light Threshold"; ui_category = "@BlackWand - Fog / Light Guard / 01 Controls";
 ui_min = 0.0; ui_max = 1.5; ui_step = 0.001; ui_tooltip = "Brightness level where emissive or bright light protection begins."; > = 0.78;
uniform float BWBlackWandX_Guard_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Feather";
    ui_category = "@BlackWand - Fog / Light Guard / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softness around the bright-light protection threshold.";
    ui_category_closed = true;
> = 0.12;
uniform float BWBlackWandX_Guard_ContrastReject <
    ui_type = "slider";
    ui_label = "Texture Rejection";
    ui_category = "@BlackWand - Fog / Light Guard / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 3.0;
    ui_step = 0.001;
    ui_tooltip = "Rejects high-contrast texture so fog detection favors smooth haze.";
    ui_category_closed = true;
> = 0.90;
static const int BWBlackWandX_Guard_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Guard_DepthStart < ui_type = "slider"; ui_label = "Depth Window Start"; ui_category = "@BlackWand - Fog / Light Guard / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Near edge of the fog/light diagnostic depth window."; > = 0.25;
uniform float BWBlackWandX_Guard_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth Window End";
    ui_category = "@BlackWand - Fog / Light Guard / 99 Advanced / Depth";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Far edge of the fog/light diagnostic depth window.";
    ui_category_closed = true;
> = 1.0;
static const float BWBlackWandX_Guard_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Guard_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float saturationValue = black_wand_Proc_ColorSaturationApprox(sourceColor);
    float localContrast = BWBlackWandX_LocalContrast(uv, 2.0, 12.0);
    float depthValue = black_wand_Proc_DepthValue(uv, BWBlackWandX_Guard_DepthMode);
    float depthWindow = BWBlackWandX_DepthWindow(depthValue, BWBlackWandX_Guard_DepthStart, BWBlackWandX_Guard_DepthEnd, 0.035);
    float fogEstimate = saturate((1.0 - saturationValue) * (1.0 - saturate(localContrast * BWBlackWandX_Guard_ContrastReject)) * depthWindow * BWBlackWandX_Guard_FogSensitivity);
    float lightEstimate = BWBlackWandX_HighlightMask(lumaValue, BWBlackWandX_Guard_LightThreshold, BWBlackWandX_Guard_LightSoftness);
    float protectedArea = saturate(max(fogEstimate, lightEstimate));
    float3 shadedColor = sourceColor * (1.0 - BWBlackWandX_Guard_ShadeOutside * (1.0 - protectedArea));
    float3 guardedColor = lerp(shadedColor, sourceColor, protectedArea * BWBlackWandX_Guard_ProtectAmount);
    float3 outputColor = lerp(sourceColor, guardedColor, saturate(BWBlackWandX_Guard_Strength));
    if (BWBlackWandX_Guard_DebugView == 1) return black_wand_Proc_OutScalar(protectedArea, 1.0, BWBlackWandX_Guard_DebugFloor);
    if (BWBlackWandX_Guard_DebugView == 2) return black_wand_Proc_OutScalar(fogEstimate, 1.0, BWBlackWandX_Guard_DebugFloor);
    if (BWBlackWandX_Guard_DebugView == 3) return black_wand_Proc_OutScalar(lightEstimate, 1.0, BWBlackWandX_Guard_DebugFloor);
    if (BWBlackWandX_Guard_DebugView == 4) return black_wand_Proc_OutScalar(localContrast, 1.0, BWBlackWandX_Guard_DebugFloor);
    if (BWBlackWandX_Guard_DebugView == 5) return black_wand_Proc_OutScalar(depthWindow, 1.0, BWBlackWandX_Guard_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Guard_DebugFloor);
}

technique BlackWand_FogLight_Guard < ui_label = "@BlackWand - Fog / Light Guard"; ui_tooltip = "Protects fog-like haze and bright light regions from later heavy filtering, with useful diagnostics for the guard mask."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Guard_PS; }
}

