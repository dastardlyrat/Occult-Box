// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: RC-4
// Capability: Standalone hatch server for previewing hatch families, tonal masks, and depth-driven placement.

#include "ReShade.fxh"

#define HEXING_EYE_CAT_DEBUG "hexing eye / 00 Debug"
#define HEXING_EYE_CAT_MAIN "hexing eye / 01 Main Settings"
#define HEXING_EYE_CAT_SUB_PATTERN "hexing eye / 02 Sub Main Settings / Pattern"
#define HEXING_EYE_CAT_SUB_BANDS "hexing eye / 02 Sub Main Settings / Bands"
#define HEXING_EYE_CAT_SUB_MASKS "hexing eye / 02 Sub Main Settings / Masks"
#define HEXING_EYE_CAT_SUB_DETAIL "hexing eye / 02 Sub Main Settings / Detail"

uniform float HEXING_EYE_Time <
    source = "timer";
> = 0.0;

uniform int HEXING_EYE_DebugView <
    ui_type = "combo";
    ui_label = "Debug View";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final (Passthrough)\0Hatch Pattern\0Luma Bands\0Edge Mask\0Depth Edge\0Far Depth\0Depth Reject\0Radius Ring\0Detail Probe\0Hatch Bands\0Selected Mask\0Application Mask\0Final Mask\0Linear Depth\0Depth Availability\0";
    ui_tooltip = "Chooses which hatch, mask, or depth diagnostic to display. Use the mask and depth views to verify where the effect is allowed to appear before judging the final shaded image.";
> = 0;

uniform float HEXING_EYE_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens dim diagnostic views so weak masks, subtle depth changes, and low-coverage hatch regions are easier to inspect. Does not change final shading.";
> = 1.0;

uniform float HEXING_EYE_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.70;

