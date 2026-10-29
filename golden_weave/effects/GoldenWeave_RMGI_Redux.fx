// GoldenWeave RMGI Redux
// Standalone ReShade screen-space ray-marched global illumination approximation.
// Source basis: compiler-safe raymarching paper + uploaded miXSR Kaleidoscope GI source.
// No BlackWand, RC3, miXSR, or source-server UI branding/dependencies.
// External include: ReShade.fxh only.

#include "ReShade.fxh"

// Sampling-pass hotfix: split the ray field into small render-target batches.
// This avoids a single large nested ray loop that can trigger HLSL X3511 unroll failure.
#ifndef LW_PASS_TAPS
#define LW_PASS_TAPS 6
#endif

texture2D LW_ReduxCW0Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
texture2D LW_ReduxCW1Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
texture2D LW_ReduxCW2Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
texture2D LW_ReduxCW3Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };

texture2D LW_ReduxCT0Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
texture2D LW_ReduxCT1Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
texture2D LW_ReduxCT2Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };
texture2D LW_ReduxCT3Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; };

sampler2D LW_ReduxCW0Sampler { Texture = LW_ReduxCW0Tex; };
sampler2D LW_ReduxCW1Sampler { Texture = LW_ReduxCW1Tex; };
sampler2D LW_ReduxCW2Sampler { Texture = LW_ReduxCW2Tex; };
sampler2D LW_ReduxCW3Sampler { Texture = LW_ReduxCW3Tex; };

sampler2D LW_ReduxCT0Sampler { Texture = LW_ReduxCT0Tex; };
sampler2D LW_ReduxCT1Sampler { Texture = LW_ReduxCT1Tex; };
sampler2D LW_ReduxCT2Sampler { Texture = LW_ReduxCT2Tex; };
sampler2D LW_ReduxCT3Sampler { Texture = LW_ReduxCT3Tex; };


#define LW_CAT_VIEW   "GoldenWeave RMGI Redux / 00 View"
#define LW_CAT_MAIN   "GoldenWeave RMGI Redux / 01 Main Controls"
#define LW_CAT_RAYS   "GoldenWeave RMGI Redux / 99 Advanced / 01 Ray Budget"
#define LW_CAT_LENS   "GoldenWeave RMGI Redux / 99 Advanced / 02 Lens Fields"
#define LW_CAT_DEPTH  "GoldenWeave RMGI Redux / 99 Advanced / 03 Depth + Surface"
#define LW_CAT_COLOR  "GoldenWeave RMGI Redux / 99 Advanced / 04 Color Response"
#define LW_CAT_GUARD  "GoldenWeave RMGI Redux / 99 Advanced / 05 Guards + Stability"

#define LW_PI 3.14159265358979323846
#define LW_TAU 6.28318530717958647692
#define LW_GOLDEN_ANGLE 2.39996322972865332
#define LW_EPS 0.000010
#define LW_MAX_TAPS 24
#define LW_MAX_STEPS 8

uniform int LW_ViewOutput <
    ui_type = "combo";
    ui_label = "View Output";
    ui_category = LW_CAT_VIEW; ui_category_closed = false;
    ui_items = "Final\0Indirect Only\0Contact Shadow\0Application Lens\0Sampling Pattern\0Depth Validity\0Depth Edges\0Surface Normal\0Guard Mask\0Ray Hit Weight\0Raw Bounce\0Fog Protect\0Light Protect\0";
    ui_tooltip = "Selects final output or a diagnostic view.";
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
    ui_tooltip = "Darkens creases and shallow occluder hits discovered by the rays.";
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
    ui_min = 1; ui_max = LW_MAX_TAPS; ui_step = 1;
    ui_tooltip = "Maximum active sampling directions before preset and budget caps.";
> = 16;

