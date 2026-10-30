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

// Color-only defringing with an optional, minute previous-mask guard.
// No depth or motion-vector dependency.
#include "../header/BlackWand_Common.fxh"

texture2D BWBlackWandX_EdgeChromaWard_ResultTex
{
    Width = BUFFER_WIDTH;
    Height = BUFFER_HEIGHT;
    Format = RGBA16F;
};
sampler2D BWBlackWandX_EdgeChromaWard_ResultSampler
{
    Texture = BWBlackWandX_EdgeChromaWard_ResultTex;
};

texture2D BWBlackWandX_EdgeChromaWard_HistoryTex
{
    Width = BUFFER_WIDTH;
    Height = BUFFER_HEIGHT;
    Format = RGBA16F;
};
sampler2D BWBlackWandX_EdgeChromaWard_HistorySampler
{
    Texture = BWBlackWandX_EdgeChromaWard_HistoryTex;
};

uniform int BWBlackWandX_Defringe_DebugView <
    ui_type = "combo";
    ui_label = "@BlackWand - Edge Chroma Ward";
    ui_category = "@BlackWand - Edge Chroma Ward / 99 Advanced / Debug";
    ui_items = "Final Image\0Luma Edge Mask\0Thin Fringe Mask\0Detected Color Family\0Correction Candidate\0Correction Amount\0Split: Source | Corrected\0Frame Change\0Temporal Hold\0";
    ui_tooltip = "Inspect the spatial evidence and optional temporal hold. The split view keeps the source on the left and the corrected result on the right.";
    ui_category_closed = true;
> = 0;

uniform float BWBlackWandX_Defringe_Strength <
    ui_type = "slider";
    ui_label = "Strength";
    ui_category = "@BlackWand - Edge Chroma Ward / 01 Controls";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.001;
    ui_tooltip = "Overall correction strength. The edge and thin-fringe gates remain active above 1.0.";
> = 0.80;

uniform float BWBlackWandX_Defringe_Radius <
    ui_type = "slider";
    ui_label = "Fringe Radius (px)";
    ui_category = "@BlackWand - Edge Chroma Ward / 01 Controls";
    ui_min = 0.50;
    ui_max = 3.00;
    ui_step = 0.05;
    ui_tooltip = "Expected width of the colored rim. Start near one pixel and raise only for visibly wider fringes.";
> = 1.00;

uniform float BWBlackWandX_Defringe_EdgeThreshold <
    ui_type = "slider";
    ui_label = "Luma Edge Cutoff";
    ui_category = "@BlackWand - Edge Chroma Ward / 01 Controls";
    ui_min = 0.0;
    ui_max = 0.25;
    ui_step = 0.001;
    ui_tooltip = "Minimum local brightness change required before color correction is allowed.";
> = 0.020;

uniform float BWBlackWandX_Defringe_ChromaThreshold <
    ui_type = "slider";
    ui_label = "Fringe Color Cutoff";
    ui_category = "@BlackWand - Edge Chroma Ward / 01 Controls";
    ui_min = 0.0;
    ui_max = 0.25;
    ui_step = 0.001;
    ui_tooltip = "Minimum narrow-band color excess required before correction is allowed.";
> = 0.018;

uniform float BWBlackWandX_Defringe_NaturalColorProtect <
    ui_type = "slider";
    ui_label = "Protect Persistent Color";
    ui_category = "@BlackWand - Edge Chroma Ward / 01 Controls";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.001;
    ui_tooltip = "Protects color that persists into the surrounding pixels. Raise this before lowering individual color-family strengths.";
> = 0.90;

uniform bool BWBlackWandX_Defringe_TemporalGuard <
    ui_label = "Enable Minute Temporal Guard";
    ui_category = "@BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard";
    ui_tooltip = "Briefly carries forward a small part of the previous correction mask when slight frame change hides the current spatial detection. It does not temporally blend image color.";
> = false;

uniform float BWBlackWandX_Defringe_TemporalHold <
    ui_type = "slider";
    ui_label = "Temporal Hold";
    ui_category = "@BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard";
    ui_min = 0.0;
    ui_max = 0.50;
    ui_step = 0.001;
    ui_tooltip = "Fraction of the previous removal mask allowed to survive for one more frame. The low default provides only a minute guard.";
> = 0.18;

uniform float BWBlackWandX_Defringe_TemporalReach <
    ui_type = "slider";
    ui_label = "Temporal Reach (px)";
    ui_category = "@BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.05;
    ui_tooltip = "Small cross-shaped search around the previous mask. One pixel helps the guard follow minute image movement without a broad temporal blur.";
> = 1.0;

