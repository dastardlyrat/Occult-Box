#ifndef black_wand_PROCEDURAL_PATTERN_FXH
#define black_wand_PROCEDURAL_PATTERN_FXH

#include "black_wand_Procedural_UV.fxh"
#include "black_wand_Procedural_SafeMath.fxh"

float black_wand_Proc_PatternStripe(float2 uv, float2 directionValue, float frequencyValue, float phaseValue, float thicknessValue) { float axis = dot(uv, normalize(directionValue)); float wave = abs(frac(axis * frequencyValue + phaseValue) - 0.5) * 2.0; return 1.0 - smoothstep(thicknessValue, thicknessValue + 0.01, wave); }
float black_wand_Proc_PatternHorizontal(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return black_wand_Proc_PatternStripe(uv, float2(0.0, 1.0), frequencyValue, phaseValue, thicknessValue); }
float black_wand_Proc_PatternVertical(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return black_wand_Proc_PatternStripe(uv, float2(1.0, 0.0), frequencyValue, phaseValue, thicknessValue); }
float black_wand_Proc_PatternDiagonalA(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return black_wand_Proc_PatternStripe(uv, float2(1.0, 1.0), frequencyValue, phaseValue, thicknessValue); }
float black_wand_Proc_PatternDiagonalB(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return black_wand_Proc_PatternStripe(uv, float2(1.0, -1.0), frequencyValue, phaseValue, thicknessValue); }
float black_wand_Proc_PatternCross(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return max(black_wand_Proc_PatternHorizontal(uv, frequencyValue, phaseValue, thicknessValue), black_wand_Proc_PatternVertical(uv, frequencyValue, phaseValue, thicknessValue)); }
float black_wand_Proc_PatternX(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { return max(black_wand_Proc_PatternDiagonalA(uv, frequencyValue, phaseValue, thicknessValue), black_wand_Proc_PatternDiagonalB(uv, frequencyValue, phaseValue, thicknessValue)); }
float black_wand_Proc_PatternChecker(float2 uv, float tileCount) { float2 cell = floor(uv * max(1.0, tileCount)); return frac(cell.x + cell.y); }
float black_wand_Proc_PatternRing(float2 uv, float frequencyValue, float phaseValue, float thicknessValue) { float d = black_wand_Proc_UVDistanceFromCenter(uv); float wave = abs(frac(d * frequencyValue + phaseValue) - 0.5) * 2.0; return 1.0 - smoothstep(thicknessValue, thicknessValue + 0.01, wave); }
float black_wand_Proc_PatternRadialSpoke(float2 uv, float spokeCount, float phaseValue, float thicknessValue) { float a = black_wand_Proc_UVAngle01(uv); float wave = abs(frac(a * max(1.0, spokeCount) + phaseValue) - 0.5) * 2.0; return 1.0 - smoothstep(thicknessValue, thicknessValue + 0.01, wave); }
float black_wand_Proc_PatternVignette(float2 uv, float startValue, float endValue) { return smoothstep(endValue, startValue, black_wand_Proc_UVDistanceFromCenter(uv)); }
float black_wand_Proc_PatternBorder(float2 uv, float widthValue) { float2 edge = min(uv, float2(1.0, 1.0) - uv); return 1.0 - step(widthValue, min(edge.x, edge.y)); }

#endif
