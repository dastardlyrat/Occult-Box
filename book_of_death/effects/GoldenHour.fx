// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Indirect light recovery effect that gathers nearby color and redistributes it as screen-space bounce lighting.

#include "ReShade.fxh"

#define GOLDEN_CAT_DEBUG "Golden Hour / 00 Debug"
#define GOLDEN_CAT_MAIN "Golden Hour / 01 Main Settings"
#define GOLDEN_CAT_LENS "Golden Hour / 02 Lens Fields and Taps"
#define GOLDEN_CAT_GATHER "Golden Hour / 03 Gather and Bounce"
#define GOLDEN_CAT_MASK "Golden Hour / 04 Mask Field and Depth"
#define GOLDEN_CAT_BREAKUP "Golden Hour / 05 Breakup Field"

uniform int GOLDEN_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final Composite\0Local Indirect\0Bounce Contribution\0Tiled Sampling Field\0Center Sampling Footprint\0Sampling Field Strength\0Tiled Application Field\0Center Application Footprint\0Application Field Strength\0Depth Accept Field\0Selected Mask\0Fog Evidence\0Final Application Gate\0Breakup Field\0";
    ui_tooltip = "Chooses which Golden Hour stage to inspect. Local Indirect shows the filtered gathered light, Bounce Contribution shows the brightened difference from the source, the tiled field views show repeated local field structure, the center footprint views show the real center-anchored tap footprint, Sampling Field Strength and Application Field Strength show scalar field intensity at the current pixel, Depth Accept Field shows how well the gather survives depth rejection, Selected Mask shows the raw selected mask result, Fog Evidence shows the atmosphere detector directly, Final Application Gate shows the fully combined indirect-light gate, and Breakup Field shows the optional structural modulation field.";
> = 0;

uniform float GOLDEN_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal diagnostics so weak gather, mask, and tap fields are easier to inspect. Does not change Final Composite.";
> = 1.0;

uniform float GOLDEN_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.65;

