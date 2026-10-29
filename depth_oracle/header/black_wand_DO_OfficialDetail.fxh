/*
    black_wand_DO_OfficialDetail.fxh
    Official-depth baseline readability primitives for v0.8.
    These helpers are derived from the working v0.6 official-depth/original-normal path.
    They do not replace ReShade::GetLinearizedDepth and do not attempt automatic depth correction.
*/
#ifndef BLACK_WAND_DO_OFFICIAL_DETAIL_FXH
#define BLACK_WAND_DO_OFFICIAL_DETAIL_FXH

float black_wand_DO_FocusedDepthScalar(float d, float focusStrength)
{
    float f = max(focusStrength, 0.0001);
    return saturate(1.0 - exp2(-saturate(d) * f));
}

float3 black_wand_DO_OfficialDepthFocused(
    float officialDepth,
    float focusStrength,
    float blackPoint,
    float whitePoint,
    float gammaValue,
    float contrastValue,
    float exposureValue,
    bool invertValue,
    bool liftDark,
    float floorValue)
{
    float focused = black_wand_DO_FocusedDepthScalar(officialDepth, focusStrength);
    return black_wand_DO_ShapeGray(focused, blackPoint, whitePoint, gammaValue, contrastValue, exposureValue, invertValue, liftDark, floorValue);
}

float3 black_wand_DO_OfficialDepthDetail(float2 uv, float radiusPixels, float edgeTolerance)
{
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c = black_wand_DO_OfficialDepthAt(uv);
    float e = black_wand_DO_OfficialDepthAt(uv + float2(s.x, 0.0));
    float w = black_wand_DO_OfficialDepthAt(uv - float2(s.x, 0.0));
    float n = black_wand_DO_OfficialDepthAt(uv - float2(0.0, s.y));
    float so = black_wand_DO_OfficialDepthAt(uv + float2(0.0, s.y));

    float minD = min(c, min(min(e, w), min(n, so)));
    float maxD = max(c, max(max(e, w), max(n, so)));
    float rangeD = max(maxD - minD, 0.000001);
    float localD = saturate((c - minD) / rangeD);
    float edgeD = saturate((abs(e - w) + abs(n - so)) * 0.5 / max(edgeTolerance, 0.000001));
    return saturate(float3(localD, edgeD, c));
}

float black_wand_DO_MidCoverageMask(float maskValue, float centerValue, float widthValue)
{
    float center = saturate(centerValue);
    float width = max(widthValue, 0.0001);
    return saturate(1.0 - abs(maskValue - center) / width);
}

float3 black_wand_DO_OfficialDepthBands(float officialDepth, float bandCount, float lineWidth, float focusStrength, float waveMix, float sharpness)
{
    float focused = black_wand_DO_FocusedDepthScalar(officialDepth, focusStrength);
    float count = max(bandCount, 1.0);
    float phase = frac(focused * count);
    float nearestLine = min(phase, 1.0 - phase);
    float line = 1.0 - smoothstep(max(lineWidth, 0.0001), max(lineWidth, 0.0001) + 0.035, nearestLine);
    float wave = 0.5 + 0.5 * cos(focused * count * 6.2831853);
    wave = pow(saturate(wave), max(sharpness, 0.0001));
    float contour = saturate(lerp(line, wave, saturate(waveMix)));
    float shade = saturate(focused * 0.70 + 0.12);
    float3 baseColor = lerp(float3(shade, shade, shade * 0.85), float3(0.05, 0.35 + shade * 0.55, 1.0), contour);
    return saturate(baseColor);
}

float black_wand_DO_OfficialEdgeScore(float2 uv, float radiusPixels, float edgeGain)
{
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c = black_wand_DO_OfficialDepthAt(uv);
    float e = black_wand_DO_OfficialDepthAt(uv + float2(s.x, 0.0));
    float w = black_wand_DO_OfficialDepthAt(uv - float2(s.x, 0.0));
    float n = black_wand_DO_OfficialDepthAt(uv - float2(0.0, s.y));
    float so = black_wand_DO_OfficialDepthAt(uv + float2(0.0, s.y));
    float centerFit = abs(e - c) + abs(w - c) + abs(n - c) + abs(so - c);
    float crossSlope = abs(e - w) + abs(n - so);
    return (crossSlope * 0.50 + centerFit * 0.25) * max(edgeGain, 0.0);
}

float black_wand_DO_SoftCoverageFromScore(float score, float thresholdValue, float softnessValue)
{
    float t = max(thresholdValue, 0.0);
    float s = max(softnessValue, 0.0001);
    return smoothstep(t, t + s, score);
}

float3 black_wand_DO_OfficialEdgeMidCoverage(float2 uv, float radiusPixels, float edgeGain, float thresholdValue, float softnessValue, float midCenter, float midWidth)
{
    float score = black_wand_DO_OfficialEdgeScore(uv, radiusPixels, edgeGain);
    float edge = black_wand_DO_SoftCoverageFromScore(score, thresholdValue, softnessValue);
    float mid = black_wand_DO_MidCoverageMask(edge, midCenter, midWidth);
    float scoreView = saturate(score / (score + 1.0));
    return saturate(float3(scoreView, edge, mid));
}

float3 black_wand_DO_OfficialEdgeConfidenceShaped(float2 uv, float radiusPixels, float edgeGain, float thresholdValue, float softnessValue, float midCenter, float midWidth)
{
    float score = black_wand_DO_OfficialEdgeScore(uv, radiusPixels, edgeGain);
    float edge = black_wand_DO_SoftCoverageFromScore(score, thresholdValue, softnessValue);
    float confidence = 1.0 - edge;
    float mid = black_wand_DO_MidCoverageMask(edge, midCenter, midWidth);
    return saturate(float3(edge, confidence, mid));
}

float3 black_wand_DO_OfficialEdgeConfidence(float2 uv, float radiusPixels, float edgeTolerance)
{
    float3 detail = black_wand_DO_OfficialDepthDetail(uv, radiusPixels, edgeTolerance);
    float edge = detail.g;
    float confidence = 1.0 - edge;
    return saturate(float3(edge, confidence, detail.b));
}

float3 black_wand_DO_OfficialNormalRelief(float3 source, float2 uv, float radiusPixels, float focusStrength, float reliefStrength)
{
    float depth = black_wand_DO_OfficialDepthAt(uv);
    float3 normalColor = black_wand_DO_OfficialNormal(uv, radiusPixels);
    float focused = black_wand_DO_FocusedDepthScalar(depth, focusStrength);
    float3 relief = saturate(normalColor * (0.55 + focused * 0.75));
    return lerp(source, relief, saturate(reliefStrength));
}

#endif
