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
// @BlackWand clean user-menu filter: @BlackWand - Guided Directional Tonal Shade. Primitive-based transpile from BlackWand directional tonal shading family.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Dir_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Guided Directional Tonal Shade"; ui_category = "@BlackWand - Guided Directional Tonal Shade / 99 Advanced / Debug";
 ui_items = "Final Image\0Shading Mask\0Pseudo Normal\0Depth Gradient\0Luma Gradient\0"; ui_tooltip = "Final Image shows guided shading. Diagnostics show directional shade, pseudo-normal, and the gradients used to build it.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Dir_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Guided Directional Tonal Shade / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall amount of directional tonal shading."; > = 0.70;
uniform float BWBlackWandX_Dir_ShadowAmount < ui_type = "slider"; ui_label = "Shadow Amount"; ui_category = "@BlackWand - Guided Directional Tonal Shade / 01 Controls"; ui_min = 0.0; ui_max = 1.5; ui_step = 0.001; ui_tooltip = "Dark-side tonal shade strength."; > = 0.34;
uniform float BWBlackWandX_Dir_LightAmount < ui_type = "slider"; ui_label = "Light Amount"; ui_category = "@BlackWand - Guided Directional Tonal Shade / 01 Controls"; ui_min = 0.0; ui_max = 1.5; ui_step = 0.001; ui_tooltip = "Light-side tonal lift strength."; > = 0.22;
uniform float BWBlackWandX_Dir_LightAngle < ui_type = "slider"; ui_label = "Light Direction"; ui_category = "@BlackWand - Guided Directional Tonal Shade / 01 Controls";
 ui_min = -180.0; ui_max = 180.0; ui_step = 0.1; ui_tooltip = "Screen-space direction of the simulated tonal light."; > = -45.0;
uniform float BWBlackWandX_Dir_NormalStrength < ui_type = "slider"; ui_label = "Normal Strength"; ui_category = "@BlackWand - Guided Directional Tonal Shade / 01 Controls";
 ui_min = 0.0; ui_max = 12.0; ui_step = 0.01; ui_tooltip = "How strongly depth/luma gradients bend the pseudo-normal."; > = 3.0;
uniform float BWBlackWandX_Dir_LumaWeight <
    ui_type = "slider";
    ui_label = "Luma Guidance Weight";
    ui_category = "@BlackWand - Guided Directional Tonal Shade / 99 Advanced / Guidance";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Blend between luma guidance and depth guidance.";
    ui_category_closed = true;
> = 0.35;
static const int BWBlackWandX_Dir_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Dir_DepthGradientGain <
    ui_type = "slider";
    ui_label = "Depth Guidance Gain";
    ui_category = "@BlackWand - Guided Directional Tonal Shade / 99 Advanced / Guidance";
    ui_min = 0.0;
    ui_max = 3000.0;
    ui_step = 1.0;
    ui_tooltip = "Amplifies depth gradients used by the directional tone guide.";
    ui_category_closed = true;
> = 1100.0;
uniform float BWBlackWandX_Dir_LumaGradientGain <
    ui_type = "slider";
    ui_label = "Luma Guidance Gain";
    ui_category = "@BlackWand - Guided Directional Tonal Shade / 99 Advanced / Guidance";
    ui_min = 0.0;
    ui_max = 96.0;
    ui_step = 0.01;
    ui_tooltip = "Amplifies brightness gradients used by the directional tone guide.";
    ui_category_closed = true;
> = 18.0;
static const float BWBlackWandX_Dir_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Dir_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float2 depthGradient = BWBlackWandX_DepthGradient(uv, BWBlackWandX_Dir_DepthMode, 1.0, BWBlackWandX_Dir_DepthGradientGain);
    float2 lumaGradient = BWBlackWandX_LumaGradient(uv, 1.0, BWBlackWandX_Dir_LumaGradientGain);
    float2 mixedGradient = lerp(depthGradient, depthGradient + lumaGradient, BWBlackWandX_Dir_LumaWeight);
    float3 normalValue = BWBlackWandX_PseudoNormalFromGradient(mixedGradient, BWBlackWandX_Dir_NormalStrength);
    float angleValue = radians(BWBlackWandX_Dir_LightAngle);
    float3 lightDirection = normalize(float3(cos(angleValue), sin(angleValue), 0.65));
    float shadeValue = dot(normalValue, lightDirection) * 0.5 + 0.5;
    float shadowMask = 1.0 - shadeValue;
    float lightMask = shadeValue;
    float3 shadedColor = saturate(sourceColor * (1.0 - shadowMask * BWBlackWandX_Dir_ShadowAmount) + lightMask.xxx * BWBlackWandX_Dir_LightAmount * 0.18);
    float3 outputColor = lerp(sourceColor, shadedColor, saturate(BWBlackWandX_Dir_Strength));
    if (BWBlackWandX_Dir_DebugView == 1) return black_wand_Proc_OutScalar(shadeValue, 1.0, BWBlackWandX_Dir_DebugFloor);
    if (BWBlackWandX_Dir_DebugView == 2) return black_wand_Proc_OutColor(BWBlackWandX_NormalDebugColor(normalValue), BWBlackWandX_Dir_DebugFloor);
    if (BWBlackWandX_Dir_DebugView == 3) return black_wand_Proc_OutColor(saturate(float3(depthGradient * 0.5 + 0.5, 0.0)), BWBlackWandX_Dir_DebugFloor);
    if (BWBlackWandX_Dir_DebugView == 4) return black_wand_Proc_OutColor(saturate(float3(lumaGradient * 0.5 + 0.5, 0.0)), BWBlackWandX_Dir_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Dir_DebugFloor);
}

technique BlackWand_GuidedDirectional_TonalShade < ui_label = "@BlackWand - Guided Directional Tonal Shade"; ui_tooltip = "Directional tonal shading from depth and image gradients, useful for guided relief and material readability."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Dir_PS; }
}