uniform float BWBlackWandX_Defringe_TemporalChangeStart <
    ui_type = "slider";
    ui_label = "Large-Change Rejection Start";
    ui_category = "@BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard";
    ui_min = 0.0;
    ui_max = 0.25;
    ui_step = 0.001;
    ui_tooltip = "Frame difference where the carried mask begins to be rejected. Small changes retain the minute guard.";
> = 0.015;

uniform float BWBlackWandX_Defringe_TemporalChangeSoftness <
    ui_type = "slider";
    ui_label = "Large-Change Rejection Feather";
    ui_category = "@BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard";
    ui_min = 0.001;
    ui_max = 0.25;
    ui_step = 0.001;
    ui_tooltip = "Feathers history rejection as frame difference grows, preventing the mask from following major motion or scene changes.";
> = 0.085;

uniform float BWBlackWandX_Defringe_Magenta <
    ui_type = "slider";
    ui_label = "Magenta";
    ui_category = "@BlackWand - Edge Chroma Ward / 02 Color Families";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.01;
    ui_tooltip = "Sensitivity to magenta fringes, the opponent of green.";
> = 1.00;

uniform float BWBlackWandX_Defringe_Cyan <
    ui_type = "slider";
    ui_label = "Cyan";
    ui_category = "@BlackWand - Edge Chroma Ward / 02 Color Families";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.01;
    ui_tooltip = "Sensitivity to cyan fringes, the opponent of red.";
> = 1.00;

uniform float BWBlackWandX_Defringe_Green <
    ui_type = "slider";
    ui_label = "Green";
    ui_category = "@BlackWand - Edge Chroma Ward / 02 Color Families";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.01;
    ui_tooltip = "Sensitivity to green fringes, the opponent of magenta.";
> = 0.75;

uniform float BWBlackWandX_Defringe_Red <
    ui_type = "slider";
    ui_label = "Red";
    ui_category = "@BlackWand - Edge Chroma Ward / 02 Color Families";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.01;
    ui_tooltip = "Sensitivity to red fringes, the opponent of cyan.";
> = 0.75;

uniform float BWBlackWandX_Defringe_Blue <
    ui_type = "slider";
    ui_label = "Blue";
    ui_category = "@BlackWand - Edge Chroma Ward / 02 Color Families";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.01;
    ui_tooltip = "Sensitivity to blue fringes, the opponent of yellow.";
> = 0.65;

uniform float BWBlackWandX_Defringe_Yellow <
    ui_type = "slider";
    ui_label = "Yellow";
    ui_category = "@BlackWand - Edge Chroma Ward / 02 Color Families";
    ui_min = 0.0;
    ui_max = 2.0;
    ui_step = 0.01;
    ui_tooltip = "Sensitivity to yellow fringes, the opponent of blue.";
> = 0.65;

uniform float BWBlackWandX_Defringe_EdgeSoftness <
    ui_type = "slider";
    ui_label = "Edge Feather";
    ui_category = "@BlackWand - Edge Chroma Ward / 99 Advanced / Detection";
    ui_min = 0.001;
    ui_max = 0.20;
    ui_step = 0.001;
    ui_tooltip = "Feathers the luminance-edge cutoff.";
    ui_category_closed = true;
> = 0.035;

uniform float BWBlackWandX_Defringe_ChromaSoftness <
    ui_type = "slider";
    ui_label = "Fringe Feather";
    ui_category = "@BlackWand - Edge Chroma Ward / 99 Advanced / Detection";
    ui_min = 0.001;
    ui_max = 0.20;
    ui_step = 0.001;
    ui_tooltip = "Feathers the narrow color-outlier cutoff.";
    ui_category_closed = true;
> = 0.040;

float3 BWBlackWandX_Defringe_RGBExcess(float3 colorValue)
{
    return max(colorValue - (colorValue.gbr + colorValue.brg) * 0.5, 0.0.xxx);
}

float3 BWBlackWandX_Defringe_CMYExcess(float3 colorValue)
{
    return max((colorValue.gbr + colorValue.brg) * 0.5 - colorValue, 0.0.xxx);
}

float BWBlackWandX_Defringe_BandScore(float3 colorValue)
{
    float3 rgbScore = BWBlackWandX_Defringe_RGBExcess(colorValue) * float3(
        BWBlackWandX_Defringe_Red,
        BWBlackWandX_Defringe_Green,
        BWBlackWandX_Defringe_Blue);
    float3 cmyScore = BWBlackWandX_Defringe_CMYExcess(colorValue) * float3(
        BWBlackWandX_Defringe_Cyan,
        BWBlackWandX_Defringe_Magenta,
        BWBlackWandX_Defringe_Yellow);
    float rgbMaximum = max(rgbScore.x, max(rgbScore.y, rgbScore.z));
    float cmyMaximum = max(cmyScore.x, max(cmyScore.y, cmyScore.z));
    return max(rgbMaximum, cmyMaximum);
}

