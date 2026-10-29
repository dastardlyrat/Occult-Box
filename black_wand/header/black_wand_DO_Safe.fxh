/*
    black_wand_DO_Safe.fxh
    Small scalar/vector safety helpers for the clean depth oracle rebuild.
    Original project code. No DisplayDepth function/text/structure is copied.
*/
#ifndef BLACK_WAND_DO_SAFE_FXH
#define BLACK_WAND_DO_SAFE_FXH

float black_wand_DO_SafeDenom(float v)
{
    return max(abs(v), 0.000001);
}

float black_wand_DO_Safe01(float v)
{
    return saturate(v);
}

float3 black_wand_DO_SafeColor(float3 c)
{
    return saturate(c);
}

float black_wand_DO_Luma(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

float3 black_wand_DO_Heat(float v)
{
    float x = saturate(v);
    float r = saturate(x * 2.0);
    float g = saturate(1.0 - abs(x * 2.0 - 1.0));
    float b = saturate(1.0 - x * 2.0);
    return float3(r, g, b);
}

float black_wand_DO_InteriorDepth(float d, float endpointMargin)
{
    float lo = step(endpointMargin, d);
    float hi = step(endpointMargin, 1.0 - d);
    return lo * hi;
}

float2 black_wand_DO_PixelStep(float radiusPixels)
{
    return BUFFER_PIXEL_SIZE * max(radiusPixels, 0.0);
}

float3 black_wand_DO_Checker(float2 uv)
{
    float2 cell = floor(uv * 16.0);
    float tile = frac((cell.x + cell.y) * 0.5) * 2.0;
    float gridX = 1.0 - step(0.025, min(frac(uv.x * 16.0), 1.0 - frac(uv.x * 16.0)));
    float gridY = 1.0 - step(0.025, min(frac(uv.y * 16.0), 1.0 - frac(uv.y * 16.0)));
    float grid = saturate(max(gridX, gridY));
    float3 a = float3(0.10, 0.10, 0.10);
    float3 b = float3(0.45, 0.45, 0.45);
    float3 c = lerp(a, b, tile);
    return lerp(c, float3(0.0, 0.8, 1.0), grid * 0.75);
}

float3 black_wand_DO_SourceWarning(float3 source, float strength)
{
    float2 uv = frac(float2(BUFFER_WIDTH, BUFFER_HEIGHT) * BUFFER_PIXEL_SIZE);
    float stripe = step(0.5, frac((uv.x + uv.y) * 32.0));
    float3 warn = lerp(float3(1.0, 0.15, 0.80), float3(1.0, 0.75, 0.0), stripe);
    return lerp(source, warn, saturate(strength));
}

#endif
