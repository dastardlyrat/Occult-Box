/*
    black_wand_DepthOracle.fx
    v0.9 luma fallback diagnostics iteration of the depth oracle harness.

    Design boundary:
    - Official ReShade linear depth is the oracle/reference branch.
    - Runtime evidence promoted Official Normal as the trusted visible path; v0.9 adds luma-derived surrogate diagnostics only as an explicit fallback layer, never as truth depth.
    - Manual decode is a live preview branch for diagnosis only.
    - RM probe is a shallow fixed-step continuity diagnostic only. Luma RM support is likewise diagnostic only.
    - Projected candidate selection from older builds is intentionally removed from the default path.
    - This is original project code and does not copy DisplayDepth labels, prose, comments, function names, pass names, or structure.
*/

#include "ReShade.fxh"
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

#ifndef BLACK_WAND_DO_LUMA_FALLBACK_OFF
#define BLACK_WAND_DO_LUMA_FALLBACK_OFF 0
#endif
#ifndef BLACK_WAND_DO_LUMA_FALLBACK_DEPTH_MISSING_ONLY
#define BLACK_WAND_DO_LUMA_FALLBACK_DEPTH_MISSING_ONLY 1
#endif
#ifndef BLACK_WAND_DO_LUMA_FALLBACK_BLEND_BY_CONFIDENCE
#define BLACK_WAND_DO_LUMA_FALLBACK_BLEND_BY_CONFIDENCE 2
#endif
#ifndef BLACK_WAND_DO_LUMA_FALLBACK_FORCE
#define BLACK_WAND_DO_LUMA_FALLBACK_FORCE 3
#endif
#include "../header/black_wand_DO_All.fxh"

#define BLACK_WAND_DO_VIEW_SOURCE 0
#define BLACK_WAND_DO_VIEW_UV 1
#define BLACK_WAND_DO_VIEW_CHECKER 2
#define BLACK_WAND_DO_VIEW_RAW 3
#define BLACK_WAND_DO_VIEW_OFFICIAL 4
#define BLACK_WAND_DO_VIEW_MANUAL 5
#define BLACK_WAND_DO_VIEW_COMPARE 6
#define BLACK_WAND_DO_VIEW_NORMAL_OFFICIAL 7
#define BLACK_WAND_DO_VIEW_NORMAL_MANUAL 8
#define BLACK_WAND_DO_VIEW_PRESENCE_BARS 9
#define BLACK_WAND_DO_VIEW_ENDPOINT_MASK 10
#define BLACK_WAND_DO_VIEW_DIFF_HEAT 11
#define BLACK_WAND_DO_VIEW_RM_HORIZONTAL 12
#define BLACK_WAND_DO_VIEW_RM_VERTICAL 13
#define BLACK_WAND_DO_VIEW_SPLIT_NORMAL_DEPTH 14
#define BLACK_WAND_DO_VIEW_OVERLAY_OFFICIAL 15
#define BLACK_WAND_DO_VIEW_OFFICIAL_FOCUSED 16
#define BLACK_WAND_DO_VIEW_OFFICIAL_DETAIL 17
#define BLACK_WAND_DO_VIEW_OFFICIAL_BANDS 18
#define BLACK_WAND_DO_VIEW_OFFICIAL_EDGE_CONFIDENCE 19
#define BLACK_WAND_DO_VIEW_OFFICIAL_NORMAL_RELIEF 20
#define BLACK_WAND_DO_VIEW_RM_CONTINUITY_OVERLAY 21
#define BLACK_WAND_DO_VIEW_OFFICIAL_EDGE_MID_COVERAGE 22
#define BLACK_WAND_DO_VIEW_RM_MID_COVERAGE_HORIZONTAL 23
#define BLACK_WAND_DO_VIEW_RM_MID_COVERAGE_VERTICAL 24
#define BLACK_WAND_DO_VIEW_LUMA_LOCAL_CONTRAST 25
#define BLACK_WAND_DO_VIEW_LUMA_SURROGATE_DEPTH 26
#define BLACK_WAND_DO_VIEW_LUMA_FALLBACK_AO_RAW 27
#define BLACK_WAND_DO_VIEW_LUMA_FALLBACK_ACTIVE 28
#define BLACK_WAND_DO_VIEW_OFFICIAL_LUMA_HYBRID_CONFIDENCE 29
#define BLACK_WAND_DO_VIEW_DEPTH_MISSING_POLICY 30
#define BLACK_WAND_DO_VIEW_LUMA_FALLBACK_OVERLAY 31
#define BLACK_WAND_DO_VIEW_LUMA_RM_SUPPORT_HORIZONTAL 32
#define BLACK_WAND_DO_VIEW_LUMA_RM_SUPPORT_VERTICAL 33