uniform int LW_StepBudget <
    ui_type = "slider";
    ui_label = "Step Budget";
    ui_category = LW_CAT_RAYS; ui_category_closed = true;
    ui_min = 1; ui_max = LW_MAX_STEPS; ui_step = 1;
    ui_tooltip = "Maximum steps per direction before preset and budget caps.";
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
    ui_tooltip = "Direction field used by the GI rays.";
> = 1;

uniform int LW_ApplicationLens <
    ui_type = "combo";
    ui_label = "Application Lens";
    ui_category = LW_CAT_LENS; ui_category_closed = true;
    ui_items = "Off\0Depth Continuity\0Contrast Field\0Edge Assist\0Depth Vignette\0Lens Pattern\0Shadow Receiver\0";
    ui_tooltip = "Field used to shape where GI is applied.";
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
    ui_tooltip = "Weights rays by the depth-derived surface normal.";
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

float2 LW_Pixel()
{
    return float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
}

float3 LW_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(saturate(uv), 0.0, 0.0)).rgb;
}

float LW_Depth(float2 uv)
{
    return saturate(ReShade::GetLinearizedDepth(saturate(uv)));
}

float LW_Luma(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

float2 LW_Rotate2(float2 v, float a)
{
    float s = sin(a);
    float c = cos(a);
    return float2(c * v.x - s * v.y, s * v.x + c * v.y);
}

float LW_Hash21(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}

float2 LW_SafeNorm2(float2 v)
{
    float len2 = dot(v, v);
    return (len2 > LW_EPS) ? v * rsqrt(len2) : float2(1.0, 0.0);
}

float3 LW_SafeNorm3(float3 v)
{
    float len2 = dot(v, v);
    return (len2 > LW_EPS) ? v * rsqrt(len2) : float3(0.0, 0.0, 1.0);
}

float LW_DebugScalar(float value)
{
    return pow(saturate(value), 0.65);
}

float3 LW_SaturateAroundLuma(float3 color, float amount)
{
    float luma = LW_Luma(color);
    return lerp(luma.xxx, color, amount);
}

float3 LW_ApplyTemperature(float3 color, float temperature)
{
    float warm = saturate(temperature);
    float cool = saturate(-temperature);
    float3 warmed = color * float3(1.0 + 0.18 * warm, 1.0 + 0.06 * warm, 1.0 - 0.12 * warm);
    float3 cooled = warmed * float3(1.0 - 0.10 * cool, 1.0 + 0.03 * cool, 1.0 + 0.18 * cool);
    return max(0.0.xxx, cooled);
}

int LW_TierTapCap()
{
    int result = LW_MAX_TAPS;
    if (LW_QualityPreset == 0)
    {
        result = 6;
    }
    else if (LW_QualityPreset == 1)
    {
        result = 12;
    }
    else if (LW_QualityPreset == 2)
    {
        result = 18;
    }
    return result;
}

int LW_TierStepCap()
{
    int result = LW_MAX_STEPS;
    if (LW_QualityPreset == 0)
    {
        result = 2;
    }
    else if (LW_QualityPreset == 1)
    {
        result = 4;
    }
    else if (LW_QualityPreset == 2)
    {
        result = 6;
    }
    return result;
}

float LW_TierLengthScale()
{
    float result = 1.25;
    if (LW_QualityPreset == 0)
    {
        result = 0.65;
    }
    else if (LW_QualityPreset == 1)
    {
        result = 0.90;
    }
    else if (LW_QualityPreset == 2)
    {
        result = 1.10;
    }
    return result;
}

float LW_TierStrengthScale()
{
    float result = 1.30;
    if (LW_QualityPreset == 0)
    {
        result = 0.70;
    }
    else if (LW_QualityPreset == 1)
    {
        result = 1.00;
    }
    else if (LW_QualityPreset == 2)
    {
        result = 1.18;
    }
    return result;
}

float3 LW_PseudoNormal(float2 uv)
{
    float2 px = LW_Pixel();
    float dR = LW_Depth(uv + float2(px.x, 0.0));
    float dL = LW_Depth(uv - float2(px.x, 0.0));
    float dU = LW_Depth(uv + float2(0.0, px.y));
    float dD = LW_Depth(uv - float2(0.0, px.y));
    float zScale = max(px.x, px.y) * 72.0 + 0.050;
    return LW_SafeNorm3(float3((dL - dR) * LW_NormalDirectionality, (dD - dU) * LW_NormalDirectionality, zScale));
}

float LW_DepthEdge(float2 uv)
{
    float2 px = LW_Pixel();
    float center = LW_Depth(uv);
    float d0 = abs(LW_Depth(uv + float2(px.x, 0.0)) - center);
    float d1 = abs(LW_Depth(uv - float2(px.x, 0.0)) - center);
    float d2 = abs(LW_Depth(uv + float2(0.0, px.y)) - center);
    float d3 = abs(LW_Depth(uv - float2(0.0, px.y)) - center);
    return saturate((d0 + d1 + d2 + d3) / max(0.0001, LW_DepthThickness * 8.0));
}

float LW_ColorEdge(float2 uv)
{
    float2 px = LW_Pixel();
    float center = LW_Luma(LW_Source(uv));
    float c0 = abs(LW_Luma(LW_Source(uv + float2(px.x, 0.0))) - center);
    float c1 = abs(LW_Luma(LW_Source(uv - float2(px.x, 0.0))) - center);
    float c2 = abs(LW_Luma(LW_Source(uv + float2(0.0, px.y))) - center);
    float c3 = abs(LW_Luma(LW_Source(uv - float2(0.0, px.y))) - center);
    return saturate((c0 + c1 + c2 + c3) * 5.0);
}

float LW_DepthValidity(float centerDepth, float depthEdge)
{
    float notSky = 1.0 - smoothstep(0.985, 1.0, centerDepth) * LW_SkyProtect;
    float edgeValid = lerp(1.0, 1.0 - depthEdge, LW_DepthEdgeReject);
    return saturate(notSky * edgeValid);
}

float2 LW_LensDir(float2 uv, int index, int count)
{
    float fi = float(index);
    float fc = max(1.0, float(count));
    float base = LW_FibonacciAnchor + fi + 0.5;
    float n = (fi + 0.5) / fc;
    float angle = base * LW_GOLDEN_ANGLE + LW_RayRotation;
    float radius = sqrt(n);

    float2 dir = float2(cos(angle), sin(angle)) * radius;

    if (LW_SamplingLens == 0)
    {
        dir = float2(cos(angle), sin(angle));
    }
    else if (LW_SamplingLens == 1)
    {
        dir = float2(cos(angle), sin(angle)) * sqrt(n);
    }
    else if (LW_SamplingLens == 2)
    {
        float quadrant = floor(frac((fi + LW_FibonacciAnchor) * 0.25) * 4.0);
        float a = quadrant * (LW_PI * 0.5) + (n - 0.5) * 0.35;
        dir = float2(cos(a), sin(a)) * lerp(0.45, 1.0, radius);
    }
    else if (LW_SamplingLens == 3)
    {
        float jitter = (LW_Hash21(uv * BUFFER_SCREEN_SIZE + fi.xx) - 0.5) * LW_OrganicDrift;
        dir = float2(cos(angle + jitter), sin(angle + jitter)) * lerp(0.35, 1.0, radius);
    }
    else if (LW_SamplingLens == 4)
    {
        float star = floor(frac((fi + 0.5) / 8.0) * 8.0);
        float a = star * (LW_TAU / 8.0) + sin(base * 0.37) * 0.18;
        dir = float2(cos(a), sin(a)) * lerp(0.25, 1.0, frac(fi * 0.61803398875 + 0.2));
    }
    else if (LW_SamplingLens == 5)
    {
        float dome = acos(1.0 - 2.0 * n);
        float a = angle + sin(dome * 3.0) * 0.25;
        dir = float2(cos(a), sin(a)) * sin(dome);
    }
    else if (LW_SamplingLens == 6)
    {
        float a = floor(frac(fi * 0.3333333) * 6.0) * (LW_TAU / 6.0);
        float weave = ((frac(fi * 0.5) < 0.5) ? 0.35 : 0.85);
        dir = float2(cos(a), sin(a)) * lerp(weave, 1.0, radius);
    }
    else if (LW_SamplingLens == 7)
    {
        float logR = exp(lerp(log(0.08), log(1.0), n));
        dir = float2(cos(angle), sin(angle)) * logR;
    }
    else if (LW_SamplingLens == 8)
    {
        float hatch = sin((uv.x + uv.y) * BUFFER_WIDTH * 0.055 + base * 1.71 + LW_OrganicDrift);
        float a = angle + hatch * 0.65;
        dir = float2(cos(a), sin(a)) * lerp(0.20, 1.0, radius);
    }
    else
    {
        float k = abs(frac(angle / LW_TAU) * 2.0 - 1.0);
        float a = floor((angle / LW_TAU) * 6.0) * (LW_TAU / 6.0);
        dir = lerp(float2(cos(angle), sin(angle)), float2(cos(a), sin(a)), 0.55 * k) * lerp(0.25, 1.0, radius);
    }

    float drift = (LW_Hash21(uv * (13.0 + LW_OrganicDrift) + fi.xx) - 0.5) * 0.18 * LW_OrganicDrift;
    return LW_SafeNorm2(LW_Rotate2(dir, drift));
}

float LW_LensPatternPreview(float2 uv, int tapCount)
{
    float tileCount = 6.0;
    float2 cellUv = frac(uv * tileCount);
    float2 localUv = cellUv - 0.5;
    float2 cellCenter = (floor(uv * tileCount) + 0.5) / tileCount;
    float accum = 0.0;
    float radiusScale = saturate(LW_LensRadiusPixels / 12.0) * 0.28 + 0.04;

    [unroll]
    for (int i = 0; i < LW_MAX_TAPS; ++i)
    {
        if (i < tapCount)
        {
            float2 dir = LW_LensDir(cellCenter, i, tapCount);
            float2 tapUv = dir * radiusScale;
            float marker = 1.0 - smoothstep(0.0, 0.030, length(localUv - tapUv));
            accum += marker;
        }
    }

    float ring = 1.0 - smoothstep(0.006, 0.016, abs(length(localUv) - radiusScale));
    return saturate(accum * 0.32 + ring * 0.25);
}

float LW_ApplicationField(float2 uv, float centerDepth, float centerLuma, float depthEdge, float colorEdge, float hitCoverage, float contact)
{
    float field = 1.0;

    if (LW_ApplicationLens == 0)
    {
        field = 1.0;
    }
    else if (LW_ApplicationLens == 1)
    {
        field = 1.0 - smoothstep(0.0, 1.0, depthEdge);
    }
    else if (LW_ApplicationLens == 2)
    {
        float2 px = LW_Pixel() * LW_LensRadiusPixels;
        float l0 = LW_Luma(LW_Source(uv + float2(px.x, 0.0)));
        float l1 = LW_Luma(LW_Source(uv - float2(px.x, 0.0)));
        float l2 = LW_Luma(LW_Source(uv + float2(0.0, px.y)));
        float l3 = LW_Luma(LW_Source(uv - float2(0.0, px.y)));
        field = saturate((abs(l0 - centerLuma) + abs(l1 - centerLuma) + abs(l2 - centerLuma) + abs(l3 - centerLuma)) * LW_LensSharpness);
    }
    else if (LW_ApplicationLens == 3)
    {
        field = saturate(max(depthEdge, colorEdge) * LW_LensSharpness);
    }
    else if (LW_ApplicationLens == 4)
    {
        field = 1.0 - smoothstep(LW_FogStart, 1.0, centerDepth);
    }
    else if (LW_ApplicationLens == 5)
    {
        field = LW_LensPatternPreview(uv, max(1, min(LW_DirectionBudget, LW_MAX_TAPS)));
    }
    else
    {
        field = saturate(contact * 1.75 + hitCoverage * 0.65);
    }

    return saturate(lerp(1.0, field, LW_ApplicationStrength));
}

void LW_MarchOneDirection(
    float2 uv,
    float centerDepth,
    float centerLuma,
    float3 centerNormal,
    float2 direction,
    int activeSteps,
    float growth,
    out float3 rayColor,
    out float rayWeight,
    out float rayContact)
{
    float2 px = LW_Pixel();
    float tierLength = LW_TierLengthScale();
    float2 marchVector = direction * px * LW_RayLengthPixels * tierLength * growth;
    float2 gatherVector = direction * px * LW_GatherLengthPixels * tierLength * growth;
    float invSteps = rcp(max(1.0, float(activeSteps)));
    float thickness = max(0.0001, LW_DepthThickness);
    float falloff = max(0.01, LW_DepthFalloff);

    rayColor = 0.0.xxx;
    rayWeight = 0.0;
    rayContact = 0.0;

    [unroll]
    for (int s = 1; s <= LW_MAX_STEPS; ++s)
    {
        if (s <= activeSteps)
        {
            float t = float(s) * invSteps;
            float2 rayUv = uv + marchVector * t;
            float2 gatherUv = uv + gatherVector;
            float3 sampleRayColor = LW_Source(rayUv);
            float3 sampleGatherColor = LW_Source(gatherUv);
            float sampleRayDepth = LW_Depth(rayUv);
            float sampleGatherDepth = LW_Depth(gatherUv);

            float rayDelta = sampleRayDepth - centerDepth;
            float gatherDelta = sampleGatherDepth - centerDepth;

            float raySurface = 1.0 - smoothstep(thickness, thickness * (1.0 + LW_SurfaceSpread * 3.0), abs(rayDelta));
            float gatherSurface = 1.0 - smoothstep(thickness, thickness * (1.0 + LW_SurfaceSpread * 2.0), abs(gatherDelta));

            float rayBehind = step(centerDepth - LW_DepthBias, sampleRayDepth + thickness);
            float gatherBehind = step(centerDepth - LW_DepthBias, sampleGatherDepth + thickness);

            float3 rayDir3 = LW_SafeNorm3(float3(direction.xy * LW_NormalDirectionality, LW_SurfaceSpread));
            float normalWeight = saturate(dot(centerNormal, rayDir3) * 0.5 + 0.5);
            float distanceWeight = exp(-t * falloff * 0.0110);

            float brightRay = smoothstep(LW_HighlightThreshold, LW_HighlightThreshold + 0.35, LW_Luma(sampleRayColor));
            float brightGather = smoothstep(LW_HighlightThreshold, LW_HighlightThreshold + 0.35, LW_Luma(sampleGatherColor));

            float rayW = raySurface * rayBehind * normalWeight * distanceWeight * (1.0 + brightRay * LW_EmissivePickup);
            float gatherW = gatherSurface * gatherBehind * normalWeight * (1.0 + brightGather * LW_EmissivePickup);

            float useMarch = (LW_RayMode == 0) ? 0.0 : 1.0;
            float useGather = (LW_RayMode == 1) ? 0.0 : 1.0;
            float marchBlend = (LW_RayMode == 2) ? 0.62 : useMarch;

            float mixedW = lerp(gatherW * useGather, rayW * useMarch, marchBlend);
            float3 mixedColor = lerp(sampleGatherColor, sampleRayColor, marchBlend);

            rayColor += mixedColor * mixedW;
            rayWeight += mixedW;

            float nearOccluder = step(sampleRayDepth + LW_DepthBias + thickness * 0.25, centerDepth);
            float occluderClose = 1.0 - smoothstep(thickness, thickness * 5.0, abs(rayDelta));
            rayContact += nearOccluder * occluderClose * distanceWeight;
        }
    }
}

void LW_ResolveActiveBudgets(out int activeTaps, out int activeSteps)
{
    int presetTapCap = LW_TierTapCap();
    int presetStepCap = LW_TierStepCap();

    activeTaps = max(1, min(min(LW_DirectionBudget, presetTapCap), LW_MAX_TAPS));
    activeTaps = max(1, int(floor(float(activeTaps) * LW_BudgetScale + 0.5)));

    activeSteps = max(1, min(min(LW_StepBudget, presetStepCap), LW_MAX_STEPS));
    activeSteps = max(1, int(floor(float(activeSteps) * LW_BudgetScale + 0.5)));
}

float4 LW_SampleBatchColorWeight(float2 uv, int batchStart)
{
    int activeTaps = 1;
    int activeSteps = 1;
    LW_ResolveActiveBudgets(activeTaps, activeSteps);

    float3 sourceColor = LW_Source(uv);
    float centerDepth = LW_Depth(uv);
    float centerLuma = LW_Luma(sourceColor);
    float3 centerNormal = LW_PseudoNormal(uv);

    float3 batchColor = 0.0.xxx;
    float batchWeight = 0.0;

    [unroll]
    for (int localTap = 0; localTap < LW_PASS_TAPS; ++localTap)
    {
        int tap = batchStart + localTap;
        if (tap < activeTaps)
        {
            float2 direction = LW_LensDir(uv, tap, activeTaps);
            float growth = lerp(0.65, 1.35, sqrt((float(tap) + 0.5) / max(1.0, float(activeTaps))));
            float3 rayColor = 0.0.xxx;
            float rayWeight = 0.0;
            float rayContact = 0.0;

            LW_MarchOneDirection(uv, centerDepth, centerLuma, centerNormal, direction, activeSteps, growth, rayColor, rayWeight, rayContact);

            batchColor += rayColor;
            batchWeight += rayWeight;
        }
    }

    return float4(batchColor, batchWeight);
}

float4 LW_SampleBatchContact(float2 uv, int batchStart)
{
    int activeTaps = 1;
    int activeSteps = 1;
    LW_ResolveActiveBudgets(activeTaps, activeSteps);

    float3 sourceColor = LW_Source(uv);
    float centerDepth = LW_Depth(uv);
    float centerLuma = LW_Luma(sourceColor);
    float3 centerNormal = LW_PseudoNormal(uv);

    float batchContact = 0.0;

    [unroll]
    for (int localTap = 0; localTap < LW_PASS_TAPS; ++localTap)
    {
        int tap = batchStart + localTap;
        if (tap < activeTaps)
        {
            float2 direction = LW_LensDir(uv, tap, activeTaps);
            float growth = lerp(0.65, 1.35, sqrt((float(tap) + 0.5) / max(1.0, float(activeTaps))));
            float3 rayColor = 0.0.xxx;
            float rayWeight = 0.0;
            float rayContact = 0.0;

            LW_MarchOneDirection(uv, centerDepth, centerLuma, centerNormal, direction, activeSteps, growth, rayColor, rayWeight, rayContact);

            batchContact += rayContact;
        }
    }

    return float4(batchContact, 0.0, 0.0, 1.0);
}

float4 GoldenWeave_RMGI_Redux_CW0_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchColorWeight(uv, 0); }
float4 GoldenWeave_RMGI_Redux_CW1_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchColorWeight(uv, 6); }
float4 GoldenWeave_RMGI_Redux_CW2_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchColorWeight(uv, 12); }
float4 GoldenWeave_RMGI_Redux_CW3_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchColorWeight(uv, 18); }

