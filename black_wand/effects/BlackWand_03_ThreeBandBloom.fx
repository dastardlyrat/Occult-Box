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
// @BlackWand clean user-menu filter: @BlackWand - Three-Band Bloom. Logic preserved from first primitive transpile; menu rebuilt for usability.
#include "../header/BlackWand_Common.fxh"

uniform int BWT_Bloom_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Three-Band Bloom";
    ui_category = "@BlackWand - Three-Band Bloom / 99 Advanced / Debug";
    ui_items = "Final Image\0Core Mask - hottest highlights\0Photosphere Halo - near glow\0Corona Halo - wide glow\0Bloom Only - added light\0";
    ui_tooltip = "Switch between final bloom, hot core, near halo, wide corona, and bloom-only output.";
    ui_category_closed = true;
> = 0;
uniform float BWT_Bloom_MasterIntensity <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Overall bloom contribution.";
> = 1.0;
uniform float BWT_Bloom_CoreThreshold <
    ui_type = "slider";
    ui_label = "Threshold";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Brightness level that begins the bloom core.";
> = 0.72;
uniform float BWT_Bloom_CoreSoftness <
    ui_type = "slider";
    ui_label = "Threshold Feather";
    ui_category = "@BlackWand - Three-Band Bloom / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Softness around the bloom threshold. Raise for smoother bloom onset; lower for hard highlight bloom.";
    ui_category_closed = true;
> = 0.20;
uniform float BWT_Bloom_CoreIntensity <
    ui_type = "slider";
    ui_label = "Core Amount";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Intensity of the tight bright highlight core.";
> = 0.70;
uniform float BWT_Bloom_PhotosphereRadius <
    ui_type = "slider";
    ui_label = "Near Halo";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 96.0;
    ui_step = 0.05;
    ui_tooltip = "Radius of the smaller halo around highlights.";
> = 8.0;
uniform float BWT_Bloom_PhotosphereIntensity <
    ui_type = "slider";
    ui_label = "Near Halo Amount";
    ui_category = "@BlackWand - Three-Band Bloom / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Intensity multiplier for the near halo band.";
    ui_category_closed = true;
> = 0.45;
uniform float BWT_Bloom_CoronaRadius <
    ui_type = "slider";
    ui_label = "Wide Halo";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 192.0;
    ui_step = 0.05;
    ui_tooltip = "Radius of the broad outer glow.";
> = 28.0;
uniform float BWT_Bloom_CoronaIntensity <
    ui_type = "slider";
    ui_label = "Wide Halo Amount";
    ui_category = "@BlackWand - Three-Band Bloom / 99 Advanced / Tunable Controls";
    ui_min = 0.0;
    ui_max = 4.0;
    ui_step = 0.001;
    ui_tooltip = "Intensity multiplier for the wide corona band.";
    ui_category_closed = true;
> = 0.22;
uniform float BWT_Bloom_WhiteGoldWarmth <
    ui_type = "slider";
    ui_label = "Warmth";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Adds a white-gold tint to bloom instead of pure source-color bloom.";
> = 0.35;
uniform float BWT_Bloom_Saturation <
    ui_type = "slider";
    ui_label = "Bloom Saturation";
    ui_category = "@BlackWand - Three-Band Bloom / 99 Advanced / Color";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Color saturation applied only to the bloom contribution.";
    ui_category_closed = true;
> = 1.05;
uniform float BWT_Bloom_ToneMapFinal <
    ui_type = "slider";
    ui_label = "Highlight Guard";
    ui_category = "@BlackWand - Three-Band Bloom / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Compresses the final bloom so bright zones do not clip too aggressively.";
> = 0.25;
static const float BWT_Bloom_VisibleFloor = 0.0; // internal fixed control; hidden from the clean menu

float4 black_wand_BWT_Bloom_ThreeBand_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float sourceLuma = black_wand_BWT_Luma(sourceColor);
    float coreMask = black_wand_BWT_SoftMask(sourceLuma, BWT_Bloom_CoreThreshold, BWT_Bloom_CoreSoftness);
    float3 coreColor = black_wand_BWT_WarmBloomColor(sourceColor * coreMask, BWT_Bloom_WhiteGoldWarmth, BWT_Bloom_Saturation) * BWT_Bloom_CoreIntensity;
    float3 photoAverage = black_wand_BWT_LocalAverage8(uv, BWT_Bloom_PhotosphereRadius);
    float photoMask = black_wand_BWT_SoftMask(black_wand_BWT_Luma(photoAverage), BWT_Bloom_CoreThreshold * 0.82, BWT_Bloom_CoreSoftness + 0.12);
    float3 photosphereColor = black_wand_BWT_WarmBloomColor(photoAverage * photoMask, BWT_Bloom_WhiteGoldWarmth, BWT_Bloom_Saturation) * BWT_Bloom_PhotosphereIntensity;
    float3 coronaAverage = black_wand_BWT_LocalAverage8(uv, BWT_Bloom_CoronaRadius);
    float spoke = black_wand_Proc_PatternRadialSpoke(uv, 13.0, sourceLuma * 0.25, 0.18);
    float coronaMask = black_wand_BWT_SoftMask(black_wand_BWT_Luma(coronaAverage), BWT_Bloom_CoreThreshold * 0.65, BWT_Bloom_CoreSoftness + 0.22) * lerp(0.7, 1.0, spoke);
    float3 coronaColor = black_wand_BWT_WarmBloomColor(coronaAverage * coronaMask, BWT_Bloom_WhiteGoldWarmth, BWT_Bloom_Saturation) * BWT_Bloom_CoronaIntensity;
    float3 bloomOnly = (coreColor + photosphereColor + coronaColor) * BWT_Bloom_MasterIntensity;
    float3 added = saturate(sourceColor + bloomOnly);
    float3 toneMapped = added / (1.0 + added * BWT_Bloom_ToneMapFinal);
    if (BWT_Bloom_DebugView == 1) return black_wand_Proc_OutColor(coreColor, BWT_Bloom_VisibleFloor);
    if (BWT_Bloom_DebugView == 2) return black_wand_Proc_OutColor(photosphereColor, BWT_Bloom_VisibleFloor);
    if (BWT_Bloom_DebugView == 3) return black_wand_Proc_OutColor(coronaColor, BWT_Bloom_VisibleFloor);
    if (BWT_Bloom_DebugView == 4) return black_wand_Proc_OutColor(bloomOnly, BWT_Bloom_VisibleFloor);
    return black_wand_Proc_OutColor(toneMapped, BWT_Bloom_VisibleFloor);
}

technique BlackWand_ThreeBandBloom <
    ui_label = "@BlackWand - Three-Band Bloom";
    ui_tooltip = "Highlight bloom split into hot core, near halo, and wider corona. Main controls are ordered from threshold to final restraint.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = black_wand_BWT_Bloom_ThreeBand_PS;
    }
}

