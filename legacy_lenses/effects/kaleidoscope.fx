// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: RC-4
// Capability: Standalone mask server for previewing modular color, depth, spatial, and hatch-like masks.

#include "ReShade.fxh"

#define KALEIDOSCOPE_CAT_DEBUG "Kaleidoscope / 00 Debug"
#define KALEIDOSCOPE_CAT_MAIN "Kaleidoscope / 01 Main Settings"
#define KALEIDOSCOPE_CAT_SUB_COLOR "Kaleidoscope / 02 Field Controls / Color"
#define KALEIDOSCOPE_CAT_SUB_DEPTH "Kaleidoscope / 02 Field Controls / Depth"
#define KALEIDOSCOPE_CAT_SUB_SPATIAL "Kaleidoscope / 02 Field Controls / Spatial"
#define KALEIDOSCOPE_CAT_SUB_HATCH "Kaleidoscope / 02 Field Controls / Hatch"
#define KALEIDOSCOPE_CAT_SUB_PROTECTION "Kaleidoscope / 02 Field Controls / Protection"

uniform int KALEIDOSCOPE_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final (Passthrough)\0Sample Mask\0Final Mask\0Combined Mask\0Weighted Mask\0Masked Scene\0Linear Depth\0Depth Availability\0Local Contrast\0Saturation\0Hue\0Ring Contrast\0Spiral Detail\0Box Variance\0Directional\0Hatch Diagonal\0Cross Hatch\0Hatch Bands\0Line Guard\0Pixel Guard\0Highlight Protect\0Silhouette Protect\0Stable Surface\0";
    ui_tooltip = "Chooses which mask or diagnostic to show. Use Sample Mask and Final Mask to inspect the independent stages, then Combined Mask and Masked Scene to see the result after combination.";
> = 0;

uniform float KALEIDOSCOPE_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens dim debug views so weak masks, subtle depth changes, and low-contrast diagnostics are easier to read. It does not change the actual mask math.";
> = 1.0;

uniform float KALEIDOSCOPE_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.70;

