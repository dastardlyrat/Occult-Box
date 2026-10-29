// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Capability: Three-stage anti-aliasing effect with FXAA-like directional smoothing, SMAA-like neighborhood blending, and organic lens-field adjunct smoothing.

#include "ReShade.fxh"

#define POTTERY_CAT_DEBUG "Potting Clay / 00 Debug"
#define POTTERY_CAT_MAIN "Potting Clay / 01 Main Settings"
#define POTTERY_CAT_LENS "Potting Clay / 02 Organic Lens Field"
#define POTTERY_CAT_DIRECTIONAL "Potting Clay / 03 FXAA-Like Directional Smoothing Pass"
#define POTTERY_CAT_NEIGHBORHOOD "Potting Clay / 04 SMAA-Like Neighborhood Blending Pass"
#define POTTERY_CAT_ORGANIC "Potting Clay / 05 Organic Lens Adjunct Smoothing Pass"
#define POTTERY_CAT_MASK "Potting Clay / 06 Mask Field and Depth"

uniform int POTTERY_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final Composite\0Edge Range\0FXAA-Like Pass Blend\0SMAA-Like Pass Blend\0Organic Adjunct Pass Blend\0Combined Pass Weight\0Computed Application Weight\0Tiled Organic Sampling Field\0Center Organic Sampling Footprint\0Organic Field Strength\0Selected Mask\0Fog Evidence\0Final Application Gate\0FXAA-Like Smoothed Image\0SMAA-Like Smoothed Image\0Organic Adjunct Smoothed Image\0";
    ui_tooltip = "Chooses which anti-aliasing stage to inspect. The first six diagnostics show edge detection and the three pass weights. The next three show the organic lens-field geometry and field strength. Selected Mask and Fog Evidence show the gating signals. Final Application Gate shows the fully combined anti-aliasing gate. The last three views show the isolated image produced by the FXAA-like, SMAA-like, and organic adjunct passes.";
> = 0;

uniform float POTTERY_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens weak diagnostics so faint blend weights, gates, and field-strength views are easier to inspect. Does not change the final anti-aliased image.";
> = 1.0;

uniform float POTTERY_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.65;

