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
// @BlackWand clean user-menu filter: @BlackWand - Gloss SSR - Material Sheen. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_Gloss_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Gloss SSR - Material Sheen";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Debug";
    ui_items = "Final Image\0Gloss Mask\0Depth Gradient\0Reflection Candidate\0Reflection Apply Mask\0";
    ui_tooltip = "Switch between final sheen, gloss mask, depth gradient, reflection candidate, and reflection mask.";
    ui_category_closed = true;
> = 0;
uniform float BWT_Gloss_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall amount of gloss/reflection contribution.";
> = 1.0;
uniform float BWT_Gloss_GlossStrength <
    ui_type = "slider";
    ui_label = "Gloss Amount";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Strength of the final glossy sheen.";
> = 0.55;
uniform float BWT_Gloss_BloomStrength <
    ui_type = "slider";
    ui_label = "Specular Bloom";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Highlight";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Adds a controlled glow from the gloss/specular term.";
    ui_category_closed = true;
> = 0.25;
uniform float BWT_Gloss_Threshold <
    ui_type = "slider";
    ui_label = "Gloss Threshold";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Brightness level where gloss begins.";
> = 0.55;
uniform float BWT_Gloss_Softness <
    ui_type = "slider";
    ui_label = "Specular Feather";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Highlight";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softens the gloss mask threshold.";
    ui_category_closed = true;
> = 0.20;
uniform float BWT_Gloss_Roughness <
    ui_type = "slider";
    ui_label = "Roughness";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Higher values make reflection response broader and less mirror-like.";
> = 0.30;
uniform float BWT_Gloss_Saturation <
    ui_type = "slider";
    ui_label = "Reflection Saturation";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Color";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Color saturation for the reflected/gloss contribution.";
    ui_category_closed = true;
> = 1.05;
static const int BWT_Gloss_DepthMode = black_wand_PRIMITIVE_DEPTH_MODE_RAW; // internal fixed control; hidden from the clean menu
uniform float BWT_Gloss_DepthGradientScale <
    ui_type = "slider";
    ui_label = "Depth Reflection Scale";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Depth";
    ui_min = 0.0;
    ui_max = 2500.0;
    ui_step = 1.0;
    ui_tooltip = "Amplifies depth gradients used to shape the SSR-like sheen direction.";
    ui_category_closed = true;
> = 850.0;
uniform float BWT_Gloss_RayDistancePixels <
    ui_type = "slider";
    ui_label = "Reflection Reach";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 01 Controls";
    ui_min = 0.0;
    ui_max = 256.0;
    ui_step = 0.05;
    ui_tooltip = "Screen-space offset distance for the reflection candidate sample.";
> = 32.0;
uniform float BWT_Gloss_DepthTolerance <
    ui_type = "slider";
    ui_label = "Depth Match";
    ui_category = "@BlackWand - Gloss SSR - Material Sheen / 01 Controls";
    ui_min = 0.0001;
    ui_max = 1.0;
    ui_step = 0.0001;
    ui_tooltip = "How much depth mismatch is allowed before the reflection is rejected.";
> = 0.080;
static const float BWT_Gloss_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_Gloss_SSR_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float sourceLuma = black_wand_BWT_Luma(sourceColor);
    float sourceSat = black_wand_Proc_ColorSaturationApprox(sourceColor);
    float glossMask = black_wand_BWT_SoftMask(sourceLuma + sourceSat * 0.35, BWT_Gloss_Threshold, BWT_Gloss_Softness);
    float2 depthGradient = black_wand_Complex_SSR_DepthGradient(uv, BWT_Gloss_DepthMode, BWT_Gloss_DepthGradientScale);
    float2 reflectDir = black_wand_Complex_SSR_ReflectDirection(depthGradient, 0.0);
    float2 reflectUV = black_wand_Complex_SSR_ReflectionUV(uv, reflectDir, BWT_Gloss_RayDistancePixels);
    float screenConfidence = black_wand_Complex_SSR_ScreenConfidence(reflectUV);
    float centerDepth = black_wand_Proc_DepthValue(uv, BWT_Gloss_DepthMode);
    float reflectedDepth = black_wand_Proc_DepthValue(reflectUV, BWT_Gloss_DepthMode);
    float depthConfidence = black_wand_Complex_SSR_DepthConfidence(centerDepth, reflectedDepth, BWT_Gloss_DepthTolerance);
    float hitConfidence = screenConfidence * depthConfidence * glossMask;
    float3 reflectedColor = black_wand_Proc_SourceColor(reflectUV);
    float3 roughColor = black_wand_BWT_LocalAverage4(reflectUV, BWT_Gloss_RayDistancePixels * 0.10 + 1.0);
    float3 responseColor = black_wand_Proc_ColorSaturateAmount(lerp(reflectedColor, roughColor, BWT_Gloss_Roughness), BWT_Gloss_Saturation);
    float3 glossColor = black_wand_Proc_SSRComposite(sourceColor, responseColor, hitConfidence, BWT_Gloss_GlossStrength * BWT_Gloss_MasterIntensity);
    float bloomMask = black_wand_BWT_SoftMask(black_wand_BWT_Luma(responseColor), 0.72, 0.18) * hitConfidence;
    float3 finalColor = black_wand_Proc_ComposeAdditive(glossColor, responseColor * bloomMask, BWT_Gloss_BloomStrength * BWT_Gloss_MasterIntensity);
    if (BWT_Gloss_DebugView == 1) return black_wand_Proc_OutColor(float3(reflectUV.x, reflectUV.y, screenConfidence), BWT_Gloss_VisibleFloor);
    if (BWT_Gloss_DebugView == 2) return black_wand_Proc_OutScalar(hitConfidence, 1.0, BWT_Gloss_VisibleFloor);
    if (BWT_Gloss_DebugView == 3) return black_wand_Proc_OutScalar(glossMask, 1.0, BWT_Gloss_VisibleFloor);
    if (BWT_Gloss_DebugView == 4) return black_wand_Proc_OutScalar(bloomMask, 1.0, BWT_Gloss_VisibleFloor);
    return black_wand_Proc_OutColor(finalColor, BWT_Gloss_VisibleFloor);
}

technique BlackWand_GlossSSR_MaterialSheen <
    ui_label = "@BlackWand - Gloss SSR - Material Sheen";
    ui_tooltip = "Gloss, sheen, and short SSR-style reflection cue. Works best after depth setup is correct.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_Gloss_SSR_PS;
    }
}

