// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Capability: Organic local deep-tone shaping with chroma-preserving remap, bounded lens support, and guarded application.

#include "ReShade.fxh"

#define DEEP_CAT_DEBUG "Blue Smoke / 00 Debug"
#define DEEP_CAT_MAIN "Blue Smoke / 01 Main Settings"
#define DEEP_CAT_LENS "Blue Smoke / 02 Organic Support Field"
#define DEEP_CAT_TONE "Blue Smoke / 03 Tone Shaping"
#define DEEP_CAT_MASK "Blue Smoke / 04 Mask Field and Depth"

uniform int DEEP_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final Composite\0Shaped Tone Field\0Organic Support Luma\0Tone Region Mask\0Depth Stability Gate\0Source Saturation\0Computed Application Weight\0Tiled Organic Support Field\0Center Organic Support Footprint\0Organic Support Strength\0Selected Mask\0Fog Evidence\0Final Application Gate\0";
    ui_tooltip = "Chooses which deep-tone stage to inspect. Shaped Tone Field shows the signed local luminance shaping, Organic Support Luma shows the local support average, Tone Region Mask shows where the tone pivot and width permit shaping, Depth Stability Gate shows how depth continuity suppresses unstable shaping, Source Saturation shows the original chroma level, Computed Application Weight shows the final scalar shaping weight before color remap, the organic field views show the repeated support field geometry and real center footprint, Selected Mask and Fog Evidence show the Crystal-derived gates, and Final Application Gate shows the fully combined application gate.";
> = 0;

uniform float DEEP_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal diagnostics so weak tone shaping, support, and gating fields are easier to inspect. Does not change the final image.";
> = 1.0;

uniform float DEEP_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.65;