uniform float HEXING_EYE_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float HEXING_EYE_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float HEXING_EYE_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int HEXING_EYE_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = HEXING_EYE_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float HEXING_EYE_DebugShape(float value)
{
    float debugLow = min(HEXING_EYE_DebugBlackPoint, HEXING_EYE_DebugWhitePoint - 0.0001);
    float debugHigh = max(HEXING_EYE_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, HEXING_EYE_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, HEXING_EYE_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, HEXING_EYE_DebugGamma));
    if (HEXING_EYE_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 HEXING_EYE_DebugShape3(float3 value)
{
    return float3(HEXING_EYE_DebugShape(value.r), HEXING_EYE_DebugShape(value.g), HEXING_EYE_DebugShape(value.b));
}


uniform int HEXING_EYE_HatchMode <
    ui_type = "combo";
    ui_label = "Hatch Style";
    ui_category = HEXING_EYE_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Diagonal Hatch A\0Diagonal Hatch B\0Cross Hatch\0Thin Diagonal Hatch\0Sparse Hatch\0Organic Sketch\0Edge Ink\0Technical Drawing\0Far Detail Hatch\0Animated Hatch\0Orchestrator Hatch\0Five-Stage Small\0Five-Stage Med-Small\0Five-Stage Very-Small\0Five-Stage Blended\0Five-Stage Near\0Five-Stage Forward\0Five-Stage Center\0Five-Stage Back\0Five-Stage Far\0Fibonacci Bio Hatch\0Procedural Bio Hatch\0Centered Fibonacci Hatch\0Log Spiral Hatch\0Log Spiral Cross Hatch\0";
    ui_tooltip = "Selects the hatch generator used by the effect. The five-stage families emphasize depth staging, while the log-spiral families create more organic, branch-driven stroke flow.";
> = 3;

uniform int HEXING_EYE_ApplicationMask <
    ui_type = "combo";
    ui_label = "Application Mask";
    ui_category = HEXING_EYE_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Luma Bands\0Edge Mask\0Depth Edge\0Far Depth\0Depth Reject\0Radius Ring\0Golden21 Detail\0Hatch Bands\0";
    ui_tooltip = "Selects the placement mask that decides where hatching is allowed. Use this to confine the effect to dark tones, edges, far depth, detail zones, or stepped hatch bands.";
> = 1;

uniform float HEXING_EYE_HatchStrength <
    ui_type = "slider";
    ui_label = "Hatch Strength";
    ui_category = HEXING_EYE_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Controls how strongly the final hatch darkens the source image. Higher values make the selected hatch family read more aggressively.";
> = 0.72;

uniform float HEXING_EYE_HatchSpacing <
    ui_type = "slider";
    ui_label = "Hatch Spacing";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 6.0; ui_max = 96.0; ui_step = 0.1;
    ui_tooltip = "Controls line spacing for the analytic hatch families. Lower values pack lines tightly for denser shading; higher values open the pattern and make strokes more separated.";
> = 8.0;

uniform float HEXING_EYE_HatchThickness <
    ui_type = "slider";
    ui_label = "Hatch Thickness";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.02; ui_max = 0.95; ui_step = 0.001;
    ui_tooltip = "Controls how thick each hatch stroke appears within its spacing interval. Higher values make the pattern feel bolder and darker.";
> = 0.22;

uniform float HEXING_EYE_HatchContrast <
    ui_type = "slider";
    ui_label = "Hatch Contrast";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.1; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Sharpens or softens how decisively hatch lines appear. Higher values create crisper, more binary strokes; lower values keep the pattern gentler.";
> = 1.25;

uniform float HEXING_EYE_AdvancedPatternScale <
    ui_type = "slider";
    ui_label = "Advanced Pattern Scale";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 40.0; ui_max = 1600.0; ui_step = 0.1;
    ui_tooltip = "Sets the spatial frequency for the synthesized multi-stage and Fibonacci hatch families. Higher values make those patterns finer and more tightly packed across the image.";
> = 860.0;

uniform float HEXING_EYE_HatchAngleA <
    ui_type = "slider";
    ui_label = "Hatch Angle A";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Primary hatch angle for analytic line families. Rotating it changes the dominant stroke direction across the image.";
> = 35.0;

uniform float HEXING_EYE_HatchAngleB <
    ui_type = "slider";
    ui_label = "Hatch Angle B";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Secondary hatch angle used by cross and layered analytic families. It changes how opposing or supporting stroke sets intersect.";
> = -35.0;

uniform float HEXING_EYE_HatchAngleC <
    ui_type = "slider";
    ui_label = "Hatch Angle C";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Tertiary hatch angle used by layered and scribble-like variants. It helps control the character of denser dark-region shading.";
> = 90.0;

uniform float HEXING_EYE_Jitter <
    ui_type = "slider";
    ui_label = "Noise Jitter";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.0; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Adds positional wobble to the analytic hatch field. Higher values break up uniform lines and make the pattern feel more hand-drawn.";
> = 1.1;

uniform float HEXING_EYE_AnimationSpeed <
    ui_type = "slider";
    ui_label = "Animation Speed";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Controls how quickly the Animated Hatch pattern moves over time. Higher values increase visible motion and can introduce shimmer if pushed too far.";
> = 0.18;

uniform int HEXING_EYE_FibonacciTapCount <
    ui_type = "slider";
    ui_label = "Fibonacci Tap Count";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 1; ui_max = 89; ui_step = 1;
    ui_tooltip = "Sets how many directional taps contribute to the Fibonacci-driven hatch families. Higher values add complexity and coverage to those synthesized patterns.";
> = 55;

uniform int HEXING_EYE_FibonacciReductionMode <
    ui_type = "combo";
    ui_label = "Fibonacci Reduction";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_items = "Staggered\0Sequential\0";
    ui_tooltip = "Controls how reduced Fibonacci tap counts are chosen. Staggered spreads taps across the full 89-tap field, while Sequential fills from the earliest taps first.";
> = 0;

uniform float HEXING_EYE_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 987.0; ui_max = 4808.0; ui_step = 1.0;
    ui_tooltip = "Shifts the directional phase of Fibonacci-driven hatch families. Changing it can noticeably alter flow, clustering feel, and local line orientation without changing tap count.";
> = 2584.0;

uniform float HEXING_EYE_FibonacciFlow <
    ui_type = "slider";
    ui_label = "Fibonacci Flow";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6.0; ui_step = 0.001;
    ui_tooltip = "Offsets the phase used by the bio and Fibonacci-derived hatch families. Use it to move the pattern into a different stable arrangement.";
> = 1.50;

uniform float HEXING_EYE_FibonacciDensity <
    ui_type = "slider";
    ui_label = "Fibonacci Density";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.1; ui_max = 3.5; ui_step = 0.001;
    ui_tooltip = "Controls how many strokes the synthesized Fibonacci families draw within their pattern space. Higher values create finer, busier hatch fields.";
> = 2.05;

uniform float HEXING_EYE_FibonacciTapSpread <
    ui_type = "slider";
    ui_label = "Fibonacci Tap Spread";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 8.0; ui_max = 180.0; ui_step = 0.01;
    ui_tooltip = "Controls how far the synthesized Fibonacci taps are spread through pattern space. Higher values increase variation across the hatch field and reduce uniform repetition.";
> = 96.0;

uniform float HEXING_EYE_FiveStageBlendWidth <
    ui_type = "slider";
    ui_label = "Five-Stage Blend Width";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.05; ui_max = 0.60; ui_step = 0.001;
    ui_tooltip = "Controls how broadly the five-stage depth bands overlap when using the blended or isolated five-stage families. Higher values make transitions between near, forward, center, back, and far feel smoother.";
> = 0.30;

uniform float HEXING_EYE_SpiralGrowth <
    ui_type = "slider";
    ui_label = "Spiral Growth";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 1.02; ui_max = 1.70; ui_step = 0.001;
    ui_tooltip = "Controls how quickly each recursive log-spiral branch expands outward. Higher values spread branches apart faster and create a more open spiral field.";
> = 1.18;

uniform float HEXING_EYE_SpiralTightness <
    ui_type = "slider";
    ui_label = "Spiral Tightness";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.00; ui_step = 0.001;
    ui_tooltip = "Controls how tightly the log-spiral branches wind around their centers. Higher values create more angular turn and denser spiral wrapping.";
> = 1.05;

uniform int HEXING_EYE_SpiralBranchCount <
    ui_type = "slider";
    ui_label = "Spiral Branch Count";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 2; ui_max = 8; ui_step = 1;
    ui_tooltip = "Sets how many branch arms the log-spiral hatch field uses. Higher values produce a richer, more distributed branch network.";
> = 5;

uniform int HEXING_EYE_SpiralRecursiveLevels <
    ui_type = "slider";
    ui_label = "Spiral Recursive Levels";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 1; ui_max = 4; ui_step = 1;
    ui_tooltip = "Controls how many recursive levels contribute to the log-spiral direction field. More levels add structure but can make the branch field busier.";
> = 3;

uniform float HEXING_EYE_SpiralBranchBlend <
    ui_type = "slider";
    ui_label = "Spiral Branch Blend";
    ui_category = HEXING_EYE_CAT_SUB_PATTERN; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between the local Fibonacci lens direction and the recursive branch direction. Lower values keep the hatch more lens-led; higher values make the spiral field dominate.";
> = 0.70;

uniform float HEXING_EYE_LumaThresholdA <
    ui_type = "slider";
    ui_label = "Luma Threshold A";
    ui_category = HEXING_EYE_CAT_SUB_BANDS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Upper threshold where darkening begins to unlock more hatch coverage. Raising it allows hatching to start earlier in brighter midtones.";
> = 0.72;

uniform float HEXING_EYE_LumaThresholdB <
    ui_type = "slider";
    ui_label = "Luma Threshold B";
    ui_category = HEXING_EYE_CAT_SUB_BANDS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Middle threshold where additional layers start appearing. It controls when medium-dark regions become more densely hatched.";
> = 0.48;

uniform float HEXING_EYE_LumaThresholdC <
    ui_type = "slider";
    ui_label = "Luma Threshold C";
    ui_category = HEXING_EYE_CAT_SUB_BANDS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Lowest threshold for the darkest regions. It determines when the deepest tones receive the fullest hatch layering.";
> = 0.24;

uniform float HEXING_EYE_EdgeThreshold <
    ui_type = "slider";
    ui_label = "Edge Threshold";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.001;
    ui_tooltip = "Sets how much local luminance contrast is required before color-edge masking activates. Lower values catch more outlines and texture transitions.";
> = 0.028;

uniform float HEXING_EYE_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.0005; ui_max = 0.10; ui_step = 0.0005;
    ui_tooltip = "Sets how much depth discontinuity is required before depth-edge masking activates. Lower values pick up finer depth seams and object boundaries.";
> = 0.010;

uniform int HEXING_EYE_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Flips near and far depth interpretation. Enable it when near objects appear dark in depth views and distant objects appear bright.";
> = 0;

uniform int HEXING_EYE_DepthLinearizationMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_items = "ReShade Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Chooses how the shader reads depth before building depth-driven masks. Use Raw or Raw Inverted when ReShade linearized depth looks flat or incorrect in your game.";
> = 0;

uniform float HEXING_EYE_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies small depth differences before edge and reject tests. Raise it when depth-based masks look flat or fail to separate foreground from background.";
> = 512.0;

uniform float HEXING_EYE_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Availability Threshold";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.10000; ui_step = 0.00001;
    ui_tooltip = "Sets the minimum local depth activity required before the shader trusts depth. Lower values accept weaker depth signals; higher values reject noisy or nearly flat depth.";
> = 0.00250;

uniform float HEXING_EYE_FarDepthStart <
    ui_type = "slider";
    ui_label = "Far Depth Start";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where the far-depth mask begins. Lower values let distant shading start closer to the camera; higher values reserve it for the far background.";
> = 0.58;

uniform float HEXING_EYE_FarDepthFeather <
    ui_type = "slider";
    ui_label = "Far Depth Feather";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.5; ui_step = 0.001;
    ui_tooltip = "Controls how gradually the far-depth mask fades in. Higher values create a broader transition from unmasked to fully masked.";
> = 0.20;

uniform float HEXING_EYE_DepthRejectRadius <
    ui_type = "slider";
    ui_label = "Depth Reject Radius";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Controls how far the shader looks around each pixel when checking for depth disagreement. Higher values make depth rejection respond to broader local structure.";
> = 1.5;

uniform float HEXING_EYE_DepthRejectThreshold <
    ui_type = "slider";
    ui_label = "Depth Reject Threshold";
    ui_category = HEXING_EYE_CAT_SUB_MASKS; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.10; ui_step = 0.001;
    ui_tooltip = "Sets how much depth mismatch is tolerated before the depth-reject mask turns off. Lower values make the mask stricter around silhouettes and intersections.";
> = 0.018;

uniform float HEXING_EYE_RadiusRing <
    ui_type = "slider";
    ui_label = "Radius Ring";
    ui_category = HEXING_EYE_CAT_SUB_DETAIL; ui_category_closed = true;
    ui_min = 0.05; ui_max = 0.70; ui_step = 0.001;
    ui_tooltip = "Sets the radius of the circular debug mask. Useful for checking where a radial placement mask will appear on screen.";
> = 0.28;

uniform float HEXING_EYE_RadiusRingThickness <
    ui_type = "slider";
    ui_label = "Ring Thickness";
    ui_category = HEXING_EYE_CAT_SUB_DETAIL; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.12; ui_step = 0.001;
    ui_tooltip = "Controls how narrow or broad the ring mask appears. Higher values make the ring easier to read but less precise.";
> = 0.020;

uniform float HEXING_EYE_DetailRadiusPixels <
    ui_type = "slider";
    ui_label = "Detail Radius";
    ui_category = HEXING_EYE_CAT_SUB_DETAIL; ui_category_closed = true;
    ui_min = 0.25; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Controls how far the detail probe samples around each pixel. Higher values make the probe respond to larger surrounding features instead of only fine detail.";
> = 1.6;

uniform float HEXING_EYE_DetailGain <
    ui_type = "slider";
    ui_label = "Detail Gain";
    ui_category = HEXING_EYE_CAT_SUB_DETAIL; ui_category_closed = true;
    ui_min = 0.1; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Scales the strength of the Golden21 detail mask. Higher values make detail-driven placement appear more aggressively.";
> = 2.2;

#include "../header/hexing_eye.fxh"

float HEXING_EYE_DebugScalar(float value)
{
    return HEXING_EYE_DebugShape(value);
}

float3 HEXING_EYE_BandColor(float value)
{
    return saturate(float3(value, value * 0.82, 1.0 - value * 0.35));
}

float HEXING_EYE_EvaluateHatch(float2 uv, float3 sourceColor)
{
    float depth = HEXING_EYE_LinearDepth(uv);
    float luma = HEXING_EYE_Luma(sourceColor);
    float phase = HEXING_EYE_Time * HEXING_EYE_AnimationSpeed;

    return HEXING_EYE_HatchPattern(
        HEXING_EYE_HatchMode,
        uv,
        depth,
        luma,
        HEXING_EYE_HatchSpacing,
        HEXING_EYE_HatchThickness,
        HEXING_EYE_HatchContrast,
        HEXING_EYE_AdvancedPatternScale,
        HEXING_EYE_HatchAngleA,
        HEXING_EYE_HatchAngleB,
        HEXING_EYE_HatchAngleC,
        phase,
        HEXING_EYE_Jitter,
        HEXING_EYE_FibonacciAnchor,
        HEXING_EYE_FibonacciFlow,
        HEXING_EYE_FibonacciDensity,
        HEXING_EYE_FibonacciTapSpread,
        HEXING_EYE_FibonacciTapCount,
        HEXING_EYE_FibonacciReductionMode,
        HEXING_EYE_FiveStageBlendWidth,
        HEXING_EYE_SpiralGrowth,
        HEXING_EYE_SpiralTightness,
        HEXING_EYE_SpiralBranchCount,
        HEXING_EYE_SpiralRecursiveLevels,
        HEXING_EYE_SpiralBranchBlend,
        HEXING_EYE_LumaThresholdA,
        HEXING_EYE_LumaThresholdB,
        HEXING_EYE_LumaThresholdC);
}

float HEXING_EYE_SelectMask(float2 uv, float3 sourceColor)
{
    float result = 1.0;

    if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_OFF)
    {
        result = 1.0;
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_LUMA_BANDS)
    {
        result = HEXING_EYE_LumaBandMask(HEXING_EYE_Luma(sourceColor), HEXING_EYE_LumaThresholdA, HEXING_EYE_LumaThresholdC);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_EDGE)
    {
        result = HEXING_EYE_EdgeMask(uv, sourceColor, HEXING_EYE_EdgeThreshold);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_DEPTH_EDGE)
    {
        result = HEXING_EYE_DepthEdgeMask(uv, HEXING_EYE_DepthEdgeThreshold);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_FAR_DEPTH)
    {
        result = HEXING_EYE_FarDepthMask(HEXING_EYE_LinearDepth(uv), HEXING_EYE_FarDepthStart, HEXING_EYE_FarDepthFeather);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_DEPTH_REJECT)
    {
        result = HEXING_EYE_DepthRejectMask(uv, HEXING_EYE_DepthRejectRadius, HEXING_EYE_DepthRejectThreshold);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_RADIUS_RING)
    {
        result = HEXING_EYE_RadiusRingMask(uv, HEXING_EYE_RadiusRing, HEXING_EYE_RadiusRingThickness);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_GOLDEN21_DETAIL)
    {
        result = saturate(HEXING_EYE_Golden21Detail(uv, HEXING_EYE_DetailRadiusPixels) * HEXING_EYE_DetailGain);
    }
    else if (HEXING_EYE_ApplicationMask == HEXING_EYE_MASK_HATCH_BANDS)
    {
        result = HEXING_EYE_HatchBandCount(HEXING_EYE_Luma(sourceColor), HEXING_EYE_LumaThresholdA, HEXING_EYE_LumaThresholdB, HEXING_EYE_LumaThresholdC);
    }

    return saturate(result);
}

