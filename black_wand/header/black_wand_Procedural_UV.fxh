#ifndef black_wand_PROCEDURAL_UV_FXH
#define black_wand_PROCEDURAL_UV_FXH

float2 black_wand_Proc_UVClamp(float2 uv) { return saturate(uv); }
float2 black_wand_Proc_UVPixelSize() { return float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT); }
float2 black_wand_Proc_UVPixelOffset(float2 pixelOffset) { return pixelOffset * black_wand_Proc_UVPixelSize(); }
float2 black_wand_Proc_UVAddPixels(float2 uv, float2 pixelOffset) { return saturate(uv + black_wand_Proc_UVPixelOffset(pixelOffset)); }
float2 black_wand_Proc_UVCenter(float2 uv) { return uv - float2(0.5, 0.5); }
float2 black_wand_Proc_UVUncenter(float2 centeredUV) { return centeredUV + float2(0.5, 0.5); }
float2 black_wand_Proc_UVAspectCorrect(float2 centeredUV) { return float2(centeredUV.x * (BUFFER_WIDTH * BUFFER_RCP_HEIGHT), centeredUV.y); }
float2 black_wand_Proc_UVAspectUncorrect(float2 aspectUV) { return float2(aspectUV.x * (BUFFER_HEIGHT * BUFFER_RCP_WIDTH), aspectUV.y); }
float2 black_wand_Proc_UVRotateCentered(float2 centeredUV, float degreesValue) { float angleValue = radians(degreesValue); float s = sin(angleValue); float c = cos(angleValue); return float2(centeredUV.x * c - centeredUV.y * s, centeredUV.x * s + centeredUV.y * c); }
float2 black_wand_Proc_UVRotate(float2 uv, float degreesValue) { return black_wand_Proc_UVUncenter(black_wand_Proc_UVRotateCentered(black_wand_Proc_UVCenter(uv), degreesValue)); }
float2 black_wand_Proc_UVTile(float2 uv, float tileCount) { return frac(uv * max(1.0, tileCount)); }
float2 black_wand_Proc_UVMirror(float2 uv) { float2 f = frac(uv); return float2(1.0, 1.0) - abs(f * 2.0 - float2(1.0, 1.0)); }
float black_wand_Proc_UVDistanceFromCenter(float2 uv) { return length(black_wand_Proc_UVAspectCorrect(black_wand_Proc_UVCenter(uv))); }
float black_wand_Proc_UVAngle01(float2 uv) { float2 c = black_wand_Proc_UVCenter(uv); return frac(atan2(c.y, c.x) / 6.28318530718 + 1.0); }
float2 black_wand_Proc_UVRadialDirection(float2 uv) { float2 c = black_wand_Proc_UVCenter(uv); float d = max(length(c), 0.000001); return c / d; }
float2 black_wand_Proc_UVNormalFromAngle(float angle01) { float a = angle01 * 6.28318530718; return float2(cos(a), sin(a)); }
float2 black_wand_Proc_UVStepRight(float2 uv, float pixels) { return black_wand_Proc_UVAddPixels(uv, float2(pixels, 0.0)); }
float2 black_wand_Proc_UVStepLeft(float2 uv, float pixels) { return black_wand_Proc_UVAddPixels(uv, float2(-pixels, 0.0)); }
float2 black_wand_Proc_UVStepUp(float2 uv, float pixels) { return black_wand_Proc_UVAddPixels(uv, float2(0.0, -pixels)); }
float2 black_wand_Proc_UVStepDown(float2 uv, float pixels) { return black_wand_Proc_UVAddPixels(uv, float2(0.0, pixels)); }

#endif
