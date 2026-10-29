// GoldenWeave RMGI Primitive Build
// New-generation ReShade screen-space ray-marched global illumination approximation.
// Built around local primitive atoms for source/depth/color/safe/lens/mask/ray-gather work.
// External include: ReShade.fxh. Local include: GoldenWeave_Primitives.fxh.
// No leaked helper UI controls or prior-generation visible branding.

#include "ReShade.fxh"
#include "../header/GoldenWeave_Primitives.fxh"

#define LW_CAT_VIEW   "GoldenWeave RMGI Primitive / 00 View"
#define LW_CAT_MAIN   "GoldenWeave RMGI Primitive / 01 Main Controls"
#define LW_CAT_RAYS   "GoldenWeave RMGI Primitive / 99 Advanced / 01 Ray Budget"
#define LW_CAT_LENS   "GoldenWeave RMGI Primitive / 99 Advanced / 02 Lens Fields"
#define LW_CAT_DEPTH  "GoldenWeave RMGI Primitive / 99 Advanced / 03 Depth + Surface"
#define LW_CAT_COLOR  "GoldenWeave RMGI Primitive / 99 Advanced / 04 Color Response"
#define LW_CAT_GUARD  "GoldenWeave RMGI Primitive / 99 Advanced / 05 Guards + Stability"

uniform int LW_ViewOutput <
    ui_type = "combo";
    ui_label = "View Output";
    ui_category = LW_CAT_VIEW; ui_category_closed = false;
    ui_items = "Final\0Indirect Only\0Contact Shadow\0Application Lens\0Sampling Pattern\0Depth Validity\0Depth Edges\0Surface Normal\0Guard Mask\0Ray Hit Weight\0Raw Bounce\0Fog Protect\0Light Protect\0Primitive Surface\0";
    ui_tooltip = "Selects final output or a diagnostic view from the primitive pipeline.";
> = 0;

uniform int LW_QualityPreset <
    ui_type = "combo";
    ui_label = "Quality Preset";
    ui_category = LW_CAT_MAIN; ui_category_closed = false;
    ui_items = "Draft\0Balanced\0Rich\0Ultra\0";
    ui_tooltip = "Caps active directions, ray steps, and strength scaling.";
> = 2;

uniform float LW_GIStrength <
    ui_type = "slider";
    ui_label = "GI Strength";
    ui_category = LW_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Overall indirect-light contribution.";
> = 1.350;

uniform float LW_ContactShadow <
    ui_type = "slider";
    ui_label = "Contact Shadow";
    ui_category = LW_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 2.5; ui_step = 0.001;
    ui_tooltip = "Darkens creases and shallow occluder hits discovered by primitive rays.";
> = 0.420;

uniform float LW_ColorBleed <
    ui_type = "slider";
    ui_label = "Color Bleed";
    ui_category = LW_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "How strongly gathered color shifts nearby surfaces.";
> = 1.250;

uniform float LW_SceneBlend <
    ui_type = "slider";
    ui_label = "Scene Blend";
    ui_category = LW_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Final blend between source frame and computed GI result.";
> = 0.780;

uniform float LW_DetailRestore <
    ui_type = "slider";
    ui_label = "Detail Restore";
    ui_category = LW_CAT_MAIN; ui_category_closed = false;
    ui_min = 0.0; ui_max = 1.5; ui_step = 0.001;
    ui_tooltip = "Returns local source contrast after GI is applied.";
> = 0.320;

uniform int LW_RayMode <
    ui_type = "combo";
    ui_label = "Ray Mode";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_items = "Gather Only\0Ray March\0Hybrid\0";
    ui_tooltip = "Gather Only uses one lens tap per direction; Ray March walks along the ray; Hybrid blends both.";
> = 2;

uniform int LW_DirectionBudget <
    ui_type = "slider";
    ui_label = "Direction Budget";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 1; ui_max = LWPR_MAX_TAPS; ui_step = 1;
    ui_tooltip = "Maximum active primitive directions before preset and budget caps.";
