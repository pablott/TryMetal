#include <metal_stdlib>
using namespace metal;

// =============================================================================
//  ImageFilters.metal
//  SwiftUI + Metal Shaders Workshop — Color Effects
//
//    [[stitchable]] half4 name(float2 position, half4 color, args...)
//
//  Unlike the procedural example (DottedBackground), here we USE the `color`
//  input — the original pixel color from the image — and transform it.
//  This is what makes these true "color effects."
// =============================================================================


// =============================================================================
//  Color space helpers — treat these as black boxes.
//  They convert between RGB and HSB (Hue, Saturation, Brightness).
// =============================================================================

/// RGB → HSB. Returns half3(hue, saturation, brightness) where hue is 0–1.
half3 color_rgbToHsb(half3 c)
{
    half maxC = max(c.r, max(c.g, c.b));
    half minC = min(c.r, min(c.g, c.b));
    half delta = maxC - minC;

    half hue = 0.0h;
    if (delta > 0.0h) {
        if (maxC == c.r)      hue = fmod((c.g - c.b) / delta, 6.0h) / 6.0h;
        else if (maxC == c.g) hue = ((c.b - c.r) / delta + 2.0h) / 6.0h;
        else                  hue = ((c.r - c.g) / delta + 4.0h) / 6.0h;
        if (hue < 0.0h) hue += 1.0h;
    }

    half sat = (maxC > 0.0h) ? (delta / maxC) : 0.0h;
    return half3(hue, sat, maxC);
}

/// HSB → RGB. Expects half3(hue, saturation, brightness) where hue is 0–1.
half3 color_hsbToRgb(half3 hsb)
{
    half c = hsb.z * hsb.y;
    half x = c * (1.0h - abs(fmod(hsb.x * 6.0h, 2.0h) - 1.0h));
    half m = hsb.z - c;

    half3 rgb;
    half h6 = hsb.x * 6.0h;
    if      (h6 < 1.0h) rgb = half3(c, x, 0.0h);
    else if (h6 < 2.0h) rgb = half3(x, c, 0.0h);
    else if (h6 < 3.0h) rgb = half3(0.0h, c, x);
    else if (h6 < 4.0h) rgb = half3(0.0h, x, c);
    else if (h6 < 5.0h) rgb = half3(x, 0.0h, c);
    else                 rgb = half3(c, 0.0h, x);

    return rgb + m;
}


// =============================================================================
//  STEP 0 — Passthrough
//  Goal: understand the color effect signature.
//  Just return the original color — the image is unchanged.
// =============================================================================
[[stitchable]]
half4 color_step0_passthrough(float2 position, half4 color, float amount)
{
    return color;
}


// =============================================================================
//  STEP 1 — Grayscale (hardcoded)
//  Goal: convert to grayscale using a dot product with luminance weights.
//
//  The human eye is more sensitive to green, less to blue.
//  These weights (0.2126, 0.7152, 0.0722) are the ITU-R BT.709 standard.
//
//  dot(rgb, weights) = R*0.2126 + G*0.7152 + B*0.0722
// =============================================================================
[[stitchable]]
half4 color_step1_grayscale(float2 position, half4 color, float amount)
{
    half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
    return half4(half3(luma), color.a);
}


// =============================================================================
//  STEP 2 — Grayscale with intensity
//  Goal: use the `amount` uniform to mix between original and grayscale.
//
//  mix(a, b, t) = a * (1-t) + b * t
//  When amount=0 → original, amount=1 → full grayscale
// =============================================================================
[[stitchable]]
half4 color_step2_grayscale_amount(float2 position, half4 color, float amount)
{
    half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
    half3 gray = half3(luma);
    return half4(mix(color.rgb, gray, half(amount)), color.a);
}


// =============================================================================
//  STEP 3 — Sepia
//  Goal: create a warm brownish tone.
//
//  Same as grayscale, but we tint the result: multiply each channel
//  by a different factor to push it toward warm brown.
//  R × 1.2 (warmer), G × 1.0 (neutral), B × 0.8 (cooler tones removed)
// =============================================================================
[[stitchable]]
half4 color_step3_sepia(float2 position, half4 color, float amount)
{
    half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
    half3 sepiaColor = half3(luma * 1.2, luma * 1.0, luma * 0.8);
    return half4(mix(color.rgb, sepiaColor, half(amount)), color.a);
}


// =============================================================================
//  STEP 4 — Hue Shift
//  Goal: rotate the hue of every pixel.
//
//  Using the rgbToHsb / hsbToRgb helpers above:
//    1. Convert to HSB
//    2. Add the angle to hue (fract wraps 0–1)
//    3. Convert back to RGB
// =============================================================================
[[stitchable]]
half4 color_step4_hueShift(float2 position, half4 color, float angle)
{
    half3 hsb = color_rgbToHsb(color.rgb);
    hsb.x = fract(hsb.x + half(angle / (2.0 * M_PI_F)));
    return half4(color_hsbToRgb(hsb), color.a);
}
