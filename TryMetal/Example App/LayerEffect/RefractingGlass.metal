#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]] half4 glassEffect(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 glassCenter,     // Center of glass shape in UV (0-1)
    float glassRadius,      // Radius in UV space (0-0.5)
    float refraction,       // Refraction strength (0.5-2.0)
    float shadowOffset,     // Shadow offset distance (0.01-0.05)
    float shadowBlur        // Shadow blur amount (0.02-0.1)
) {
    float2 uv = position / size;
    
    // Distance from glass center
    float2 toCenter = uv - glassCenter;
    float dist = length(toCenter);
    
    // Sample the original layer first
    half4 originalColor = layer.sample(position);
    half4 result = originalColor;
    
    // Calculate shadow ONLY for areas outside the glass
    float2 shadowCenter = glassCenter + float2(shadowOffset * 0.7, shadowOffset);
    float2 toShadowCenter = uv - shadowCenter;
    float shadowDist = length(toShadowCenter);
    
    // Apply shadow only if we're NOT inside the glass shape
    if (dist > glassRadius) {
        float shadowRadius = glassRadius + shadowBlur;
        if (shadowDist < shadowRadius) {
            float normalizedShadowDist = (shadowDist - glassRadius) / shadowBlur;
            float shadow = smoothstep(1.0, 0.0, normalizedShadowDist) * 0.025;
            result = mix(originalColor, half4(0.0, 0.0, 0.0, 1.0), shadow);
        }
    }
    
    // Now apply glass effect if we're inside the glass shape
    if (dist < glassRadius) {
        // Normalize distance within glass
        float normalizedDist = dist / glassRadius;
        
        // Parabolic distortion for lens effect
        // Stronger in center, weaker at edges
        float distortionAmount = (1.0 - normalizedDist * normalizedDist);
        
        // Create refraction offset - this creates the magnifying glass effect
        float2 refractedOffset = toCenter * distortionAmount * refraction;
        
        // Sample with refraction
        float2 refractedPos = position - refractedOffset * size;
        half4 refractedColor = layer.sample(refractedPos);
        
        // Chromatic aberration - split RGB channels
        float chromaticStrength = normalizedDist * 0.1;
        
        float2 redPos = position - refractedOffset * size * (1.0 + chromaticStrength);
        float2 bluePos = position - refractedOffset * size * (1.0 - chromaticStrength);
        
        half4 redSample = layer.sample(redPos);
        half4 blueSample = layer.sample(bluePos);
        
        refractedColor.r = redSample.r;
        refractedColor.b = blueSample.b;
                
        // Fresnel highlight at edges
        float fresnel = pow(normalizedDist, 2.0);
        float highlight = smoothstep(0.8, 0.9, fresnel) * 0.3;
        refractedColor.rgb += half3(highlight);
        
        // Ensure proper blending at edges
        float edgeBlend = smoothstep(glassRadius - 0.01, glassRadius, dist);
        result = mix(refractedColor, result, edgeBlend);
    }
    
    return result;
}