> = 16;

uniform int LW_StepBudget <
    ui_type = "slider";
    ui_label = "Step Budget";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 1; ui_max = LWPR_MAX_STEPS; ui_step = 1;
    ui_tooltip = "Maximum primitive ray steps per direction before preset and budget caps.";
> = 6;

uniform float LW_BudgetScale <
    ui_type = "slider";
    ui_label = "Budget Scale";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 0.15; ui_max = 1.0; ui_step = 0.01;
    ui_tooltip = "Scales active direction and step count without changing the preset.";
> = 0.75;

uniform float LW_RayLengthPixels <
    ui_type = "slider";
    ui_label = "Ray Length";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 64.0; ui_step = 0.01;
    ui_tooltip = "Maximum ray reach in pixels.";
> = 7.50;

uniform float LW_GatherLengthPixels <
    ui_type = "slider";
    ui_label = "Gather Length";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 48.0; ui_step = 0.01;
    ui_tooltip = "Single-sample gather reach in pixels.";
> = 3.25;

uniform float LW_RayRotation <
    ui_type = "slider";
    ui_label = "Ray Rotation";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = -3.14159; ui_max = 3.14159; ui_step = 0.001;
    ui_tooltip = "Rotates the sampling field.";
> = 0.0;

uniform float LW_OrganicDrift <
    ui_type = "slider";
    ui_label = "Organic Drift";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 8.0; ui_step = 0.001;
    ui_tooltip = "Deterministic per-pixel drift used to break rigid ray patterns.";
> = 1.300;

uniform int LW_SamplingLens <
    ui_type = "combo";
    ui_label = "Sampling Lens";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_items = "Golden Spiral\0Fibonacci Growth\0Cross Ring\0Jitter Ring\0Muqarnas Star\0Geodesic Dome\0Trihex Weave\0Log Spiral\0Organic Hatch\0Kaleidoscope\0";
    ui_tooltip = "Primitive direction field used by the GI rays.";
> = 1;

uniform int LW_ApplicationLens <
    ui_type = "combo";
    ui_label = "Application Lens";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_items = "Off\0Depth Continuity\0Contrast Field\0Edge Assist\0Depth Vignette\0Lens Pattern\0Shadow Receiver\0";
    ui_tooltip = "Primitive field used to shape where GI is applied.";
> = 2;

uniform float LW_ApplicationStrength <
    ui_type = "slider";
    ui_label = "Application Strength";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "How strongly the selected application lens modulates final GI.";
> = 0.650;

uniform float LW_LensRadiusPixels <
    ui_type = "slider";
    ui_label = "Lens Radius";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_min = 0.25; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Neighborhood radius used for application-lens diagnostics and contrast fields.";
> = 2.50;

uniform float LW_LensSharpness <
    ui_type = "slider";
    ui_label = "Lens Sharpness";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_min = 0.1; ui_max = 12.0; ui_step = 0.01;
    ui_tooltip = "Contrast/edge gain used by application lens modes.";
> = 4.20;

uniform float LW_FibonacciAnchor <
    ui_type = "slider";
    ui_label = "Fibonacci Anchor";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_min = 0.0; ui_max = 8000.0; ui_step = 1.0;
    ui_tooltip = "Phase anchor for Fibonacci and organic lens synthesis.";
> = 1597.0;

uniform float LW_DepthThickness <
    ui_type = "slider";
    ui_label = "Depth Thickness";
    ui_category = LW_CAT_DEPTH; ui_category_closed = true;
    ui_min = 0.0001; ui_max = 0.1000; ui_step = 0.0001;
    ui_tooltip = "Depth tolerance for accepting ray samples as related surfaces.";
> = 0.0120;

uniform float LW_DepthBias <
    ui_type = "slider";
    ui_label = "Depth Bias";
    ui_category = LW_CAT_DEPTH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 0.1000; ui_step = 0.0001;
    ui_tooltip = "Self-intersection bias for nearby samples.";
