// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Lens placement and sampling server for bounded Lens55 and Fibonacci-derived image sampling fields.

#include "ReShade.fxh"

#define OBSIDIAN_CAT_DEBUG "Obsidian Mirror / 00 Debug"
#define OBSIDIAN_CAT_MAIN "Obsidian Mirror / 01 Main Settings"
#define OBSIDIAN_CAT_SUB "Obsidian Mirror / 02 Field Controls"
#define OBSIDIAN_CAT_DEBUG_PATTERN "Obsidian Mirror / 03 Debug Pattern Controls"
#define OBSIDIAN_CAT_DEBUG_ANALYSIS "Obsidian Mirror / 04 Debug Analysis Controls"

uniform int OBSIDIAN_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final (Passthrough)\0Tiled Lens Placement Field\0Tiled Tap Index Field\0Center Sample Footprint Overlay\0Tiled Tap Coverage Field\0Analysis Mask\0Analysis Applied Overlay\0Averaged Image\0Difference From Source\0";
    ui_tooltip = "Chooses which lens stage to inspect. Tiled Lens Placement Field shows the repeated debug layout of the active tap set, Tiled Tap Index Field colors taps by active sampling order, Center Sample Footprint Overlay shows the true image-facing sampling footprint anchored at screen center, Tiled Tap Coverage Field shows how support accumulates across the repeated debug layout, Analysis Mask shows a selected spatial diagnostic, Analysis Applied Overlay blends that diagnostic onto the live image, Averaged Image shows the live gathered result, and Difference From Source shows what the current lens changes.";
> = 0;

uniform float OBSIDIAN_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal debug views so sparse tap fields and weak coverage are easier to inspect. Does not change passthrough output.";
> = 1.0;

uniform float OBSIDIAN_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 1.00;

