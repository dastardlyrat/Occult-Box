# Occult Box API 0.1.0 — Effect Interface Reference

This generated reference records the ReShade-facing techniques and uniforms
declared by the current source tree. Labels, tooltips, defaults, and source
locations are transcribed from source; missing descriptions remain visibly
missing rather than being inferred.

Coverage: **36 effect files · 36 techniques · 932 uniforms**.

> `uses depth` and `uses back buffer` are derived from literal ReShade resource
> references anywhere in the effect's resolved local include closure. They do
> not prove correct target-game depth configuration or runtime behavior.

## Catalog

| Family | Effect source | Technique | Controls | Uses depth | Uses back buffer |
|---|---|---|---:|:---:|:---:|
| `black_wand` | [`BlackWand_01_SmartAA_EdgeClean.fx`](../../black_wand/effects/BlackWand_01_SmartAA_EdgeClean.fx) | `BlackWand_SmartAA_EdgeClean` | 10 | yes | yes |
| `black_wand` | [`BlackWand_02_DepthAO_ContactShade.fx`](../../black_wand/effects/BlackWand_02_DepthAO_ContactShade.fx) | `BlackWand_DepthAO_ContactShade` | 11 | yes | yes |
| `black_wand` | [`BlackWand_03_ThreeBandBloom.fx`](../../black_wand/effects/BlackWand_03_ThreeBandBloom.fx) | `BlackWand_ThreeBandBloom` | 12 | yes | yes |
| `black_wand` | [`BlackWand_04_HatchInkCel.fx`](../../black_wand/effects/BlackWand_04_HatchInkCel.fx) | `BlackWand_HatchInkCel` | 11 | yes | yes |
| `black_wand` | [`BlackWand_05_GI_ColorBleed.fx`](../../black_wand/effects/BlackWand_05_GI_ColorBleed.fx) | `BlackWand_GI_ColorBleed` | 10 | yes | yes |
| `black_wand` | [`BlackWand_06_GlossSSR_MaterialSheen.fx`](../../black_wand/effects/BlackWand_06_GlossSSR_MaterialSheen.fx) | `BlackWand_GlossSSR_MaterialSheen` | 11 | yes | yes |
| `black_wand` | [`BlackWand_07_ToneDetail_Richness.fx`](../../black_wand/effects/BlackWand_07_ToneDetail_Richness.fx) | `BlackWand_ToneDetail_Richness` | 11 | yes | yes |
| `black_wand` | [`BlackWand_08_RayMarch_PrimitiveLight.fx`](../../black_wand/effects/BlackWand_08_RayMarch_PrimitiveLight.fx) | `BlackWand_RayMarch_PrimitiveLight` | 18 | yes | yes |
| `black_wand` | [`BlackWand_09_MaskDepth_DebugRouter.fx`](../../black_wand/effects/BlackWand_09_MaskDepth_DebugRouter.fx) | `BlackWand_MaskDepth_DebugRouter` | 7 | yes | yes |
| `black_wand` | [`BlackWand_10_FogLight_Guard.fx`](../../black_wand/effects/BlackWand_10_FogLight_Guard.fx) | `BlackWand_FogLight_Guard` | 10 | yes | yes |
| `black_wand` | [`BlackWand_11_FarZ_Detail.fx`](../../black_wand/effects/BlackWand_11_FarZ_Detail.fx) | `BlackWand_FarZ_Detail` | 8 | yes | yes |
| `black_wand` | [`BlackWand_12_MicroDetail_Clarity.fx`](../../black_wand/effects/BlackWand_12_MicroDetail_Clarity.fx) | `BlackWand_MicroDetail_Clarity` | 7 | yes | yes |
| `black_wand` | [`BlackWand_13_SurfaceContinuity.fx`](../../black_wand/effects/BlackWand_13_SurfaceContinuity.fx) | `BlackWand_SurfaceContinuity` | 6 | yes | yes |
| `black_wand` | [`BlackWand_14_BloomBurst_Corona.fx`](../../black_wand/effects/BlackWand_14_BloomBurst_Corona.fx) | `BlackWand_BloomBurst_Corona` | 9 | yes | yes |
| `black_wand` | [`BlackWand_15_ObsidianGlass_SSR.fx`](../../black_wand/effects/BlackWand_15_ObsidianGlass_SSR.fx) | `BlackWand_ObsidianGlass_SSR` | 9 | yes | yes |
| `black_wand` | [`BlackWand_16_LogSpiral_HatchClarity.fx`](../../black_wand/effects/BlackWand_16_LogSpiral_HatchClarity.fx) | `BlackWand_LogSpiral_HatchClarity` | 8 | yes | yes |
| `black_wand` | [`BlackWand_17_GuidedDirectional_TonalShade.fx`](../../black_wand/effects/BlackWand_17_GuidedDirectional_TonalShade.fx) | `BlackWand_GuidedDirectional_TonalShade` | 9 | yes | yes |
| `black_wand` | [`BlackWand_18_MorningLight_GI.fx`](../../black_wand/effects/BlackWand_18_MorningLight_GI.fx) | `BlackWand_MorningLight_GI` | 8 | yes | yes |
| `black_wand` | [`BlackWand_19_DeepColor_Grade.fx`](../../black_wand/effects/BlackWand_19_DeepColor_Grade.fx) | `BlackWand_DeepColor_Grade` | 9 | yes | yes |
| `black_wand` | [`BlackWand_20_SpiralDenoiser.fx`](../../black_wand/effects/BlackWand_20_SpiralDenoiser.fx) | `BlackWand_SpiralDenoiser` | 8 | yes | yes |
| `black_wand` | [`BlackWand_21_EdgeChromaWard.fx`](../../black_wand/effects/BlackWand_21_EdgeChromaWard.fx) | `BlackWand_EdgeChromaWard` | 19 | yes | yes |
| `book_of_death` | [`BlueSmoke.fx`](../../book_of_death/effects/BlueSmoke.fx) | `BlueSmoke` | 53 | yes | yes |
| `book_of_death` | [`CrookedTongue.fx`](../../book_of_death/effects/CrookedTongue.fx) | `CrookedTongue` | 28 | yes | yes |
| `book_of_death` | [`CrystalMass.fx`](../../book_of_death/effects/CrystalMass.fx) | `CrystalMass` | 41 | yes | yes |
| `book_of_death` | [`DeathGaze.fx`](../../book_of_death/effects/DeathGaze.fx) | `DeathGaze` | 63 | yes | yes |
| `book_of_death` | [`FoolsGold.fx`](../../book_of_death/effects/FoolsGold.fx) | `FoolsGold` | 63 | yes | yes |
| `book_of_death` | [`GoldenHour.fx`](../../book_of_death/effects/GoldenHour.fx) | `GoldenHour` | 60 | yes | yes |
| `book_of_death` | [`ObsidianMirror.fx`](../../book_of_death/effects/ObsidianMirror.fx) | `ObsidianMirror` | 24 | no | yes |
| `book_of_death` | [`PottingClay.fx`](../../book_of_death/effects/PottingClay.fx) | `PottingClay` | 59 | yes | yes |
| `book_of_death` | [`SpiritWorld.fx`](../../book_of_death/effects/SpiritWorld.fx) | `SpiritWorld` | 62 | yes | yes |
| `depth_oracle` | [`black_wand_DepthOracle.fx`](../../depth_oracle/effects/black_wand_DepthOracle.fx) | `black_wand_DepthOracle` | 56 | yes | yes |
| `golden_weave` | [`GoldenWeave_RMGI_Primitive.fx`](../../golden_weave/effects/GoldenWeave_RMGI_Primitive.fx) | `GoldenWeave_RMGI_Primitive` | 39 | yes | yes |
| `golden_weave` | [`GoldenWeave_RMGI_Redux.fx`](../../golden_weave/effects/GoldenWeave_RMGI_Redux.fx) | `GoldenWeave_RMGI_Redux` | 39 | yes | yes |
| `legacy_lenses` | [`hexing_eye.fx`](../../legacy_lenses/effects/hexing_eye.fx) | `hexing_eye` | 49 | yes | yes |
| `legacy_lenses` | [`kaleidoscope.fx`](../../legacy_lenses/effects/kaleidoscope.fx) | `kaleidoscope` | 63 | yes | yes |
| `legacy_lenses` | [`looking_glass.fx`](../../legacy_lenses/effects/looking_glass.fx) | `looking_glass` | 22 | no | yes |

## `black_wand/effects/BlackWand_01_SmartAA_EdgeClean.fx`

### `BlackWand_SmartAA_EdgeClean`

- Source line: `142`
- UI label: @BlackWand - Smart AA - Edge Clean
- UI tooltip: Edge-aware anti-aliasing and small-radius coherence cleanup. Use this first for shimmer, jagged edges, and fine edge crawl.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_AA_DebugView` | `int` | `0` | @BlackWand - Smart AA - Edge Clean | @BlackWand - Smart AA - Edge Clean / 99 Advanced / Debug | Final Image shows the finished AA/coherence pass. Other views isolate edge detection, denoise candidate, detail restoration, or application mask. |
| `BWT_AA_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Smart AA - Edge Clean / 01 Controls | Overall mix of the AA/coherence result into the source image. |
| `BWT_AA_EdgeThreshold` | `float` | `0.055` | Edge Cutoff | @BlackWand - Smart AA - Edge Clean / 01 Controls | Minimum detected edge value before smoothing and edge cleanup are allowed. |
| `BWT_AA_EdgeSoftness` | `float` | `0.060` | Edge Feather | @BlackWand - Smart AA - Edge Clean / 99 Advanced / Tunable Controls | Softens the edge cutoff. Raise for smoother transitions; lower for sharper edge-only application. |
| `BWT_AA_EdgeGain` | `float` | `8.0` | Edge Sensitivity | @BlackWand - Smart AA - Edge Clean / 01 Controls | Amplifies the edge detector before thresholding. Raise it when edges are missed; lower it when too much texture is treated as an edge. |
| `BWT_AA_CoherenceBlend` | `float` | `0.35` | Smoothing | @BlackWand - Smart AA - Edge Clean / 01 Controls | How strongly the local coherent sample replaces noisy source pixels. |
| `BWT_AA_EdgePreserve` | `float` | `0.75` | Edge Preservation | @BlackWand - Smart AA - Edge Clean / 99 Advanced / Tunable Controls | Controls how much detected edges resist smoothing. Lower for stronger smoothing; higher for more edge protection. |
| `BWT_AA_DetailRestore` | `float` | `0.35` | Detail Return | @BlackWand - Smart AA - Edge Clean / 01 Controls | Adds back small detail after the smoothing stage so the image does not become mushy. |
| `BWT_AA_TapCount_UI` | `float` | `21.0` | Sample Budget | @BlackWand - Smart AA - Edge Clean / 99 Advanced / Sampling | Maximum number of samples used by the selected internal AA sampling lens. |
| `BWT_AA_RadiusPixels` | `float` | `1.25` | Sample Radius | @BlackWand - Smart AA - Edge Clean / 99 Advanced / Sampling | Pixel radius for the AA/coherence sampling pass. |

## `black_wand/effects/BlackWand_02_DepthAO_ContactShade.fx`

### `BlackWand_DepthAO_ContactShade`

- Source line: `149`
- UI label: @BlackWand - Depth AO - Contact Shade
- UI tooltip: Depth-buffer ambient occlusion/contact shadow pass. Tune depth first, then radius, then strength.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_AO_DebugView` | `int` | `0` | @BlackWand - Depth AO - Contact Shade | @BlackWand - Depth AO - Contact Shade / 99 Advanced / Debug | Switch between final AO, raw occlusion, depth edge, depth validity, and sample depth-delta diagnostics. |
| `BWT_AO_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Depth AO - Contact Shade / 01 Controls | Overall amount of the AO pass applied to the source image. |
| `BWT_AO_Strength` | `float` | `1.0` | Darkening Amount | @BlackWand - Depth AO - Contact Shade / 01 Controls | Controls how strongly the occlusion mask darkens nearby surfaces. |
| `BWT_AO_Power` | `float` | `1.35` | Occlusion Curve | @BlackWand - Depth AO - Contact Shade / 99 Advanced / Tunable Controls | Shapes the occlusion mask after detection. Higher values tighten contact shade; lower values broaden it. |
| `BWT_AO_MaxDarkening` | `float` | `0.55` | Dark Limit | @BlackWand - Depth AO - Contact Shade / 01 Controls | Hard cap on how much the AO pass can darken the final image. |
| `BWT_AO_DepthBias` | `float` | `0.002` | Bias | @BlackWand - Depth AO - Contact Shade / 01 Controls | Small offset used to avoid self-occlusion. Raise slightly if flat surfaces dirty themselves. |
| `BWT_AO_OcclusionGain` | `float` | `18.0` | Depth Sensitivity | @BlackWand - Depth AO - Contact Shade / 01 Controls | Amplifies sampled depth differences before they become occlusion. |
| `BWT_AO_TapCount_UI` | `float` | `13.0` | Sample Budget | @BlackWand - Depth AO - Contact Shade / 99 Advanced / Sampling | Maximum number of depth samples used by the internal AO sampling lens. |
| `BWT_AO_RadiusPixels` | `float` | `6.0` | Radius | @BlackWand - Depth AO - Contact Shade / 01 Controls | Screen-space reach of the AO probe in pixels. |
| `BWT_AO_RotationDegrees` | `float` | `0.0` | Sample Rotation | @BlackWand - Depth AO - Contact Shade / 99 Advanced / Sampling | Rotates the AO sampling pattern to reduce directional artifacts. |
| `BWT_AO_DepthEdgeGain` | `float` | `120.0` | Depth Edge Response | @BlackWand - Depth AO - Contact Shade / 99 Advanced / Depth | Strength of geometry-break detection used as an extra AO/contact term. |

## `black_wand/effects/BlackWand_03_ThreeBandBloom.fx`

### `BlackWand_ThreeBandBloom`

- Source line: `160`
- UI label: @BlackWand - Three-Band Bloom
- UI tooltip: Highlight bloom split into hot core, near halo, and wider corona. Main controls are ordered from threshold to final restraint.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_Bloom_DebugView` | `int` | `0` | @BlackWand - Three-Band Bloom | @BlackWand - Three-Band Bloom / 99 Advanced / Debug | Switch between final bloom, hot core, near halo, wide corona, and bloom-only output. |
| `BWT_Bloom_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Three-Band Bloom / 01 Controls | Overall bloom contribution. |
| `BWT_Bloom_CoreThreshold` | `float` | `0.72` | Threshold | @BlackWand - Three-Band Bloom / 01 Controls | Brightness level that begins the bloom core. |
| `BWT_Bloom_CoreSoftness` | `float` | `0.20` | Threshold Feather | @BlackWand - Three-Band Bloom / 99 Advanced / Tunable Controls | Softness around the bloom threshold. Raise for smoother bloom onset; lower for hard highlight bloom. |
| `BWT_Bloom_CoreIntensity` | `float` | `0.70` | Core Amount | @BlackWand - Three-Band Bloom / 01 Controls | Intensity of the tight bright highlight core. |
| `BWT_Bloom_PhotosphereRadius` | `float` | `8.0` | Near Halo | @BlackWand - Three-Band Bloom / 01 Controls | Radius of the smaller halo around highlights. |
| `BWT_Bloom_PhotosphereIntensity` | `float` | `0.45` | Near Halo Amount | @BlackWand - Three-Band Bloom / 99 Advanced / Tunable Controls | Intensity multiplier for the near halo band. |
| `BWT_Bloom_CoronaRadius` | `float` | `28.0` | Wide Halo | @BlackWand - Three-Band Bloom / 01 Controls | Radius of the broad outer glow. |
| `BWT_Bloom_CoronaIntensity` | `float` | `0.22` | Wide Halo Amount | @BlackWand - Three-Band Bloom / 99 Advanced / Tunable Controls | Intensity multiplier for the wide corona band. |
| `BWT_Bloom_WhiteGoldWarmth` | `float` | `0.35` | Warmth | @BlackWand - Three-Band Bloom / 01 Controls | Adds a white-gold tint to bloom instead of pure source-color bloom. |
| `BWT_Bloom_Saturation` | `float` | `1.05` | Bloom Saturation | @BlackWand - Three-Band Bloom / 99 Advanced / Color | Color saturation applied only to the bloom contribution. |
| `BWT_Bloom_ToneMapFinal` | `float` | `0.25` | Highlight Guard | @BlackWand - Three-Band Bloom / 01 Controls | Compresses the final bloom so bright zones do not clip too aggressively. |

## `black_wand/effects/BlackWand_04_HatchInkCel.fx`

### `BlackWand_HatchInkCel`

- Source line: `152`
- UI label: @BlackWand - Hatch / Ink / Cel
- UI tooltip: Stylized ink edges, cel-band toning, and hatch overlay from the BlackWand CellHatchInk family.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_Ink_DebugView` | `int` | `0` | @BlackWand - Hatch / Ink / Cel | @BlackWand - Hatch / Ink / Cel / 99 Advanced / Debug | Switch between final stylized output, ink edges, cel bands, hatch pattern, and depth edges. |
| `BWT_Ink_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Hatch / Ink / Cel / 01 Controls | Overall amount of stylization applied to the image. |
| `BWT_Ink_InkStrength` | `float` | `1.0` | Ink Edges | @BlackWand - Hatch / Ink / Cel / 01 Controls | Strength of dark outline/ink response on detected edges. |
| `BWT_Ink_StylizeStrength` | `float` | `0.65` | Cel Amount | @BlackWand - Hatch / Ink / Cel / 01 Controls | How strongly the image is pushed toward cel-shaded tonal bands. |
| `BWT_Ink_CelBands` | `float` | `5.0` | Cel Bands | @BlackWand - Hatch / Ink / Cel / 01 Controls | Approximate number of tonal steps in the cel-shading stage. |
| `BWT_Ink_BandSoftness` | `float` | `0.25` | Cel Band Feather | @BlackWand - Hatch / Ink / Cel / 99 Advanced / Tunable Controls | Softens transitions between cel shade bands. |
| `BWT_Ink_LumaEdgeGain` | `float` | `12.0` | Edge Sensitivity | @BlackWand - Hatch / Ink / Cel / 01 Controls | Amplifies luma edges before ink thresholding. |
| `BWT_Ink_EdgeThreshold` | `float` | `0.18` | Ink Edge Threshold | @BlackWand - Hatch / Ink / Cel / 99 Advanced / Edge | Depth-edge amount required before ink lines appear. |
| `BWT_Ink_EdgeSoftness` | `float` | `0.08` | Ink Edge Feather | @BlackWand - Hatch / Ink / Cel / 99 Advanced / Edge | Softens the ink-line edge threshold. |
| `BWT_Ink_HatchInfluence` | `float` | `0.45` | Hatch Amount | @BlackWand - Hatch / Ink / Cel / 01 Controls | Amount of hatch pattern added to shaded regions. |
| `BWT_Ink_HatchPhase` | `float` | `0.0` | Hatch Phase | @BlackWand - Hatch / Ink / Cel / 99 Advanced / Pattern | Offsets the hatch pattern phase without changing its source family. |

## `black_wand/effects/BlackWand_05_GI_ColorBleed.fx`

### `BlackWand_GI_ColorBleed`

- Source line: `139`
- UI label: @BlackWand - GI - Color Bleed
- UI tooltip: Screen-space color-bleed approximation using the primitive sampling lens and a depth rejection guard.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_GI_DebugView` | `int` | `0` | @BlackWand - GI - Color Bleed | @BlackWand - GI - Color Bleed / 99 Advanced / Debug | Switch between final color bleed, indirect color candidate, GI mask, depth gate, and color delta. |
| `BWT_GI_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - GI - Color Bleed / 01 Controls | Overall amount of GI color bleed applied. |
| `BWT_GI_Strength` | `float` | `0.55` | Bleed Amount | @BlackWand - GI - Color Bleed / 01 Controls | How much sampled nearby color contributes to the final image. |
| `BWT_GI_ColorBleedSaturation` | `float` | `1.15` | Bleed Saturation | @BlackWand - GI - Color Bleed / 01 Controls | Saturation of the indirect color contribution. |
| `BWT_GI_MaxContribution` | `float` | `0.35` | Contribution Limit | @BlackWand - GI - Color Bleed / 01 Controls | Caps color-bleed strength to prevent heavy smearing. |
| `BWT_GI_TapCount_UI` | `float` | `21.0` | Sample Budget | @BlackWand - GI - Color Bleed / 99 Advanced / Sampling | Maximum donor samples used by the internal GI color-bleed lens. |
| `BWT_GI_RadiusPixels` | `float` | `18.0` | Radius | @BlackWand - GI - Color Bleed / 01 Controls | Screen-space reach of the color-bleed sample. |
| `BWT_GI_RotationDegrees` | `float` | `0.0` | Sample Rotation | @BlackWand - GI - Color Bleed / 99 Advanced / Sampling | Rotates the color-bleed sampling pattern. |
| `BWT_GI_DepthRejectThreshold` | `float` | `0.025` | Depth Guard | @BlackWand - GI - Color Bleed / 01 Controls | Depth difference where color bleed begins being rejected. |
| `BWT_GI_DepthRejectSoftness` | `float` | `0.040` | Depth Reject Feather | @BlackWand - GI - Color Bleed / 99 Advanced / Depth | Softens the depth rejection around donor samples so bleed does not cut off abruptly. |

## `black_wand/effects/BlackWand_06_GlossSSR_MaterialSheen.fx`

### `BlackWand_GlossSSR_MaterialSheen`

- Source line: `156`
- UI label: @BlackWand - Gloss SSR - Material Sheen
- UI tooltip: Gloss, sheen, and short SSR-style reflection cue. Works best after depth setup is correct.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_Gloss_DebugView` | `int` | `0` | @BlackWand - Gloss SSR - Material Sheen | @BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Debug | Switch between final sheen, gloss mask, depth gradient, reflection candidate, and reflection mask. |
| `BWT_Gloss_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Gloss SSR - Material Sheen / 01 Controls | Overall amount of gloss/reflection contribution. |
| `BWT_Gloss_GlossStrength` | `float` | `0.55` | Gloss Amount | @BlackWand - Gloss SSR - Material Sheen / 01 Controls | Strength of the final glossy sheen. |
| `BWT_Gloss_BloomStrength` | `float` | `0.25` | Specular Bloom | @BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Highlight | Adds a controlled glow from the gloss/specular term. |
| `BWT_Gloss_Threshold` | `float` | `0.55` | Gloss Threshold | @BlackWand - Gloss SSR - Material Sheen / 01 Controls | Brightness level where gloss begins. |
| `BWT_Gloss_Softness` | `float` | `0.20` | Specular Feather | @BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Highlight | Softens the gloss mask threshold. |
| `BWT_Gloss_Roughness` | `float` | `0.30` | Roughness | @BlackWand - Gloss SSR - Material Sheen / 01 Controls | Higher values make reflection response broader and less mirror-like. |
| `BWT_Gloss_Saturation` | `float` | `1.05` | Reflection Saturation | @BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Color | Color saturation for the reflected/gloss contribution. |
| `BWT_Gloss_DepthGradientScale` | `float` | `850.0` | Depth Reflection Scale | @BlackWand - Gloss SSR - Material Sheen / 99 Advanced / Depth | Amplifies depth gradients used to shape the SSR-like sheen direction. |
| `BWT_Gloss_RayDistancePixels` | `float` | `32.0` | Reflection Reach | @BlackWand - Gloss SSR - Material Sheen / 01 Controls | Screen-space offset distance for the reflection candidate sample. |
| `BWT_Gloss_DepthTolerance` | `float` | `0.080` | Depth Match | @BlackWand - Gloss SSR - Material Sheen / 01 Controls | How much depth mismatch is allowed before the reflection is rejected. |

## `black_wand/effects/BlackWand_07_ToneDetail_Richness.fx`

