/*
    black_wand_DO_Display.fxh
    Display shaping and diagnostic composition primitives.
*/
#ifndef BLACK_WAND_DO_DISPLAY_FXH
#define BLACK_WAND_DO_DISPLAY_FXH

float black_wand_DO_ShapeScalar(
    float v,
    float blackPoint,
    float whitePoint,
    float gammaValue,
    float contrastValue,
    float exposureValue,
    bool invertValue)
{
    float lo = min(blackPoint, whitePoint - 0.0001);
    float hi = max(whitePoint, lo + 0.0001);
    float x = saturate((v - lo) / (hi - lo));
    x = pow(max(x, 0.0), 1.0 / max(gammaValue, 0.0001));
    x = (x - 0.5) * contrastValue + 0.5;
    x = x * exp2(exposureValue);
    x = saturate(x);
    if (invertValue)
        x = 1.0 - x;
    return x;
}

float3 black_wand_DO_ShapeGray(
    float v,
    float blackPoint,
    float whitePoint,
    float gammaValue,
    float contrastValue,
    float exposureValue,
    bool invertValue,
    bool liftDark,
    float floorValue)
{
    float x = black_wand_DO_ShapeScalar(v, blackPoint, whitePoint, gammaValue, contrastValue, exposureValue, invertValue);
    if (liftDark)
        x = max(x, floorValue);
    return x.xxx;
}

float3 black_wand_DO_UVGradient(float2 uv)
{
    float gridX = 1.0 - step(0.020, min(frac(uv.x * 16.0), 1.0 - frac(uv.x * 16.0)));
    float gridY = 1.0 - step(0.020, min(frac(uv.y * 16.0), 1.0 - frac(uv.y * 16.0)));
    float grid = saturate(max(gridX, gridY));
    return saturate(float3(uv.x, uv.y, 0.25) + grid.xxx * float3(0.25, 0.25, 0.70));
}

float3 black_wand_DO_OracleCompare(float rawDepth, float manualDepth, float officialDepth, float scale)
{
    float diffMO = abs(manualDepth - officialDepth) * scale;
    float diffRO = abs(rawDepth - officialDepth) * scale;
    float diffRM = abs(rawDepth - manualDepth) * scale;
    return saturate(float3(diffRO, diffMO, diffRM));
}

float3 black_wand_DO_Bars(float2 uv, float3 bars)
{
    float region0 = 1.0 - step(0.333333, uv.x);
    float region1 = step(0.333333, uv.x) * (1.0 - step(0.666667, uv.x));
    float region2 = step(0.666667, uv.x);
    float h = 1.0 - uv.y;
    float b0 = region0 * step(h, bars.x);
    float b1 = region1 * step(h, bars.y);
    float b2 = region2 * step(h, bars.z);
    float guide = 1.0 - step(0.010, min(abs(uv.x - 0.333333), abs(uv.x - 0.666667)));
    return saturate(float3(b0, b1, b2) + guide.xxx * 0.25);
}

float3 black_wand_DO_Split(float2 uv, float3 leftColor, float3 rightColor)
{
    float chooseRight = step(0.5, uv.x);
    float seam = 1.0 - step(0.004, abs(uv.x - 0.5));
    return saturate(lerp(leftColor, rightColor, chooseRight) + seam.xxx * float3(0.0, 0.6, 1.0));
}

float3 black_wand_DO_Overlay(float3 source, float3 diagnostic, float strength)
{
    return lerp(source, diagnostic, saturate(strength));
}

#endif
