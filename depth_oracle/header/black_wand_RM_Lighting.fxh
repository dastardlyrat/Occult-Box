#ifndef BLACK_WAND_RM_LIGHTING_FXH
#define BLACK_WAND_RM_LIGHTING_FXH 1

float3 black_wand_RM_MaterialColor(float materialId, float3 sourceColor, float sourceColorInfluence)
{
    float3 c = float3(0.78, 0.82, 0.88);
    if (materialId < 1.5) c = float3(0.85, 0.35, 0.22);
    else if (materialId < 2.5) c = float3(0.24, 0.62, 0.88);
    else if (materialId < 3.5) c = float3(0.32, 0.84, 0.45);
    else if (materialId < 4.5) c = float3(0.88, 0.72, 0.28);
    else if (materialId < 5.5) c = float3(0.75, 0.48, 0.90);
    else if (materialId < 6.5) c = float3(0.40, 0.78, 0.78);
    else if (materialId < 7.5) c = float3(0.95, 0.52, 0.42);
    else if (materialId < 8.5) c = float3(0.92, 0.92, 0.62);
    else if (materialId < 9.5) c = float3(0.34, 0.34, 0.38);
    else c = float3(0.92, 0.92, 0.98);
    return lerp(c, c * max(sourceColor, 0.05), saturate(sourceColorInfluence));
}

void black_wand_RM_AOStep(
    inout float occ,
    inout float weight,
    float3 p,
    float3 n,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float radius,
    int stepIndex)
{
    float fi = float(stepIndex + 1);
    float sampleDistance = radius * fi / float(BLACK_WAND_RM_AO_STEPS);
    float d = black_wand_RM_EvaluateSceneLoopSafe(p + n * sampleDistance, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    occ += max(sampleDistance - d, 0.0) * weight;
    weight *= 0.62;
}

float black_wand_RM_AmbientOcclusion(
    float3 p,
    float3 n,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float aoRadius,
    float aoStrength)
{
    float occ = 0.0;
    float weight = 1.0;
    float radius = max(aoRadius, 0.001);

    black_wand_RM_AOStep(occ, weight, p, n, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, radius, 0);
    black_wand_RM_AOStep(occ, weight, p, n, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, radius, 1);

    return saturate(1.0 - occ * aoStrength);
}

void black_wand_RM_ShadowStep(
    inout float res,
    inout float t,
    inout float shadowDone,
    float3 startP,
    float3 lightDir,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float endT,
    float softness)
{
    if (shadowDone > 0.5)
    {
        return;
    }

    float3 q = startP + lightDir * t;
    float d = black_wand_RM_EvaluateSceneLoopSafe(q, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    res = min(res, softness * d / max(t, 0.0001));
    t += clamp(abs(d), 0.02, 0.25);

    if (t > endT)
    {
        shadowDone = 1.0;
    }
}

float black_wand_RM_SoftShadow(
    float3 p,
    float3 n,
    float3 lightDir,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float shadowStart,
    float shadowEnd,
    float shadowSoftness)
{
    float res = 1.0;
    float t = max(shadowStart, 0.001);
    float endT = max(shadowEnd, t + 0.001);
    float softness = max(shadowSoftness, 0.1);
    float3 startP = p + n * max(shadowStart, 0.001);
    float shadowDone = 0.0;

    black_wand_RM_ShadowStep(res, t, shadowDone, startP, lightDir, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, endT, softness);
    black_wand_RM_ShadowStep(res, t, shadowDone, startP, lightDir, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, endT, softness);
    black_wand_RM_ShadowStep(res, t, shadowDone, startP, lightDir, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, endT, softness);

    return saturate(res);
}

float3 black_wand_RM_LitColor(
    float3 materialColor,
    float3 normalValue,
    float3 viewDir,
    float3 lightDir,
    float ambientAmount,
    float diffuseAmount,
    float rimAmount,
    float aoValue,
    float shadowValue)
{
    float ndl = saturate(dot(normalValue, lightDir));
    float rim = pow(saturate(1.0 - dot(normalValue, -viewDir)), 2.0);
    float light = ambientAmount + diffuseAmount * ndl * shadowValue;
    return materialColor * light * aoValue + materialColor * rim * rimAmount;
}

#endif
