// Copyright (c) 2026 Alia June and contributors
// Licensed under LICENSE-SOURCE-AVAILABLE-RESHADE-ONLY.txt (ReShade-only; no other engines).
// Version: 6
// Capability: Three-pass cell shading effect with base banding, coarse hatch shading, and superfine detail shaping, without ray marching.

#include "ReShade.fxh"

#define SPIRIT_CAT_DEBUG "Spirit World / 00 Debug"
#define SPIRIT_CAT_MAIN "Spirit World / 01 Main Settings"
#define SPIRIT_CAT_BASE "Spirit World / 02 Base Pass"
#define SPIRIT_CAT_COARSE "Spirit World / 03 Coarse Pass"
#define SPIRIT_CAT_SUPERFINE "Spirit World / 04 Superfine Pass"
#define SPIRIT_CAT_LENS "Spirit World / 05 Lens Field Input"
#define SPIRIT_CAT_MASK "Spirit World / 06 Mask Gate Input"

uniform int SPIRIT_DebugView <
    ui_type = "combo";
    ui_label = "Displayed Output";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Final Composite\0Base Result\0Coarse Contribution\0Superfine Contribution\0Edge Field\0Depth Gate\0Effective Mask Gate\0";
    ui_tooltip = "Chooses which Spirit World stage to inspect. Base Result shows the banded foundation, Coarse Contribution and Superfine Contribution show the isolated additions from those passes, and Edge Field, Depth Gate, and Effective Mask Gate expose the main controls behind the stack.";
> = 0;

uniform float SPIRIT_DebugExposure <
    ui_type = "slider";
    ui_label = "Debug Exposure";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_min = 1.0; ui_max = 16.0; ui_step = 0.1;
    ui_tooltip = "Brightens low-signal debug outputs so thin edges, weak masks, and subtle superfine detail are easier to read. Does not change the final composite when Debug View is Final Composite.";
> = 1.0;

uniform float SPIRIT_DebugGamma <
    ui_type = "slider";
    ui_label = "Debug Gamma";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.20; ui_max = 3.00; ui_step = 0.01;
    ui_tooltip = "Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final.";
> = 1.00;

uniform float SPIRIT_DebugContrast <
    ui_type = "slider";
    ui_label = "Debug Contrast";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.10; ui_max = 8.00; ui_step = 0.01;
    ui_tooltip = "Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path.";
> = 1.00;

uniform float SPIRIT_DebugBlackPoint <
    ui_type = "slider";
    ui_label = "Debug Black Point";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal.";
> = 0.00;

uniform float SPIRIT_DebugWhitePoint <
    ui_type = "slider";
    ui_label = "Debug White Point";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_min = 0.00; ui_max = 1.00; ui_step = 0.001;
    ui_tooltip = "Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes.";
> = 1.00;

uniform int SPIRIT_DebugInvert <
    ui_type = "combo";
    ui_label = "Debug Invert";
    ui_category = SPIRIT_CAT_DEBUG; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage.";
> = 0;

float SPIRIT_DebugShape(float value)
{
    float debugLow = min(SPIRIT_DebugBlackPoint, SPIRIT_DebugWhitePoint - 0.0001);
    float debugHigh = max(SPIRIT_DebugWhitePoint, debugLow + 0.0001);
    float debugValue = saturate((value - debugLow) / max(0.0001, debugHigh - debugLow));
    debugValue = saturate(debugValue * max(0.0, SPIRIT_DebugExposure));
    debugValue = saturate((debugValue - 0.5) * max(0.0, SPIRIT_DebugContrast) + 0.5);
    debugValue = pow(abs(max(debugValue, 0.0)), max(0.001, SPIRIT_DebugGamma));
    if (SPIRIT_DebugInvert != 0) debugValue = 1.0 - debugValue;
    return saturate(debugValue);
}

float3 SPIRIT_DebugShape3(float3 value)
{
    return float3(SPIRIT_DebugShape(value.r), SPIRIT_DebugShape(value.g), SPIRIT_DebugShape(value.b));
}


uniform int SPIRIT_Enable <
    ui_type = "combo";
    ui_label = "Enable Cell Shading Effect";
    ui_category = SPIRIT_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Master enable for the Spirit World cell shader stack. Off returns the source image unchanged.";
