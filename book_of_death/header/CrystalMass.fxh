#ifndef CRYSTAL_MASS_FXH
#define CRYSTAL_MASS_FXH

#include "shared_core.fxh"
#include "shared_depth.fxh"

#define CRYSTAL_MASK_OFF 0
#define CRYSTAL_MASK_FOG 1
#define CRYSTAL_MASK_LIGHT 2
#define CRYSTAL_MASK_LINE 3
#define CRYSTAL_MASK_PIXEL 4
#define CRYSTAL_MASK_DEPTH 5
#define CRYSTAL_MASK_FAR_DETAIL 6
#define CRYSTAL_MASK_FOREGROUND_GUARD 7
#define CRYSTAL_MASK_CONTRAST 8
#define CRYSTAL_MASK_HUE_WARM 9
#define CRYSTAL_MASK_DIRECTIONAL 10
#define CRYSTAL_MASK_SILHOUETTE 11
#define CRYSTAL_MASK_COMPOSITE 12

float CRYSTAL_Depth(float2 uv)
{
    return SHARED_LinearDepth(saturate(uv), CRYSTAL_DepthMode, CRYSTAL_DepthInvert);
}

float CRYSTAL_DepthAvailability(float2 uv)
{
    return SHARED_DepthAvailability(saturate(uv), CRYSTAL_DepthMode, CRYSTAL_DepthInvert, CRYSTAL_DepthTraceScale, CRYSTAL_DepthAvailabilityThreshold);
}

float CRYSTAL_DepthNear(float depth)
{
    return 1.0 - smoothstep(CRYSTAL_ForegroundNearStart, CRYSTAL_ForegroundNearEnd, depth);
}

float CRYSTAL_DepthFar(float depth)
{
    return smoothstep(CRYSTAL_FarDetailStart, CRYSTAL_FarDetailEnd, depth);
}

float CRYSTAL_DepthEdge(float2 uv)
{
    return SHARED_DepthEdgeMask(saturate(uv), CRYSTAL_DepthMode, CRYSTAL_DepthInvert, CRYSTAL_DepthTraceScale, CRYSTAL_DepthAvailabilityThreshold, CRYSTAL_DepthEdgeThreshold);
}

float CRYSTAL_DepthWindow(float2 uv)
{
    float availability = CRYSTAL_DepthAvailability(uv);
    float depth = CRYSTAL_Depth(uv);
    float d0 = min(CRYSTAL_DepthStart, CRYSTAL_DepthEnd);
    float d1 = max(CRYSTAL_DepthStart, CRYSTAL_DepthEnd);
    float soft = 0.01;
    float beginMask = smoothstep(d0 - soft, d0 + soft, depth);
    float endMask = 1.0 - smoothstep(d1 - soft, d1 + soft, depth);
    return saturate(beginMask * endMask * availability);
}

float CRYSTAL_DebugDepth(float2 uv)
{
    float availability = CRYSTAL_DepthAvailability(uv);
    float depth = CRYSTAL_Depth(uv);
    float shaped = pow(abs(saturate(depth)), 0.65);
    return saturate(shaped * availability);
}

float2 CRYSTAL_LensOffset(int lensMode, int index)
{
    if (lensMode == 0)
    {
        if (index <= 0) return 0.0.xx;
        float angle = (6.2831853 * float(index - 1)) / 8.0;
        return float2(cos(angle), sin(angle));
    }

    if (index <= 0) return 0.0.xx;
    float sampleIndex = float(index - 1);
    float radial = sqrt((sampleIndex + 1.0) / 12.0);
    float angle = (sampleIndex + 0.5) * 2.39996323;
    return float2(cos(angle), sin(angle)) * radial;
}

float3 CRYSTAL_LensAverage(float2 uv, int lensMode, float radiusPixels)
{
    int tapCount = (lensMode == 0) ? 9 : 13;
    float2 px = SHARED_PixelSize() * radiusPixels;
    float3 sumColor = 0.0.xxx;
    float weight = 0.0;

    [loop]
    for (int i = 0; i < 13; ++i)
    {
        if (i >= tapCount) break;
        float2 sampleUv = saturate(uv + CRYSTAL_LensOffset(lensMode, i) * px);
        sumColor += tex2Dlod(ReShade::BackBuffer, float4(sampleUv, 0.0, 0.0)).rgb;
        weight += 1.0;
    }

    return sumColor / max(0.00001, weight);
}

float CRYSTAL_LensContrastMask(float2 uv, float3 source, int lensMode)
{
    float3 averageColor = CRYSTAL_LensAverage(uv, lensMode, 2.0);
    float detail = abs(SHARED_Luma(source) - SHARED_Luma(averageColor)) * max(1.0, CRYSTAL_DetailScale);
    return smoothstep(CRYSTAL_DetailLow, CRYSTAL_DetailHigh, detail);
}

