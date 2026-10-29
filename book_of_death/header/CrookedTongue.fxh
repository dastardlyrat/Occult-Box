#ifndef CROOKED_TONGUE_FXH
#define CROOKED_TONGUE_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"
#include "shared_lens55.fxh"

#define CROOKED_HATCH_OFF 0
#define CROOKED_HATCH_BIO 1
#define CROOKED_HATCH_FIVE_STAGE 2
#define CROOKED_HATCH_LOG_SPIRAL 3
#define CROOKED_HATCH_ADAPTIVE_CLARITY 4
#define CROOKED_HATCH_STABILITY 5
#define CROOKED_HATCH_CROSS 6

float CROOKED_Luma(float3 c)
{
    return SHARED_Luma(c);
}

float CROOKED_Depth(float2 uv)
{
    return saturate(ReShade::GetLinearizedDepth(saturate(uv)));
}

float CROOKED_Edge(float2 uv)
{
    float2 px = SHARED_PixelSize();
    float c = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb);
    float r = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(px.x, 0.0)), 0.0, 0.0)).rgb);
    float l = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(px.x, 0.0)), 0.0, 0.0)).rgb);
    float u = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, px.y)), 0.0, 0.0)).rgb);
    float d = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(0.0, px.y)), 0.0, 0.0)).rgb);
    return saturate((abs(c - r) + abs(c - l) + abs(c - u) + abs(c - d)) * 4.0);
}

float CROOKED_StabilityMask(float2 uv, float3 sourceColor)
{
    float depthValid = SHARED_DepthAvailability(saturate(uv), 0, 0, 256.0, 0.001);
    float depthReject = 1.0 - SHARED_DepthRejectMask(saturate(uv), 0, 0, 256.0, 0.001, CROOKED_ClarityRadius, CROOKED_StabilityDepthRejectStart);
    depthReject = smoothstep(CROOKED_StabilityDepthRejectStart, CROOKED_StabilityDepthRejectEnd, depthReject);

    float luma = CROOKED_Luma(sourceColor);
    float2 px = SHARED_PixelSize();
    float lumaR = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(px.x, 0.0)), 0.0, 0.0)).rgb);
    float lumaU = CROOKED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, px.y)), 0.0, 0.0)).rgb);
    float lumaDelta = max(abs(luma - lumaR), abs(luma - lumaU));
    float lumaReject = saturate(max(0.0, lumaDelta - 0.012) * CROOKED_StabilityLumaResponse);
    float edgeReject = saturate(CROOKED_Edge(uv) * CROOKED_StabilityEdgeInfluence);

    float stability = 1.0 - max(depthReject, max(lumaReject, edgeReject));
    return saturate(stability * depthValid);
}

float2 CROOKED_OrganicDirection(float2 lensOffset, float fibIndex, float2 uv, float tapNorm)
{
    float2 lensDir = normalize(float2(0.23 - lensOffset.y, 0.17 + lensOffset.x + frac(fibIndex * 0.000618)));
    float armAngle = (6.2831853 * frac(fibIndex * 0.61803398875)) + dot(uv * (CROOKED_Density * 18.0), float2(0.1618, 0.2718));
    float2 branchDir = normalize(SHARED_Rotate(lensDir, degrees(armAngle + tapNorm * CROOKED_SpiralTightness)));
    return normalize(lerp(lensDir, branchDir, CROOKED_BranchBlend * 0.65));
}

float CROOKED_Line(float2 p, float2 dir, float phase, float density)
{
    float v = sin(dot(p, dir) * density + phase);
    return smoothstep(0.72, 0.96, v);
}

float CROOKED_MidtoneMask(float luma)
{
    float lower = smoothstep(0.08, 0.45, luma);
    float upper = 1.0 - smoothstep(0.55, 0.95, luma);
    return saturate(lerp(lower * upper, lower, CROOKED_MidtoneBias));
}

float CROOKED_ProceduralBioPattern(float2 uv)
{
    float2 p = uv * CROOKED_PatternScale;
    float sumValue = 0.0;
    float sumWeight = 0.0;
    int tapCount = clamp(CROOKED_TapBudget, 3, 34);

    [loop]
    for (int i = 0; i < SHARED_LENS55_TAP_COUNT; ++i)
    {
        if (i >= tapCount) break;
        float2 o = SHARED_Lens55Offset(i);
        float fi = CROOKED_FibonacciAnchor + float(i);
        float tapNorm = (float(i) + 0.5) / 55.0;
        float2 dir = CROOKED_OrganicDirection(o, fi, uv, tapNorm);
        float phase = fi * 0.013 + CROOKED_Flow * 0.15 + dot(uv * (CROOKED_Density * 48.0), float2(0.754, 0.569));
        float hatch = CROOKED_Line(p + o * CROOKED_TapSpread, dir, phase, CROOKED_Density);
        sumValue += hatch;
        sumWeight += 1.0;
    }

    return saturate(sumValue / max(0.00001, sumWeight));
}

