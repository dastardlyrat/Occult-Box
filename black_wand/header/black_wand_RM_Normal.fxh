#ifndef BLACK_WAND_RM_NORMAL_FXH
#define BLACK_WAND_RM_NORMAL_FXH 1

float3 black_wand_RM_NormalCentral(
    float3 p,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float normalEpsilon)
{
    float e = max(normalEpsilon, 0.0001);
    float dx1 = black_wand_RM_EvaluateSceneLoopSafe(p + float3(e, 0.0, 0.0), sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float dx0 = black_wand_RM_EvaluateSceneLoopSafe(p - float3(e, 0.0, 0.0), sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float dy1 = black_wand_RM_EvaluateSceneLoopSafe(p + float3(0.0, e, 0.0), sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float dy0 = black_wand_RM_EvaluateSceneLoopSafe(p - float3(0.0, e, 0.0), sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float dz1 = black_wand_RM_EvaluateSceneLoopSafe(p + float3(0.0, 0.0, e), sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float dz0 = black_wand_RM_EvaluateSceneLoopSafe(p - float3(0.0, 0.0, e), sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    return black_wand_RM_SafeNormalize3(float3(dx1 - dx0, dy1 - dy0, dz1 - dz0), float3(0.0, 0.0, -1.0));
}

float3 black_wand_RM_NormalTetra(
    float3 p,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float normalEpsilon)
{
    float e = max(normalEpsilon, 0.0001);
    float3 k1 = float3( 1.0, -1.0, -1.0);
    float3 k2 = float3(-1.0, -1.0,  1.0);
    float3 k3 = float3(-1.0,  1.0, -1.0);
    float3 k4 = float3( 1.0,  1.0,  1.0);
    float d1 = black_wand_RM_EvaluateSceneLoopSafe(p + k1 * e, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float d2 = black_wand_RM_EvaluateSceneLoopSafe(p + k2 * e, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float d3 = black_wand_RM_EvaluateSceneLoopSafe(p + k3 * e, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    float d4 = black_wand_RM_EvaluateSceneLoopSafe(p + k4 * e, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency).distanceValue;
    return black_wand_RM_SafeNormalize3(k1 * d1 + k2 * d2 + k3 * d3 + k4 * d4, float3(0.0, 0.0, -1.0));
}

float3 black_wand_RM_SelectNormal(
    float3 p,
    int normalMode,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency,
    float normalEpsilon)
{
    if (normalMode == 1)
    {
        return black_wand_RM_NormalCentral(p, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, normalEpsilon);
    }
    return black_wand_RM_NormalTetra(p, sceneMode, sceneScale, morphAmount, smoothUnionAmount, repeatSpacing, displacementAmount, displacementFrequency, normalEpsilon);
}

#endif