float3 BWBlackWandX_Defringe_BandColor(float3 colorValue)
{
    float3 rgbScore = BWBlackWandX_Defringe_RGBExcess(colorValue) * float3(
        BWBlackWandX_Defringe_Red,
        BWBlackWandX_Defringe_Green,
        BWBlackWandX_Defringe_Blue);
    float3 cmyScore = BWBlackWandX_Defringe_CMYExcess(colorValue) * float3(
        BWBlackWandX_Defringe_Cyan,
        BWBlackWandX_Defringe_Magenta,
        BWBlackWandX_Defringe_Yellow);
    float3 displayColor = 0.0.xxx;
    displayColor += rgbScore.x * float3(1.0, 0.0, 0.0);
    displayColor += rgbScore.y * float3(0.0, 1.0, 0.0);
    displayColor += rgbScore.z * float3(0.0, 0.0, 1.0);
    displayColor += cmyScore.x * float3(0.0, 1.0, 1.0);
    displayColor += cmyScore.y * float3(1.0, 0.0, 1.0);
    displayColor += cmyScore.z * float3(1.0, 1.0, 0.0);
    float totalWeight = rgbScore.x + rgbScore.y + rgbScore.z + cmyScore.x + cmyScore.y + cmyScore.z;
    return saturate(displayColor / max(totalWeight, 0.000001));
}

float3 BWBlackWandX_Defringe_ReapplyCenterLuma(float3 neighborhoodColor, float centerLuma)
{
    float neighborhoodLuma = black_wand_BWT_Luma(neighborhoodColor);
    return saturate(neighborhoodColor + (centerLuma - neighborhoodLuma).xxx);
}

float BWBlackWandX_Defringe_FrameDifference(float3 currentColor, float3 historyColor)
{
    float3 difference = abs(currentColor - historyColor);
    return max(difference.x, max(difference.y, difference.z));
}

float BWBlackWandX_Defringe_HistoryConfidence(float frameDifference)
{
    float largeChange = smoothstep(
        BWBlackWandX_Defringe_TemporalChangeStart,
        BWBlackWandX_Defringe_TemporalChangeStart + max(BWBlackWandX_Defringe_TemporalChangeSoftness, 0.000001),
        frameDifference);
    return 1.0 - largeChange;
}

