#include <metal_stdlib>
using namespace metal;


[[stitchable]]
float2 jelly(float2 position, float2 size, float time,
             float2 touch,
             float amplitude, float frequency, float damping,
             float mode)
{
    return position;
}