> = 1;

uniform int SPIRIT_EnableBase <
    ui_type = "combo";
    ui_label = "Enable Base Shading Pass";
    ui_category = SPIRIT_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the base cel-shading pass. This is the primary banding and edge-inking layer.";
> = 1;

uniform int SPIRIT_EnableCoarse <
    ui_type = "combo";
    ui_label = "Enable Coarse Shading Pass";
    ui_category = SPIRIT_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the broader hatch-weighted coarse pass. This adds large-form stylized shading over the base layer.";
> = 1;

uniform int SPIRIT_EnableSuperfine <
    ui_type = "combo";
    ui_label = "Enable Superfine Detail Pass";
    ui_category = SPIRIT_CAT_MAIN; ui_category_closed = false;
    ui_items = "Off\0On\0";
    ui_tooltip = "Enables the superfine pass. This adds restrained micro-detail and clarity on top of the broader cell structure.";
> = 1;

uniform float SPIRIT_MasterIntensity <
    ui_type = "slider";
    ui_label = "Master Intensity";
    ui_category = SPIRIT_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Overall intensity multiplier for the combined three-pass stack. Lower values keep the effect subtle; higher values push all enabled passes harder.";
> = 1.0;

uniform float SPIRIT_BaseStrength <
    ui_type = "slider";
    ui_label = "Base Strength";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Blend amount of the banded base pass. Higher values make cel quantization and flat-value grouping more obvious.";
> = 0.75;

uniform int SPIRIT_BaseBands <
    ui_type = "slider";
    ui_label = "Base Bands";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 2; ui_max = 16; ui_step = 1;
    ui_tooltip = "Number of luminance bands used by the base pass. Lower values give chunkier cel shading; higher values preserve more tonal resolution.";
> = 7;

uniform float SPIRIT_BaseBandContrast <
    ui_type = "slider";
    ui_label = "Base Band Contrast";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.25; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Contrast shaping applied before band quantization. Higher values push separation between light and dark bands.";
> = 0.95;

uniform float SPIRIT_BaseEdgeStrength <
    ui_type = "slider";
    ui_label = "Base Edge Strength";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Darkening strength of the base edge-inking pass. Higher values make contour emphasis more graphic and assertive.";
> = 0.65;

uniform float SPIRIT_EdgeRadiusPixels <
    ui_type = "slider";
    ui_label = "Edge Radius Pixels";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.25; ui_max = 6.0; ui_step = 0.01;
    ui_tooltip = "Sampling radius used for edge evaluation. Larger values read broader contour structure; smaller values hold onto tight local edges.";
> = 0.8;

uniform float SPIRIT_EdgeLumaGain <
    ui_type = "slider";
    ui_label = "Luma Edge Gain";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 24.0; ui_step = 0.01;
    ui_tooltip = "Gain applied to luminance edge response before thresholding. Raise it when visible contrast edges are present but not reading strongly enough.";
> = 5.0;

uniform float SPIRIT_EdgeDepthGain <
    ui_type = "slider";
    ui_label = "Depth Edge Gain";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 240.0; ui_step = 0.1;
    ui_tooltip = "Gain applied to depth-discontinuity response before thresholding. Raise it when silhouette structure exists in depth but the edge pass is too weak.";
> = 90.0;

uniform float SPIRIT_EdgeThreshold <
    ui_type = "slider";
    ui_label = "Edge Threshold";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Threshold where edge response begins. Lower values catch more structure; higher values reserve inking for clearer contours.";
> = 0.16;

uniform float SPIRIT_EdgeSoftness <
    ui_type = "slider";
    ui_label = "Edge Softness";
    ui_category = SPIRIT_CAT_BASE; ui_category_closed = true;
    ui_min = 0.01; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Softness of the edge threshold transition. Lower values make edge inking crisper; higher values blend it more gently.";
> = 0.24;

uniform float SPIRIT_CoarseStrength <
    ui_type = "slider";
    ui_label = "Coarse Strength";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Darkening strength of the coarse pass. This controls how strongly the broad hatch and shadow structure shapes the base layer.";
> = 0.55;