### `BlackWand_ToneDetail_Richness`

- Source line: `152`
- UI label: @BlackWand - Tone Detail - Richness
- UI tooltip: Local tone shaping, shadow lift, highlight compression, and detail recovery. Use as a final image-richness pass.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_Tone_DebugView` | `int` | `0` | @BlackWand - Tone Detail - Richness | @BlackWand - Tone Detail - Richness / 99 Advanced / Debug | Switch between final tone pass, shaped luma, local contrast, detail delta, and shadow-lift mask. |
| `BWT_Tone_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Tone Detail - Richness / 01 Controls | Overall amount of tone/detail result mixed into the source image. |
| `BWT_Tone_RichnessStrength` | `float` | `0.75` | Richness | @BlackWand - Tone Detail - Richness / 01 Controls | Strength of local tone shaping around the selected tonal pivot. |
| `BWT_Tone_ColorfulnessStrength` | `float` | `1.10` | Colorfulness | @BlackWand - Tone Detail - Richness / 01 Controls | Final color saturation after tone shaping. |
| `BWT_Tone_TonePivot` | `float` | `0.45` | Tone Pivot | @BlackWand - Tone Detail - Richness / 99 Advanced / Tonal Shape | Midpoint used by the tonal richness curve. |
| `BWT_Tone_ToneWidth` | `float` | `0.30` | Tone Width | @BlackWand - Tone Detail - Richness / 99 Advanced / Tonal Shape | Width around the tone pivot affected by the richness curve. |
| `BWT_Tone_ShadowLift` | `float` | `0.08` | Shadow Lift | @BlackWand - Tone Detail - Richness / 01 Controls | Raises dark tones before final detail is applied. |
| `BWT_Tone_HighlightCompression` | `float` | `0.18` | Highlight Guard | @BlackWand - Tone Detail - Richness / 01 Controls | Compresses bright tones to reduce clipping and glare. |
| `BWT_Tone_LocalRadiusPixels` | `float` | `10.0` | Local Detail Radius | @BlackWand - Tone Detail - Richness / 99 Advanced / Local Detail | Pixel radius for the local average used to derive detail richness. |
| `BWT_Tone_LocalContrast` | `float` | `0.65` | Local Contrast Amount | @BlackWand - Tone Detail - Richness / 99 Advanced / Local Detail | Amount of local-contrast shaping added to the tone pass. |
| `BWT_Tone_DetailStrength` | `float` | `0.35` | Detail Return | @BlackWand - Tone Detail - Richness / 01 Controls | Amount of fine detail added back after tone shaping. |

## `black_wand/effects/BlackWand_08_RayMarch_PrimitiveLight.fx`

### `BlackWand_RayMarch_PrimitiveLight`

- Source line: `231`
- UI label: @BlackWand - Raymarch - Primitive Light
- UI tooltip: Procedural raymarched primitive overlay with material color, normals, lighting, AO, and debug heat views.
- Local include closure: `68` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_RM_DebugView` | `int` | `0` | @BlackWand - Raymarch - Primitive Light | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Debug | Switch between final overlay, hit mask, step heat, normals, material ID, travel depth, and miss code. |
| `BWT_RM_MasterIntensity` | `float` | `1.0` | Strength | @BlackWand - Raymarch - Primitive Light / 01 Controls | Overall amount of raymarched primitive overlay. |
| `BWT_RM_SourceColorInfluence` | `float` | `0.35` | Source Color Influence | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Material | How much screen color tints the raymarched primitive material. |
| `BWT_RM_OverlayStrength` | `float` | `0.85` | Overlay | @BlackWand - Raymarch - Primitive Light / 01 Controls | Opacity of the primitive overlay where the ray hits. |
| `BWT_RM_FovY` | `float` | `58.0` | Field of View | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Camera Ray | Vertical field of view used to build the internal raymarch camera. |
| `BWT_RM_CameraZ` | `float` | `-3.0` | Camera Distance | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Camera Ray | Camera Z offset for the internal primitive-field view. |
| `BWT_RM_TMax` | `float` | `7.0` | Trace Distance | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Trace | Maximum distance the primitive raymarch can travel. |
| `BWT_RM_SceneMode` | `int` | `BLACK_WAND_RM_SCENE_CSG_GALLERY` | Scene | @BlackWand - Raymarch - Primitive Light / 01 Controls | Selects the procedural primitive field being raymarched. |
| `BWT_RM_Steps_UI` | `float` | `8.0` | Step Budget | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Trace | Visible step cap for the unrolled primitive raymarch helper. |
| `BWT_RM_SceneScale` | `float` | `1.0` | Scene Scale | @BlackWand - Raymarch - Primitive Light / 01 Controls | Scales the primitive field. |
| `BWT_RM_Morph` | `float` | `0.35` | Morph | @BlackWand - Raymarch - Primitive Light / 01 Controls | Morph/control amount passed into the selected primitive scene. |
| `BWT_RM_SmoothUnion` | `float` | `0.12` | Shape Blend | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Primitive Field | Smoothness used when primitive forms blend together. |
| `BWT_RM_RepeatSpacing` | `float` | `0.90` | Repeat Spacing | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Primitive Field | Spacing of repeated primitive cells in the internal field. |
| `BWT_RM_Ambient` | `float` | `0.24` | Ambient | @BlackWand - Raymarch - Primitive Light / 01 Controls | Base light level on primitive surfaces. |
| `BWT_RM_Diffuse` | `float` | `0.95` | Diffuse | @BlackWand - Raymarch - Primitive Light / 01 Controls | Main directional light strength. |
| `BWT_RM_Rim` | `float` | `0.22` | Rim Light | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Lighting | Adds rim light around the primitive silhouette. |
| `BWT_RM_AOStrength` | `float` | `0.65` | Primitive AO | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Lighting | Ambient occlusion strength for the raymarched primitive. |
| `BWT_RM_ShadowStrength` | `float` | `0.45` | Primitive Shadow | @BlackWand - Raymarch - Primitive Light / 99 Advanced / Lighting | Shadow strength for the raymarched primitive. |

## `black_wand/effects/BlackWand_09_MaskDepth_DebugRouter.fx`

### `BlackWand_MaskDepth_DebugRouter`

- Source line: `108`
- UI label: @BlackWand - Mask / Depth Debug Router
- UI tooltip: Diagnostic router for masks, depth availability, fog/far gate, light-protect gate, and stable-surface selection.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWT_Orch_DebugView` | `int` | `0` | View Output | @BlackWand - Mask / Depth Debug Router / 99 Advanced / Debug | Select the diagnostic surface to inspect masks, depth, fog/far gate, light-protect gate, and stable surface logic. |
| `BWT_Orch_InputMaskSource` | `int` | `black_wand_MASK_ALWAYS` | Input Mask | @BlackWand - Mask / Depth Debug Router / 01 Controls | Mask used to describe where an effect is allowed to read or analyze the source image. |
| `BWT_Orch_OutputBlendMaskSource` | `int` | `black_wand_MASK_ALWAYS` | Output Mask | @BlackWand - Mask / Depth Debug Router / 01 Controls | Mask used to decide where the finished effect may be blended into the image. |
| `BWT_Orch_DepthMode` | `int` | `black_wand_PRIMITIVE_DEPTH_MODE_RAW` | Depth Orientation | @BlackWand - Mask / Depth Debug Router / 01 Controls | Use Raw or Raw Inverted depending on the game depth buffer. |
| `BWT_Orch_FogFarStart` | `float` | `0.72` | Fog Start | @BlackWand - Mask / Depth Debug Router / 01 Controls | Depth value where far/fog protection begins. |
| `BWT_Orch_LightThreshold` | `float` | `0.78` | Light Guard | @BlackWand - Mask / Depth Debug Router / 01 Controls | Brightness where light-protection begins. |
| `BWT_Orch_DebugExposure` | `float` | `1.0` | Debug Exposure | @BlackWand - Mask / Depth Debug Router / 01 Controls | Brightens diagnostics without changing final output. |

## `black_wand/effects/BlackWand_10_FogLight_Guard.fx`

### `BlackWand_FogLight_Guard`

- Source line: `101`
- UI label: @BlackWand - Fog / Light Guard
- UI tooltip: Protects fog-like haze and bright light regions from later heavy filtering, with useful diagnostics for the guard mask.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Guard_DebugView` | `int` | `0` | @BlackWand - Fog / Light Guard | @BlackWand - Fog / Light Guard / 99 Advanced / Debug | Final Image shows the guarded result. Diagnostic views show the protected fog/light region and the inputs used to build it. |
| `BWBlackWandX_Guard_Strength` | `float` | `1.0` | Strength | @BlackWand - Fog / Light Guard / 01 Controls | Overall amount of the fog/light guard applied to the source image. |
| `BWBlackWandX_Guard_ShadeOutside` | `float` | `0.18` | Outside Shade | @BlackWand - Fog / Light Guard / 99 Advanced / Tunable Controls | Amount of shading applied outside the protected fog/light area. |
| `BWBlackWandX_Guard_ProtectAmount` | `float` | `0.85` | Protection Amount | @BlackWand - Fog / Light Guard / 01 Controls | How strongly detected fog and light return to the original source color. |
| `BWBlackWandX_Guard_FogSensitivity` | `float` | `1.15` | Fog Sensitivity | @BlackWand - Fog / Light Guard / 01 Controls | Raises detection of low-contrast desaturated far-field haze. |
| `BWBlackWandX_Guard_LightThreshold` | `float` | `0.78` | Light Threshold | @BlackWand - Fog / Light Guard / 01 Controls | Brightness level where emissive or bright light protection begins. |
| `BWBlackWandX_Guard_LightSoftness` | `float` | `0.12` | Light Feather | @BlackWand - Fog / Light Guard / 99 Advanced / Tunable Controls | Softness around the bright-light protection threshold. |
| `BWBlackWandX_Guard_ContrastReject` | `float` | `0.90` | Texture Rejection | @BlackWand - Fog / Light Guard / 99 Advanced / Tunable Controls | Rejects high-contrast texture so fog detection favors smooth haze. |
| `BWBlackWandX_Guard_DepthStart` | `float` | `0.25` | Depth Window Start | @BlackWand - Fog / Light Guard / 01 Controls | Near edge of the fog/light diagnostic depth window. |
| `BWBlackWandX_Guard_DepthEnd` | `float` | `1.0` | Depth Window End | @BlackWand - Fog / Light Guard / 99 Advanced / Depth | Far edge of the fog/light diagnostic depth window. |

## `black_wand/effects/BlackWand_11_FarZ_Detail.fx`

### `BlackWand_FarZ_Detail`

- Source line: `78`
- UI label: @BlackWand - Far-Z Detail
- UI tooltip: Reinforces background/far-plane detail using depth targeting, local detail recovery, and edge support.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Far_DebugView` | `int` | `0` | @BlackWand - Far-Z Detail | @BlackWand - Far-Z Detail / 99 Advanced / Debug | Final Image shows far-plane detail. Diagnostics isolate the depth target, detail signal, edge support, and apply region. |
| `BWBlackWandX_Far_Strength` | `float` | `0.85` | Strength | @BlackWand - Far-Z Detail / 01 Controls | Overall strength of far-plane detail reinforcement. |
| `BWBlackWandX_Far_DetailStrength` | `float` | `1.10` | Fine Detail Amount | @BlackWand - Far-Z Detail / 01 Controls | Adds back high-frequency information in the far field. |
| `BWBlackWandX_Far_EdgeLight` | `float` | `0.22` | Far Edge Lift | @BlackWand - Far-Z Detail / 99 Advanced / Tunable Controls | Adds light/detail along far depth discontinuities. |
| `BWBlackWandX_Far_Radius` | `float` | `1.50` | Detail Radius (px) | @BlackWand - Far-Z Detail / 01 Controls | Radius used to separate far detail from the local average. |
| `BWBlackWandX_Far_Start` | `float` | `0.52` | Far Detail Starts | @BlackWand - Far-Z Detail / 01 Controls | Depth value where background detail starts being reinforced. |
| `BWBlackWandX_Far_Softness` | `float` | `0.12` | Far Window Feather | @BlackWand - Far-Z Detail / 99 Advanced / Depth | Softens the far-depth activation window. |
| `BWBlackWandX_Far_EdgeGain` | `float` | `10.0` | Edge Sensitivity | @BlackWand - Far-Z Detail / 01 Controls | How strongly luma edges support the far detail boost. |

## `black_wand/effects/BlackWand_12_MicroDetail_Clarity.fx`

### `BlackWand_MicroDetail_Clarity`

- Source line: `65`
- UI label: @BlackWand - Micro Detail Clarity
- UI tooltip: Fine detail clarity pass with edge protection, intended for texture readability without heavy haloing.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Micro_DebugView` | `int` | `0` | @BlackWand - Micro Detail Clarity | @BlackWand - Micro Detail Clarity / 99 Advanced / Debug | Final Image shows the clarity pass. Diagnostics isolate detail, protected edges, apply mask, and candidate output. |
| `BWBlackWandX_Micro_Strength` | `float` | `0.75` | Strength | @BlackWand - Micro Detail Clarity / 01 Controls | Overall mix of the micro-detail clarity result into the image. |
| `BWBlackWandX_Micro_DetailAmount` | `float` | `0.95` | Micro Detail Amount | @BlackWand - Micro Detail Clarity / 01 Controls | Strength of fine detail enhancement. |
| `BWBlackWandX_Micro_LocalContrast` | `float` | `0.25` | Local Contrast | @BlackWand - Micro Detail Clarity / 01 Controls | Small contrast lift applied after detail recovery. |
| `BWBlackWandX_Micro_Radius` | `float` | `1.0` | Detail Radius (px) | @BlackWand - Micro Detail Clarity / 01 Controls | Radius used to isolate micro detail from the local average. |
| `BWBlackWandX_Micro_EdgeProtect` | `float` | `0.65` | Protect Harsh Edges | @BlackWand - Micro Detail Clarity / 01 Controls | Reduces clarity on strong edges to avoid halos. |
| `BWBlackWandX_Micro_EdgeGain` | `float` | `14.0` | Micro Edge Sensitivity | @BlackWand - Micro Detail Clarity / 99 Advanced / Tunable Controls | Amplifies small local edges before clarity is applied. |

## `black_wand/effects/BlackWand_13_SurfaceContinuity.fx`

### `BlackWand_SurfaceContinuity`

- Source line: `58`
- UI label: @BlackWand - Surface Continuity
- UI tooltip: Same-surface coherence smoother for shimmer and noisy surfaces, guarded by depth and image edge rejection.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Surface_DebugView` | `int` | `0` | @BlackWand - Surface Continuity | @BlackWand - Surface Continuity / 99 Advanced / Debug | Final Image shows surface smoothing. Diagnostics show where the effect considers the surface stable enough to smooth. |
| `BWBlackWandX_Surface_Strength` | `float` | `0.45` | Strength | @BlackWand - Surface Continuity / 01 Controls | Overall amount of same-surface smoothing. |
| `BWBlackWandX_Surface_Radius` | `float` | `1.25` | Smoothing Radius (px) | @BlackWand - Surface Continuity / 01 Controls | Local radius used to build the continuity candidate. |
| `BWBlackWandX_Surface_DetailReturn` | `float` | `0.35` | Return Fine Detail | @BlackWand - Surface Continuity / 01 Controls | Adds a controlled amount of original micro detail back after smoothing. |
| `BWBlackWandX_Surface_DepthEdgeGain` | `float` | `400.0` | Depth Edge Reject | @BlackWand - Surface Continuity / 01 Controls | Rejects smoothing across depth discontinuities. |
| `BWBlackWandX_Surface_ImageEdgeGain` | `float` | `12.0` | Image Edge Reject | @BlackWand - Surface Continuity / 01 Controls | Rejects smoothing across high-contrast image edges. |

## `black_wand/effects/BlackWand_14_BloomBurst_Corona.fx`

### `BlackWand_BloomBurst_Corona`

- Source line: `88`
- UI label: @BlackWand - Bloom Burst / Corona
- UI tooltip: Highlight bloom with tight core and broad corona controls, derived from the BlackWand bloom variant family.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Burst_DebugView` | `int` | `0` | @BlackWand - Bloom Burst / Corona | @BlackWand - Bloom Burst / Corona / 99 Advanced / Debug | Final Image shows the bloom result. Diagnostics show highlight extraction, core bloom, corona spread, and apply mask. |
| `BWBlackWandX_Burst_Strength` | `float` | `0.85` | Strength | @BlackWand - Bloom Burst / Corona / 01 Controls | Overall bloom burst strength. |
| `BWBlackWandX_Burst_Threshold` | `float` | `0.72` | Highlight Threshold | @BlackWand - Bloom Burst / Corona / 01 Controls | Brightness where bloom extraction begins. |
| `BWBlackWandX_Burst_Softness` | `float` | `0.22` | Burst Feather | @BlackWand - Bloom Burst / Corona / 99 Advanced / Tunable Controls | Softens bloom burst activation. |
| `BWBlackWandX_Burst_CoreRadius` | `float` | `2.0` | Core Radius (px) | @BlackWand - Bloom Burst / Corona / 01 Controls | Small-radius bloom body around bright highlights. |
| `BWBlackWandX_Burst_CoronaRadius` | `float` | `11.0` | Corona Radius (px) | @BlackWand - Bloom Burst / Corona / 01 Controls | Wide-radius bloom halo/corona around bright highlights. |
| `BWBlackWandX_Burst_CoreStrength` | `float` | `0.72` | Burst Core Amount | @BlackWand - Bloom Burst / Corona / 99 Advanced / Tunable Controls | Intensity of the tight burst core. |
| `BWBlackWandX_Burst_CoronaStrength` | `float` | `0.46` | Burst Corona Amount | @BlackWand - Bloom Burst / Corona / 99 Advanced / Tunable Controls | Intensity of the wide burst corona. |
| `BWBlackWandX_Burst_Warmth` | `float` | `0.30` | Bloom Warmth | @BlackWand - Bloom Burst / Corona / 01 Controls | Warms the bloom contribution. |

## `black_wand/effects/BlackWand_15_ObsidianGlass_SSR.fx`

### `BlackWand_ObsidianGlass_SSR`

- Source line: `95`
- UI label: @BlackWand - Obsidian Glass SSR
- UI tooltip: Dark glass reflection pass using primitive SSR confidence, depth matching, and dark-surface targeting.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Obs_DebugView` | `int` | `0` | @BlackWand - Obsidian Glass SSR | @BlackWand - Obsidian Glass SSR / 99 Advanced / Debug | Final Image shows the glass reflection. Diagnostics show reflected color, confidence masks, glass application, and direction. |
| `BWBlackWandX_Obs_Strength` | `float` | `0.70` | Strength | @BlackWand - Obsidian Glass SSR / 01 Controls | Overall mix of the obsidian glass reflection. |
| `BWBlackWandX_Obs_GlassDarken` | `float` | `0.28` | Glass Darkening | @BlackWand - Obsidian Glass SSR / 01 Controls | Darkens the base layer before reflection, creating a black-glass response. |
| `BWBlackWandX_Obs_ReflectionSaturation` | `float` | `0.85` | Reflection Saturation | @BlackWand - Obsidian Glass SSR / 01 Controls | Saturation applied to the sampled reflection color. |
| `BWBlackWandX_Obs_DarkSurfaceStart` | `float` | `0.42` | Dark Surface Start | @BlackWand - Obsidian Glass SSR / 99 Advanced / Surface | Luma point where the obsidian/dark-surface response begins. |
| `BWBlackWandX_Obs_TraceDistance` | `float` | `18.0` | Reflection Distance (px) | @BlackWand - Obsidian Glass SSR / 01 Controls | Screen-space distance used to fetch the reflection color. |
| `BWBlackWandX_Obs_DepthGradientScale` | `float` | `1200.0` | Reflection Depth Scale | @BlackWand - Obsidian Glass SSR / 99 Advanced / Depth | Amplifies depth gradients used to steer the obsidian reflection smear. |
| `BWBlackWandX_Obs_FallbackAngle` | `float` | `-32.0` | Fallback Reflection Angle | @BlackWand - Obsidian Glass SSR / 99 Advanced / Surface | Fallback angle used when depth direction is weak. |
| `BWBlackWandX_Obs_DepthTolerance` | `float` | `0.035` | Depth Match Tolerance | @BlackWand - Obsidian Glass SSR / 01 Controls | How closely reflected depth should match current depth to keep confidence. |

## `black_wand/effects/BlackWand_16_LogSpiral_HatchClarity.fx`

### `BlackWand_LogSpiral_HatchClarity`

- Source line: `81`
- UI label: @BlackWand - Log-Spiral Hatch Clarity
- UI tooltip: Log-spiral hatch clarity and ink pass with edge/detail support for stylized texture readability.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Log_DebugView` | `int` | `0` | @BlackWand - Log-Spiral Hatch Clarity | @BlackWand - Log-Spiral Hatch Clarity / 99 Advanced / Debug | Final Image shows hatch clarity. Diagnostics isolate hatch pattern, edges, detail, and apply region. |
| `BWBlackWandX_Log_Strength` | `float` | `0.65` | Strength | @BlackWand - Log-Spiral Hatch Clarity / 01 Controls | Overall amount of log-spiral hatch clarity. |
| `BWBlackWandX_Log_InkAmount` | `float` | `0.75` | Ink Amount | @BlackWand - Log-Spiral Hatch Clarity / 01 Controls | How dark the hatch/edge ink becomes. |
| `BWBlackWandX_Log_DetailAmount` | `float` | `0.35` | Detail Return | @BlackWand - Log-Spiral Hatch Clarity / 01 Controls | Adds source detail back through the hatch field. |
| `BWBlackWandX_Log_Phase` | `float` | `0.0` | Hatch Phase | @BlackWand - Log-Spiral Hatch Clarity / 99 Advanced / Pattern | Offsets the log-spiral hatch pattern. |
| `BWBlackWandX_Log_EdgeGain` | `float` | `16.0` | Edge Sensitivity | @BlackWand - Log-Spiral Hatch Clarity / 01 Controls | Image edge sensitivity used to reinforce hatch clarity. |
| `BWBlackWandX_Log_HatchThreshold` | `float` | `0.38` | Hatch Threshold | @BlackWand - Log-Spiral Hatch Clarity / 01 Controls | Minimum hatch value before ink contributes strongly. |
| `BWBlackWandX_Log_HatchSoftness` | `float` | `0.16` | Hatch Feather | @BlackWand - Log-Spiral Hatch Clarity / 99 Advanced / Pattern | Softens log-spiral hatch activation. |

## `black_wand/effects/BlackWand_17_GuidedDirectional_TonalShade.fx`

### `BlackWand_GuidedDirectional_TonalShade`

- Source line: `89`
- UI label: @BlackWand - Guided Directional Tonal Shade
- UI tooltip: Directional tonal shading from depth and image gradients, useful for guided relief and material readability.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Dir_DebugView` | `int` | `0` | @BlackWand - Guided Directional Tonal Shade | @BlackWand - Guided Directional Tonal Shade / 99 Advanced / Debug | Final Image shows guided shading. Diagnostics show directional shade, pseudo-normal, and the gradients used to build it. |
| `BWBlackWandX_Dir_Strength` | `float` | `0.70` | Strength | @BlackWand - Guided Directional Tonal Shade / 01 Controls | Overall amount of directional tonal shading. |
| `BWBlackWandX_Dir_ShadowAmount` | `float` | `0.34` | Shadow Amount | @BlackWand - Guided Directional Tonal Shade / 01 Controls | Dark-side tonal shade strength. |
| `BWBlackWandX_Dir_LightAmount` | `float` | `0.22` | Light Amount | @BlackWand - Guided Directional Tonal Shade / 01 Controls | Light-side tonal lift strength. |
| `BWBlackWandX_Dir_LightAngle` | `float` | `-45.0` | Light Direction | @BlackWand - Guided Directional Tonal Shade / 01 Controls | Screen-space direction of the simulated tonal light. |
| `BWBlackWandX_Dir_NormalStrength` | `float` | `3.0` | Normal Strength | @BlackWand - Guided Directional Tonal Shade / 01 Controls | How strongly depth/luma gradients bend the pseudo-normal. |
| `BWBlackWandX_Dir_LumaWeight` | `float` | `0.35` | Luma Guidance Weight | @BlackWand - Guided Directional Tonal Shade / 99 Advanced / Guidance | Blend between luma guidance and depth guidance. |
| `BWBlackWandX_Dir_DepthGradientGain` | `float` | `1100.0` | Depth Guidance Gain | @BlackWand - Guided Directional Tonal Shade / 99 Advanced / Guidance | Amplifies depth gradients used by the directional tone guide. |
| `BWBlackWandX_Dir_LumaGradientGain` | `float` | `18.0` | Luma Guidance Gain | @BlackWand - Guided Directional Tonal Shade / 99 Advanced / Guidance | Amplifies brightness gradients used by the directional tone guide. |

