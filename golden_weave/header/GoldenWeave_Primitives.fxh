#ifndef LUMENWEAVE_PRIMITIVES_FXH
#define LUMENWEAVE_PRIMITIVES_FXH

// GoldenWeave primitive layer.
// No UI uniforms are declared in this header.
// This file is intentionally local and project-neutral: it re-expresses the useful primitive families
// as source/depth/color/safe/lens/mask/ray-gather atoms for a screen-space ReShade GI pass.

#define LWPR_PI 3.14159265358979323846
#define LWPR_TAU 6.28318530717958647692
#define LWPR_GOLDEN_ANGLE 2.39996322972865332
#define LWPR_EPS 0.000010
#define LWPR_MAX_TAPS 24
#define LWPR_MAX_STEPS 8

struct LWPR_Surface
{
    float3 color;
    float  depth;
    float  luma;
    float3 normal;
    float  depthEdge;
    float  colorEdge;
    float  depthValidity;
};

struct LWPR_RayResult
{
    float3 color;
    float  weight;
    float  contact;
};

float2 LWPR_Pixel()
{
    return float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
}

float2 LWPR_SaturateUV(float2 uv)
{
    return saturate(uv);
}

float3 LWPR_Source(float2 uv)
{
    return tex2Dlod(ReShade::BackBuffer, float4(LWPR_SaturateUV(uv), 0.0, 0.0)).rgb;
}

float LWPR_Depth(float2 uv)
{
    return saturate(ReShade::GetLinearizedDepth(LWPR_SaturateUV(uv)));
}