uniform float DEEP_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float DEEP_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float DEEP_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int DEEP_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float DEEP_DebugShape(float value)
{
    float debugLow = min(DEEP_DebugBlackPoint, DEEP_DebugWhitePoint - 0.0001);
    float debugHigh = max(DEEP_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, DEEP_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, DEEP_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, DEEP_DebugGamma));
    if (DEEP_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 DEEP_DebugShape3(float3 value)
{
    return float3(DEEP_DebugShape(value.r), DEEP_DebugShape(value.g), DEEP_DebugShape(value.b));
}


uniform float DEEP_DebugPatternScale <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales only the repeated organic support debug field. This does not change the real support radius.";
> = 0.24;

uniform float DEEP_DebugPatternTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the support field debug layout across the screen for easier spacing and rotation inspection.";
> = 4.0;

uniform float DEEP_DebugMarkerSize <
    ui_type = "slider";
    ui_label = "Debug Marker Size";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Controls how large support taps appear in the debug field and center footprint views. This does not change real sampling.";
> = 0.016;

uniform float DEEP_DebugPatternSoftness <
    ui_type = "slider";
    ui_label = "Debug Pattern Softness";
    ui_category = DEEP_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens support tap markers and guide rings in debug only.";
> = 0.012;

uniform int DEEP_Enable <
    ui_type = "combo";
    ui_label = "Enable Blue Smoke Effect";
    ui_category = DEEP_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the deep-tone effect. Off returns the source image unchanged.";
> = 1;

uniform float DEEP_MasterIntensity <
    ui_type = "slider";
    ui_label = "Master Intensity";
    ui_category = DEEP_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Overall multiplier applied after local tone shaping, colorfulness shaping, and final gating are combined.";
> = 1.0;

uniform float DEEP_RichnessStrength <
    ui_type = "slider";
    ui_label = "Deep Tone Strength";
    ui_category = DEEP_CAT_MAIN; ui_category_closed = false;
    ui_min = -1.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Strength of the local luminance remap. Positive values deepen tone relationships; negative values invert the behavior toward lifting.";
> = 0.65;

uniform float DEEP_ColorfulnessStrength <
    ui_type = "slider";
    ui_label = "Colorfulness Expansion";
    ui_category = DEEP_CAT_MAIN; ui_category_closed = false;
    ui_min = -1.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Optional chroma expansion applied after luminance remap. Higher values let strengthened tone structure carry more color separation.";
> = 0.28;

uniform int DEEP_LensMode <
    ui_type = "combo";
    ui_label = "Organic Support Lens Family";
    ui_category = DEEP_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived lens family used to compute local organic tone support.";
> = 3;

uniform int DEEP_QualityTier <
    ui_type = "combo";
    ui_label = "Organic Support Quality Tier";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_items = "Disciplined 9\0Broad 21\0High 34\0Ultra 55\0";
    ui_tooltip = "Caps the support tap budget before family-size clamping is applied.";
> = 2;

uniform int DEEP_TapBudget <
    ui_type = "slider";
    ui_label = "Organic Support Tap Budget";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the organic support field before quality-tier and family-size clamping are applied. This changes the real support field.";
> = 12;

uniform int DEEP_ReductionMode <
    ui_type = "combo";
    ui_label = "Organic Support Reduction Mode";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "Sequential uses the earliest taps first. Staggered redistributes reduced support taps across the full canonical lens shape.";
> = 1;

uniform float DEEP_FieldScale <
    ui_type = "slider";
    ui_label = "Organic Support Field Scale";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Scales the organic support lens constellation before it is converted into pixel-space support offsets.";
> = 1.0;

uniform float DEEP_FieldRotation <
    ui_type = "slider";
    ui_label = "Organic Support Field Rotation";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the organic support field used to gather local tone context.";
> = 0.0;

uniform float DEEP_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Organic Support Fibonacci Anchor";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the golden-angle phase used by Fibonacci-derived support lens families.";
> = 2584.0;

uniform float DEEP_RadiusPixels <
    ui_type = "slider";
    ui_label = "Organic Support Radius";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 32.0; ui_step = 0.01;
    ui_tooltip = "Screen-space radius used to gather organic local tone support.";
> = 2.4;

uniform float DEEP_OrganicFlow <
    ui_type = "slider";
    ui_label = "Organic Support Flow";
    ui_category = DEEP_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Phase drift applied to the organic support direction generation.";
> = 1.25;

uniform float DEEP_TonePivot <
    ui_type = "slider";
    ui_label = "Tone Pivot";
    ui_category = DEEP_CAT_TONE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Luminance pivot where deep-tone shaping is strongest.";
> = 0.369;

uniform float DEEP_ToneWidth <
    ui_type = "slider";
    ui_label = "Tone Width";
    ui_category = DEEP_CAT_TONE; ui_category_closed = true;
    ui_min = 0.01; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Width of the tonal region emphasized around the tone pivot.";
> = 0.314;

uniform float DEEP_LocalContrast <
    ui_type = "slider";
    ui_label = "Local Tone Contrast";
    ui_category = DEEP_CAT_TONE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Weight of immediate local tone contrast when shaping luminance.";
> = 2.631;

uniform float DEEP_ShadowLift <
    ui_type = "slider";
    ui_label = "Shadow Lift Protection";
    ui_category = DEEP_CAT_TONE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Reduces excessive darkening in deep shadows by protecting the darkest tones.";
> = 0.348;

uniform float DEEP_HighlightCompression <
    ui_type = "slider";
    ui_label = "Highlight Compression";
    ui_category = DEEP_CAT_TONE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Restrains over-expansion in highlights so deep tone does not become highlight lift.";
> = 0.660;

uniform float DEEP_DepthGate <
    ui_type = "slider";
    ui_label = "Depth Stability Gate";
    ui_category = DEEP_CAT_TONE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Suppresses deep-tone shaping when local depth is unstable.";
> = 0.650;

uniform int DEEP_MaskMode <
    ui_type = "combo";
    ui_label = "Selected Mask Field";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Depth Window\0Far Detail Stack\0Contrast\0Composite Guard\0";
    ui_tooltip = "Selects the Crystal-derived field used to gate deep-tone application.";
> = 6;

uniform float DEEP_MaskInfluence <
    ui_type = "slider";
    ui_label = "Mask Influence";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly the selected mask field influences the final deep-tone application gate.";
> = 0.40;

uniform float DEEP_FogInfluence <
    ui_type = "slider";
    ui_label = "Fog Evidence Influence";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly fog-like regions reduce deep-tone application.";
> = 0.35;

uniform int DEEP_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Interpretation Mode";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_items = "ReShade Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Controls how the depth buffer is interpreted by the Crystal-derived gating logic.";
> = 0;

uniform int DEEP_DepthInvert <
    ui_type = "combo";
    ui_label = "Invert Depth";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts depth interpretation for reversed depth buffers.";
> = 0;

uniform float DEEP_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies small depth differences before depth-driven masks are evaluated.";
> = 256.0;

uniform float DEEP_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Confidence Threshold";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.05; ui_step = 0.00001;
    ui_tooltip = "Minimum local depth activity needed before depth-driven masks trust the buffer.";
> = 0.001;

uniform float DEEP_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Window Start";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the depth window mask.";
> = 0.0;

uniform float DEEP_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth Window End";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary of the depth window mask.";
> = 1.0;

uniform float DEEP_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.05; ui_step = 0.0001;
    ui_tooltip = "Depth discontinuity threshold used by depth-derived gating logic.";
> = 0.003;

uniform float DEEP_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary where the far-detail mask begins to activate.";
> = 0.45;

uniform float DEEP_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Boundary where the far-detail mask reaches full strength.";
> = 0.75;

uniform float DEEP_DetailLow <
    ui_type = "slider";
    ui_label = "Detail Threshold Low";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.5; ui_step = 0.0001;
    ui_tooltip = "Low threshold of the detail detector used by the far-detail mask.";
> = 0.035;

uniform float DEEP_DetailHigh <
    ui_type = "slider";
    ui_label = "Detail Threshold High";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "High threshold of the detail detector used by the far-detail mask.";
> = 0.120;

uniform float DEEP_DetailScale <
    ui_type = "slider";
    ui_label = "Detail Scale";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.1; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Scales the detail detector used by the far-detail mask.";
> = 1.0;

uniform float DEEP_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Threshold used by the contrast-derived mask field.";
> = 0.06;

uniform float DEEP_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.1; ui_max = 8.0; ui_step = 0.001;
    ui_tooltip = "Gain applied to the local-contrast detector before the contrast mask is formed.";
> = 2.0;

uniform float DEEP_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1; ui_step = 0.0001;
    ui_tooltip = "Minimum scene brightness before fog evidence begins to register.";
> = 0.004;

uniform float DEEP_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation Floor";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How colorless a region must be before fog evidence rises.";
> = 0.18;

uniform float DEEP_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast Ceiling";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Upper contrast ceiling used by the fog evidence detector.";
> = 0.04;

uniform float DEEP_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness threshold where the light-shield detector starts treating pixels as emissive or highlight-critical.";
> = 0.68;

uniform float DEEP_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Soft transition width for the light-shield detector.";
> = 0.18;

uniform float DEEP_LineThreshold <
    ui_type = "slider";
    ui_label = "Line Threshold";
    ui_category = DEEP_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.001;
    ui_tooltip = "Edge threshold used by line-like structure suppression inside the fog-evidence logic.";
> = 0.018;

#include "../header/BlueSmoke.fxh"

technique BlueSmoke <
    ui_label = "Blue Smoke :: Organic Local Tone Shaping";
    ui_tooltip = "Deepens local tone relationships using organic support averaging, chroma-preserving luminance remap, and Crystal-derived guarded application.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = DEEP_MainPS;
    }
}