float HEXING_EYE_StyleMask(float2 uv, float3 sourceColor)
{
    float result = 1.0;

    if (HEXING_EYE_HatchMode == HEXING_EYE_HATCH_EDGE_INK)
    {
        result = HEXING_EYE_EdgeMask(uv, sourceColor, HEXING_EYE_EdgeThreshold);
    }
    else if (HEXING_EYE_HatchMode == HEXING_EYE_HATCH_TECHNICAL)
    {
        result = HEXING_EYE_DepthEdgeMask(uv, HEXING_EYE_DepthEdgeThreshold);
    }
    else if (HEXING_EYE_HatchMode == HEXING_EYE_HATCH_FAR_DETAIL)
    {
        float farDepth = HEXING_EYE_FarDepthMask(HEXING_EYE_LinearDepth(uv), HEXING_EYE_FarDepthStart, HEXING_EYE_FarDepthFeather);
        float detailProbe = saturate(HEXING_EYE_Golden21Detail(uv, HEXING_EYE_DetailRadiusPixels) * HEXING_EYE_DetailGain);
        result = farDepth * detailProbe;
    }

    return result;
}

float HEXING_EYE_ApplicationMaskValue(float2 uv, float3 sourceColor)
{
    float styleMask = HEXING_EYE_StyleMask(uv, sourceColor);
    float result = styleMask;

    if (HEXING_EYE_ApplicationMask != HEXING_EYE_MASK_OFF)
    {
        result = saturate(HEXING_EYE_SelectMask(uv, sourceColor) * styleMask);
    }

    return saturate(result);
}