float CROOKED_FiveStagePattern(float2 uv, float depth, float localContrast)
{
    float smallScale = CROOKED_PatternScale * 1.30;
    float medScale = CROOKED_PatternScale * 1.00;
    float verySmallScale = CROOKED_PatternScale * 1.70;

    float small = saturate((sin((uv.x + uv.y) * smallScale + depth * 21.0) * sin((uv.x - uv.y) * (smallScale * 0.825) - depth * 17.0) * 0.5 + 0.5));
    float med = saturate((sin((uv.x + uv.y) * medScale + depth * 19.0) * sin((uv.x - uv.y) * (medScale * 0.810) - depth * 15.0) * 0.5 + 0.5));
    float tiny = saturate((sin((uv.x + uv.y) * verySmallScale + depth * 23.0) * sin((uv.x - uv.y) * (verySmallScale * 0.840) - depth * 19.0) * 0.5 + 0.5));

    float stagePos = saturate(depth);
    float wNear = 1.0 - saturate(abs(stagePos - 0.10) / 0.30);
    float wForward = 1.0 - saturate(abs(stagePos - 0.32) / 0.30);
    float wCenter = 1.0 - saturate(abs(stagePos - 0.50) / 0.30);
    float wBack = 1.0 - saturate(abs(stagePos - 0.68) / 0.30);
    float wFar = 1.0 - saturate(abs(stagePos - 0.90) / 0.30);

    float blended = (small * wNear + med * wForward + tiny * wCenter + med * wBack + small * wFar) / max(0.00001, wNear + wForward + wCenter + wBack + wFar);
    return saturate(lerp(blended, blended * (0.6 + localContrast * 0.4), 0.5));
}

float CROOKED_LogSpiralPattern(float2 uv)
{
    float2 p = (uv - 0.5) * CROOKED_PatternScale * 0.006;
    float radius = max(0.001, length(p));
    float angle = atan2(p.y, p.x);
    float sumValue = 0.0;

    [loop]
    for (int branch = 0; branch < 8; ++branch)
    {
        if (branch >= CROOKED_BranchCount) break;
        float branchPhase = 6.2831853 * (float(branch) / max(2.0, float(CROOKED_BranchCount)));
        float spiral = cos(log(radius * CROOKED_SpiralGrowth + 1.0) * (6.0 * CROOKED_SpiralTightness) - angle * float(CROOKED_BranchCount) + branchPhase + CROOKED_Flow);
        sumValue += smoothstep(0.35, 0.95, spiral);
    }

    return saturate(sumValue / max(1.0, float(CROOKED_BranchCount)));
}

float CROOKED_CrossHatchPattern(float2 uv, float3 sourceColor)
{
    float2 p = uv * CROOKED_PatternScale;
    float luma = CROOKED_Luma(sourceColor);
    float darkness = 1.0 - smoothstep(0.18, 0.88, luma);
    float diagA = CROOKED_Line(p, normalize(float2(1.0, 1.0)), CROOKED_Flow, CROOKED_Density);
    float diagB = CROOKED_Line(p, normalize(float2(1.0, -1.0)), CROOKED_Flow * 1.17 + 1.3, CROOKED_Density * 0.92);
    float layerA = diagA * smoothstep(0.10, 0.75, darkness);
    float layerB = diagB * smoothstep(0.42, 0.98, darkness);
    return saturate(max(layerA, layerB));
}

float2 CROOKED_KernelDirection(float degreesValue)
{
    float a = radians(degreesValue);
    return float2(cos(a), sin(a));
}

float CROOKED_HatchMask(float2 uv, float3 sourceColor)
{
    float luma = CROOKED_Luma(sourceColor);
    float shadow = 1.0 - smoothstep(0.35, 0.85, luma);
    float depth = CROOKED_Depth(uv);
    float edge = CROOKED_Edge(uv);
    return saturate(shadow * (0.55 + edge * 0.45) * (0.55 + depth * 0.45));
}

float CROOKED_DepthStage(float2 uv)
{
    float depth = CROOKED_Depth(uv);
    float wNear = 1.0 - saturate(abs(depth - 0.10) / 0.25);
    float wForward = 1.0 - saturate(abs(depth - 0.32) / 0.25);
    float wCenter = 1.0 - saturate(abs(depth - 0.50) / 0.25);
    float wBack = 1.0 - saturate(abs(depth - 0.68) / 0.25);
    float wFar = 1.0 - saturate(abs(depth - 0.90) / 0.25);
    return saturate(max(max(wNear, wForward), max(wCenter, max(wBack, wFar))));
}

