#include <metal_stdlib>
using namespace metal;

[[stitchable]]
half4 dot_background(float2 position, half4 color,
                     float2 size,
                     float2 touch,
                     float mode)
{
    float2 uv = position / size; // x: 0.0-1.0, y: 0.0-1.0
    
    // SDF params
    float cols = 20;
    float2 cellUV = fract(uv * float2(cols, cols)); // multiple dots
//    return(half4(cellUV.x, 0, 0, 1.0);        // single dot
    
    float2 center = (0.5, 0.5);
    float radius = 0.4;
    
    float2 d1 = cellUV - center;
//    float2 d1 = uv - center;
           
//    d1 = float2(d1.x * size.x/size.y, d1.y);  // long form
    d1.y *= size.y / size.x;                    // short form
    
    float distance = radius - length(d1);
    
    
    
    // We need something better than branching,
    // a math function that we can tweak
//    if (distance < radius) {
//        return half4(1);
//    }
    
    // SDF = Signed Distance Functions
    // inside:  1.0
    // edge:    0.0
    // outside: -1.0
    float sdf = smoothstep(-0.1, 0.001, distance);
    
    // Touch
    float2 touchUV = touch / size;
    float touchDistance = 0.4 - length(uv - touchUV);
    sdf *= touchDistance;
    
    
    return half4(sdf, sdf, sdf, 1.0);
    //    return half4(uv.x, 0, uv.y, 1);   // gradient
}
