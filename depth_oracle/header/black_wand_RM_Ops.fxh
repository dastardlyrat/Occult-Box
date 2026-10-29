#ifndef BLACK_WAND_RM_OPS_FXH
#define BLACK_WAND_RM_OPS_FXH 1

black_wand_RM_Field black_wand_RM_FieldUnion(black_wand_RM_Field a, black_wand_RM_Field b)
{
    black_wand_RM_Field r = a;
    if (b.distanceValue < a.distanceValue)
    {
        r = b;
    }
    r.localBound = min(a.localBound, b.localBound);
    return r;
}

black_wand_RM_Field black_wand_RM_FieldIntersect(black_wand_RM_Field a, black_wand_RM_Field b)
{
    black_wand_RM_Field r = a;
    if (b.distanceValue > a.distanceValue)
    {
        r = b;
    }
    r.distanceValue = max(a.distanceValue, b.distanceValue);
    r.localBound = abs(r.distanceValue);
    return r;
}

black_wand_RM_Field black_wand_RM_FieldSubtract(black_wand_RM_Field a, black_wand_RM_Field b)
{
    black_wand_RM_Field r = a;
    r.distanceValue = max(a.distanceValue, -b.distanceValue);
    r.localBound = abs(r.distanceValue);
    return r;
}

black_wand_RM_Field black_wand_RM_FieldSmoothUnion(black_wand_RM_Field a, black_wand_RM_Field b, float k)
{
    float safeK = max(k, 0.00001);
    float h = saturate(0.5 + 0.5 * (b.distanceValue - a.distanceValue) / safeK);
    black_wand_RM_Field r = a;
    r.distanceValue = lerp(b.distanceValue, a.distanceValue, h) - safeK * h * (1.0 - h);
    r.materialId = lerp(b.materialId, a.materialId, step(0.5, h));
    r.localBound = abs(r.distanceValue);
    return r;
}

float3 black_wand_RM_Translate(float3 p, float3 t)
{
    return p - t;
}

float3 black_wand_RM_MirrorX(float3 p)
{
    return float3(abs(p.x), p.y, p.z);
}

float3 black_wand_RM_MirrorXZ(float3 p)
{
    return float3(abs(p.x), p.y, abs(p.z));
}

float3 black_wand_RM_FloatDomainModulo(float3 value, float3 modulusValue)
{
    float3 safeModulus = max(abs(modulusValue), float3(0.0001, 0.0001, 0.0001));
    return value - safeModulus * floor(value / safeModulus);
}

float3 black_wand_RM_Repeat(float3 p, float3 cellSize)
{
    float3 safeCell = max(abs(cellSize), float3(0.0001, 0.0001, 0.0001));
    return black_wand_RM_FloatDomainModulo(p + 0.5 * safeCell, safeCell) - 0.5 * safeCell;
}

float3 black_wand_RM_TwistY(float3 p, float twistAmount)
{
    float angleValue = p.y * twistAmount;
    float s = sin(angleValue);
    float c = cos(angleValue);
    return float3(c * p.x - s * p.z, p.y, s * p.x + c * p.z);
}

float black_wand_RM_ShellDistance(float d, float thickness)
{
    return abs(d) - max(thickness, 0.00001);
}

float black_wand_RM_DisplaceSin(float3 p, float amplitudeValue, float frequencyValue)
{
    float3 q = p * frequencyValue;
    return amplitudeValue * sin(q.x) * sin(q.y) * sin(q.z);
}

#endif