float4 GoldenWeave_RMGI_Redux_CT0_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchContact(uv, 0); }
float4 GoldenWeave_RMGI_Redux_CT1_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchContact(uv, 6); }
float4 GoldenWeave_RMGI_Redux_CT2_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchContact(uv, 12); }
float4 GoldenWeave_RMGI_Redux_CT3_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target { return LW_SampleBatchContact(uv, 18); }

float4 GoldenWeave_RMGI_Redux_PS(float4 position : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    int activeTaps = 1;
    int activeSteps = 1;
    LW_ResolveActiveBudgets(activeTaps, activeSteps);

    float3 sourceColor = LW_Source(uv);
    float centerDepth = LW_Depth(uv);
    float centerLuma = LW_Luma(sourceColor);
    float3 centerNormal = LW_PseudoNormal(uv);

    float depthEdge = LW_DepthEdge(uv);
    float colorEdge = LW_ColorEdge(uv);
    float depthValidity = LW_DepthValidity(centerDepth, depthEdge);

    float4 cw0 = tex2Dlod(LW_ReduxCW0Sampler, float4(saturate(uv), 0.0, 0.0));
    float4 cw1 = tex2Dlod(LW_ReduxCW1Sampler, float4(saturate(uv), 0.0, 0.0));
    float4 cw2 = tex2Dlod(LW_ReduxCW2Sampler, float4(saturate(uv), 0.0, 0.0));
    float4 cw3 = tex2Dlod(LW_ReduxCW3Sampler, float4(saturate(uv), 0.0, 0.0));

    float4 ct0 = tex2Dlod(LW_ReduxCT0Sampler, float4(saturate(uv), 0.0, 0.0));
    float4 ct1 = tex2Dlod(LW_ReduxCT1Sampler, float4(saturate(uv), 0.0, 0.0));
    float4 ct2 = tex2Dlod(LW_ReduxCT2Sampler, float4(saturate(uv), 0.0, 0.0));
    float4 ct3 = tex2Dlod(LW_ReduxCT3Sampler, float4(saturate(uv), 0.0, 0.0));

    float3 gathered = sourceColor + cw0.rgb + cw1.rgb + cw2.rgb + cw3.rgb;
    float gatheredWeight = 1.0 + cw0.a + cw1.a + cw2.a + cw3.a;
    float contactAccum = ct0.r + ct1.r + ct2.r + ct3.r;

    float rayBudget = max(1.0, float(activeTaps * activeSteps));
    float hitCoverage = saturate((gatheredWeight - 1.0) / rayBudget);
    float contact = saturate(contactAccum / rayBudget);

    float3 indirect = gathered / max(LW_EPS, gatheredWeight);
    indirect = LW_SaturateAroundLuma(indirect, LW_BounceSaturation);
    indirect = LW_ApplyTemperature(indirect, LW_ColorTemperature);

    float3 rawBounce = max(0.0.xxx, indirect - sourceColor);
    float3 colorShift = (indirect - sourceColor) * LW_ColorBleed;
    float3 bounce = min(rawBounce + max(0.0.xxx, colorShift), LW_ContributionClamp.xxx);

    float appField = LW_ApplicationField(uv, centerDepth, centerLuma, depthEdge, colorEdge, hitCoverage, contact);
    float coverageMask = pow(saturate(hitCoverage * appField * depthValidity), max(0.25, LW_ResponseCurve));

    float fogProtect = smoothstep(LW_FogStart, 1.0, centerDepth) * LW_FogProtect;
    float lightProtect = smoothstep(LW_HighlightThreshold, LW_HighlightThreshold + 0.30, centerLuma) * LW_LightProtect;
    float edgeProtect = saturate(max(depthEdge * LW_StabilityBlend, max(depthEdge, colorEdge) * LW_EdgePreserve));
    float guardMask = saturate(max(max(fogProtect, lightProtect), edgeProtect));

    float strength = LW_GIStrength * LW_TierStrengthScale();
    float3 giLift = bounce * strength * coverageMask;
    float3 contactShade = sourceColor * (1.0 - contact * LW_ContactShadow * coverageMask);

    float3 giColor = saturate(contactShade + giLift);
    float3 localContrast = sourceColor - LW_Source(uv + LW_Pixel() * 1.25);
    giColor = saturate(giColor + localContrast * LW_DetailRestore * (1.0 - guardMask));

    float3 guarded = lerp(giColor, sourceColor, guardMask);
    float3 finalColor = lerp(sourceColor, guarded, LW_SceneBlend);

    float samplingPattern = LW_LensPatternPreview(uv, activeTaps);
    float3 normalView = centerNormal * 0.5 + 0.5;

    if (LW_ViewOutput == 1) return float4(saturate(indirect), 1.0);
    if (LW_ViewOutput == 2) return float4(LW_DebugScalar(contact).xxx, 1.0);
    if (LW_ViewOutput == 3) return float4(LW_DebugScalar(appField).xxx, 1.0);
    if (LW_ViewOutput == 4) return float4(LW_DebugScalar(samplingPattern).xxx, 1.0);
    if (LW_ViewOutput == 5) return float4(LW_DebugScalar(depthValidity).xxx, 1.0);
    if (LW_ViewOutput == 6) return float4(LW_DebugScalar(depthEdge).xxx, 1.0);
    if (LW_ViewOutput == 7) return float4(saturate(normalView), 1.0);
    if (LW_ViewOutput == 8) return float4(LW_DebugScalar(guardMask).xxx, 1.0);
    if (LW_ViewOutput == 9) return float4(LW_DebugScalar(hitCoverage).xxx, 1.0);
    if (LW_ViewOutput == 10) return float4(saturate(rawBounce * 4.0), 1.0);
    if (LW_ViewOutput == 11) return float4(LW_DebugScalar(fogProtect).xxx, 1.0);
    if (LW_ViewOutput == 12) return float4(LW_DebugScalar(lightProtect).xxx, 1.0);

    return float4(saturate(finalColor), 1.0);
}