> = 0.0015;

uniform float LW_DepthFalloff <
    ui_type = "slider";
    ui_label = "Depth Falloff";
    ui_category = LW_CAT_DEPTH; ui_category_closed = true;
    ui_min = 0.01; ui_max = 256.0; ui_step = 0.01;
    ui_tooltip = "Distance falloff along the ray.";
> = 36.0;

uniform float LW_DepthEdgeReject <
    ui_type = "slider";
    ui_label = "Depth Edge Reject";
    ui_category = LW_CAT_DEPTH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Suppresses GI near discontinuities to reduce halos.";
> = 0.720;

uniform float LW_NormalDirectionality <
    ui_type = "slider";
    ui_label = "Normal Directionality";
    ui_category = LW_CAT_DEPTH; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Weights rays by the depth-derived primitive surface normal.";
> = 0.850;

uniform float LW_SurfaceSpread <
    ui_type = "slider";
    ui_label = "Surface Spread";
    ui_category = LW_CAT_DEPTH; ui_category_closed = true;
    ui_min = 0.05; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Controls how permissive the surface-normal lobe is.";
> = 0.720;

uniform float LW_BounceSaturation <
    ui_type = "slider";
    ui_label = "Bounce Saturation";
    ui_category = LW_CAT_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Saturation of gathered indirect color.";
> = 1.380;

uniform float LW_ColorTemperature <
    ui_type = "slider";
    ui_label = "Color Temperature";
    ui_category = LW_CAT_COLOR; ui_category_closed = true;
    ui_min = -1.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Negative cools bounce light, positive warms bounce light.";
> = 0.080;

uniform float LW_EmissivePickup <
    ui_type = "slider";
    ui_label = "Emissive Pickup";
    ui_category = LW_CAT_COLOR; ui_category_closed = true;
    ui_min = 0.0; ui_max = 3.0; ui_step = 0.001;
    ui_tooltip = "Boosts contribution from bright donor pixels.";
> = 0.450;

uniform float LW_ContributionClamp <
    ui_type = "slider";
    ui_label = "Contribution Clamp";
    ui_category = LW_CAT_COLOR; ui_category_closed = true;
    ui_min = 0.1; ui_max = 8.0; ui_step = 0.001;
    ui_tooltip = "Upper bound on indirect contribution before composition.";
> = 2.250;

uniform float LW_ResponseCurve <
    ui_type = "slider";
    ui_label = "Response Curve";
    ui_category = LW_CAT_COLOR; ui_category_closed = true;
    ui_min = 0.25; ui_max = 4.0; ui_step = 0.001;
    ui_tooltip = "Power curve applied to ray-hit coverage and application mask.";
> = 1.120;

uniform float LW_SkyProtect <
    ui_type = "slider";
    ui_label = "Sky Protect";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Suppresses GI where the depth buffer appears invalid or sky-like.";
> = 0.950;

uniform float LW_FogStart <
    ui_type = "slider";
    ui_label = "Fog Start";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Depth position where far/fog protection begins.";
> = 0.780;

uniform float LW_FogProtect <
    ui_type = "slider";
    ui_label = "Fog Protect";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Suppresses GI in far/fog regions.";
> = 0.620;

uniform float LW_HighlightThreshold <
    ui_type = "slider";
    ui_label = "Highlight Threshold";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.001;
    ui_tooltip = "Luma threshold for highlight/light protection.";
> = 0.820;

uniform float LW_LightProtect <
    ui_type = "slider";
    ui_label = "Light Protect";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Restores protected bright pixels toward the original source color.";
> = 0.720;

uniform float LW_StabilityBlend <
    ui_type = "slider";
    ui_label = "Stability Blend";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Suppresses contribution at unstable depth/edge regions.";
> = 0.520;

