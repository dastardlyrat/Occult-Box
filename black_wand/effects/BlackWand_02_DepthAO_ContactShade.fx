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
// @BlackWand clean user-menu filter: @BlackWand - Depth AO - Contact Shade. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_AO_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Depth AO - Contact Shade";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 99 Advanced / Debug";
    ui_items = "Final Image\0Occlusion Mask - darkening driver\0Depth Edge - geometry breaks\0Depth Available - valid depth pixels\0Sample Depth Delta - neighbor comparison\0";
    ui_tooltip = "Switch between final AO, raw occlusion, depth edge, depth validity, and sample depth-delta diagnostics.";
    ui_category_closed = true;
> = 0;
uniform float BWT_AO_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall amount of the AO pass applied to the source image.";
> = 1.0;
uniform float BWT_AO_Strength <
    ui_type = "slider";
    ui_label = "Darkening Amount";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Controls how strongly the occlusion mask darkens nearby surfaces.";
> = 1.0;
uniform float BWT_AO_Power <
    ui_type = "slider";
    ui_label = "Occlusion Curve";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 99 Advanced / Tunable Controls";
    ui_min = 0.25;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Shapes the occlusion mask after detection. Higher values tighten contact shade; lower values broaden it.";
    ui_category_closed = true;
> = 1.35;
uniform float BWT_AO_MaxDarkening <
    ui_type = "slider";
    ui_label = "Dark Limit";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Hard cap on how much the AO pass can darken the final image.";
> = 0.55;
uniform float BWT_AO_DepthBias <
    ui_type = "slider";
    ui_label = "Bias";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 01 Controls";
    ui_min = -0.2;
    ui_max = 0.2;
    ui_step = 0.0001;
    ui_tooltip = "Small offset used to avoid self-occlusion. Raise slightly if flat surfaces dirty themselves.";
> = 0.002;
uniform float BWT_AO_OcclusionGain <
    ui_type = "slider";
    ui_label = "Depth Sensitivity";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 01 Controls";
    ui_min = 0.0;
    ui_max = 96.0;
    ui_step = 0.01;
    ui_tooltip = "Amplifies sampled depth differences before they become occlusion.";
> = 18.0;
static const int BWT_AO_InputSamplingLens = black_wand_LENS_RADIAL13; // internal fixed control; hidden from the clean menu
uniform float BWT_AO_TapCount_UI <
    ui_type = "slider";
    ui_label = "Sample Budget";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 99 Advanced / Sampling";
    ui_min = 1.0;
    ui_max = 55.0;
    ui_step = 1.0;
    ui_tooltip = "Maximum number of depth samples used by the internal AO sampling lens.";
    ui_category_closed = true;
> = 13.0;
uniform float BWT_AO_RadiusPixels <
    ui_type = "slider";
    ui_label = "Radius";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 01 Controls";
    ui_min = 0.0;
    ui_max = 128.0;
    ui_step = 0.05;
    ui_tooltip = "Screen-space reach of the AO probe in pixels.";
> = 6.0;
uniform float BWT_AO_RotationDegrees <
    ui_type = "slider";
    ui_label = "Sample Rotation";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 99 Advanced / Sampling";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Rotates the AO sampling pattern to reduce directional artifacts.";
    ui_category_closed = true;
> = 0.0;
static const int BWT_AO_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
static const float BWT_AO_DepthAvailabilityThreshold = 0.00005; // internal fixed control; hidden from the clean menu
uniform float BWT_AO_DepthEdgeGain <
    ui_type = "slider";
    ui_label = "Depth Edge Response";
    ui_category = "@BlackWand - Depth AO - Contact Shade / 99 Advanced / Depth";
    ui_min = 0.0;
    ui_max = 500.0;
    ui_step = 1.0;
    ui_tooltip = "Strength of geometry-break detection used as an extra AO/contact term.";
    ui_category_closed = true;
> = 120.0;
static const float BWT_AO_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_AO_Depth_RayM_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float centerDepth = black_wand_Proc_DepthValue(uv, BWT_AO_DepthMode);
    float sampleDepth = black_wand_BWT_LensAverageDepth(uv, BWT_AO_InputSamplingLens, BWT_AO_TapCount_UI, BWT_AO_RadiusPixels, BWT_AO_RotationDegrees, BWT_AO_DepthMode);
    float depthAvailable = black_wand_Proc_DepthAvailable(uv, BWT_AO_DepthMode, BWT_AO_DepthAvailabilityThreshold);
    float sampleOcc = black_wand_Proc_AOFromDepthDelta(centerDepth, sampleDepth, BWT_AO_DepthBias, BWT_AO_OcclusionGain);
    float edgeOcc = black_wand_BWT_DepthEdge(uv, BWT_AO_DepthMode, BWT_AO_DepthEdgeGain);
    float occlusion = saturate(max(sampleOcc, edgeOcc * 0.55) * depthAvailable);
    occlusion = pow(max(0.0, occlusion), BWT_AO_Power);
    float3 aoColor = black_wand_Proc_AOApply(sourceColor, occlusion * BWT_AO_MaxDarkening, BWT_AO_Strength * BWT_AO_MasterIntensity);
    if (BWT_AO_DebugView == 1) return black_wand_Proc_OutScalar(occlusion, 1.0, BWT_AO_VisibleFloor);
    if (BWT_AO_DebugView == 2) return black_wand_Proc_OutScalar(edgeOcc, 1.0, BWT_AO_VisibleFloor);
    if (BWT_AO_DebugView == 3) return black_wand_Proc_OutScalar(depthAvailable, 1.0, BWT_AO_VisibleFloor);
    if (BWT_AO_DebugView == 4) return black_wand_Proc_OutScalar(abs(centerDepth - sampleDepth) * BWT_AO_OcclusionGain, 1.0, BWT_AO_VisibleFloor);
    return black_wand_Proc_OutColor(aoColor, BWT_AO_VisibleFloor);
}

technique BlackWand_DepthAO_ContactShade <
    ui_label = "@BlackWand - Depth AO - Contact Shade";
    ui_tooltip = "Depth-buffer ambient occlusion/contact shadow pass. Tune depth first, then radius, then strength.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_AO_Depth_RayM_PS;
    }
}