uniform float KALEIDOSCOPE_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float KALEIDOSCOPE_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float KALEIDOSCOPE_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int KALEIDOSCOPE_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = KALEIDOSCOPE_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float KALEIDOSCOPE_DebugShape(float value)
{
    float debugLow = min(KALEIDOSCOPE_DebugBlackPoint, KALEIDOSCOPE_DebugWhitePoint - 0.0001);
    float debugHigh = max(KALEIDOSCOPE_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, KALEIDOSCOPE_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, KALEIDOSCOPE_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, KALEIDOSCOPE_DebugGamma));
    if (KALEIDOSCOPE_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 KALEIDOSCOPE_DebugShape3(float3 value)
{
    return float3(KALEIDOSCOPE_DebugShape(value.r), KALEIDOSCOPE_DebugShape(value.g), KALEIDOSCOPE_DebugShape(value.b));
}


uniform int KALEIDOSCOPE_SampleMaskMode <
    ui_type = "combo";
    ui_label = "Sample Mask";
    ui_category = KALEIDOSCOPE_CAT_MAIN; ui_category_closed = false;
    ui_items =
        "Off\0Always\0Never\0Luma Dark\0Luma Bright\0Luma Mid\0Saturation High\0Saturation Low\0Hue Warm\0Hue Cool\0Hue Green\0Contrast\0Depth Available\0Depth Near\0Depth Far\0Depth Edge\0Depth Reject\0Ring Contrast\0Spiral Detail\0Box Variance\0Directional\0Hatch Diagonal\0Cross Hatch\0Hatch Bands\0Line Guard\0Pixel Guard\0Highlight Protect\0Foreground Protect\0Silhouette Protect\0Stable Surface\0";
    ui_tooltip = "Selects the mask intended for sampling-time decisions. In a consuming shader this is the mask you would use inside loops, ray taps, or weighting logic.";
> = 3;

uniform int KALEIDOSCOPE_FinalMaskMode <
    ui_type = "combo";
    ui_label = "Final Mask";
    ui_category = KALEIDOSCOPE_CAT_MAIN; ui_category_closed = false;
    ui_items =
        "Off\0Always\0Never\0Luma Dark\0Luma Bright\0Luma Mid\0Saturation High\0Saturation Low\0Hue Warm\0Hue Cool\0Hue Green\0Contrast\0Depth Available\0Depth Near\0Depth Far\0Depth Edge\0Depth Reject\0Ring Contrast\0Spiral Detail\0Box Variance\0Directional\0Hatch Diagonal\0Cross Hatch\0Hatch Bands\0Line Guard\0Pixel Guard\0Highlight Protect\0Foreground Protect\0Silhouette Protect\0Stable Surface\0";
    ui_tooltip = "Selects the mask intended for final application strength. In a consuming shader this is the mask you would use after the effect has already been computed.";
> = 14;

uniform int KALEIDOSCOPE_CombineMode <
    ui_type = "combo";
    ui_label = "Combine Mode";
    ui_category = KALEIDOSCOPE_CAT_MAIN; ui_category_closed = false;
    ui_items = "Multiply\0Min\0Max\0Add\0Difference\0Sample Only\0Final Only\0";
    ui_tooltip = "Controls how the sample mask and final mask are merged. Multiply is the safest default, Max broadens coverage, Add intensifies it, and Difference highlights where the two masks disagree.";
> = 0;

uniform float KALEIDOSCOPE_MaskStrength <
    ui_type = "slider";
    ui_label = "Mask Strength";
    ui_category = KALEIDOSCOPE_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Scales the combined mask after sample and final stages are merged. Higher values push the weighted mask closer to full strength and make Masked Scene more obvious.";
> = 1.0;

uniform float KALEIDOSCOPE_SceneMix <
    ui_type = "slider";
    ui_label = "Masked Scene Mix";
    ui_category = KALEIDOSCOPE_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Controls how strongly the weighted mask is visualized over the source image in Masked Scene. Lower values keep more of the original scene visible.";
> = 0.8;

uniform float KALEIDOSCOPE_LumaDarkStart <
    ui_type = "slider";
    ui_label = "Dark Start";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where the dark-tone mask starts fading out. Higher values allow more midtones into Luma Dark before the mask weakens.";
> = 0.45;

uniform float KALEIDOSCOPE_LumaDarkFeather <
    ui_type = "slider";
    ui_label = "Dark Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.75; ui_step = 0.001;
    ui_tooltip = "Controls how gradually the dark-tone mask fades into brighter regions. Higher values make Luma Dark smoother and less binary.";
> = 0.18;

uniform float KALEIDOSCOPE_LumaBrightStart <
    ui_type = "slider";
    ui_label = "Bright Start";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where the bright-tone mask begins. Lower values let highlights and upper midtones enter Luma Bright earlier.";
> = 0.62;

uniform float KALEIDOSCOPE_LumaBrightFeather <
    ui_type = "slider";
    ui_label = "Bright Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.75; ui_step = 0.001;
    ui_tooltip = "Controls how softly the bright-tone mask rises. Higher values make the highlight transition broader and less abrupt.";
> = 0.16;

uniform float KALEIDOSCOPE_LumaMidCenter <
    ui_type = "slider";
    ui_label = "Mid Center";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Places the center of the Luma Mid window. Moving it shifts which tonal band is treated as the primary midtone region.";
> = 0.50;

uniform float KALEIDOSCOPE_LumaMidWidth <
    ui_type = "slider";
    ui_label = "Mid Width";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.01; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how wide the Luma Mid window is before it starts falling off. Higher values include more of the tonal range.";
> = 0.12;

uniform float KALEIDOSCOPE_LumaMidFeather <
    ui_type = "slider";
    ui_label = "Mid Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Softens the edges of the midtone window. Higher values create a broader transition from strong midtone selection to no selection.";
> = 0.08;

uniform float KALEIDOSCOPE_SaturationHighStart <
    ui_type = "slider";
    ui_label = "Sat High Start";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where the high-saturation mask begins. Lower values let moderately colorful regions into Saturation High sooner.";
> = 0.45;

uniform float KALEIDOSCOPE_SaturationHighFeather <
    ui_type = "slider";
    ui_label = "Sat High Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how smoothly the high-saturation mask grows. Higher values make colorful transitions less harsh.";
> = 0.18;

uniform float KALEIDOSCOPE_SaturationLowStart <
    ui_type = "slider";
    ui_label = "Sat Low Start";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where the low-saturation mask starts fading out. Higher values keep more muted color inside Saturation Low.";
> = 0.32;

uniform float KALEIDOSCOPE_SaturationLowFeather <
    ui_type = "slider";
    ui_label = "Sat Low Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how gradually the low-saturation mask releases into more vivid color. Higher values are more forgiving.";
> = 0.14;

uniform float KALEIDOSCOPE_HueWidth <
    ui_type = "slider";
    ui_label = "Hue Width";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.01; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how broad each hue-sector mask is around its center. Higher values include a larger color family, while lower values isolate a tighter hue range.";
> = 0.10;

uniform float KALEIDOSCOPE_HueFeather <
    ui_type = "slider";
    ui_label = "Hue Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.30; ui_step = 0.001;
    ui_tooltip = "Softens the edge of each hue-sector mask. Higher values make warm, cool, and green masks transition more smoothly across neighboring hues.";
> = 0.05;

uniform float KALEIDOSCOPE_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Sets how much local luminance change is required before the Contrast mask turns on. Lower values catch more edges and texture.";
> = 0.035;

uniform float KALEIDOSCOPE_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = KALEIDOSCOPE_CAT_SUB_COLOR; ui_category_closed = true;
    ui_min = 1.0; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Amplifies local contrast before thresholding. Higher values make weak structure read more strongly in the Contrast mask.";
> = 2.4;

uniform int KALEIDOSCOPE_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_items = "ReShade Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Chooses how depth is interpreted before depth masks are built. Switch modes when Linear Depth looks flat, inverted, or otherwise wrong for the current game.";
> = 0;

uniform int KALEIDOSCOPE_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Flips near and far interpretation after the selected depth mode is applied. Enable it if near objects appear dark and far objects appear bright when they should not.";
> = 0;

uniform float KALEIDOSCOPE_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies tiny depth differences before edge and reject tests. Raise it when depth-based masks appear too flat to separate scene layers.";
> = 512.0;

uniform float KALEIDOSCOPE_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Availability Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.10000; ui_step = 0.00001;
    ui_tooltip = "Sets how much local depth activity is required before the shader trusts depth. Higher values are stricter and reject weak or noisy depth feeds.";
> = 0.00250;

uniform float KALEIDOSCOPE_DepthNearEnd <
    ui_type = "slider";
    ui_label = "Near End";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets how far the Depth Near mask reaches before it fades out. Higher values extend near coverage farther into the scene.";
> = 0.26;

uniform float KALEIDOSCOPE_DepthNearFeather <
    ui_type = "slider";
    ui_label = "Near Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how gradually the near mask fades away. Higher values create a softer near-to-mid transition.";
> = 0.12;

uniform float KALEIDOSCOPE_DepthFarStart <
    ui_type = "slider";
    ui_label = "Far Start";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where the far-depth mask begins. Lower values bring distant masking closer to the camera, while higher values reserve it for deeper background.";
> = 0.58;

uniform float KALEIDOSCOPE_DepthFarFeather <
    ui_type = "slider";
    ui_label = "Far Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how softly the far-depth mask rises. Higher values create a broader transition into far-region coverage.";
> = 0.18;

uniform float KALEIDOSCOPE_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.0005; ui_max = 0.1000; ui_step = 0.0005;
    ui_tooltip = "Sets how much depth discontinuity is needed before the Depth Edge mask turns on. Lower values catch finer object boundaries.";
> = 0.0100;

uniform float KALEIDOSCOPE_DepthRejectRadius <
    ui_type = "slider";
    ui_label = "Depth Reject Radius";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.25; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Controls how far the shader looks for conflicting depth when building Depth Reject. Higher values make rejection respond to broader local structure.";
> = 1.50;

uniform float KALEIDOSCOPE_DepthRejectThreshold <
    ui_type = "slider";
    ui_label = "Depth Reject Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_DEPTH; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.1000; ui_step = 0.001;
    ui_tooltip = "Sets how much depth mismatch is tolerated before the Depth Reject mask turns off. Lower values make it more protective around silhouettes and intersections.";
> = 0.018;

uniform float KALEIDOSCOPE_SpatialRadiusPixels <
    ui_type = "slider";
    ui_label = "Spatial Radius";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = 0.25; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Controls how far spatial masks sample around each pixel. Higher values make ring, spiral, box, and directional masks respond to larger surrounding structure.";
> = 2.0;

uniform float KALEIDOSCOPE_SpatialGain <
    ui_type = "slider";
    ui_label = "Spatial Gain";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = 0.1; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Amplifies ring and spiral detail responses. Higher values make subtle neighborhood differences read more strongly in those masks.";
> = 2.2;

uniform float KALEIDOSCOPE_BoxVarianceGain <
    ui_type = "slider";
    ui_label = "Box Variance Gain";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = 1.0; ui_max = 64.0; ui_step = 0.1;
    ui_tooltip = "Scales the 3x3 variance response used by Box Variance. Higher values make texture and small tonal breaks show up much more clearly.";
> = 18.0;

uniform float KALEIDOSCOPE_DirectionalAngle <
    ui_type = "slider";
    ui_label = "Directional Angle";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Sets the preferred direction tested by the Directional mask. Rotating it changes which oriented structures are emphasized.";
> = 0.0;

uniform float KALEIDOSCOPE_DirectionalGain <
    ui_type = "slider";
    ui_label = "Directional Gain";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = 0.1; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Amplifies directional difference before thresholding. Higher values make the mask more sensitive to alignment with the chosen angle.";
> = 3.0;

uniform float KALEIDOSCOPE_DirectionalThreshold <
    ui_type = "slider";
    ui_label = "Directional Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets how strong the directional response must be before the Directional mask activates. Lower values catch more subtle orientation.";
> = 0.08;

uniform float KALEIDOSCOPE_DirectionalFeather <
    ui_type = "slider";
    ui_label = "Directional Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_SPATIAL; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how softly the directional mask rises once it passes threshold. Higher values make orientation selection less abrupt.";
> = 0.08;

uniform float KALEIDOSCOPE_HatchScale <
    ui_type = "slider";
    ui_label = "Hatch Scale";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = 4.0; ui_max = 256.0; ui_step = 0.1;
    ui_tooltip = "Controls line spacing for hatch-derived masks. Lower values make lines denser, while higher values spread the pattern farther apart.";
> = 18.0;

uniform float KALEIDOSCOPE_HatchThickness <
    ui_type = "slider";
    ui_label = "Hatch Thickness";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = 0.01; ui_max = 0.95; ui_step = 0.001;
    ui_tooltip = "Changes how thick each hatch stroke is inside its spacing interval. Higher values make hatch masks darker and bolder.";
> = 0.22;

uniform float KALEIDOSCOPE_HatchSoftness <
    ui_type = "slider";
    ui_label = "Hatch Softness";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.001;
    ui_tooltip = "Softens the edge of hatch strokes. Lower values give crisper line masks, while higher values blend line boundaries more gently.";
> = 0.04;

uniform float KALEIDOSCOPE_HatchAngleA <
    ui_type = "slider";
    ui_label = "Hatch Angle A";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Primary hatch direction used by Hatch Diagonal and one side of Cross Hatch. Rotating it changes the dominant stroke orientation.";
> = 35.0;

uniform float KALEIDOSCOPE_HatchAngleB <
    ui_type = "slider";
    ui_label = "Hatch Angle B";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Secondary hatch direction used by Cross Hatch. Changing it alters how the two stroke families intersect.";
> = -35.0;

uniform float KALEIDOSCOPE_HatchBandA <
    ui_type = "slider";
    ui_label = "Hatch Band A";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "First tonal threshold for Hatch Bands. Raising it allows the first hatch layer to appear in brighter tones.";
> = 0.72;

uniform float KALEIDOSCOPE_HatchBandB <
    ui_type = "slider";
    ui_label = "Hatch Band B";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Second tonal threshold for Hatch Bands. It controls when a denser stepped hatch zone becomes active.";
> = 0.48;

uniform float KALEIDOSCOPE_HatchBandC <
    ui_type = "slider";
    ui_label = "Hatch Band C";
    ui_category = KALEIDOSCOPE_CAT_SUB_HATCH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Third tonal threshold for Hatch Bands. Lower values reserve the strongest stepped hatch response for the darkest tones only.";
> = 0.24;

uniform float KALEIDOSCOPE_LineGuardThreshold <
    ui_type = "slider";
    ui_label = "Line Guard Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.250; ui_step = 0.001;
    ui_tooltip = "Sets how strong a local luminance gradient must be before thin-line protection activates. Lower values make the line guard catch more fine structures.";
> = 0.018;

uniform float KALEIDOSCOPE_LineGuardStrength <
    ui_type = "slider";
    ui_label = "Line Guard Strength";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Scales the line-protection mask after detection. Higher values make protected line structures survive more strongly in downstream use.";
> = 0.85;

uniform float KALEIDOSCOPE_PixelGuardThreshold <
    ui_type = "slider";
    ui_label = "Pixel Guard Threshold";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Brightness threshold where hot-pixel protection starts. Lower values make the mask pick up more bright micro-details.";
> = 0.70;

uniform float KALEIDOSCOPE_PixelGuardSaturation <
    ui_type = "slider";
    ui_label = "Pixel Guard Saturation";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Minimum saturation required for color-driven hot-pixel protection. Lower values make the mask catch more vivid pixels.";
> = 0.25;

uniform float KALEIDOSCOPE_PixelGuardStrength <
    ui_type = "slider";
    ui_label = "Pixel Guard Strength";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Scales the hot-pixel protection mask. Higher values preserve bright or saturated micro-pixels more aggressively.";
> = 0.90;

uniform float KALEIDOSCOPE_HighlightProtectStart <
    ui_type = "slider";
    ui_label = "Highlight Protect Start";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Sets where broad highlight protection begins. Lower values bring more upper-midtones into the protected region.";
> = 0.68;

uniform float KALEIDOSCOPE_HighlightProtectFeather <
    ui_type = "slider";
    ui_label = "Highlight Protect Feather";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.50; ui_step = 0.001;
    ui_tooltip = "Controls how softly the highlight-protection mask rolls in. Higher values make bright-region protection more gradual.";
> = 0.18;

uniform float KALEIDOSCOPE_HighlightProtectSaturation <
    ui_type = "slider";
    ui_label = "Highlight Protect Saturation";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Minimum saturation required for color-biased highlight protection. Lower values let colorful highlights enter the mask sooner.";
> = 0.22;

uniform float KALEIDOSCOPE_HighlightProtectColorBias <
    ui_type = "slider";
    ui_label = "Highlight Color Bias";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between pure brightness-driven highlight protection and added saturation-driven protection. Higher values favor vivid emissive colors.";
> = 0.35;

uniform float KALEIDOSCOPE_SilhouetteContrastBias <
    ui_type = "slider";
    ui_label = "Silhouette Contrast Bias";
    ui_category = KALEIDOSCOPE_CAT_SUB_PROTECTION; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Controls how much color-contrast edges contribute relative to depth edges in the silhouette-protection mask. Higher values make silhouettes respond more strongly to image edges.";
> = 0.85;

#include "../header/kaleidoscope.fxh"

float KALEIDOSCOPE_DebugScalar(float value)
{
    return KALEIDOSCOPE_DebugShape(value);
}

float3 KALEIDOSCOPE_HueColor(float hue)
{
    float3 phase = float3(0.0, 0.6666667, 0.3333333);
    return saturate(0.5 + 0.5 * cos(6.2831853 * (hue + phase)));
}

float4 MainPS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;

    if (KALEIDOSCOPE_DebugView == 0)
    {
        return float4(sourceColor, 1.0);
    }

    if (KALEIDOSCOPE_DebugView == 1)
    {
        float sampleMask = KALEIDOSCOPE_EvaluateMask(KALEIDOSCOPE_SampleMaskMode, uv, sourceColor);
        return float4(KALEIDOSCOPE_DebugScalar(sampleMask).xxx, 1.0);
    }

    if (KALEIDOSCOPE_DebugView == 2)
    {
        float finalMask = KALEIDOSCOPE_EvaluateMask(KALEIDOSCOPE_FinalMaskMode, uv, sourceColor);
        return float4(KALEIDOSCOPE_DebugScalar(finalMask).xxx, 1.0);
    }

    if (KALEIDOSCOPE_DebugView == 3 || KALEIDOSCOPE_DebugView == 4 || KALEIDOSCOPE_DebugView == 5)
    {
        float sampleMask = KALEIDOSCOPE_EvaluateMask(KALEIDOSCOPE_SampleMaskMode, uv, sourceColor);
        float finalMask = KALEIDOSCOPE_EvaluateMask(KALEIDOSCOPE_FinalMaskMode, uv, sourceColor);
        float combinedMask = KALEIDOSCOPE_CombineMasks(sampleMask, finalMask);

        if (KALEIDOSCOPE_DebugView == 3)
        {
            return float4(KALEIDOSCOPE_DebugScalar(combinedMask).xxx, 1.0);
        }

        float weightedMask = saturate(combinedMask * KALEIDOSCOPE_MaskStrength);

        if (KALEIDOSCOPE_DebugView == 4)
        {
            return float4(KALEIDOSCOPE_DebugScalar(weightedMask).xxx, 1.0);
        }

        float3 tinted = lerp(
            sourceColor,
            sourceColor * (1.0 - 0.75 * weightedMask) + float3(weightedMask, weightedMask * 0.65, weightedMask * 0.18),
            KALEIDOSCOPE_SceneMix);
        return float4(tinted, 1.0);
    }

    if (KALEIDOSCOPE_DebugView == 6)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_LinearDepth(uv)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 7)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_DepthAvailability(uv)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 8)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_LocalContrast(uv, sourceColor) * KALEIDOSCOPE_ContrastGain).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 9)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_Saturation(sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 10)
    {
        return float4(KALEIDOSCOPE_DebugShape3(KALEIDOSCOPE_HueColor(KALEIDOSCOPE_Hue(sourceColor))), 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 11)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_RingContrastMask(uv, sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 12)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_SpiralDetailMask(uv, sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 13)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_BoxVarianceMask(uv, sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 14)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_DirectionalMask(uv, sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 15)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_HatchDiagonalMask(uv)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 16)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_CrossHatchMask(uv)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 17)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_HatchBandsMask(KALEIDOSCOPE_Luma(sourceColor))).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 18)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_LineGuardMask(sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 19)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_PixelGuardMask(sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 20)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_HighlightProtectMask(sourceColor)).xxx, 1.0);
    }
    if (KALEIDOSCOPE_DebugView == 21)
    {
        return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_SilhouetteProtectMask(uv, sourceColor)).xxx, 1.0);
    }

    return float4(KALEIDOSCOPE_DebugScalar(KALEIDOSCOPE_StableSurfaceMask(uv, sourceColor)).xxx, 1.0);
}

technique kaleidoscope
<
    ui_label = "Kaleidoscope :: Image Mask Construction Server";
    ui_tooltip = "Displays sample-mask fields, final-mask fields, mask combination logic, and the supporting color, depth, spatial, hatch, and protection diagnostics used to construct image masks.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = MainPS;
    }
}