uniform float SPIRIT_CoarsePatternScale <
    ui_type = "slider";
    ui_label = "Coarse Hatch Field Scale";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 60.0; ui_max = 1800.0; ui_step = 0.1;
    ui_tooltip = "UV scale of the coarse hatch field in the real image. Larger values tighten the pattern; smaller values broaden the structural shading shapes.";
> = 620.0;

uniform float SPIRIT_CoarseDensity <
    ui_type = "slider";
    ui_label = "Coarse Density";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.1; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Density of the coarse hatch field in the real image. Higher values create denser coarse stylization and heavier directional structure.";
> = 2.0;

uniform float SPIRIT_CoarseFlow <
    ui_type = "slider";
    ui_label = "Coarse Flow";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6.0; ui_step = 0.001;
    ui_tooltip = "Phase drift for the coarse hatch field in the real image. Changing it alters the organic directional drift without changing tap count.";
> = 2.7;

uniform float SPIRIT_CoarseTapSpread <
    ui_type = "slider";
    ui_label = "Coarse Tap Spread";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 8.0; ui_max = 220.0; ui_step = 0.01;
    ui_tooltip = "How far Lens55 support taps spread while building the coarse hatch field in the real image. Larger values produce broader structural reach.";
> = 115.0;

uniform int SPIRIT_CoarseFieldTapBudget <
    ui_type = "slider";
    ui_label = "Coarse Field Tap Budget";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 3; ui_max = 55; ui_step = 1;
    ui_tooltip = "Number of taps used by the coarse hatch field itself. This is independent from the bounded lens support field budget, so the base support and coarse hatch can now be tuned separately.";
> = 21;

uniform float SPIRIT_CoarseCenterContrast <
    ui_type = "slider";
    ui_label = "Coarse Center Contrast";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Contrast shaping for the centered Fibonacci hatch body used by the coarse pass. Lower values keep the hatch broader and softer; higher values make the centered structure read more sharply.";
> = 0.45;

uniform float SPIRIT_CoarseStageBlend <
    ui_type = "slider";
    ui_label = "Coarse Stage Blend";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly the five-stage depth banding influences the coarse field. Higher values make the coarse pass more depth-zoned and staged.";
> = 0.55;

uniform float SPIRIT_CoarseShadowStart <
    ui_type = "slider";
    ui_label = "Coarse Shadow Start";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Beginning of the tonal range where coarse shading starts to appear. Lower values allow the coarse layer into brighter areas.";
> = 0.24;

uniform float SPIRIT_CoarseShadowEnd <
    ui_type = "slider";
    ui_label = "Coarse Shadow End";
    ui_category = SPIRIT_CAT_COARSE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Full-strength tonal boundary for the coarse layer. Lower values reserve the strongest coarse shading for darker regions only.";
> = 0.82;

uniform float SPIRIT_SuperfineStrength <
    ui_type = "slider";
    ui_label = "Superfine Strength";
    ui_category = SPIRIT_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Strength of the superfine pass. Higher values push micro-detail and clarity more strongly on top of the base and coarse layers.";
 > = 0.85;

uniform float SPIRIT_SuperfineRadius <
    ui_type = "slider";
    ui_label = "Superfine Radius";
    ui_category = SPIRIT_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.25; ui_max = 6.0; ui_step = 0.01;
    ui_tooltip = "Sampling radius of the superfine neighborhood. Smaller values keep the pass tight and crisp; larger values broaden micro-detail support.";
> = 0.9;

uniform float SPIRIT_SuperfineClamp <
    ui_type = "slider";
    ui_label = "Superfine Clamp";
    ui_category = SPIRIT_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.01; ui_max = 0.25; ui_step = 0.001;
    ui_tooltip = "Clamp on signed superfine detail contribution. Lower values keep the pass subtle and safer; higher values allow more visible micro-contrast lift.";
 > = 0.14;

uniform float SPIRIT_SuperfineChromaSafety <
    ui_type = "slider";
    ui_label = "Superfine Chroma Safety";
    ui_category = SPIRIT_CAT_SUPERFINE; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Biases superfine detail toward luminance instead of raw color. Higher values reduce color fizz and keep the micro-detail cleaner.";
> = 0.7;