uniform float OBSIDIAN_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float OBSIDIAN_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float OBSIDIAN_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int OBSIDIAN_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = OBSIDIAN_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float OBSIDIAN_DebugShape(float value)
{
    float debugLow = min(OBSIDIAN_DebugBlackPoint, OBSIDIAN_DebugWhitePoint - 0.0001);
    float debugHigh = max(OBSIDIAN_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, OBSIDIAN_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, OBSIDIAN_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, OBSIDIAN_DebugGamma));
    if (OBSIDIAN_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 OBSIDIAN_DebugShape3(float3 value)
{
    return float3(OBSIDIAN_DebugShape(value.r), OBSIDIAN_DebugShape(value.g), OBSIDIAN_DebugShape(value.b));
}


uniform float OBSIDIAN_DebugPatternScale <
    ui_type = "slider";
    ui_label = "Debug Pattern Scale";
    ui_category = OBSIDIAN_CAT_DEBUG_PATTERN; ui_category_closed = true;
    ui_min = 0.05; ui_max = 0.42; ui_step = 0.001;
    ui_tooltip = "Scales the tiled debug layout only. This changes how large the repeated debug lens appears on screen and does not change the real sample radius used for image gathering.";
> = 0.24;

uniform float OBSIDIAN_DebugPatternTiles <
    ui_type = "slider";
    ui_label = "Debug Pattern Tiles";
    ui_category = OBSIDIAN_CAT_DEBUG_PATTERN; ui_category_closed = true;
    ui_min = 1.0; ui_max = 12.0; ui_step = 1.0;
    ui_tooltip = "Repeats the debug lens layout across the screen. This is debug-only and exists to make spacing and rotation easier to judge at a glance.";
> = 4.0;

uniform float OBSIDIAN_DebugMarkerSize <
    ui_type = "slider";
    ui_label = "Debug Marker Size";
    ui_category = OBSIDIAN_CAT_DEBUG_PATTERN; ui_category_closed = true;
    ui_min = 0.004; ui_max = 0.060; ui_step = 0.001;
    ui_tooltip = "Controls how large each debug tap marker appears in the tiled pattern and center footprint overlay. This does not change the real sampling footprint size.";
> = 0.016;

uniform float OBSIDIAN_DebugPatternSoftness <
    ui_type = "slider";
    ui_label = "Debug Pattern Softness";
    ui_category = OBSIDIAN_CAT_DEBUG_PATTERN; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.050; ui_step = 0.001;
    ui_tooltip = "Softens debug marker edges and guide rings. This is a readability control for debug only and does not affect real image sampling.";
> = 0.012;

uniform int OBSIDIAN_AnalysisMode <
    ui_type = "combo";
    ui_label = "Analysis Mode";
    ui_category = OBSIDIAN_CAT_DEBUG_ANALYSIS; ui_category_closed = true;
    ui_items = "Coverage\0Voronoi Cells\0Voronoi Edge\0Radial Order\0Sequence Order\0Gap Heat\0Angular Sector\0";
    ui_tooltip = "Selects which spatial diagnostic Analysis Mask shows. Coverage emphasizes overall support, Voronoi modes show nearest-tap ownership and cell boundaries, Radial and Sequence Order expose ordering behavior, Gap Heat exposes under-supported regions, and Angular Sector shows angular distribution.";
> = 0;

uniform float OBSIDIAN_AnalysisContrast <
    ui_type = "slider";
    ui_label = "Analysis Contrast";
    ui_category = OBSIDIAN_CAT_DEBUG_ANALYSIS; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Raises contrast in analysis views so tap ownership changes, weak coverage, and gap structure are easier to read. This affects debug only.";
> = 2.0;

uniform float OBSIDIAN_AnalysisBlend <
    ui_type = "slider";
    ui_label = "Analysis Blend";
    ui_category = OBSIDIAN_CAT_DEBUG_ANALYSIS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Controls how boldly categorical analysis colors render in Analysis Mask. Lower values soften diagnostic coloring; higher values show stronger category separation.";
> = 1.0;

uniform float OBSIDIAN_AnalysisApplyStrength <
    ui_type = "slider";
    ui_label = "Analysis Apply Strength";
    ui_category = OBSIDIAN_CAT_DEBUG_ANALYSIS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Controls how strongly the selected analysis diagnostic is blended over the live image in Analysis Applied Overlay. This affects debug only.";
> = 0.65;

uniform int OBSIDIAN_Enable <
    ui_type = "combo";
    ui_label = "Enable Lens Sampling Effect";
    ui_category = OBSIDIAN_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the mined lens modes. Off keeps the module in passthrough-only mode.";
> = 1;

uniform int OBSIDIAN_LensMode <
    ui_type = "combo";
    ui_label = "Lens Mode";
    ui_category = OBSIDIAN_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Organic Lens55\0Golden Spiral Sweep\0Staggered Lens55\0Ring9\0Spiral13\0Rect Horizontal15\0Rect Vertical15\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the active mined lens family. The rectangular, diamond, and Box25 fields are mined coverage variants that emphasize horizontal sweep, vertical sweep, diamond-biased spread, or dense square neighborhood support rather than purely organic placement.";
> = 1;

uniform int OBSIDIAN_TapBudget <
    ui_type = "slider";
    ui_label = "Tap Budget";
    ui_category = OBSIDIAN_CAT_MAIN; ui_category_closed = false;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Controls how many taps are active in the current mined lens for the real image, not just the debug view. Each family clamps this to its own canonical size, so Ring9 tops out at 9, Spiral13 and Diamond13 top out at 13, the rectangular fields top out at 15, Box25 tops out at 25, and the Lens55 families top out at 55.";
> = 21;

uniform float OBSIDIAN_SampleRadius <
    ui_type = "slider";
    ui_label = "Sample Radius";
    ui_category = OBSIDIAN_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Controls how far active taps reach in pixel space for the real sampled image output. Larger values spread the lens farther from the center sample.";
> = 2.0;

uniform int OBSIDIAN_ReductionMode <
    ui_type = "combo";
    ui_label = "Reduction Mode";
    ui_category = OBSIDIAN_CAT_SUB; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "Sequential uses the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so lower budgets stay evenly spread instead of bunching near the front of the tap order.";
> = 1;

uniform float OBSIDIAN_FieldScale <
    ui_type = "slider";
    ui_label = "Field Scale";
    ui_category = OBSIDIAN_CAT_SUB; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Scales the geometric spread of the active lens pattern for real sampling, not just debug preview. Larger values widen the lens constellation before it is converted into pixel-space sampling.";
> = 1.0;

uniform float OBSIDIAN_FieldRotation <
    ui_type = "slider";
    ui_label = "Field Rotation";
    ui_category = OBSIDIAN_CAT_SUB; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotates the active lens field for the actual image gather. This changes the orientation of anisotropic or directional tap distributions.";
> = 0.0;

uniform float OBSIDIAN_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = OBSIDIAN_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the golden-angle phase used by the Fibonacci-derived lens modes in the live sampling field. Changing it rotates and re-phases the distribution without altering tap count.";
> = 2584.0;

uniform float OBSIDIAN_AverageMix <
    ui_type = "slider";
    ui_label = "Average Mix";
    ui_category = OBSIDIAN_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends the lens average back toward the source image in Sample Average view. Lower values preserve more of the source; higher values emphasize the aggregate lens sample.";
> = 1.0;

#include "../header/ObsidianMirror.fxh"

technique ObsidianMirror < ui_label = "Obsidian Mirror :: Lens Placement And Sampling Server"; ui_tooltip = "Displays and applies lens placement fields for image sampling, including bounded Lens55, spiral, rectangular, diamond, ring, and square coverage patterns."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = OBSIDIAN_MainPS;
    }
}