float CRYSTAL_Contrast(float2 uv, float3 source)
{
    float contrast = SHARED_LocalContrast(uv, source);
    return smoothstep(
        CRYSTAL_ContrastThreshold,
        CRYSTAL_ContrastThreshold * max(1.25, CRYSTAL_ContrastGain),
        contrast * CRYSTAL_ContrastGain);
}

float CRYSTAL_ForegroundGuardBlock(float2 uv)
{
    float depth = CRYSTAL_Depth(uv);
    float nearMask = CRYSTAL_DepthNear(depth);
    float edgeMask = CRYSTAL_DepthEdge(uv);
    return saturate(nearMask * CRYSTAL_ForegroundNearStrength + edgeMask * CRYSTAL_ForegroundEdgeStrength);
}

float CRYSTAL_HueDistance(float a, float b)
{
    float d = abs(a - b);
    return min(d, 1.0 - d);
}

float CRYSTAL_HueWarm(float3 source)
{
    float hue = SHARED_Hue(source);
    float sat = SHARED_Saturation(source);
    float warmA = 1.0 - smoothstep(0.0, CRYSTAL_HueWarmWidth, CRYSTAL_HueDistance(hue, 0.02));
    float warmB = 1.0 - smoothstep(0.0, CRYSTAL_HueWarmWidth, CRYSTAL_HueDistance(hue, 0.98));
    return saturate(max(warmA, warmB) * smoothstep(0.08, 0.35, sat));
}

float CRYSTAL_Directional(float2 uv)
{
    float luma = SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb);
    float2 px = SHARED_PixelSize();
    float lumaR = SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(px.x, 0.0)), 0.0, 0.0)).rgb);
    float lumaL = SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(px.x, 0.0)), 0.0, 0.0)).rgb);
    float lumaU = SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, px.y)), 0.0, 0.0)).rgb);
    float lumaD = SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv - float2(0.0, px.y)), 0.0, 0.0)).rgb);
    float2 grad = float2(lumaR - lumaL, lumaU - lumaD);
    float mag = length(grad);
    float2 dir = (mag > 0.00001) ? (grad / mag) : float2(1.0, 0.0);
    float angle = radians(CRYSTAL_DirectionalAngle);
    float2 target = float2(cos(angle), sin(angle));
    float aligned = abs(dot(dir, target));
    return saturate(smoothstep(1.0 - CRYSTAL_DirectionalSoftness, 1.0, aligned) * smoothstep(0.01, 0.08, mag));
}

float CRYSTAL_SilhouetteGuard(float2 uv, float3 source)
{
    float depthValid = CRYSTAL_DepthAvailability(uv);
    float edge = CRYSTAL_DepthEdge(uv);
    float luma = SHARED_Luma(source);
    float darkCut = 1.0 - smoothstep(0.05, 0.35, luma);
    return saturate(depthValid * edge * CRYSTAL_SilhouetteStrength * (0.65 + 0.35 * darkCut));
}

float CRYSTAL_FarDetailStack(float2 uv, float3 source)
{
    float depthValid = CRYSTAL_DepthAvailability(uv);
    float depth = CRYSTAL_Depth(uv);
    float farMask = CRYSTAL_DepthFar(depth);
    float guardBlock = CRYSTAL_ForegroundGuardBlock(uv);
    float edgeMask = CRYSTAL_DepthEdge(uv);
    float edgeSuppress = 1.0 - saturate(edgeMask * CRYSTAL_ForegroundEdgeStrength);
    float detailMask = max(CRYSTAL_LensContrastMask(uv, source, 0), CRYSTAL_LensContrastMask(uv, source, 1) * 0.9);
    return saturate(depthValid * farMask * (1.0 - guardBlock) * edgeSuppress * detailMask);
}