## `black_wand/effects/BlackWand_18_MorningLight_GI.fx`

### `BlackWand_MorningLight_GI`

- Source line: `77`
- UI label: @BlackWand - Morning Light GI
- UI tooltip: Warm indirect-light pass for shadow lift and gentle color bleed using the primitive sampling lens.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Morning_DebugView` | `int` | `0` | @BlackWand - Morning Light GI | @BlackWand - Morning Light GI / 99 Advanced / Debug | Final Image shows the warm indirect-light result. Diagnostics isolate indirect sample, receiver mask, warmth field, and apply region. |
| `BWBlackWandX_Morning_Strength` | `float` | `0.60` | Strength | @BlackWand - Morning Light GI / 01 Controls | Overall warm indirect-light contribution. |
| `BWBlackWandX_Morning_Warmth` | `float` | `0.55` | Morning Warmth | @BlackWand - Morning Light GI / 01 Controls | Warm color bias applied to the indirect light. |
| `BWBlackWandX_Morning_ShadowLift` | `float` | `0.42` | Lift Shadows | @BlackWand - Morning Light GI / 01 Controls | How much warm indirect light enters darker receiver areas. |
| `BWBlackWandX_Morning_TapCount` | `float` | `21.0` | Sample Budget | @BlackWand - Morning Light GI / 99 Advanced / Sampling | Maximum donor samples used by the morning-light GI lens. |
| `BWBlackWandX_Morning_Radius` | `float` | `9.0` | Indirect Radius (px) | @BlackWand - Morning Light GI / 01 Controls | Distance used to gather neighboring indirect color. |
| `BWBlackWandX_Morning_Rotation` | `float` | `-18.0` | Sample Rotation | @BlackWand - Morning Light GI / 99 Advanced / Sampling | Rotates the warm GI sampling direction. |
| `BWBlackWandX_Morning_ShadowStart` | `float` | `0.48` | Receiver Shadow Target | @BlackWand - Morning Light GI / 01 Controls | Below this luma, pixels receive more indirect warmth. |

## `black_wand/effects/BlackWand_19_DeepColor_Grade.fx`

### `BlackWand_DeepColor_Grade`

- Source line: `81`
- UI label: @BlackWand - Deep Color Grade
- UI tooltip: Deep tone/color grade with shadow deepening, highlight protection, saturation, and warm/cool balance.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Color_DebugView` | `int` | `0` | @BlackWand - Deep Color Grade | @BlackWand - Deep Color Grade / 99 Advanced / Debug | Final Image shows the color grade. Diagnostics isolate tone candidate, shadow target, highlight protection, and apply region. |
| `BWBlackWandX_Color_Strength` | `float` | `0.80` | Strength | @BlackWand - Deep Color Grade / 01 Controls | Overall mix of the deep color grade. |
| `BWBlackWandX_Color_Contrast` | `float` | `1.14` | Contrast | @BlackWand - Deep Color Grade / 01 Controls | Midpoint contrast of the graded image. |
| `BWBlackWandX_Color_Saturation` | `float` | `1.12` | Saturation | @BlackWand - Deep Color Grade / 01 Controls | Color saturation after contrast shaping. |
| `BWBlackWandX_Color_WarmCool` | `float` | `0.12` | Warm / Cool Balance | @BlackWand - Deep Color Grade / 01 Controls | Negative cools the grade; positive warms it. |
| `BWBlackWandX_Color_ShadowDepth` | `float` | `0.22` | Deepen Shadows | @BlackWand - Deep Color Grade / 01 Controls | Adds depth to darker tones without directly crushing highlights. |
| `BWBlackWandX_Color_ShadowStart` | `float` | `0.38` | Shadow Color Start | @BlackWand - Deep Color Grade / 99 Advanced / Tonal Shape | Brightness point where shadow color treatment begins. |
| `BWBlackWandX_Color_HighlightProtect` | `float` | `0.55` | Protect Highlights | @BlackWand - Deep Color Grade / 01 Controls | Reduces grading strength in bright highlights. |
| `BWBlackWandX_Color_GrainlessFloor` | `float` | `0.006` | Grainless Floor | @BlackWand - Deep Color Grade / 99 Advanced / Tonal Shape | Minimum floor used to avoid noisy color math in very dark regions. |

## `black_wand/effects/BlackWand_20_SpiralDenoiser.fx`

### `BlackWand_SpiralDenoiser`

- Source line: `96`
- UI label: @BlackWand - Spiral Denoiser
- UI tooltip: Fixed-tap spiral denoiser with edge protection and detail return; no dynamic sample loops.
- Local include closure: `58` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Denoise_DebugView` | `int` | `0` | @BlackWand - Spiral Denoiser | @BlackWand - Spiral Denoiser / 99 Advanced / Debug | Final Image shows denoising. Diagnostics show candidate color, noise estimate, protected edges, and final blend amount. |
| `BWBlackWandX_Denoise_Strength` | `float` | `0.52` | Strength | @BlackWand - Spiral Denoiser / 01 Controls | Overall amount of denoising applied. |
| `BWBlackWandX_Denoise_DetailReturn` | `float` | `0.28` | Return Fine Detail | @BlackWand - Spiral Denoiser / 01 Controls | Adds some original detail back after denoising to avoid plastic blur. |
| `BWBlackWandX_Denoise_Radius` | `float` | `1.4` | Spiral Radius (px) | @BlackWand - Spiral Denoiser / 01 Controls | Base radius for the fixed spiral sample set. |
| `BWBlackWandX_Denoise_Rotation` | `float` | `0.0` | Denoise Rotation | @BlackWand - Spiral Denoiser / 99 Advanced / Sampling | Rotates the spiral denoise sample pattern. |
| `BWBlackWandX_Denoise_NoiseGain` | `float` | `7.0` | Noise Sensitivity | @BlackWand - Spiral Denoiser / 01 Controls | Amplifies the local difference used to decide where denoising is useful. |
| `BWBlackWandX_Denoise_EdgeGain` | `float` | `12.0` | Edge Preserve Sensitivity | @BlackWand - Spiral Denoiser / 99 Advanced / Edge | Raises edge preservation during denoise. Higher values protect more edges from smoothing. |
| `BWBlackWandX_Denoise_EdgeProtect` | `float` | `0.80` | Protect Edges | @BlackWand - Spiral Denoiser / 01 Controls | Reduces denoising across protected edges. |

## `black_wand/effects/BlackWand_21_EdgeChromaWard.fx`

### `BlackWand_EdgeChromaWard`

- Source line: `385`
- UI label: @BlackWand - Edge Chroma Ward
- UI tooltip: Color-only cleanup for thin magenta, cyan, green, red, blue, and yellow edge fringes, with an optional minute previous-mask guard for slight motion occlusion.
- Local include closure: `57` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `BWBlackWandX_Defringe_DebugView` | `int` | `0` | @BlackWand - Edge Chroma Ward | @BlackWand - Edge Chroma Ward / 99 Advanced / Debug | Inspect the spatial evidence and optional temporal hold. The split view keeps the source on the left and the corrected result on the right. |
| `BWBlackWandX_Defringe_Strength` | `float` | `0.80` | Strength | @BlackWand - Edge Chroma Ward / 01 Controls | Overall correction strength. The edge and thin-fringe gates remain active above 1.0. |
| `BWBlackWandX_Defringe_Radius` | `float` | `1.00` | Fringe Radius (px) | @BlackWand - Edge Chroma Ward / 01 Controls | Expected width of the colored rim. Start near one pixel and raise only for visibly wider fringes. |
| `BWBlackWandX_Defringe_EdgeThreshold` | `float` | `0.020` | Luma Edge Cutoff | @BlackWand - Edge Chroma Ward / 01 Controls | Minimum local brightness change required before color correction is allowed. |
| `BWBlackWandX_Defringe_ChromaThreshold` | `float` | `0.018` | Fringe Color Cutoff | @BlackWand - Edge Chroma Ward / 01 Controls | Minimum narrow-band color excess required before correction is allowed. |
| `BWBlackWandX_Defringe_NaturalColorProtect` | `float` | `0.90` | Protect Persistent Color | @BlackWand - Edge Chroma Ward / 01 Controls | Protects color that persists into the surrounding pixels. Raise this before lowering individual color-family strengths. |
| `BWBlackWandX_Defringe_TemporalGuard` | `bool` | `false` | Enable Minute Temporal Guard | @BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard | Briefly carries forward a small part of the previous correction mask when slight frame change hides the current spatial detection. It does not temporally blend image color. |
| `BWBlackWandX_Defringe_TemporalHold` | `float` | `0.18` | Temporal Hold | @BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard | Fraction of the previous removal mask allowed to survive for one more frame. The low default provides only a minute guard. |
| `BWBlackWandX_Defringe_TemporalReach` | `float` | `1.0` | Temporal Reach (px) | @BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard | Small cross-shaped search around the previous mask. One pixel helps the guard follow minute image movement without a broad temporal blur. |
| `BWBlackWandX_Defringe_TemporalChangeStart` | `float` | `0.015` | Large-Change Rejection Start | @BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard | Frame difference where the carried mask begins to be rejected. Small changes retain the minute guard. |
| `BWBlackWandX_Defringe_TemporalChangeSoftness` | `float` | `0.085` | Large-Change Rejection Feather | @BlackWand - Edge Chroma Ward / 03 Optional Temporal Guard | Feathers history rejection as frame difference grows, preventing the mask from following major motion or scene changes. |
| `BWBlackWandX_Defringe_Magenta` | `float` | `1.00` | Magenta | @BlackWand - Edge Chroma Ward / 02 Color Families | Sensitivity to magenta fringes, the opponent of green. |
| `BWBlackWandX_Defringe_Cyan` | `float` | `1.00` | Cyan | @BlackWand - Edge Chroma Ward / 02 Color Families | Sensitivity to cyan fringes, the opponent of red. |
| `BWBlackWandX_Defringe_Green` | `float` | `0.75` | Green | @BlackWand - Edge Chroma Ward / 02 Color Families | Sensitivity to green fringes, the opponent of magenta. |
| `BWBlackWandX_Defringe_Red` | `float` | `0.75` | Red | @BlackWand - Edge Chroma Ward / 02 Color Families | Sensitivity to red fringes, the opponent of cyan. |
| `BWBlackWandX_Defringe_Blue` | `float` | `0.65` | Blue | @BlackWand - Edge Chroma Ward / 02 Color Families | Sensitivity to blue fringes, the opponent of yellow. |
| `BWBlackWandX_Defringe_Yellow` | `float` | `0.65` | Yellow | @BlackWand - Edge Chroma Ward / 02 Color Families | Sensitivity to yellow fringes, the opponent of blue. |
| `BWBlackWandX_Defringe_EdgeSoftness` | `float` | `0.035` | Edge Feather | @BlackWand - Edge Chroma Ward / 99 Advanced / Detection | Feathers the luminance-edge cutoff. |
| `BWBlackWandX_Defringe_ChromaSoftness` | `float` | `0.040` | Fringe Feather | @BlackWand - Edge Chroma Ward / 99 Advanced / Detection | Feathers the narrow color-outlier cutoff. |

## `book_of_death/effects/BlueSmoke.fx`

### `BlueSmoke`

- Source line: `456`
- UI label: Blue Smoke :: Organic Local Tone Shaping
- UI tooltip: Deepens local tone relationships using organic support averaging, chroma-preserving luminance remap, and Crystal-derived guarded application.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `DEEP_DebugView` | `int` | `0` | Displayed Output | — | Chooses which deep-tone stage to inspect. Shaped Tone Field shows the signed local luminance shaping, Organic Support Luma shows the local support average, Tone Region Mask shows where the tone pivot and width permit shaping, Depth Stability Gate shows how depth continuity suppresses unstable shaping, Source Saturation shows the original chroma level, Computed Application Weight shows the final scalar shaping weight before color remap, the organic field views show the repeated support field geometry and real center footprint, Selected Mask and Fog Evidence show the Crystal-derived gates, and Final Application Gate shows the fully combined application gate. |
| `DEEP_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal diagnostics so weak tone shaping, support, and gating fields are easier to inspect. Does not change the final image. |
| `DEEP_DebugGamma` | `float` | `0.65` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `DEEP_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `DEEP_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `DEEP_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `DEEP_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `DEEP_DebugPatternScale` | `float` | `0.24` | Debug Pattern Scale | — | Scales only the repeated organic support debug field. This does not change the real support radius. |
| `DEEP_DebugPatternTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the support field debug layout across the screen for easier spacing and rotation inspection. |
| `DEEP_DebugMarkerSize` | `float` | `0.016` | Debug Marker Size | — | Controls how large support taps appear in the debug field and center footprint views. This does not change real sampling. |
| `DEEP_DebugPatternSoftness` | `float` | `0.012` | Debug Pattern Softness | — | Softens support tap markers and guide rings in debug only. |
| `DEEP_Enable` | `int` | `1` | Enable Blue Smoke Effect | — | Master enable for the deep-tone effect. Off returns the source image unchanged. |
| `DEEP_MasterIntensity` | `float` | `1.0` | Master Intensity | — | Overall multiplier applied after local tone shaping, colorfulness shaping, and final gating are combined. |
| `DEEP_RichnessStrength` | `float` | `0.65` | Deep Tone Strength | — | Strength of the local luminance remap. Positive values deepen tone relationships; negative values invert the behavior toward lifting. |
| `DEEP_ColorfulnessStrength` | `float` | `0.28` | Colorfulness Expansion | — | Optional chroma expansion applied after luminance remap. Higher values let strengthened tone structure carry more color separation. |
| `DEEP_LensMode` | `int` | `3` | Organic Support Lens Family | — | Selects the Obsidian Mirror-derived lens family used to compute local organic tone support. |
| `DEEP_QualityTier` | `int` | `2` | Organic Support Quality Tier | — | Caps the support tap budget before family-size clamping is applied. |
| `DEEP_TapBudget` | `int` | `12` | Organic Support Tap Budget | — | Requested tap count for the organic support field before quality-tier and family-size clamping are applied. This changes the real support field. |
| `DEEP_ReductionMode` | `int` | `1` | Organic Support Reduction Mode | — | Sequential uses the earliest taps first. Staggered redistributes reduced support taps across the full canonical lens shape. |
| `DEEP_FieldScale` | `float` | `1.0` | Organic Support Field Scale | — | Scales the organic support lens constellation before it is converted into pixel-space support offsets. |
| `DEEP_FieldRotation` | `float` | `0.0` | Organic Support Field Rotation | — | Rotates the organic support field used to gather local tone context. |
| `DEEP_FibonacciAnchor` | `float` | `2584.0` | Organic Support Fibonacci Anchor | — | Offsets the golden-angle phase used by Fibonacci-derived support lens families. |
| `DEEP_RadiusPixels` | `float` | `2.4` | Organic Support Radius | — | Screen-space radius used to gather organic local tone support. |
| `DEEP_OrganicFlow` | `float` | `1.25` | Organic Support Flow | — | Phase drift applied to the organic support direction generation. |
| `DEEP_TonePivot` | `float` | `0.369` | Tone Pivot | — | Luminance pivot where deep-tone shaping is strongest. |
| `DEEP_ToneWidth` | `float` | `0.314` | Tone Width | — | Width of the tonal region emphasized around the tone pivot. |
| `DEEP_LocalContrast` | `float` | `2.631` | Local Tone Contrast | — | Weight of immediate local tone contrast when shaping luminance. |
| `DEEP_ShadowLift` | `float` | `0.348` | Shadow Lift Protection | — | Reduces excessive darkening in deep shadows by protecting the darkest tones. |
| `DEEP_HighlightCompression` | `float` | `0.660` | Highlight Compression | — | Restrains over-expansion in highlights so deep tone does not become highlight lift. |
| `DEEP_DepthGate` | `float` | `0.650` | Depth Stability Gate | — | Suppresses deep-tone shaping when local depth is unstable. |
| `DEEP_MaskMode` | `int` | `6` | Selected Mask Field | — | Selects the Crystal-derived field used to gate deep-tone application. |
| `DEEP_MaskInfluence` | `float` | `0.40` | Mask Influence | — | How strongly the selected mask field influences the final deep-tone application gate. |
| `DEEP_FogInfluence` | `float` | `0.35` | Fog Evidence Influence | — | How strongly fog-like regions reduce deep-tone application. |
| `DEEP_DepthMode` | `int` | `0` | Depth Interpretation Mode | — | Controls how the depth buffer is interpreted by the Crystal-derived gating logic. |
| `DEEP_DepthInvert` | `int` | `0` | Invert Depth | — | Inverts depth interpretation for reversed depth buffers. |
| `DEEP_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Amplifies small depth differences before depth-driven masks are evaluated. |
| `DEEP_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Confidence Threshold | — | Minimum local depth activity needed before depth-driven masks trust the buffer. |
| `DEEP_DepthStart` | `float` | `0.0` | Depth Window Start | — | Near boundary of the depth window mask. |
| `DEEP_DepthEnd` | `float` | `1.0` | Depth Window End | — | Far boundary of the depth window mask. |
| `DEEP_DepthEdgeThreshold` | `float` | `0.003` | Depth Edge Threshold | — | Depth discontinuity threshold used by depth-derived gating logic. |
| `DEEP_FarDetailStart` | `float` | `0.45` | Far Detail Start | — | Near boundary where the far-detail mask begins to activate. |
| `DEEP_FarDetailEnd` | `float` | `0.75` | Far Detail End | — | Boundary where the far-detail mask reaches full strength. |
| `DEEP_DetailLow` | `float` | `0.035` | Detail Threshold Low | — | Low threshold of the detail detector used by the far-detail mask. |
| `DEEP_DetailHigh` | `float` | `0.120` | Detail Threshold High | — | High threshold of the detail detector used by the far-detail mask. |
| `DEEP_DetailScale` | `float` | `1.0` | Detail Scale | — | Scales the detail detector used by the far-detail mask. |
| `DEEP_ContrastThreshold` | `float` | `0.06` | Contrast Threshold | — | Threshold used by the contrast-derived mask field. |
| `DEEP_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Gain applied to the local-contrast detector before the contrast mask is formed. |
| `DEEP_FogBrightnessFloor` | `float` | `0.004` | Fog Brightness Floor | — | Minimum scene brightness before fog evidence begins to register. |
| `DEEP_FogDesaturation` | `float` | `0.18` | Fog Desaturation Floor | — | How colorless a region must be before fog evidence rises. |
| `DEEP_FogLowContrast` | `float` | `0.04` | Fog Low Contrast Ceiling | — | Upper contrast ceiling used by the fog evidence detector. |
| `DEEP_LightThreshold` | `float` | `0.68` | Light Threshold | — | Brightness threshold where the light-shield detector starts treating pixels as emissive or highlight-critical. |
| `DEEP_LightSoftness` | `float` | `0.18` | Light Softness | — | Soft transition width for the light-shield detector. |
| `DEEP_LineThreshold` | `float` | `0.018` | Line Threshold | — | Edge threshold used by line-like structure suppression inside the fog-evidence logic. |

## `book_of_death/effects/CrookedTongue.fx`

### `CrookedTongue`

- Source line: `255`
- UI label: Crooked Tongue :: Hatch Pattern And Shading Server
- UI tooltip: Displays and applies hatch pattern fields, shading masks, and clarity or stability modifiers using procedural bio, multistage, spiral, and cross-hatch structures.
- Local include closure: `4` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `CROOKED_DebugView` | `int` | `0` | Displayed Output | — | Chooses which hatch stage to inspect. Pattern Field shows raw hatch generation before any gating. Structural Gate Field shows the mode-specific structural allowance, such as five-stage depth staging or adaptive clarity tone shaping. Placement Mask Field shows where the shader permits hatch application on the image. Final Shading Field shows the scalar field that is actually applied to darken or enhance the image. Applied Shading Preview shows the resulting image. Clarity Delta Field is meaningful for Adaptive Hatch Clarity, and Stability Gate is meaningful for Stability Hatch. |
| `CROOKED_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal hatch diagnostics so weak patterns and masks are easier to inspect. Does not affect passthrough output. |
| `CROOKED_DebugGamma` | `float` | `1.00` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `CROOKED_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `CROOKED_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `CROOKED_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `CROOKED_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `CROOKED_Enable` | `int` | `1` | Enable Hatch Shading Effect | — | Master enable for the mined hatch modes. Off keeps the module in passthrough-only mode. |
| `CROOKED_HatchMode` | `int` | `1` | Hatch Mode | — | Selects the active mined hatch family. Stability Hatch is a non-temporal branch mined from organic hatch TAA ideas, using depth, luma, and edge rejection to stabilize where hatch is allowed to survive. Cross Hatch adds a disciplined two-angle ink weave that thickens naturally in darker regions. |
| `CROOKED_HatchStrength` | `float` | `1.0` | Hatch Strength | — | Controls how strongly the active hatch effect influences the source image. For shading modes it darkens and textures the scene; for Adaptive Hatch Clarity it scales hatch-placed clarity emphasis. |
| `CROOKED_TapBudget` | `int` | `21` | Tap Budget | — | Controls how many Lens55 taps contribute to the real hatch field, not just debug preview. Higher values increase pattern richness and directional continuity. |
| `CROOKED_PatternScale` | `float` | `860.0` | Pattern Scale | — | Controls the UV scale of the real hatch field. Larger values tighten stroke frequency; smaller values broaden it. |
| `CROOKED_Density` | `float` | `2.4` | Density | — | Controls the frequency of the mined procedural hatch lines in the actual image output. Higher values produce denser and more tightly packed stroke structure. |
| `CROOKED_Flow` | `float` | `3.0` | Flow | — | Offsets the directional phase used by the procedural hatch families in the live hatch field. Changing it alters drift and branch motion within the static pattern field. |
| `CROOKED_TapSpread` | `float` | `120.0` | Tap Spread | — | Controls how far Lens55 taps are spread through UV space when synthesizing the real procedural hatch field. Larger values increase spatial reach and loosen local repetition. |
| `CROOKED_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Offsets the Fibonacci phase used by the procedural hatch families in the live hatch field. This changes directional sequencing and branch phasing without changing tap count. |
| `CROOKED_SpiralGrowth` | `float` | `1.18` | Spiral Growth | — | Controls how quickly the log-spiral branch hatch expands as it moves away from the center. Larger values make the branch family flare outward faster. |
| `CROOKED_SpiralTightness` | `float` | `1.05` | Spiral Tightness | — | Controls how tightly the log-spiral branch field winds. Higher values produce more turns and denser spiral wrapping. |
| `CROOKED_BranchCount` | `int` | `5` | Branch Count | — | Controls how many primary arms the log-spiral branch hatch distributes around the center. More branches create denser radial subdivision. |
| `CROOKED_BranchBlend` | `float` | `0.7` | Branch Blend | — | Blends between local Lens55 direction and recursive spiral branch direction in the log-spiral hatch family. |
| `CROOKED_ClarityRadius` | `float` | `1.1` | Clarity Radius | — | Pixel radius for the compact clarity kernel used by Adaptive Hatch Clarity. Larger values broaden the local clarity neighborhood and make the effect read less like sharpening and more like structure lift. |
| `CROOKED_KernelAngle` | `float` | `28.0` | Kernel Angle | — | Orientation in degrees for the compact clarity kernel. Rotating it changes the dominant direction of the local clarity probe without rotating the hatch field itself. |
| `CROOKED_HighlightProtect` | `float` | `0.85` | Highlight Protect | — | Reduces clarity lift in bright highlights for Adaptive Hatch Clarity. Higher values protect hot pixels and reflective accents from sparkle and halos. |
| `CROOKED_MidtoneBias` | `float` | `0.65` | Midtone Bias | — | Biases Adaptive Hatch Clarity toward midtones instead of deep shadows or bright highlights. Higher values concentrate the effect on the body of the image. |
| `CROOKED_StabilityDepthRejectStart` | `float` | `0.01` | Stability Depth Reject Start | — | Smallest depth mismatch that begins suppressing Stability Hatch. Lower values make the hatch more cautious around depth breaks. |
| `CROOKED_StabilityDepthRejectEnd` | `float` | `0.05` | Stability Depth Reject End | — | Depth mismatch where Stability Hatch is fully suppressed. Raise it to tolerate broader local depth variation before the hatch is rejected. |
| `CROOKED_StabilityLumaResponse` | `float` | `8.0` | Stability Luma Response | — | How strongly local luma disagreement suppresses Stability Hatch. Higher values favor cleaner, more selective hatch persistence. |
| `CROOKED_StabilityEdgeInfluence` | `float` | `1.0` | Stability Edge Influence | — | How strongly edge activity suppresses Stability Hatch. Raise it to keep hatching off unstable or rapidly changing contours. |

