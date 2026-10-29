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
// @BlackWand clean user-menu filter: @BlackWand - Far-Z Detail. Primitive-based transpile from BlackWand far-plane/detail families.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Far_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Far-Z Detail"; ui_category = "@BlackWand - Far-Z Detail / 99 Advanced / Debug";
 ui_items = "Final Image\0Far Depth Mask\0Detail Delta\0Edge Support\0Apply Mask\0"; ui_tooltip = "Final Image shows far-plane detail. Diagnostics isolate the depth target, detail signal, edge support, and apply region.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Far_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Far-Z Detail / 01 Controls"; ui_min = 0.0; ui_max = 2.5; ui_step = 0.001; ui_tooltip = "Overall strength of far-plane detail reinforcement."; > = 0.85;
uniform float BWBlackWandX_Far_DetailStrength < ui_type = "slider"; ui_label = "Fine Detail Amount"; ui_category = "@BlackWand - Far-Z Detail / 01 Controls"; ui_min = 0.0; ui_max = 4.0; ui_step = 0.001; ui_tooltip = "Adds back high-frequency information in the far field."; > = 1.10;
uniform float BWBlackWandX_Far_EdgeLight <
    ui_type = "slider";
    ui_label = "Far Edge Lift";
    ui_category = "@BlackWand - Far-Z Detail / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Adds light/detail along far depth discontinuities.";
    ui_category_closed = true;
> = 0.22;
uniform float BWBlackWandX_Far_Radius < ui_type = "slider"; ui_label = "Detail Radius (px)"; ui_category = "@BlackWand - Far-Z Detail / 01 Controls"; ui_min = 0.25; ui_max = 16.0; ui_step = 0.05; ui_tooltip = "Radius used to separate far detail from the local average."; > = 1.50;
static const int BWBlackWandX_Far_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Far_Start < ui_type = "slider"; ui_label = "Far Detail Starts"; ui_category = "@BlackWand - Far-Z Detail / 01 Controls";
 ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Depth value where background detail starts being reinforced."; > = 0.52;
uniform float BWBlackWandX_Far_Softness <
    ui_type = "slider";
    ui_label = "Far Window Feather";
    ui_category = "@BlackWand - Far-Z Detail / 99 Advanced / Depth";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softens the far-depth activation window.";
    ui_category_closed = true;
> = 0.12;
uniform float BWBlackWandX_Far_EdgeGain < ui_type = "slider"; ui_label = "Edge Sensitivity"; ui_category = "@BlackWand - Far-Z Detail / 01 Controls";
 ui_min = 0.0; ui_max = 64.0; ui_step = 0.01; ui_tooltip = "How strongly luma edges support the far detail boost."; > = 10.0;
static const int BWBlackWandX_Far_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Far_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Far_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Far_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float depthValue = black_wand_Proc_DepthValue(uv, BWBlackWandX_Far_DepthMode);
    float farMask = smoothstep(BWBlackWandX_Far_Start - BWBlackWandX_Far_Softness, BWBlackWandX_Far_Start + BWBlackWandX_Far_Softness, depthValue);
    float3 detailDelta = BWBlackWandX_DetailDelta(uv, BWBlackWandX_Far_Radius);
    float edgeSupport = black_wand_BWT_LumaEdge(uv, BWBlackWandX_Far_EdgeGain);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Far_ApplyMask, uv, sourceColor, BWBlackWandX_Far_ApplyMaskStrength);
    float3 detailedColor = saturate(sourceColor + detailDelta * BWBlackWandX_Far_DetailStrength + edgeSupport.xxx * BWBlackWandX_Far_EdgeLight);
    float blendAmount = saturate(BWBlackWandX_Far_Strength * farMask * applyMask);
    float3 outputColor = lerp(sourceColor, detailedColor, blendAmount);
    if (BWBlackWandX_Far_DebugView == 1) return black_wand_Proc_OutScalar(farMask, 1.0, BWBlackWandX_Far_DebugFloor);
    if (BWBlackWandX_Far_DebugView == 2) return black_wand_Proc_OutSigned(black_wand_BWT_Luma(detailDelta), 8.0, BWBlackWandX_Far_DebugFloor);
    if (BWBlackWandX_Far_DebugView == 3) return black_wand_Proc_OutScalar(edgeSupport, 1.0, BWBlackWandX_Far_DebugFloor);
    if (BWBlackWandX_Far_DebugView == 4) return black_wand_Proc_OutScalar(applyMask, 1.0, BWBlackWandX_Far_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Far_DebugFloor);
}

technique BlackWand_FarZ_Detail < ui_label = "@BlackWand - Far-Z Detail"; ui_tooltip = "Reinforces background/far-plane detail using depth targeting, local detail recovery, and edge support."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Far_PS; }
}

