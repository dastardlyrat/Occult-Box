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
// @BlackWand clean user-menu filter: @BlackWand - Mask / Depth Debug Router. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_Orch_DebugView <
    ui_type = "combo";
    ui_label = "View Output";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 99 Advanced / Debug";
    ui_items = "Source Image\0Input Mask\0Sample Weight Mask\0Output Blend Mask\0Depth Available\0Depth Edge\0Fog/Far Gate\0Light Protect Gate\0Stable Surface Mask\0";
    ui_tooltip = "Select the diagnostic surface to inspect masks, depth, fog/far gate, light-protect gate, and stable surface logic.";
    ui_category_closed = true;
> = 0;
uniform int BWT_Orch_InputMaskSource <
    ui_type = "combo";
    ui_label = "Input Mask";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 01 Controls";
    ui_items = BLACK_WAND_BWT_MASK_ITEMS;
    ui_tooltip = "Mask used to describe where an effect is allowed to read or analyze the source image.";
> = black_wand_MASK_ALWAYS;
static const int BWT_Orch_SampleWeightMaskSource = black_wand_MASK_STABLE_SURFACE; // internal fixed control; hidden from the clean menu
uniform int BWT_Orch_OutputBlendMaskSource <
    ui_type = "combo";
    ui_label = "Output Mask";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 01 Controls";
    ui_items = BLACK_WAND_BWT_MASK_ITEMS;
    ui_tooltip = "Mask used to decide where the finished effect may be blended into the image.";
> = black_wand_MASK_ALWAYS;
uniform int BWT_Orch_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Orientation";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 01 Controls";
    ui_items = "Raw\0Raw Inverted\0";
    ui_tooltip = "Use Raw or Raw Inverted depending on the game depth buffer.";
> = black_wand_PRIMITIVE_DEPTH_MODE_RAW;
static const float BWT_Orch_DepthAvailabilityThreshold = 0.00005; // internal fixed control; hidden from the clean menu
uniform float BWT_Orch_FogFarStart <
    ui_type = "slider";
    ui_label = "Fog Start";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Depth value where far/fog protection begins.";
> = 0.72;
static const float BWT_Orch_FogFarFeather = 0.18; // internal fixed control; hidden from the clean menu
uniform float BWT_Orch_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Guard";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Brightness where light-protection begins.";
> = 0.78;
static const float BWT_Orch_LightSoftness = 0.12; // internal fixed control; hidden from the clean menu
uniform float BWT_Orch_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = "@BlackWand - Mask / Depth Debug Router / 01 Controls";
    ui_min = 0.0;
    ui_max = 8.0;
    ui_step = 0.001;
    ui_tooltip = "Brightens diagnostics without changing final output.";
> = 1.0;
static const float BWT_Orch_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_Orchestrator_Debug_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float depthValue = black_wand_Proc_DepthValue(uv, BWT_Orch_DepthMode);
    float depthAvailable = black_wand_Proc_DepthAvailable(uv, BWT_Orch_DepthMode, BWT_Orch_DepthAvailabilityThreshold);
    float fogGate = black_wand_Proc_DepthFar(uv, BWT_Orch_DepthMode, BWT_Orch_FogFarStart, BWT_Orch_FogFarFeather);
    float lightProtect = black_wand_BWT_SoftMask(black_wand_BWT_Luma(sourceColor), BWT_Orch_LightThreshold, BWT_Orch_LightSoftness);
    float inputMask = black_wand_Proc_InputMask(BWT_Orch_InputMaskSource, uv, sourceColor);
    float sampleWeightMask = black_wand_Proc_SampleWeightMask(BWT_Orch_SampleWeightMaskSource, uv, sourceColor);
    float outputBlendMask = black_wand_Proc_OutputBlendMask(BWT_Orch_OutputBlendMaskSource, uv, sourceColor);
    float3 unified = saturate(float3(fogGate, lightProtect, min(inputMask, outputBlendMask)) * BWT_Orch_DebugExposure);
    if (BWT_Orch_DebugView == 1) return black_wand_Proc_OutScalar(depthValue, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 2) return black_wand_Proc_OutScalar(depthAvailable, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 3) return black_wand_Proc_OutScalar(fogGate, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 4) return black_wand_Proc_OutScalar(lightProtect, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 5) return black_wand_Proc_OutScalar(inputMask, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 6) return black_wand_Proc_OutScalar(sampleWeightMask, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 7) return black_wand_Proc_OutScalar(outputBlendMask, BWT_Orch_DebugExposure, BWT_Orch_VisibleFloor);
    if (BWT_Orch_DebugView == 8) return black_wand_Proc_OutColor(unified, BWT_Orch_VisibleFloor);
    return black_wand_Proc_OutColor(sourceColor, BWT_Orch_VisibleFloor);
}

technique BlackWand_MaskDepth_DebugRouter <
    ui_label = "@BlackWand - Mask / Depth Debug Router";
    ui_tooltip = "Diagnostic router for masks, depth availability, fog/far gate, light-protect gate, and stable-surface selection.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_Orchestrator_Debug_PS;
    }
}

