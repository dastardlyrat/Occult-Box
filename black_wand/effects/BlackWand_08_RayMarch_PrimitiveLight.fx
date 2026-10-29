#ifndef BW_RESTORE_XCOM_HOTFIX_SAFE_NUMERIC_FXH
#define BW_RESTORE_XCOM_HOTFIX_SAFE_NUMERIC_FXH 1
float BW_RESTORE_XCOM_SafePow(float baseValue, float exponentValue)
{
    float safeBase = max(abs(baseValue), 0.0);
    return (safeBase <= 0.0) ? 0.0 : exp(log(safeBase) * exponentValue);
}
int BW_RESTORE_XCOM_IntDivNoWarn(int value, int divisor)
{
    float safeDivisor = max(abs(float(divisor)), 1.0);
    float quotient = floor(float(value) / safeDivisor);
    return int(quotient);
}
int BW_RESTORE_XCOM_IntModuloNoWarn(int value, int modulus)
{
    float safeModulus = max(abs(float(modulus)), 1.0);
    float quotient = floor(float(value) / safeModulus);
    return int(float(value) - safeModulus * quotient);
}
#define pow BW_RESTORE_XCOM_SafePow
#endif
// @BlackWand clean user-menu filter: @BlackWand - Raymarch - Primitive Light. Logic preserved from first primitive transpile; menu rebuilt for usability.
#define BLACK_WAND_RM_COMPILE_MAX_STEPS 8
#define BLACK_WAND_RM_AO_STEPS 2
#define BLACK_WAND_RM_SHADOW_STEPS 3
#include "../header/BlackWand_Common.fxh"
#include "../header/black_wand_RM_All.fxh"

uniform int BWT_RM_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Raymarch - Primitive Light";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Debug";
    ui_items = "Final Image\0Hit Mask\0Step Heat - ray cost\0Surface Normal\0Material ID\0Travel Depth\0Miss Code\0";
    ui_tooltip = "Switch between final overlay, hit mask, step heat, normals, material ID, travel depth, and miss code.";
    ui_category_closed = true;
> = 0;
uniform float BWT_RM_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall amount of raymarched primitive overlay.";
> = 1.0;
uniform float BWT_RM_SourceColorInfluence <
    ui_type = "slider";
    ui_label = "Source Color Influence";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Material";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "How much screen color tints the raymarched primitive material.";
    ui_category_closed = true;
> = 0.35;
uniform float BWT_RM_OverlayStrength <
    ui_type = "slider";
    ui_label = "Overlay";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Opacity of the primitive overlay where the ray hits.";
> = 0.85;
uniform float BWT_RM_FovY <
    ui_type = "slider";
    ui_label = "Field of View";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Camera Ray";
    ui_min = 20.0;
    ui_max = 120.0;
    ui_step = 0.1;
    ui_tooltip = "Vertical field of view used to build the internal raymarch camera.";
    ui_category_closed = true;
> = 58.0;
uniform float BWT_RM_CameraZ <
    ui_type = "slider";
    ui_label = "Camera Distance";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Camera Ray";
    ui_min = -10.0;
    ui_max = -0.5;
    ui_step = 0.01;
    ui_tooltip = "Camera Z offset for the internal primitive-field view.";
    ui_category_closed = true;
> = -3.0;
static const float BWT_RM_TMin = 0.05; // internal fixed control; hidden from the clean menu
uniform float BWT_RM_TMax <
    ui_type = "slider";
    ui_label = "Trace Distance";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Trace";
    ui_min = 0.25;
    ui_max = 20.0;
    ui_step = 0.01;
    ui_tooltip = "Maximum distance the primitive raymarch can travel.";
    ui_category_closed = true;
> = 7.0;
uniform int BWT_RM_SceneMode <
    ui_type = "combo";
    ui_label = "Scene";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_items = "Sphere\0CSG Gallery\0Rounded Machine\0Capsule Torus\0Repeated Cells\0Shell Field\0Ground Objects\0Hex Column\0";
    ui_tooltip = "Selects the procedural primitive field being raymarched.";