#define BLACK_WAND_DO_LUMA_FALLBACK_OFF 0
#define BLACK_WAND_DO_LUMA_FALLBACK_DEPTH_MISSING_ONLY 1
#define BLACK_WAND_DO_LUMA_FALLBACK_BLEND_BY_CONFIDENCE 2
#define BLACK_WAND_DO_LUMA_FALLBACK_FORCE 3

uniform int black_wand_DO_ViewMode <
    ui_category = "Depth Oracle / View";
    ui_label = "Debug View";
    ui_type = "combo";
    ui_items = "Source Image\0UV Gradient\0Checkerboard\0Raw Depth Direct\0Official Linear Depth\0Manual Preview Depth\0Raw Manual Official Compare\0Official Normal\0Manual Preview Normal\0Depth Presence Bars\0Endpoint Mask\0Difference Heat\0RM Probe Horizontal\0RM Probe Vertical\0Split Normal | Official Depth\0Overlay Official Depth On Source\0Official Depth Focused\0Official Depth Local Detail\0Official Depth Bands\0Official Edge Confidence\0Official Normal Relief\0RM Continuity Overlay\0Official Edge Mid Coverage\0RM Mid Coverage Horizontal\0RM Mid Coverage Vertical\0Luma Local Contrast\0Luma Surrogate Depth\0Luma Fallback AO Raw\0Luma Fallback Active\0Official/Luma Hybrid Confidence\0Depth Missing Policy\0Luma Fallback Overlay\0Luma RM Support Horizontal\0Luma RM Support Vertical\0";
    ui_tooltip = "Clean DisplayDepth-parity diagnostic order. Source/UV/checker prove output before depth; official depth is the oracle path.";
> = BLACK_WAND_DO_VIEW_SOURCE;

uniform bool black_wand_DO_ManualPreviewEnabled <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Enable Manual Preview Branch";
    ui_tooltip = "Manual branch is for diagnosis only. Official ReShade linear depth remains the oracle/reference branch.";
> = false;

uniform bool black_wand_DO_FlipVertical <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Flip Vertical";
> = false;

uniform float2 black_wand_DO_UVScale <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Depth UV Scale";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 4.000; ui_step = 0.001;
> = float2(1.0, 1.0);

uniform int2 black_wand_DO_PixelOffset <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Depth Pixel Offset";
    ui_type = "slider";
    ui_min = -256; ui_max = 256; ui_step = 1;
> = int2(0, 0);

uniform bool black_wand_DO_ReverseDepth <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Reverse Depth";
> = RESHADE_DEPTH_INPUT_IS_REVERSED;

uniform bool black_wand_DO_LogDepth <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Log Depth Decode";
> = RESHADE_DEPTH_INPUT_IS_LOGARITHMIC;

uniform float black_wand_DO_DepthMultiplier <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Depth Multiplier";
    ui_type = "drag";
    ui_min = 0.000; ui_max = 8.000; ui_step = 0.001;
> = RESHADE_DEPTH_MULTIPLIER;

uniform float black_wand_DO_LogCurve <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Log Curve";
    ui_type = "drag";
    ui_min = 0.0001; ui_max = 1.0000; ui_step = 0.0001;
> = 0.0100;

uniform float black_wand_DO_NearPlane <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Near Plane";
    ui_type = "drag";
    ui_min = 0.001; ui_max = 10.000; ui_step = 0.001;
> = 1.000;

uniform float black_wand_DO_FarPlane <
    ui_category = "Depth Oracle / Manual Preview";
    ui_label = "Manual Far Plane";
    ui_type = "drag";
    ui_min = 1.000; ui_max = 10000.000; ui_step = 1.000;
> = RESHADE_DEPTH_LINEARIZATION_FAR_PLANE;

uniform float black_wand_DO_EndpointMargin <
    ui_category = "Depth Oracle / Validity";
    ui_label = "Endpoint Rejection Margin";
    ui_type = "drag";
    ui_min = 0.000000; ui_max = 0.100000; ui_step = 0.000001;
> = 0.000001;