float CRYSTAL_FogEvidence(float2 uv, float3 source)
{
    float luma = SHARED_Luma(source);
    float saturation = SHARED_Saturation(source);
    float desaturation = 1.0 - saturation;
    float contrast = SHARED_LocalContrast(uv, source);
    float depthAvailability = CRYSTAL_DepthAvailability(uv);
    float depth = CRYSTAL_Depth(uv);
    float depthBias = smoothstep(max(CRYSTAL_DepthStart, 0.08), max(CRYSTAL_FarDetailStart, 0.35), depth);

    float lumaGrad = abs(ddx(luma)) + abs(ddy(luma));
    float brightMask = smoothstep(CRYSTAL_FogBrightnessFloor, CRYSTAL_FogBrightnessFloor + 0.08, luma);
    float desatMask = smoothstep(CRYSTAL_FogDesaturation, min(1.0, CRYSTAL_FogDesaturation + 0.20), desaturation);
    float lowContrastMask = 1.0 - smoothstep(CRYSTAL_FogLowContrast, max(CRYSTAL_FogLowContrast + 0.01, CRYSTAL_FogLowContrast * 3.0), contrast);
    float edgeSuppress = 1.0 - smoothstep(CRYSTAL_LineThreshold, CRYSTAL_LineThreshold * 4.0, lumaGrad);
    float lightSuppress = 1.0 - smoothstep(CRYSTAL_LightThreshold, CRYSTAL_LightThreshold + CRYSTAL_LightSoftness, luma);

    // When depth is present, haze should bias toward farther, flatter regions.
    // Without trustworthy depth, keep a weaker fallback so the debug view still reveals the color/contrast logic.
    float atmosphericDepth = lerp(0.55, depthBias, depthAvailability);

    return saturate(brightMask * desatMask * lowContrastMask * edgeSuppress * lerp(1.0, lightSuppress, 0.65) * atmosphericDepth);
}

float CRYSTAL_LightShield(float3 source)
{
    float luma = SHARED_Luma(source);
    float maxv = max(source.r, max(source.g, source.b));
    float minv = min(source.r, min(source.g, source.b));
    float sat = (maxv <= 0.00001) ? 0.0 : ((maxv - minv) / maxv);
    float satMask = smoothstep(0.22, 1.0, sat);
    float lumaMask = smoothstep(CRYSTAL_LightThreshold, CRYSTAL_LightThreshold + CRYSTAL_LightSoftness, luma);
    float peakMask = smoothstep(CRYSTAL_LightThreshold, CRYSTAL_LightThreshold + CRYSTAL_LightSoftness, maxv);
    return saturate(max(lumaMask, peakMask) + satMask * peakMask * 0.35);
}

float CRYSTAL_LineGuard(float3 source)
{
    float luma = SHARED_Luma(source);
    float grad = abs(ddx(luma)) + abs(ddy(luma));
    return smoothstep(CRYSTAL_LineThreshold, CRYSTAL_LineThreshold * 3.0, grad);
}

float CRYSTAL_PixelGuard(float3 source)
{
    float luma = SHARED_Luma(source);
    float sat = SHARED_Saturation(source);
    float brightMask = smoothstep(CRYSTAL_PixelThreshold, 1.0, luma);
    float satMask = smoothstep(CRYSTAL_PixelSaturation, 1.0, sat);
    return saturate(max(brightMask, satMask));
}

float CRYSTAL_ActiveMask(float2 uv, float3 source)
{
    float result = 0.0;

    if (CRYSTAL_MaskMode == CRYSTAL_MASK_FOG)
        result = CRYSTAL_FogEvidence(uv, source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_LIGHT)
        result = CRYSTAL_LightShield(source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_LINE)
        result = CRYSTAL_LineGuard(source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_PIXEL)
        result = CRYSTAL_PixelGuard(source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_DEPTH)
        result = CRYSTAL_DepthWindow(uv);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_FAR_DETAIL)
        result = CRYSTAL_FarDetailStack(uv, source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_FOREGROUND_GUARD)
        result = CRYSTAL_ForegroundGuardBlock(uv);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_CONTRAST)
        result = CRYSTAL_Contrast(uv, source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_HUE_WARM)
        result = CRYSTAL_HueWarm(source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_DIRECTIONAL)
        result = CRYSTAL_Directional(uv);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_SILHOUETTE)
        result = CRYSTAL_SilhouetteGuard(uv, source);
    else if (CRYSTAL_MaskMode == CRYSTAL_MASK_COMPOSITE)
    {
        float fog = CRYSTAL_FogEvidence(uv, source);
        float light = CRYSTAL_LightShield(source);
        float line = CRYSTAL_LineGuard(source);
        float pixel = CRYSTAL_PixelGuard(source);
        float depth = CRYSTAL_DepthWindow(uv);
        float farDetail = CRYSTAL_FarDetailStack(uv, source);
        float contrast = CRYSTAL_Contrast(uv, source);
        float hueWarm = CRYSTAL_HueWarm(source);
        float directional = CRYSTAL_Directional(uv);
        float silhouette = CRYSTAL_SilhouetteGuard(uv, source);
        result = saturate(max(max(max(max(fog, light), max(line, pixel)), max(max(farDetail, contrast), hueWarm)), max(directional, silhouette)) * depth);
    }

    return result;
}

