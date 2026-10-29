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
// @BlackWand clean user-menu filter: @BlackWand - Smart AA - Edge Clean. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_AA_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Smart AA - Edge Clean";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 99 Advanced / Debug";
    ui_items = "Final Image\0Edge Mask - detected edges\0Coherence Candidate - smoothed image\0Detail Restore - recovered fine detail\0Apply Mask - where AA is allowed\0";
    ui_tooltip = "Final Image shows the finished AA/coherence pass. Other views isolate edge detection, denoise candidate, detail restoration, or application mask.";
    ui_category_closed = true;
> = 0;
uniform float BWT_AA_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall mix of the AA/coherence result into the source image.";
> = 1.0;
uniform float BWT_AA_EdgeThreshold <
    ui_type = "slider";
    ui_label = "Edge Cutoff";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Minimum detected edge value before smoothing and edge cleanup are allowed.";
> = 0.055;
uniform float BWT_AA_EdgeSoftness <
    ui_type = "slider";
    ui_label = "Edge Feather";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 0.5;
    ui_step = 0.001;
    ui_tooltip = "Softens the edge cutoff. Raise for smoother transitions; lower for sharper edge-only application.";
    ui_category_closed = true;
> = 0.060;
uniform float BWT_AA_EdgeGain <
    ui_type = "slider";
    ui_label = "Edge Sensitivity";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 01 Controls";
    ui_min = 0.0;
    ui_max = 48.0;
    ui_step = 0.01;
    ui_tooltip = "Amplifies the edge detector before thresholding. Raise it when edges are missed; lower it when too much texture is treated as an edge.";
> = 8.0;
uniform float BWT_AA_CoherenceBlend <
    ui_type = "slider";
    ui_label = "Smoothing";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "How strongly the local coherent sample replaces noisy source pixels.";
> = 0.35;
uniform float BWT_AA_EdgePreserve <
    ui_type = "slider";
    ui_label = "Edge Preservation";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Controls how much detected edges resist smoothing. Lower for stronger smoothing; higher for more edge protection.";
    ui_category_closed = true;
> = 0.75;
uniform float BWT_AA_DetailRestore <
    ui_type = "slider";
    ui_label = "Detail Return";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Adds back small detail after the smoothing stage so the image does not become mushy.";
> = 0.35;
static const int BWT_AA_InputSamplingLens = black_wand_LENS_FIBONACCI55; // internal fixed control; hidden from the clean menu
uniform float BWT_AA_TapCount_UI <
    ui_type = "slider";
    ui_label = "Sample Budget";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 99 Advanced / Sampling";
    ui_min = 1.0;
    ui_max = 55.0;
    ui_step = 1.0;
    ui_tooltip = "Maximum number of samples used by the selected internal AA sampling lens.";
    ui_category_closed = true;
> = 21.0;
uniform float BWT_AA_RadiusPixels <
    ui_type = "slider";
    ui_label = "Sample Radius";
    ui_category = "@BlackWand - Smart AA - Edge Clean / 99 Advanced / Sampling";
    ui_min = 0.0;
    ui_max = 8.0;
    ui_step = 0.05;
    ui_tooltip = "Pixel radius for the AA/coherence sampling pass.";
    ui_category_closed = true;
> = 1.25;
static const float BWT_AA_RotationDegrees = 0.0; // internal fixed control; hidden from the clean menu
static const int BWT_AA_OutputBlendMaskSource = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWT_AA_OutputBlendMaskInfluence = 1.0; // internal fixed control; hidden from the clean menu
static const float BWT_AA_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_AA_Coherence_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float edgeSeed = black_wand_BWT_LensAverageLumaDelta(uv, BWT_AA_InputSamplingLens, BWT_AA_TapCount_UI, BWT_AA_RadiusPixels, BWT_AA_RotationDegrees, BWT_AA_EdgeGain);
    float edgeMask = black_wand_Complex_AA_EdgeMask(edgeSeed, BWT_AA_EdgeThreshold, BWT_AA_EdgeSoftness);
    float3 lensBlend = black_wand_BWT_FirstLensAverage(uv, BWT_AA_InputSamplingLens, BWT_AA_TapCount_UI, BWT_AA_RadiusPixels, BWT_AA_RotationDegrees, 0.35);
    float preserveFactor = lerp(1.0, 1.0 - edgeMask, saturate(BWT_AA_EdgePreserve));
    float3 coherenceColor = lerp(sourceColor, lensBlend, saturate(BWT_AA_CoherenceBlend) * preserveFactor);
    float3 detailDelta = sourceColor - black_wand_BWT_LocalAverage4(uv, max(1.0, BWT_AA_RadiusPixels));
    float3 restoredColor = saturate(coherenceColor + detailDelta * BWT_AA_DetailRestore * edgeMask);
    float outputMask = black_wand_BWT_OutputRoleMask(BWT_AA_OutputBlendMaskSource, uv, sourceColor, BWT_AA_OutputBlendMaskInfluence);
    float3 outputColor = lerp(sourceColor, restoredColor, saturate(BWT_AA_MasterIntensity) * outputMask);
    if (BWT_AA_DebugView == 1) return black_wand_Proc_OutScalar(edgeMask, 1.0, BWT_AA_VisibleFloor);
    if (BWT_AA_DebugView == 2) return black_wand_Proc_OutColor(coherenceColor, BWT_AA_VisibleFloor);
    if (BWT_AA_DebugView == 3) return black_wand_Proc_OutSigned(black_wand_BWT_Luma(detailDelta), 8.0, BWT_AA_VisibleFloor);
    if (BWT_AA_DebugView == 4) return black_wand_Proc_OutScalar(outputMask, 1.0, BWT_AA_VisibleFloor);
    return black_wand_Proc_OutColor(outputColor, BWT_AA_VisibleFloor);
}

technique BlackWand_SmartAA_EdgeClean <
    ui_label = "@BlackWand - Smart AA - Edge Clean";
    ui_tooltip = "Edge-aware anti-aliasing and small-radius coherence cleanup. Use this first for shimmer, jagged edges, and fine edge crawl.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_AA_Coherence_PS;
    }
}

