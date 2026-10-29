// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Image mask server for mining fog, light, and protection-style masks without restoring the old full mask stack.

#include "ReShade.fxh"

#define CRYSTAL_CAT_DEBUG "Crystal Mass / 00 Debug"
#define CRYSTAL_CAT_MAIN "Crystal Mass / 01 Main Settings"
#define CRYSTAL_CAT_SUB "Crystal Mass / 02 Field Controls and Gates"
#define CRYSTAL_CAT_DEBUG_BRANCH "Crystal Mass / 03 Debug Branch Controls"

uniform int CRYSTAL_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final (Passthrough)\0Selected Mask\0Branch Direct Field\0Composite Guard\0Shaped Linear Depth\0Depth Confidence\0Depth Discontinuity\0Masked Preview\0";
    ui_tooltip = "Chooses which mask stage to inspect. Selected Mask shows the final result of the current Selected Mask Field, Branch Direct Field shows the raw branch signal behind the current selection, Composite Guard shows the broader combined protection field, the three depth diagnostics validate the depth feed, and Masked Preview shows the selected mask applied over the image.";
> = 0;

uniform float CRYSTAL_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal mask diagnostics so weak protection fields are easier to inspect. Does not affect passthrough output.";
> = 1.0;

uniform float CRYSTAL_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 1.00;