float CRYSTAL_CompositeDebugComponent(
    float fog,
    float light,
    float line,
    float pixel,
    float depth,
    float farDetail,
    float contrast,
    float hueWarm,
    float directional,
    float silhouette)
{
    if (CRYSTAL_CompositeDebugBranch == 0) return fog;
    if (CRYSTAL_CompositeDebugBranch == 1) return light;
    if (CRYSTAL_CompositeDebugBranch == 2) return line;
    if (CRYSTAL_CompositeDebugBranch == 3) return pixel;
    if (CRYSTAL_CompositeDebugBranch == 4) return depth;
    if (CRYSTAL_CompositeDebugBranch == 5) return farDetail;
    if (CRYSTAL_CompositeDebugBranch == 6) return contrast;
    if (CRYSTAL_CompositeDebugBranch == 7) return hueWarm;
    if (CRYSTAL_CompositeDebugBranch == 8) return directional;
    return silhouette;
}

float CRYSTAL_BranchDirectField(
    float2 uv,
    float3 source,
    float fog,
    float light,
    float line,
    float pixel,
    float depth,
    float farDetail,
    float foreground,
    float contrast,
    float hueWarm,
    float directional,
    float silhouette)
{
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_FOG) return fog;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_LIGHT) return light;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_LINE) return line;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_PIXEL) return pixel;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_DEPTH) return depth;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_FAR_DETAIL) return farDetail;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_FOREGROUND_GUARD) return foreground;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_CONTRAST) return contrast;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_HUE_WARM) return hueWarm;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_DIRECTIONAL) return directional;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_SILHOUETTE) return silhouette;
    if (CRYSTAL_MaskMode == CRYSTAL_MASK_COMPOSITE)
        return CRYSTAL_CompositeDebugComponent(fog, light, line, pixel, depth, farDetail, contrast, hueWarm, directional, silhouette);
    return 0.0;
}

float3 CRYSTAL_MaskedPreview(float2 uv, float3 source)
{
    float mask = CRYSTAL_ActiveMask(uv, source) * CRYSTAL_MaskStrength;
    return lerp(source, float3(mask, mask * 0.85, mask * 0.55), saturate(mask));
}

float4 CRYSTAL_MainPS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 source = tex2Dlod(ReShade::BackBuffer, float4(uv, 0.0, 0.0)).rgb;
    if (CRYSTAL_Enable == 0 || CRYSTAL_DebugView == 0)
        return float4(source, 1.0);

    bool isPureDepthDebug = (CRYSTAL_DebugView >= 4 && CRYSTAL_DebugView <= 6);
    if (!isPureDepthDebug && CRYSTAL_MaskMode == CRYSTAL_MASK_OFF)
        return float4(source, 1.0);

    float activeMask = CRYSTAL_ActiveMask(uv, source);
    float fog = CRYSTAL_FogEvidence(uv, source);
    float light = CRYSTAL_LightShield(source);
    float line = CRYSTAL_LineGuard(source);
    float pixel = CRYSTAL_PixelGuard(source);
    float depth = CRYSTAL_DepthWindow(uv);
    float farDetail = CRYSTAL_FarDetailStack(uv, source);
    float foreground = CRYSTAL_ForegroundGuardBlock(uv);
    float contrast = CRYSTAL_Contrast(uv, source);
    float hueWarm = CRYSTAL_HueWarm(source);
    float directional = CRYSTAL_Directional(uv);
    float silhouette = CRYSTAL_SilhouetteGuard(uv, source);
    float composite = saturate(max(max(max(max(fog, light), max(line, pixel)), max(max(farDetail, contrast), hueWarm)), max(directional, silhouette)) * depth);
    float branchDirect = CRYSTAL_BranchDirectField(uv, source, fog, light, line, pixel, depth, farDetail, foreground, contrast, hueWarm, directional, silhouette);

    float3 outColor = source;
    if (CRYSTAL_DebugView == 1) outColor = CRYSTAL_DebugShape3(((activeMask * CRYSTAL_MaskStrength)).xxx);
    else if (CRYSTAL_DebugView == 2) outColor = CRYSTAL_DebugShape3((branchDirect).xxx);
    else if (CRYSTAL_DebugView == 3) outColor = CRYSTAL_DebugShape3(((composite * CRYSTAL_MaskStrength)).xxx);
    else if (CRYSTAL_DebugView == 4) outColor = CRYSTAL_DebugShape3((CRYSTAL_DebugDepth(uv)).xxx);
    else if (CRYSTAL_DebugView == 5) outColor = CRYSTAL_DebugShape3((CRYSTAL_DepthAvailability(uv)).xxx);
    else if (CRYSTAL_DebugView == 6) outColor = CRYSTAL_DebugShape3((CRYSTAL_DepthEdge(uv)).xxx);
    else outColor = CRYSTAL_MaskedPreview(uv, source);

    return float4(saturate(outColor), 1.0);
}

#endif
