#ifndef black_wand_PROCEDURAL_NOISE_FXH
#define black_wand_PROCEDURAL_NOISE_FXH

float black_wand_Proc_Hash11(float value) { return frac(sin(value * 127.1) * 43758.5453123); }
float black_wand_Proc_Hash21(float2 value) { return frac(sin(dot(value, float2(127.1, 311.7))) * 43758.5453123); }
float2 black_wand_Proc_Hash22(float2 value) { return frac(sin(float2(dot(value, float2(127.1, 311.7)), dot(value, float2(269.5, 183.3)))) * 43758.5453123); }
float black_wand_Proc_ValueNoise2(float2 value) { float2 i = floor(value); float2 f = frac(value); float a = black_wand_Proc_Hash21(i); float b = black_wand_Proc_Hash21(i + float2(1.0, 0.0)); float c = black_wand_Proc_Hash21(i + float2(0.0, 1.0)); float d = black_wand_Proc_Hash21(i + float2(1.0, 1.0)); float2 u = f * f * (3.0 - 2.0 * f); return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y); }
float black_wand_Proc_InterleavedGradientNoise(float2 pixelCoord) { return frac(52.9829189 * frac(0.06711056 * pixelCoord.x + 0.00583715 * pixelCoord.y)); }
float black_wand_Proc_FrameHash(float2 uv, float frameValue) { return black_wand_Proc_Hash21(uv * float2(BUFFER_WIDTH, BUFFER_HEIGHT) + float2(frameValue, frameValue)); }
float black_wand_Proc_NoiseSigned(float value) { return black_wand_Proc_Hash11(value) * 2.0 - 1.0; }
float black_wand_Proc_NoiseMask(float2 uv, float scaleValue, float thresholdValue) { return step(thresholdValue, black_wand_Proc_ValueNoise2(uv * scaleValue)); }

#endif
