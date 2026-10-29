#ifndef black_wand_LENS_ADAPTER_FXH
#define black_wand_LENS_ADAPTER_FXH

// Additive Book of Life lens adapter. Wraps ../looking_glass/looking_glass.fxh without modifying base code.
#include "looking_glass.fxh"

#ifndef black_wand_LENS_OFF
#define black_wand_LENS_OFF LOOKING_GLASS_LENS_OFF
#endif
#ifndef black_wand_LENS_POINT1
#define black_wand_LENS_POINT1 LOOKING_GLASS_LENS_POINT1
#endif
#ifndef black_wand_LENS_HORIZONTALPAIR2
#define black_wand_LENS_HORIZONTALPAIR2 LOOKING_GLASS_LENS_HORIZONTALPAIR2
#endif
#ifndef black_wand_LENS_VERTICALPAIR2
#define black_wand_LENS_VERTICALPAIR2 LOOKING_GLASS_LENS_VERTICALPAIR2
#endif
#ifndef black_wand_LENS_DIAGONALPAIR2A
#define black_wand_LENS_DIAGONALPAIR2A LOOKING_GLASS_LENS_DIAGONALPAIR2A
#endif
#ifndef black_wand_LENS_DIAGONALPAIR2B
#define black_wand_LENS_DIAGONALPAIR2B LOOKING_GLASS_LENS_DIAGONALPAIR2B
#endif
#ifndef black_wand_LENS_CROSS5
#define black_wand_LENS_CROSS5 LOOKING_GLASS_LENS_CROSS5
#endif
#ifndef black_wand_LENS_X5
#define black_wand_LENS_X5 LOOKING_GLASS_LENS_X5
#endif
#ifndef black_wand_LENS_CROSSX9
#define black_wand_LENS_CROSSX9 LOOKING_GLASS_LENS_CROSSX9
#endif
#ifndef black_wand_LENS_BOX4
#define black_wand_LENS_BOX4 LOOKING_GLASS_LENS_BOX4
#endif
#ifndef black_wand_LENS_BOX9
#define black_wand_LENS_BOX9 LOOKING_GLASS_LENS_BOX9
#endif
#ifndef black_wand_LENS_BOX25
#define black_wand_LENS_BOX25 LOOKING_GLASS_LENS_BOX25
#endif
#ifndef black_wand_LENS_RECTHORIZONTAL15
#define black_wand_LENS_RECTHORIZONTAL15 LOOKING_GLASS_LENS_RECTHORIZONTAL15
#endif
#ifndef black_wand_LENS_RECTVERTICAL15
#define black_wand_LENS_RECTVERTICAL15 LOOKING_GLASS_LENS_RECTVERTICAL15
#endif
#ifndef black_wand_LENS_DIAMOND9
#define black_wand_LENS_DIAMOND9 LOOKING_GLASS_LENS_DIAMOND9
#endif
#ifndef black_wand_LENS_DIAMOND13
#define black_wand_LENS_DIAMOND13 LOOKING_GLASS_LENS_DIAMOND13
#endif
#ifndef black_wand_LENS_RING4
#define black_wand_LENS_RING4 LOOKING_GLASS_LENS_RING4
#endif
#ifndef black_wand_LENS_RING8
#define black_wand_LENS_RING8 LOOKING_GLASS_LENS_RING8
#endif
#ifndef black_wand_LENS_RING9
#define black_wand_LENS_RING9 LOOKING_GLASS_LENS_RING9
#endif
#ifndef black_wand_LENS_RING12
#define black_wand_LENS_RING12 LOOKING_GLASS_LENS_RING12
#endif
#ifndef black_wand_LENS_RADIAL13
#define black_wand_LENS_RADIAL13 LOOKING_GLASS_LENS_RADIAL13
#endif
#ifndef black_wand_LENS_SPIRAL13
#define black_wand_LENS_SPIRAL13 LOOKING_GLASS_LENS_SPIRAL13
#endif
#ifndef black_wand_LENS_GOLDEN21
#define black_wand_LENS_GOLDEN21 LOOKING_GLASS_LENS_GOLDEN21
#endif
#ifndef black_wand_LENS_BOUNDED55
#define black_wand_LENS_BOUNDED55 LOOKING_GLASS_LENS_BOUNDED55
#endif
#ifndef black_wand_LENS_FIBONACCI55
#define black_wand_LENS_FIBONACCI55 LOOKING_GLASS_LENS_FIBONACCI55
#endif
#ifndef black_wand_LENS_FIBONACCI89
#define black_wand_LENS_FIBONACCI89 LOOKING_GLASS_LENS_FIBONACCI89
#endif
#ifndef black_wand_LENS_MAX_TAPS
#define black_wand_LENS_MAX_TAPS LOOKING_GLASS_MAX_TAPS
#endif
#ifndef black_wand_LENS_REDUCTION_STAGGERED
#define black_wand_LENS_REDUCTION_STAGGERED LOOKING_GLASS_REDUCTION_STAGGERED
#endif
#ifndef black_wand_LENS_REDUCTION_SEQUENTIAL
#define black_wand_LENS_REDUCTION_SEQUENTIAL LOOKING_GLASS_REDUCTION_SEQUENTIAL
#endif
#ifndef black_wand_LENS_ACTIVE_SOURCE
#define black_wand_LENS_ACTIVE_SOURCE 0
#endif
#ifndef black_wand_LENS_ACTIVE_CONSUMER_CLAMP
#define black_wand_LENS_ACTIVE_CONSUMER_CLAMP 1
#endif