## `book_of_death/effects/CrystalMass.fx`

### `CrystalMass`

- Source line: `360`
- UI label: Crystal Mass :: Image Mask And Protection Server
- UI tooltip: Displays and applies image masks for fog-like regions, highlights, depth ranges, contrast, hue, direction, silhouettes, and combined protection behavior.
- Local include closure: `3` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `CRYSTAL_DebugView` | `int` | `0` | Displayed Output | — | Chooses which mask stage to inspect. Selected Mask shows the final result of the current Selected Mask Field, Branch Direct Field shows the raw branch signal behind the current selection, Composite Guard shows the broader combined protection field, the three depth diagnostics validate the depth feed, and Masked Preview shows the selected mask applied over the image. |
| `CRYSTAL_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal mask diagnostics so weak protection fields are easier to inspect. Does not affect passthrough output. |
| `CRYSTAL_DebugGamma` | `float` | `1.00` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `CRYSTAL_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `CRYSTAL_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `CRYSTAL_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `CRYSTAL_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `CRYSTAL_CompositeDebugBranch` | `int` | `0` | Composite Debug Branch | — | When Selected Mask Field is Composite Guard, Branch Direct Field uses this control to choose which underlying component branch to show directly. |
| `CRYSTAL_Enable` | `int` | `1` | Enable Mask Output Effect | — | Master enable for the mined image-mask modes. Off keeps the module in passthrough-only mode. |
| `CRYSTAL_MaskMode` | `int` | `12` | Selected Mask Field | — | Selects the active mined mask family. The compact gates cover contrast selection, warm-hue selection, directional support, and silhouette protection, while Composite Guard folds them into the broader protection field. |
| `CRYSTAL_MaskStrength` | `float` | `1.0` | Mask Strength | — | Scales the intensity of the active mined mask in the real image, not just the debug views. Higher values make weak fields apply more strongly and also easier to inspect. |
| `CRYSTAL_FogBrightnessFloor` | `float` | `0.004` | Fog Brightness Floor | — | Minimum scene brightness before fog evidence begins to register. Raising it restricts fog detection to brighter haze and mist. |
| `CRYSTAL_FogDesaturation` | `float` | `0.18` | Fog Desaturation | — | How colorless a region must be before fog evidence increases. Higher values focus the mask on neutral fog rather than tinted atmosphere. |
| `CRYSTAL_FogLowContrast` | `float` | `0.04` | Fog Low Contrast | — | Local contrast threshold used by the fog evidence mask. Lower values make the fog gate more selective; higher values let flatter regions qualify more easily. |
| `CRYSTAL_LightThreshold` | `float` | `0.68` | Light Threshold | — | Brightness threshold where the light shield starts to treat pixels as emissive or highlight-critical. |
| `CRYSTAL_LightSoftness` | `float` | `0.18` | Light Softness | — | Soft transition width for the light shield. Larger values broaden the highlight protection ramp instead of clipping abruptly. |
| `CRYSTAL_LineThreshold` | `float` | `0.018` | Line Threshold | — | Gradient threshold where the line guard begins to register. Lower values catch more fine structure; higher values focus on stronger edges. |
| `CRYSTAL_PixelThreshold` | `float` | `0.7` | Pixel Threshold | — | Brightness threshold used by the pixel guard. Lower values catch more bright micro-pixels; higher values isolate only the hottest points. |
| `CRYSTAL_PixelSaturation` | `float` | `0.25` | Pixel Saturation | — | Saturation threshold used by the pixel guard. This helps protect very colorful hot pixels and emissive accents. |
| `CRYSTAL_DepthStart` | `float` | `0.0` | Depth Start | — | Near boundary of the generic depth window. This also helps define the near-side region protected by Foreground Guard and Far Detail Stack. |
| `CRYSTAL_DepthEnd` | `float` | `1.0` | Depth End | — | Far boundary of the generic depth window. Together with Depth Start, this also defines how far the near-side foreground protection extends. |
| `CRYSTAL_ForegroundNearStart` | `float` | `0.0` | Foreground Near Start | — | Near boundary used specifically by Foreground Guard. Lower values reserve protection for the closest geometry only; higher values let more mid-depth objects count as foreground. |
| `CRYSTAL_ForegroundNearEnd` | `float` | `0.35` | Foreground Near End | — | Far boundary used specifically by Foreground Guard. This decouples foreground protection from the generic Depth Window so both can be tuned independently. |
| `CRYSTAL_DepthInvert` | `int` | `0` | Depth Invert | — | Inverts near and far interpretation for reversed depth buffers or alternative depth conventions. |
| `CRYSTAL_DepthMode` | `int` | `0` | Depth Mode | — | Chooses how depth is interpreted before the mined depth-aware masks are evaluated. Switch this when the depth views look flat or reversed. |
| `CRYSTAL_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Amplifies small depth differences before depth availability, depth edge, and far-detail gating are evaluated. Raise it when the scene has valid depth but the detail and guard masks are too faint. |
| `CRYSTAL_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Availability Threshold | — | Minimum local depth activity needed before the depth-aware masks trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal. |
| `CRYSTAL_DepthEdgeThreshold` | `float` | `0.003` | Depth Edge Threshold | — | Depth discontinuity threshold for the foreground guard and far-detail stack. Lower values catch more silhouette edges; higher values reserve the guard for stronger breaks. |
| `CRYSTAL_FarDetailStart` | `float` | `0.45` | Far Detail Start | — | Near boundary of the far-detail region. Pixels beyond this point begin to qualify for the far-detail stack. |
| `CRYSTAL_FarDetailEnd` | `float` | `0.75` | Far Detail End | — | Full-strength boundary of the far-detail region. Raising it pushes the stack deeper into the scene; lowering it brings detail gating closer. |
| `CRYSTAL_DetailLow` | `float` | `0.035` | Detail Low | — | Lower threshold for the lens-contrast detail test used by the far-detail stack. Lower values allow weaker texture variation to qualify. |
| `CRYSTAL_DetailHigh` | `float` | `0.11` | Detail High | — | Upper threshold for the lens-contrast detail test. Higher values make the far-detail stack more selective about what counts as preserved structure. |
| `CRYSTAL_DetailScale` | `float` | `2.4` | Detail Scale | — | Gain applied to the ring and spiral contrast probes before thresholding. Raise it when detail masks are structurally correct but too weak. |
| `CRYSTAL_ForegroundNearStrength` | `float` | `1.0` | Foreground Near Strength | — | How strongly near-depth pixels block the far-detail stack. Higher values more aggressively preserve foreground subjects. |
| `CRYSTAL_ForegroundEdgeStrength` | `float` | `1.0` | Foreground Edge Strength | — | How strongly depth silhouettes block the far-detail stack. Higher values carve out more of the foreground outline from distant detail gating. |
| `CRYSTAL_ContrastThreshold` | `float` | `0.02` | Contrast Threshold | — | Minimum local luminance variation required before the Contrast mask turns on. Lower values catch more texture and edges; higher values reserve the mask for stronger structural change. |
| `CRYSTAL_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Amplifies local contrast before thresholding. Raise it when the mask is conceptually correct but too faint to separate useful structure from the surrounding image. |
| `CRYSTAL_HueWarmWidth` | `float` | `0.10` | Hue Warm Width | — | Hue-wheel width of the warm gate. Lower values isolate a tighter warm band; higher values include more orange, red, and gold-adjacent hues. |
| `CRYSTAL_DirectionalAngle` | `float` | `35.0` | Directional Angle | — | Primary angle used by the directional gate. Rotate it to align the mask with the dominant scene direction you want to favor. |
| `CRYSTAL_DirectionalSoftness` | `float` | `0.25` | Directional Softness | — | Softness of the directional gate. Lower values make the selected direction narrow and strict; higher values broaden acceptance around the chosen angle. |
| `CRYSTAL_SilhouetteStrength` | `float` | `1.0` | Silhouette Strength | — | Scales how strongly depth-edge silhouettes register in the silhouette guard. Raise it to favor stronger cutout protection around subject outlines. |

## `book_of_death/effects/DeathGaze.fx`

### `DeathGaze`

- Source line: `539`
- UI label: Death Gaze :: Three Pass Ambient Occlusion
- UI tooltip: Darkens the image with three occlusion layers: contact shadows, broad grounding shadows, and superfine crevice shadows.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `AO_DebugView` | `int` | `0` | Displayed Output | — | Chooses which ambient-occlusion stage to inspect. The first three views show isolated pass outputs, Combined Occlusion shows the merged raw occlusion before darkening, the representative sampling field views show the repeated local lens structure and center-anchored footprint using the strongest active AO sampling pass, Representative Sampling Field Strength shows scalar sampling-field intensity at the current pixel, the application field views show the repeated local placement structure and center-anchored placement footprint, Application Field Strength shows scalar placement-field intensity at the current pixel, Selected Mask shows the raw selected mask result, Fog Evidence shows the atmosphere detector directly, and Final AO Gate shows the fully combined occlusion gate. |
| `AO_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal diagnostics so weak occlusion, lens, and gate fields are easier to inspect. Does not change Final Composite. |
| `AO_DebugGamma` | `float` | `0.65` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `AO_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `AO_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `AO_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `AO_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `AO_DebugPatternScale` | `float` | `0.24` | Debug Pattern Scale | — | Scales the tiled debug field views only. This does not change the real ambient occlusion radius. |
| `AO_DebugPatternTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the debug field layout across the screen. This is only for reading spacing and rotation. |
| `AO_DebugMarkerSize` | `float` | `0.016` | Debug Marker Size | — | Controls how large each tap marker appears in the debug field and footprint views. This does not change the real sample size. |
| `AO_DebugPatternSoftness` | `float` | `0.012` | Debug Pattern Softness | — | Softens debug marker edges and guide rings. This is a readability control for debug only. |
| `AO_Enable` | `int` | `1` | Enable Ambient Occlusion Effect | — | Master enable for the three-pass ambient-occlusion stack. Off returns the source image unchanged. |
| `AO_EnableBase` | `int` | `1` | Enable Base Occlusion Pass | — | Enables the small-radius base occlusion pass. This is the primary contact and cavity layer. |
| `AO_EnableBroad` | `int` | `1` | Enable Broad Occlusion Pass | — | Enables the broad-radius occlusion pass. This adds larger-form grounding and distance-weighted structure. |
| `AO_EnableSuperfine` | `int` | `1` | Enable Superfine Occlusion Pass | — | Enables the superfine micro-occlusion pass. This concentrates on tiny creases and local structure without carrying the whole shadow load. |
| `AO_MasterIntensity` | `float` | `1.0` | Master Intensity | — | Overall strength multiplier for the final AO darkening after all three passes and placement gating are combined. |
| `AO_SamplingLensMode` | `int` | `3` | Sampling Field Lens Family | — | Selects the Obsidian Mirror-derived lens family used to gather occlusion samples for all three passes. |
| `AO_ApplicationLensMode` | `int` | `8` | Application Field Lens Family | — | Selects the Obsidian Mirror-derived lens field used to shape where the final AO is allowed to land. |
| `AO_QualityTier` | `int` | `2` | Quality Tier | — | Caps pass tap budgets before each pass resolves its own active count. Higher tiers keep more of the high-quality tap field alive. |
| `AO_ReductionMode` | `int` | `1` | Reduction Mode | — | Sequential consumes the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so lower budgets stay spatially balanced. |
| `AO_FieldScale` | `float` | `1.0` | Field Scale | — | Scales the underlying Obsidian Mirror lens constellation before it is converted into pixel-space sampling offsets for the real AO field. |
| `AO_FieldRotation` | `float` | `0.0` | Field Rotation | — | Rotates the active lens field in the real AO sampling and application paths. This mostly affects directional or anisotropic families like the rectangular and diamond shapes. |
| `AO_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Offsets the golden-angle phase used by the Fibonacci-derived tap families. Changing it re-phases the sample ordering without changing tap count. |
| `AO_ApplicationTapBudget` | `int` | `21` | Application Field Tap Budget | — | Requested tap count for the application lens field before quality-tier and family-size clamping are applied. This changes the real placement field, not just debug, and does not affect sampling. |
| `AO_ApplicationRadiusPixels` | `float` | `2.6` | Application Field Radius | — | Pixel radius used to evaluate the application lens field in the real AO output. Larger values make the placement field respond to broader neighborhood structure. |
| `AO_ApplicationLensStrength` | `float` | `0.9` | Application Lens Strength | — | How strongly the application lens field modulates where the final ambient occlusion is allowed to land. |
| `AO_BaseTapBudget` | `int` | `13` | Base Tap Budget | — | Requested tap count for the base pass before quality-tier and family-size clamping are applied. |
| `AO_BaseRadiusPixels` | `float` | `1.2` | Base Radius | — | Pixel radius of the base pass. Smaller values stay close to contact edges and creases. |
| `AO_BaseStrength` | `float` | `1.0` | Base Strength | — | Strength of the base occlusion pass. Higher values deepen contact shadows and small cavities. |
| `AO_BaseRejectStart` | `float` | `0.003` | Base Reject Start | — | Beginning of the depth delta ramp that starts counting neighboring geometry as occluding for the base pass. |
| `AO_BaseRejectEnd` | `float` | `0.022` | Base Reject End | — | Depth delta where the base pass reaches full occlusion response. Lower values make the pass tighter and more crease-focused. |
| `AO_BroadTapBudget` | `int` | `34` | Broad Tap Budget | — | Requested tap count for the broad pass before quality-tier and family-size clamping are applied. |
| `AO_BroadRadiusPixels` | `float` | `6.5` | Broad Radius | — | Pixel radius of the broad pass. Larger values push the effect into larger-form grounding and wider ambient shaping. |
| `AO_BroadStrength` | `float` | `0.8` | Broad Strength | — | Strength of the broad occlusion pass. Higher values add more large-scale grounding and scene mass. |
| `AO_BroadRejectStart` | `float` | `0.004` | Broad Reject Start | — | Beginning of the broad-pass depth delta ramp. Lower values make the pass respond to subtler depth enclosure. |
| `AO_BroadRejectEnd` | `float` | `0.035` | Broad Reject End | — | Depth delta where the broad pass reaches full occlusion response. Higher values tolerate more variation before the pass saturates. |
| `AO_BroadDistanceFalloff` | `float` | `1.2` | Broad Distance Falloff | — | How quickly far taps lose influence in the broad pass. Lower values keep the pass more evenly distributed across the radius. |
| `AO_SuperfineTapBudget` | `int` | `9` | Superfine Tap Budget | — | Requested tap count for the superfine pass before quality-tier and family-size clamping are applied. |
| `AO_SuperfineRadiusPixels` | `float` | `0.55` | Superfine Radius | — | Pixel radius of the superfine pass. Smaller values concentrate on tiny creases and local micro-structure. |
| `AO_SuperfineStrength` | `float` | `0.65` | Superfine Strength | — | Strength of the superfine pass. Higher values deepen micro-cavities and fine structure without changing the broader shape. |
| `AO_SuperfineRejectStart` | `float` | `0.0015` | Superfine Reject Start | — | Beginning of the superfine depth delta ramp. Lower values make tiny depth changes register earlier. |
| `AO_SuperfineRejectEnd` | `float` | `0.012` | Superfine Reject End | — | Depth delta where the superfine pass reaches full occlusion response. Lower values keep it tighter and more surgical. |
| `AO_SuperfineContrastThreshold` | `float` | `0.018` | Superfine Contrast Threshold | — | Minimum local contrast needed before the superfine pass fully trusts a tiny occlusion signal. Raise it to avoid broad low-detail darkening. |
| `AO_SuperfineContrastGain` | `float` | `2.2` | Superfine Contrast Gain | — | Amplifies local contrast before it modulates the superfine pass. Higher values make the pass cling more strongly to sharp local detail. |
| `AO_MaskMode` | `int` | `6` | Selected Mask Field | — | Selects the Crystal Mass-derived field used to shape where ambient occlusion is allowed to land. Composite Guard combines depth, contrast, distance, and protection behavior into a broader placement guide. |
| `AO_MaskInfluence` | `float` | `0.65` | Mask Influence | — | Blends between ungated occlusion and the selected mask field. Lower values expose the raw pass structure; higher values enforce the mask more strongly. |
| `AO_MaskStrength` | `float` | `1.0` | Mask Strength | — | Scales the selected mask field before it is blended into the final AO gate. |
| `AO_DepthMode` | `int` | `0` | Depth Mode | — | Chooses how depth is interpreted before the three AO passes and the Crystal Mass-derived guards evaluate the scene. |
| `AO_DepthInvert` | `int` | `0` | Depth Invert | — | Inverts near and far interpretation for reversed depth buffers or alternative depth conventions. |
| `AO_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Amplifies small depth differences before availability, edge, and reject logic are evaluated. Raise it when valid depth exists but the occlusion passes are too faint. |
| `AO_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Availability Threshold | — | Minimum local depth activity required before depth-aware filters fully trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal. |
| `AO_DepthEdgeThreshold` | `float` | `0.003` | Depth Edge Threshold | — | Threshold used by the depth-discontinuity logic. Lower values catch more silhouette changes; higher values reserve the signal for stronger breaks. |
| `AO_DepthStart` | `float` | `0.08` | Depth Start | — | Near boundary of the generic depth window used by the depth and composite masks. |
| `AO_DepthEnd` | `float` | `1.0` | Depth End | — | Far boundary of the generic depth window used by the depth and composite masks. |
| `AO_FarDetailStart` | `float` | `0.40` | Far Detail Start | — | Beginning of the far-distance range used by the far-detail and composite masks. |
| `AO_FarDetailEnd` | `float` | `0.78` | Far Detail End | — | Point where far-distance qualification reaches full strength for the far-detail and composite masks. |
| `AO_FogBrightnessFloor` | `float` | `0.004` | Fog Brightness Floor | — | Minimum brightness before the fog evidence branch begins to react. Raise it to ignore dim haze and focus on brighter atmosphere. |
| `AO_FogDesaturation` | `float` | `0.18` | Fog Desaturation | — | How colorless a region should be before fog evidence strengthens. Higher values focus more tightly on neutral mist and haze. |
| `AO_FogLowContrast` | `float` | `0.04` | Fog Low Contrast | — | Local-contrast threshold used by the fog evidence branch. Lower values make fog detection more selective; higher values allow flatter structure to qualify more easily. |
| `AO_LightThreshold` | `float` | `0.68` | Light Threshold | — | Brightness threshold used by the light-protection branch. Lower values protect more highlights and emissive accents. |
| `AO_LightSoftness` | `float` | `0.18` | Light Softness | — | Transition width of the light-protection branch. Higher values broaden highlight protection instead of clipping it abruptly. |
| `AO_ContrastThreshold` | `float` | `0.02` | Contrast Threshold | — | Minimum local contrast required before the contrast branch qualifies. Lower values catch more texture; higher values reserve the field for clearer structure. |
| `AO_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Gain applied to the local contrast probe before thresholding. Raise it when structurally correct contrast fields are too faint to be useful. |

## `book_of_death/effects/FoolsGold.fx`

### `FoolsGold`