uniform int SPIRIT_LensMode <
    ui_type = "combo";
    ui_label = "Lens Support Mode";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_items = "Organic Lens55\0Staggered Lens55\0Diamond13\0Box25\0";
    ui_tooltip = "Selects the bounded support field used by the base pass. Organic and Staggered are broader organic fields; Diamond13 and Box25 are tighter structured support fields.";
> = 0;

uniform int SPIRIT_TapBudget <
    ui_type = "slider";
    ui_label = "Lens Field Tap Budget";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_min = 1; ui_max = 55; ui_step = 1;
    ui_tooltip = "Number of support taps used by the bounded lens field in the real image. Each support mode clamps this to its own canonical size.";
> = 21;

uniform int SPIRIT_ReductionMode <
    ui_type = "combo";
    ui_label = "Lens Reduction";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_items = "Sequential\0Staggered\0";
    ui_tooltip = "How reduced tap counts are selected for the active support lens. Sequential takes the earliest taps, while Staggered redistributes lower budgets across the full canonical shape so the support field stays spatially balanced.";
> = 1;

uniform float SPIRIT_LensRadiusPixels <
    ui_type = "slider";
    ui_label = "Lens Radius Pixels";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Pixel reach of the bounded lens support field used by the base pass in the real image. Larger values broaden the averaged support neighborhood.";
> = 2.2;

uniform float SPIRIT_LensFieldScale <
    ui_type = "slider";
    ui_label = "Lens Field Scale";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 3.0; ui_step = 0.01;
    ui_tooltip = "Geometric scale of the bounded support field in the real image. Higher values spread taps farther within the support constellation.";
> = 1.0;

uniform float SPIRIT_LensFieldRotation <
    ui_type = "slider";
    ui_label = "Lens Field Rotation";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_min = -180.0; ui_max = 180.0; ui_step = 0.1;
    ui_tooltip = "Rotation of the bounded support field in the real image. This mainly affects anisotropic support modes such as Diamond13 and the structured Lens55 reductions.";
> = 0.0;

uniform float SPIRIT_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = SPIRIT_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 6100.0; ui_step = 1.0;
    ui_tooltip = "Phase anchor shared by the bounded lens support field and the centered Fibonacci coarse field. Changing it re-phases their ordering without changing tap count.";
> = 2584.0;

uniform int SPIRIT_MaskMode <
    ui_type = "combo";
    ui_label = "Mask Gate Mode";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_items = "Off\0Fog Evidence\0Light Shield\0Depth Window\0Far Detail\0Contrast\0Composite Guard\0";
    ui_tooltip = "Chooses the compact Crystal-style gate used to admit or suppress the three-pass stack. Off disables mask gating and lets the stack apply everywhere.";
 > = 0;

uniform float SPIRIT_MaskStrength <
    ui_type = "slider";
    ui_label = "Mask Strength";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Gain applied to the selected mask gate before it modulates the three-pass stack. Raise it when the chosen gate is correct but too weak.";
> = 1.0;

uniform float SPIRIT_MaskInfluence <
    ui_type = "slider";
    ui_label = "Mask Influence";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How strongly the selected mask gate suppresses the coarse and superfine passes. At 0 the advanced passes are ungated; at 1 they fully obey the selected mask.";
> = 0.0;

uniform int SPIRIT_DepthMode <
    ui_type = "combo";
    ui_label = "Depth Mode";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_items = "Linearized\0Raw Depth\0Raw Inverted\0";
    ui_tooltip = "Depth interpretation used by depth-aware edge, gate, and mask logic. Switch this if the depth diagnostics look reversed or flat.";
> = 0;

uniform int SPIRIT_DepthInvert <
    ui_type = "combo";
    ui_label = "Depth Invert";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_items = "No\0Yes\0";
    ui_tooltip = "Inverts near and far interpretation for alternative depth conventions.";
> = 0;

uniform float SPIRIT_DepthTraceScale <
    ui_type = "slider";
    ui_label = "Depth Trace Scale";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 1.0; ui_max = 4096.0; ui_step = 1.0;
    ui_tooltip = "Amplifies subtle depth differences before they feed edge detection, depth confidence, and depth-aware masks.";