float2 black_wand_Lens_PixelSize()
{
    return LOOKING_GLASS_PixelSize();
}

bool black_wand_Lens_IsFibonacci(int lensMode)
{
    return LOOKING_GLASS_IsFibonacciLens(lensMode);
}

int black_wand_Lens_CanonicalTapCount(int lensMode)
{
    return clamp(LOOKING_GLASS_GetTapCount(lensMode), 0, black_wand_LENS_MAX_TAPS);
}

int black_wand_Lens_SourceActiveTapCount(int lensMode, int requestedTapCount)
{
    return clamp(LOOKING_GLASS_GetActiveTapCount(lensMode, requestedTapCount), 0, black_wand_LENS_MAX_TAPS);
}

int black_wand_Lens_ConsumerActiveTapCount(int lensMode, int requestedTapCount)
{
    int canonicalTapCount = black_wand_Lens_CanonicalTapCount(lensMode);
    if (canonicalTapCount <= 0) return 0;
    return clamp(requestedTapCount, 1, canonicalTapCount);
}

int black_wand_Lens_ActiveTapCount(int lensMode, int requestedTapCount, int activeTapWiring)
{
    if (activeTapWiring == black_wand_LENS_ACTIVE_CONSUMER_CLAMP)
    {
        return black_wand_Lens_ConsumerActiveTapCount(lensMode, requestedTapCount);
    }
    return black_wand_Lens_SourceActiveTapCount(lensMode, requestedTapCount);
}

int black_wand_Lens_CanonicalIndex(int lensMode, int logicalIndex, int activeTapCount, int reductionMode)
{
    return LOOKING_GLASS_GetCanonicalIndex(lensMode, logicalIndex, activeTapCount, reductionMode);
}

float2 black_wand_Lens_CanonicalOffset(int lensMode, int canonicalIndex)
{
    return LOOKING_GLASS_GetCanonicalOffset(lensMode, canonicalIndex);
}

float2 black_wand_Lens_LogicalOffset(int lensMode, int logicalIndex, int activeTapCount, int reductionMode)
{
    return LOOKING_GLASS_GetOffset(lensMode, logicalIndex, activeTapCount, reductionMode);
}

float2 black_wand_Lens_RotatedOffset(int lensMode, int logicalIndex, int activeTapCount, int reductionMode, float rotationDegrees)
{
    float2 offsetValue = black_wand_Lens_LogicalOffset(lensMode, logicalIndex, activeTapCount, reductionMode);
    return LOOKING_GLASS_Rotate(offsetValue, rotationDegrees);
}

float2 black_wand_Lens_UV(float2 uv, int lensMode, int logicalIndex, int activeTapCount, int reductionMode, float radiusPixels, float rotationDegrees)
{
    float2 offsetValue = black_wand_Lens_RotatedOffset(lensMode, logicalIndex, activeTapCount, reductionMode, rotationDegrees);
    return saturate(uv + offsetValue * black_wand_Lens_PixelSize() * max(0.0, radiusPixels));
}

float black_wand_Lens_OffsetRadius(float2 offsetValue)
{
    return saturate(length(offsetValue));
}

#endif

