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
// @BlackWand clean user-menu filter: @BlackWand - GI - Color Bleed. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_GI_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - GI - Color Bleed";
    ui_category = "@BlackWand - GI - Color Bleed / 99 Advanced / Debug";
    ui_items = "Final Image\0Indirect Color Candidate\0GI Apply Mask\0Depth Rejection Gate\0Color Bleed Delta\0";
    ui_tooltip = "Switch between final color bleed, indirect color candidate, GI mask, depth gate, and color delta.";
    ui_category_closed = true;
> = 0;
uniform float BWT_GI_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - GI - Color Bleed / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall amount of GI color bleed applied.";
> = 1.0;
uniform float BWT_GI_Strength <
    ui_type = "slider";
    ui_label = "Bleed Amount";
    ui_category = "@BlackWand - GI - Color Bleed / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "How much sampled nearby color contributes to the final image.";
> = 0.55;
uniform float BWT_GI_ColorBleedSaturation <
    ui_type = "slider";
    ui_label = "Bleed Saturation";
    ui_category = "@BlackWand - GI - Color Bleed / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Saturation of the indirect color contribution.";
> = 1.15;
uniform float BWT_GI_MaxContribution <
    ui_type = "slider";
    ui_label = "Contribution Limit";
    ui_category = "@BlackWand - GI - Color Bleed / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Caps color-bleed strength to prevent heavy smearing.";
> = 0.35;
static const int BWT_GI_InputSamplingLens = black_wand_LENS_GOLDEN21; // internal fixed control; hidden from the clean menu
uniform float BWT_GI_TapCount_UI <
    ui_type = "slider";
    ui_label = "Sample Budget";
    ui_category = "@BlackWand - GI - Color Bleed / 99 Advanced / Sampling";
    ui_min = 1.0;
    ui_max = 55.0;
    ui_step = 1.0;
    ui_tooltip = "Maximum donor samples used by the internal GI color-bleed lens.";
    ui_category_closed = true;
> = 21.0;
uniform float BWT_GI_RadiusPixels <
    ui_type = "slider";
    ui_label = "Radius";
    ui_category = "@BlackWand - GI - Color Bleed / 01 Controls";
    ui_min = 0.0;
    ui_max = 192.0;
    ui_step = 0.05;
    ui_tooltip = "Screen-space reach of the color-bleed sample.";
> = 18.0;
uniform float BWT_GI_RotationDegrees <
    ui_type = "slider";
    ui_label = "Sample Rotation";
    ui_category = "@BlackWand - GI - Color Bleed / 99 Advanced / Sampling";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Rotates the color-bleed sampling pattern.";
    ui_category_closed = true;
> = 0.0;
static const int BWT_GI_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWT_GI_DepthRejectThreshold <
    ui_type = "slider";
    ui_label = "Depth Guard";
    ui_category = "@BlackWand - GI - Color Bleed / 01 Controls";
    ui_min = 0.000001;
    ui_max = 0.25;
    ui_step = 0.0001;
    ui_tooltip = "Depth difference where color bleed begins being rejected.";
> = 0.025;
uniform float BWT_GI_DepthRejectSoftness <
    ui_type = "slider";
    ui_label = "Depth Reject Feather";
    ui_category = "@BlackWand - GI - Color Bleed / 99 Advanced / Depth";
    ui_min = 0.0;
    ui_max = 0.25;
    ui_step = 0.001;
    ui_tooltip = "Softens the depth rejection around donor samples so bleed does not cut off abruptly.";
    ui_category_closed = true;
> = 0.040;
static const float BWT_GI_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_GI_ColorBleed_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float3 tapColor = black_wand_BWT_LensAverageColor(uv, BWT_GI_InputSamplingLens, BWT_GI_TapCount_UI, BWT_GI_RadiusPixels, BWT_GI_RotationDegrees);
    float centerDepth = black_wand_Proc_DepthValue(uv, BWT_GI_DepthMode);
    float tapDepth = black_wand_BWT_LensAverageDepth(uv, BWT_GI_InputSamplingLens, BWT_GI_TapCount_UI, BWT_GI_RadiusPixels, BWT_GI_RotationDegrees, BWT_GI_DepthMode);
    float sameLayer = black_wand_Proc_DepthSameLayer(centerDepth, tapDepth, BWT_GI_DepthRejectThreshold, BWT_GI_DepthRejectSoftness);
    float darkReceiveMask = 1.0 - black_wand_BWT_SoftMask(black_wand_BWT_Luma(sourceColor), 0.62, 0.22);
    float brightDonorMask = black_wand_BWT_SoftMask(black_wand_BWT_Luma(tapColor), 0.35, 0.24);
    float giMask = saturate(sameLayer * darkReceiveMask * brightDonorMask);
    float3 indirectColor = black_wand_Proc_ColorSaturateAmount(tapColor, BWT_GI_ColorBleedSaturation) * giMask;
    float3 outputColor = black_wand_Proc_ComposeAdditive(sourceColor, indirectColor, min(BWT_GI_Strength * BWT_GI_MasterIntensity, BWT_GI_MaxContribution));
    if (BWT_GI_DebugView == 1) return black_wand_Proc_OutColor(indirectColor, BWT_GI_VisibleFloor);
    if (BWT_GI_DebugView == 2) return black_wand_Proc_OutScalar(giMask, 1.0, BWT_GI_VisibleFloor);
    if (BWT_GI_DebugView == 3) return black_wand_Proc_OutScalar(sameLayer, 1.0, BWT_GI_VisibleFloor);
    if (BWT_GI_DebugView == 4) return black_wand_Proc_OutDelta(outputColor, sourceColor, 4.0, BWT_GI_VisibleFloor);
    return black_wand_Proc_OutColor(outputColor, BWT_GI_VisibleFloor);
}

technique BlackWand_GI_ColorBleed <
    ui_label = "@BlackWand - GI - Color Bleed";
    ui_tooltip = "Screen-space color-bleed approximation using the primitive sampling lens and a depth rejection guard.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_GI_ColorBleed_PS;
    }
}

