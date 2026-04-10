#include <metal_stdlib>
using namespace metal;

[[stitchable]]
half4 dot_background(float2 position, half4 color,
                     float2 size,
                     float2 touch,
                     float mode)
{
    return half4(0.0, 0.0, 0.0, 1.0);
}