uniform float black_wand_DO_NormalRadius <
    ui_category = "Depth Oracle / Normal";
    ui_label = "Normal Sample Radius";
    ui_type = "drag";
    ui_min = 1.000; ui_max = 4.000; ui_step = 0.125;
> = 1.000;

uniform float black_wand_DO_RMProbeStepPixels <
    ui_category = "Depth Oracle / RM Probe";
    ui_label = "RM Probe Step Pixels";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 8.000; ui_step = 0.125;
    ui_tooltip = "Fixed, shallow screen-space depth-continuity probe step. This does not replace depth normalization.";
> = 1.000;

uniform float black_wand_DO_RMDepthTolerance <
    ui_category = "Depth Oracle / RM Probe";
    ui_label = "RM Probe Depth Tolerance";
    ui_type = "drag";
    ui_min = 0.000001; ui_max = 0.100000; ui_step = 0.000001;
> = 0.002000;

uniform float black_wand_DO_CompareScale <
    ui_category = "Depth Oracle / Compare";
    ui_label = "Difference Heat Scale";
    ui_type = "drag";
    ui_min = 1.000; ui_max = 1000.000; ui_step = 1.000;
> = 100.000;

uniform float black_wand_DO_DisplayBlackPoint <
    ui_category = "Depth Oracle / Display";
    ui_label = "Display Black Point";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.000;

uniform float black_wand_DO_DisplayWhitePoint <
    ui_category = "Depth Oracle / Display";
    ui_label = "Display White Point";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 1.000;

uniform float black_wand_DO_DisplayGamma <
    ui_category = "Depth Oracle / Display";
    ui_label = "Display Gamma";
    ui_type = "drag";
    ui_min = 0.100; ui_max = 5.000; ui_step = 0.001;
> = 1.000;

uniform float black_wand_DO_DisplayContrast <
    ui_category = "Depth Oracle / Display";
    ui_label = "Display Contrast";
    ui_type = "drag";
    ui_min = 0.000; ui_max = 5.000; ui_step = 0.001;
> = 1.000;

uniform float black_wand_DO_DisplayExposure <
    ui_category = "Depth Oracle / Display";
    ui_label = "Display Exposure";
    ui_type = "drag";
    ui_min = -8.000; ui_max = 8.000; ui_step = 0.001;
> = 0.000;

uniform bool black_wand_DO_DisplayInvert <
    ui_category = "Depth Oracle / Display";
    ui_label = "Display Invert";
> = false;

uniform bool black_wand_DO_LiftDarkDiagnostics <
    ui_category = "Depth Oracle / Display";
    ui_label = "Lift Dark Diagnostics";
    ui_tooltip = "Raises scalar views slightly so valid low-depth output is not mistaken for a blank pass.";
> = true;

uniform float black_wand_DO_VisibilityFloor <
    ui_category = "Depth Oracle / Display";
    ui_label = "Diagnostic Visibility Floor";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 0.250; ui_step = 0.001;
> = 0.035;

uniform float black_wand_DO_OverlayStrength <
    ui_category = "Depth Oracle / Display";
    ui_label = "Overlay Strength";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.700;

uniform float black_wand_DO_OfficialFocusStrength <
    ui_category = "Depth Oracle / Official Baseline";
    ui_label = "Official Depth Focus Strength";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 64.000; ui_step = 0.125;
    ui_tooltip = "Compresses official linear depth into a readable scalar view. Higher values brighten near/mid depth detail.";
> = 8.000;

uniform float black_wand_DO_OfficialDetailRadius <
    ui_category = "Depth Oracle / Official Baseline";
    ui_label = "Official Detail Radius";
    ui_type = "drag";
    ui_min = 1.000; ui_max = 4.000; ui_step = 0.125;
> = 1.000;

uniform float black_wand_DO_OfficialEdgeTolerance <
    ui_category = "Depth Oracle / Official Baseline";
    ui_label = "Official Edge Tolerance";
    ui_type = "drag";
    ui_min = 0.000001; ui_max = 0.100000; ui_step = 0.000001;
> = 0.002000;

uniform float black_wand_DO_OfficialBandCount <
    ui_category = "Depth Oracle / Official Baseline";
    ui_label = "Official Depth Band Count";
    ui_type = "drag";
    ui_min = 2.000; ui_max = 128.000; ui_step = 1.000;
> = 32.000;

