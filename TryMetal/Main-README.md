# SwiftUI + Metal Shaders Workshop

A hands-on workshop exploring Metal shaders in SwiftUI. We build four interactive effects from scratch, learning how GPU shaders work and how SwiftUI connects to them.

## Requirements

- Xcode 26+
- iOS 26+ / macOS 26+
- No third-party dependencies

## Project Structure

```
TryMetal/
  Example App/          Polished showcase of all four effects
  Workshop/
    Start/              Starting point for the workshop
    Final/              Completed step-by-step reference
```

### Example App

A tab-based app with four finished effects you can interact with. This folder is **for reference only** -- you don't need to modify anything here. Use it after the workshop to review the final implementations, explore how the SwiftUI views are wired up, or compare with your own code.

| Tab | Effect | What it shows |
|-----|--------|---------------|
| Procedural | Dotted Background | Touch-driven dot grid with glow, repulsion, and attraction modes |
| Color | Image Filters | Grayscale, sepia, and hue shift applied to a photo via sliders |
| Layer | Refracting Glass | Magnifying lens with chromatic aberration, drag to move |
| Distortion | Jelly Wobble | Touch-triggered damped spring distortion with circular reveal transition |

### Workshop

This is where we work during the workshop.

**`Start/`** contains the files you'll be editing:

| File | Description |
|------|-------------|
| `DottedBackground.metal` | Starter Metal file with a single function that returns black. We build from here. |
| `DottedBackgroundView.swift` | SwiftUI view already wired to the starter shader. Focus is on Metal, not SwiftUI boilerplate. |
| `ImageFiltersView.swift` | Image with sliders. No shader connected yet -- we'll create the Metal file and add `.colorEffect()` together. |
| `RefractingGlassView.swift` | Glass UI with drag and sliders. No shader connected -- we'll create the Metal file and add `.layerEffect()` together. |
| `WaveDistortionView.swift` | Image with TimelineView and sliders. No shader connected -- we'll create the Metal file and add `.distortionEffect()` together. |

**`Final/`** contains the completed code broken into incremental steps (step0, step1, step2...) for each effect. Use this after the workshop to review concepts at your own pace. Each step has comments explaining what changed and why.

## Workshop Flow

1. **Procedural (Dotted Background)** -- Metal only. Learn UV coordinates, SDF circles, `fract()` for tiling, touch interaction, and three modes (glow, repulsion, attraction).

2. **Color Effect (Image Filters)** -- Introduce SwiftUI's `.colorEffect()` modifier and `ShaderLibrary`. Build grayscale, sepia, and hue shift filters that transform the `color` input.

3. **Layer Effect (Refracting Glass)** -- Introduce `.layerEffect()` and `SwiftUI::Layer`. Build magnification via `layer.sample()`, add chromatic aberration and Fresnel highlights.

4. **Distortion Effect (Jelly Wobble)** -- Introduce `.distortionEffect()` and `TimelineView` for time-based animation. Build a damped spring wobble with touch interaction.

## Three Shader Types

| SwiftUI Modifier | Metal Signature | Returns | Use For |
|-----------------|----------------|---------|---------|
| `.colorEffect()` | `half4 name(float2 position, half4 color, ...)` | New color | Filters, tinting, procedural patterns |
| `.layerEffect()` | `half4 name(float2 position, SwiftUI::Layer layer, ...)` | New color | Sampling other positions: blur, magnify, refract |
| `.distortionEffect()` | `float2 name(float2 position, ...)` | New position | Moving/warping content: waves, wobble, ripple |