uniform float CRYSTAL_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float CRYSTAL_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float CRYSTAL_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int CRYSTAL_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = CRYSTAL_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float CRYSTAL_DebugShape(float value)
{
    float debugLow = min(CRYSTAL_DebugBlackPoint, CRYSTAL_DebugWhitePoint - 0.0001);
    float debugHigh = max(CRYSTAL_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, CRYSTAL_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, CRYSTAL_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, CRYSTAL_DebugGamma));
    if (CRYSTAL_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 CRYSTAL_DebugShape3(float3 value)
{
    return float3(CRYSTAL_DebugShape(value.r), CRYSTAL_DebugShape(value.g), CRYSTAL_DebugShape(value.b));
}


uniform int CRYSTAL_CompositeDebugBranch <
    ui_type = "combo";
    ui_label = "Composite Debug Branch";
    ui_category = CRYSTAL_CAT_DEBUG_BRANCH; ui_category_closed = true;
    ui_items = "Fog Evidence\0Light Shield\0Line Guard\0Pixel Guard\0Depth Window\0Far Detail Stack\0Contrast\0Hue Warm\0Directional\0Silhouette Guard\0";
    ui_tooltip = "When Selected Mask Field is Composite Guard, Branch Direct Field uses this control to choose which underlying component branch to show directly.";
> = 0;

uniform int CRYSTAL_Enable <
    ui_type = "combo";
    ui_label = "Enable Mask Output Effect";
    ui_category = CRYSTAL_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the mined image-mask modes. Off keeps the module in passthrough-only mode.";
> = 1;

uniform int CRYSTAL_MaskMode <
    ui_type = "combo";
    ui_label = "Selected Mask Field";
    ui_category = CRYSTAL_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Line Guard\0Pixel Guard\0Depth Window\0Far Detail Stack\0Foreground Guard\0Contrast\0Hue Warm\0Directional\0Silhouette Guard\0Composite Guard\0";
    ui_tooltip = "Selects the active mined mask family. The compact gates cover contrast selection, warm-hue selection, directional support, and silhouette protection, while Composite Guard folds them into the broader protection field.";
 > = 12;

uniform float CRYSTAL_MaskStrength <
    ui_type = "slider";
    ui_label = "Mask Strength";
    ui_category = CRYSTAL_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Scales the intensity of the active mined mask in the real image, not just the debug views. Higher values make weak fields apply more strongly and also easier to inspect.";
> = 1.0;

uniform float CRYSTAL_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1; ui_step = 0.0001;
    ui_tooltip = "Minimum scene brightness before fog evidence begins to register. Raising it restricts fog detection to brighter haze and mist.";
> = 0.004;

uniform float CRYSTAL_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How colorless a region must be before fog evidence increases. Higher values focus the mask on neutral fog rather than tinted atmosphere.";
> = 0.18;

uniform float CRYSTAL_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Local contrast threshold used by the fog evidence mask. Lower values make the fog gate more selective; higher values let flatter regions qualify more easily.";
> = 0.04;

uniform float CRYSTAL_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness threshold where the light shield starts to treat pixels as emissive or highlight-critical.";
> = 0.68;

uniform float CRYSTAL_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Soft transition width for the light shield. Larger values broaden the highlight protection ramp instead of clipping abruptly.";
> = 0.18;

uniform float CRYSTAL_LineThreshold <
    ui_type = "slider";
    ui_label = "Line Threshold";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.001;
    ui_tooltip = "Gradient threshold where the line guard begins to register. Lower values catch more fine structure; higher values focus on stronger edges.";
> = 0.018;

uniform float CRYSTAL_PixelThreshold <
    ui_type = "slider";
    ui_label = "Pixel Threshold";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Brightness threshold used by the pixel guard. Lower values catch more bright micro-pixels; higher values isolate only the hottest points.";
> = 0.7;

uniform float CRYSTAL_PixelSaturation <
    ui_type = "slider";
    ui_label = "Pixel Saturation";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Saturation threshold used by the pixel guard. This helps protect very colorful hot pixels and emissive accents.";
> = 0.25;

uniform float CRYSTAL_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Start";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the generic depth window. This also helps define the near-side region protected by Foreground Guard and Far Detail Stack.";
> = 0.0;

uniform float CRYSTAL_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth End";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary of the generic depth window. Together with Depth Start, this also defines how far the near-side foreground protection extends.";
> = 1.0;

uniform float CRYSTAL_ForegroundNearStart <
    ui_type = "slider";
    ui_label = "Foreground Near Start";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary used specifically by Foreground Guard. Lower values reserve protection for the closest geometry only; higher values let more mid-depth objects count as foreground.";
> = 0.0;

uniform float CRYSTAL_ForegroundNearEnd <
    ui_type = "slider";
    ui_label = "Foreground Near End";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary used specifically by Foreground Guard. This decouples foreground protection from the generic Depth Window so both can be tuned independently.";
> = 0.35;

uniform int CRYSTAL_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts near and far interpretation for reversed depth buffers or alternative depth conventions.";
> = 0;

uniform int CRYSTAL_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_items = "Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Chooses how depth is interpreted before the mined depth-aware masks are evaluated. Switch this when the depth views look flat or reversed.";
> = 0;

uniform float CRYSTAL_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies small depth differences before depth availability, depth edge, and far-detail gating are evaluated. Raise it when the scene has valid depth but the detail and guard masks are too faint.";
> = 256.0;

uniform float CRYSTAL_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Availability Threshold";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.05; ui_step = 0.00001;
    ui_tooltip = "Minimum local depth activity needed before the depth-aware masks trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal.";
> = 0.001;

uniform float CRYSTAL_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.05; ui_step = 0.0001;
    ui_tooltip = "Depth discontinuity threshold for the foreground guard and far-detail stack. Lower values catch more silhouette edges; higher values reserve the guard for stronger breaks.";
> = 0.003;

uniform float CRYSTAL_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the far-detail region. Pixels beyond this point begin to qualify for the far-detail stack.";
> = 0.45;

uniform float CRYSTAL_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Full-strength boundary of the far-detail region. Raising it pushes the stack deeper into the scene; lowering it brings detail gating closer.";
> = 0.75;

uniform float CRYSTAL_DetailLow <
    ui_type = "slider";
    ui_label = "Detail Low";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.5; ui_step = 0.0001;
    ui_tooltip = "Lower threshold for the lens-contrast detail test used by the far-detail stack. Lower values allow weaker texture variation to qualify.";
> = 0.035;

uniform float CRYSTAL_DetailHigh <
    ui_type = "slider";
    ui_label = "Detail High";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Upper threshold for the lens-contrast detail test. Higher values make the far-detail stack more selective about what counts as preserved structure.";
> = 0.11;

uniform float CRYSTAL_DetailScale <
    ui_type = "slider";
    ui_label = "Detail Scale";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Gain applied to the ring and spiral contrast probes before thresholding. Raise it when detail masks are structurally correct but too weak.";
> = 2.4;

uniform float CRYSTAL_ForegroundNearStrength <
    ui_type = "slider";
    ui_label = "Foreground Near Strength";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly near-depth pixels block the far-detail stack. Higher values more aggressively preserve foreground subjects.";
> = 1.0;

uniform float CRYSTAL_ForegroundEdgeStrength <
    ui_type = "slider";
    ui_label = "Foreground Edge Strength";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly depth silhouettes block the far-detail stack. Higher values carve out more of the foreground outline from distant detail gating.";
> = 1.0;

uniform float CRYSTAL_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.0001;
    ui_tooltip = "Minimum local luminance variation required before the Contrast mask turns on. Lower values catch more texture and edges; higher values reserve the mask for stronger structural change.";
> = 0.02;

uniform float CRYSTAL_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Amplifies local contrast before thresholding. Raise it when the mask is conceptually correct but too faint to separate useful structure from the surrounding image.";
> = 2.0;

uniform float CRYSTAL_HueWarmWidth <
    ui_type = "slider";
    ui_label = "Hue Warm Width";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.02; ui_max = 0.35; ui_step = 0.001;
    ui_tooltip = "Hue-wheel width of the warm gate. Lower values isolate a tighter warm band; higher values include more orange, red, and gold-adjacent hues.";
> = 0.10;

uniform float CRYSTAL_DirectionalAngle <
    ui_type = "slider";
    ui_label = "Directional Angle";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Primary angle used by the directional gate. Rotate it to align the mask with the dominant scene direction you want to favor.";
> = 35.0;

uniform float CRYSTAL_DirectionalSoftness <
    ui_type = "slider";
    ui_label = "Directional Softness";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Softness of the directional gate. Lower values make the selected direction narrow and strict; higher values broaden acceptance around the chosen angle.";
> = 0.25;

uniform float CRYSTAL_SilhouetteStrength <
    ui_type = "slider";
    ui_label = "Silhouette Strength";
    ui_category = CRYSTAL_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Scales how strongly depth-edge silhouettes register in the silhouette guard. Raise it to favor stronger cutout protection around subject outlines.";
> = 1.0;

#include "../header/CrystalMass.fxh"

technique CrystalMass < ui_label = "Crystal Mass :: Image Mask And Protection Server"; ui_tooltip = "Displays and applies image masks for fog-like regions, highlights, depth ranges, contrast, hue, direction, silhouettes, and combined protection behavior."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = CRYSTAL_MainPS;
    }
}

