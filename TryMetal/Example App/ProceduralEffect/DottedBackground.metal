#include <metal_stdlib>
using namespace metal;

/// Dot-grid background with three interactive modes driven by touch.
///
/// Modes (passed as float):
///   0 — Glow:       dots near touch grow and brighten
///   1 — Repulsion:  dots push away from touch
///   2 — Attraction: dots pull toward touch
///
/// Samples a 3x3 neighborhood of cells so displaced dots are never clipped
/// at cell boundaries during repulsion/attraction.
[[stitchable]]
half4 dottedBackground(float2 position, half4 color,
                       float2 size,
                       float2 touch,
                       float mode,
                       float intensity)
{
    float2 uv = position / size;
    float cols = 40.0;
    float rows = cols * (size.y / size.x);
    float2 grid = float2(cols, rows);

    float2 scaled = uv * grid;
    float2 currentCell = floor(scaled);

    float2 touchUV = touch / size;
    float aspect = size.y / size.x;
    float influenceRadius = 0.4;
    float maxDisplacement = 0.6;

    float bestBrightness = 0.0;
    float bestDotMask = 0.0;

    // Why 3x3 neighborhood?
    // In the workshop version, each pixel only checks its own cell's dot.
    // That works for glow (dots don't move), but when repulsion/attraction
    // displaces a dot, it can shift into a neighboring cell's territory.
    // Since fract() clips at cell boundaries, the dot gets cut off.
    //
    // The fix: for each pixel, check not just its own cell's dot but also
    // all 8 surrounding cells. If a neighbor's dot has been displaced into
    // our cell, we'll see it. We keep the brightest contribution across
    // all 9 candidates. Cost is 9x more math per pixel, but the GPU
    // handles it fine — this is exactly the kind of parallel brute-force
    // work GPUs are built for.
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            float2 neighbor = currentCell + float2(dx, dy);
            float2 dotWorld = (neighbor + 0.5) / grid;

            float2 awayDir = dotWorld - touchUV;
            float touchDist = length(float2(awayDir.x, awayDir.y * aspect));
            float2 dir = touchDist > 0.001 ? normalize(awayDir) : float2(0.0);
            float influence = (1.0 - smoothstep(0.0, influenceRadius, touchDist)) * intensity;

            // Dot center in scaled space, then apply displacement
            float2 dotCenter = neighbor + 0.5;
            float radius = 0.12;
            float brightness = 0.25;

            if (mode < 0.5) {
                // Glow
                radius = mix(0.12, 0.22, influence);
                brightness = mix(0.25, 1.0, influence);
            } else if (mode < 1.5) {
                // Repulsion — shift dot center away from touch
                dotCenter -= dir * (influence * maxDisplacement);
                brightness = mix(0.25, 1.0, 1.0 - influence);
            } else {
                // Attraction — shift dot center toward touch
                dotCenter += dir * (influence * maxDisplacement);
                brightness = mix(0.25, 1.0, influence);
            }

            float dist = radius - length(scaled - dotCenter);
            float dotMask = smoothstep(-0.02, 0.02, dist);

            // Keep the brightest contribution
            if (dotMask * brightness > bestDotMask * bestBrightness) {
                bestDotMask = dotMask;
                bestBrightness = brightness;
            }
        }
    }

    return half4(half3(bestBrightness * bestDotMask), 1.0);
}
