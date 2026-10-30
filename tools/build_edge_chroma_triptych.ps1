param(
    [Parameter(Mandatory = $true)][string]$EffectsOff,
    [Parameter(Mandatory = $true)][string]$EffectsOnNoDefringe,
    [Parameter(Mandatory = $true)][string]$EffectsOnDefringe,
    [Parameter(Mandatory = $true)][string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$drawingAssembly = [System.Drawing.Bitmap].Assembly.Location
$gdiAssembly = [AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GetName().Name -eq 'System.Private.Windows.GdiPlus' } |
    Select-Object -ExpandProperty Location -First 1
$windowsCoreAssembly = [AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GetName().Name -eq 'System.Private.Windows.Core' } |
    Select-Object -ExpandProperty Location -First 1
$drawingPrimitivesAssembly = [System.Drawing.Rectangle].Assembly.Location
Add-Type -ReferencedAssemblies @($drawingAssembly, $drawingPrimitivesAssembly, $gdiAssembly, $windowsCoreAssembly) -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;

public static class EdgeChromaPresentation
{
    private static int Luma(byte r, byte g, byte b)
    {
        return (77 * r + 150 * g + 29 * b) >> 8;
    }

    private static bool IsMagenta(byte r, byte g, byte b)
    {
        return Math.Min((int)r, (int)b) - (int)g > 4;
    }

    public static unsafe Bitmap EnhanceExistingMagentaEdges(Bitmap input, out int changedPixels)
    {
        Bitmap source = new Bitmap(input.Width, input.Height, PixelFormat.Format24bppRgb);
        using (Graphics g = Graphics.FromImage(source))
            g.DrawImageUnscaled(input, 0, 0);

        Bitmap output = source.Clone(new Rectangle(0, 0, source.Width, source.Height), PixelFormat.Format24bppRgb);
        Rectangle area = new Rectangle(0, 0, source.Width, source.Height);
        BitmapData src = source.LockBits(area, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
        BitmapData dst = output.LockBits(area, ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb);
        changedPixels = 0;

        try
        {
            byte* s0 = (byte*)src.Scan0;
            byte* d0 = (byte*)dst.Scan0;
            for (int y = 1; y < source.Height - 1; y++)
            {
                for (int x = 1; x < source.Width - 1; x++)
                {
                    byte* p = s0 + y * src.Stride + x * 3;
                    byte b = p[0], g = p[1], r = p[2];
                    int score = Math.Min((int)r, (int)b) - (int)g;
                    if (score <= 4)
                        continue;

                    int centerLuma = Luma(r, g, b);
                    int maxDifference = 0;
                    int magentaNeighbors = 0;
                    int[,] offsets = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } };
                    for (int n = 0; n < 8; n++)
                    {
                        byte* q = s0 + (y + offsets[n, 1]) * src.Stride + (x + offsets[n, 0]) * 3;
                        int difference = Math.Abs(centerLuma - Luma(q[2], q[1], q[0]));
                        if (difference > maxDifference) maxDifference = difference;
                        if (IsMagenta(q[2], q[1], q[0])) magentaNeighbors++;
                    }

                    // Only amplify existing, thin magenta-dominant pixels at a visible luminance edge.
                    if (maxDifference < 8 || magentaNeighbors > 6)
                        continue;

                    int boost = Math.Min(36, 6 + (score - 4) * 2);
                    byte* o = d0 + y * dst.Stride + x * 3;
                    o[2] = (byte)Math.Min(255, r + boost);
                    o[0] = (byte)Math.Min(255, b + boost);
                    changedPixels++;
                }
            }
        }
        finally
        {
            source.UnlockBits(src);
            output.UnlockBits(dst);
            source.Dispose();
        }

        return output;
    }

    public static unsafe int CountDifferentPixels(
        Bitmap first, int firstX, int firstY,
        Bitmap second, int secondX, int secondY,
        int width, int height)
    {
        Rectangle firstArea = new Rectangle(0, 0, first.Width, first.Height);
        Rectangle secondArea = new Rectangle(0, 0, second.Width, second.Height);
        BitmapData a = first.LockBits(firstArea, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
        BitmapData b = second.LockBits(secondArea, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
        int different = 0;
        try
        {
            byte* a0 = (byte*)a.Scan0;
            byte* b0 = (byte*)b.Scan0;
            for (int y = 0; y < height; y++)
            {
                byte* ap = a0 + (firstY + y) * a.Stride + firstX * 3;
                byte* bp = b0 + (secondY + y) * b.Stride + secondX * 3;
                for (int x = 0; x < width; x++, ap += 3, bp += 3)
                    if (ap[0] != bp[0] || ap[1] != bp[1] || ap[2] != bp[2]) different++;
            }
        }
        finally
        {
            first.UnlockBits(a);
            second.UnlockBits(b);
        }
        return different;
    }
}
'@ -CompilerOptions '/unsafe'

function New-ScaledFrame {
    param([string]$Path)
    $source = [System.Drawing.Image]::FromFile($Path)
    try {
        $frame = [System.Drawing.Bitmap]::new(1280, 720, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
        $graphics = [System.Drawing.Graphics]::FromImage($frame)
        try {
            $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, 0, 1280, 720))
        }
        finally { $graphics.Dispose() }
        return $frame
    }
    finally { $source.Dispose() }
}

function Write-Collage {
    param(
        [System.Drawing.Bitmap[]]$Frames,
        [string[]]$Labels,
        [string[]]$Subtitles,
        [string]$Path
    )

    $panelWidth = 1280
    $panelHeight = 720
    $headerHeight = 110
    $gutter = 8
    $width = ($panelWidth * 3) + ($gutter * 2)
    $height = $headerHeight + $panelHeight
    $canvas = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(18, 22, 28))
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
        $titleFont = [System.Drawing.Font]::new('Segoe UI', 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $subtitleFont = [System.Drawing.Font]::new('Segoe UI', 19, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
        $white = [System.Drawing.Brushes]::White
        $muted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(215, 222, 231))
        $center = [System.Drawing.StringFormat]::new()
        $center.Alignment = [System.Drawing.StringAlignment]::Center
        $center.LineAlignment = [System.Drawing.StringAlignment]::Center
        try {
            for ($i = 0; $i -lt 3; $i++) {
                $x = $i * ($panelWidth + $gutter)
                $graphics.DrawString($Labels[$i], $titleFont, $white, [System.Drawing.RectangleF]::new($x, 13, $panelWidth, 43), $center)
                if ($Subtitles[$i]) {
                    $graphics.DrawString($Subtitles[$i], $subtitleFont, $muted, [System.Drawing.RectangleF]::new($x, 58, $panelWidth, 35), $center)
                }
                $graphics.DrawImageUnscaled($Frames[$i], $x, $headerHeight)
            }
        }
        finally {
            $center.Dispose()
            $muted.Dispose()
            $titleFont.Dispose()
            $subtitleFont.Dispose()
        }
        $canvas.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $canvas.Dispose()
    }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$frames = @(
    (New-ScaledFrame $EffectsOff),
    (New-ScaledFrame $EffectsOnNoDefringe),
    (New-ScaledFrame $EffectsOnDefringe)
)

try {
    $faithfulPath = Join-Path $OutputDirectory 'edge-chroma-ward-three-way-faithful.png'
    Write-Collage $frames `
        @('EFFECTS OFF', 'EFFECTS ON - NO DEFRINGE', 'EFFECTS ON - EDGE CHROMA WARD') `
        @('SOURCE CAPTURE', 'SOURCE CAPTURE', 'SOURCE CAPTURE') `
        $faithfulPath

    $changed = 0
    $enhancedMiddle = [EdgeChromaPresentation]::EnhanceExistingMagentaEdges($frames[1], [ref]$changed)
    try {
        $presentationFrames = @($frames[0], $enhancedMiddle, $frames[2])
        $presentationPath = Join-Path $OutputDirectory 'edge-chroma-ward-three-way-magenta-aid.png'
        Write-Collage $presentationFrames `
            @('EFFECTS OFF', 'EFFECTS ON - NO DEFRINGE', 'EFFECTS ON - EDGE CHROMA WARD') `
            @('SOURCE CAPTURE', 'MAGENTA FRINGE ENHANCED FOR VISIBILITY', 'SOURCE CAPTURE') `
            $presentationPath

        $faithfulImage = [System.Drawing.Bitmap]::FromFile($faithfulPath)
        $presentationImage = [System.Drawing.Bitmap]::FromFile($presentationPath)
        try {
            $panelX = @(0, 1288, 2576)
            $faithfulMismatch = 0
            for ($i = 0; $i -lt 3; $i++) {
                $faithfulMismatch += [EdgeChromaPresentation]::CountDifferentPixels(
                    $faithfulImage, $panelX[$i], 110, $frames[$i], 0, 0, 1280, 720)
            }
            $presentationOuterMismatch =
                [EdgeChromaPresentation]::CountDifferentPixels(
                    $presentationImage, $panelX[0], 110, $frames[0], 0, 0, 1280, 720) +
                [EdgeChromaPresentation]::CountDifferentPixels(
                    $presentationImage, $panelX[2], 110, $frames[2], 0, 0, 1280, 720)
            $presentationMiddleMismatch = [EdgeChromaPresentation]::CountDifferentPixels(
                $presentationImage, $panelX[1], 110, $enhancedMiddle, 0, 0, 1280, 720)
        }
        finally {
            $faithfulImage.Dispose()
            $presentationImage.Dispose()
        }

        [pscustomobject]@{
            Faithful = $faithfulPath
            Presentation = $presentationPath
            EnhancedMiddlePixels = $changed
            FaithfulPanelMismatchPixels = $faithfulMismatch
            PresentationOuterPanelMismatchPixels = $presentationOuterMismatch
            PresentationMiddleMismatchPixels = $presentationMiddleMismatch
        }
    }
    finally { $enhancedMiddle.Dispose() }
}
finally {
    foreach ($frame in $frames) { $frame.Dispose() }
}