> = 256.0;

uniform float SPIRIT_DepthAvailabilityThreshold <
    ui_type = "slider";
    ui_label = "Depth Confidence Threshold";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.00001; ui_max = 0.05; ui_step = 0.00001;
    ui_tooltip = "Minimum local depth activity needed before the shader trusts depth for gating and edge logic.";
> = 0.001;

uniform float SPIRIT_DepthEdgeThreshold <
    ui_type = "slider";
    ui_label = "Depth Edge Threshold";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.05; ui_step = 0.0001;
    ui_tooltip = "Threshold where depth-discontinuity response begins. Lower values catch more silhouettes; higher values reserve response for stronger breaks.";
> = 0.003;

uniform float SPIRIT_DepthStart <
    ui_type = "slider";
    ui_label = "Depth Start";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary of the compact depth window and far-bias logic. Lower values let near structure into the depth gate earlier.";
> = 0.0;

uniform float SPIRIT_DepthEnd <
    ui_type = "slider";
    ui_label = "Depth End";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Far boundary of the compact depth window. Together with Depth Start, this controls the core depth acceptance band.";
> = 1.0;

uniform float SPIRIT_FarDetailStart <
    ui_type = "slider";
    ui_label = "Far Detail Start";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Near boundary where far-detail logic starts to become active. Also used as a far bias for haze-like fog detection.";
> = 0.45;

uniform float SPIRIT_FarDetailEnd <
    ui_type = "slider";
    ui_label = "Far Detail End";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Full-strength far-detail boundary. Raising it pushes far-detail gating deeper into the scene.";
> = 0.75;

uniform float SPIRIT_FogBrightnessFloor <
    ui_type = "slider";
    ui_label = "Fog Brightness Floor";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1; ui_step = 0.0001;
    ui_tooltip = "Brightness floor used by the fog evidence gate. Raising it restricts fog detection to brighter haze and mist.";
> = 0.004;

uniform float SPIRIT_FogDesaturation <
    ui_type = "slider";
    ui_label = "Fog Desaturation";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "How colorless a region must be before the fog gate increases. Higher values focus more strongly on neutral haze.";
> = 0.18;

uniform float SPIRIT_FogLowContrast <
    ui_type = "slider";
    ui_label = "Fog Low Contrast";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.0001;
    ui_tooltip = "Local-contrast threshold used by the fog gate. Lower values make the haze detector more selective.";
> = 0.04;

uniform float SPIRIT_LightThreshold <
    ui_type = "slider";
    ui_label = "Light Threshold";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Brightness threshold where the light-shield gate starts to treat pixels as highlight-critical.";
> = 0.68;

uniform float SPIRIT_LightSoftness <
    ui_type = "slider";
    ui_label = "Light Softness";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Soft transition width for the light-shield gate. Higher values broaden highlight protection.";
> = 0.18;

uniform float SPIRIT_LineThreshold <
    ui_type = "slider";
    ui_label = "Line Threshold";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.001;
    ui_tooltip = "Threshold used by line-oriented mask logic and fog edge suppression. Lower values catch more fine structure.";
> = 0.018;

uniform float SPIRIT_ContrastThreshold <
    ui_type = "slider";
    ui_label = "Contrast Threshold";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.001; ui_max = 0.25; ui_step = 0.0001;
    ui_tooltip = "Minimum local luminance change required before the contrast gate turns on. Lower values catch more texture and edges.";
> = 0.02;

uniform float SPIRIT_ContrastGain <
    ui_type = "slider";
    ui_label = "Contrast Gain";
    ui_category = SPIRIT_CAT_MASK; ui_category_closed = true;
    ui_min = 0.5; ui_max = 8.0; ui_step = 0.01;
    ui_tooltip = "Gain applied to local contrast before thresholding. Raise it when the contrast gate is structurally right but too weak.";
> = 2.0;

#include "../header/SpiritWorld.fxh"

technique SpiritWorld < ui_label = "Spirit World :: Three Pass Cell Shading"; ui_tooltip = "Applies three layered stylization passes: a base banded shading pass, a coarse hatch-driven shading pass, and a superfine detail pass."; >
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = SPIRIT_MainPS;
    }
}

