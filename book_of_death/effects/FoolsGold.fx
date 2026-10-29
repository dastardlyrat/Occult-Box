// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Three-pass screen-space reflection effect with highlight reflections, base reflections, and broad gloss reflections.

#include "ReShade.fxh"

#define SSR_CAT_DEBUG "Fools Gold / 00 Debug"
#define SSR_CAT_MAIN "Fools Gold / 01 Main Settings"
#define SSR_CAT_LENS "Fools Gold / 02 Lens Fields and Taps"
#define SSR_CAT_HIGHLIGHT "Fools Gold / 03 Highlight Pass"
#define SSR_CAT_BASE "Fools Gold / 04 Base Pass"
#define SSR_CAT_GLOSS "Fools Gold / 05 Gloss Pass"
#define SSR_CAT_MASK "Fools Gold / 06 Mask Field and Depth"

uniform int SSR_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final Composite\0Highlight Reflection\0Base Reflection\0Gloss Reflection\0Combined Reflection\0Reflection Direction\0Tiled Representative Sampling Field\0Center Representative Sampling Footprint\0Representative Sampling Field Strength\0Tiled Application Field\0Center Application Footprint\0Application Field Strength\0Selected Mask\0Fog Evidence\0Final Reflection Gate\0";
    ui_tooltip = "Chooses which reflection stage to inspect. The three pass views show isolated reflection color, Combined Reflection shows the merged raw reflection before compositing, Reflection Direction shows the current screen-space reflection direction, the representative sampling field views show the repeated local lens structure and center-anchored footprint using the strongest active reflection sampling pass, Representative Sampling Field Strength shows scalar sampling-field intensity at the current pixel, the application field views show the repeated local placement structure and center-anchored placement footprint, Application Field Strength shows scalar placement-field intensity at the current pixel, Selected Mask shows the raw selected mask result, Fog Evidence exposes the atmosphere detector directly, and Final Reflection Gate shows the fully combined placement gate.";
> = 0;

uniform float SSR_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal reflection diagnostics so subtle reflected color, gates, and direction fields are easier to inspect. Does not change Final Composite.";
> = 1.0;

uniform float SSR_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.65;

