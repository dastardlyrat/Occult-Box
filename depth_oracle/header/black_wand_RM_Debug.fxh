#ifndef BLACK_WAND_RM_DEBUG_FXH
#define BLACK_WAND_RM_DEBUG_FXH 1

float3 black_wand_RM_HeatColor(float v)
{
    float x = saturate(v);
    float3 cold = float3(0.05, 0.12, 0.35);
    float3 mid = float3(0.15, 0.78, 0.38);
    float3 hot = float3(1.0, 0.28, 0.06);
    return lerp(lerp(cold, mid, saturate(x * 2.0)), hot, saturate(x * 2.0 - 1.0));
}

float3 black_wand_RM_NormalColor(float3 n)
{
    return saturate(n * 0.5 + 0.5);
}

float3 black_wand_RM_MissCodeColor(float missCode)
{
    float3 c = float3(0.06, 0.06, 0.08);
    if (missCode < 0.5) c = float3(0.02, 0.18, 0.02);
    else if (missCode < 1.5) c = float3(0.16, 0.18, 0.45);
    else if (missCode < 2.5) c = float3(0.45, 0.10, 0.12);
    else c = float3(0.42, 0.28, 0.05);
    return c;
}

float3 black_wand_RM_MaterialIdColor(float materialId)
{
    return black_wand_RM_MaterialColor(materialId, float3(1.0, 1.0, 1.0), 0.0);
}

float3 black_wand_RM_BandedDistanceColor(float d, float bandScale)
{
    float bands = abs(frac(d * max(bandScale, 0.001)) - 0.5) * 2.0;
    float signTint = (d < 0.0) ? 0.25 : 0.75;
    return float3(bands * signTint, bands * 0.65, bands * (1.0 - signTint));
}

float3 black_wand_RM_OverlayColor(float3 sourceColor, float3 overlayColor, float strength)
{
    return lerp(sourceColor, black_wand_RM_VisibleFloor3(overlayColor, 0.0125), saturate(strength));
}

#endif
