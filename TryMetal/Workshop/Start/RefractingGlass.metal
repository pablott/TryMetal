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

    half4 original = layer.sample(position);

    if (dist < glassRadius) {
        // Inside the glass — tint blue to visualise the region
        return mix(original, half4(0.2, 0.4, 1.0, 1.0), 0.4);
    }

    return original;
}
