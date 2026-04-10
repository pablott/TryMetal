#include <metal_stdlib>
using namespace metal;

// MARK: - Color space helpers

/// Standard RGB → HSB conversion.
/// Returns half3(hue, saturation, brightness) where hue is 0–1.
half3 rgbToHsb(half3 c)
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

/// Standard HSB → RGB conversion.
/// Expects half3(hue, saturation, brightness) where hue is 0–1.
half3 hsbToRgb(half3 hsb)
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

// MARK: - Shaders

/// Grayscale — converts to luminance using perceptual weights.
/// `amount` controls how much grayscale is applied (0 = original, 1 = full grayscale).
[[stitchable]]
half4 grayscale(float2 position, half4 color, float amount)
{
    half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
    half3 gray = half3(luma);
    return half4(mix(color.rgb, gray, half(amount)), color.a);
}

/// Sepia — warm brownish tone applied over grayscale.
/// `amount` controls intensity (0 = original, 1 = full sepia).
[[stitchable]]
half4 sepia(float2 position, half4 color, float amount)
{
    half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
    half3 sepiaColor = half3(luma * 1.2, luma * 1.0, luma * 0.8);
    return half4(mix(color.rgb, sepiaColor, half(amount)), color.a);
}

/// Hue Shift — rotates the hue of each pixel.
/// `angle` is in radians (0 to 2π for a full rotation).
[[stitchable]]
half4 hueShift(float2 position, half4 color, float angle)
{
    half3 hsb = rgbToHsb(color.rgb);
    hsb.x = fract(hsb.x + half(angle / (2.0 * M_PI_F)));
    return half4(hsbToRgb(hsb), color.a);
}
