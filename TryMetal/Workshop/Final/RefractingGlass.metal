#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// =============================================================================
//  RefractingGlass.metal
//  SwiftUI + Metal Shaders Workshop — Layer Effects
//
//    [[stitchable]] half4 name(float2 position, SwiftUI::Layer layer, args...)
//
//  Layer effects receive a `SwiftUI::Layer` instead of a `half4 color`.
//  The layer lets you sample ANY position — not just the current pixel.
//  This is what enables magnification, refraction, blur, and chromatic aberration.
//
//  Key function: layer.sample(float2 position)
//    Returns the color at that position in the original layer.
//    Sampling at `position` gives the original pixel.
//    Sampling elsewhere moves/distorts the content.
// =============================================================================


// =============================================================================
//  STEP 0 — Passthrough
//  Goal: understand the layer effect signature.
//  Sample the layer at the current position — no distortion.
// =============================================================================
[[stitchable]]
half4 glass_step0_passthrough(float2 position, SwiftUI::Layer layer,
                              float2 size, float2 glassCenter,
                              float glassRadius, float refraction)
{
    return layer.sample(position);
}


// =============================================================================
//  STEP 1 — Circle mask
//  Goal: detect if we're inside the glass circle.
//
//  Convert position to UV (0–1), measure distance from glassCenter.
//  Inside: tint blue so we can see the shape. Outside: original color.
// =============================================================================
[[stitchable]]
half4 glass_step1_circle(float2 position, SwiftUI::Layer layer,
                         float2 size, float2 glassCenter,
                         float glassRadius, float refraction)
{
    float2 uv = position / size;
    float dist = length(uv - glassCenter);

    half4 original = layer.sample(position);

    if (dist < glassRadius) {
        // Inside the glass — tint blue to visualise the region
        return mix(original, half4(0.2, 0.4, 1.0, 1.0), 0.4);
    }

    return original;
}


// =============================================================================
//  STEP 2 — Magnification (refraction)
//  Goal: sample the layer at a shifted position to create a magnifying effect.
//
//  Key insight: to magnify, we sample CLOSER to the glass center.
//  Think of it as: "instead of looking at this pixel, look at the pixel
//  that's closer to the center of the lens."
//
//  Parabolic falloff (1 - d²) makes the effect stronger in the center
//  and weaker near the edges, like a real lens.
// =============================================================================
[[stitchable]]
half4 glass_step2_magnify(float2 position, SwiftUI::Layer layer,
                          float2 size, float2 glassCenter,
                          float glassRadius, float refraction)
{
    float2 uv = position / size;
    float2 toCenter = uv - glassCenter;
    float dist = length(toCenter);

    if (dist < glassRadius) {
        float normalizedDist = dist / glassRadius;

        // Parabolic: strong in center, zero at edge
        float distortionAmount = (1.0 - normalizedDist * normalizedDist);

        // Offset toward center, scaled by refraction strength
        float2 refractedOffset = toCenter * distortionAmount * refraction;
        float2 refractedPos = position - refractedOffset * size;

        return layer.sample(refractedPos);
    }

    return layer.sample(position);
}


// =============================================================================
//  STEP 3 — Chromatic aberration
//  Goal: split RGB channels by sampling each at slightly different positions.
//
//  Real lenses bend different wavelengths differently:
//  red bends less, blue bends more. We simulate this by sampling
//  R and B at slightly offset positions from the main refracted point.
// =============================================================================
[[stitchable]]
half4 glass_step3_chromatic(float2 position, SwiftUI::Layer layer,
                            float2 size, float2 glassCenter,
                            float glassRadius, float refraction)
{
    float2 uv = position / size;
    float2 toCenter = uv - glassCenter;
    float dist = length(toCenter);

    if (dist < glassRadius) {
        float normalizedDist = dist / glassRadius;
        float distortionAmount = (1.0 - normalizedDist * normalizedDist);
        float2 refractedOffset = toCenter * distortionAmount * refraction;

        // Base refracted position (green channel)
        float2 refractedPos = position - refractedOffset * size;
        half4 refractedColor = layer.sample(refractedPos);

        // Chromatic split: offset R and B slightly more/less
        float chromaticStrength = normalizedDist * 0.1;
        float2 redPos  = position - refractedOffset * size * (1.0 + chromaticStrength);
        float2 bluePos = position - refractedOffset * size * (1.0 - chromaticStrength);

        refractedColor.r = layer.sample(redPos).r;
        refractedColor.b = layer.sample(bluePos).b;

        return refractedColor;
    }

    return layer.sample(position);
}


// =============================================================================
//  STEP 4 — Edge highlight (Fresnel)
//  Goal: add a highlight around the edge of the glass for realism.
//
//  In real optics, light reflects more at glancing angles (Fresnel effect).
//  We approximate this: brightness increases toward the edge of the circle.
//
//  Also adds smooth blending at the glass boundary so it doesn't
//  cut off sharply against the background.
// =============================================================================
[[stitchable]]
half4 glass_step4_fresnel(float2 position, SwiftUI::Layer layer,
                          float2 size, float2 glassCenter,
                          float glassRadius, float refraction)
{
    float2 uv = position / size;
    float2 toCenter = uv - glassCenter;
    float dist = length(toCenter);

    half4 original = layer.sample(position);

    if (dist < glassRadius) {
        float normalizedDist = dist / glassRadius;
        float distortionAmount = (1.0 - normalizedDist * normalizedDist);
        float2 refractedOffset = toCenter * distortionAmount * refraction;

        // Refracted sample with chromatic aberration
        float2 refractedPos = position - refractedOffset * size;
        half4 refractedColor = layer.sample(refractedPos);

        float chromaticStrength = normalizedDist * 0.1;
        float2 redPos  = position - refractedOffset * size * (1.0 + chromaticStrength);
        float2 bluePos = position - refractedOffset * size * (1.0 - chromaticStrength);
        refractedColor.r = layer.sample(redPos).r;
        refractedColor.b = layer.sample(bluePos).b;

        // Fresnel highlight — stronger at edge
        float fresnel = pow(normalizedDist, 2.0);
        float highlight = smoothstep(0.8, 0.9, fresnel) * 0.3;
        refractedColor.rgb += half3(highlight);

        // Smooth edge blending
        float edgeBlend = smoothstep(glassRadius - 0.01, glassRadius, dist);
        return mix(refractedColor, original, edgeBlend);
    }

    return original;
}
