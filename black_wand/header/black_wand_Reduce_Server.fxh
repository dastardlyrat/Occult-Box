#ifndef black_wand_REDUCE_SERVER_FXH
#define black_wand_REDUCE_SERVER_FXH

#ifndef black_wand_REDUCE_AVERAGE
#define black_wand_REDUCE_AVERAGE 0
#endif
#ifndef black_wand_REDUCE_CENTER_MINUS_AVERAGE
#define black_wand_REDUCE_CENTER_MINUS_AVERAGE 1
#endif
#ifndef black_wand_REDUCE_MAX_DELTA
#define black_wand_REDUCE_MAX_DELTA 2
#endif
#ifndef black_wand_REDUCE_MIN_MAX_SPAN
#define black_wand_REDUCE_MIN_MAX_SPAN 3
#endif
#ifndef black_wand_REDUCE_VARIANCE
#define black_wand_REDUCE_VARIANCE 4
#endif

float black_wand_Reduce_Luma(float3 colorValue)
{
    return dot(colorValue, float3(0.299, 0.587, 0.114));
}

float3 black_wand_Reduce_CenterMinusAverage(float3 centerColor, float3 averageColor, float gain)
{
    return saturate(centerColor + (centerColor - averageColor) * gain);
}

float3 black_wand_Reduce_DeltaColor(float3 centerColor, float3 averageColor, float gain)
{
    return saturate(abs(centerColor - averageColor) * gain);
}

float black_wand_Reduce_LumaDelta(float3 centerColor, float3 averageColor, float gain)
{
    return saturate(abs(black_wand_Reduce_Luma(centerColor) - black_wand_Reduce_Luma(averageColor)) * gain);
}

float black_wand_Reduce_VarianceFromMoments(float lumaMean, float lumaMoment)
{
    return max(0.0, lumaMoment - lumaMean * lumaMean);
}

float3 black_wand_Reduce_ColorizeScalar(float value)
{
    return saturate(float3(value, value, value));
}

float3 black_wand_Reduce_ColorizeSigned(float value)
{
    float pos = saturate(value);
    float neg = saturate(-value);
    return saturate(float3(pos, abs(value) * 0.25, neg));
}

#endif
