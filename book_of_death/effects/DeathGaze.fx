// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Three-pass ambient occlusion effect with base contact shadowing, broad form shadowing, and superfine crevice darkening.

#include "ReShade.fxh"

#define AO_CAT_DEBUG "Death Gaze / 00 Debug"
#define AO_CAT_MAIN "Death Gaze / 01 Main Settings"
#define AO_CAT_LENS "Death Gaze / 02 Lens Fields and Taps"
#define AO_CAT_BASE "Death Gaze / 03 Base Pass"
#define AO_CAT_BROAD "Death Gaze / 04 Broad Pass"
#define AO_CAT_SUPERFINE "Death Gaze / 05 Superfine Pass"
#define AO_CAT_MASK "Death Gaze / 06 Mask Field and Depth"

uniform int AO_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final Composite\0Base Occlusion\0Broad Occlusion\0Superfine Occlusion\0Combined Occlusion\0Tiled Representative Sampling Field\0Center Representative Sampling Footprint\0Representative Sampling Field Strength\0Tiled Application Field\0Center Application Footprint\0Application Field Strength\0Selected Mask\0Fog Evidence\0Final AO Gate\0";
    ui_tooltip = "Chooses which ambient-occlusion stage to inspect. The first three views show isolated pass outputs, Combined Occlusion shows the merged raw occlusion before darkening, the representative sampling field views show the repeated local lens structure and center-anchored footprint using the strongest active AO sampling pass, Representative Sampling Field Strength shows scalar sampling-field intensity at the current pixel, the application field views show the repeated local placement structure and center-anchored placement footprint, Application Field Strength shows scalar placement-field intensity at the current pixel, Selected Mask shows the raw selected mask result, Fog Evidence shows the atmosphere detector directly, and Final AO Gate shows the fully combined occlusion gate.";
> = 0;

uniform float AO_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 24.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal diagnostics so weak occlusion, lens, and gate fields are easier to inspect. Does not change Final Composite.";
> = 1.0;

uniform float AO_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 0.65;