> = BLACK_WAND_RM_SCENE_CSG_GALLERY;
uniform float BWT_RM_Steps_UI <
    ui_type = "slider";
    ui_label = "Step Budget";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Trace";
    ui_min = 1.0;
    ui_max = 8.0;
    ui_step = 1.0;
    ui_tooltip = "Visible step cap for the unrolled primitive raymarch helper.";
    ui_category_closed = true;
> = 8.0;
uniform float BWT_RM_SceneScale <
    ui_type = "slider";
    ui_label = "Scene Scale";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_min = 0.1;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Scales the primitive field.";
> = 1.0;
uniform float BWT_RM_Morph <
    ui_type = "slider";
    ui_label = "Morph";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Morph/control amount passed into the selected primitive scene.";
> = 0.35;
uniform float BWT_RM_SmoothUnion <
    ui_type = "slider";
    ui_label = "Shape Blend";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Primitive Field";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Smoothness used when primitive forms blend together.";
    ui_category_closed = true;
> = 0.12;
uniform float BWT_RM_RepeatSpacing <
    ui_type = "slider";
    ui_label = "Repeat Spacing";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Primitive Field";
    ui_min = 0.25;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Spacing of repeated primitive cells in the internal field.";
    ui_category_closed = true;
> = 0.90;
static const float BWT_RM_DisplaceAmount = 0.0; // internal fixed control; hidden from the clean menu
static const float BWT_RM_DisplaceFrequency = 3.0; // internal fixed control; hidden from the clean menu
static const float BWT_RM_EpsAbs = 0.001; // internal fixed control; hidden from the clean menu
static const float BWT_RM_EpsRel = 0.001; // internal fixed control; hidden from the clean menu
static const float BWT_RM_MinStep = 0.0005; // internal fixed control; hidden from the clean menu
static const float BWT_RM_StepScale = 0.85; // internal fixed control; hidden from the clean menu
static const int BWT_RM_NormalMode = 0; // internal fixed control; hidden from the clean menu
static const float BWT_RM_NormalEpsilon = 0.004; // internal fixed control; hidden from the clean menu
uniform float BWT_RM_Ambient <
    ui_type = "slider";
    ui_label = "Ambient";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Base light level on primitive surfaces.";
> = 0.24;
uniform float BWT_RM_Diffuse <
    ui_type = "slider";
    ui_label = "Diffuse";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Main directional light strength.";
> = 0.95;
uniform float BWT_RM_Rim <
    ui_type = "slider";
    ui_label = "Rim Light";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Lighting";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Adds rim light around the primitive silhouette.";
    ui_category_closed = true;
> = 0.22;
uniform float BWT_RM_AOStrength <
    ui_type = "slider";
    ui_label = "Primitive AO";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Lighting";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Ambient occlusion strength for the raymarched primitive.";
    ui_category_closed = true;
> = 0.65;
uniform float BWT_RM_ShadowStrength <
    ui_type = "slider";
    ui_label = "Primitive Shadow";
    ui_category = "@BlackWand - Raymarch - Primitive Light / 99 Advanced / Lighting";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Shadow strength for the raymarched primitive.";
    ui_category_closed = true;