uniform float black_wand_DO_OfficialBandLineWidth <
    ui_category = "Depth Oracle / Official Baseline";
    ui_label = "Official Band Line Width";
    ui_type = "drag";
    ui_min = 0.002; ui_max = 0.250; ui_step = 0.001;
> = 0.035;

uniform float black_wand_DO_NormalReliefStrength <
    ui_category = "Depth Oracle / Official Baseline";
    ui_label = "Official Normal Relief Strength";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.650;

/* v0.8 mid-coverage controls.
   RC3 debug shaders repeatedly shape visibility with gain + threshold + softness,
   rather than showing raw saturated deltas. These controls apply that pattern to
   official-depth edge and RM continuity diagnostics. */
uniform float black_wand_DO_OfficialEdgeGain <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Official Edge Gain";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 512.000; ui_step = 0.250;
    ui_tooltip = "Scales local official-depth differences before threshold/softness shaping. Lower this if edge views are solid red.";
> = 32.000;

uniform float black_wand_DO_OfficialEdgeThreshold <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Official Edge Threshold";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 4.000; ui_step = 0.001;
    ui_tooltip = "Edge response starts here after gain. Raise this if the view is over-covered.";
> = 0.160;

uniform float black_wand_DO_OfficialEdgeSoftness <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Official Edge Softness";
    ui_type = "slider";
    ui_min = 0.001; ui_max = 8.000; ui_step = 0.001;
    ui_tooltip = "Soft transition width around the edge threshold. Raise this for mid coverage instead of red-only saturation.";
> = 1.250;

uniform float black_wand_DO_MidCoverageCenter <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Mid Coverage Center";
    ui_type = "slider";
    ui_min = 0.050; ui_max = 0.950; ui_step = 0.001;
    ui_tooltip = "Diagnostic center used by mid-coverage views. 0.5 means strongest response where the shaped mask is half-covered.";
> = 0.500;

uniform float black_wand_DO_MidCoverageWidth <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Mid Coverage Width";
    ui_type = "slider";
    ui_min = 0.050; ui_max = 1.000; ui_step = 0.001;
    ui_tooltip = "Width of the mid-coverage diagnostic window. Raise this to see more partial coverage.";
> = 0.650;

uniform float black_wand_DO_RMMidGain <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "RM Delta Gain";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 512.000; ui_step = 0.250;
    ui_tooltip = "Scales RM depth deltas before threshold/softness shaping. Lower this if RM views are solid red.";
> = 24.000;

uniform float black_wand_DO_RMMidThreshold <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "RM Delta Threshold";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 4.000; ui_step = 0.001;
> = 0.160;

uniform float black_wand_DO_RMMidSoftness <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "RM Delta Softness";
    ui_type = "slider";
    ui_min = 0.001; ui_max = 8.000; ui_step = 0.001;
> = 1.500;

uniform float black_wand_DO_OfficialBandWaveMix <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Official Band Wave Mix";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
    ui_tooltip = "Adds a continuous contour wave to depth bands so bands remain visible when thin line bands miss coverage.";
> = 0.850;

uniform float black_wand_DO_OfficialBandSharpness <
    ui_category = "Depth Oracle / Mid Coverage";
    ui_label = "Official Band Sharpness";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 8.000; ui_step = 0.001;
> = 1.500;


/* v0.9 luma fallback controls.
   Luma fallback is a surrogate diagnostic/occlusion-detail layer only. It does not
   replace official depth, does not create hidden geometry, and is only blended when
   explicitly selected or when depth confidence falls below the configured threshold. */
uniform int black_wand_DO_LumaFallbackMode <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Fallback Policy";
    ui_type = "combo";
    ui_items = "Off\0Depth Missing Only\0Blend By Depth Confidence\0Force Luma Fallback\0";
    ui_tooltip = "Controls when the luma surrogate branch participates. Official depth/normal remain the trusted path when available.";
> = BLACK_WAND_DO_LUMA_FALLBACK_OFF;

uniform float black_wand_DO_LumaRadius <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Sample Radius";
    ui_type = "drag";
    ui_min = 1.000; ui_max = 6.000; ui_step = 0.125;
> = 1.000;

uniform float black_wand_DO_LumaContrastGain <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Contrast Gain";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 128.000; ui_step = 0.250;
> = 16.000;

uniform float black_wand_DO_LumaToneGain <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Tone/Occlusion Gain";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 128.000; ui_step = 0.250;
> = 8.000;