uniform float AO_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float AO_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float AO_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int AO_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float AO_DebugShape(float value)
{
    float debugLow = min(AO_DebugBlackPoint, AO_DebugWhitePoint - 0.0001);
    float debugHigh = max(AO_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, AO_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, AO_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, AO_DebugGamma));
    if (AO_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 AO_DebugShape3(float3 value)
{
    return float3(AO_DebugShape(value.r), AO_DebugShape(value.g), AO_DebugShape(value.b));
}


uniform float AO_DebugPatternScale <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales the tiled debug field views only. This does not change the real ambient occlusion radius.";
> = 0.24;

uniform float AO_DebugPatternTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the debug field layout across the screen. This is only for reading spacing and rotation.";
> = 4.0;

uniform float AO_DebugMarkerSize <
    ui_type = "slider";
    ui_label = "Debug Marker Size";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Controls how large each tap marker appears in the debug field and footprint views. This does not change the real sample size.";
> = 0.016;

uniform float AO_DebugPatternSoftness <
    ui_type = "slider";
    ui_label = "Debug Pattern Softness";
    ui_category = AO_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens debug marker edges and guide rings. This is a readability control for debug only.";
> = 0.012;

uniform int AO_Enable <
    ui_type = "combo";
    ui_label = "Enable Ambient Occlusion Effect";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the three-pass ambient-occlusion stack. Off returns the source image unchanged.";
> = 1;

uniform int AO_EnableBase <
    ui_type = "combo";
    ui_label = "Enable Base Occlusion Pass";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the small-radius base occlusion pass. This is the primary contact and cavity layer.";
> = 1;

uniform int AO_EnableBroad <
    ui_type = "combo";
    ui_label = "Enable Broad Occlusion Pass";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the broad-radius occlusion pass. This adds larger-form grounding and distance-weighted structure.";
> = 1;

uniform int AO_EnableSuperfine <
    ui_type = "combo";
    ui_label = "Enable Superfine Occlusion Pass";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the superfine micro-occlusion pass. This concentrates on tiny creases and local structure without carrying the whole shadow load.";
> = 1;

uniform float AO_MasterIntensity <
    ui_type = "slider";
    ui_label = "Master Intensity";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Overall strength multiplier for the final AO darkening after all three passes and placement gating are combined.";
> = 1.0;

uniform int AO_SamplingLensMode <
    ui_type = "combo";
    ui_label = "Sampling Field Lens Family";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived lens family used to gather occlusion samples for all three passes.";
> = 3;

uniform int AO_ApplicationLensMode <
    ui_type = "combo";
    ui_label = "Application Field Lens Family";
    ui_category = AO_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the Obsidian Mirror-derived lens field used to shape where the final AO is allowed to land.";
> = 8;

uniform int AO_QualityTier <
    ui_type = "combo";
    ui_label = "Quality Tier";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_items = "Disciplined 9\0Broad 21\0High 34\0Ultra 55\0";
    ui_tooltip = "Caps pass tap budgets before each pass resolves its own active count. Higher tiers keep more of the high-quality tap field alive.";
> = 2;

uniform int AO_ReductionMode <
    ui_type = "combo";
    ui_label = "Reduction Mode";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "Sequential consumes the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so lower budgets stay spatially balanced.";
> = 1;

uniform float AO_FieldScale <
    ui_type = "slider";
    ui_label = "Field Scale";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Scales the underlying Obsidian Mirror lens constellation before it is converted into pixel-space sampling offsets for the real AO field.";
> = 1.0;

uniform float AO_FieldRotation <
    ui_type = "slider";
    ui_label = "Field Rotation";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the active lens field in the real AO sampling and application paths. This mostly affects directional or anisotropic families like the rectangular and diamond shapes.";
> = 0.0;

uniform float AO_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the golden-angle phase used by the Fibonacci-derived tap families. Changing it re-phases the sample ordering without changing tap count.";
> = 2584.0;

uniform int AO_ApplicationTapBudget <
    ui_type = "slider";
    ui_label = "Application Field Tap Budget";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the application lens field before quality-tier and family-size clamping are applied. This changes the real placement field, not just debug, and does not affect sampling.";
> = 21;

uniform float AO_ApplicationRadiusPixels <
    ui_type = "slider";
    ui_label = "Application Field Radius";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius used to evaluate the application lens field in the real AO output. Larger values make the placement field respond to broader neighborhood structure.";
> = 2.6;

uniform float AO_ApplicationLensStrength <
    ui_type = "slider";
    ui_label = "Application Lens Strength";
    ui_category = AO_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly the application lens field modulates where the final ambient occlusion is allowed to land.";
> = 0.9;

uniform int AO_BaseTapBudget <
    ui_type = "slider";
    ui_label = "Base Tap Budget";
    ui_category = AO_CAT_BASE; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the base pass before quality-tier and family-size clamping are applied.";
> = 13;

uniform float AO_BaseRadiusPixels <
    ui_type = "slider";
    ui_label = "Base Radius";
    ui_category = AO_CAT_BASE; ui_category_closed = true;
    ui_min = 0.25; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the base pass. Smaller values stay close to contact edges and creases.";
> = 1.2;

uniform float AO_BaseStrength <
    ui_type = "slider";
    ui_label = "Base Strength";
    ui_category = AO_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Strength of the base occlusion pass. Higher values deepen contact shadows and small cavities.";
> = 1.0;

uniform float AO_BaseRejectStart <
    ui_type = "slider";
    ui_label = "Base Reject Start";
    ui_category = AO_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Beginning of the depth delta ramp that starts counting neighboring geometry as occluding for the base pass.";
> = 0.003;

uniform float AO_BaseRejectEnd <
    ui_type = "slider";
    ui_label = "Base Reject End";
    ui_category = AO_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.4; ui_step = 0.0001;
    ui_tooltip = "Depth delta where the base pass reaches full occlusion response. Lower values make the pass tighter and more crease-focused.";
> = 0.022;

uniform int AO_BroadTapBudget <
    ui_type = "slider";
    ui_label = "Broad Tap Budget";
    ui_category = AO_CAT_BROAD; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the broad pass before quality-tier and family-size clamping are applied.";
> = 34;

uniform float AO_BroadRadiusPixels <
    ui_type = "slider";
    ui_label = "Broad Radius";
    ui_category = AO_CAT_BROAD; ui_category_closed = true;
    ui_min = 0.25; ui_max = 24.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the broad pass. Larger values push the effect into larger-form grounding and wider ambient shaping.";
> = 6.5;

uniform float AO_BroadStrength <
    ui_type = "slider";
    ui_label = "Broad Strength";
    ui_category = AO_CAT_BROAD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Strength of the broad occlusion pass. Higher values add more large-scale grounding and scene mass.";
> = 0.8;

uniform float AO_BroadRejectStart <
    ui_type = "slider";
    ui_label = "Broad Reject Start";
    ui_category = AO_CAT_BROAD; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Beginning of the broad-pass depth delta ramp. Lower values make the pass respond to subtler depth enclosure.";
> = 0.004;

uniform float AO_BroadRejectEnd <
    ui_type = "slider";
    ui_label = "Broad Reject End";
    ui_category = AO_CAT_BROAD; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.4; ui_step = 0.0001;
    ui_tooltip = "Depth delta where the broad pass reaches full occlusion response. Higher values tolerate more variation before the pass saturates.";
> = 0.035;

uniform float AO_BroadDistanceFalloff <
    ui_type = "slider";
    ui_label = "Broad Distance Falloff";
    ui_category = AO_CAT_BROAD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "How quickly far taps lose influence in the broad pass. Lower values keep the pass more evenly distributed across the radius.";
> = 1.2;

uniform int AO_SuperfineTapBudget <
    ui_type = "slider";
    ui_label = "Superfine Tap Budget";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Requested tap count for the superfine pass before quality-tier and family-size clamping are applied.";
> = 9;

uniform float AO_SuperfineRadiusPixels <
    ui_type = "slider";
    ui_label = "Superfine Radius";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.10; ui_max = 4.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius of the superfine pass. Smaller values concentrate on tiny creases and local micro-structure.";
> = 0.55;

uniform float AO_SuperfineStrength <
    ui_type = "slider";
    ui_label = "Superfine Strength";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Strength of the superfine pass. Higher values deepen micro-cavities and fine structure without changing the broader shape.";
> = 0.65;

uniform float AO_SuperfineRejectStart <
    ui_type = "slider";
    ui_label = "Superfine Reject Start";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Beginning of the superfine depth delta ramp. Lower values make tiny depth changes register earlier.";
> = 0.0015;

uniform float AO_SuperfineRejectEnd <
    ui_type = "slider";
    ui_label = "Superfine Reject End";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Depth delta where the superfine pass reaches full occlusion response. Lower values keep it tighter and more surgical.";
> = 0.012;

uniform float AO_SuperfineContrastThreshold <
    ui_type = "slider";
    ui_label = "Superfine Contrast Threshold";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.0001;
    ui_tooltip = "Minimum local contrast needed before the superfine pass fully trusts a tiny occlusion signal. Raise it to avoid broad low-detail darkening.";
> = 0.018;

uniform float AO_SuperfineContrastGain <
    ui_type = "slider";
    ui_label = "Superfine Contrast Gain";
    ui_category = AO_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Amplifies local contrast before it modulates the superfine pass. Higher values make the pass cling more strongly to sharp local detail.";
> = 2.2;

uniform int AO_MaskMode <
    ui_type = "combo";
    ui_label = "Selected Mask Field";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Depth Window\0Far Detail Stack\0Contrast\0Composite Guard\0";
    ui_tooltip = "Selects the Crystal Mass-derived field used to shape where ambient occlusion is allowed to land. Composite Guard combines depth, contrast, distance, and protection behavior into a broader placement guide.";
> = 6;

uniform float AO_MaskInfluence <
    ui_type = "slider";
    ui_label = "Mask Influence";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between ungated occlusion and the selected mask field. Lower values expose the raw pass structure; higher values enforce the mask more strongly.";
> = 0.65;

uniform float AO_MaskStrength <
    ui_type = "slider";
    ui_label = "Mask Strength";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Scales the selected mask field before it is blended into the final AO gate.";
> = 1.0;

uniform int AO_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_items = "Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Chooses how depth is interpreted before the three AO passes and the Crystal Mass-derived guards evaluate the scene.";
> = 0;

uniform int AO_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts near and far interpretation for reversed depth buffers or alternative depth conventions.";
> = 0;

uniform float AO_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies small depth differences before availability, edge, and reject logic are evaluated. Raise it when valid depth exists but the occlusion passes are too faint.";
> = 256.0;

uniform float AO_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Availability Threshold";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.05; ui_step = 0.00001;
    ui_tooltip = "Minimum local depth activity required before depth-aware filters fully trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal.";
> = 0.001;

uniform float AO_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.05; ui_step = 0.0001;
    ui_tooltip = "Threshold used by the depth-discontinuity logic. Lower values catch more silhouette changes; higher values reserve the signal for stronger breaks.";
> = 0.003;

uniform float AO_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Start";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the generic depth window used by the depth and composite masks.";
> = 0.08;

uniform float AO_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth End";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary of the generic depth window used by the depth and composite masks.";
> = 1.0;

uniform float AO_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Beginning of the far-distance range used by the far-detail and composite masks.";
> = 0.40;

uniform float AO_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Point where far-distance qualification reaches full strength for the far-detail and composite masks.";
> = 0.78;

uniform float AO_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1; ui_step = 0.0001;
    ui_tooltip = "Minimum brightness before the fog evidence branch begins to react. Raise it to ignore dim haze and focus on brighter atmosphere.";
> = 0.004;

uniform float AO_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How colorless a region should be before fog evidence strengthens. Higher values focus more tightly on neutral mist and haze.";
> = 0.18;

uniform float AO_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Local-contrast threshold used by the fog evidence branch. Lower values make fog detection more selective; higher values allow flatter structure to qualify more easily.";
> = 0.04;

uniform float AO_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness threshold used by the light-protection branch. Lower values protect more highlights and emissive accents.";
> = 0.68;

uniform float AO_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Transition width of the light-protection branch. Higher values broaden highlight protection instead of clipping it abruptly.";
> = 0.18;

uniform float AO_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.0001;
    ui_tooltip = "Minimum local contrast required before the contrast branch qualifies. Lower values catch more texture; higher values reserve the field for clearer structure.";
> = 0.02;

uniform float AO_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = AO_CAT_MASK; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Gain applied to the local contrast probe before thresholding. Raise it when structurally correct contrast fields are too faint to be useful.";
> = 2.0;

#include "../header/DeathGaze.fxh"

technique DeathGaze < ui_label = "Death Gaze :: Three Pass Ambient Occlusion"; ui_tooltip = "Darkens the image with three occlusion layers: contact shadows, broad grounding shadows, and superfine crevice shadows."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = AO_MainPS;
    }
}

