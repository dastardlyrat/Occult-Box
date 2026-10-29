// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Hatch pattern and shading server for procedural bio, five-stage, log-spiral, clarity, stability, and cross-hatch fields.

#include "ReShade.fxh"

#define CROOKED_CAT_DEBUG "Crooked Tongue / 00 Debug"
#define CROOKED_CAT_MAIN "Crooked Tongue / 01 Main Settings"
#define CROOKED_CAT_SUB "Crooked Tongue / 02 Field Controls"

uniform int CROOKED_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final (Passthrough)\0Pattern Field\0Structural Gate Field\0Placement Mask Field\0Final Shading Field\0Applied Shading Preview\0Clarity Delta Field (Adaptive Only)\0Stability Gate (Stability Only)\0";
    ui_tooltip = "Chooses which hatch stage to inspect. Pattern Field shows raw hatch generation before any gating. Structural Gate Field shows the mode-specific structural allowance, such as five-stage depth staging or adaptive clarity tone shaping. Placement Mask Field shows where the shader permits hatch application on the image. Final Shading Field shows the scalar field that is actually applied to darken or enhance the image. Applied Shading Preview shows the resulting image. Clarity Delta Field is meaningful for Adaptive Hatch Clarity, and Stability Gate is meaningful for Stability Hatch.";
> = 0;

uniform float CROOKED_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal hatch diagnostics so weak patterns and masks are easier to inspect. Does not affect passthrough output.";
> = 1.0;

uniform float CROOKED_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 1.00;

