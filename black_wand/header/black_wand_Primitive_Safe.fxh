#ifndef black_wand_PRIMITIVE_SAFE_FXH
#define black_wand_PRIMITIVE_SAFE_FXH

#ifndef black_wand_PRIMITIVE_EPSILON
#define black_wand_PRIMITIVE_EPSILON 0.000001
#endif

float black_wand_Primitive_SaturateScalar(float inputScalar)
{
    return saturate(inputScalar);
}

float2 black_wand_Primitive_SaturateUV(float2 inputUV)
{
    return saturate(inputUV);
}

float black_wand_Primitive_SafeDenominator(float denominatorValue)
{
    return max(abs(denominatorValue), black_wand_PRIMITIVE_EPSILON);
}

float black_wand_Primitive_SafeDivide(float numeratorValue, float denominatorValue)
{
    return numeratorValue / black_wand_Primitive_SafeDenominator(denominatorValue);
}

float3 black_wand_Primitive_SafeColor(float3 inputColor)
{
    return saturate(inputColor);
}

float black_wand_Primitive_VisibleScalar(float scalarValue, float fallbackValue)
{
    float cleanScalar = saturate(scalarValue);
    float cleanFallback = saturate(fallbackValue);
    return lerp(cleanFallback, cleanScalar, step(black_wand_PRIMITIVE_EPSILON, abs(cleanScalar)));
}

float3 black_wand_Primitive_VisibleColor(float3 inputColor, float3 fallbackColor)
{
    float colorEnergy = max(max(abs(inputColor.r), abs(inputColor.g)), abs(inputColor.b));
    return saturate(lerp(fallbackColor, inputColor, step(black_wand_PRIMITIVE_EPSILON, colorEnergy)));
}

float4 black_wand_Primitive_OutputColor(float3 inputColor)
{
    return float4(saturate(inputColor), 1.0);
}

float4 black_wand_Primitive_OutputScalar(float scalarValue)
{
    float cleanScalar = saturate(scalarValue);
    return float4(cleanScalar, cleanScalar, cleanScalar, 1.0);
}

float4 black_wand_Primitive_OutputFallback()
{
    return float4(0.125, 0.125, 0.125, 1.0);
}

#endif
