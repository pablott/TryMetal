//
//  ColorShader.metal
//  TryMetal
//
//  Created by Pablo Trabajos on 2026/04/12.
//

#include <metal_stdlib>
#include "ColorHelpers.h"
using namespace metal;

[[ stitchable ]] half4 filters(
                               float2 position,
                               half4 color,
                               float amount)
{
    
//    float r = color.r * 0.2;
//    float g = color.g * 0.8;
//    float b = color.b * 0.6;
//    float final = r + g + b;
//    return half4(final, final, final, 1);

    
    float finalBW = dot(half3(color.x, color.y, color.z), half3(0.2, 0.8, 0.6));
    
    half4 final = mix(color, half4(finalBW), amount);
    return final;
}



[[ stitchable ]] half4 hsb(
                               float2 position,
                               half4 color,
                               float amount)
{
//     float finalBW = dot(half3(color.x, color.y, color.z), half3(0.2, 0.8, 0.6));

//    half4 final = mix(color, half4(finalBW), amount);
//    return final;
    
    half3 hsb = rgbToHsb(half3(color.x, color.y, color.z));
    hsb.x *= amount;
    
    return half4(hsbToRgb(half3(hsb.x, hsb.y, hsb.z)), 1.0);
}
