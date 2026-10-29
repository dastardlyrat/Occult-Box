#ifndef black_wand_DEBUG_COLORIZE_SERVER_FXH
#define black_wand_DEBUG_COLORIZE_SERVER_FXH

float3 black_wand_Debug_Heat(float v)
{
    float x = saturate(v);
    return saturate(float3(smoothstep(0.25, 0.75, x), 1.0 - abs(x - 0.5) * 2.0, 1.0 - smoothstep(0.25, 0.75, x)));
}

float3 black_wand_Debug_IndexColor(int indexValue, int activeCount)
{
    float denom = max(1.0, float(max(1, activeCount - 1)));
    float t = frac(float(indexValue) / denom);
    return saturate(float3(frac(t + 0.00), frac(t + 0.3333333), frac(t + 0.6666667)));
}

float4 black_wand_Debug_ScalarOut(float scalarValue, float exposure)
{
    float v = saturate(scalarValue * max(0.0, exposure));
    return float4(v.xxx, 1.0);
}

float4 black_wand_Debug_ColorOut(float3 colorValue, float exposure)
{
    return float4(saturate(colorValue * max(0.0, exposure)), 1.0);
}

#endif