uniform float CROOKED_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float CROOKED_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float CROOKED_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int CROOKED_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = CROOKED_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float CROOKED_DebugShape(float value)
{
    float debugLow = min(CROOKED_DebugBlackPoint, CROOKED_DebugWhitePoint - 0.0001);
    float debugHigh = max(CROOKED_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, CROOKED_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, CROOKED_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, CROOKED_DebugGamma));
    if (CROOKED_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 CROOKED_DebugShape3(float3 value)
{
    return float3(CROOKED_DebugShape(value.r), CROOKED_DebugShape(value.g), CROOKED_DebugShape(value.b));
}


uniform int CROOKED_Enable <
    ui_type = "combo";
    ui_label = "Enable Hatch Shading Effect";
    ui_category = CROOKED_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the mined hatch modes. Off keeps the module in passthrough-only mode.";
> = 1;

uniform int CROOKED_HatchMode <
    ui_type = "combo";
    ui_label = "Hatch Mode";
    ui_category = CROOKED_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0Procedural Bio Hatch\0Five-Stage Hatch\0Log Spiral Branch Hatch\0Adaptive Hatch Clarity\0Stability Hatch\0Cross Hatch\0";
    ui_tooltip = "Selects the active mined hatch family. Stability Hatch is a non-temporal branch mined from organic hatch TAA ideas, using depth, luma, and edge rejection to stabilize where hatch is allowed to survive. Cross Hatch adds a disciplined two-angle ink weave that thickens naturally in darker regions.";
> = 1;

uniform float CROOKED_HatchStrength <
    ui_type = "slider";
    ui_label = "Hatch Strength";
    ui_category = CROOKED_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Controls how strongly the active hatch effect influences the source image. For shading modes it darkens and textures the scene; for Adaptive Hatch Clarity it scales hatch-placed clarity emphasis.";
> = 1.0;

uniform int CROOKED_TapBudget <
    ui_type = "slider";
    ui_label = "Tap Budget";
    ui_category = CROOKED_CAT_MAIN; ui_category_closed = false;
    ui_min = 3; ui_max = 34; ui_step = 1;
    ui_tooltip = "Controls how many Lens55 taps contribute to the real hatch field, not just debug preview. Higher values increase pattern richness and directional continuity.";
> = 21;

uniform float CROOKED_PatternScale <
    ui_type = "slider";
    ui_label = "Pattern Scale";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 40.0; ui_max = 1600.0; ui_step = 0.1;
    ui_tooltip = "Controls the UV scale of the real hatch field. Larger values tighten stroke frequency; smaller values broaden it.";
> = 860.0;

uniform float CROOKED_Density <
    ui_type = "slider";
    ui_label = "Density";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.1; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Controls the frequency of the mined procedural hatch lines in the actual image output. Higher values produce denser and more tightly packed stroke structure.";
> = 2.4;

uniform float CROOKED_Flow <
    ui_type = "slider";
    ui_label = "Flow";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6.0; ui_step = 0.001;
    ui_tooltip = "Offsets the directional phase used by the procedural hatch families in the live hatch field. Changing it alters drift and branch motion within the static pattern field.";
> = 3.0;

uniform float CROOKED_TapSpread <
    ui_type = "slider";
    ui_label = "Tap Spread";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 8.0; ui_max = 220.0; ui_step = 0.01;
    ui_tooltip = "Controls how far Lens55 taps are spread through UV space when synthesizing the real procedural hatch field. Larger values increase spatial reach and loosen local repetition.";
> = 120.0;

uniform float CROOKED_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Offsets the Fibonacci phase used by the procedural hatch families in the live hatch field. This changes directional sequencing and branch phasing without changing tap count.";
> = 2584.0;

uniform float CROOKED_SpiralGrowth <
    ui_type = "slider";
    ui_label = "Spiral Growth";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 1.02; ui_max = 1.70; ui_step = 0.001;
    ui_tooltip = "Controls how quickly the log-spiral branch hatch expands as it moves away from the center. Larger values make the branch family flare outward faster.";
> = 1.18;

uniform float CROOKED_SpiralTightness <
    ui_type = "slider";
    ui_label = "Spiral Tightness";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Controls how tightly the log-spiral branch field winds. Higher values produce more turns and denser spiral wrapping.";
> = 1.05;

uniform int CROOKED_BranchCount <
    ui_type = "slider";
    ui_label = "Branch Count";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 2; ui_max = 8; ui_step = 1;
    ui_tooltip = "Controls how many primary arms the log-spiral branch hatch distributes around the center. More branches create denser radial subdivision.";
> = 5;

uniform float CROOKED_BranchBlend <
    ui_type = "slider";
    ui_label = "Branch Blend";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Blends between local Lens55 direction and recursive spiral branch direction in the log-spiral hatch family.";
> = 0.7;

uniform float CROOKED_ClarityRadius <
    ui_type = "slider";
    ui_label = "Clarity Radius";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Pixel radius for the compact clarity kernel used by Adaptive Hatch Clarity. Larger values broaden the local clarity neighborhood and make the effect read less like sharpening and more like structure lift.";
> = 1.1;

uniform float CROOKED_KernelAngle <
    ui_type = "slider";
    ui_label = "Kernel Angle";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = -90.0; ui_max = 90.0; ui_step = 0.1;
    ui_tooltip = "Orientation in degrees for the compact clarity kernel. Rotating it changes the dominant direction of the local clarity probe without rotating the hatch field itself.";
> = 28.0;

uniform float CROOKED_HighlightProtect <
    ui_type = "slider";
    ui_label = "Highlight Protect";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Reduces clarity lift in bright highlights for Adaptive Hatch Clarity. Higher values protect hot pixels and reflective accents from sparkle and halos.";
> = 0.85;

uniform float CROOKED_MidtoneBias <
    ui_type = "slider";
    ui_label = "Midtone Bias";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Biases Adaptive Hatch Clarity toward midtones instead of deep shadows or bright highlights. Higher values concentrate the effect on the body of the image.";
> = 0.65;

uniform float CROOKED_StabilityDepthRejectStart <
    ui_type = "slider";
    ui_label = "Stability Depth Reject Start";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.2; ui_step = 0.0001;
    ui_tooltip = "Smallest depth mismatch that begins suppressing Stability Hatch. Lower values make the hatch more cautious around depth breaks.";
> = 0.01;

uniform float CROOKED_StabilityDepthRejectEnd <
    ui_type = "slider";
    ui_label = "Stability Depth Reject End";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.5; ui_step = 0.0001;
    ui_tooltip = "Depth mismatch where Stability Hatch is fully suppressed. Raise it to tolerate broader local depth variation before the hatch is rejected.";
> = 0.05;

uniform float CROOKED_StabilityLumaResponse <
    ui_type = "slider";
    ui_label = "Stability Luma Response";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 32.0; ui_step = 0.01;
    ui_tooltip = "How strongly local luma disagreement suppresses Stability Hatch. Higher values favor cleaner, more selective hatch persistence.";
> = 8.0;

uniform float CROOKED_StabilityEdgeInfluence <
    ui_type = "slider";
    ui_label = "Stability Edge Influence";
    ui_category = CROOKED_CAT_SUB; ui_category_closed = true;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "How strongly edge activity suppresses Stability Hatch. Raise it to keep hatching off unstable or rapidly changing contours.";
> = 1.0;

#include "../header/CrookedTongue.fxh"

technique CrookedTongue < ui_label = "Crooked Tongue :: Hatch Pattern And Shading Server"; ui_tooltip = "Displays and applies hatch pattern fields, shading masks, and clarity or stability modifiers using procedural bio, multistage, spiral, and cross-hatch structures."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = CROOKED_MainPS;
    }
}

