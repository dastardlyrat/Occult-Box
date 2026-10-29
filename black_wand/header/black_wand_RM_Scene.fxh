#ifndef BLACK_WAND_RM_SCENE_FXH
#define BLACK_WAND_RM_SCENE_FXH 1

#ifndef BLACK_WAND_RM_SCENE_SPHERE
#define BLACK_WAND_RM_SCENE_SPHERE 0
#endif
#ifndef BLACK_WAND_RM_SCENE_CSG_GALLERY
#define BLACK_WAND_RM_SCENE_CSG_GALLERY 1
#endif
#ifndef BLACK_WAND_RM_SCENE_ROUNDED_MACHINE
#define BLACK_WAND_RM_SCENE_ROUNDED_MACHINE 2
#endif
#ifndef BLACK_WAND_RM_SCENE_CAPSULE_TORUS
#define BLACK_WAND_RM_SCENE_CAPSULE_TORUS 3
#endif
#ifndef BLACK_WAND_RM_SCENE_REPEATED_CELLS
#define BLACK_WAND_RM_SCENE_REPEATED_CELLS 4
#endif
#ifndef BLACK_WAND_RM_SCENE_SHELL_FIELD
#define BLACK_WAND_RM_SCENE_SHELL_FIELD 5
#endif
#ifndef BLACK_WAND_RM_SCENE_GROUND_OBJECTS
#define BLACK_WAND_RM_SCENE_GROUND_OBJECTS 6
#endif
#ifndef BLACK_WAND_RM_SCENE_HEX_COLUMN
#define BLACK_WAND_RM_SCENE_HEX_COLUMN 7
#endif

black_wand_RM_Field black_wand_RM_EvaluateScene(
    float3 p,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency)
{
    float safeScale = max(sceneScale, 0.0001);
    float3 q = p / safeScale;
    float k = max(smoothUnionAmount, 0.00001);
    float morph = saturate(morphAmount);
    float displaceAmp = displacementAmount;
    float displaceFreq = max(displacementFrequency, 0.0001);

    black_wand_RM_Field result = black_wand_RM_MakeField(100000.0, 0.0);

    if (sceneMode == BLACK_WAND_RM_SCENE_SPHERE)
    {
        float d = black_wand_RM_sdSphere(q, lerp(0.65, 1.05, morph));
        d += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result = black_wand_RM_MakeField(d * safeScale, 1.0);
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_CSG_GALLERY)
    {
        black_wand_RM_Field a = black_wand_RM_MakeField(black_wand_RM_sdSphere(q - float3(-0.75, 0.0, 0.0), 0.55), 1.0);
        black_wand_RM_Field b = black_wand_RM_MakeField(black_wand_RM_sdBox(q - float3(0.72, 0.0, 0.0), float3(0.45, 0.45, 0.45)), 2.0);
        black_wand_RM_Field c = black_wand_RM_MakeField(black_wand_RM_sdCappedCylinderY(q - float3(0.0, -0.12, 0.58), 0.42, 0.32), 3.0);
        result = black_wand_RM_FieldSmoothUnion(a, b, k);
        result = black_wand_RM_FieldUnion(result, c);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_ROUNDED_MACHINE)
    {
        float3 t = black_wand_RM_TwistY(q, lerp(0.0, 1.65, morph));
        black_wand_RM_Field body = black_wand_RM_MakeField(black_wand_RM_sdRoundBox(t, float3(0.78, 0.42, 0.42), 0.16), 2.0);
        black_wand_RM_Field cut = black_wand_RM_MakeField(black_wand_RM_sdSphere(t - float3(0.0, 0.0, 0.05), 0.45), 4.0);
        black_wand_RM_Field rail = black_wand_RM_MakeField(black_wand_RM_sdCapsule(t, float3(-0.9, 0.48, 0.0), float3(0.9, 0.48, 0.0), 0.08), 5.0);
        result = black_wand_RM_FieldSubtract(body, cut);
        result = black_wand_RM_FieldUnion(result, rail);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_CAPSULE_TORUS)
    {
        black_wand_RM_Field capsuleA = black_wand_RM_MakeField(black_wand_RM_sdCapsule(q, float3(-0.82, -0.18, 0.0), float3(0.82, 0.18, 0.0), 0.18), 3.0);
        black_wand_RM_Field capsuleB = black_wand_RM_MakeField(black_wand_RM_sdCapsule(q, float3(-0.82, 0.18, 0.0), float3(0.82, -0.18, 0.0), 0.18), 4.0);
        black_wand_RM_Field torusA = black_wand_RM_MakeField(black_wand_RM_sdTorusY(q, lerp(0.48, 0.68, morph), 0.08), 5.0);
        result = black_wand_RM_FieldSmoothUnion(capsuleA, capsuleB, k);
        result = black_wand_RM_FieldUnion(result, torusA);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_REPEATED_CELLS)
    {
        float cell = max(repeatSpacing, 0.25);
        float3 rp = black_wand_RM_Repeat(q, float3(cell, cell, cell));
        black_wand_RM_Field cellSphere = black_wand_RM_MakeField(black_wand_RM_sdSphere(rp, lerp(0.16, 0.31, morph)), 6.0);
        black_wand_RM_Field cellBox = black_wand_RM_MakeField(black_wand_RM_sdBox(rp, float3(0.18, 0.18, 0.18)), 7.0);
        result = black_wand_RM_FieldSmoothUnion(cellSphere, cellBox, k);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_SHELL_FIELD)
    {
        black_wand_RM_Field sphereA = black_wand_RM_MakeField(black_wand_RM_ShellDistance(black_wand_RM_sdSphere(q, 0.8), lerp(0.025, 0.12, morph)), 8.0);
        black_wand_RM_Field torusB = black_wand_RM_MakeField(black_wand_RM_sdTorusY(black_wand_RM_RotateX(q, 1.5707963), 0.55, 0.045), 5.0);
        result = black_wand_RM_FieldUnion(sphereA, torusB);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_GROUND_OBJECTS)
    {
        black_wand_RM_Field ground = black_wand_RM_MakeField(black_wand_RM_sdPlane(q, float3(0.0, 1.0, 0.0), 0.62), 9.0);
        black_wand_RM_Field sphereA = black_wand_RM_MakeField(black_wand_RM_sdSphere(q - float3(-0.55, -0.15, 0.15), 0.42), 1.0);
        black_wand_RM_Field boxA = black_wand_RM_MakeField(black_wand_RM_sdRoundBox(q - float3(0.52, -0.18, 0.0), float3(0.36, 0.36, 0.36), 0.08), 2.0);
        result = black_wand_RM_FieldUnion(ground, sphereA);
        result = black_wand_RM_FieldSmoothUnion(result, boxA, k);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }
    else
    {
        float3 columnP = q;
        columnP.xz = black_wand_RM_RotateY(columnP, lerp(0.0, 1.2, morph)).xz;
        black_wand_RM_Field column = black_wand_RM_MakeField(black_wand_RM_sdHexPrismY(columnP, 0.55, 0.8), 10.0);
        black_wand_RM_Field ring = black_wand_RM_MakeField(black_wand_RM_sdTorusY(columnP, 0.55, 0.055), 5.0);
        result = black_wand_RM_FieldUnion(column, ring);
        result.distanceValue += black_wand_RM_DisplaceSin(q, displaceAmp, displaceFreq);
        result.distanceValue *= safeScale;
        result.localBound = abs(result.distanceValue);
    }

    return result;
}