float LWPR_Luma(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

float LWPR_SafeRcp(float v)
{
    return rcp(max(abs(v), LWPR_EPS));
}

float2 LWPR_SafeNorm2(float2 v, float2 fallbackValue)
{
    float len2 = dot(v, v);
    return (len2 > LWPR_EPS) ? v * rsqrt(len2) : fallbackValue;
}

float3 LWPR_SafeNorm3(float3 v, float3 fallbackValue)
{
    float len2 = dot(v, v);
    return (len2 > LWPR_EPS) ? v * rsqrt(len2) : fallbackValue;
}

float2 LWPR_Rotate2(float2 v, float radiansValue)
{
    float s = sin(radiansValue);
    float c = cos(radiansValue);
    return float2(c * v.x - s * v.y, s * v.x + c * v.y);
}

float LWPR_Hash21(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}

float LWPR_DebugScalar(float value)
{
    return pow(abs(saturate(value)), 0.65);
}

float3 LWPR_SaturateAroundLuma(float3 color, float amount)
{
    float luma = LWPR_Luma(color);
    return lerp(luma.xxx, color, amount);
}

float3 LWPR_ApplyTemperature(float3 color, float temperature)
{
    float warm = saturate(temperature);
    float cool = saturate(-temperature);
    float3 warmed = color * float3(1.0 + 0.18 * warm, 1.0 + 0.06 * warm, 1.0 - 0.12 * warm);
    float3 cooled = warmed * float3(1.0 - 0.10 * cool, 1.0 + 0.03 * cool, 1.0 + 0.18 * cool);
    return max(0.0.xxx, cooled);
}

int LWPR_TierTapCap(int qualityPreset)
{
    int result = LWPR_MAX_TAPS;
    if (qualityPreset == 0) result = 6;
    else if (qualityPreset == 1) result = 12;
    else if (qualityPreset == 2) result = 18;
    return result;
}

int LWPR_TierStepCap(int qualityPreset)
{
    int result = LWPR_MAX_STEPS;
    if (qualityPreset == 0) result = 2;
    else if (qualityPreset == 1) result = 4;
    else if (qualityPreset == 2) result = 6;
    return result;
}

float LWPR_TierLengthScale(int qualityPreset)
{
    float result = 1.25;
    if (qualityPreset == 0) result = 0.65;
    else if (qualityPreset == 1) result = 0.90;
    else if (qualityPreset == 2) result = 1.10;
    return result;
}

float LWPR_TierStrengthScale(int qualityPreset)
{
    float result = 1.30;
    if (qualityPreset == 0) result = 0.70;
    else if (qualityPreset == 1) result = 1.00;
    else if (qualityPreset == 2) result = 1.18;
    return result;
}

float3 LWPR_PseudoNormal(float2 uv, float normalDirectionality)
{
    float2 px = LWPR_Pixel();
    float dR = LWPR_Depth(uv + float2(px.x, 0.0));
    float dL = LWPR_Depth(uv - float2(px.x, 0.0));
    float dU = LWPR_Depth(uv + float2(0.0, px.y));
    float dD = LWPR_Depth(uv - float2(0.0, px.y));
    float zScale = max(px.x, px.y) * 72.0 + 0.050;
    return LWPR_SafeNorm3(float3((dL - dR) * normalDirectionality, (dD - dU) * normalDirectionality, zScale), float3(0.0, 0.0, 1.0));
}

float LWPR_DepthEdge4(float2 uv, float depthThickness)
{
    float2 px = LWPR_Pixel();
    float center = LWPR_Depth(uv);
    float d0 = abs(LWPR_Depth(uv + float2(px.x, 0.0)) - center);
    float d1 = abs(LWPR_Depth(uv - float2(px.x, 0.0)) - center);
    float d2 = abs(LWPR_Depth(uv + float2(0.0, px.y)) - center);
    float d3 = abs(LWPR_Depth(uv - float2(0.0, px.y)) - center);
    return saturate((d0 + d1 + d2 + d3) / max(0.0001, depthThickness * 8.0));
}

float LWPR_ColorEdge4(float2 uv)
{
    float2 px = LWPR_Pixel();
    float center = LWPR_Luma(LWPR_Source(uv));
    float c0 = abs(LWPR_Luma(LWPR_Source(uv + float2(px.x, 0.0))) - center);
    float c1 = abs(LWPR_Luma(LWPR_Source(uv - float2(px.x, 0.0))) - center);
    float c2 = abs(LWPR_Luma(LWPR_Source(uv + float2(0.0, px.y))) - center);
    float c3 = abs(LWPR_Luma(LWPR_Source(uv - float2(0.0, px.y))) - center);
    return saturate((c0 + c1 + c2 + c3) * 5.0);
}

float LWPR_DepthValidity(float centerDepth, float depthEdge, float depthEdgeReject, float skyProtect)
{
    float notSky = 1.0 - smoothstep(0.985, 1.0, centerDepth) * skyProtect;
    float edgeValid = lerp(1.0, 1.0 - depthEdge, depthEdgeReject);
    return saturate(notSky * edgeValid);
}

LWPR_Surface LWPR_ReadSurface(
    float2 uv,
    float depthThickness,
    float depthEdgeReject,
    float skyProtect,
    float normalDirectionality)
{
    LWPR_Surface s;
    s.color = LWPR_Source(uv);
    s.depth = LWPR_Depth(uv);
    s.luma = LWPR_Luma(s.color);
    s.normal = LWPR_PseudoNormal(uv, normalDirectionality);
    s.depthEdge = LWPR_DepthEdge4(uv, depthThickness);
    s.colorEdge = LWPR_ColorEdge4(uv);
    s.depthValidity = LWPR_DepthValidity(s.depth, s.depthEdge, depthEdgeReject, skyProtect);
    return s;
}

float2 LWPR_LensDirection(
    float2 uv,
    int index,
    int count,
    int samplingLens,
    float fibonacciAnchor,
    float rayRotation,
    float organicDrift)
{
    float fi = float(index);
    float fc = max(1.0, float(count));
    float base = fibonacciAnchor + fi + 0.5;
    float n = (fi + 0.5) / fc;
    float angle = base * LWPR_GOLDEN_ANGLE + rayRotation;
    float radius = sqrt(n);

    float2 dir = float2(cos(angle), sin(angle)) * radius;

    if (samplingLens == 0)
    {
        dir = float2(cos(angle), sin(angle));
    }
    else if (samplingLens == 1)
    {
        dir = float2(cos(angle), sin(angle)) * sqrt(n);
    }
    else if (samplingLens == 2)
    {
        float quadrant = floor(frac((fi + fibonacciAnchor) * 0.25) * 4.0);
        float a = quadrant * (LWPR_PI * 0.5) + (n - 0.5) * 0.35;
        dir = float2(cos(a), sin(a)) * lerp(0.45, 1.0, radius);
    }
    else if (samplingLens == 3)
    {
        float jitter = (LWPR_Hash21(uv * BUFFER_SCREEN_SIZE + fi.xx) - 0.5) * organicDrift;
        dir = float2(cos(angle + jitter), sin(angle + jitter)) * lerp(0.35, 1.0, radius);
    }
    else if (samplingLens == 4)
    {
        float star = floor(frac((fi + 0.5) / 8.0) * 8.0);
        float a = star * (LWPR_TAU / 8.0) + sin(base * 0.37) * 0.18;
        dir = float2(cos(a), sin(a)) * lerp(0.25, 1.0, frac(fi * 0.61803398875 + 0.2));
    }
    else if (samplingLens == 5)
    {
        float dome = acos(1.0 - 2.0 * n);
        float a = angle + sin(dome * 3.0) * 0.25;
        dir = float2(cos(a), sin(a)) * sin(dome);
    }
    else if (samplingLens == 6)
    {
        float a = floor(frac(fi * 0.3333333) * 6.0) * (LWPR_TAU / 6.0);
        float weave = ((frac(fi * 0.5) < 0.5) ? 0.35 : 0.85);
        dir = float2(cos(a), sin(a)) * lerp(weave, 1.0, radius);
    }
    else if (samplingLens == 7)
    {
        float logR = exp(lerp(log(0.08), log(1.0), n));
        dir = float2(cos(angle), sin(angle)) * logR;
    }
    else if (samplingLens == 8)
    {
        float hatch = sin((uv.x + uv.y) * BUFFER_WIDTH * 0.055 + base * 1.71 + organicDrift);
        float a = angle + hatch * 0.65;
        dir = float2(cos(a), sin(a)) * lerp(0.20, 1.0, radius);
    }
    else
    {
        float k = abs(frac(angle / LWPR_TAU) * 2.0 - 1.0);
        float a = floor((angle / LWPR_TAU) * 6.0) * (LWPR_TAU / 6.0);
        dir = lerp(float2(cos(angle), sin(angle)), float2(cos(a), sin(a)), 0.55 * k) * lerp(0.25, 1.0, radius);
    }

    float drift = (LWPR_Hash21(uv * (13.0 + organicDrift) + fi.xx) - 0.5) * 0.18 * organicDrift;
    return LWPR_SafeNorm2(LWPR_Rotate2(dir, drift), float2(1.0, 0.0));
}

float LWPR_LensPatternChunk4(
    float2 localUv,
    float2 cellCenter,
    int tapCount,
    int samplingLens,
    float fibonacciAnchor,
    float rayRotation,
    float organicDrift,
    float radiusScale,
    int tapStart)
{
    float accum = 0.0;

    [unroll]
    for (int localTap = 0; localTap < 4; ++localTap)
    {
        int i = tapStart + localTap;
        if (i < tapCount)
        {
            float2 dir = LWPR_LensDirection(cellCenter, i, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift);
            float2 tapUv = dir * radiusScale;
            float marker = 1.0 - smoothstep(0.0, 0.030, length(localUv - tapUv));
            accum += marker;
        }
    }

    return accum;
}

float LWPR_LensPatternPreview(
    float2 uv,
    int tapCount,
    int samplingLens,
    float fibonacciAnchor,
    float rayRotation,
    float organicDrift,
    float lensRadiusPixels)
{
    float tileCount = 6.0;
    float2 cellUv = frac(uv * tileCount);
    float2 localUv = cellUv - 0.5;
    float2 cellCenter = (floor(uv * tileCount) + 0.5) / tileCount;
    float radiusScale = saturate(lensRadiusPixels / 12.0) * 0.28 + 0.04;

    // Bound-pass structure: six independent 4-tap chunks instead of one large 24-tap unroll.
    float accum = 0.0;
    accum += LWPR_LensPatternChunk4(localUv, cellCenter, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift, radiusScale, 0);
    if (tapCount > 4)  accum += LWPR_LensPatternChunk4(localUv, cellCenter, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift, radiusScale, 4);
    if (tapCount > 8)  accum += LWPR_LensPatternChunk4(localUv, cellCenter, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift, radiusScale, 8);
    if (tapCount > 12) accum += LWPR_LensPatternChunk4(localUv, cellCenter, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift, radiusScale, 12);
    if (tapCount > 16) accum += LWPR_LensPatternChunk4(localUv, cellCenter, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift, radiusScale, 16);
    if (tapCount > 20) accum += LWPR_LensPatternChunk4(localUv, cellCenter, tapCount, samplingLens, fibonacciAnchor, rayRotation, organicDrift, radiusScale, 20);

    float ring = 1.0 - smoothstep(0.006, 0.016, abs(length(localUv) - radiusScale));
    return saturate(accum * 0.32 + ring * 0.25);
}

float LWPR_ApplicationField(
    float2 uv,
    LWPR_Surface surface,
    int applicationLens,
    float applicationStrength,
    float lensRadiusPixels,
    float lensSharpness,
    float fogStart,
    float hitCoverage,
    float contact,
    float lensPattern)
{
    float field = 1.0;

    if (applicationLens == 0)
    {
        field = 1.0;
    }
    else if (applicationLens == 1)
    {
        field = 1.0 - smoothstep(0.0, 1.0, surface.depthEdge);
    }
    else if (applicationLens == 2)
    {
        float2 px = LWPR_Pixel() * lensRadiusPixels;
        float l0 = LWPR_Luma(LWPR_Source(uv + float2(px.x, 0.0)));
        float l1 = LWPR_Luma(LWPR_Source(uv - float2(px.x, 0.0)));
        float l2 = LWPR_Luma(LWPR_Source(uv + float2(0.0, px.y)));
        float l3 = LWPR_Luma(LWPR_Source(uv - float2(0.0, px.y)));
        field = saturate((abs(l0 - surface.luma) + abs(l1 - surface.luma) + abs(l2 - surface.luma) + abs(l3 - surface.luma)) * lensSharpness);
    }
    else if (applicationLens == 3)
    {
        field = saturate(max(surface.depthEdge, surface.colorEdge) * lensSharpness);
    }
    else if (applicationLens == 4)
    {
        field = 1.0 - smoothstep(fogStart, 1.0, surface.depth);
    }
    else if (applicationLens == 5)
    {
        field = lensPattern;
    }
    else
    {
        field = saturate(contact * 1.75 + hitCoverage * 0.65);
    }

    return saturate(lerp(1.0, field, applicationStrength));
}

void LWPR_MarchStepChunk4(
    float2 uv,
    LWPR_Surface surface,
    float2 direction,
    int rayMode,
    int activeSteps,
    float2 marchVector,
    float2 gatherVector,
    float invSteps,
    float thickness,
    float falloff,
    float depthBias,
    float surfaceSpread,
    float normalDirectionality,
    float emissivePickup,
    float highlightThreshold,
    int stepStart,
    inout LWPR_RayResult r)
{
    [unroll]
    for (int localStep = 0; localStep < 4; ++localStep)
    {
        int s = stepStart + localStep;
        if (s <= activeSteps)
        {
            float t = float(s) * invSteps;
            float2 rayUv = uv + marchVector * t;
            float2 gatherUv = uv + gatherVector;
            float3 sampleRayColor = LWPR_Source(rayUv);
            float3 sampleGatherColor = LWPR_Source(gatherUv);
            float sampleRayDepth = LWPR_Depth(rayUv);
            float sampleGatherDepth = LWPR_Depth(gatherUv);

            float rayDelta = sampleRayDepth - surface.depth;
            float gatherDelta = sampleGatherDepth - surface.depth;

            float raySurface = 1.0 - smoothstep(thickness, thickness * (1.0 + surfaceSpread * 3.0), abs(rayDelta));
            float gatherSurface = 1.0 - smoothstep(thickness, thickness * (1.0 + surfaceSpread * 2.0), abs(gatherDelta));

            float rayBehind = step(surface.depth - depthBias, sampleRayDepth + thickness);
            float gatherBehind = step(surface.depth - depthBias, sampleGatherDepth + thickness);

            float3 rayDir3 = LWPR_SafeNorm3(float3(direction.xy * normalDirectionality, surfaceSpread), float3(0.0, 0.0, 1.0));
            float normalWeight = saturate(dot(surface.normal, rayDir3) * 0.5 + 0.5);
            float distanceWeight = exp(-t * falloff * 0.0110);

            float brightRay = smoothstep(highlightThreshold, highlightThreshold + 0.35, LWPR_Luma(sampleRayColor));
            float brightGather = smoothstep(highlightThreshold, highlightThreshold + 0.35, LWPR_Luma(sampleGatherColor));

            float rayW = raySurface * rayBehind * normalWeight * distanceWeight * (1.0 + brightRay * emissivePickup);
            float gatherW = gatherSurface * gatherBehind * normalWeight * (1.0 + brightGather * emissivePickup);

            float useMarch = (rayMode == 0) ? 0.0 : 1.0;
            float useGather = (rayMode == 1) ? 0.0 : 1.0;
            float marchBlend = (rayMode == 2) ? 0.62 : useMarch;

            float mixedW = lerp(gatherW * useGather, rayW * useMarch, marchBlend);
            float3 mixedColor = lerp(sampleGatherColor, sampleRayColor, marchBlend);

            r.color += mixedColor * mixedW;
            r.weight += mixedW;

            float nearOccluder = step(sampleRayDepth + depthBias + thickness * 0.25, surface.depth);
            float occluderClose = 1.0 - smoothstep(thickness, thickness * 5.0, abs(rayDelta));
            r.contact += nearOccluder * occluderClose * distanceWeight;
        }
    }
}

LWPR_RayResult LWPR_MarchDirection(
    float2 uv,
    LWPR_Surface surface,
    float2 direction,
    int rayMode,
    int activeSteps,
    int qualityPreset,
    float rayLengthPixels,
    float gatherLengthPixels,
    float depthThickness,
    float depthBias,
    float depthFalloff,
    float surfaceSpread,
    float normalDirectionality,
    float emissivePickup,
    float highlightThreshold,
    float growth)
{
    LWPR_RayResult r;
    r.color = 0.0.xxx;
    r.weight = 0.0;
    r.contact = 0.0;

    float2 px = LWPR_Pixel();
    float tierLength = LWPR_TierLengthScale(qualityPreset);
    float2 marchVector = direction * px * rayLengthPixels * tierLength * growth;
    float2 gatherVector = direction * px * gatherLengthPixels * tierLength * growth;
    float invSteps = rcp(max(1.0, float(activeSteps)));
    float thickness = max(0.0001, depthThickness);
    float falloff = max(0.01, depthFalloff);

    // Bound-pass structure: two separate 4-step regions instead of one large 8-step body.
    LWPR_MarchStepChunk4(uv, surface, direction, rayMode, activeSteps, marchVector, gatherVector, invSteps, thickness, falloff, depthBias, surfaceSpread, normalDirectionality, emissivePickup, highlightThreshold, 1, r);
    if (activeSteps > 4)
    {
        LWPR_MarchStepChunk4(uv, surface, direction, rayMode, activeSteps, marchVector, gatherVector, invSteps, thickness, falloff, depthBias, surfaceSpread, normalDirectionality, emissivePickup, highlightThreshold, 5, r);
    }

    return r;
}

float3 LWPR_GuardedComposite(
    float3 sourceColor,
    float3 indirect,
    float contact,
    float coverageMask,
    float guardMask,
    float giStrength,
    float tierStrength,
    float colorBleed,
    float contributionClamp,
    float contactShadow,
    float detailRestore,
    float sceneBlend,
    float2 uv)
{
    float3 rawBounce = max(0.0.xxx, indirect - sourceColor);
    float3 colorShift = (indirect - sourceColor) * colorBleed;
    float3 bounce = min(rawBounce + max(0.0.xxx, colorShift), contributionClamp.xxx);

    float3 giLift = bounce * giStrength * tierStrength * coverageMask;
    float3 contactShade = sourceColor * (1.0 - contact * contactShadow * coverageMask);
    float3 giColor = saturate(contactShade + giLift);
    float3 localContrast = sourceColor - LWPR_Source(uv + LWPR_Pixel() * 1.25);
    giColor = saturate(giColor + localContrast * detailRestore * (1.0 - guardMask));

    float3 guarded = lerp(giColor, sourceColor, guardMask);
    return lerp(sourceColor, guarded, sceneBlend);
}

#endif
