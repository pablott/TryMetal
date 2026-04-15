#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]]
half4 glassCircle(float2 position, SwiftUI::Layer layer,
                  float2 size, float2 glassCenter,
                  float glassRadius, float refraction)
{
    float2 uv = position / size;
    float dist = length(uv - glassCenter);
    float2 toCenter = uv - glassCenter;
    half4 color = layer.sample(position);

    // Blue circle
//    half4 original = layer.sample(position);
//    if (dist < glassRadius) {
//        // Inside the glass — tint blue to visualise the region
//        return mix(original, half4(0.2, 0.4, 1.0, 1.0), 0.4);
//    }


    // Magnifier
    if (dist < glassRadius) {
        // Non-parabolic
//        float2 magnified  = position - (toCenter * refraction * size);
        
        // Parabolic
        float glassUV  = dist / glassRadius;
        float distortionAmount = (1.0 - glassUV * glassUV);
        float2 refractedOffset = toCenter * distortionAmount * refraction;

        float2 magnified  = position - (refractedOffset * size);
        return layer.sample(magnified);
    }

    return color;
}