> = 0.45;
static const float BWT_RM_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_RayMarch_Material_Light_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float aspectValue = ReShade::ScreenSize.x / max(ReShade::ScreenSize.y, 1.0);
    black_wand_RM_Ray ray = black_wand_RM_MakePerspectiveRay(uv, aspectValue, BWT_RM_FovY, float3(0.0, 0.0, BWT_RM_CameraZ), 0.0, 0.0, 0.0, BWT_RM_TMin, BWT_RM_TMax);
    black_wand_RM_Hit hitValue = black_wand_RM_MarchPrimary(ray, BWT_RM_SceneMode, int(round(BWT_RM_Steps_UI)), BWT_RM_SceneScale, BWT_RM_Morph, BWT_RM_SmoothUnion, BWT_RM_RepeatSpacing, BWT_RM_DisplaceAmount, BWT_RM_DisplaceFrequency, BWT_RM_EpsAbs, BWT_RM_EpsRel, BWT_RM_MinStep, BWT_RM_StepScale);
    hitValue = black_wand_RM_RefineHit(hitValue, ray, BWT_RM_SceneMode, BWT_RM_SceneScale, BWT_RM_Morph, BWT_RM_SmoothUnion, BWT_RM_RepeatSpacing, BWT_RM_DisplaceAmount, BWT_RM_DisplaceFrequency, 0.5);
    float3 normalValue = black_wand_RM_SelectNormal(hitValue.position, BWT_RM_NormalMode, BWT_RM_SceneMode, BWT_RM_SceneScale, BWT_RM_Morph, BWT_RM_SmoothUnion, BWT_RM_RepeatSpacing, BWT_RM_DisplaceAmount, BWT_RM_DisplaceFrequency, BWT_RM_NormalEpsilon);
    float3 materialColor = black_wand_RM_MaterialColor(hitValue.materialId, sourceColor, BWT_RM_SourceColorInfluence);
    float3 lightDir = black_wand_RM_SafeNormalize3(float3(-0.35, 0.55, -0.65), float3(0.0, 1.0, -1.0));
    float aoValue = lerp(1.0, black_wand_RM_AmbientOcclusion(hitValue.position, normalValue, BWT_RM_SceneMode, BWT_RM_SceneScale, BWT_RM_Morph, BWT_RM_SmoothUnion, BWT_RM_RepeatSpacing, BWT_RM_DisplaceAmount, BWT_RM_DisplaceFrequency, 0.20, BWT_RM_AOStrength), hitValue.hitFlag);
    float shadowValue = lerp(1.0, black_wand_RM_SoftShadow(hitValue.position, normalValue, lightDir, BWT_RM_SceneMode, BWT_RM_SceneScale, BWT_RM_Morph, BWT_RM_SmoothUnion, BWT_RM_RepeatSpacing, BWT_RM_DisplaceAmount, BWT_RM_DisplaceFrequency, 0.035, 1.2, 12.0), hitValue.hitFlag * BWT_RM_ShadowStrength);
    float3 litColor = black_wand_RM_LitColor(materialColor, normalValue, ray.direction, lightDir, BWT_RM_Ambient, BWT_RM_Diffuse, BWT_RM_Rim, aoValue, shadowValue);
    float3 overlayColor = black_wand_RM_OverlayColor(sourceColor, litColor, BWT_RM_OverlayStrength * hitValue.hitFlag * BWT_RM_MasterIntensity);
    if (BWT_RM_DebugView == 1) return black_wand_Proc_OutScalar(hitValue.hitFlag, 1.0, BWT_RM_VisibleFloor);
    if (BWT_RM_DebugView == 2) return black_wand_Proc_OutColor(black_wand_RM_HeatColor(hitValue.stepCount / 8.0), BWT_RM_VisibleFloor);
    if (BWT_RM_DebugView == 3) return black_wand_Proc_OutColor(black_wand_RM_NormalColor(normalValue), BWT_RM_VisibleFloor);
    if (BWT_RM_DebugView == 4) return black_wand_Proc_OutColor(black_wand_RM_MaterialIdColor(hitValue.materialId), BWT_RM_VisibleFloor);
    if (BWT_RM_DebugView == 5) return black_wand_Proc_OutScalar(hitValue.travel01, 1.0, BWT_RM_VisibleFloor);
    if (BWT_RM_DebugView == 6) return black_wand_Proc_OutColor(black_wand_RM_MissCodeColor(hitValue.missCode), BWT_RM_VisibleFloor);
    return black_wand_Proc_OutColor(overlayColor, BWT_RM_VisibleFloor);
}

technique BlackWand_RayMarch_PrimitiveLight <
    ui_label = "@BlackWand - Raymarch - Primitive Light";
    ui_tooltip = "Procedural raymarched primitive overlay with material color, normals, lighting, AO, and debug heat views.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_RayMarch_Material_Light_PS;
    }
}

