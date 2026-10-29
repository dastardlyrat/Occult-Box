#ifndef BLACK_WAND_RM_SDF_BASIC_FXH
#define BLACK_WAND_RM_SDF_BASIC_FXH 1

float black_wand_RM_sdSphere(float3 p, float radiusValue)
{
    return length(p) - radiusValue;
}

float black_wand_RM_sdPlane(float3 p, float3 unitNormal, float heightValue)
{
    return dot(p, unitNormal) + heightValue;
}

float black_wand_RM_sdBox(float3 p, float3 halfSize)
{
    float3 q = abs(p) - halfSize;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float black_wand_RM_sdRoundBox(float3 p, float3 halfSize, float radiusValue)
{
    float3 q = abs(p) - halfSize;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - radiusValue;
}

float black_wand_RM_sdCapsule(float3 p, float3 a, float3 b, float radiusValue)
{
    float3 pa = p - a;
    float3 ba = b - a;
    float h = saturate(dot(pa, ba) / black_wand_RM_SafeDenom(dot(ba, ba)));
    return length(pa - ba * h) - radiusValue;
}

float black_wand_RM_sdTorusY(float3 p, float majorRadius, float minorRadius)
{
    float2 q = float2(length(p.xz) - majorRadius, p.y);
    return length(q) - minorRadius;
}

float black_wand_RM_sdCappedCylinderY(float3 p, float halfHeight, float radiusValue)
{
    float2 q = abs(float2(length(p.xz), p.y)) - float2(radiusValue, halfHeight);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0));
}

float black_wand_RM_sdConeY(float3 p, float halfHeight, float radiusBottom, float radiusTop)
{
    float q = saturate((p.y + halfHeight) / black_wand_RM_SafeDenom(halfHeight * 2.0));
    float radiusAtY = lerp(radiusBottom, radiusTop, q);
    float side = length(p.xz) - radiusAtY;
    float cap = abs(p.y) - halfHeight;
    return max(side, cap);
}

float black_wand_RM_sdHexPrismY(float3 p, float radiusValue, float halfHeight)
{
    float3 q = abs(p);
    float hex = max(q.x * 0.8660254 + q.z * 0.5, q.z) - radiusValue;
    return max(hex, q.y - halfHeight);
}

#endif
