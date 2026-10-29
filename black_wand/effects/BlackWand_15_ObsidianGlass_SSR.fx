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
// @BlackWand clean user-menu filter: @BlackWand - Obsidian Glass SSR. Primitive-based transpile from BlackWand obsidian/gloss SSR variants.
#include "../header/BlackWand_Extended_Common.fxh"

uniform int BWBlackWandX_Obs_DebugView < ui_type = "combo"; ui_label = "@BlackWand - Obsidian Glass SSR"; ui_category = "@BlackWand - Obsidian Glass SSR / 99 Advanced / Debug";
 ui_items = "Final Image\0Reflection Color\0Screen Confidence\0Depth Confidence\0Glass Mask\0Reflection Direction\0"; ui_tooltip = "Final Image shows the glass reflection. Diagnostics show reflected color, confidence masks, glass application, and direction.";
    ui_category_closed = true;
> = 0;
uniform float BWBlackWandX_Obs_Strength < ui_type = "slider"; ui_label = "Strength"; ui_category = "@BlackWand - Obsidian Glass SSR / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Overall mix of the obsidian glass reflection."; > = 0.70;
uniform float BWBlackWandX_Obs_GlassDarken < ui_type = "slider"; ui_label = "Glass Darkening"; ui_category = "@BlackWand - Obsidian Glass SSR / 01 Controls"; ui_min = 0.0; ui_max = 1.0; ui_step = 0.001; ui_tooltip = "Darkens the base layer before reflection, creating a black-glass response."; > = 0.28;
uniform float BWBlackWandX_Obs_ReflectionSaturation < ui_type = "slider"; ui_label = "Reflection Saturation"; ui_category = "@BlackWand - Obsidian Glass SSR / 01 Controls"; ui_min = 0.0; ui_max = 2.0; ui_step = 0.001; ui_tooltip = "Saturation applied to the sampled reflection color."; > = 0.85;
uniform float BWBlackWandX_Obs_DarkSurfaceStart <
    ui_type = "slider";
    ui_label = "Dark Surface Start";
    ui_category = "@BlackWand - Obsidian Glass SSR / 99 Advanced / Surface";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Luma point where the obsidian/dark-surface response begins.";
    ui_category_closed = true;
> = 0.42;
static const int BWBlackWandX_Obs_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWBlackWandX_Obs_TraceDistance < ui_type = "slider"; ui_label = "Reflection Distance (px)"; ui_category = "@BlackWand - Obsidian Glass SSR / 01 Controls";
 ui_min = 0.0; ui_max = 96.0; ui_step = 0.05; ui_tooltip = "Screen-space distance used to fetch the reflection color."; > = 18.0;
uniform float BWBlackWandX_Obs_DepthGradientScale <
    ui_type = "slider";
    ui_label = "Reflection Depth Scale";
    ui_category = "@BlackWand - Obsidian Glass SSR / 99 Advanced / Depth";
    ui_min = 0.0;
    ui_max = 3000.0;
    ui_step = 1.0;
    ui_tooltip = "Amplifies depth gradients used to steer the obsidian reflection smear.";
    ui_category_closed = true;
> = 1200.0;
uniform float BWBlackWandX_Obs_FallbackAngle <
    ui_type = "slider";
    ui_label = "Fallback Reflection Angle";
    ui_category = "@BlackWand - Obsidian Glass SSR / 99 Advanced / Surface";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_tooltip = "Fallback angle used when depth direction is weak.";
    ui_category_closed = true;
> = -32.0;
uniform float BWBlackWandX_Obs_DepthTolerance < ui_type = "slider"; ui_label = "Depth Match Tolerance"; ui_category = "@BlackWand - Obsidian Glass SSR / 01 Controls";
 ui_min = 0.0001; ui_max = 0.25; ui_step = 0.0001; ui_tooltip = "How closely reflected depth should match current depth to keep confidence."; > = 0.035;
static const int BWBlackWandX_Obs_ApplyMask = black_wand_MASK_ALWAYS; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Obs_ApplyMaskStrength = 1.0; // internal fixed control; hidden from the clean menu
static const float BWBlackWandX_Obs_DebugFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 BWBlackWandX_Obs_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float lumaValue = black_wand_BWT_Luma(sourceColor);
    float2 depthGradient = black_wand_Complex_SSR_DepthGradient(uv, BWBlackWandX_Obs_DepthMode, BWBlackWandX_Obs_DepthGradientScale);
    float2 reflectDirection = black_wand_Complex_SSR_ReflectDirection(depthGradient, BWBlackWandX_Obs_FallbackAngle);
    float2 reflectionUV = black_wand_Complex_SSR_ReflectionUV(uv, reflectDirection, BWBlackWandX_Obs_TraceDistance);
    float3 reflectedColor = black_wand_Proc_ColorSaturateAmount(black_wand_Proc_SourceColor(reflectionUV), BWBlackWandX_Obs_ReflectionSaturation);
    float screenConfidence = black_wand_Complex_SSR_ScreenConfidence(reflectionUV);
    float centerDepth = black_wand_Proc_DepthValue(uv, BWBlackWandX_Obs_DepthMode);
    float reflectedDepth = black_wand_Proc_DepthValue(reflectionUV, BWBlackWandX_Obs_DepthMode);
    float depthConfidence = black_wand_Complex_SSR_DepthConfidence(centerDepth, reflectedDepth, BWBlackWandX_Obs_DepthTolerance);
    float darkSurface = 1.0 - BWBlackWandX_HighlightMask(lumaValue, BWBlackWandX_Obs_DarkSurfaceStart, 0.12);
    float applyMask = BWBlackWandX_ApplyMask(BWBlackWandX_Obs_ApplyMask, uv, sourceColor, BWBlackWandX_Obs_ApplyMaskStrength);
    float glassMask = saturate(darkSurface * screenConfidence * depthConfidence * applyMask);
    float3 baseGlass = sourceColor * (1.0 - BWBlackWandX_Obs_GlassDarken * glassMask);
    float3 glassColor = black_wand_Complex_SSR_Composite(baseGlass, reflectedColor, glassMask, BWBlackWandX_Obs_Strength);
    if (BWBlackWandX_Obs_DebugView == 1) return black_wand_Proc_OutColor(reflectedColor, BWBlackWandX_Obs_DebugFloor);
    if (BWBlackWandX_Obs_DebugView == 2) return black_wand_Proc_OutScalar(screenConfidence, 1.0, BWBlackWandX_Obs_DebugFloor);
    if (BWBlackWandX_Obs_DebugView == 3) return black_wand_Proc_OutScalar(depthConfidence, 1.0, BWBlackWandX_Obs_DebugFloor);
    if (BWBlackWandX_Obs_DebugView == 4) return black_wand_Proc_OutScalar(glassMask, 1.0, BWBlackWandX_Obs_DebugFloor);
    if (BWBlackWandX_Obs_DebugView == 5) return black_wand_Proc_OutColor(saturate(float3(reflectDirection * 0.5 + 0.5, 0.0)), BWBlackWandX_Obs_DebugFloor);
    return black_wand_Proc_OutColor(glassColor, BWBlackWandX_Obs_DebugFloor);
}

technique BlackWand_ObsidianGlass_SSR < ui_label = "@BlackWand - Obsidian Glass SSR"; ui_tooltip = "Dark glass reflection pass using primitive SSR confidence, depth matching, and dark-surface targeting."; >
{
    pass { VertexShader = PostProcessVS; PixelShader = BWBlackWandX_Obs_PS; }
}