uniform float POTTERY_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float POTTERY_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float POTTERY_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int POTTERY_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float POTTERY_DebugShape(float value)
{
    float debugLow = min(POTTERY_DebugBlackPoint, POTTERY_DebugWhitePoint - 0.0001);
    float debugHigh = max(POTTERY_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, POTTERY_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, POTTERY_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, POTTERY_DebugGamma));
    if (POTTERY_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 POTTERY_DebugShape3(float3 value)
{
    return float3(POTTERY_DebugShape(value.r), POTTERY_DebugShape(value.g), POTTERY_DebugShape(value.b));
}


uniform float POTTERY_DebugPatternScale <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales only the repeated debug field views. This changes how large the organic field appears in debug and does not change real smoothing.";
> = 0.24;

uniform float POTTERY_DebugPatternTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the organic field debug layout across the screen. This is only for reading field spacing and rotation.";
> = 4.0;

uniform float POTTERY_DebugMarkerSize <
    ui_type = "slider";
    ui_label = "Debug Marker Size";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Controls how large tap markers appear in the tiled field and center footprint debug views. This does not change real sample size.";
> = 0.016;

uniform float POTTERY_DebugPatternSoftness <
    ui_type = "slider";
    ui_label = "Debug Pattern Softness";
    ui_category = POTTERY_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens the marker edges and guide rings in debug views. This is a readability control only.";
> = 0.012;

uniform int POTTERY_Enable <
    ui_type = "combo";
    ui_label = "Enable Three-Stage Anti-Aliasing Effect";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the three-stage anti-aliasing effect. Off returns the original image unchanged.";
> = 1;

uniform int POTTERY_EnableDirectional <
    ui_type = "combo";
    ui_label = "Enable FXAA-Like Directional Smoothing Pass";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the first pass, which performs fast directional smoothing along the detected edge direction in an FXAA-like way.";
> = 1;

uniform int POTTERY_EnableNeighborhood <
    ui_type = "combo";
    ui_label = "Enable SMAA-Like Neighborhood Blending Pass";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the second pass, which blends nearby horizontal, vertical, and diagonal neighborhoods in an SMAA-like way.";
> = 1;

uniform int POTTERY_EnableOrganic <
    ui_type = "combo";
    ui_label = "Enable Organic Lens Adjunct Smoothing Pass";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the third pass, which uses the lens server field as an organic adjunct smoothing stage after the FXAA-like and SMAA-like stages.";
> = 1;

uniform float POTTERY_MasterIntensity <
    ui_type = "slider";
    ui_label = "Master Intensity";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Overall strength multiplier applied after the three anti-aliasing stages are merged and gated.";
> = 1.0;

uniform float POTTERY_EdgeThreshold <
    ui_type = "slider";
    ui_label = "Edge Threshold";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0001; ui_max = 0.5000; ui_step = 0.0001;
    ui_tooltip = "Minimum luma range required before any anti-aliasing is allowed to engage.";
> = 0.035;

uniform float POTTERY_EdgeSoftness <
    ui_type = "slider";
    ui_label = "Edge Softness";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0001; ui_max = 0.5000; ui_step = 0.0001;
    ui_tooltip = "Soft transition width above the edge threshold. Higher values make anti-aliasing ramp in more gradually.";
> = 0.040;

uniform int POTTERY_OrganicLensMode <
    ui_type = "combo";
    ui_label = "Organic Sampling Lens Family";
    ui_category = POTTERY_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived lens family used by the organic smoothing pass.";
> = 3;

uniform int POTTERY_QualityTier <
    ui_type = "combo";
    ui_label = "Organic Quality Tier";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_items = "Disciplined 9\0Broad 21\0High 34\0Ultra 55\0";
    ui_tooltip = "Caps the organic tap budget before the active lens family applies its own family-size clamp.";
> = 2;

uniform int POTTERY_OrganicTapBudget <
    ui_type = "slider";
    ui_label = "Organic Field Tap Budget";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the organic lens field before quality-tier and family-size clamping are applied. This changes real smoothing, not just debug.";
> = 21;

uniform int POTTERY_ReductionMode <
    ui_type = "combo";
    ui_label = "Organic Reduction Mode";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "Sequential uses the earliest taps first. Staggered redistributes reduced tap counts across the full canonical lens shape.";
> = 1;

uniform float POTTERY_FieldScale <
    ui_type = "slider";
    ui_label = "Organic Field Scale";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Scales the underlying organic lens constellation before it is converted into pixel-space smoothing offsets.";
> = 1.0;

uniform float POTTERY_FieldRotation <
    ui_type = "slider";
    ui_label = "Organic Field Rotation";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the organic lens field used by the third anti-aliasing pass.";
> = 0.0;

uniform float POTTERY_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Organic Fibonacci Anchor";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the golden-angle phase used by the Fibonacci-derived organic lens families.";
> = 2584.0;

uniform float POTTERY_OrganicRadiusPixels <
    ui_type = "slider";
    ui_label = "Organic Radius";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 6.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the organic lens smoothing pass.";
> = 1.25;

uniform float POTTERY_OrganicEdgeBias <
    ui_type = "slider";
    ui_label = "Organic Edge Bias";
    ui_category = POTTERY_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Biases organic lens weights toward taps aligned with the detected edge direction.";
> = 0.58;

uniform float POTTERY_DirectionalStrength <
    ui_type = "slider";
    ui_label = "FXAA-Like Pass Strength";
    ui_category = POTTERY_CAT_DIRECTIONAL; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Blend strength of the FXAA-like directional smoothing pass.";
> = 0.85;

uniform float POTTERY_DirectionalSpanPixels <
    ui_type = "slider";
    ui_label = "FXAA-Like Directional Span";
    ui_category = POTTERY_CAT_DIRECTIONAL; ui_category_closed = true;
    ui_min = 0.25; ui_max = 4.0; ui_step = 0.01;
    ui_tooltip = "Maximum span sampled along the detected edge direction by the FXAA-like smoothing pass.";
> = 1.45;

uniform float POTTERY_DirectionalSubpixel <
    ui_type = "slider";
    ui_label = "FXAA-Like Subpixel Bias";
    ui_category = POTTERY_CAT_DIRECTIONAL; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Subpixel weighting for the FXAA-like pass. Higher values extend the directional smoothing footprint.";
> = 0.65;

uniform float POTTERY_NeighborhoodStrength <
    ui_type = "slider";
    ui_label = "SMAA-Like Pass Strength";
    ui_category = POTTERY_CAT_NEIGHBORHOOD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Blend strength of the SMAA-like neighborhood blending pass.";
> = 0.90;

uniform float POTTERY_NeighborhoodContrastThreshold <
    ui_type = "slider";
    ui_label = "SMAA-Like Neighborhood Contrast Threshold";
    ui_category = POTTERY_CAT_NEIGHBORHOOD; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.5000; ui_step = 0.0001;
    ui_tooltip = "Contrast gate for the SMAA-like neighborhood blending pass. Higher values make this pass more selective.";
> = 0.022;

uniform float POTTERY_NeighborhoodDiagonalWeight <
    ui_type = "slider";
    ui_label = "SMAA-Like Diagonal Weight";
    ui_category = POTTERY_CAT_NEIGHBORHOOD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly diagonal neighborhood blending contributes relative to horizontal and vertical blending inside the SMAA-like pass.";
> = 0.70;

uniform float POTTERY_OrganicStrength <
    ui_type = "slider";
    ui_label = "Organic Adjunct Pass Strength";
    ui_category = POTTERY_CAT_ORGANIC; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Blend strength of the organic lens adjunct smoothing pass.";
> = 0.85;

uniform float POTTERY_OrganicDistanceFalloff <
    ui_type = "slider";
    ui_label = "Organic Adjunct Distance Falloff";
    ui_category = POTTERY_CAT_ORGANIC; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "How quickly farther organic taps lose influence. Higher values bias the organic adjunct pass toward nearer taps.";
> = 1.2;

uniform float POTTERY_OrganicCenterWeight <
    ui_type = "slider";
    ui_label = "Organic Adjunct Center Weight";
    ui_category = POTTERY_CAT_ORGANIC; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly the source pixel is preserved within the organic adjunct pass before neighboring taps are averaged in.";
> = 1.0;

uniform int POTTERY_MaskMode <
    ui_type = "combo";
    ui_label = "Selected Mask Field";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Depth Window\0Far Detail Stack\0Contrast\0Composite Guard\0";
    ui_tooltip = "Selects the Crystal Mass-derived mask used to gate the anti-aliasing result.";
> = 5;

uniform float POTTERY_MaskInfluence <
    ui_type = "slider";
    ui_label = "Mask Influence";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly the selected mask field influences the final anti-aliasing gate. At zero the mask is ignored. At one the selected mask is fully respected.";
> = 0.35;

uniform float POTTERY_FogInfluence <
    ui_type = "slider";
    ui_label = "Fog Evidence Influence";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly fog-like regions reduce the final anti-aliasing gate.";
> = 0.25;

uniform int POTTERY_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Interpretation Mode";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_items = "ReShade Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Controls how the Crystal Mass-derived depth logic interprets the scene depth buffer.";
> = 0;

uniform int POTTERY_DepthInvert <
    ui_type = "combo";
    ui_label = "Invert Depth";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts depth interpretation before depth-derived masks are evaluated.";
> = 0;

uniform float POTTERY_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 1.0; ui_max = 512.0; ui_step = 1.0;
    ui_tooltip = "Scales small depth differences so depth confidence, depth windowing, and far-detail logic read more clearly.";
> = 256.0;

uniform float POTTERY_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Confidence Threshold";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.01; ui_step = 0.00001;
    ui_tooltip = "Minimum useful depth variation required before depth-driven masks are trusted.";
> = 0.001;

uniform float POTTERY_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Window Start";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Near boundary of the selected depth window mask.";
> = 0.10;

uniform float POTTERY_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth Window End";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Far boundary of the selected depth window mask.";
> = 0.95;

uniform float POTTERY_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Threshold used by depth-edge diagnostics and silhouette-style logic within the Crystal-derived masks.";
> = 0.012;

uniform float POTTERY_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Depth where the far-detail mask begins to activate.";
> = 0.40;

uniform float POTTERY_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Depth where the far-detail mask reaches full strength.";
> = 0.85;

uniform float POTTERY_DetailScale <
    ui_type = "slider";
    ui_label = "Detail Scale";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.1; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Scales the detail detector used by the far-detail mask.";
> = 1.0;

uniform float POTTERY_DetailLow <
    ui_type = "slider";
    ui_label = "Detail Threshold Low";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Low threshold of the detail detector used by the far-detail mask.";
> = 0.03;

uniform float POTTERY_DetailHigh <
    ui_type = "slider";
    ui_label = "Detail Threshold High";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "High threshold of the detail detector used by the far-detail mask.";
> = 0.12;

uniform float POTTERY_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Threshold used by the contrast-derived mask field.";
> = 0.06;

uniform float POTTERY_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.1; ui_max = 8.0; ui_step = 0.001;
    ui_tooltip = "Gain applied to the local-contrast detector before the contrast mask is formed.";
> = 2.0;

uniform float POTTERY_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Brightness floor used by the fog-evidence detector.";
> = 0.45;

uniform float POTTERY_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation Floor";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Desaturation floor used by the fog-evidence detector.";
> = 0.25;

uniform float POTTERY_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast Ceiling";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Upper contrast ceiling used by the fog-evidence detector.";
> = 0.06;

uniform float POTTERY_LineThreshold <
    ui_type = "slider";
    ui_label = "Line Threshold";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.5; ui_step = 0.0001;
    ui_tooltip = "Edge threshold used by line-like structure suppression inside the fog-evidence logic.";
> = 0.020;

uniform float POTTERY_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Brightness threshold used by the light-shield detector.";
> = 0.72;

uniform float POTTERY_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = POTTERY_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.5; ui_step = 0.001;
    ui_tooltip = "Transition softness used by the light-shield detector.";
> = 0.12;

#include "../header/PottingClay.fxh"

technique PottingClay <
    ui_label = "Potting Clay :: Three-Stage Anti-Aliasing";
    ui_tooltip = "Applies three anti-aliasing stages: an FXAA-like directional smoothing pass, an SMAA-like neighborhood blending pass, and an organic lens-field adjunct smoothing pass, then gates the result with a Crystal-derived application mask.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = POTTERY_MainPS;
    }
}

