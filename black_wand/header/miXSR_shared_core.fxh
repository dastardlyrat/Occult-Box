#ifndef MIXSR_SHARED_CORE_FXH
#define MIXSR_SHARED_CORE_FXH

float2 MIXSR_SHARED_PixelSize()
{
    return float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
}

float MIXSR_SHARED_PatternSpan()
{
    return min(BUFFER_WIDTH, BUFFER_HEIGHT);
}

float MIXSR_SHARED_SafeRcp(float v)
{
    return 1.0 / max(0.00001, v);
}

float MIXSR_SHARED_Luma(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

float MIXSR_SHARED_Saturation(float3 c)
{
    float maxv = max(c.r, max(c.g, c.b));
    float minv = min(c.r, min(c.g, c.b));
    return (maxv <= 0.00001) ? 0.0 : ((maxv - minv) / maxv);
}

float MIXSR_SHARED_Hue(float3 c)
{
    float maxv = max(c.r, max(c.g, c.b));
    float minv = min(c.r, min(c.g, c.b));
    float delta = maxv - minv;

    if (delta <= 0.00001)
    {
        return 0.0;
    }

    float hue = 0.0;
    if (maxv == c.r)
    {
        hue = frac((c.g - c.b) / delta / 6.0);
    }
    else if (maxv == c.g)
    {
        hue = ((c.b - c.r) / delta + 2.0) / 6.0;
    }
    else
    {
        hue = ((c.r - c.g) / delta + 4.0) / 6.0;
    }

    return frac(hue);
}

float2 MIXSR_SHARED_Rotate(float2 v, float angleDegrees)
{
    float angle = radians(angleDegrees);
    float s = sin(angle);
    float c = cos(angle);
    return float2(v.x * c - v.y * s, v.x * s + v.y * c);
}

float MIXSR_SHARED_LocalContrast(float2 uv, float3 sourceColor)
{
    float center = MIXSR_SHARED_Luma(sourceColor);
    float2 px = MIXSR_SHARED_PixelSize();
    float l1 = MIXSR_SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(px.x, 0.0)), 0.0, 0.0)).rgb);
    float l2 = MIXSR_SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(-px.x, 0.0)), 0.0, 0.0)).rgb);
    float l3 = MIXSR_SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, px.y)), 0.0, 0.0)).rgb);
    float l4 = MIXSR_SHARED_Luma(tex2Dlod(ReShade::BackBuffer, float4(saturate(uv + float2(0.0, -px.y)), 0.0, 0.0)).rgb);
    return abs(center - l1) + abs(center - l2) + abs(center - l3) + abs(center - l4);
}

#endif
