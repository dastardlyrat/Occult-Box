#ifndef BLACK_WAND_RM_MARCH_FXH
#define BLACK_WAND_RM_MARCH_FXH 1

void black_wand_RM_MarchPrimaryStep(
    inout black_wand_RM_Hit h,
    black_wand_RM_Ray ray,
    int sceneMode,
    int stepIndex,
    int boundedStepCount,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float epsAbs,
    float epsRel,
    float safeMinStep,
    float safeStepScale,
    inout float marchDone)
{
    if (marchDone > 0.5)
    {
        return;
    }

    if (stepIndex >= boundedStepCount)
    {
        h.missCode = 3.0;
        marchDone = 1.0;
        return;
    }

    if (h.t > ray.tMax)
    {
        h.missCode = 1.0;
        marchDone = 1.0;
        return;
    }

    float3 p = ray.origin + ray.direction * h.t;
    black_wand_RM_Field f = black_wand_RM_EvaluateSceneLoopSafe(p, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency);
    float eps = black_wand_RM_HitEpsilon(h.t, epsAbs, epsRel);

    h.position = p;
    h.distanceValue = f.distanceValue;
    h.materialId = f.materialId;
    h.stepCount = float(stepIndex + 1);
    h.lastStep = f.distanceValue;
    h.travel01 = saturate((h.t - ray.tMin) / max(ray.tMax - ray.tMin, 0.0001));

    if (abs(f.distanceValue) <= eps)
    {
        h.hitFlag = 1.0;
        h.missCode = 0.0;
        marchDone = 1.0;
        return;
    }

    h.t += max(abs(f.distanceValue) * safeStepScale, safeMinStep);
}

black_wand_RM_Hit black_wand_RM_MarchPrimary(
    black_wand_RM_Ray ray,
    int sceneMode,
    int activeStepCount,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float epsAbs,
    float epsRel,
    float minStep,
    float stepScale)
{
    black_wand_RM_Hit h = black_wand_RM_MakeMiss(0.0, ray.tMin, ray.origin + ray.direction * ray.tMin, 0.0);
    h.t = ray.tMin;
    h.missCode = 3.0;

    int boundedStepCount = min(max(activeStepCount, 1), BLACK_WAND_RM_COMPILE_MAX_STEPS);
    float safeMinStep = max(minStep, 0.000001);
    float safeStepScale = max(stepScale, 0.05);
    float marchDone = 0.0;

    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 0, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 1, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 2, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 3, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 4, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 5, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 6, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);
    black_wand_RM_MarchPrimaryStep(h, ray, sceneMode, 7, boundedStepCount, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, epsAbs, epsRel, safeMinStep, safeStepScale, marchDone);

    return h;
}

void black_wand_RM_RefineHitStep(
    inout float t,
    inout float side,
    black_wand_RM_Ray ray,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency)
{
    float3 pA = ray.origin + ray.direction * max(ray.tMin, t - side);
    float3 pB = ray.origin + ray.direction * min(ray.tMax, t + side);
    float dA = abs(black_wand_RM_EvaluateSceneLoopSafe(pA, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue);
    float dB = abs(black_wand_RM_EvaluateSceneLoopSafe(pB, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue);
    t = (dA < dB) ? max(ray.tMin, t - side) : min(ray.tMax, t + side);
    side *= 0.5;
}

black_wand_RM_Hit black_wand_RM_RefineHit(
    black_wand_RM_Hit h,
    black_wand_RM_Ray ray,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float refineScale)
{
    black_wand_RM_Hit result = h;
    if (result.hitFlag >= 0.5)
    {
        float t = result.t;
        float side = max(abs(result.lastStep), 0.001) * max(refineScale, 0.05);

        black_wand_RM_RefineHitStep(t, side, ray, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency);
        black_wand_RM_RefineHitStep(t, side, ray, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency);

        result.t = t;
        result.position = ray.origin + ray.direction * t;
        black_wand_RM_Field f = black_wand_RM_EvaluateSceneLoopSafe(result.position, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency);
        result.distanceValue = f.distanceValue;
        result.materialId = f.materialId;
        result.travel01 = saturate((result.t - ray.tMin) / max(ray.tMax - ray.tMin, 0.0001));
    }
    return result;
}

#endif