technique GoldenWeave_RMGI_Redux <
    ui_label = "GoldenWeave - Ray-Marched GI - Redux";
    ui_tooltip = "Standalone screen-space ray-marched global illumination, split into bounded sampling passes to avoid X3511 loop-unroll failure.";
>
{
    pass GoldenWeave_RMGI_Redux_ColorWeight_0
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CW0_PS;
        RenderTarget = LW_ReduxCW0Tex;
    }

    pass GoldenWeave_RMGI_Redux_ColorWeight_1
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CW1_PS;
        RenderTarget = LW_ReduxCW1Tex;
    }

    pass GoldenWeave_RMGI_Redux_ColorWeight_2
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CW2_PS;
        RenderTarget = LW_ReduxCW2Tex;
    }

    pass GoldenWeave_RMGI_Redux_ColorWeight_3
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CW3_PS;
        RenderTarget = LW_ReduxCW3Tex;
    }

    pass GoldenWeave_RMGI_Redux_Contact_0
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CT0_PS;
        RenderTarget = LW_ReduxCT0Tex;
    }

    pass GoldenWeave_RMGI_Redux_Contact_1
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CT1_PS;
        RenderTarget = LW_ReduxCT1Tex;
    }

    pass GoldenWeave_RMGI_Redux_Contact_2
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CT2_PS;
        RenderTarget = LW_ReduxCT2Tex;
    }

    pass GoldenWeave_RMGI_Redux_Contact_3
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_CT3_PS;
        RenderTarget = LW_ReduxCT3Tex;
    }

    pass GoldenWeave_RMGI_Redux_Final
    {
        VertexShader = PostProcessVS;
        PixelShader = GoldenWeave_RMGI_Redux_PS;
    }
}