- Source line: `539`
- UI label: Fools Gold :: Three Pass Screen Space Reflection
- UI tooltip: Builds reflections in three layers: bright highlight reflections, general base reflections, and broad gloss reflections.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `SSR_DebugView` | `int` | `0` | Displayed Output | — | Chooses which reflection stage to inspect. The three pass views show isolated reflection color, Combined Reflection shows the merged raw reflection before compositing, Reflection Direction shows the current screen-space reflection direction, the representative sampling field views show the repeated local lens structure and center-anchored footprint using the strongest active reflection sampling pass, Representative Sampling Field Strength shows scalar sampling-field intensity at the current pixel, the application field views show the repeated local placement structure and center-anchored placement footprint, Application Field Strength shows scalar placement-field intensity at the current pixel, Selected Mask shows the raw selected mask result, Fog Evidence exposes the atmosphere detector directly, and Final Reflection Gate shows the fully combined placement gate. |
| `SSR_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal reflection diagnostics so subtle reflected color, gates, and direction fields are easier to inspect. Does not change Final Composite. |
| `SSR_DebugGamma` | `float` | `0.65` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `SSR_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `SSR_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `SSR_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `SSR_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `SSR_DebugPatternScale` | `float` | `0.24` | Debug Pattern Scale | — | Scales the tiled debug field views only. This does not change the real reflection radius. |
| `SSR_DebugPatternTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the debug field layout across the screen. This is only for reading spacing and rotation. |
| `SSR_DebugMarkerSize` | `float` | `0.016` | Debug Marker Size | — | Controls how large each tap marker appears in the debug field and footprint views. This does not change the real sample size. |
| `SSR_DebugPatternSoftness` | `float` | `0.012` | Debug Pattern Softness | — | Softens debug marker edges and guide rings. This is a readability control for debug only. |
| `SSR_Enable` | `int` | `1` | Enable Reflection Effect | — | Master enable for the three-pass screen-space reflection stack. Off returns the source image unchanged. |
| `SSR_EnableHighlight` | `int` | `1` | Enable Highlight Reflection Pass | — | Enables the highlight reflection pass. This favors bright and sharp reflected energy. |
| `SSR_EnableBase` | `int` | `1` | Enable Base Reflection Pass | — | Enables the base reflection pass. This is the main body reflection layer. |
| `SSR_EnableGloss` | `int` | `1` | Enable Gloss Reflection Pass | — | Enables the gloss reflection pass. This broadens and smooths reflected structure for a softer reflective finish. |
| `SSR_MasterIntensity` | `float` | `1.0` | Master Intensity | — | Overall strength multiplier for the final reflected-light composite after all three passes and placement gating are combined. |
| `SSR_SamplingLensMode` | `int` | `3` | Sampling Field Lens Family | — | Selects the Obsidian Mirror-derived lens family used to distribute reflection samples around the reflected direction. |
| `SSR_ApplicationLensMode` | `int` | `8` | Application Field Lens Family | — | Selects the Obsidian Mirror-derived field used to shape where the final reflection is allowed to land. |
| `SSR_QualityTier` | `int` | `2` | Quality Tier | — | Caps pass tap budgets before each pass resolves its own active count. Higher tiers keep more of the high-quality tap field alive. |
| `SSR_ReductionMode` | `int` | `1` | Reduction Mode | — | Sequential consumes the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so lower budgets stay spatially balanced. |
| `SSR_FieldScale` | `float` | `1.0` | Field Scale | — | Scales the underlying Obsidian Mirror lens constellation before it is converted into pixel-space reflection offsets for the real SSR image. |
| `SSR_FieldRotation` | `float` | `0.0` | Field Rotation | — | Rotates the active lens field in the real SSR sampling and placement paths. This mainly affects directional and anisotropic lens families such as the rectangular and diamond variants. |
| `SSR_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Offsets the golden-angle phase used by the Fibonacci-derived tap families. Changing it re-phases sample ordering without changing tap count. |
| `SSR_ApplicationTapBudget` | `int` | `21` | Application Field Tap Budget | — | Requested tap count for the application lens field before quality-tier and family-size clamping are applied. This changes the real placement field, not just debug, and does not affect reflection sampling. |
| `SSR_ApplicationRadiusPixels` | `float` | `2.6` | Application Field Radius | — | Pixel radius used to evaluate the application lens field in the real SSR output. Larger values make the placement field respond to broader neighborhood structure. |
| `SSR_ApplicationLensStrength` | `float` | `0.9` | Application Lens Strength | — | How strongly the application lens field modulates where the final reflection is allowed to land. |
| `SSR_HighlightTapBudget` | `int` | `9` | Highlight Tap Budget | — | Requested tap count for the highlight pass before quality-tier and family-size clamping are applied. |
| `SSR_HighlightRadiusPixels` | `float` | `1.1` | Highlight Radius | — | Pixel radius of the highlight reflection pass. Smaller values keep highlights tight and sharp. |
| `SSR_HighlightStrength` | `float` | `0.85` | Highlight Strength | — | Strength of the highlight reflection pass. Higher values emphasize bright reflected peaks and specular accents. |
| `SSR_HighlightBrightStart` | `float` | `0.55` | Highlight Bright Start | — | Brightness where samples begin to qualify strongly for the highlight pass. |
| `SSR_HighlightBrightEnd` | `float` | `0.95` | Highlight Bright End | — | Brightness where the highlight pass reaches full reflective emphasis. |
| `SSR_BaseTapBudget` | `int` | `21` | Base Tap Budget | — | Requested tap count for the base reflection pass before quality-tier and family-size clamping are applied. |
| `SSR_BaseRadiusPixels` | `float` | `4.0` | Base Radius | — | Pixel radius of the base reflection pass. Larger values reach farther along the reflection direction. |
| `SSR_BaseStrength` | `float` | `0.70` | Base Strength | — | Strength of the base reflection pass. This is the main body reflection layer. |
| `SSR_BaseDepthRejectStart` | `float` | `0.006` | Base Reject Start | — | Beginning of the depth mismatch ramp that starts rejecting off-surface reflected samples for the base pass. |
| `SSR_BaseDepthRejectEnd` | `float` | `0.030` | Base Reject End | — | Depth mismatch where the base pass fully rejects reflected samples. Lower values keep it more surface-tight. |
| `SSR_BaseDistanceFalloff` | `float` | `1.0` | Base Distance Falloff | — | How quickly far reflected taps lose influence in the base pass. Lower values keep the pass more evenly distributed along the reflection direction. |
| `SSR_GlossTapBudget` | `int` | `34` | Gloss Tap Budget | — | Requested tap count for the gloss pass before quality-tier and family-size clamping are applied. |
| `SSR_GlossRadiusPixels` | `float` | `9.0` | Gloss Radius | — | Pixel radius of the gloss reflection pass. Larger values broaden the reflected field into a smoother glossy response. |
| `SSR_GlossStrength` | `float` | `0.55` | Gloss Strength | — | Strength of the gloss reflection pass. Higher values make the broader reflective sheen more visible. |
| `SSR_GlossDepthRejectStart` | `float` | `0.008` | Gloss Reject Start | — | Beginning of the depth mismatch ramp for the gloss pass. Lower values make the pass adhere more tightly to the current surface. |
| `SSR_GlossDepthRejectEnd` | `float` | `0.045` | Gloss Reject End | — | Depth mismatch where the gloss pass fully rejects reflected samples. Higher values let the pass stay broader and smoother. |
| `SSR_GlossDistanceFalloff` | `float` | `0.65` | Gloss Distance Falloff | — | How quickly far reflected taps lose influence in the gloss pass. Lower values keep the glossy sheen broad and even. |
| `SSR_GlossBlend` | `float` | `0.72` | Gloss Blend | — | How strongly the gloss pass blends toward a smoother average reflection instead of preserving sharper reflected detail. |
| `SSR_MaskMode` | `int` | `6` | Selected Mask Field | — | Selects the Crystal Mass-derived field used to shape where reflections are allowed to land. Composite Guard combines depth, contrast, distance, and protection behavior into a broader placement guide. |
| `SSR_MaskInfluence` | `float` | `0.65` | Mask Influence | — | Blends between ungated reflections and the selected mask field. Lower values expose the raw pass structure; higher values enforce the placement mask more strongly. |
| `SSR_MaskStrength` | `float` | `1.0` | Mask Strength | — | Scales the selected mask field before it is blended into the final reflection gate. |
| `SSR_DepthMode` | `int` | `0` | Depth Mode | — | Chooses how depth is interpreted before the three reflection passes and the Crystal Mass-derived guards evaluate the scene. |
| `SSR_DepthInvert` | `int` | `0` | Depth Invert | — | Inverts near and far interpretation for reversed depth buffers or alternative depth conventions. |
| `SSR_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Amplifies small depth differences before availability, edge, and reject logic are evaluated. Raise it when valid depth exists but reflection acceptance is too weak. |
| `SSR_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Availability Threshold | — | Minimum local depth activity required before depth-aware filters fully trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal. |
| `SSR_DepthEdgeThreshold` | `float` | `0.003` | Depth Edge Threshold | — | Threshold used by the depth-discontinuity logic. Lower values catch more silhouette changes; higher values reserve the signal for stronger breaks. |
| `SSR_DepthStart` | `float` | `0.08` | Depth Start | — | Near boundary of the generic depth window used by the depth and composite masks. |
| `SSR_DepthEnd` | `float` | `1.0` | Depth End | — | Far boundary of the generic depth window used by the depth and composite masks. |
| `SSR_FarDetailStart` | `float` | `0.40` | Far Detail Start | — | Beginning of the far-distance range used by the far-detail and composite masks. |
| `SSR_FarDetailEnd` | `float` | `0.78` | Far Detail End | — | Point where far-distance qualification reaches full strength for the far-detail and composite masks. |
| `SSR_FogBrightnessFloor` | `float` | `0.004` | Fog Brightness Floor | — | Minimum brightness before the fog evidence branch begins to react. Raise it to ignore dim haze and focus on brighter atmosphere. |
| `SSR_FogDesaturation` | `float` | `0.18` | Fog Desaturation | — | How colorless a region should be before fog evidence strengthens. Higher values focus more tightly on neutral mist and haze. |
| `SSR_FogLowContrast` | `float` | `0.04` | Fog Low Contrast | — | Local-contrast threshold used by the fog evidence branch. Lower values make fog detection more selective; higher values allow flatter structure to qualify more easily. |
| `SSR_LightThreshold` | `float` | `0.68` | Light Threshold | — | Brightness threshold used by the light-protection branch. Lower values protect more highlights and emissive accents. |
| `SSR_LightSoftness` | `float` | `0.18` | Light Softness | — | Transition width of the light-protection branch. Higher values broaden highlight protection instead of clipping it abruptly. |
| `SSR_ContrastThreshold` | `float` | `0.02` | Contrast Threshold | — | Minimum local contrast required before the contrast branch qualifies. Lower values catch more texture; higher values reserve the field for clearer structure. |
| `SSR_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Gain applied to the local contrast probe before thresholding. Raise it when structurally correct contrast fields are too faint to be useful. |

## `book_of_death/effects/GoldenHour.fx`

### `GoldenHour`

- Source line: `514`
- UI label: Golden Hour :: Screen Space Indirect Light
- UI tooltip: Recovers nearby image color, filters it through sampling and application fields, and adds it back as indirect bounce light.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `GOLDEN_DebugView` | `int` | `0` | Displayed Output | — | Chooses which Golden Hour stage to inspect. Local Indirect shows the filtered gathered light, Bounce Contribution shows the brightened difference from the source, the tiled field views show repeated local field structure, the center footprint views show the real center-anchored tap footprint, Sampling Field Strength and Application Field Strength show scalar field intensity at the current pixel, Depth Accept Field shows how well the gather survives depth rejection, Selected Mask shows the raw selected mask result, Fog Evidence shows the atmosphere detector directly, Final Application Gate shows the fully combined indirect-light gate, and Breakup Field shows the optional structural modulation field. |
| `GOLDEN_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal diagnostics so weak gather, mask, and tap fields are easier to inspect. Does not change Final Composite. |
| `GOLDEN_DebugGamma` | `float` | `0.65` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `GOLDEN_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `GOLDEN_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `GOLDEN_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `GOLDEN_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `GOLDEN_DebugPatternScale` | `float` | `0.24` | Debug Pattern Scale | — | Scales the tiled debug field views only. This changes how large the repeated debug field appears on screen and does not change the real sampling or application radius. |
| `GOLDEN_DebugPatternTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the debug field layout across the screen. This is only for reading spacing and rotation and does not affect the real indirect-light image. |
| `GOLDEN_DebugMarkerSize` | `float` | `0.016` | Debug Marker Size | — | Controls how large each tap marker appears in the tiled field views and center footprint views. This does not change the real sample size. |
| `GOLDEN_DebugPatternSoftness` | `float` | `0.012` | Debug Pattern Softness | — | Softens debug marker edges and guide rings. This is a readability control for debug only. |
| `GOLDEN_Enable` | `int` | `1` | Enable Indirect Light Effect | — | Master enable for the Golden Hour gather GI. Off returns the source image unchanged. |
| `GOLDEN_MasterIntensity` | `float` | `1.0` | Master Intensity | — | Overall strength multiplier for the final indirect-light contribution after all gather, mask, and breakup shaping. |
| `GOLDEN_GIStrength` | `float` | `1.4` | GI Strength | — | Scales the recovered bounce contribution before it is composited over the source. Raise it when the indirect field is structurally right but too faint. |
| `GOLDEN_MaxContribution` | `float` | `1.8` | Max Contribution | — | Upper cap on how much gathered light may brighten the source. Lower values keep the effect conservative; higher values let bright bounce accumulate more strongly. |
| `GOLDEN_SamplingLensMode` | `int` | `3` | Sampling Field Lens Family | — | Selects the Obsidian Mirror-derived tap geometry used to gather indirect light. Lens55 families favor broad quality gathers, while the smaller structured lenses favor more disciplined local support. |
| `GOLDEN_ApplicationLensMode` | `int` | `8` | Application Field Lens Family | — | Selects the Obsidian Mirror-derived field used to shape where the gathered light is allowed to land in the final composite. |
| `GOLDEN_QualityTier` | `int` | `2` | Quality Tier | — | Caps the active tap count before the user tap budget is applied. Higher tiers keep more of the high-quality tap field alive. |
| `GOLDEN_TapBudget` | `int` | `34` | Sampling Field Tap Budget | — | Requested tap count for the main indirect-light gather field before the lens family size and quality tier clamp are applied. This changes the real GI gather, not just debug. Higher values favor denser and smoother indirect gathers. |
| `GOLDEN_ApplicationTapBudget` | `int` | `21` | Application Field Tap Budget | — | Requested tap count for the application lens field before the family size and quality tier clamp are applied. This changes the real placement field, not just debug, and affects where GI is allowed to land rather than how it is gathered. |
| `GOLDEN_ReductionMode` | `int` | `1` | Reduction Mode | — | Sequential consumes the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so coverage stays even when the budget is below the maximum. |
| `GOLDEN_FieldScale` | `float` | `1.0` | Field Scale | — | Scales the underlying Obsidian Mirror lens constellation before it is converted into pixel-space gather offsets for the real GI image. |
| `GOLDEN_FieldRotation` | `float` | `0.0` | Field Rotation | — | Rotates the active lens field in the real GI gather and placement paths. This mainly affects directional and anisotropic lens families such as the rectangular and diamond variants. |
| `GOLDEN_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Offsets the golden-angle phase used by the Fibonacci-derived lens families in the real gather and placement fields. Changing it re-phases sample ordering without altering the total tap count. |
| `GOLDEN_GatherRadiusPixels` | `float` | `5.0` | Gather Radius | — | Pixel radius of the indirect-light gather. Larger values reach farther and recover broader bounce; smaller values stay tighter and more local. |
| `GOLDEN_DistanceFalloff` | `float` | `1.1` | Distance Falloff | — | Controls how quickly far taps lose influence within the active lens field. Lower values keep distant taps strong; higher values bias the gather back toward the center. |
| `GOLDEN_BrightSampleBias` | `float` | `0.10` | Bright Sample Bias | — | Bias toward taps that are brighter than the current pixel. Higher values make Golden Hour recover more luminous neighboring bounce, especially in shadowed regions. |
| `GOLDEN_ShadowPreference` | `float` | `1.2` | Shadow Preference | — | Biases the recovered bounce toward darker source regions. Higher values keep the brightening concentrated in shadow and midtone areas instead of lifting the whole scene evenly. |
| `GOLDEN_BounceSaturation` | `float` | `1.15` | Bounce Saturation | — | Restores or suppresses color saturation in the gathered indirect light. Lower values make the bounce more neutral; higher values let it keep more sampled color character. |
| `GOLDEN_SourceRetention` | `float` | `0.72` | Source Retention | — | How much of the source color is treated as already-lit before bounce is extracted. Higher values make the GI more conservative by requiring gathered light to rise farther above the source. |
| `GOLDEN_ApplicationRadiusPixels` | `float` | `2.6` | Application Field Radius | — | Pixel radius used to evaluate the application lens field in the real GI output. Larger values let the application mask respond to broader neighborhood structure. |
| `GOLDEN_ApplicationLensStrength` | `float` | `0.9` | Application Lens Strength | — | How strongly the application lens field modulates where the recovered GI is allowed to land in the real composite. |
| `GOLDEN_MaskMode` | `int` | `6` | Selected Mask Field | — | Selects the Crystal Mass-derived field used to gate GI application. Composite Guard combines depth, contrast, distance, and protection behavior into a broader placement guide. |
| `GOLDEN_MaskInfluence` | `float` | `0.65` | Mask Influence | — | Blends between ungated application and the selected mask field. Lower values let the gather read clearly for tuning; higher values enforce the mask more strongly. |
| `GOLDEN_MaskStrength` | `float` | `1.0` | Mask Strength | — | Scales the selected mask field before it is blended into the final application gate. |
| `GOLDEN_DepthMode` | `int` | `0` | Depth Mode | — | Chooses how depth is interpreted before the depth-aware gather and Crystal Mass-derived guards evaluate the scene. |
| `GOLDEN_DepthInvert` | `int` | `0` | Depth Invert | — | Inverts near and far interpretation for reversed depth buffers or alternative depth conventions. |
| `GOLDEN_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Amplifies small depth differences before availability, edge, and reject logic are evaluated. Raise it when valid depth exists but gather acceptance is too weak. |
| `GOLDEN_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Availability Threshold | — | Minimum local depth activity required before depth-aware filters fully trust the buffer. Lower values accept weaker depth; higher values demand a clearer signal. |
| `GOLDEN_DepthRejectStart` | `float` | `0.008` | Depth Reject Start | — | Beginning of the depth mismatch ramp that suppresses off-surface taps. Lower values make the gather more surface-tight. |
| `GOLDEN_DepthRejectEnd` | `float` | `0.045` | Depth Reject End | — | Depth mismatch where taps are fully rejected. Raising it tolerates broader depth variation before samples drop out. |
| `GOLDEN_DepthEdgeThreshold` | `float` | `0.003` | Depth Edge Threshold | — | Threshold used by the Crystal Mass-derived depth-discontinuity logic. Lower values catch more silhouette changes; higher values reserve the signal for stronger breaks. |
| `GOLDEN_DepthStart` | `float` | `0.08` | Depth Start | — | Near boundary of the generic depth window used by the depth and composite masks. |
| `GOLDEN_DepthEnd` | `float` | `1.0` | Depth End | — | Far boundary of the generic depth window used by the depth and composite masks. |
| `GOLDEN_FarDetailStart` | `float` | `0.40` | Far Detail Start | — | Beginning of the far-distance range used by the far-detail and composite masks. |
| `GOLDEN_FarDetailEnd` | `float` | `0.78` | Far Detail End | — | Point where far-distance qualification reaches full strength for the far-detail and composite masks. |
| `GOLDEN_FogBrightnessFloor` | `float` | `0.004` | Fog Brightness Floor | — | Minimum brightness before the fog evidence branch begins to react. Raise it to ignore dim haze and focus on brighter atmosphere. |
| `GOLDEN_FogDesaturation` | `float` | `0.18` | Fog Desaturation | — | How colorless a region should be before fog evidence strengthens. Higher values focus more tightly on neutral mist and haze. |
| `GOLDEN_FogLowContrast` | `float` | `0.04` | Fog Low Contrast | — | Local-contrast threshold used by the fog evidence branch. Lower values make fog detection more selective; higher values allow flatter structure to qualify more easily. |
| `GOLDEN_LightThreshold` | `float` | `0.68` | Light Threshold | — | Brightness threshold used by the light-protection branch. Lower values protect more highlights and emissive accents. |
| `GOLDEN_LightSoftness` | `float` | `0.18` | Light Softness | — | Transition width of the light-protection branch. Higher values broaden highlight protection instead of clipping it abruptly. |
| `GOLDEN_ContrastThreshold` | `float` | `0.02` | Contrast Threshold | — | Minimum local contrast required before the contrast branch qualifies. Lower values catch more texture; higher values reserve the field for clearer structure. |
| `GOLDEN_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Gain applied to the local contrast probe before thresholding. Raise it when structurally correct contrast fields are too faint to be useful. |
| `GOLDEN_BreakupMode` | `int` | `0` | Breakup Mode | — | Optional Crooked Tongue-derived breakup field used to subtly shape GI placement. Off keeps the indirect light smooth and purely lens-driven. |
| `GOLDEN_BreakupInfluence` | `float` | `0.25` | Breakup Influence | — | How strongly the breakup field modulates where the final GI lands. Lower values keep the result smoother; higher values introduce more stylized structural modulation. |
| `GOLDEN_BreakupTapBudget` | `int` | `13` | Breakup Tap Budget | — | Requested tap count for tap-driven breakup branches. This mainly affects the Procedural Bio breakup field, which uses Lens55-derived directional support. |
| `GOLDEN_BreakupScale` | `float` | `540.0` | Breakup Scale | — | UV scale of the optional breakup field. Larger values tighten the breakup structure; smaller values keep it broad and slow. |
| `GOLDEN_BreakupDensity` | `float` | `1.9` | Breakup Density | — | Frequency of the optional breakup field. Higher values pack more structure into the same spatial region. |
| `GOLDEN_BreakupFlow` | `float` | `2.2` | Breakup Flow | — | Directional phase offset used by the optional breakup field. Changing it re-phases the structure without changing tap count. |
| `GOLDEN_BreakupTapSpread` | `float` | `96.0` | Breakup Tap Spread | — | How far Lens55 taps spread when the Procedural Bio breakup branch is active. Larger values produce looser and broader structural drift. |

## `book_of_death/effects/ObsidianMirror.fx`

### `ObsidianMirror`