uniform float black_wand_DO_LumaFallbackStrength <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Fallback Strength";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.650;

uniform bool black_wand_DO_LumaBrightIsNear <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Surrogate Bright Is Near";
    ui_tooltip = "When off, darker pixels produce nearer surrogate depth. This is diagnostic only.";
> = false;

uniform float black_wand_DO_LumaSurrogateGamma <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Surrogate Gamma";
    ui_type = "drag";
    ui_min = 0.100; ui_max = 5.000; ui_step = 0.001;
> = 1.000;

uniform float black_wand_DO_LumaSurrogateContrastMix <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Surrogate Contrast Mix";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.350;

uniform float black_wand_DO_DepthConfidenceThreshold <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Depth Confidence Threshold";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.350;

uniform float black_wand_DO_LumaActivationThreshold <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma Activation Threshold";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 1.000; ui_step = 0.001;
> = 0.080;

uniform float black_wand_DO_DepthActivityGain <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Depth Activity Gain";
    ui_type = "drag";
    ui_min = 1.000; ui_max = 2048.000; ui_step = 1.000;
> = 256.000;

uniform float black_wand_DO_LumaRMStepPixels <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma RM Step Pixels";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 8.000; ui_step = 0.125;
> = 1.000;

uniform float black_wand_DO_LumaRMGain <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma RM Delta Gain";
    ui_type = "drag";
    ui_min = 0.250; ui_max = 512.000; ui_step = 0.250;
> = 12.000;

uniform float black_wand_DO_LumaRMThreshold <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma RM Delta Threshold";
    ui_type = "slider";
    ui_min = 0.000; ui_max = 4.000; ui_step = 0.001;
> = 0.120;

uniform float black_wand_DO_LumaRMSoftness <
    ui_category = "Depth Oracle / Luma Fallback";
    ui_label = "Luma RM Delta Softness";
    ui_type = "slider";
    ui_min = 0.001; ui_max = 8.000; ui_step = 0.001;
> = 1.500;

float black_wand_DO_ManualBranch(float2 uv)
{
    float branchDepth = black_wand_DO_OfficialDepthAt(uv);
    if (black_wand_DO_ManualPreviewEnabled)
    {
        branchDepth = black_wand_DO_ManualDepthAt(
            uv,
            black_wand_DO_FlipVertical,
            black_wand_DO_UVScale,
            black_wand_DO_PixelOffset,
            black_wand_DO_ReverseDepth,
            black_wand_DO_LogDepth,
            black_wand_DO_DepthMultiplier,
            black_wand_DO_LogCurve,
            black_wand_DO_NearPlane,
            black_wand_DO_FarPlane);
    }
    return branchDepth;
}

