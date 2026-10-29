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
// @BlackWand clean user-menu filter: @BlackWand - Hatch / Ink / Cel. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_Ink_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Hatch / Ink / Cel";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 99 Advanced / Debug";
    ui_items = "Final Image\0Ink Edge Mask\0Cel Bands\0Hatch Pattern\0Depth Edge Mask\0";
    ui_tooltip = "Switch between final stylized output, ink edges, cel bands, hatch pattern, and depth edges.";
    ui_category_closed = true;
> = 0;
uniform float BWT_Ink_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall amount of stylization applied to the image.";
> = 1.0;
uniform float BWT_Ink_InkStrength <
    ui_type = "slider";
    ui_label = "Ink Edges";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Strength of dark outline/ink response on detected edges.";
> = 1.0;
uniform float BWT_Ink_StylizeStrength <
    ui_type = "slider";
    ui_label = "Cel Amount";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "How strongly the image is pushed toward cel-shaded tonal bands.";
> = 0.65;
uniform float BWT_Ink_CelBands <
    ui_type = "slider";
    ui_label = "Cel Bands";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 01 Controls";
    ui_min = 2.0;
    ui_max = 12.0;
    ui_step = 1.0;
    ui_tooltip = "Approximate number of tonal steps in the cel-shading stage.";
> = 5.0;
uniform float BWT_Ink_BandSoftness <
    ui_type = "slider";
    ui_label = "Cel Band Feather";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softens transitions between cel shade bands.";
    ui_category_closed = true;
> = 0.25;
uniform float BWT_Ink_LumaEdgeGain <
    ui_type = "slider";
    ui_label = "Edge Sensitivity";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 01 Controls";
    ui_min = 0.0;
    ui_max = 96.0;
    ui_step = 0.01;
    ui_tooltip = "Amplifies luma edges before ink thresholding.";
> = 12.0;
uniform float BWT_Ink_EdgeThreshold <
    ui_type = "slider";
    ui_label = "Ink Edge Threshold";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 99 Advanced / Edge";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Depth-edge amount required before ink lines appear.";
    ui_category_closed = true;
> = 0.18;
uniform float BWT_Ink_EdgeSoftness <
    ui_type = "slider";
    ui_label = "Ink Edge Feather";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 99 Advanced / Edge";
    ui_min = 0.0;
    ui_max = 0.5;
    ui_step = 0.001;
    ui_tooltip = "Softens the ink-line edge threshold.";
    ui_category_closed = true;
> = 0.08;
static const int BWT_Ink_HatchSource = black_wand_HATCH_FIBONACCI_BIO; // internal fixed control; hidden from the clean menu
uniform float BWT_Ink_HatchInfluence <
    ui_type = "slider";
    ui_label = "Hatch Amount";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Amount of hatch pattern added to shaded regions.";
> = 0.45;
uniform float BWT_Ink_HatchPhase <
    ui_type = "slider";
    ui_label = "Hatch Phase";
    ui_category = "@BlackWand - Hatch / Ink / Cel / 99 Advanced / Pattern";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Offsets the hatch pattern phase without changing its source family.";
    ui_category_closed = true;
> = 0.0;
static const int BWT_Ink_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
static const float BWT_Ink_DepthEdgeGain = 220.0; // internal fixed control; hidden from the clean menu
static const float BWT_Ink_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_Hatch_Ink_Cel_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float sourceLuma = black_wand_BWT_Luma(sourceColor);
    float centerDepth = black_wand_Proc_DepthValue(uv, BWT_Ink_DepthMode);
    float lumaEdge = black_wand_BWT_LumaEdge(uv, BWT_Ink_LumaEdgeGain);
    float depthEdge = black_wand_BWT_DepthEdge(uv, BWT_Ink_DepthMode, BWT_Ink_DepthEdgeGain);
    float edgeMask = black_wand_BWT_SoftMask(max(lumaEdge, depthEdge), BWT_Ink_EdgeThreshold, BWT_Ink_EdgeSoftness);
    float hatchMask = black_wand_Proc_InputHatch(BWT_Ink_HatchSource, uv, centerDepth, sourceLuma, BWT_Ink_HatchPhase);
    float inkMask = saturate(max(edgeMask, hatchMask * BWT_Ink_HatchInfluence));
    float3 celColor = black_wand_BWT_CelBand(sourceColor, BWT_Ink_CelBands, BWT_Ink_BandSoftness, 1.0);
    float3 stylizedColor = lerp(sourceColor, celColor, BWT_Ink_StylizeStrength);
    float3 inkedColor = black_wand_Proc_HatchInk(stylizedColor, inkMask, BWT_Ink_InkStrength);
    float3 outputColor = lerp(sourceColor, inkedColor, saturate(BWT_Ink_MasterIntensity));
    if (BWT_Ink_DebugView == 1) return black_wand_Proc_OutColor(celColor, BWT_Ink_VisibleFloor);
    if (BWT_Ink_DebugView == 2) return black_wand_Proc_OutScalar(edgeMask, 1.0, BWT_Ink_VisibleFloor);
    if (BWT_Ink_DebugView == 3) return black_wand_Proc_OutScalar(hatchMask, 1.0, BWT_Ink_VisibleFloor);
    if (BWT_Ink_DebugView == 4) return black_wand_Proc_OutScalar(depthEdge, 1.0, BWT_Ink_VisibleFloor);
    return black_wand_Proc_OutColor(outputColor, BWT_Ink_VisibleFloor);
}

technique BlackWand_HatchInkCel <
    ui_label = "@BlackWand - Hatch / Ink / Cel";
    ui_tooltip = "Stylized ink edges, cel-band toning, and hatch overlay from the BlackWand CellHatchInk family.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_Hatch_Ink_Cel_PS;
    }
}