- Source line: `225`
- UI label: Obsidian Mirror :: Lens Placement And Sampling Server
- UI tooltip: Displays and applies lens placement fields for image sampling, including bounded Lens55, spiral, rectangular, diamond, ring, and square coverage patterns.
- Local include closure: `5` files
- Derived resource flags: depth `no`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `OBSIDIAN_DebugView` | `int` | `0` | Displayed Output | — | Chooses which lens stage to inspect. Tiled Lens Placement Field shows the repeated debug layout of the active tap set, Tiled Tap Index Field colors taps by active sampling order, Center Sample Footprint Overlay shows the true image-facing sampling footprint anchored at screen center, Tiled Tap Coverage Field shows how support accumulates across the repeated debug layout, Analysis Mask shows a selected spatial diagnostic, Analysis Applied Overlay blends that diagnostic onto the live image, Averaged Image shows the live gathered result, and Difference From Source shows what the current lens changes. |
| `OBSIDIAN_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal debug views so sparse tap fields and weak coverage are easier to inspect. Does not change passthrough output. |
| `OBSIDIAN_DebugGamma` | `float` | `1.00` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `OBSIDIAN_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `OBSIDIAN_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `OBSIDIAN_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `OBSIDIAN_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `OBSIDIAN_DebugPatternScale` | `float` | `0.24` | Debug Pattern Scale | — | Scales the tiled debug layout only. This changes how large the repeated debug lens appears on screen and does not change the real sample radius used for image gathering. |
| `OBSIDIAN_DebugPatternTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the debug lens layout across the screen. This is debug-only and exists to make spacing and rotation easier to judge at a glance. |
| `OBSIDIAN_DebugMarkerSize` | `float` | `0.016` | Debug Marker Size | — | Controls how large each debug tap marker appears in the tiled pattern and center footprint overlay. This does not change the real sampling footprint size. |
| `OBSIDIAN_DebugPatternSoftness` | `float` | `0.012` | Debug Pattern Softness | — | Softens debug marker edges and guide rings. This is a readability control for debug only and does not affect real image sampling. |
| `OBSIDIAN_AnalysisMode` | `int` | `0` | Analysis Mode | — | Selects which spatial diagnostic Analysis Mask shows. Coverage emphasizes overall support, Voronoi modes show nearest-tap ownership and cell boundaries, Radial and Sequence Order expose ordering behavior, Gap Heat exposes under-supported regions, and Angular Sector shows angular distribution. |
| `OBSIDIAN_AnalysisContrast` | `float` | `2.0` | Analysis Contrast | — | Raises contrast in analysis views so tap ownership changes, weak coverage, and gap structure are easier to read. This affects debug only. |
| `OBSIDIAN_AnalysisBlend` | `float` | `1.0` | Analysis Blend | — | Controls how boldly categorical analysis colors render in Analysis Mask. Lower values soften diagnostic coloring; higher values show stronger category separation. |
| `OBSIDIAN_AnalysisApplyStrength` | `float` | `0.65` | Analysis Apply Strength | — | Controls how strongly the selected analysis diagnostic is blended over the live image in Analysis Applied Overlay. This affects debug only. |
| `OBSIDIAN_Enable` | `int` | `1` | Enable Lens Sampling Effect | — | Master enable for the mined lens modes. Off keeps the module in passthrough-only mode. |
| `OBSIDIAN_LensMode` | `int` | `1` | Lens Mode | — | Selects the active mined lens family. The rectangular, diamond, and Box25 fields are mined coverage variants that emphasize horizontal sweep, vertical sweep, diamond-biased spread, or dense square neighborhood support rather than purely organic placement. |
| `OBSIDIAN_TapBudget` | `int` | `21` | Tap Budget | — | Controls how many taps are active in the current mined lens for the real image, not just the debug view. Each family clamps this to its own canonical size, so Ring9 tops out at 9, Spiral13 and Diamond13 top out at 13, the rectangular fields top out at 15, Box25 tops out at 25, and the Lens55 families top out at 55. |
| `OBSIDIAN_SampleRadius` | `float` | `2.0` | Sample Radius | — | Controls how far active taps reach in pixel space for the real sampled image output. Larger values spread the lens farther from the center sample. |
| `OBSIDIAN_ReductionMode` | `int` | `1` | Reduction Mode | — | Sequential uses the earliest taps first. Staggered redistributes reduced tap counts across the full canonical shape of the active lens so lower budgets stay evenly spread instead of bunching near the front of the tap order. |
| `OBSIDIAN_FieldScale` | `float` | `1.0` | Field Scale | — | Scales the geometric spread of the active lens pattern for real sampling, not just debug preview. Larger values widen the lens constellation before it is converted into pixel-space sampling. |
| `OBSIDIAN_FieldRotation` | `float` | `0.0` | Field Rotation | — | Rotates the active lens field for the actual image gather. This changes the orientation of anisotropic or directional tap distributions. |
| `OBSIDIAN_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Offsets the golden-angle phase used by the Fibonacci-derived lens modes in the live sampling field. Changing it rotates and re-phases the distribution without altering tap count. |
| `OBSIDIAN_AverageMix` | `float` | `1.0` | Average Mix | — | Blends the lens average back toward the source image in Sample Average view. Lower values preserve more of the source; higher values emphasize the aggregate lens sample. |

## `book_of_death/effects/PottingClay.fx`

### `PottingClay`

- Source line: `506`
- UI label: Potting Clay :: Three-Stage Anti-Aliasing
- UI tooltip: Applies three anti-aliasing stages: an FXAA-like directional smoothing pass, an SMAA-like neighborhood blending pass, and an organic lens-field adjunct smoothing pass, then gates the result with a Crystal-derived application mask.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `POTTERY_DebugView` | `int` | `0` | Displayed Output | — | Chooses which anti-aliasing stage to inspect. The first six diagnostics show edge detection and the three pass weights. The next three show the organic lens-field geometry and field strength. Selected Mask and Fog Evidence show the gating signals. Final Application Gate shows the fully combined anti-aliasing gate. The last three views show the isolated image produced by the FXAA-like, SMAA-like, and organic adjunct passes. |
| `POTTERY_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens weak diagnostics so faint blend weights, gates, and field-strength views are easier to inspect. Does not change the final anti-aliased image. |
| `POTTERY_DebugGamma` | `float` | `0.65` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `POTTERY_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `POTTERY_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `POTTERY_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `POTTERY_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `POTTERY_DebugPatternScale` | `float` | `0.24` | Debug Pattern Scale | — | Scales only the repeated debug field views. This changes how large the organic field appears in debug and does not change real smoothing. |
| `POTTERY_DebugPatternTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the organic field debug layout across the screen. This is only for reading field spacing and rotation. |
| `POTTERY_DebugMarkerSize` | `float` | `0.016` | Debug Marker Size | — | Controls how large tap markers appear in the tiled field and center footprint debug views. This does not change real sample size. |
| `POTTERY_DebugPatternSoftness` | `float` | `0.012` | Debug Pattern Softness | — | Softens the marker edges and guide rings in debug views. This is a readability control only. |
| `POTTERY_Enable` | `int` | `1` | Enable Three-Stage Anti-Aliasing Effect | — | Master enable for the three-stage anti-aliasing effect. Off returns the original image unchanged. |
| `POTTERY_EnableDirectional` | `int` | `1` | Enable FXAA-Like Directional Smoothing Pass | — | Enables the first pass, which performs fast directional smoothing along the detected edge direction in an FXAA-like way. |
| `POTTERY_EnableNeighborhood` | `int` | `1` | Enable SMAA-Like Neighborhood Blending Pass | — | Enables the second pass, which blends nearby horizontal, vertical, and diagonal neighborhoods in an SMAA-like way. |
| `POTTERY_EnableOrganic` | `int` | `1` | Enable Organic Lens Adjunct Smoothing Pass | — | Enables the third pass, which uses the lens server field as an organic adjunct smoothing stage after the FXAA-like and SMAA-like stages. |
| `POTTERY_MasterIntensity` | `float` | `1.0` | Master Intensity | — | Overall strength multiplier applied after the three anti-aliasing stages are merged and gated. |
| `POTTERY_EdgeThreshold` | `float` | `0.035` | Edge Threshold | — | Minimum luma range required before any anti-aliasing is allowed to engage. |
| `POTTERY_EdgeSoftness` | `float` | `0.040` | Edge Softness | — | Soft transition width above the edge threshold. Higher values make anti-aliasing ramp in more gradually. |
| `POTTERY_OrganicLensMode` | `int` | `3` | Organic Sampling Lens Family | — | Selects the Obsidian Mirror-derived lens family used by the organic smoothing pass. |
| `POTTERY_QualityTier` | `int` | `2` | Organic Quality Tier | — | Caps the organic tap budget before the active lens family applies its own family-size clamp. |
| `POTTERY_OrganicTapBudget` | `int` | `21` | Organic Field Tap Budget | — | Requested tap count for the organic lens field before quality-tier and family-size clamping are applied. This changes real smoothing, not just debug. |
| `POTTERY_ReductionMode` | `int` | `1` | Organic Reduction Mode | — | Sequential uses the earliest taps first. Staggered redistributes reduced tap counts across the full canonical lens shape. |
| `POTTERY_FieldScale` | `float` | `1.0` | Organic Field Scale | — | Scales the underlying organic lens constellation before it is converted into pixel-space smoothing offsets. |
| `POTTERY_FieldRotation` | `float` | `0.0` | Organic Field Rotation | — | Rotates the organic lens field used by the third anti-aliasing pass. |
| `POTTERY_FibonacciAnchor` | `float` | `2584.0` | Organic Fibonacci Anchor | — | Offsets the golden-angle phase used by the Fibonacci-derived organic lens families. |
| `POTTERY_OrganicRadiusPixels` | `float` | `1.25` | Organic Radius | — | Pixel radius of the organic lens smoothing pass. |
| `POTTERY_OrganicEdgeBias` | `float` | `0.58` | Organic Edge Bias | — | Biases organic lens weights toward taps aligned with the detected edge direction. |
| `POTTERY_DirectionalStrength` | `float` | `0.85` | FXAA-Like Pass Strength | — | Blend strength of the FXAA-like directional smoothing pass. |
| `POTTERY_DirectionalSpanPixels` | `float` | `1.45` | FXAA-Like Directional Span | — | Maximum span sampled along the detected edge direction by the FXAA-like smoothing pass. |
| `POTTERY_DirectionalSubpixel` | `float` | `0.65` | FXAA-Like Subpixel Bias | — | Subpixel weighting for the FXAA-like pass. Higher values extend the directional smoothing footprint. |
| `POTTERY_NeighborhoodStrength` | `float` | `0.90` | SMAA-Like Pass Strength | — | Blend strength of the SMAA-like neighborhood blending pass. |
| `POTTERY_NeighborhoodContrastThreshold` | `float` | `0.022` | SMAA-Like Neighborhood Contrast Threshold | — | Contrast gate for the SMAA-like neighborhood blending pass. Higher values make this pass more selective. |
| `POTTERY_NeighborhoodDiagonalWeight` | `float` | `0.70` | SMAA-Like Diagonal Weight | — | How strongly diagonal neighborhood blending contributes relative to horizontal and vertical blending inside the SMAA-like pass. |
| `POTTERY_OrganicStrength` | `float` | `0.85` | Organic Adjunct Pass Strength | — | Blend strength of the organic lens adjunct smoothing pass. |
| `POTTERY_OrganicDistanceFalloff` | `float` | `1.2` | Organic Adjunct Distance Falloff | — | How quickly farther organic taps lose influence. Higher values bias the organic adjunct pass toward nearer taps. |
| `POTTERY_OrganicCenterWeight` | `float` | `1.0` | Organic Adjunct Center Weight | — | How strongly the source pixel is preserved within the organic adjunct pass before neighboring taps are averaged in. |
| `POTTERY_MaskMode` | `int` | `5` | Selected Mask Field | — | Selects the Crystal Mass-derived mask used to gate the anti-aliasing result. |
| `POTTERY_MaskInfluence` | `float` | `0.35` | Mask Influence | — | How strongly the selected mask field influences the final anti-aliasing gate. At zero the mask is ignored. At one the selected mask is fully respected. |
| `POTTERY_FogInfluence` | `float` | `0.25` | Fog Evidence Influence | — | How strongly fog-like regions reduce the final anti-aliasing gate. |
| `POTTERY_DepthMode` | `int` | `0` | Depth Interpretation Mode | — | Controls how the Crystal Mass-derived depth logic interprets the scene depth buffer. |
| `POTTERY_DepthInvert` | `int` | `0` | Invert Depth | — | Inverts depth interpretation before depth-derived masks are evaluated. |
| `POTTERY_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Scales small depth differences so depth confidence, depth windowing, and far-detail logic read more clearly. |
| `POTTERY_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Confidence Threshold | — | Minimum useful depth variation required before depth-driven masks are trusted. |
| `POTTERY_DepthStart` | `float` | `0.10` | Depth Window Start | — | Near boundary of the selected depth window mask. |
| `POTTERY_DepthEnd` | `float` | `0.95` | Depth Window End | — | Far boundary of the selected depth window mask. |
| `POTTERY_DepthEdgeThreshold` | `float` | `0.012` | Depth Edge Threshold | — | Threshold used by depth-edge diagnostics and silhouette-style logic within the Crystal-derived masks. |
| `POTTERY_FarDetailStart` | `float` | `0.40` | Far Detail Start | — | Depth where the far-detail mask begins to activate. |
| `POTTERY_FarDetailEnd` | `float` | `0.85` | Far Detail End | — | Depth where the far-detail mask reaches full strength. |
| `POTTERY_DetailScale` | `float` | `1.0` | Detail Scale | — | Scales the detail detector used by the far-detail mask. |
| `POTTERY_DetailLow` | `float` | `0.03` | Detail Threshold Low | — | Low threshold of the detail detector used by the far-detail mask. |
| `POTTERY_DetailHigh` | `float` | `0.12` | Detail Threshold High | — | High threshold of the detail detector used by the far-detail mask. |
| `POTTERY_ContrastThreshold` | `float` | `0.06` | Contrast Threshold | — | Threshold used by the contrast-derived mask field. |
| `POTTERY_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Gain applied to the local-contrast detector before the contrast mask is formed. |
| `POTTERY_FogBrightnessFloor` | `float` | `0.45` | Fog Brightness Floor | — | Brightness floor used by the fog-evidence detector. |
| `POTTERY_FogDesaturation` | `float` | `0.25` | Fog Desaturation Floor | — | Desaturation floor used by the fog-evidence detector. |
| `POTTERY_FogLowContrast` | `float` | `0.06` | Fog Low Contrast Ceiling | — | Upper contrast ceiling used by the fog-evidence detector. |
| `POTTERY_LineThreshold` | `float` | `0.020` | Line Threshold | — | Edge threshold used by line-like structure suppression inside the fog-evidence logic. |
| `POTTERY_LightThreshold` | `float` | `0.72` | Light Threshold | — | Brightness threshold used by the light-shield detector. |
| `POTTERY_LightSoftness` | `float` | `0.12` | Light Softness | — | Transition softness used by the light-shield detector. |

## `book_of_death/effects/SpiritWorld.fx`

### `SpiritWorld`

- Source line: `531`
- UI label: Spirit World :: Three Pass Cell Shading
- UI tooltip: Applies three layered stylization passes: a base banded shading pass, a coarse hatch-driven shading pass, and a superfine detail pass.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `SPIRIT_DebugView` | `int` | `0` | Displayed Output | — | Chooses which Spirit World stage to inspect. Base Result shows the banded foundation, Coarse Contribution and Superfine Contribution show the isolated additions from those passes, and Edge Field, Depth Gate, and Effective Mask Gate expose the main controls behind the stack. |
| `SPIRIT_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens low-signal debug outputs so thin edges, weak masks, and subtle superfine detail are easier to read. Does not change the final composite when Debug View is Final Composite. |
| `SPIRIT_DebugGamma` | `float` | `1.00` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `SPIRIT_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `SPIRIT_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `SPIRIT_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `SPIRIT_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `SPIRIT_Enable` | `int` | `1` | Enable Cell Shading Effect | — | Master enable for the Spirit World cell shader stack. Off returns the source image unchanged. |
| `SPIRIT_EnableBase` | `int` | `1` | Enable Base Shading Pass | — | Enables the base cel-shading pass. This is the primary banding and edge-inking layer. |
| `SPIRIT_EnableCoarse` | `int` | `1` | Enable Coarse Shading Pass | — | Enables the broader hatch-weighted coarse pass. This adds large-form stylized shading over the base layer. |
| `SPIRIT_EnableSuperfine` | `int` | `1` | Enable Superfine Detail Pass | — | Enables the superfine pass. This adds restrained micro-detail and clarity on top of the broader cell structure. |
| `SPIRIT_MasterIntensity` | `float` | `1.0` | Master Intensity | — | Overall intensity multiplier for the combined three-pass stack. Lower values keep the effect subtle; higher values push all enabled passes harder. |
| `SPIRIT_BaseStrength` | `float` | `0.75` | Base Strength | — | Blend amount of the banded base pass. Higher values make cel quantization and flat-value grouping more obvious. |
| `SPIRIT_BaseBands` | `int` | `7` | Base Bands | — | Number of luminance bands used by the base pass. Lower values give chunkier cel shading; higher values preserve more tonal resolution. |
| `SPIRIT_BaseBandContrast` | `float` | `0.95` | Base Band Contrast | — | Contrast shaping applied before band quantization. Higher values push separation between light and dark bands. |
| `SPIRIT_BaseEdgeStrength` | `float` | `0.65` | Base Edge Strength | — | Darkening strength of the base edge-inking pass. Higher values make contour emphasis more graphic and assertive. |
| `SPIRIT_EdgeRadiusPixels` | `float` | `0.8` | Edge Radius Pixels | — | Sampling radius used for edge evaluation. Larger values read broader contour structure; smaller values hold onto tight local edges. |
| `SPIRIT_EdgeLumaGain` | `float` | `5.0` | Luma Edge Gain | — | Gain applied to luminance edge response before thresholding. Raise it when visible contrast edges are present but not reading strongly enough. |
| `SPIRIT_EdgeDepthGain` | `float` | `90.0` | Depth Edge Gain | — | Gain applied to depth-discontinuity response before thresholding. Raise it when silhouette structure exists in depth but the edge pass is too weak. |
| `SPIRIT_EdgeThreshold` | `float` | `0.16` | Edge Threshold | — | Threshold where edge response begins. Lower values catch more structure; higher values reserve inking for clearer contours. |
| `SPIRIT_EdgeSoftness` | `float` | `0.24` | Edge Softness | — | Softness of the edge threshold transition. Lower values make edge inking crisper; higher values blend it more gently. |
| `SPIRIT_CoarseStrength` | `float` | `0.55` | Coarse Strength | — | Darkening strength of the coarse pass. This controls how strongly the broad hatch and shadow structure shapes the base layer. |
| `SPIRIT_CoarsePatternScale` | `float` | `620.0` | Coarse Hatch Field Scale | — | UV scale of the coarse hatch field in the real image. Larger values tighten the pattern; smaller values broaden the structural shading shapes. |
| `SPIRIT_CoarseDensity` | `float` | `2.0` | Coarse Density | — | Density of the coarse hatch field in the real image. Higher values create denser coarse stylization and heavier directional structure. |
| `SPIRIT_CoarseFlow` | `float` | `2.7` | Coarse Flow | — | Phase drift for the coarse hatch field in the real image. Changing it alters the organic directional drift without changing tap count. |
| `SPIRIT_CoarseTapSpread` | `float` | `115.0` | Coarse Tap Spread | — | How far Lens55 support taps spread while building the coarse hatch field in the real image. Larger values produce broader structural reach. |
| `SPIRIT_CoarseFieldTapBudget` | `int` | `21` | Coarse Field Tap Budget | — | Number of taps used by the coarse hatch field itself. This is independent from the bounded lens support field budget, so the base support and coarse hatch can now be tuned separately. |
| `SPIRIT_CoarseCenterContrast` | `float` | `0.45` | Coarse Center Contrast | — | Contrast shaping for the centered Fibonacci hatch body used by the coarse pass. Lower values keep the hatch broader and softer; higher values make the centered structure read more sharply. |
| `SPIRIT_CoarseStageBlend` | `float` | `0.55` | Coarse Stage Blend | — | How strongly the five-stage depth banding influences the coarse field. Higher values make the coarse pass more depth-zoned and staged. |
| `SPIRIT_CoarseShadowStart` | `float` | `0.24` | Coarse Shadow Start | — | Beginning of the tonal range where coarse shading starts to appear. Lower values allow the coarse layer into brighter areas. |
| `SPIRIT_CoarseShadowEnd` | `float` | `0.82` | Coarse Shadow End | — | Full-strength tonal boundary for the coarse layer. Lower values reserve the strongest coarse shading for darker regions only. |
| `SPIRIT_SuperfineStrength` | `float` | `0.85` | Superfine Strength | — | Strength of the superfine pass. Higher values push micro-detail and clarity more strongly on top of the base and coarse layers. |
| `SPIRIT_SuperfineRadius` | `float` | `0.9` | Superfine Radius | — | Sampling radius of the superfine neighborhood. Smaller values keep the pass tight and crisp; larger values broaden micro-detail support. |
| `SPIRIT_SuperfineClamp` | `float` | `0.14` | Superfine Clamp | — | Clamp on signed superfine detail contribution. Lower values keep the pass subtle and safer; higher values allow more visible micro-contrast lift. |
| `SPIRIT_SuperfineChromaSafety` | `float` | `0.7` | Superfine Chroma Safety | — | Biases superfine detail toward luminance instead of raw color. Higher values reduce color fizz and keep the micro-detail cleaner. |
| `SPIRIT_LensMode` | `int` | `0` | Lens Support Mode | — | Selects the bounded support field used by the base pass. Organic and Staggered are broader organic fields; Diamond13 and Box25 are tighter structured support fields. |
| `SPIRIT_TapBudget` | `int` | `21` | Lens Field Tap Budget | — | Number of support taps used by the bounded lens field in the real image. Each support mode clamps this to its own canonical size. |
| `SPIRIT_ReductionMode` | `int` | `1` | Lens Reduction | — | How reduced tap counts are selected for the active support lens. Sequential takes the earliest taps, while Staggered redistributes lower budgets across the full canonical shape so the support field stays spatially balanced. |
| `SPIRIT_LensRadiusPixels` | `float` | `2.2` | Lens Radius Pixels | — | Pixel reach of the bounded lens support field used by the base pass in the real image. Larger values broaden the averaged support neighborhood. |
| `SPIRIT_LensFieldScale` | `float` | `1.0` | Lens Field Scale | — | Geometric scale of the bounded support field in the real image. Higher values spread taps farther within the support constellation. |
| `SPIRIT_LensFieldRotation` | `float` | `0.0` | Lens Field Rotation | — | Rotation of the bounded support field in the real image. This mainly affects anisotropic support modes such as Diamond13 and the structured Lens55 reductions. |
| `SPIRIT_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Phase anchor shared by the bounded lens support field and the centered Fibonacci coarse field. Changing it re-phases their ordering without changing tap count. |
| `SPIRIT_MaskMode` | `int` | `0` | Mask Gate Mode | — | Chooses the compact Crystal-style gate used to admit or suppress the three-pass stack. Off disables mask gating and lets the stack apply everywhere. |
| `SPIRIT_MaskStrength` | `float` | `1.0` | Mask Strength | — | Gain applied to the selected mask gate before it modulates the three-pass stack. Raise it when the chosen gate is correct but too weak. |
| `SPIRIT_MaskInfluence` | `float` | `0.0` | Mask Influence | — | How strongly the selected mask gate suppresses the coarse and superfine passes. At 0 the advanced passes are ungated; at 1 they fully obey the selected mask. |
| `SPIRIT_DepthMode` | `int` | `0` | Depth Mode | — | Depth interpretation used by depth-aware edge, gate, and mask logic. Switch this if the depth diagnostics look reversed or flat. |
| `SPIRIT_DepthInvert` | `int` | `0` | Depth Invert | — | Inverts near and far interpretation for alternative depth conventions. |
| `SPIRIT_DepthTraceScale` | `float` | `256.0` | Depth Trace Scale | — | Amplifies subtle depth differences before they feed edge detection, depth confidence, and depth-aware masks. |
| `SPIRIT_DepthAvailabilityThreshold` | `float` | `0.001` | Depth Confidence Threshold | — | Minimum local depth activity needed before the shader trusts depth for gating and edge logic. |
| `SPIRIT_DepthEdgeThreshold` | `float` | `0.003` | Depth Edge Threshold | — | Threshold where depth-discontinuity response begins. Lower values catch more silhouettes; higher values reserve response for stronger breaks. |
| `SPIRIT_DepthStart` | `float` | `0.0` | Depth Start | — | Near boundary of the compact depth window and far-bias logic. Lower values let near structure into the depth gate earlier. |
| `SPIRIT_DepthEnd` | `float` | `1.0` | Depth End | — | Far boundary of the compact depth window. Together with Depth Start, this controls the core depth acceptance band. |
| `SPIRIT_FarDetailStart` | `float` | `0.45` | Far Detail Start | — | Near boundary where far-detail logic starts to become active. Also used as a far bias for haze-like fog detection. |
| `SPIRIT_FarDetailEnd` | `float` | `0.75` | Far Detail End | — | Full-strength far-detail boundary. Raising it pushes far-detail gating deeper into the scene. |
| `SPIRIT_FogBrightnessFloor` | `float` | `0.004` | Fog Brightness Floor | — | Brightness floor used by the fog evidence gate. Raising it restricts fog detection to brighter haze and mist. |
| `SPIRIT_FogDesaturation` | `float` | `0.18` | Fog Desaturation | — | How colorless a region must be before the fog gate increases. Higher values focus more strongly on neutral haze. |
| `SPIRIT_FogLowContrast` | `float` | `0.04` | Fog Low Contrast | — | Local-contrast threshold used by the fog gate. Lower values make the haze detector more selective. |
| `SPIRIT_LightThreshold` | `float` | `0.68` | Light Threshold | — | Brightness threshold where the light-shield gate starts to treat pixels as highlight-critical. |
| `SPIRIT_LightSoftness` | `float` | `0.18` | Light Softness | — | Soft transition width for the light-shield gate. Higher values broaden highlight protection. |
| `SPIRIT_LineThreshold` | `float` | `0.018` | Line Threshold | — | Threshold used by line-oriented mask logic and fog edge suppression. Lower values catch more fine structure. |
| `SPIRIT_ContrastThreshold` | `float` | `0.02` | Contrast Threshold | — | Minimum local luminance change required before the contrast gate turns on. Lower values catch more texture and edges. |
| `SPIRIT_ContrastGain` | `float` | `2.0` | Contrast Gain | — | Gain applied to local contrast before thresholding. Raise it when the contrast gate is structurally right but too weak. |

## `depth_oracle/effects/black_wand_DepthOracle.fx`

### `black_wand_DepthOracle`

