#include <metal_stdlib>
using namespace metal;

// =============================================================================
//  WaveDistortion.metal
//  SwiftUI + Metal Shaders Workshop — Distortion Effects
//
//    [[stitchable]] float2 name(float2 position, args...)
//
//  Unlike color and layer effects, distortion effects return a float2 —
//  the new position to sample. SwiftUI reads the pixel from that displaced
//  position instead of the original one. This moves/warps content.
//
//  Return `position` unchanged → no distortion (passthrough).
//  Return `position + offset` → content shifts by that offset.
// =============================================================================


// =============================================================================
//  STEP 0 — Passthrough
//  Goal: understand the distortion effect signature.
//  Return the original position — nothing moves.
// =============================================================================
[[stitchable]]
float2 jelly_step0_passthrough(float2 position, float2 size, float time)
{
    return position;
}


// =============================================================================
//  STEP 1 — Static wobble with sin()
//  Goal: use sin() to displace pixels based on their position.
//
//  sin(uv.y * frequency) creates a wave pattern along Y.
//  We use it to offset X → content wiggles horizontally.
//  No animation yet — the wave is frozen.
// =============================================================================
[[stitchable]]
float2 jelly_step1_static(float2 position, float2 size, float time,
                          float amplitude, float frequency)
{
    float2 uv = position / size;

    float offsetX = sin(uv.y * frequency) * amplitude;

    return position + float2(offsetX, 0.0);
}


// =============================================================================
//  STEP 2 — Animated wobble (introduce time)
//  Goal: make it move by using `time` in sin().
//
//  sin(time * frequency) oscillates over time.
//  exp(-time * damping) makes the oscillation decay — a damped spring.
//
//  This is the core formula:  sin(t * freq) * exp(-t * damp)
//  It produces a bounce that settles to zero, like jello.
//
//  On the SwiftUI side, we use TimelineView(.animation) to feed time,
//  and reset `time` to 0 on each new touch so the wobble restarts.
// =============================================================================
[[stitchable]]
float2 jelly_step2_animated(float2 position, float2 size, float time,
                            float amplitude, float frequency, float damping)
{
    // Damped spring oscillation
    float wobble = sin(time * frequency) * exp(-time * damping);

    // Apply as vertical displacement (whole image bounces)
    float offsetY = wobble * amplitude;

    return position + float2(0.0, offsetY) * size * 0.05;
}


// =============================================================================
//  STEP 3 — Touch-driven wobble
//  Goal: make the wobble radiate from the touch position.
//
//  We measure distance from each pixel to the touch point.
//  Pixels near touch wobble strongly, pixels far away barely move.
//  smoothstep creates a smooth falloff radius.
//
//  The direction is away from touch — pixels push outward, then
//  the damped spring pulls them back.
// =============================================================================
[[stitchable]]
float2 jelly_step3_touch(float2 position, float2 size, float time,
                         float2 touch,
                         float amplitude, float frequency, float damping)
{
    float2 uv = position / size;
    float2 touchUV = touch / size;

    // Distance from touch — wobble fades outward
    float dist = length(uv - touchUV);
    float spatial = 1.0 - smoothstep(0.0, 0.6, dist);

    // Damped spring
    float wobble = sin(time * frequency) * exp(-time * damping);

    // Direction: away from touch
    float2 dir = (dist > 0.001) ? normalize(uv - touchUV) : float2(0.0, -1.0);

    float2 offset = dir * wobble * spatial * amplitude;

    return position + offset * size * 0.05;
}


// =============================================================================
//  STEP 4 — Compress / Expand mode
//  Goal: add a mode toggle — compress pushes inward, expand pushes outward.
//
//  The only difference is the sign of the direction.
//  mode 0 (compress): negate direction → pixels push toward touch
//  mode 1 (expand):   keep direction  → pixels push away from touch
//
//  Same < 0.5 pattern we used in the procedural example.
// =============================================================================
[[stitchable]]
float2 jelly_step4_mode(float2 position, float2 size, float time,
                        float2 touch,
                        float amplitude, float frequency, float damping,
                        float mode)
{
    float2 uv = position / size;
    float2 touchUV = touch / size;

    float dist = length(uv - touchUV);
    float spatial = 1.0 - smoothstep(0.0, 0.6, dist);

    float wobble = sin(time * frequency) * exp(-time * damping);

    float2 dir = (dist > 0.001) ? normalize(uv - touchUV) : float2(0.0, -1.0);
    float sign = (mode < 0.5) ? -1.0 : 1.0;

    float2 offset = dir * sign * wobble * spatial * amplitude;

    return position + offset * size * 0.05;
}