uniform float GOLDEN_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float GOLDEN_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float GOLDEN_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int GOLDEN_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float GOLDEN_DebugShape(float value)
{
    float debugLow = min(GOLDEN_DebugBlackPoint, GOLDEN_DebugWhitePoint - 0.0001);
    float debugHigh = max(GOLDEN_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, GOLDEN_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, GOLDEN_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, GOLDEN_DebugGamma));
    if (GOLDEN_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 GOLDEN_DebugShape3(float3 value)
{
    return float3(GOLDEN_DebugShape(value.r), GOLDEN_DebugShape(value.g), GOLDEN_DebugShape(value.b));
}


uniform float GOLDEN_DebugPatternScale <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales the tiled debug field views only. This changes how large the repeated debug field appears on screen and does not change the real sampling or application radius.";
> = 0.24;

uniform float GOLDEN_DebugPatternTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the debug field layout across the screen. This is only for reading spacing and rotation and does not affect the real indirect-light image.";
> = 4.0;

uniform float GOLDEN_DebugMarkerSize <
    ui_type = "slider";
    ui_label = "Debug Marker Size";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Controls how large each tap marker appears in the tiled field views and center footprint views. This does not change the real sample size.";
> = 0.016;

uniform float GOLDEN_DebugPatternSoftness <
    ui_type = "slider";
    ui_label = "Debug Pattern Softness";
    ui_category = GOLDEN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens debug marker edges and guide rings. This is a readability control for debug only.";
> = 0.012;

uniform int GOLDEN_Enable <
    ui_type = "combo";
    ui_label = "Enable Indirect Light Effect";
    ui_category = GOLDEN_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the Golden Hour gather GI. Off returns the source image unchanged.";
> = 1;

uniform float GOLDEN_MasterIntensity <
    ui_type = "slider";
    ui_label = "Master Intensity";
    ui_category = GOLDEN_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Overall strength multiplier for the final indirect-light contribution after all gather, mask, and breakup shaping.";
> = 1.0;

uniform float GOLDEN_GIStrength <
    ui_type = "slider";
    ui_label = "GI Strength";
    ui_category = GOLDEN_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Scales the recovered bounce contribution before it is composited over the source. Raise it when the indirect field is structurally right but too faint.";
> = 1.4;

uniform float GOLDEN_MaxContribution <
    ui_type = "slider";
    ui_label = "Max Contribution";
    ui_category = GOLDEN_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Upper cap on how much gathered light may brighten the source. Lower values keep the effect conservative; higher values let bright bounce accumulate more strongly.";
> = 1.8;

uniform int GOLDEN_SamplingLensMode <
    ui_type = "combo";
    ui_label = "Sampling Field Lens Family";
    ui_category = GOLDEN_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived tap geometry used to gather indirect light. Lens55 families favor broad quality gathers, while the smaller structured lenses favor more disciplined local support.";
> = 3;

uniform int GOLDEN_ApplicationLensMode <
    ui_type = "combo";
    ui_label = "Application Field Lens Family";
    ui_category = GOLDEN_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived field used to shape where the gathered light is allowed to land in the final composite.";
> = 8;

uniform int GOLDEN_QualityTier <
    ui_type = "combo";
    ui_label = "Quality Tier";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_items = "Disciplined 9\0Broad 21\0High 34\0Ultra 55\0";
    ui_tooltip = "Caps the active tap count before the user tap budget is applied. Higher tiers keep more of the high-quality tap field alive.";
> = 2;

uniform int GOLDEN_TapBudget <
    ui_type = "slider";
    ui_label = "Sampling Field Tap Budget";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the main indirect-light gather field before the lens family size and quality tier clamp are applied. This changes the real GI gather, not just debug. Higher values favor denser and smoother indirect gathers.";
> = 34;

uniform int GOLDEN_ApplicationTapBudget <
    ui_type = "slider";
    ui_label = "Application Field Tap Budget";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the application lens field before the family size and quality tier clamp are applied. This changes the real placement field, not just debug, and affects where GI is allowed to land rather than how it is gathered.";
> = 21;

uniform int GOLDEN_ReductionMode <
    ui_type = "combo";
    ui_label = "Reduction Mode";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "Sequential consumes the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so coverage stays even when the budget is below the maximum.";
> = 1;

uniform float GOLDEN_FieldScale <
    ui_type = "slider";
    ui_label = "Field Scale";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Scales the underlying Obsidian Mirror lens constellation before it is converted into pixel-space gather offsets for the real GI image.";
> = 1.0;

uniform float GOLDEN_FieldRotation <
    ui_type = "slider";
    ui_label = "Field Rotation";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the active lens field in the real GI gather and placement paths. This mainly affects directional and anisotropic lens families such as the rectangular and diamond variants.";
> = 0.0;

uniform float GOLDEN_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = GOLDEN_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the golden-angle phase used by the Fibonacci-derived lens families in the real gather and placement fields. Changing it re-phases sample ordering without altering the total tap count.";
> = 2584.0;

uniform float GOLDEN_GatherRadiusPixels <
    ui_type = "slider";
    ui_label = "Gather Radius";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.25; ui_max = 24.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the indirect-light gather. Larger values reach farther and recover broader bounce; smaller values stay tighter and more local.";
> = 5.0;

uniform float GOLDEN_DistanceFalloff <
    ui_type = "slider";
    ui_label = "Distance Falloff";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Controls how quickly far taps lose influence within the active lens field. Lower values keep distant taps strong; higher values bias the gather back toward the center.";
> = 1.1;

uniform float GOLDEN_BrightSampleBias <
    ui_type = "slider";
    ui_label = "Bright Sample Bias";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.5; ui_step = 0.001;
    ui_tooltip = "Bias toward taps that are brighter than the current pixel. Higher values make Golden Hour recover more luminous neighboring bounce, especially in shadowed regions.";
> = 0.10;

uniform float GOLDEN_ShadowPreference <
    ui_type = "slider";
    ui_label = "Shadow Preference";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Biases the recovered bounce toward darker source regions. Higher values keep the brightening concentrated in shadow and midtone areas instead of lifting the whole scene evenly.";
> = 1.2;

uniform float GOLDEN_BounceSaturation <
    ui_type = "slider";
    ui_label = "Bounce Saturation";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.5; ui_step = 0.001;
    ui_tooltip = "Restores or suppresses color saturation in the gathered indirect light. Lower values make the bounce more neutral; higher values let it keep more sampled color character.";
> = 1.15;

uniform float GOLDEN_SourceRetention <
    ui_type = "slider";
    ui_label = "Source Retention";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How much of the source color is treated as already-lit before bounce is extracted. Higher values make the GI more conservative by requiring gathered light to rise farther above the source.";
> = 0.72;

uniform float GOLDEN_ApplicationRadiusPixels <
    ui_type = "slider";
    ui_label = "Application Field Radius";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.25; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius used to evaluate the application lens field in the real GI output. Larger values let the application mask respond to broader neighborhood structure.";
> = 2.6;

uniform float GOLDEN_ApplicationLensStrength <
    ui_type = "slider";
    ui_label = "Application Lens Strength";
    ui_category = GOLDEN_CAT_GATHER; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly the application lens field modulates where the recovered GI is allowed to land in the real composite.";
> = 0.9;

uniform int GOLDEN_MaskMode <
    ui_type = "combo";
    ui_label = "Selected Mask Field";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Depth Window\0Far Detail Stack\0Contrast\0Composite Guard\0";
    ui_tooltip = "Selects the Crystal Mass-derived field used to gate GI application. Composite Guard combines depth, contrast, distance, and protection behavior into a broader placement guide.";
> = 6;

uniform float GOLDEN_MaskInfluence <
    ui_type = "slider";
    ui_label = "Mask Influence";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between ungated application and the selected mask field. Lower values let the gather read clearly for tuning; higher values enforce the mask more strongly.";
> = 0.65;

uniform float GOLDEN_MaskStrength <
    ui_type = "slider";
    ui_label = "Mask Strength";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Scales the selected mask field before it is blended into the final application gate.";
> = 1.0;

uniform int GOLDEN_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_items = "Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Chooses how depth is interpreted before the depth-aware gather and Crystal Mass-derived guards evaluate the scene.";
> = 0;

uniform int GOLDEN_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts near and far interpretation for reversed depth buffers or alternative depth conventions.";
> = 0;

uniform float GOLDEN_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies small depth differences before availability, edge, and reject logic are evaluated. Raise it when valid depth exists but gather acceptance is too weak.";
> = 256.0;

uniform float GOLDEN_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Availability Threshold";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.05; ui_step = 0.00001;
    ui_tooltip = "Minimum local depth activity required before depth-aware filters fully trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal.";
> = 0.001;

uniform float GOLDEN_DepthRejectStart <
    ui_type = "slider";
    ui_label = "Depth Reject Start";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Beginning of the depth mismatch ramp that suppresses off-surface taps. Lower values make the gather more surface-tight.";
> = 0.008;

uniform float GOLDEN_DepthRejectEnd <
    ui_type = "slider";
    ui_label = "Depth Reject End";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.4; ui_step = 0.0001;
    ui_tooltip = "Depth mismatch where taps are fully rejected. Raising it tolerates broader depth variation before samples drop out.";
> = 0.045;

uniform float GOLDEN_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.05; ui_step = 0.0001;
    ui_tooltip = "Threshold used by the Crystal Mass-derived depth-discontinuity logic. Lower values catch more silhouette changes; higher values reserve the signal for stronger breaks.";
> = 0.003;

uniform float GOLDEN_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Start";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the generic depth window used by the depth and composite masks.";
> = 0.08;

uniform float GOLDEN_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth End";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary of the generic depth window used by the depth and composite masks.";
> = 1.0;

uniform float GOLDEN_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Beginning of the far-distance range used by the far-detail and composite masks.";
> = 0.40;

uniform float GOLDEN_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Point where far-distance qualification reaches full strength for the far-detail and composite masks.";
> = 0.78;

uniform float GOLDEN_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1; ui_step = 0.0001;
    ui_tooltip = "Minimum brightness before the fog evidence branch begins to react. Raise it to ignore dim haze and focus on brighter atmosphere.";
> = 0.004;

uniform float GOLDEN_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How colorless a region should be before fog evidence strengthens. Higher values focus more tightly on neutral mist and haze.";
> = 0.18;

uniform float GOLDEN_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Local-contrast threshold used by the fog evidence branch. Lower values make fog detection more selective; higher values allow flatter structure to qualify more easily.";
> = 0.04;

uniform float GOLDEN_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness threshold used by the light-protection branch. Lower values protect more highlights and emissive accents.";
> = 0.68;

uniform float GOLDEN_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Transition width of the light-protection branch. Higher values broaden highlight protection instead of clipping it abruptly.";
> = 0.18;

uniform float GOLDEN_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.0001;
    ui_tooltip = "Minimum local contrast required before the contrast branch qualifies. Lower values catch more texture; higher values reserve the field for clearer structure.";
> = 0.02;

uniform float GOLDEN_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = GOLDEN_CAT_MASK; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Gain applied to the local contrast probe before thresholding. Raise it when structurally correct contrast fields are too faint to be useful.";
> = 2.0;

uniform int GOLDEN_BreakupMode <
    ui_type = "combo";
    ui_label = "Breakup Mode";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_items = "Off\0Procedural Bio\0Five-Stage\0Cross Hatch\0";
    ui_tooltip = "Optional Crooked Tongue-derived breakup field used to subtly shape GI placement. Off keeps the indirect light smooth and purely lens-driven.";
> = 0;

uniform float GOLDEN_BreakupInfluence <
    ui_type = "slider";
    ui_label = "Breakup Influence";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly the breakup field modulates where the final GI lands. Lower values keep the result smoother; higher values introduce more stylized structural modulation.";
> = 0.25;

uniform int GOLDEN_BreakupTapBudget <
    ui_type = "slider";
    ui_label = "Breakup Tap Budget";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_min = 3; ui_max = 34; ui_step = 1;
    ui_tooltip = "Requested tap count for tap-driven breakup branches. This mainly affects the Procedural Bio breakup field, which uses Lens55-derived directional support.";
> = 13;

uniform float GOLDEN_BreakupScale <
    ui_type = "slider";
    ui_label = "Breakup Scale";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_min = 60.0; ui_max = 1600.0; ui_step = 0.1;
    ui_tooltip = "UV scale of the optional breakup field. Larger values tighten the breakup structure; smaller values keep it broad and slow.";
> = 540.0;

uniform float GOLDEN_BreakupDensity <
    ui_type = "slider";
    ui_label = "Breakup Density";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_min = 0.1; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Frequency of the optional breakup field. Higher values pack more structure into the same spatial region.";
> = 1.9;

uniform float GOLDEN_BreakupFlow <
    ui_type = "slider";
    ui_label = "Breakup Flow";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6.0; ui_step = 0.001;
    ui_tooltip = "Directional phase offset used by the optional breakup field. Changing it re-phases the structure without changing tap count.";
> = 2.2;

uniform float GOLDEN_BreakupTapSpread <
    ui_type = "slider";
    ui_label = "Breakup Tap Spread";
    ui_category = GOLDEN_CAT_BREAKUP; ui_category_closed = true;
    ui_min = 8.0; ui_max = 220.0; ui_step = 0.01;
    ui_tooltip = "How far Lens55 taps spread when the Procedural Bio breakup branch is active. Larger values produce looser and broader structural drift.";
> = 96.0;

#include "../header/GoldenHour.fxh"

technique GoldenHour < ui_label = "Golden Hour :: Screen Space Indirect Light"; ui_tooltip = "Recovers nearby image color, filters it through sampling and application fields, and adds it back as indirect bounce light."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = GOLDEN_MainPS;
    }
}

