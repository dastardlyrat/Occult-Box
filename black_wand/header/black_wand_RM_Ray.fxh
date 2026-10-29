#ifndef BLACK_WAND_RM_RAY_FXH
#define BLACK_WAND_RM_RAY_FXH 1

black_wand_RM_Ray black_wand_RM_MakePerspectiveRay(
    float2 uv,
    float aspectValue,
    float fovYDegrees,
    float3 cameraOrigin,
    float yawDegrees,
    float pitchDegrees,
    float rollDegrees,
    float tMin,
    float tMax)
{
    float2 ndc = uv * 2.0 - 1.0;
    ndc.y = -ndc.y;
    float fovRadians = radians(clamp(fovYDegrees, 5.0, 160.0));
    float tanHalf = tan(fovRadians * 0.5);
    float3 localDir = black_wand_RM_SafeNormalize3(float3(ndc.x * aspectValue * tanHalf, ndc.y * tanHalf, 1.0), float3(0.0, 0.0, 1.0));
    float yaw = radians(yawDegrees);
    float pitch = radians(pitchDegrees);
    float roll = radians(rollDegrees);

    black_wand_RM_Ray ray;
    ray.origin = cameraOrigin;
    ray.direction = black_wand_RM_SafeNormalize3(black_wand_RM_RotateYXZ(localDir, yaw, pitch, roll), float3(0.0, 0.0, 1.0));
    ray.tMin = max(0.0, tMin);
    ray.tMax = max(ray.tMin + 0.0001, tMax);
    return ray;
}

black_wand_RM_Ray black_wand_RM_ApplyRawDepthTMax(
    black_wand_RM_Ray ray,
    float useRawDepthClip,
    float rawDepth,
    float rawDepthAvailable,
    float rawDepthScale,
    float rawDepthBias)
{
    float rawT = max(ray.tMin + 0.0001, rawDepth * rawDepthScale + rawDepthBias);
    float clippedTMax = min(ray.tMax, rawT);
    float useClip = saturate(useRawDepthClip) * rawDepthAvailable;
    ray.tMax = lerp(ray.tMax, clippedTMax, useClip);
    return ray;
}

float black_wand_RM_RayBoundEvidence(black_wand_RM_Ray ray)
{
    return saturate((ray.tMax - ray.tMin) / max(ray.tMax, 0.0001));
}

#endif
