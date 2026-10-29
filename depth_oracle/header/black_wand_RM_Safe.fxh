#ifndef BLACK_WAND_RM_SAFE_FXH
#define BLACK_WAND_RM_SAFE_FXH 1

float black_wand_RM_SafeDenom(float v)
{
    return (abs(v) < 0.000001) ? ((v < 0.0) ? -0.000001 : 0.000001) : v;
}

float black_wand_RM_SafeDivide(float n, float d, float fallbackValue)
{
    return (abs(d) < 0.000001) ? fallbackValue : (n / d);
}

float3 black_wand_RM_SafeNormalize3(float3 v, float3 fallbackValue)
{
    float len2 = dot(v, v);
    return (len2 > 0.00000001) ? (v * rsqrt(len2)) : fallbackValue;
}

float2 black_wand_RM_SafeNormalize2(float2 v, float2 fallbackValue)
{
    float len2 = dot(v, v);
    return (len2 > 0.00000001) ? (v * rsqrt(len2)) : fallbackValue;
}

float black_wand_RM_Luma(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

float black_wand_RM_HitEpsilon(float t, float epsAbs, float epsRel)
{
    return max(epsAbs, abs(t) * epsRel);
}

float black_wand_RM_VisibleFloor(float v, float floorValue)
{
    return max(v, floorValue);
}

float3 black_wand_RM_VisibleFloor3(float3 v, float floorValue)
{
    return max(v, float3(floorValue, floorValue, floorValue));
}

float black_wand_RM_Remap01(float value, float lowValue, float highValue)
{
    return saturate((value - lowValue) / black_wand_RM_SafeDenom(highValue - lowValue));
}

float3 black_wand_RM_RotateX(float3 p, float radiansValue)
{
    float s = sin(radiansValue);
    float c = cos(radiansValue);
    return float3(p.x, c * p.y - s * p.z, s * p.y + c * p.z);
}

float3 black_wand_RM_RotateY(float3 p, float radiansValue)
{
    float s = sin(radiansValue);
    float c = cos(radiansValue);
    return float3(c * p.x + s * p.z, p.y, -s * p.x + c * p.z);
}

float3 black_wand_RM_RotateZ(float3 p, float radiansValue)
{
    float s = sin(radiansValue);
    float c = cos(radiansValue);
    return float3(c * p.x - s * p.y, s * p.x + c * p.y, p.z);
}

float3 black_wand_RM_RotateYXZ(float3 p, float yawRadians, float pitchRadians, float rollRadians)
{
    float3 r = black_wand_RM_RotateY(p, yawRadians);
    r = black_wand_RM_RotateX(r, pitchRadians);
    r = black_wand_RM_RotateZ(r, rollRadians);
    return r;
}

float black_wand_RM_Checker3(float3 p, float scaleValue)
{
    float3 q = floor(p * max(scaleValue, 0.0001));
    float v = q.x + q.y + q.z;
    return frac(v * 0.5) * 2.0;
}

#endif