float CROOKED_AdaptiveClarityToneGate(float3 sourceColor)
{
    float luma = CROOKED_Luma(sourceColor);
    float midtoneMask = CROOKED_MidtoneMask(luma);
    float highlightGuard = 1.0 - smoothstep(0.65, 1.0, luma) * CROOKED_HighlightProtect;
    return saturate(midtoneMask * highlightGuard);
}

float CROOKED_StructuralGate(float2 uv, float3 sourceColor)
{
    float result = 1.0;

    if (CROOKED_HatchMode == CROOKED_HATCH_FIVE_STAGE)
        result = CROOKED_DepthStage(uv);
    else if (CROOKED_HatchMode == CROOKED_HATCH_ADAPTIVE_CLARITY)
        result = CROOKED_AdaptiveClarityToneGate(sourceColor);
    else if (CROOKED_HatchMode == CROOKED_HATCH_STABILITY)
        result = CROOKED_StabilityMask(uv, sourceColor);

    return result;
}

float CROOKED_ActivePattern(float2 uv, float3 sourceColor)
{
    float depth = CROOKED_Depth(uv);
    float contrast = saturate(SHARED_LocalContrast(uv, sourceColor) * 2.0);
    float result = 0.0;

    if (CROOKED_HatchMode == CROOKED_HATCH_BIO)
        result = CROOKED_ProceduralBioPattern(uv);
    else if (CROOKED_HatchMode == CROOKED_HATCH_FIVE_STAGE)
        result = CROOKED_FiveStagePattern(uv, depth, contrast);
    else if (CROOKED_HatchMode == CROOKED_HATCH_LOG_SPIRAL)
        result = CROOKED_LogSpiralPattern(uv);
    else if (CROOKED_HatchMode == CROOKED_HATCH_ADAPTIVE_CLARITY)
        result = CROOKED_ProceduralBioPattern(uv);
    else if (CROOKED_HatchMode == CROOKED_HATCH_STABILITY)
        result = CROOKED_ProceduralBioPattern(uv);
    else if (CROOKED_HatchMode == CROOKED_HATCH_CROSS)
        result = CROOKED_CrossHatchPattern(uv, sourceColor);

    return result;
}

void CROOKED_AdaptiveClarity(float2 uv, float3 sourceColor, out float3 resultColor, out float3 deltaColor, out float sharpenMask)
{
    float2 px = SHARED_PixelSize() * CROOKED_ClarityRadius;
    float2 dirA = CROOKED_KernelDirection(CROOKED_KernelAngle);
    float2 dirB = float2(-dirA.y, dirA.x);
    float2 dirC = normalize(dirA + dirB);
    float2 dirD = normalize(dirA - dirB);

    float3 sA0 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + dirA * px), 0.0, 0.0)).rgb;
    float3 sA1 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - dirA * px), 0.0, 0.0)).rgb;
    float3 sB0 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + dirB * px), 0.0, 0.0)).rgb;
    float3 sB1 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - dirB * px), 0.0, 0.0)).rgb;
    float3 sC0 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + dirC * px * 0.85), 0.0, 0.0)).rgb;
    float3 sC1 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - dirC * px * 0.85), 0.0, 0.0)).rgb;
    float3 sD0 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + dirD * px * 0.85), 0.0, 0.0)).rgb;
    float3 sD1 = tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - dirD * px * 0.85), 0.0, 0.0)).rgb;

    float3 organicBlur = (sourceColor + sA0 + sA1 + sB0 + sB1 + sC0 + sC1 + sD0 + sD1) / 9.0;
    float3 ringMin = min(sourceColor, min(min(sA0, sA1), min(min(sB0, sB1), min(min(sC0, sC1), min(sD0, sD1)))));
    float3 ringMax = max(sourceColor, max(max(sA0, sA1), max(max(sB0, sB1), max(max(sC0, sC1), max(sD0, sD1)))));

    float3 ampRgb = saturate(min(ringMin, 1.0 - ringMax) / max(ringMax, 0.00001));
    ampRgb = sqrt(ampRgb);
    sharpenMask = (ampRgb.r + ampRgb.g + ampRgb.b) / 3.0;

    float3 sharpened = sourceColor + (sourceColor - organicBlur) * (CROOKED_HatchStrength * sharpenMask);
    sharpened = saturate(sourceColor + clamp(sharpened - sourceColor, -0.05, 0.05));

    deltaColor = sharpened - organicBlur;
    float luma = CROOKED_Luma(sharpened);
    float midtoneMask = CROOKED_MidtoneMask(luma);
    float highlightGuard = 1.0 - smoothstep(0.65, 1.0, luma) * CROOKED_HighlightProtect;
    float hatchWeight = CROOKED_ProceduralBioPattern(uv) * CROOKED_HatchMask(uv, sourceColor);
    float clarityWeight = CROOKED_HatchStrength * midtoneMask * highlightGuard * hatchWeight;
    resultColor = saturate(sharpened + deltaColor * clarityWeight);
}