float4 BWBlackWandX_Defringe_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float2 historyStep = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT) * BWBlackWandX_Defringe_TemporalReach;
    float4 historyCenter = tex2D(BWBlackWandX_EdgeChromaWard_HistorySampler, saturate(uv));
    float4 historyRight = tex2D(BWBlackWandX_EdgeChromaWard_HistorySampler, saturate(uv + float2(historyStep.x, 0.0)));
    float4 historyLeft = tex2D(BWBlackWandX_EdgeChromaWard_HistorySampler, saturate(uv - float2(historyStep.x, 0.0)));
    float4 historyDown = tex2D(BWBlackWandX_EdgeChromaWard_HistorySampler, saturate(uv + float2(0.0, historyStep.y)));
    float4 historyUp = tex2D(BWBlackWandX_EdgeChromaWard_HistorySampler, saturate(uv - float2(0.0, historyStep.y)));
    float innerRadius = max(BWBlackWandX_Defringe_Radius, 0.5);
    float outerRadius = innerRadius * 2.0;
    float3 innerAverage = black_wand_BWT_LocalAverage8(uv, innerRadius);
    float3 outerAverage = black_wand_BWT_LocalAverage8(uv, outerRadius);

    float centerLuma = black_wand_BWT_Luma(sourceColor);
    float innerLuma = black_wand_BWT_Luma(innerAverage);
    float outerLuma = black_wand_BWT_Luma(outerAverage);
    float lumaDifference = max(abs(centerLuma - innerLuma), abs(centerLuma - outerLuma));
    float edgeMask = smoothstep(
        BWBlackWandX_Defringe_EdgeThreshold,
        BWBlackWandX_Defringe_EdgeThreshold + max(BWBlackWandX_Defringe_EdgeSoftness, 0.000001),
        lumaDifference);

    float centerBand = BWBlackWandX_Defringe_BandScore(sourceColor);
    float innerBand = BWBlackWandX_Defringe_BandScore(innerAverage);
    float outerBand = BWBlackWandX_Defringe_BandScore(outerAverage);
    float persistentBand = max(innerBand, outerBand) * saturate(BWBlackWandX_Defringe_NaturalColorProtect);
    float narrowBandExcess = max(centerBand - persistentBand, 0.0);
    float thinFringeMask = smoothstep(
        BWBlackWandX_Defringe_ChromaThreshold,
        BWBlackWandX_Defringe_ChromaThreshold + max(BWBlackWandX_Defringe_ChromaSoftness, 0.000001),
        narrowBandExcess);

    float spatialCorrection = saturate(edgeMask * thinFringeMask * BWBlackWandX_Defringe_Strength);
    float frameDifferenceCenter = BWBlackWandX_Defringe_FrameDifference(sourceColor, historyCenter.rgb);
    float frameDifferenceRight = BWBlackWandX_Defringe_FrameDifference(sourceColor, historyRight.rgb);
    float frameDifferenceLeft = BWBlackWandX_Defringe_FrameDifference(sourceColor, historyLeft.rgb);
    float frameDifferenceDown = BWBlackWandX_Defringe_FrameDifference(sourceColor, historyDown.rgb);
    float frameDifferenceUp = BWBlackWandX_Defringe_FrameDifference(sourceColor, historyUp.rgb);
    float historyCandidate = historyCenter.a * BWBlackWandX_Defringe_HistoryConfidence(frameDifferenceCenter);
    historyCandidate = max(historyCandidate, historyRight.a * BWBlackWandX_Defringe_HistoryConfidence(frameDifferenceRight));
    historyCandidate = max(historyCandidate, historyLeft.a * BWBlackWandX_Defringe_HistoryConfidence(frameDifferenceLeft));
    historyCandidate = max(historyCandidate, historyDown.a * BWBlackWandX_Defringe_HistoryConfidence(frameDifferenceDown));
    historyCandidate = max(historyCandidate, historyUp.a * BWBlackWandX_Defringe_HistoryConfidence(frameDifferenceUp));
    float frameDifference = min(frameDifferenceCenter, min(frameDifferenceRight, min(frameDifferenceLeft, min(frameDifferenceDown, frameDifferenceUp))));
    float temporalHold = BWBlackWandX_Defringe_TemporalGuard
        ? historyCandidate * BWBlackWandX_Defringe_TemporalHold
        : 0.0;
    float correctionAmount = max(spatialCorrection, saturate(temporalHold));
    float3 correctionCandidate = BWBlackWandX_Defringe_ReapplyCenterLuma(innerAverage, centerLuma);
    float3 outputColor = lerp(sourceColor, correctionCandidate, correctionAmount);

    if (BWBlackWandX_Defringe_DebugView == 1)
        return float4(edgeMask.xxx, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 2)
        return float4(thinFringeMask.xxx, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 3)
        return float4(BWBlackWandX_Defringe_BandColor(sourceColor) * thinFringeMask, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 4)
        return float4(correctionCandidate, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 5)
        return float4(correctionAmount.xxx, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 6)
        return float4((uv.x < 0.5) ? sourceColor : outputColor, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 7)
        return float4(frameDifference.xxx, correctionAmount);
    if (BWBlackWandX_Defringe_DebugView == 8)
        return float4(temporalHold.xxx, correctionAmount);
    return float4(outputColor, correctionAmount);
}

float4 BWBlackWandX_Defringe_StoreHistory_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    float3 sourceColor = black_wand_Proc_SourceColor(uv);
    float correctionAmount = tex2D(BWBlackWandX_EdgeChromaWard_ResultSampler, saturate(uv)).a;
    return float4(sourceColor, correctionAmount);
}

float4 BWBlackWandX_Defringe_Present_PS(float4 pos : SV_Position, float2 uv : TEXCOORD) : SV_Target
{
    return float4(tex2D(BWBlackWandX_EdgeChromaWard_ResultSampler, saturate(uv)).rgb, 1.0);
}

technique BlackWand_EdgeChromaWard <
    ui_label = "@BlackWand - Edge Chroma Ward";
    ui_tooltip = "Color-only cleanup for thin magenta, cyan, green, red, blue, and yellow edge fringes, with an optional minute previous-mask guard for slight motion occlusion.";
>
{
    pass EdgeChromaWard_Correct
    {
        VertexShader = PostProcessVS;
        PixelShader = BWBlackWandX_Defringe_PS;
        RenderTarget = BWBlackWandX_EdgeChromaWard_ResultTex;
    }

    pass EdgeChromaWard_StoreHistory
    {
        VertexShader = PostProcessVS;
        PixelShader = BWBlackWandX_Defringe_StoreHistory_PS;
        RenderTarget = BWBlackWandX_EdgeChromaWard_HistoryTex;
    }

    pass EdgeChromaWard_Present
    {
        VertexShader = PostProcessVS;
        PixelShader = BWBlackWandX_Defringe_Present_PS;
    }
}