// Compile-safe evaluator for loop bodies.
// Keeps RM viewports useful while preventing the compiler from expanding the full scene library inside every marched step.
black_wand_RM_Field black_wand_RM_EvaluateSceneLoopSafe(
    float3 p,
    int sceneMode,
    float sceneScale,
    float morphAmount,
    float smoothUnionAmount,
    float repeatSpacing,
    float displacementAmount,
    float displacementFrequency)
{
    float safeScale = max(sceneScale, 0.0001);
    float3 q = p / safeScale;
    float morph = saturate(morphAmount);
    float displace = black_wand_RM_DisplaceSin(q, displacementAmount, max(displacementFrequency, 0.0001));

    float d = black_wand_RM_sdSphere(q, lerp(0.60, 0.95, morph));
    float materialId = 1.0;

    if (sceneMode == BLACK_WAND_RM_SCENE_CSG_GALLERY || sceneMode == BLACK_WAND_RM_SCENE_ROUNDED_MACHINE)
    {
        float boxD = black_wand_RM_sdRoundBox(q - float3(0.16, 0.0, 0.0), float3(0.48, 0.36, 0.36), 0.10);
        float sphereD = black_wand_RM_sdSphere(q - float3(-0.42, 0.04, 0.0), 0.42);
        d = min(boxD, sphereD);
        materialId = (boxD < sphereD) ? 2.0 : 1.0;
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_CAPSULE_TORUS || sceneMode == BLACK_WAND_RM_SCENE_SHELL_FIELD)
    {
        float capsuleD = black_wand_RM_sdCapsule(q, float3(-0.58, -0.12, 0.0), float3(0.58, 0.12, 0.0), 0.18);
        float torusD = black_wand_RM_sdTorusY(q, lerp(0.42, 0.58, morph), 0.075);
        d = min(capsuleD, torusD);
        materialId = (capsuleD < torusD) ? 3.0 : 5.0;
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_REPEATED_CELLS)
    {
        float cell = max(repeatSpacing, 0.30);
        float3 rp = black_wand_RM_Repeat(q, float3(cell, cell, cell));
        d = black_wand_RM_sdSphere(rp, lerp(0.14, 0.26, morph));
        materialId = 6.0;
    }
    else if (sceneMode == BLACK_WAND_RM_SCENE_GROUND_OBJECTS || sceneMode == BLACK_WAND_RM_SCENE_HEX_COLUMN)
    {
        float groundD = black_wand_RM_sdPlane(q, float3(0.0, 1.0, 0.0), 0.62);
        float objectD = black_wand_RM_sdSphere(q - float3(0.0, -0.16, 0.0), 0.46);
        d = min(groundD, objectD);
        materialId = (groundD < objectD) ? 9.0 : 7.0;
    }

    d = (d + displace) * safeScale;
    return black_wand_RM_MakeField(d, materialId);
}

#endif