- Source line: `601`
- UI label: Source provides no `ui_label`.
- UI tooltip: Source provides no `ui_tooltip`.
- Local include closure: `8` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `black_wand_DO_ViewMode` | `int` | `BLACK_WAND_DO_VIEW_SOURCE` | Debug View | Depth Oracle / View | Clean DisplayDepth-parity diagnostic order. Source/UV/checker prove output before depth; official depth is the oracle path. |
| `black_wand_DO_ManualPreviewEnabled` | `bool` | `false` | Enable Manual Preview Branch | Depth Oracle / Manual Preview | Manual branch is for diagnosis only. Official ReShade linear depth remains the oracle/reference branch. |
| `black_wand_DO_FlipVertical` | `bool` | `false` | Manual Flip Vertical | Depth Oracle / Manual Preview | — |
| `black_wand_DO_UVScale` | `float2` | `float2(1.0, 1.0)` | Manual Depth UV Scale | Depth Oracle / Manual Preview | — |
| `black_wand_DO_PixelOffset` | `int2` | `int2(0, 0)` | Manual Depth Pixel Offset | Depth Oracle / Manual Preview | — |
| `black_wand_DO_ReverseDepth` | `bool` | `RESHADE_DEPTH_INPUT_IS_REVERSED` | Manual Reverse Depth | Depth Oracle / Manual Preview | — |
| `black_wand_DO_LogDepth` | `bool` | `RESHADE_DEPTH_INPUT_IS_LOGARITHMIC` | Manual Log Depth Decode | Depth Oracle / Manual Preview | — |
| `black_wand_DO_DepthMultiplier` | `float` | `RESHADE_DEPTH_MULTIPLIER` | Manual Depth Multiplier | Depth Oracle / Manual Preview | — |
| `black_wand_DO_LogCurve` | `float` | `0.0100` | Manual Log Curve | Depth Oracle / Manual Preview | — |
| `black_wand_DO_NearPlane` | `float` | `1.000` | Manual Near Plane | Depth Oracle / Manual Preview | — |
| `black_wand_DO_FarPlane` | `float` | `RESHADE_DEPTH_LINEARIZATION_FAR_PLANE` | Manual Far Plane | Depth Oracle / Manual Preview | — |
| `black_wand_DO_EndpointMargin` | `float` | `0.000001` | Endpoint Rejection Margin | Depth Oracle / Validity | — |
| `black_wand_DO_NormalRadius` | `float` | `1.000` | Normal Sample Radius | Depth Oracle / Normal | — |
| `black_wand_DO_RMProbeStepPixels` | `float` | `1.000` | RM Probe Step Pixels | Depth Oracle / RM Probe | Fixed, shallow screen-space depth-continuity probe step. This does not replace depth normalization. |
| `black_wand_DO_RMDepthTolerance` | `float` | `0.002000` | RM Probe Depth Tolerance | Depth Oracle / RM Probe | — |
| `black_wand_DO_CompareScale` | `float` | `100.000` | Difference Heat Scale | Depth Oracle / Compare | — |
| `black_wand_DO_DisplayBlackPoint` | `float` | `0.000` | Display Black Point | Depth Oracle / Display | — |
| `black_wand_DO_DisplayWhitePoint` | `float` | `1.000` | Display White Point | Depth Oracle / Display | — |
| `black_wand_DO_DisplayGamma` | `float` | `1.000` | Display Gamma | Depth Oracle / Display | — |
| `black_wand_DO_DisplayContrast` | `float` | `1.000` | Display Contrast | Depth Oracle / Display | — |
| `black_wand_DO_DisplayExposure` | `float` | `0.000` | Display Exposure | Depth Oracle / Display | — |
| `black_wand_DO_DisplayInvert` | `bool` | `false` | Display Invert | Depth Oracle / Display | — |
| `black_wand_DO_LiftDarkDiagnostics` | `bool` | `true` | Lift Dark Diagnostics | Depth Oracle / Display | Raises scalar views slightly so valid low-depth output is not mistaken for a blank pass. |
| `black_wand_DO_VisibilityFloor` | `float` | `0.035` | Diagnostic Visibility Floor | Depth Oracle / Display | — |
| `black_wand_DO_OverlayStrength` | `float` | `0.700` | Overlay Strength | Depth Oracle / Display | — |
| `black_wand_DO_OfficialFocusStrength` | `float` | `8.000` | Official Depth Focus Strength | Depth Oracle / Official Baseline | Compresses official linear depth into a readable scalar view. Higher values brighten near/mid depth detail. |
| `black_wand_DO_OfficialDetailRadius` | `float` | `1.000` | Official Detail Radius | Depth Oracle / Official Baseline | — |
| `black_wand_DO_OfficialEdgeTolerance` | `float` | `0.002000` | Official Edge Tolerance | Depth Oracle / Official Baseline | — |
| `black_wand_DO_OfficialBandCount` | `float` | `32.000` | Official Depth Band Count | Depth Oracle / Official Baseline | — |
| `black_wand_DO_OfficialBandLineWidth` | `float` | `0.035` | Official Band Line Width | Depth Oracle / Official Baseline | — |
| `black_wand_DO_NormalReliefStrength` | `float` | `0.650` | Official Normal Relief Strength | Depth Oracle / Official Baseline | — |
| `black_wand_DO_OfficialEdgeGain` | `float` | `32.000` | Official Edge Gain | Depth Oracle / Mid Coverage | Scales local official-depth differences before threshold/softness shaping. Lower this if edge views are solid red. |
| `black_wand_DO_OfficialEdgeThreshold` | `float` | `0.160` | Official Edge Threshold | Depth Oracle / Mid Coverage | Edge response starts here after gain. Raise this if the view is over-covered. |
| `black_wand_DO_OfficialEdgeSoftness` | `float` | `1.250` | Official Edge Softness | Depth Oracle / Mid Coverage | Soft transition width around the edge threshold. Raise this for mid coverage instead of red-only saturation. |
| `black_wand_DO_MidCoverageCenter` | `float` | `0.500` | Mid Coverage Center | Depth Oracle / Mid Coverage | Diagnostic center used by mid-coverage views. 0.5 means strongest response where the shaped mask is half-covered. |
| `black_wand_DO_MidCoverageWidth` | `float` | `0.650` | Mid Coverage Width | Depth Oracle / Mid Coverage | Width of the mid-coverage diagnostic window. Raise this to see more partial coverage. |
| `black_wand_DO_RMMidGain` | `float` | `24.000` | RM Delta Gain | Depth Oracle / Mid Coverage | Scales RM depth deltas before threshold/softness shaping. Lower this if RM views are solid red. |
| `black_wand_DO_RMMidThreshold` | `float` | `0.160` | RM Delta Threshold | Depth Oracle / Mid Coverage | — |
| `black_wand_DO_RMMidSoftness` | `float` | `1.500` | RM Delta Softness | Depth Oracle / Mid Coverage | — |
| `black_wand_DO_OfficialBandWaveMix` | `float` | `0.850` | Official Band Wave Mix | Depth Oracle / Mid Coverage | Adds a continuous contour wave to depth bands so bands remain visible when thin line bands miss coverage. |
| `black_wand_DO_OfficialBandSharpness` | `float` | `1.500` | Official Band Sharpness | Depth Oracle / Mid Coverage | — |
| `black_wand_DO_LumaFallbackMode` | `int` | `BLACK_WAND_DO_LUMA_FALLBACK_OFF` | Luma Fallback Policy | Depth Oracle / Luma Fallback | Controls when the luma surrogate branch participates. Official depth/normal remain the trusted path when available. |
| `black_wand_DO_LumaRadius` | `float` | `1.000` | Luma Sample Radius | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaContrastGain` | `float` | `16.000` | Luma Contrast Gain | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaToneGain` | `float` | `8.000` | Luma Tone/Occlusion Gain | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaFallbackStrength` | `float` | `0.650` | Luma Fallback Strength | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaBrightIsNear` | `bool` | `false` | Luma Surrogate Bright Is Near | Depth Oracle / Luma Fallback | When off, darker pixels produce nearer surrogate depth. This is diagnostic only. |
| `black_wand_DO_LumaSurrogateGamma` | `float` | `1.000` | Luma Surrogate Gamma | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaSurrogateContrastMix` | `float` | `0.350` | Luma Surrogate Contrast Mix | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_DepthConfidenceThreshold` | `float` | `0.350` | Depth Confidence Threshold | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaActivationThreshold` | `float` | `0.080` | Luma Activation Threshold | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_DepthActivityGain` | `float` | `256.000` | Depth Activity Gain | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaRMStepPixels` | `float` | `1.000` | Luma RM Step Pixels | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaRMGain` | `float` | `12.000` | Luma RM Delta Gain | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaRMThreshold` | `float` | `0.120` | Luma RM Delta Threshold | Depth Oracle / Luma Fallback | — |
| `black_wand_DO_LumaRMSoftness` | `float` | `1.500` | Luma RM Delta Softness | Depth Oracle / Luma Fallback | — |

## `golden_weave/effects/GoldenWeave_RMGI_Primitive.fx`

### `GoldenWeave_RMGI_Primitive`

- Source line: `450`
- UI label: GoldenWeave - Ray-Marched GI - Primitive Build
- UI tooltip: Primitive-built screen-space ray-marched global illumination with source/depth/color/lens/mask/ray atoms, explicit budgets, guards, and diagnostics.
- Local include closure: `1` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `LW_ViewOutput` | `int` | `0` | View Output | — | Selects final output or a diagnostic view from the primitive pipeline. |
| `LW_QualityPreset` | `int` | `2` | Quality Preset | — | Caps active directions, ray steps, and strength scaling. |
| `LW_GIStrength` | `float` | `1.350` | GI Strength | — | Overall indirect-light contribution. |
| `LW_ContactShadow` | `float` | `0.420` | Contact Shadow | — | Darkens creases and shallow occluder hits discovered by primitive rays. |
| `LW_ColorBleed` | `float` | `1.250` | Color Bleed | — | How strongly gathered color shifts nearby surfaces. |
| `LW_SceneBlend` | `float` | `0.780` | Scene Blend | — | Final blend between source frame and computed GI result. |
| `LW_DetailRestore` | `float` | `0.320` | Detail Restore | — | Returns local source contrast after GI is applied. |
| `LW_RayMode` | `int` | `2` | Ray Mode | — | Gather Only uses one lens tap per direction; Ray March walks along the ray; Hybrid blends both. |
| `LW_DirectionBudget` | `int` | `16` | Direction Budget | — | Maximum active primitive directions before preset and budget caps. |
| `LW_StepBudget` | `int` | `6` | Step Budget | — | Maximum primitive ray steps per direction before preset and budget caps. |
| `LW_BudgetScale` | `float` | `0.75` | Budget Scale | — | Scales active direction and step count without changing the preset. |
| `LW_RayLengthPixels` | `float` | `7.50` | Ray Length | — | Maximum ray reach in pixels. |
| `LW_GatherLengthPixels` | `float` | `3.25` | Gather Length | — | Single-sample gather reach in pixels. |
| `LW_RayRotation` | `float` | `0.0` | Ray Rotation | — | Rotates the sampling field. |
| `LW_OrganicDrift` | `float` | `1.300` | Organic Drift | — | Deterministic per-pixel drift used to break rigid ray patterns. |
| `LW_SamplingLens` | `int` | `1` | Sampling Lens | — | Primitive direction field used by the GI rays. |
| `LW_ApplicationLens` | `int` | `2` | Application Lens | — | Primitive field used to shape where GI is applied. |
| `LW_ApplicationStrength` | `float` | `0.650` | Application Strength | — | How strongly the selected application lens modulates final GI. |
| `LW_LensRadiusPixels` | `float` | `2.50` | Lens Radius | — | Neighborhood radius used for application-lens diagnostics and contrast fields. |
| `LW_LensSharpness` | `float` | `4.20` | Lens Sharpness | — | Contrast/edge gain used by application lens modes. |
| `LW_FibonacciAnchor` | `float` | `1597.0` | Fibonacci Anchor | — | Phase anchor for Fibonacci and organic lens synthesis. |
| `LW_DepthThickness` | `float` | `0.0120` | Depth Thickness | — | Depth tolerance for accepting ray samples as related surfaces. |
| `LW_DepthBias` | `float` | `0.0015` | Depth Bias | — | Self-intersection bias for nearby samples. |
| `LW_DepthFalloff` | `float` | `36.0` | Depth Falloff | — | Distance falloff along the ray. |
| `LW_DepthEdgeReject` | `float` | `0.720` | Depth Edge Reject | — | Suppresses GI near discontinuities to reduce halos. |
| `LW_NormalDirectionality` | `float` | `0.850` | Normal Directionality | — | Weights rays by the depth-derived primitive surface normal. |
| `LW_SurfaceSpread` | `float` | `0.720` | Surface Spread | — | Controls how permissive the surface-normal lobe is. |
| `LW_BounceSaturation` | `float` | `1.380` | Bounce Saturation | — | Saturation of gathered indirect color. |
| `LW_ColorTemperature` | `float` | `0.080` | Color Temperature | — | Negative cools bounce light, positive warms bounce light. |
| `LW_EmissivePickup` | `float` | `0.450` | Emissive Pickup | — | Boosts contribution from bright donor pixels. |
| `LW_ContributionClamp` | `float` | `2.250` | Contribution Clamp | — | Upper bound on indirect contribution before composition. |
| `LW_ResponseCurve` | `float` | `1.120` | Response Curve | — | Power curve applied to ray-hit coverage and application mask. |
| `LW_SkyProtect` | `float` | `0.950` | Sky Protect | — | Suppresses GI where the depth buffer appears invalid or sky-like. |
| `LW_FogStart` | `float` | `0.780` | Fog Start | — | Depth position where far/fog protection begins. |
| `LW_FogProtect` | `float` | `0.620` | Fog Protect | — | Suppresses GI in far/fog regions. |
| `LW_HighlightThreshold` | `float` | `0.820` | Highlight Threshold | — | Luma threshold for highlight/light protection. |
| `LW_LightProtect` | `float` | `0.720` | Light Protect | — | Restores protected bright pixels toward the original source color. |
| `LW_StabilityBlend` | `float` | `0.520` | Stability Blend | — | Suppresses contribution at unstable depth/edge regions. |
| `LW_EdgePreserve` | `float` | `0.410` | Edge Preserve | — | Restores source color around strong color/depth edges. |

## `golden_weave/effects/GoldenWeave_RMGI_Redux.fx`

### `GoldenWeave_RMGI_Redux`

- Source line: `920`
- UI label: GoldenWeave - Ray-Marched GI - Redux
- UI tooltip: Standalone screen-space ray-marched global illumination, split into bounded sampling passes to avoid X3511 loop-unroll failure.
- Local include closure: `0` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `LW_ViewOutput` | `int` | `0` | View Output | — | Selects final output or a diagnostic view. |
| `LW_QualityPreset` | `int` | `2` | Quality Preset | — | Caps active directions, ray steps, and strength scaling. |
| `LW_GIStrength` | `float` | `1.350` | GI Strength | — | Overall indirect-light contribution. |
| `LW_ContactShadow` | `float` | `0.420` | Contact Shadow | — | Darkens creases and shallow occluder hits discovered by the rays. |
| `LW_ColorBleed` | `float` | `1.250` | Color Bleed | — | How strongly gathered color shifts nearby surfaces. |
| `LW_SceneBlend` | `float` | `0.780` | Scene Blend | — | Final blend between source frame and computed GI result. |
| `LW_DetailRestore` | `float` | `0.320` | Detail Restore | — | Returns local source contrast after GI is applied. |
| `LW_RayMode` | `int` | `2` | Ray Mode | — | Gather Only uses one lens tap per direction; Ray March walks along the ray; Hybrid blends both. |
| `LW_DirectionBudget` | `int` | `16` | Direction Budget | — | Maximum active sampling directions before preset and budget caps. |
| `LW_StepBudget` | `int` | `6` | Step Budget | — | Maximum steps per direction before preset and budget caps. |
| `LW_BudgetScale` | `float` | `0.75` | Budget Scale | — | Scales active direction and step count without changing the preset. |
| `LW_RayLengthPixels` | `float` | `7.50` | Ray Length | — | Maximum ray reach in pixels. |
| `LW_GatherLengthPixels` | `float` | `3.25` | Gather Length | — | Single-sample gather reach in pixels. |
| `LW_RayRotation` | `float` | `0.0` | Ray Rotation | — | Rotates the sampling field. |
| `LW_OrganicDrift` | `float` | `1.300` | Organic Drift | — | Deterministic per-pixel drift used to break rigid ray patterns. |
| `LW_SamplingLens` | `int` | `1` | Sampling Lens | — | Direction field used by the GI rays. |
| `LW_ApplicationLens` | `int` | `2` | Application Lens | — | Field used to shape where GI is applied. |
| `LW_ApplicationStrength` | `float` | `0.650` | Application Strength | — | How strongly the selected application lens modulates final GI. |
| `LW_LensRadiusPixels` | `float` | `2.50` | Lens Radius | — | Neighborhood radius used for application-lens diagnostics and contrast fields. |
| `LW_LensSharpness` | `float` | `4.20` | Lens Sharpness | — | Contrast/edge gain used by application lens modes. |
| `LW_FibonacciAnchor` | `float` | `1597.0` | Fibonacci Anchor | — | Phase anchor for Fibonacci and organic lens synthesis. |
| `LW_DepthThickness` | `float` | `0.0120` | Depth Thickness | — | Depth tolerance for accepting ray samples as related surfaces. |
| `LW_DepthBias` | `float` | `0.0015` | Depth Bias | — | Self-intersection bias for nearby samples. |
| `LW_DepthFalloff` | `float` | `36.0` | Depth Falloff | — | Distance falloff along the ray. |
| `LW_DepthEdgeReject` | `float` | `0.720` | Depth Edge Reject | — | Suppresses GI near discontinuities to reduce halos. |
| `LW_NormalDirectionality` | `float` | `0.850` | Normal Directionality | — | Weights rays by the depth-derived surface normal. |
| `LW_SurfaceSpread` | `float` | `0.720` | Surface Spread | — | Controls how permissive the surface-normal lobe is. |
| `LW_BounceSaturation` | `float` | `1.380` | Bounce Saturation | — | Saturation of gathered indirect color. |
| `LW_ColorTemperature` | `float` | `0.080` | Color Temperature | — | Negative cools bounce light, positive warms bounce light. |
| `LW_EmissivePickup` | `float` | `0.450` | Emissive Pickup | — | Boosts contribution from bright donor pixels. |
| `LW_ContributionClamp` | `float` | `2.250` | Contribution Clamp | — | Upper bound on indirect contribution before composition. |
| `LW_ResponseCurve` | `float` | `1.120` | Response Curve | — | Power curve applied to ray-hit coverage and application mask. |
| `LW_SkyProtect` | `float` | `0.950` | Sky Protect | — | Suppresses GI where the depth buffer appears invalid or sky-like. |
| `LW_FogStart` | `float` | `0.780` | Fog Start | — | Depth position where far/fog protection begins. |
| `LW_FogProtect` | `float` | `0.620` | Fog Protect | — | Suppresses GI in far/fog regions. |
| `LW_HighlightThreshold` | `float` | `0.820` | Highlight Threshold | — | Luma threshold for highlight/light protection. |
| `LW_LightProtect` | `float` | `0.720` | Light Protect | — | Restores protected bright pixels toward the original source color. |
| `LW_StabilityBlend` | `float` | `0.520` | Stability Blend | — | Suppresses contribution at unstable depth/edge regions. |
| `LW_EdgePreserve` | `float` | `0.410` | Edge Preserve | — | Restores source color around strong color/depth edges. |

## `legacy_lenses/effects/hexing_eye.fx`

### `hexing_eye`

- Source line: `630`
- UI label: hexing eye :: standalone hatch server
- UI tooltip: Standalone hatch host for inspecting hatch families, tonal masks, edge masks, and depth-driven placement before using the final shaded result.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `HEXING_EYE_Time` | `float` | `0.0` | — | — | — |
| `HEXING_EYE_DebugView` | `int` | `0` | Debug View | — | Chooses which hatch, mask, or depth diagnostic to display. Use the mask and depth views to verify where the effect is allowed to appear before judging the final shaded image. |
| `HEXING_EYE_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens dim diagnostic views so weak masks, subtle depth changes, and low-coverage hatch regions are easier to inspect. Does not change final shading. |
| `HEXING_EYE_DebugGamma` | `float` | `0.70` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `HEXING_EYE_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `HEXING_EYE_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `HEXING_EYE_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `HEXING_EYE_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `HEXING_EYE_HatchMode` | `int` | `3` | Hatch Style | — | Selects the hatch generator used by the effect. The five-stage families emphasize depth staging, while the log-spiral families create more organic, branch-driven stroke flow. |
| `HEXING_EYE_ApplicationMask` | `int` | `1` | Application Mask | — | Selects the placement mask that decides where hatching is allowed. Use this to confine the effect to dark tones, edges, far depth, detail zones, or stepped hatch bands. |
| `HEXING_EYE_HatchStrength` | `float` | `0.72` | Hatch Strength | — | Controls how strongly the final hatch darkens the source image. Higher values make the selected hatch family read more aggressively. |
| `HEXING_EYE_HatchSpacing` | `float` | `8.0` | Hatch Spacing | — | Controls line spacing for the analytic hatch families. Lower values pack lines tightly for denser shading; higher values open the pattern and make strokes more separated. |
| `HEXING_EYE_HatchThickness` | `float` | `0.22` | Hatch Thickness | — | Controls how thick each hatch stroke appears within its spacing interval. Higher values make the pattern feel bolder and darker. |
| `HEXING_EYE_HatchContrast` | `float` | `1.25` | Hatch Contrast | — | Sharpens or softens how decisively hatch lines appear. Higher values create crisper, more binary strokes; lower values keep the pattern gentler. |
| `HEXING_EYE_AdvancedPatternScale` | `float` | `860.0` | Advanced Pattern Scale | — | Sets the spatial frequency for the synthesized multi-stage and Fibonacci hatch families. Higher values make those patterns finer and more tightly packed across the image. |
| `HEXING_EYE_HatchAngleA` | `float` | `35.0` | Hatch Angle A | — | Primary hatch angle for analytic line families. Rotating it changes the dominant stroke direction across the image. |
| `HEXING_EYE_HatchAngleB` | `float` | `-35.0` | Hatch Angle B | — | Secondary hatch angle used by cross and layered analytic families. It changes how opposing or supporting stroke sets intersect. |
| `HEXING_EYE_HatchAngleC` | `float` | `90.0` | Hatch Angle C | — | Tertiary hatch angle used by layered and scribble-like variants. It helps control the character of denser dark-region shading. |
| `HEXING_EYE_Jitter` | `float` | `1.1` | Noise Jitter | — | Adds positional wobble to the analytic hatch field. Higher values break up uniform lines and make the pattern feel more hand-drawn. |
| `HEXING_EYE_AnimationSpeed` | `float` | `0.18` | Animation Speed | — | Controls how quickly the Animated Hatch pattern moves over time. Higher values increase visible motion and can introduce shimmer if pushed too far. |
| `HEXING_EYE_FibonacciTapCount` | `int` | `55` | Fibonacci Tap Count | — | Sets how many directional taps contribute to the Fibonacci-driven hatch families. Higher values add complexity and coverage to those synthesized patterns. |
| `HEXING_EYE_FibonacciReductionMode` | `int` | `0` | Fibonacci Reduction | — | Controls how reduced Fibonacci tap counts are chosen. Staggered spreads taps across the full 89-tap field, while Sequential fills from the earliest taps first. |
| `HEXING_EYE_FibonacciAnchor` | `float` | `2584.0` | Fibonacci Anchor | — | Shifts the directional phase of Fibonacci-driven hatch families. Changing it can noticeably alter flow, clustering feel, and local line orientation without changing tap count. |
| `HEXING_EYE_FibonacciFlow` | `float` | `1.50` | Fibonacci Flow | — | Offsets the phase used by the bio and Fibonacci-derived hatch families. Use it to move the pattern into a different stable arrangement. |
| `HEXING_EYE_FibonacciDensity` | `float` | `2.05` | Fibonacci Density | — | Controls how many strokes the synthesized Fibonacci families draw within their pattern space. Higher values create finer, busier hatch fields. |
| `HEXING_EYE_FibonacciTapSpread` | `float` | `96.0` | Fibonacci Tap Spread | — | Controls how far the synthesized Fibonacci taps are spread through pattern space. Higher values increase variation across the hatch field and reduce uniform repetition. |
| `HEXING_EYE_FiveStageBlendWidth` | `float` | `0.30` | Five-Stage Blend Width | — | Controls how broadly the five-stage depth bands overlap when using the blended or isolated five-stage families. Higher values make transitions between near, forward, center, back, and far feel smoother. |
| `HEXING_EYE_SpiralGrowth` | `float` | `1.18` | Spiral Growth | — | Controls how quickly each recursive log-spiral branch expands outward. Higher values spread branches apart faster and create a more open spiral field. |
| `HEXING_EYE_SpiralTightness` | `float` | `1.05` | Spiral Tightness | — | Controls how tightly the log-spiral branches wind around their centers. Higher values create more angular turn and denser spiral wrapping. |
| `HEXING_EYE_SpiralBranchCount` | `int` | `5` | Spiral Branch Count | — | Sets how many branch arms the log-spiral hatch field uses. Higher values produce a richer, more distributed branch network. |
| `HEXING_EYE_SpiralRecursiveLevels` | `int` | `3` | Spiral Recursive Levels | — | Controls how many recursive levels contribute to the log-spiral direction field. More levels add structure but can make the branch field busier. |
| `HEXING_EYE_SpiralBranchBlend` | `float` | `0.70` | Spiral Branch Blend | — | Blends between the local Fibonacci lens direction and the recursive branch direction. Lower values keep the hatch more lens-led; higher values make the spiral field dominate. |
| `HEXING_EYE_LumaThresholdA` | `float` | `0.72` | Luma Threshold A | — | Upper threshold where darkening begins to unlock more hatch coverage. Raising it allows hatching to start earlier in brighter midtones. |
| `HEXING_EYE_LumaThresholdB` | `float` | `0.48` | Luma Threshold B | — | Middle threshold where additional layers start appearing. It controls when medium-dark regions become more densely hatched. |
| `HEXING_EYE_LumaThresholdC` | `float` | `0.24` | Luma Threshold C | — | Lowest threshold for the darkest regions. It determines when the deepest tones receive the fullest hatch layering. |
| `HEXING_EYE_EdgeThreshold` | `float` | `0.028` | Edge Threshold | — | Sets how much local luminance contrast is required before color-edge masking activates. Lower values catch more outlines and texture transitions. |
| `HEXING_EYE_DepthEdgeThreshold` | `float` | `0.010` | Depth Edge Threshold | — | Sets how much depth discontinuity is required before depth-edge masking activates. Lower values pick up finer depth seams and object boundaries. |
| `HEXING_EYE_DepthInvert` | `int` | `0` | Depth Invert | — | Flips near and far depth interpretation. Enable it when near objects appear dark in depth views and distant objects appear bright. |
| `HEXING_EYE_DepthLinearizationMode` | `int` | `0` | Depth Mode | — | Chooses how the shader reads depth before building depth-driven masks. Use Raw or Raw Inverted when ReShade linearized depth looks flat or incorrect in your game. |
| `HEXING_EYE_DepthTraceScale` | `float` | `512.0` | Depth Trace Scale | — | Amplifies small depth differences before edge and reject tests. Raise it when depth-based masks look flat or fail to separate foreground from background. |
| `HEXING_EYE_DepthAvailabilityThreshold` | `float` | `0.00250` | Depth Availability Threshold | — | Sets the minimum local depth activity required before the shader trusts depth. Lower values accept weaker depth signals; higher values reject noisy or nearly flat depth. |
| `HEXING_EYE_FarDepthStart` | `float` | `0.58` | Far Depth Start | — | Sets where the far-depth mask begins. Lower values let distant shading start closer to the camera; higher values reserve it for the far background. |
| `HEXING_EYE_FarDepthFeather` | `float` | `0.20` | Far Depth Feather | — | Controls how gradually the far-depth mask fades in. Higher values create a broader transition from unmasked to fully masked. |
| `HEXING_EYE_DepthRejectRadius` | `float` | `1.5` | Depth Reject Radius | — | Controls how far the shader looks around each pixel when checking for depth disagreement. Higher values make depth rejection respond to broader local structure. |
| `HEXING_EYE_DepthRejectThreshold` | `float` | `0.018` | Depth Reject Threshold | — | Sets how much depth mismatch is tolerated before the depth-reject mask turns off. Lower values make the mask stricter around silhouettes and intersections. |
| `HEXING_EYE_RadiusRing` | `float` | `0.28` | Radius Ring | — | Sets the radius of the circular debug mask. Useful for checking where a radial placement mask will appear on screen. |
| `HEXING_EYE_RadiusRingThickness` | `float` | `0.020` | Ring Thickness | — | Controls how narrow or broad the ring mask appears. Higher values make the ring easier to read but less precise. |
| `HEXING_EYE_DetailRadiusPixels` | `float` | `1.6` | Detail Radius | — | Controls how far the detail probe samples around each pixel. Higher values make the probe respond to larger surrounding features instead of only fine detail. |
| `HEXING_EYE_DetailGain` | `float` | `2.2` | Detail Gain | — | Scales the strength of the Golden21 detail mask. Higher values make detail-driven placement appear more aggressively. |

