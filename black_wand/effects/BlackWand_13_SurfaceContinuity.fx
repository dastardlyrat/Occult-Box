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
// @BlackWand clean user-menu filter: @BlackWand - Surface Continuity. Primitive-based transpile from BlackWand surface continuity / anti-shimmer variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Surface_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Surface Continuity"; ui_category = "@BlackWand - Surface Continuity / 99 Advanced / Debug";
 ui_items = "Final Image\0Continuity Mask\0Depth Edge Reject\0Image Edge Reject\0Smooth Candidate\0"; ui_tooltip = "Final Image shows surface smoothing. Diagnostics show where the effect considers the surface stable enough to smooth.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Surface_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Surface Continuity / 01 Controls"; ui_min = 0.0; ui_max = 1.5; ui_step = 0.001; ui_tooltip = "Overall amount of same-surface smoothing."; > = 0.45;
uniform float BWBlackWandX_Surface_Radius < ui_type = "slider"; ui_label = "Smoothing Radius (px)"; ui_category = "@BlackWand - Surface Continuity / 01 Controls"; ui_min = 0.25; ui_max = 12.0; ui_step = 0.05; ui_tooltip = "Local radius used to build the continuity candidate."; > = 1.25;
uniform float BWBlackWandX_Surface_DetailReturn < ui_type = "slider"; ui_label = "Return Fine Detail"; ui_category = "@BlackWand - Surface Continuity / 01 Controls"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Adds a controlled amount of original micro detail back after smoothing."; > = 0.35;
static const int BWBlackWandX_Surface_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Surface_DepthEdgeGain < ui_type = "slider"; ui_label = "Depth Edge Reject"; ui_category = "@BlackWand - Surface Continuity / 01 Controls";
 ui_min = 0.0; ui_max = 3000.0; ui_step = 0.1; ui_tooltip = "Rejects smoothing across depth discontinuities."; > = 400.0;
uniform float BWBlackWandX_Surface_ImageEdgeGain < ui_type = "slider"; ui_label = "Image Edge Reject"; ui_category = "@BlackWand - Surface Continuity / 01 Controls";
 ui_min = 0.0; ui_max = 64.0; ui_step = 0.01; ui_tooltip = "Rejects smoothing across high-contrast image edges."; > = 12.0;
static const int BWBlackWandX_Surface_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Surface_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Surface_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Surface_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float3 smoothCandidate = BWBlackWandX_CrossBlur(uv, BWBlackWandX_Surface_Radius);
    float3 detailDelta = sourceColor - smoothCandidate;
    float depthEdge = black_wand_BWT_DepthEdge(uv, BWBlackWandX_Surface_DepthMode, BWBlackWandX_Surface_DepthEdgeGain);
    float imageEdge = black_wand_BWT_LumaEdge(uv, BWBlackWandX_Surface_ImageEdgeGain);
    float continuityMask = saturate((1.0 - depthEdge) * (1.0 - imageEdge));
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Surface_ApplyMask, uv, sourceColor, BWBlackWandX_Surface_ApplyMaskStrength);
    float3 restoredCandidate = saturate(smoothCandidate + detailDelta * BWBlackWandX_Surface_DetailReturn);
    float3 outputColor = lerp(sourceColor, restoredCandidate, saturate(BWBlackWandX_Surface_Strength) * continuityMask * applyMask);
    if (BWBlackWandX_Surface_DebugView == 1) return black_wand_Proc_OutScalar(continuityMask, 1.0, BWBlackWandX_Surface_DebugFloor);
    if (BWBlackWandX_Surface_DebugView == 2) return black_wand_Proc_OutScalar(depthEdge, 1.0, BWBlackWandX_Surface_DebugFloor);
    if (BWBlackWandX_Surface_DebugView == 3) return black_wand_Proc_OutScalar(imageEdge, 1.0, BWBlackWandX_Surface_DebugFloor);
    if (BWBlackWandX_Surface_DebugView == 4) return black_wand_Proc_OutColor(restoredCandidate, BWBlackWandX_Surface_DebugFloor);
    return black_wand_Proc_OutColor(outputColor, BWBlackWandX_Surface_DebugFloor);
}

technique BlackWand_SurfaceContinuity < ui_label = "@BlackWand - Surface Continuity"; ui_tooltip = "Same-surface coherence smoother for shimmer and noisy surfaces, guarded by depth and image edge rejection."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Surface_PS; }
}

