/*
    black_wand_DO_Oracle.fxh
    Depth access primitives. The official branch delegates to ReShade::GetLinearizedDepth.
    The manual branch is an original preview/diagnostic transform, not a replacement for global preprocessor setup.
*/
#ifndef BLACK_WAND_DO_ORACLE_FXH
#define BLACK_WAND_DO_ORACLE_FXH

float2 black_wand_DO_ManualUV(float2 uv, bool flipVertical, float2 scale, int2 pixelOffset)
{
    float2 p = uv;
    if (flipVertical)
        p.y = 1.0 - p.y;
    p.x = p.x / black_wand_DO_SafeDenom(scale.x);
    p.y = p.y / black_wand_DO_SafeDenom(scale.y);
    p.x = p.x - float(pixelOffset.x) * BUFFER_RCP_WIDTH;
    p.y = p.y + float(pixelOffset.y) * BUFFER_RCP_HEIGHT;
    return p;
}

float black_wand_DO_RawDepthAt(float2 uv)
{
    return tex2Dlod(ReShade::DepthBuffer, float4(uv, 0.0, 0.0)).x;
}

float black_wand_DO_OfficialDepthAt(float2 uv)
{
    return ReShade::GetLinearizedDepth(uv);
}

float black_wand_DO_ExpandLogPreview(float d, float curve)
{
    float c = max(curve, 0.0001);
    return (exp(saturate(d) * log(c + 1.0)) - 1.0) / c;
}

float black_wand_DO_LinearProxy(float d, float nearPlane, float farPlane)
{
    float nearV = max(nearPlane, 0.0001);
    float farV = max(farPlane, nearV + 0.0001);
    float x = saturate(d);
    float denom = farV - x * (farV - nearV);
    return saturate(x / black_wand_DO_SafeDenom(denom));
}

float black_wand_DO_ManualDepthAt(
    float2 uv,
    bool flipVertical,
    float2 scale,
    int2 pixelOffset,
    bool reversed,
    bool logEncoded,
    float multiplier,
    float logCurve,
    float nearPlane,
    float farPlane)
{
    float2 p = black_wand_DO_ManualUV(uv, flipVertical, scale, pixelOffset);
    float d = black_wand_DO_RawDepthAt(p) * max(multiplier, 0.0);
    if (logEncoded)
        d = black_wand_DO_ExpandLogPreview(d, logCurve);
    if (reversed)
        d = 1.0 - d;
    return black_wand_DO_LinearProxy(d, nearPlane, farPlane);
}

float3 black_wand_DO_DepthPresence(float2 uv, float endpointMargin)
{
    float raw = black_wand_DO_RawDepthAt(uv);
    float official = black_wand_DO_OfficialDepthAt(uv);
    float rawPresent = step(0.0000001, raw) + step(0.0000001, 1.0 - raw);
    rawPresent = saturate(rawPresent * 0.5);
    float rawInterior = black_wand_DO_InteriorDepth(raw, endpointMargin);
    float officialPresent = step(0.0000001, official);
    return float3(rawPresent, rawInterior, officialPresent);
}

#endif
