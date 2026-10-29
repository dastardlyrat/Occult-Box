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
// @BlackWand clean user-menu filter: @BlackWand - Tone Detail - Richness. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_Tone_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Tone Detail - Richness";
    ui_category = "@BlackWand - Tone Detail - Richness / 99 Advanced / Debug";
    ui_items = "Final Image\0Shaped Luma\0Local Contrast Mask\0Detail Delta\0Shadow Lift Mask\0";
    ui_tooltip = "Switch between final tone pass, shaped luma, local contrast, detail delta, and shadow-lift mask.";
    ui_category_closed = true;
> = 0;
uniform float BWT_Tone_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Tone Detail - Richness / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall amount of tone/detail result mixed into the source image.";
> = 1.0;
uniform float BWT_Tone_RichnessStrength <
    ui_type = "slider";
    ui_label = "Richness";
    ui_category = "@BlackWand - Tone Detail - Richness / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Strength of local tone shaping around the selected tonal pivot.";
> = 0.75;
uniform float BWT_Tone_ColorfulnessStrength <
    ui_type = "slider";
    ui_label = "Colorfulness";
    ui_category = "@BlackWand - Tone Detail - Richness / 01 Controls";
    ui_min = 0.0;
    ui_max = 3.0;
    ui_step = 0.001;
    ui_tooltip = "Final color saturation after tone shaping.";
> = 1.10;
uniform float BWT_Tone_TonePivot <
    ui_type = "slider";
    ui_label = "Tone Pivot";
    ui_category = "@BlackWand - Tone Detail - Richness / 99 Advanced / Tonal Shape";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Midpoint used by the tonal richness curve.";
    ui_category_closed = true;
> = 0.45;
uniform float BWT_Tone_ToneWidth <
    ui_type = "slider";
    ui_label = "Tone Width";
    ui_category = "@BlackWand - Tone Detail - Richness / 99 Advanced / Tonal Shape";
    ui_min = 0.01;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Width around the tone pivot affected by the richness curve.";
    ui_category_closed = true;
> = 0.30;
uniform float BWT_Tone_ShadowLift <
    ui_type = "slider";
    ui_label = "Shadow Lift";
    ui_category = "@BlackWand - Tone Detail - Richness / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Raises dark tones before final detail is applied.";
> = 0.08;
uniform float BWT_Tone_HighlightCompression <
    ui_type = "slider";
    ui_label = "Highlight Guard";
    ui_category = "@BlackWand - Tone Detail - Richness / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Compresses bright tones to reduce clipping and glare.";
> = 0.18;
uniform float BWT_Tone_LocalRadiusPixels <
    ui_type = "slider";
    ui_label = "Local Detail Radius";
    ui_category = "@BlackWand - Tone Detail - Richness / 99 Advanced / Local Detail";
    ui_min = 0.0;
    ui_max = 64.0;
    ui_step = 0.05;
    ui_tooltip = "Pixel radius for the local average used to derive detail richness.";
    ui_category_closed = true;
> = 10.0;
uniform float BWT_Tone_LocalContrast <
    ui_type = "slider";
    ui_label = "Local Contrast Amount";
    ui_category = "@BlackWand - Tone Detail - Richness / 99 Advanced / Local Detail";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Amount of local-contrast shaping added to the tone pass.";
    ui_category_closed = true;
> = 0.65;
uniform float BWT_Tone_DetailStrength <
    ui_type = "slider";
    ui_label = "Detail Return";
    ui_category = "@BlackWand - Tone Detail - Richness / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Amount of fine detail added back after tone shaping.";
> = 0.35;
static const float BWT_Tone_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_Tone_Detail_Richness_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float sourceLuma = black_wand_BWT_Luma(sourceColor);
    float3 localAverage = black_wand_BWT_LocalAverage8(uv, BWT_Tone_LocalRadiusPixels);
    float localLuma = black_wand_BWT_Luma(localAverage);
    float localContrast = saturate(abs(sourceLuma - localLuma) * BWT_Tone_LocalContrast * 4.0);
    float toneWindow = 1.0 - saturate(abs(sourceLuma - BWT_Tone_TonePivot) / max(BWT_Tone_ToneWidth, 0.000001));
    float shapedLuma = saturate(sourceLuma + (sourceLuma - localLuma) * localContrast * BWT_Tone_RichnessStrength * toneWindow);
    shapedLuma = lerp(shapedLuma, shapedLuma / (1.0 + shapedLuma * BWT_Tone_HighlightCompression), black_wand_BWT_SoftMask(shapedLuma, 0.72, 0.20));
    float shadowMask = 1.0 - black_wand_BWT_SoftMask(sourceLuma, 0.32, 0.18);
    shapedLuma = saturate(shapedLuma + shadowMask * BWT_Tone_ShadowLift);
    float3 richColor = black_wand_BWT_ReapplyLuma(sourceColor, shapedLuma, 1.0);
    richColor = black_wand_Proc_ColorSaturateAmount(richColor, BWT_Tone_ColorfulnessStrength);
    float3 detailDelta = sourceColor - localAverage;
    float3 detailColor = saturate(richColor + detailDelta * BWT_Tone_DetailStrength * toneWindow);
    float3 outputColor = lerp(sourceColor, detailColor, saturate(BWT_Tone_MasterIntensity));
    if (BWT_Tone_DebugView == 1) return black_wand_Proc_OutScalar(shapedLuma, 1.0, BWT_Tone_VisibleFloor);
    if (BWT_Tone_DebugView == 2) return black_wand_Proc_OutScalar(localContrast, 1.0, BWT_Tone_VisibleFloor);
    if (BWT_Tone_DebugView == 3) return black_wand_Proc_OutSigned(black_wand_BWT_Luma(detailDelta), 8.0, BWT_Tone_VisibleFloor);
    if (BWT_Tone_DebugView == 4) return black_wand_Proc_OutScalar(shadowMask, 1.0, BWT_Tone_VisibleFloor);
    return black_wand_Proc_OutColor(outputColor, BWT_Tone_VisibleFloor);
}

technique BlackWand_ToneDetail_Richness <
    ui_label = "@BlackWand - Tone Detail - Richness";
    ui_tooltip = "Local tone shaping, shadow lift, highlight compression, and detail recovery. Use as a final image-richness pass.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_Tone_Detail_Richness_PS;
    }
}