uniform float SSR_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float SSR_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float SSR_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int SSR_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float SSR_DebugShape(float value)
{
    float debugLow = min(SSR_DebugBlackPoint, SSR_DebugWhitePoint - 0.0001);
    float debugHigh = max(SSR_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, SSR_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, SSR_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, SSR_DebugGamma));
    if (SSR_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 SSR_DebugShape3(float3 value)
{
    return float3(SSR_DebugShape(value.r), SSR_DebugShape(value.g), SSR_DebugShape(value.b));
}


uniform float SSR_DebugPatternScale <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales the tiled debug field views only. This does not change the real reflection radius.";
> = 0.24;

uniform float SSR_DebugPatternTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the debug field layout across the screen. This is only for reading spacing and rotation.";
> = 4.0;

uniform float SSR_DebugMarkerSize <
    ui_type = "slider";
    ui_label = "Debug Marker Size";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Controls how large each tap marker appears in the debug field and footprint views. This does not change the real sample size.";
> = 0.016;

uniform float SSR_DebugPatternSoftness <
    ui_type = "slider";
    ui_label = "Debug Pattern Softness";
    ui_category = SSR_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens debug marker edges and guide rings. This is a readability control for debug only.";
> = 0.012;

uniform int SSR_Enable <
    ui_type = "combo";
    ui_label = "Enable Reflection Effect";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the three-pass screen-space reflection stack. Off returns the source image unchanged.";
> = 1;

uniform int SSR_EnableHighlight <
    ui_type = "combo";
    ui_label = "Enable Highlight Reflection Pass";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the highlight reflection pass. This favors bright and sharp reflected energy.";
> = 1;

uniform int SSR_EnableBase <
    ui_type = "combo";
    ui_label = "Enable Base Reflection Pass";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the base reflection pass. This is the main body reflection layer.";
> = 1;

uniform int SSR_EnableGloss <
    ui_type = "combo";
    ui_label = "Enable Gloss Reflection Pass";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the gloss reflection pass. This broadens and smooths reflected structure for a softer reflective finish.";
> = 1;

uniform float SSR_MasterIntensity <
    ui_type = "slider";
    ui_label = "Master Intensity";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Overall strength multiplier for the final reflected-light composite after all three passes and placement gating are combined.";
> = 1.0;

uniform int SSR_SamplingLensMode <
    ui_type = "combo";
    ui_label = "Sampling Field Lens Family";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived lens family used to distribute reflection samples around the reflected direction.";
> = 3;

uniform int SSR_ApplicationLensMode <
    ui_type = "combo";
    ui_label = "Application Field Lens Family";
    ui_category = SSR_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived field used to shape where the final reflection is allowed to land.";
> = 8;

uniform int SSR_QualityTier <
    ui_type = "combo";
    ui_label = "Quality Tier";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_items = "Disciplined 9\0Broad 21\0High 34\0Ultra 55\0";
    ui_tooltip = "Caps pass tap budgets before each pass resolves its own active count. Higher tiers keep more of the high-quality tap field alive.";
> = 2;

uniform int SSR_ReductionMode <
    ui_type = "combo";
    ui_label = "Reduction Mode";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "Sequential consumes the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so lower budgets stay spatially balanced.";
> = 1;

uniform float SSR_FieldScale <
    ui_type = "slider";
    ui_label = "Field Scale";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Scales the underlying Obsidian Mirror lens constellation before it is converted into pixel-space reflection offsets for the real SSR image.";
> = 1.0;

uniform float SSR_FieldRotation <
    ui_type = "slider";
    ui_label = "Field Rotation";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the active lens field in the real SSR sampling and placement paths. This mainly affects directional and anisotropic lens families such as the rectangular and diamond variants.";
> = 0.0;

uniform float SSR_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the golden-angle phase used by the Fibonacci-derived tap families. Changing it re-phases sample ordering without changing tap count.";
> = 2584.0;

uniform int SSR_ApplicationTapBudget <
    ui_type = "slider";
    ui_label = "Application Field Tap Budget";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the application lens field before quality-tier and family-size clamping are applied. This changes the real placement field, not just debug, and does not affect reflection sampling.";
> = 21;

uniform float SSR_ApplicationRadiusPixels <
    ui_type = "slider";
    ui_label = "Application Field Radius";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius used to evaluate the application lens field in the real SSR output. Larger values make the placement field respond to broader neighborhood structure.";
> = 2.6;

uniform float SSR_ApplicationLensStrength <
    ui_type = "slider";
    ui_label = "Application Lens Strength";
    ui_category = SSR_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly the application lens field modulates where the final reflection is allowed to land.";
> = 0.9;

uniform int SSR_HighlightTapBudget <
    ui_type = "slider";
    ui_label = "Highlight Tap Budget";
    ui_category = SSR_CAT_HIGHLIGHT; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the highlight pass before quality-tier and family-size clamping are applied.";
> = 9;

uniform float SSR_HighlightRadiusPixels <
    ui_type = "slider";
    ui_label = "Highlight Radius";
    ui_category = SSR_CAT_HIGHLIGHT; ui_category_closed = true;
    ui_min = 0.25; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the highlight reflection pass. Smaller values keep highlights tight and sharp.";
> = 1.1;

uniform float SSR_HighlightStrength <
    ui_type = "slider";
    ui_label = "Highlight Strength";
    ui_category = SSR_CAT_HIGHLIGHT; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Strength of the highlight reflection pass. Higher values emphasize bright reflected peaks and specular accents.";
> = 0.85;

uniform float SSR_HighlightBrightStart <
    ui_type = "slider";
    ui_label = "Highlight Bright Start";
    ui_category = SSR_CAT_HIGHLIGHT; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness where samples begin to qualify strongly for the highlight pass.";
> = 0.55;

uniform float SSR_HighlightBrightEnd <
    ui_type = "slider";
    ui_label = "Highlight Bright End";
    ui_category = SSR_CAT_HIGHLIGHT; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Brightness where the highlight pass reaches full reflective emphasis.";
> = 0.95;

uniform int SSR_BaseTapBudget <
    ui_type = "slider";
    ui_label = "Base Tap Budget";
    ui_category = SSR_CAT_BASE; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the base reflection pass before quality-tier and family-size clamping are applied.";
> = 21;

uniform float SSR_BaseRadiusPixels <
    ui_type = "slider";
    ui_label = "Base Radius";
    ui_category = SSR_CAT_BASE; ui_category_closed = true;
    ui_min = 0.25; ui_max = 20.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the base reflection pass. Larger values reach farther along the reflection direction.";
> = 4.0;

uniform float SSR_BaseStrength <
    ui_type = "slider";
    ui_label = "Base Strength";
    ui_category = SSR_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Strength of the base reflection pass. This is the main body reflection layer.";
> = 0.70;

uniform float SSR_BaseDepthRejectStart <
    ui_type = "slider";
    ui_label = "Base Reject Start";
    ui_category = SSR_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Beginning of the depth mismatch ramp that starts rejecting off-surface reflected samples for the base pass.";
> = 0.006;

uniform float SSR_BaseDepthRejectEnd <
    ui_type = "slider";
    ui_label = "Base Reject End";
    ui_category = SSR_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.4; ui_step = 0.0001;
    ui_tooltip = "Depth mismatch where the base pass fully rejects reflected samples. Lower values keep it more surface-tight.";
> = 0.030;

uniform float SSR_BaseDistanceFalloff <
    ui_type = "slider";
    ui_label = "Base Distance Falloff";
    ui_category = SSR_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "How quickly far reflected taps lose influence in the base pass. Lower values keep the pass more evenly distributed along the reflection direction.";
> = 1.0;

uniform int SSR_GlossTapBudget <
    ui_type = "slider";
    ui_label = "Gloss Tap Budget";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the gloss pass before quality-tier and family-size clamping are applied.";
> = 34;

uniform float SSR_GlossRadiusPixels <
    ui_type = "slider";
    ui_label = "Gloss Radius";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 28.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the gloss reflection pass. Larger values broaden the reflected field into a smoother glossy response.";
> = 9.0;

uniform float SSR_GlossStrength <
    ui_type = "slider";
    ui_label = "Gloss Strength";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Strength of the gloss reflection pass. Higher values make the broader reflective sheen more visible.";
> = 0.55;

uniform float SSR_GlossDepthRejectStart <
    ui_type = "slider";
    ui_label = "Gloss Reject Start";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Beginning of the depth mismatch ramp for the gloss pass. Lower values make the pass adhere more tightly to the current surface.";
> = 0.008;

uniform float SSR_GlossDepthRejectEnd <
    ui_type = "slider";
    ui_label = "Gloss Reject End";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.4; ui_step = 0.0001;
    ui_tooltip = "Depth mismatch where the gloss pass fully rejects reflected samples. Higher values let the pass stay broader and smoother.";
> = 0.045;

uniform float SSR_GlossDistanceFalloff <
    ui_type = "slider";
    ui_label = "Gloss Distance Falloff";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "How quickly far reflected taps lose influence in the gloss pass. Lower values keep the glossy sheen broad and even.";
> = 0.65;

uniform float SSR_GlossBlend <
    ui_type = "slider";
    ui_label = "Gloss Blend";
    ui_category = SSR_CAT_GLOSS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly the gloss pass blends toward a smoother average reflection instead of preserving sharper reflected detail.";
> = 0.72;

uniform int SSR_MaskMode <
    ui_type = "combo";
    ui_label = "Selected Mask Field";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Depth Window\0Far Detail Stack\0Contrast\0Composite Guard\0";
    ui_tooltip = "Selects the Crystal Mass-derived field used to shape where reflections are allowed to land. Composite Guard combines depth, contrast, distance, and protection behavior into a broader placement guide.";
> = 6;

uniform float SSR_MaskInfluence <
    ui_type = "slider";
    ui_label = "Mask Influence";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between ungated reflections and the selected mask field. Lower values expose the raw pass structure; higher values enforce the placement mask more strongly.";
> = 0.65;

uniform float SSR_MaskStrength <
    ui_type = "slider";
    ui_label = "Mask Strength";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Scales the selected mask field before it is blended into the final reflection gate.";
> = 1.0;

uniform int SSR_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_items = "Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Chooses how depth is interpreted before the three reflection passes and the Crystal Mass-derived guards evaluate the scene.";
> = 0;

uniform int SSR_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts near and far interpretation for reversed depth buffers or alternative depth conventions.";
> = 0;

uniform float SSR_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies small depth differences before availability, edge, and reject logic are evaluated. Raise it when valid depth exists but reflection acceptance is too weak.";
> = 256.0;

uniform float SSR_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Availability Threshold";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.05; ui_step = 0.00001;
    ui_tooltip = "Minimum local depth activity required before depth-aware filters fully trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal.";
> = 0.001;

uniform float SSR_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.05; ui_step = 0.0001;
    ui_tooltip = "Threshold used by the depth-discontinuity logic. Lower values catch more silhouette changes; higher values reserve the signal for stronger breaks.";
> = 0.003;

uniform float SSR_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Start";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the generic depth window used by the depth and composite masks.";
> = 0.08;

uniform float SSR_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth End";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary of the generic depth window used by the depth and composite masks.";
> = 1.0;

uniform float SSR_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Beginning of the far-distance range used by the far-detail and composite masks.";
> = 0.40;

uniform float SSR_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Point where far-distance qualification reaches full strength for the far-detail and composite masks.";
> = 0.78;

uniform float SSR_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1; ui_step = 0.0001;
    ui_tooltip = "Minimum brightness before the fog evidence branch begins to react. Raise it to ignore dim haze and focus on brighter atmosphere.";
> = 0.004;

uniform float SSR_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How colorless a region should be before fog evidence strengthens. Higher values focus more tightly on neutral mist and haze.";
> = 0.18;

uniform float SSR_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Local-contrast threshold used by the fog evidence branch. Lower values make fog detection more selective; higher values allow flatter structure to qualify more easily.";
> = 0.04;

uniform float SSR_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness threshold used by the light-protection branch. Lower values protect more highlights and emissive accents.";
> = 0.68;

uniform float SSR_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Transition width of the light-protection branch. Higher values broaden highlight protection instead of clipping it abruptly.";
> = 0.18;

uniform float SSR_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.0001;
    ui_tooltip = "Minimum local contrast required before the contrast branch qualifies. Lower values catch more texture; higher values reserve the field for clearer structure.";
> = 0.02;

uniform float SSR_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = SSR_CAT_MASK; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Gain applied to the local contrast probe before thresholding. Raise it when structurally correct contrast fields are too faint to be useful.";
> = 2.0;

#include "../header/FoolsGold.fxh"

technique FoolsGold < ui_label = "Fools Gold :: Three Pass Screen Space Reflection"; ui_tooltip = "Builds reflections in three layers: bright highlight reflections, general base reflections, and broad gloss reflections."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = SSR_MainPS;
    }
}