float3 black_wand_DO_Render(float2 uv)
{
    float3 source = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    float3 result = black_wand_DO_SourceWarning(source, 0.35);

    float rawDepth = black_wand_DO_RawDepthAt(uv);
    float officialDepth = black_wand_DO_OfficialDepthAt(uv);
    float manualDepth = black_wand_DO_ManualBranch(uv);

    float3 rawDisplay = black_wand_DO_ShapeGray(rawDepth, black_wand_DO_DisplayBlackPoint, black_wand_DO_DisplayWhitePoint, black_wand_DO_DisplayGamma, black_wand_DO_DisplayContrast, black_wand_DO_DisplayExposure, black_wand_DO_DisplayInvert, black_wand_DO_LiftDarkDiagnostics, black_wand_DO_VisibilityFloor);
    float3 officialDisplay = black_wand_DO_ShapeGray(officialDepth, black_wand_DO_DisplayBlackPoint, black_wand_DO_DisplayWhitePoint, black_wand_DO_DisplayGamma, black_wand_DO_DisplayContrast, black_wand_DO_DisplayExposure, black_wand_DO_DisplayInvert, black_wand_DO_LiftDarkDiagnostics, black_wand_DO_VisibilityFloor);
    float3 manualDisplay = black_wand_DO_ShapeGray(manualDepth, black_wand_DO_DisplayBlackPoint, black_wand_DO_DisplayWhitePoint, black_wand_DO_DisplayGamma, black_wand_DO_DisplayContrast, black_wand_DO_DisplayExposure, black_wand_DO_DisplayInvert, black_wand_DO_LiftDarkDiagnostics, black_wand_DO_VisibilityFloor);

    if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_SOURCE)
        result = source;
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_UV)
        result = black_wand_DO_UVGradient(uv);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_CHECKER)
        result = black_wand_DO_Checker(uv);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_RAW)
        result = rawDisplay;
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL)
        result = officialDisplay;
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_MANUAL)
        result = manualDisplay;
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_COMPARE)
        result = black_wand_DO_OracleCompare(rawDepth, manualDepth, officialDepth, black_wand_DO_CompareScale);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_NORMAL_OFFICIAL)
        result = black_wand_DO_OfficialNormal(uv, black_wand_DO_NormalRadius);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_NORMAL_MANUAL)
        result = black_wand_DO_ManualNormal(uv, black_wand_DO_NormalRadius, black_wand_DO_FlipVertical, black_wand_DO_UVScale, black_wand_DO_PixelOffset, black_wand_DO_ReverseDepth, black_wand_DO_LogDepth, black_wand_DO_DepthMultiplier, black_wand_DO_LogCurve, black_wand_DO_NearPlane, black_wand_DO_FarPlane);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_PRESENCE_BARS)
        result = black_wand_DO_Bars(uv, black_wand_DO_DepthPresence(uv, black_wand_DO_EndpointMargin));
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_ENDPOINT_MASK)
        result = black_wand_DO_InteriorDepth(rawDepth, black_wand_DO_EndpointMargin).xxx;
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_DIFF_HEAT)
        result = black_wand_DO_Heat(abs(manualDepth - officialDepth) * black_wand_DO_CompareScale);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_RM_HORIZONTAL)
        result = black_wand_DO_RMProbeOfficial(uv, float2(black_wand_DO_RMProbeStepPixels, 0.0), black_wand_DO_RMDepthTolerance);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_RM_VERTICAL)
        result = black_wand_DO_RMProbeOfficial(uv, float2(0.0, black_wand_DO_RMProbeStepPixels), black_wand_DO_RMDepthTolerance);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_SPLIT_NORMAL_DEPTH)
        result = black_wand_DO_Split(uv, black_wand_DO_OfficialNormal(uv, black_wand_DO_NormalRadius), officialDisplay);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OVERLAY_OFFICIAL)
        result = black_wand_DO_Overlay(source, officialDisplay, black_wand_DO_OverlayStrength);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_FOCUSED)
        result = black_wand_DO_OfficialDepthFocused(officialDepth, black_wand_DO_OfficialFocusStrength, black_wand_DO_DisplayBlackPoint, black_wand_DO_DisplayWhitePoint, black_wand_DO_DisplayGamma, black_wand_DO_DisplayContrast, black_wand_DO_DisplayExposure, black_wand_DO_DisplayInvert, black_wand_DO_LiftDarkDiagnostics, black_wand_DO_VisibilityFloor);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_DETAIL)
        result = black_wand_DO_OfficialDepthDetail(uv, black_wand_DO_OfficialDetailRadius, black_wand_DO_OfficialEdgeTolerance);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_BANDS)
        result = black_wand_DO_OfficialDepthBands(officialDepth, black_wand_DO_OfficialBandCount, black_wand_DO_OfficialBandLineWidth, black_wand_DO_OfficialFocusStrength, black_wand_DO_OfficialBandWaveMix, black_wand_DO_OfficialBandSharpness);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_EDGE_CONFIDENCE)
        result = black_wand_DO_OfficialEdgeConfidenceShaped(uv, black_wand_DO_OfficialDetailRadius, black_wand_DO_OfficialEdgeGain, black_wand_DO_OfficialEdgeThreshold, black_wand_DO_OfficialEdgeSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_NORMAL_RELIEF)
        result = black_wand_DO_OfficialNormalRelief(source, uv, black_wand_DO_NormalRadius, black_wand_DO_OfficialFocusStrength, black_wand_DO_NormalReliefStrength);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_RM_CONTINUITY_OVERLAY)
        result = black_wand_DO_Overlay(source, black_wand_DO_RMProbeOfficialShaped(uv, float2(black_wand_DO_RMProbeStepPixels, 0.0), black_wand_DO_RMMidGain, black_wand_DO_RMMidThreshold, black_wand_DO_RMMidSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth), black_wand_DO_OverlayStrength);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_EDGE_MID_COVERAGE)
        result = black_wand_DO_OfficialEdgeMidCoverage(uv, black_wand_DO_OfficialDetailRadius, black_wand_DO_OfficialEdgeGain, black_wand_DO_OfficialEdgeThreshold, black_wand_DO_OfficialEdgeSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_RM_MID_COVERAGE_HORIZONTAL)
        result = black_wand_DO_RMProbeOfficialShaped(uv, float2(black_wand_DO_RMProbeStepPixels, 0.0), black_wand_DO_RMMidGain, black_wand_DO_RMMidThreshold, black_wand_DO_RMMidSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_RM_MID_COVERAGE_VERTICAL)
        result = black_wand_DO_RMProbeOfficialShaped(uv, float2(0.0, black_wand_DO_RMProbeStepPixels), black_wand_DO_RMMidGain, black_wand_DO_RMMidThreshold, black_wand_DO_RMMidSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_LOCAL_CONTRAST)
        result = black_wand_DO_LumaLocalContrastView(uv, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_SURROGATE_DEPTH)
        result = black_wand_DO_LumaSurrogateDepthView(uv, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain, black_wand_DO_LumaBrightIsNear, black_wand_DO_LumaSurrogateGamma, black_wand_DO_LumaSurrogateContrastMix, black_wand_DO_DisplayBlackPoint, black_wand_DO_DisplayWhitePoint, black_wand_DO_DisplayGamma, black_wand_DO_DisplayContrast, black_wand_DO_DisplayExposure, black_wand_DO_DisplayInvert, black_wand_DO_LiftDarkDiagnostics, black_wand_DO_VisibilityFloor);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_FALLBACK_AO_RAW)
        result = black_wand_DO_LumaFallbackAORaw(uv, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain, black_wand_DO_LumaToneGain).xxx;
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_FALLBACK_ACTIVE)
        result = black_wand_DO_LumaFallbackActiveView(uv, black_wand_DO_LumaFallbackMode, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain, black_wand_DO_LumaToneGain, black_wand_DO_EndpointMargin, black_wand_DO_DepthActivityGain, black_wand_DO_DepthConfidenceThreshold, black_wand_DO_LumaActivationThreshold);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_OFFICIAL_LUMA_HYBRID_CONFIDENCE)
        result = black_wand_DO_OfficialLumaHybridConfidenceView(uv, black_wand_DO_LumaFallbackMode, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain, black_wand_DO_LumaToneGain, black_wand_DO_EndpointMargin, black_wand_DO_DepthActivityGain, black_wand_DO_DepthConfidenceThreshold, black_wand_DO_LumaActivationThreshold);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_DEPTH_MISSING_POLICY)
        result = black_wand_DO_DepthMissingPolicyBars(uv, black_wand_DO_LumaFallbackMode, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain, black_wand_DO_LumaToneGain, black_wand_DO_EndpointMargin, black_wand_DO_DepthActivityGain, black_wand_DO_DepthConfidenceThreshold, black_wand_DO_LumaActivationThreshold);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_FALLBACK_OVERLAY)
        result = black_wand_DO_LumaFallbackOverlay(source, uv, black_wand_DO_LumaFallbackMode, black_wand_DO_LumaRadius, black_wand_DO_LumaContrastGain, black_wand_DO_LumaToneGain, black_wand_DO_LumaFallbackStrength, black_wand_DO_EndpointMargin, black_wand_DO_DepthActivityGain, black_wand_DO_DepthConfidenceThreshold, black_wand_DO_LumaActivationThreshold);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_RM_SUPPORT_HORIZONTAL)
        result = black_wand_DO_LumaRMSupportView(uv, float2(black_wand_DO_LumaRMStepPixels, 0.0), black_wand_DO_LumaRMGain, black_wand_DO_LumaRMThreshold, black_wand_DO_LumaRMSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth);
    else if (black_wand_DO_ViewMode == BLACK_WAND_DO_VIEW_LUMA_RM_SUPPORT_VERTICAL)
        result = black_wand_DO_LumaRMSupportView(uv, float2(0.0, black_wand_DO_LumaRMStepPixels), black_wand_DO_LumaRMGain, black_wand_DO_LumaRMThreshold, black_wand_DO_LumaRMSoftness, black_wand_DO_MidCoverageCenter, black_wand_DO_MidCoverageWidth);

    return saturate(result);
}

void black_wand_DO_PS(float4 pos : SV_Position, float2 uv : TEXCOORD, out float4 color : SV_Target)
{
    color = float4(black_wand_DO_Render(uv), 1.0);
}

technique black_wand_DepthOracle
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_DO_PS;
    }
}