## `legacy_lenses/effects/kaleidoscope.fx`

### `kaleidoscope`

- Source line: `666`
- UI label: Kaleidoscope :: Image Mask Construction Server
- UI tooltip: Displays sample-mask fields, final-mask fields, mask combination logic, and the supporting color, depth, spatial, hatch, and protection diagnostics used to construct image masks.
- Local include closure: `6` files
- Derived resource flags: depth `yes`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `KALEIDOSCOPE_DebugView` | `int` | `0` | Displayed Output | — | Chooses which mask or diagnostic to show. Use Sample Mask and Final Mask to inspect the independent stages, then Combined Mask and Masked Scene to see the result after combination. |
| `KALEIDOSCOPE_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens dim debug views so weak masks, subtle depth changes, and low-contrast diagnostics are easier to read. It does not change the actual mask math. |
| `KALEIDOSCOPE_DebugGamma` | `float` | `0.70` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `KALEIDOSCOPE_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `KALEIDOSCOPE_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `KALEIDOSCOPE_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `KALEIDOSCOPE_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `KALEIDOSCOPE_SampleMaskMode` | `int` | `3` | Sample Mask | — | Selects the mask intended for sampling-time decisions. In a consuming shader this is the mask you would use inside loops, ray taps, or weighting logic. |
| `KALEIDOSCOPE_FinalMaskMode` | `int` | `14` | Final Mask | — | Selects the mask intended for final application strength. In a consuming shader this is the mask you would use after the effect has already been computed. |
| `KALEIDOSCOPE_CombineMode` | `int` | `0` | Combine Mode | — | Controls how the sample mask and final mask are merged. Multiply is the safest default, Max broadens coverage, Add intensifies it, and Difference highlights where the two masks disagree. |
| `KALEIDOSCOPE_MaskStrength` | `float` | `1.0` | Mask Strength | — | Scales the combined mask after sample and final stages are merged. Higher values push the weighted mask closer to full strength and make Masked Scene more obvious. |
| `KALEIDOSCOPE_SceneMix` | `float` | `0.8` | Masked Scene Mix | — | Controls how strongly the weighted mask is visualized over the source image in Masked Scene. Lower values keep more of the original scene visible. |
| `KALEIDOSCOPE_LumaDarkStart` | `float` | `0.45` | Dark Start | — | Sets where the dark-tone mask starts fading out. Higher values allow more midtones into Luma Dark before the mask weakens. |
| `KALEIDOSCOPE_LumaDarkFeather` | `float` | `0.18` | Dark Feather | — | Controls how gradually the dark-tone mask fades into brighter regions. Higher values make Luma Dark smoother and less binary. |
| `KALEIDOSCOPE_LumaBrightStart` | `float` | `0.62` | Bright Start | — | Sets where the bright-tone mask begins. Lower values let highlights and upper midtones enter Luma Bright earlier. |
| `KALEIDOSCOPE_LumaBrightFeather` | `float` | `0.16` | Bright Feather | — | Controls how softly the bright-tone mask rises. Higher values make the highlight transition broader and less abrupt. |
| `KALEIDOSCOPE_LumaMidCenter` | `float` | `0.50` | Mid Center | — | Places the center of the Luma Mid window. Moving it shifts which tonal band is treated as the primary midtone region. |
| `KALEIDOSCOPE_LumaMidWidth` | `float` | `0.12` | Mid Width | — | Controls how wide the Luma Mid window is before it starts falling off. Higher values include more of the tonal range. |
| `KALEIDOSCOPE_LumaMidFeather` | `float` | `0.08` | Mid Feather | — | Softens the edges of the midtone window. Higher values create a broader transition from strong midtone selection to no selection. |
| `KALEIDOSCOPE_SaturationHighStart` | `float` | `0.45` | Sat High Start | — | Sets where the high-saturation mask begins. Lower values let moderately colorful regions into Saturation High sooner. |
| `KALEIDOSCOPE_SaturationHighFeather` | `float` | `0.18` | Sat High Feather | — | Controls how smoothly the high-saturation mask grows. Higher values make colorful transitions less harsh. |
| `KALEIDOSCOPE_SaturationLowStart` | `float` | `0.32` | Sat Low Start | — | Sets where the low-saturation mask starts fading out. Higher values keep more muted color inside Saturation Low. |
| `KALEIDOSCOPE_SaturationLowFeather` | `float` | `0.14` | Sat Low Feather | — | Controls how gradually the low-saturation mask releases into more vivid color. Higher values are more forgiving. |
| `KALEIDOSCOPE_HueWidth` | `float` | `0.10` | Hue Width | — | Controls how broad each hue-sector mask is around its center. Higher values include a larger color family, while lower values isolate a tighter hue range. |
| `KALEIDOSCOPE_HueFeather` | `float` | `0.05` | Hue Feather | — | Softens the edge of each hue-sector mask. Higher values make warm, cool, and green masks transition more smoothly across neighboring hues. |
| `KALEIDOSCOPE_ContrastThreshold` | `float` | `0.035` | Contrast Threshold | — | Sets how much local luminance change is required before the Contrast mask turns on. Lower values catch more edges and texture. |
| `KALEIDOSCOPE_ContrastGain` | `float` | `2.4` | Contrast Gain | — | Amplifies local contrast before thresholding. Higher values make weak structure read more strongly in the Contrast mask. |
| `KALEIDOSCOPE_DepthMode` | `int` | `0` | Depth Mode | — | Chooses how depth is interpreted before depth masks are built. Switch modes when Linear Depth looks flat, inverted, or otherwise wrong for the current game. |
| `KALEIDOSCOPE_DepthInvert` | `int` | `0` | Depth Invert | — | Flips near and far interpretation after the selected depth mode is applied. Enable it if near objects appear dark and far objects appear bright when they should not. |
| `KALEIDOSCOPE_DepthTraceScale` | `float` | `512.0` | Depth Trace Scale | — | Amplifies tiny depth differences before edge and reject tests. Raise it when depth-based masks appear too flat to separate scene layers. |
| `KALEIDOSCOPE_DepthAvailabilityThreshold` | `float` | `0.00250` | Depth Availability Threshold | — | Sets how much local depth activity is required before the shader trusts depth. Higher values are stricter and reject weak or noisy depth feeds. |
| `KALEIDOSCOPE_DepthNearEnd` | `float` | `0.26` | Near End | — | Sets how far the Depth Near mask reaches before it fades out. Higher values extend near coverage farther into the scene. |
| `KALEIDOSCOPE_DepthNearFeather` | `float` | `0.12` | Near Feather | — | Controls how gradually the near mask fades away. Higher values create a softer near-to-mid transition. |
| `KALEIDOSCOPE_DepthFarStart` | `float` | `0.58` | Far Start | — | Sets where the far-depth mask begins. Lower values bring distant masking closer to the camera, while higher values reserve it for deeper background. |
| `KALEIDOSCOPE_DepthFarFeather` | `float` | `0.18` | Far Feather | — | Controls how softly the far-depth mask rises. Higher values create a broader transition into far-region coverage. |
| `KALEIDOSCOPE_DepthEdgeThreshold` | `float` | `0.0100` | Depth Edge Threshold | — | Sets how much depth discontinuity is needed before the Depth Edge mask turns on. Lower values catch finer object boundaries. |
| `KALEIDOSCOPE_DepthRejectRadius` | `float` | `1.50` | Depth Reject Radius | — | Controls how far the shader looks for conflicting depth when building Depth Reject. Higher values make rejection respond to broader local structure. |
| `KALEIDOSCOPE_DepthRejectThreshold` | `float` | `0.018` | Depth Reject Threshold | — | Sets how much depth mismatch is tolerated before the Depth Reject mask turns off. Lower values make it more protective around silhouettes and intersections. |
| `KALEIDOSCOPE_SpatialRadiusPixels` | `float` | `2.0` | Spatial Radius | — | Controls how far spatial masks sample around each pixel. Higher values make ring, spiral, box, and directional masks respond to larger surrounding structure. |
| `KALEIDOSCOPE_SpatialGain` | `float` | `2.2` | Spatial Gain | — | Amplifies ring and spiral detail responses. Higher values make subtle neighborhood differences read more strongly in those masks. |
| `KALEIDOSCOPE_BoxVarianceGain` | `float` | `18.0` | Box Variance Gain | — | Scales the 3x3 variance response used by Box Variance. Higher values make texture and small tonal breaks show up much more clearly. |
| `KALEIDOSCOPE_DirectionalAngle` | `float` | `0.0` | Directional Angle | — | Sets the preferred direction tested by the Directional mask. Rotating it changes which oriented structures are emphasized. |
| `KALEIDOSCOPE_DirectionalGain` | `float` | `3.0` | Directional Gain | — | Amplifies directional difference before thresholding. Higher values make the mask more sensitive to alignment with the chosen angle. |
| `KALEIDOSCOPE_DirectionalThreshold` | `float` | `0.08` | Directional Threshold | — | Sets how strong the directional response must be before the Directional mask activates. Lower values catch more subtle orientation. |
| `KALEIDOSCOPE_DirectionalFeather` | `float` | `0.08` | Directional Feather | — | Controls how softly the directional mask rises once it passes threshold. Higher values make orientation selection less abrupt. |
| `KALEIDOSCOPE_HatchScale` | `float` | `18.0` | Hatch Scale | — | Controls line spacing for hatch-derived masks. Lower values make lines denser, while higher values spread the pattern farther apart. |
| `KALEIDOSCOPE_HatchThickness` | `float` | `0.22` | Hatch Thickness | — | Changes how thick each hatch stroke is inside its spacing interval. Higher values make hatch masks darker and bolder. |
| `KALEIDOSCOPE_HatchSoftness` | `float` | `0.04` | Hatch Softness | — | Softens the edge of hatch strokes. Lower values give crisper line masks, while higher values blend line boundaries more gently. |
| `KALEIDOSCOPE_HatchAngleA` | `float` | `35.0` | Hatch Angle A | — | Primary hatch direction used by Hatch Diagonal and one side of Cross Hatch. Rotating it changes the dominant stroke orientation. |
| `KALEIDOSCOPE_HatchAngleB` | `float` | `-35.0` | Hatch Angle B | — | Secondary hatch direction used by Cross Hatch. Changing it alters how the two stroke families intersect. |
| `KALEIDOSCOPE_HatchBandA` | `float` | `0.72` | Hatch Band A | — | First tonal threshold for Hatch Bands. Raising it allows the first hatch layer to appear in brighter tones. |
| `KALEIDOSCOPE_HatchBandB` | `float` | `0.48` | Hatch Band B | — | Second tonal threshold for Hatch Bands. It controls when a denser stepped hatch zone becomes active. |
| `KALEIDOSCOPE_HatchBandC` | `float` | `0.24` | Hatch Band C | — | Third tonal threshold for Hatch Bands. Lower values reserve the strongest stepped hatch response for the darkest tones only. |
| `KALEIDOSCOPE_LineGuardThreshold` | `float` | `0.018` | Line Guard Threshold | — | Sets how strong a local luminance gradient must be before thin-line protection activates. Lower values make the line guard catch more fine structures. |
| `KALEIDOSCOPE_LineGuardStrength` | `float` | `0.85` | Line Guard Strength | — | Scales the line-protection mask after detection. Higher values make protected line structures survive more strongly in downstream use. |
| `KALEIDOSCOPE_PixelGuardThreshold` | `float` | `0.70` | Pixel Guard Threshold | — | Brightness threshold where hot-pixel protection starts. Lower values make the mask pick up more bright micro-details. |
| `KALEIDOSCOPE_PixelGuardSaturation` | `float` | `0.25` | Pixel Guard Saturation | — | Minimum saturation required for color-driven hot-pixel protection. Lower values make the mask catch more vivid pixels. |
| `KALEIDOSCOPE_PixelGuardStrength` | `float` | `0.90` | Pixel Guard Strength | — | Scales the hot-pixel protection mask. Higher values preserve bright or saturated micro-pixels more aggressively. |
| `KALEIDOSCOPE_HighlightProtectStart` | `float` | `0.68` | Highlight Protect Start | — | Sets where broad highlight protection begins. Lower values bring more upper-midtones into the protected region. |
| `KALEIDOSCOPE_HighlightProtectFeather` | `float` | `0.18` | Highlight Protect Feather | — | Controls how softly the highlight-protection mask rolls in. Higher values make bright-region protection more gradual. |
| `KALEIDOSCOPE_HighlightProtectSaturation` | `float` | `0.22` | Highlight Protect Saturation | — | Minimum saturation required for color-biased highlight protection. Lower values let colorful highlights enter the mask sooner. |
| `KALEIDOSCOPE_HighlightProtectColorBias` | `float` | `0.35` | Highlight Color Bias | — | Blends between pure brightness-driven highlight protection and added saturation-driven protection. Higher values favor vivid emissive colors. |
| `KALEIDOSCOPE_SilhouetteContrastBias` | `float` | `0.85` | Silhouette Contrast Bias | — | Controls how much color-contrast edges contribute relative to depth edges in the silhouette-protection mask. Higher values make silhouettes respond more strongly to image edges. |

## `legacy_lenses/effects/looking_glass.fx`

### `looking_glass`

- Source line: `604`
- UI label: looking glass :: standalone lens server
- UI tooltip: Standalone lens host for inspecting tap layouts, true sample footprints, reduced Fibonacci subsets, and spatial analysis masks.
- Local include closure: `5` files
- Derived resource flags: depth `no`; back buffer `yes`

### Uniform controls

| Symbol | Type | Default | UI label | Category | Tooltip |
|---|---|---|---|---|---|
| `LOOKING_GLASS_DebugView` | `int` | `0` | Debug View | — | Chooses which lens debug output to show. Pattern and Tap Index visualize placement, Sample views show image response, Analysis Mask shows raw spatial diagnostics, and Analysis Applied Overlay shows the selected analysis mask applied over the live image. |
| `LOOKING_GLASS_DebugExposure` | `float` | `1.0` | Debug Exposure | — | Brightens dim debug views so sparse taps, weak overlays, and low-contrast analysis fields are easier to inspect. Does not change sampling or final image output. |
| `LOOKING_GLASS_DebugGamma` | `float` | `0.70` | Debug Gamma | — | Display-only gamma for debug outputs. Lower values lift dim detail; higher values compress it. Does not change the final composite when the displayed output is Final. |
| `LOOKING_GLASS_DebugContrast` | `float` | `1.00` | Debug Contrast | — | Display-only contrast for masks, depth fields, detail fields, and other diagnostics. Does not alter the real effect path. |
| `LOOKING_GLASS_DebugBlackPoint` | `float` | `0.00` | Debug Black Point | — | Lower remap point for debug visualization. Raise it to clip low-level noise and isolate stronger diagnostic signal. |
| `LOOKING_GLASS_DebugWhitePoint` | `float` | `1.00` | Debug White Point | — | Upper remap point for debug visualization. Lower it to expand faint masks, depth variation, and detail probes. |
| `LOOKING_GLASS_DebugInvert` | `int` | `0` | Debug Invert | — | Inverts the shaped debug view only. Useful for inspecting dark depth, inverse masks, and negative-space coverage. |
| `LOOKING_GLASS_LensMode` | `int` | `21` | Lens | — | Selects the tap layout used by all previews and sample-based debug modes. Pair, box, diamond, and ring lenses are useful for oriented analysis, while bounded and Fibonacci families give broader organic coverage. |
| `LOOKING_GLASS_AnalysisMaskMode` | `int` | `2` | Analysis Mask | — | Selects the analysis coloring used by Analysis Mask. These modes help inspect coverage gaps, ordering, Voronoi ownership, and how reduced tap counts distribute across the lens. |
| `LOOKING_GLASS_SampleRadiusPixels` | `float` | `2.0` | Sample Radius | — | Controls how far each tap samples from the center in pixel space. Higher values widen the true sampling footprint and make Sample Average and Sample Delta respond more strongly. |
| `LOOKING_GLASS_RotationDegrees` | `float` | `0.0` | Rotation | — | Rotates the active tap layout around the center without changing tap count or relative spacing. Use it to inspect directional bias or align a lens with scene structure. |
| `LOOKING_GLASS_PreviewRadius` | `float` | `0.24` | Debug Pattern Scale | — | Scales the on-screen debug layout for Lens Pattern, Tap Index, Analysis Mask, and the tiled portion of Sample Footprint Overlay. It does not change the real sample radius used for image fetches. |
| `LOOKING_GLASS_PreviewTiles` | `float` | `4.0` | Debug Pattern Tiles | — | Repeats the debug pattern across the screen. Higher values show more copies of the lens layout, which is useful when comparing spacing and rotation at a glance. |
| `LOOKING_GLASS_MarkerSize` | `float` | `0.016` | Marker Size | — | Changes how large each tap appears in debug previews and overlays. Larger values make individual taps easier to read, especially in dense Fibonacci layouts. |
| `LOOKING_GLASS_PatternSoftness` | `float` | `0.012` | Pattern Softness | — | Softens the edges of debug markers and guide rings. Lower values give crisp dots and rings, while higher values create broader, more blended previews. |
| `LOOKING_GLASS_DeltaBoost` | `float` | `4.0` | Delta Boost | — | Amplifies the difference image in Sample Delta. Raise it when the lens effect is subtle and you want to see which areas the current layout changes the most. |
| `LOOKING_GLASS_AverageMix` | `float` | `1.0` | Average Mix | — | Blends between the untouched image and the lens-averaged image in Sample Average. Lower values keep more of the source; higher values reveal the full averaging effect. |
| `LOOKING_GLASS_FibActiveTapCount` | `int` | `55` | Fibonacci Active Taps | — | Sets how many taps are active for Fibonacci lens families. Lower values reduce cost and simplify the layout while trying to keep coverage spread across the full lens. |
| `LOOKING_GLASS_FibReductionMode` | `int` | `0` | Reduction Mode | — | Controls how reduced Fibonacci tap counts are chosen. Staggered keeps taps spread over the full pattern, while Sequential fills from the earliest canonical taps first. |
| `LOOKING_GLASS_AnalysisContrast` | `float` | `2.0` | Analysis Contrast | — | Increases contrast in Analysis Mask views so boundaries, ownership changes, and gap differences are easier to see. |
| `LOOKING_GLASS_AnalysisBlend` | `float` | `1.0` | Analysis Blend | — | Controls how strongly some analysis coloring is blended into the debug output. Higher values make categorical analysis views read more boldly. |
| `LOOKING_GLASS_AnalysisApplyStrength` | `float` | `0.65` | Analysis Apply Strength | — | Controls how strongly the Analysis Applied Overlay debug view applies the selected analysis mask over the live image. This affects debug visualization only. |

## Validation boundary

This reference establishes source declaration coverage and resolved local
include relationships. It does not establish clean ReShade compilation,
backend compatibility, performance, target-game depth correctness, preset
quality, effect ordering, or live visual acceptance.