float4 HEXING_EYE_MainPS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;

    if (HEXING_EYE_DebugView == 1)
    {
        return float4(HEXING_EYE_DebugScalar(HEXING_EYE_EvaluateHatch(uv, sourceColor)).xxx, 1.0);
    }
    if (HEXING_EYE_DebugView == 2)
    {
        float luma = HEXING_EYE_Luma(sourceColor);
        return float4(HEXING_EYE_BandColor(HEXING_EYE_LumaBandMask(luma, HEXING_EYE_LumaThresholdA, HEXING_EYE_LumaThresholdC)), 1.0);
    }
    if (HEXING_EYE_DebugView == 3)
    {
        return float4(HEXING_EYE_DebugScalar(HEXING_EYE_EdgeMask(uv, sourceColor, HEXING_EYE_EdgeThreshold)).xxx, 1.0);
    }
    if (HEXING_EYE_DebugView == 4)
    {
        float depthEdge = HEXING_EYE_DepthEdgeMask(uv, HEXING_EYE_DepthEdgeThreshold);
        return float4(float3(HEXING_EYE_DebugScalar(depthEdge), HEXING_EYE_DebugScalar(depthEdge) * 0.85, 1.0), 1.0);
    }
    if (HEXING_EYE_DebugView == 5)
    {
        float farDepth = HEXING_EYE_FarDepthMask(HEXING_EYE_LinearDepth(uv), HEXING_EYE_FarDepthStart, HEXING_EYE_FarDepthFeather);
        return float4(float3(HEXING_EYE_DebugScalar(farDepth) * 0.4, HEXING_EYE_DebugScalar(farDepth) * 0.8, HEXING_EYE_DebugScalar(farDepth)), 1.0);
    }
    if (HEXING_EYE_DebugView == 6)
    {
        float depthReject = HEXING_EYE_DepthRejectMask(uv, HEXING_EYE_DepthRejectRadius, HEXING_EYE_DepthRejectThreshold);
        return float4(float3(HEXING_EYE_DebugScalar(depthReject), 0.15, 1.0 - HEXING_EYE_DebugScalar(depthReject) * 0.5), 1.0);
    }
    if (HEXING_EYE_DebugView == 7)
    {
        float radiusRing = HEXING_EYE_RadiusRingMask(uv, HEXING_EYE_RadiusRing, HEXING_EYE_RadiusRingThickness);
        return float4(float3(HEXING_EYE_DebugScalar(radiusRing), HEXING_EYE_DebugScalar(radiusRing) * 0.8, 0.25), 1.0);
    }
    if (HEXING_EYE_DebugView == 8)
    {
        float detailProbe = saturate(HEXING_EYE_Golden21Detail(uv, HEXING_EYE_DetailRadiusPixels) * HEXING_EYE_DetailGain);
        return float4(float3(HEXING_EYE_DebugScalar(detailProbe), HEXING_EYE_DebugScalar(detailProbe) * 0.75, 1.0), 1.0);
    }
    if (HEXING_EYE_DebugView == 9)
    {
        float luma = HEXING_EYE_Luma(sourceColor);
        return float4(HEXING_EYE_BandColor(HEXING_EYE_HatchBandCount(luma, HEXING_EYE_LumaThresholdA, HEXING_EYE_LumaThresholdB, HEXING_EYE_LumaThresholdC)), 1.0);
    }
    if (HEXING_EYE_DebugView == 10)
    {
        return float4(HEXING_EYE_DebugScalar(HEXING_EYE_SelectMask(uv, sourceColor)).xxx, 1.0);
    }
    if (HEXING_EYE_DebugView == 11)
    {
        return float4(HEXING_EYE_DebugScalar(HEXING_EYE_ApplicationMaskValue(uv, sourceColor)).xxx, 1.0);
    }
    if (HEXING_EYE_DebugView == 12)
    {
        float hatch = HEXING_EYE_EvaluateHatch(uv, sourceColor);
        float applicationMask = HEXING_EYE_ApplicationMaskValue(uv, sourceColor);
        return float4(HEXING_EYE_DebugScalar(saturate(hatch * applicationMask)).xxx, 1.0);
    }
    if (HEXING_EYE_DebugView == 13)
    {
        float depth = HEXING_EYE_LinearDepth(uv);
        float shapedDepth = saturate(1.0 - exp(-depth * max(1.0, HEXING_EYE_DepthTraceScale)));
        float shownDepth = HEXING_EYE_DebugShape(shapedDepth);
        return float4(float3(shownDepth, HEXING_EYE_DebugShape(pow(abs(max(shapedDepth, 0.0)), 0.75)), 1.0 - shownDepth * 0.65), 1.0);
    }
    if (HEXING_EYE_DebugView == 14)
    {
        float rawDepth = HEXING_EYE_RawDepth(uv);
        float depthAvailability = HEXING_EYE_DepthAvailability(uv);
        return float4(float3(HEXING_EYE_DebugShape(depthAvailability), HEXING_EYE_DebugShape(rawDepth), HEXING_EYE_DebugShape(depthAvailability)), 1.0);
    }

    float hatch = HEXING_EYE_EvaluateHatch(uv, sourceColor);
    float applicationMask = HEXING_EYE_ApplicationMaskValue(uv, sourceColor);
    float finalMask = saturate(hatch * applicationMask);
    float3 hatchedColor = sourceColor * (1.0 - finalMask * HEXING_EYE_HatchStrength);
    return float4(hatchedColor, 1.0);
}

technique hexing_eye < ui_label = "hexing eye :: standalone hatch server"; ui_tooltip = "Standalone hatch host for inspecting hatch families, tonal masks, edge masks, and depth-driven placement before using the final shaded result."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = HEXING_EYE_MainPS;
    }
}

