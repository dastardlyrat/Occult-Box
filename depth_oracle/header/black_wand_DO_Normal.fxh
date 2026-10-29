/*
    black_wand_DO_Normal.fxh
    Small fixed normal reconstruction from a selectable depth branch.
*/
#ifndef BLACK_WAND_DO_NORMAL_FXH
#define BLACK_WAND_DO_NORMAL_FXH

float3 black_wand_DO_NormalFromDepthValues(float2 uv, float center, float east, float north, float radiusPixels)
{
    float2 stepUV = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float3 vc = float3(uv - 0.5, 1.0) * center;
    float3 ve = float3(uv + float2(stepUV.x, 0.0) - 0.5, 1.0) * east;
    float3 vn = float3(uv - float2(0.0, stepUV.y) - 0.5, 1.0) * north;
    float3 n = normalize(cross(vc - vn, vc - ve));
    return saturate(n * 0.5 + 0.5);
}

float3 black_wand_DO_OfficialNormal(float2 uv, float radiusPixels)
{
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c = black_wand_DO_OfficialDepthAt(uv);
    float e = black_wand_DO_OfficialDepthAt(uv + float2(s.x, 0.0));
    float n = black_wand_DO_OfficialDepthAt(uv - float2(0.0, s.y));
    return black_wand_DO_NormalFromDepthValues(uv, c, e, n, radiusPixels);
}

float3 black_wand_DO_ManualNormal(
    float2 uv,
    float radiusPixels,
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
    float2 s = black_wand_DO_PixelStep(max(radiusPixels, 1.0));
    float c = black_wand_DO_ManualDepthAt(uv, flipVertical, scale, pixelOffset, reversed, logEncoded, multiplier, logCurve, nearPlane, farPlane);
    float e = black_wand_DO_ManualDepthAt(uv + float2(s.x, 0.0), flipVertical, scale, pixelOffset, reversed, logEncoded, multiplier, logCurve, nearPlane, farPlane);
    float n = black_wand_DO_ManualDepthAt(uv - float2(0.0, s.y), flipVertical, scale, pixelOffset, reversed, logEncoded, multiplier, logCurve, nearPlane, farPlane);
    return black_wand_DO_NormalFromDepthValues(uv, c, e, n, radiusPixels);
}

#endif