uniform float LW_EdgePreserve <
    ui_type = "slider";
    ui_label = "Edge Preserve";
    ui_category = LW_CAT_GUARD; ui_category_closed = true;
    ui_min = 0.0; ui_max = 1.0; ui_step = 0.001;
    ui_tooltip = "Restores source color around strong color/depth edges.";
> = 0.410;

void LW_AccumulateTapChunk4(
    float2 uv,
    LWPR_Surface surface,
    int activeTaps,
    int activeSteps,
    int tapStart,
    inout float3 gathered,
    inout float gatheredWeight,
    inout float contactAccum)
{
    [unroll]
    for (int localTap = 0; localTap < 4; ++localTap)
    {
        int tap = tapStart + localTap;
        if (tap < activeTaps)
        {
            float2 direction = LWPR_LensDirection(uv, tap, activeTaps, LW_SamplingLens, LW_FibonacciAnchor, LW_RayRotation, LW_OrganicDrift);
            float growth = lerp(0.65, 1.35, sqrt((float(tap) + 0.5) / max(1.0, float(activeTaps))));

            LWPR_RayResult ray = LWPR_MarchDirection(
                uv,
                surface,
                direction,
                LW_RayMode,
                activeSteps,
                LW_QualityPreset,
                LW_RayLengthPixels,
                LW_GatherLengthPixels,
                LW_DepthThickness,
                LW_DepthBias,
                LW_DepthFalloff,
                LW_SurfaceSpread,
                LW_NormalDirectionality,
                LW_EmissivePickup,
                LW_HighlightThreshold,
                growth);

            gathered += ray.color;
            gatheredWeight += ray.weight;
            contactAccum += ray.contact;
        }
    }
}

