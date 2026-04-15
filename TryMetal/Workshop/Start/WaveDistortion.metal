#include <metal_stdlib>
using namespace metal;


[[stitchable]]
float2 jelly(float2 position, float2 size, float time,
             float2 touch,
             float amplitude, float frequency, float damping,
             float mode)
{
    float2 uv = position / size;
    float2 touchUV = touch / size;
    float2 delta = uv - touchUV;
    float dist = length(uv - touchUV);
    float spatial = 1.0 - smoothstep(0.0, 0.6, dist);

//    float2 dir = (dist > 0.001) ? normalize(uv - touchUV) : float2(0.0 -1.0);
//    float2 wobble = sin(time * frequency) * amplitude * dir;
//    float2 offset = wobble * spatial * amplitude;
    
    
    // '* spatial' makes the effect more localized on the touch position
    float2 offset = exp(-time * damping) * sin(time * frequency) * amplitude * normalize(uv- touchUV) * spatial;

    return position + offset * size * 0.05;
    // adding clamp makes the movement jerky
//    return position + clamp(offset, 0.1, 0.3) * size * 0.05;

}