float CROOKED_FinalShadingField(float2 uv, float3 sourceColor)
{
    float result = 0.0;

    if (CROOKED_HatchMode == CROOKED_HATCH_ADAPTIVE_CLARITY)
    {
        float luma = CROOKED_Luma(sourceColor);
        float midtoneMask = CROOKED_MidtoneMask(luma);
        float highlightGuard = 1.0 - smoothstep(0.65, 1.0, luma) * CROOKED_HighlightProtect;
        float hatchWeight = CROOKED_ProceduralBioPattern(uv) * CROOKED_HatchMask(uv, sourceColor);
        result = saturate(CROOKED_HatchStrength * midtoneMask * highlightGuard * hatchWeight);
    }
    else if (CROOKED_HatchMode == CROOKED_HATCH_STABILITY)
    {
        float pattern = CROOKED_ProceduralBioPattern(uv);
        float stability = CROOKED_StabilityMask(uv, sourceColor);
        result = saturate(pattern * stability * CROOKED_HatchStrength);
    }
    else
    {
        float pattern = CROOKED_ActivePattern(uv, sourceColor);
        float placementMask = CROOKED_HatchMask(uv, sourceColor);
        result = saturate(pattern * placementMask * CROOKED_HatchStrength);
    }

    return result;
}

float3 CROOKED_ShadedPreview(float2 uv, float3 sourceColor)
{
    float3 resultColor = sourceColor;

    if (CROOKED_HatchMode == CROOKED_HATCH_ADAPTIVE_CLARITY)
    {
        float3 deltaColor = 0.0.xxx;
        float sharpenMask = 0.0;
        CROOKED_AdaptiveClarity(uv, sourceColor, resultColor, deltaColor, sharpenMask);
    }
    else if (CROOKED_HatchMode == CROOKED_HATCH_STABILITY)
    {
        float pattern = CROOKED_ProceduralBioPattern(uv);
        float stability = CROOKED_StabilityMask(uv, sourceColor);
        float ink = pattern * stability * CROOKED_HatchStrength;
        resultColor = saturate(sourceColor * (1.0 - ink * 0.70));
    }
    else
    {
        float pattern = CROOKED_ActivePattern(uv, sourceColor);
        float mask = CROOKED_HatchMask(uv, sourceColor);
        float ink = pattern * mask * CROOKED_HatchStrength;
        resultColor = saturate(sourceColor * (1.0 - ink * 0.85));
    }

    return resultColor;
}

float4 CROOKED_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 source = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    if (CROOKED_Enable == 0 || CROOKED_DebugView == 0 || CROOKED_HatchMode == CROOKED_HATCH_OFF)
        return float4(source, 1.0);

    float3 outColor = source;
    if (CROOKED_DebugView == 1) outColor = CROOKED_DebugShape3((CROOKED_ActivePattern(uv, source)).xxx);
    else if (CROOKED_DebugView == 2) outColor = CROOKED_DebugShape3((CROOKED_StructuralGate(uv, source)).xxx);
    else if (CROOKED_DebugView == 3) outColor = CROOKED_DebugShape3((CROOKED_HatchMask(uv, source)).xxx);
    else if (CROOKED_DebugView == 4) outColor = CROOKED_DebugShape3((CROOKED_FinalShadingField(uv, source)).xxx);
    else if (CROOKED_DebugView == 5) outColor = CROOKED_ShadedPreview(uv, source);
    else if (CROOKED_DebugView == 6)
    {
        float3 resultColor = source;
        float3 deltaColor = 0.0.xxx;
        float sharpenMask = 0.0;
        if (CROOKED_HatchMode == CROOKED_HATCH_ADAPTIVE_CLARITY)
        {
            CROOKED_AdaptiveClarity(uv, source, resultColor, deltaColor, sharpenMask);
            outColor = CROOKED_DebugShape3(deltaColor * 4.0 + 0.5);
        }
        else
        {
            outColor = CROOKED_DebugShape3((CROOKED_ActivePattern(uv, source)).xxx);
        }
    }
    else outColor = CROOKED_DebugShape3((CROOKED_StabilityMask(uv, source)).xxx);

    return float4(saturate(outColor), 1.0);
}

#endif
