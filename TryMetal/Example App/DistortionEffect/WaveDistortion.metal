#include <metal_stdlib>
using namespace metal;

/// Jelly wobble — the image bounces like jello when touched.
///
/// Modes (passed as float):
///   0 — Compress: pixels push inward on touch, then bounce back
///   1 — Expand:   pixels push outward on touch, then bounce back
[[stitchable]]
float2 jellyDistortion(float2 position,
                       float2 size,
                       float time,
                       float2 touch,
                       float amplitude,
                       float frequency,
                       float damping,
                       float mode)
{
    float2 uv = position / size;
    float2 touchUV = touch / size;

    float2 delta = uv - touchUV;
    float dist = length(delta);
    float spatial = 1.0 - smoothstep(0.0, 0.6, dist);

    float wobble = sin(time * frequency) * exp(-time * damping);

    float2 dir = (dist > 0.001) ? delta / dist : float2(0.0, -1.0);
    float sign = (mode < 0.5) ? -1.0 : 1.0;

    float2 offset = dir * sign * wobble * spatial * amplitude;

    return position + offset * size * 0.05;
}