float4 GoldenWeave_RMGI_Primitive_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    int presetTapCap = LWPR_TierTapCap(LW_QualityPreset);
    int presetStepCap = LWPR_TierStepCap(LW_QualityPreset);

    int activeTaps = max(1, min(min(LW_DirectionBudget, presetTapCap), LWPR_MAX_TAPS));
    activeTaps = max(1, int(floor(float(activeTaps) * LW_BudgetScale + 0.5)));

    int activeSteps = max(1, min(min(LW_StepBudget, presetStepCap), LWPR_MAX_STEPS));
    activeSteps = max(1, int(floor(float(activeSteps) * LW_BudgetScale + 0.5)));

    LWPR_Surface surface = LWPR_ReadSurface(uv, LW_DepthThickness, LW_DepthEdgeReject, LW_SkyProtect, LW_NormalDirectionality);

    float3 gathered = surface.color;
    float gatheredWeight = 1.0;
    float contactAccum = 0.0;

    // Sequential bounded passes: each call exposes only a four-tap loop to the compiler.
    LW_AccumulateTapChunk4(uv, surface, activeTaps, activeSteps, 0, gathered, gatheredWeight, contactAccum);
    if (activeTaps > 4)  LW_AccumulateTapChunk4(uv, surface, activeTaps, activeSteps, 4, gathered, gatheredWeight, contactAccum);
    if (activeTaps > 8)  LW_AccumulateTapChunk4(uv, surface, activeTaps, activeSteps, 8, gathered, gatheredWeight, contactAccum);
    if (activeTaps > 12) LW_AccumulateTapChunk4(uv, surface, activeTaps, activeSteps, 12, gathered, gatheredWeight, contactAccum);
    if (activeTaps > 16) LW_AccumulateTapChunk4(uv, surface, activeTaps, activeSteps, 16, gathered, gatheredWeight, contactAccum);
    if (activeTaps > 20) LW_AccumulateTapChunk4(uv, surface, activeTaps, activeSteps, 20, gathered, gatheredWeight, contactAccum);

    float hitCoverage = saturate((gatheredWeight - 1.0) / max(1.0, float(activeTaps * activeSteps)));
    float contact = saturate(contactAccum / max(1.0, float(activeTaps * activeSteps)));

    float3 indirect = gathered / max(LWPR_EPS, gatheredWeight);
    indirect = LWPR_SaturateAroundLuma(indirect, LW_BounceSaturation);
    indirect = LWPR_ApplyTemperature(indirect, LW_ColorTemperature);

    float3 rawBounce = max(0.0.xxx, indirect - surface.color);
    float samplingPattern = LWPR_LensPatternPreview(uv, activeTaps, LW_SamplingLens, LW_FibonacciAnchor, LW_RayRotation, LW_OrganicDrift, LW_LensRadiusPixels);
    float appField = LWPR_ApplicationField(uv, surface, LW_ApplicationLens, LW_ApplicationStrength, LW_LensRadiusPixels, LW_LensSharpness, LW_FogStart, hitCoverage, contact, samplingPattern);
    float coverageMask = pow(abs(saturate(hitCoverage * appField * surface.depthValidity)), max(0.25, LW_ResponseCurve));

    float fogProtect = smoothstep(LW_FogStart, 1.0, surface.depth) * LW_FogProtect;
    float lightProtect = smoothstep(LW_HighlightThreshold, LW_HighlightThreshold + 0.30, surface.luma) * LW_LightProtect;
    float edgeProtect = saturate(max(surface.depthEdge * LW_StabilityBlend, max(surface.depthEdge, surface.colorEdge) * LW_EdgePreserve));
    float guardMask = saturate(max(max(fogProtect, lightProtect), edgeProtect));

    float3 finalColor = LWPR_GuardedComposite(
        surface.color,
        indirect,
        contact,
        coverageMask,
        guardMask,
        LW_GIStrength,
        LWPR_TierStrengthScale(LW_QualityPreset),
        LW_ColorBleed,
        LW_ContributionClamp,
        LW_ContactShadow,
        LW_DetailRestore,
        LW_SceneBlend,
        uv);

    float3 normalView = surface.normal * 0.5 + 0.5;
    float3 primitiveSurface = float3(surface.depthValidity, 1.0 - surface.depthEdge, 1.0 - surface.colorEdge);

    if (LW_ViewOutput == 1) return float4(saturate(indirect), 1.0);
    if (LW_ViewOutput == 2) return float4(LWPR_DebugScalar(contact).xxx, 1.0);
    if (LW_ViewOutput == 3) return float4(LWPR_DebugScalar(appField).xxx, 1.0);
    if (LW_ViewOutput == 4) return float4(LWPR_DebugScalar(samplingPattern).xxx, 1.0);
    if (LW_ViewOutput == 5) return float4(LWPR_DebugScalar(surface.depthValidity).xxx, 1.0);
    if (LW_ViewOutput == 6) return float4(LWPR_DebugScalar(surface.depthEdge).xxx, 1.0);
    if (LW_ViewOutput == 7) return float4(saturate(normalView), 1.0);
    if (LW_ViewOutput == 8) return float4(LWPR_DebugScalar(guardMask).xxx, 1.0);
    if (LW_ViewOutput == 9) return float4(LWPR_DebugScalar(hitCoverage).xxx, 1.0);
    if (LW_ViewOutput == 10) return float4(saturate(rawBounce * 4.0), 1.0);
    if (LW_ViewOutput == 11) return float4(LWPR_DebugScalar(fogProtect).xxx, 1.0);
    if (LW_ViewOutput == 12) return float4(LWPR_DebugScalar(lightProtect).xxx, 1.0);
    if (LW_ViewOutput == 13) return float4(saturate(primitiveSurface), 1.0);

    return float4(saturate(finalColor), 1.0);
}

technique GoldenWeave_RMGI_Primitive <
    ui_label = "GoldenWeave - Ray-Marched GI - Primitive Build";
    ui_tooltip = "Primitive-built screen-space ray-marched global illumination with source/depth/color/lens/mask/ray atoms, explicit budgets, guards, and diagnostics.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Primitive_PS;
    }
}

