#include <metal_stdlib>
using namespace metal;

// =============================================================================
//  DottedBackground.metal
//  SwiftUI + Metal Shaders Workshop
//
//    [[stitchable]] half4 name(float2 position, half4 color, args...)
//
//  • position  — current pixel position in POINTS (injected by SwiftUI)
//  • color     — original pixel color from the SwiftUI view (injected by SwiftUI)
//  • args...   — your uniforms, passed from Swift in order
//
//  SDF convention used throughout:
//    dist = radius - length(...)   → positive inside, negative outside
//    smoothstep(-eps, eps, dist)   → 1 inside, 0 outside
// =============================================================================


// =============================================================================
//  STEP 0 — Boilerplate
//  Goal: understand the function signature. Just return black.
// =============================================================================
[[stitchable]]
half4 dot_step0_black(float2 position, half4 color,
                  float2 size,   // uniform 0 — canvas size in points
                  float2 touch,  // uniform 1 — touch position in points
                  float mode)    // uniform 2 — 0=glow, 1=repulsion, 2=attraction
{
    return half4(0.0, 0.0, 0.0, 1.0);
}


// =============================================================================
//  STEP 1 — SDF circle
//  Goal: draw a single circle at screen centre using a Signed Distance Field.
//
//  dist = radius - length(uv - center)
//  • positive → inside  the circle
//  • zero     → exactly on the edge
//  • negative → outside the circle
// =============================================================================
[[stitchable]]
half4 dot_step1_circle(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float2 center = float2(0.5, 0.5);
    float radius = 0.05;

//    The code produces an oval, based on `size` aspect ratio. To make it a circle,
//    we need to account for size aspect ratio. Example:
//    float2 delta = float2(uv.x - center.x, (uv.y - center.y) * size.y / size.x);
//    float dist = radius - length(delta);
    
    float dist = radius - length(uv - center);
    float circle = smoothstep(-0.005, 0.005, dist);

    return half4(half3(circle), 1.0);
}


// =============================================================================
//  STEP 2 — Grid via fract()
//  Goal: tile the circle into a full dot grid.
//
//  fract(uv * cols) repeats 0→1 across each cell.
//  floor(uv * cols) tells us which cell we are in.
// =============================================================================
[[stitchable]]
half4 dot_step2_grid(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float cols = 20.0;
    float rows = cols * (size.y / size.x);  // keep cells square

    float2 cellUV = fract(uv * float2(cols, rows));
    float radius = 0.15;
    float dist = radius - length(cellUV - 0.5);
    float dot_ = smoothstep(-0.02, 0.02, dist);

    return half4(half3(dot_), 1.0);
}


// =============================================================================
//  STEP 3 — Introduce the touch uniform
//  Goal: visualise the touch position — prove the uniform arrives correctly.
//
//  We draw the dot grid AND a single bright dot at the touch position.
//  No effect on the grid dots yet — that comes in step 4.
// =============================================================================
[[stitchable]]
half4 dot_step3_touch(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float cols = 20.0;
    float rows = cols * (size.y / size.x);

    // Dot grid — same as step 2
    float2 cellUV = fract(uv * float2(cols, rows));
    float dotRadius = 0.15;
    float dotMask = smoothstep(-0.02, 0.02, dotRadius - length(cellUV - 0.5));

    // Touch indicator — a single bright dot at the touch position
    float2 touchUV = touch / size;
    float indicatorRadius = 0.2;
    float indicator = smoothstep(-0.02, 0.02, indicatorRadius - length(uv - touchUV));

    half3 c = half3(dotMask) + half3(0.0, 0.5, 1.0) * indicator;
    return half4(c, 1.0);
}


// =============================================================================
//  STEP 4 — Glow
//  Goal: dots near touch grow larger and brighter.
//
//  Key: use floor() to find each dot's world position, then measure
//  the distance from that dot centre to the touch.
// =============================================================================
[[stitchable]]
half4 dot_step4_glow(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float cols = 20.0;
    float rows = cols * (size.y / size.x);

    float2 scaled = uv * float2(cols, rows);
    float2 cellIndex = floor(scaled);
    float2 dotWorld = (cellIndex + 0.5) / float2(cols, rows);

    float2 touchUV = touch / size;
    float touchDist = length(dotWorld - touchUV);
    float influenceRadius = 0.2;
    float influence = 1.0 - smoothstep(0.0, influenceRadius, touchDist);

    float2 cellUV = fract(scaled);
    float minRadius = 0.12;
    float maxRadius = 0.22;
    float radius = mix(minRadius, maxRadius, influence);
    float dist = radius - length(cellUV - 0.5);
    float dotMask = smoothstep(-0.02, 0.02, dist);

    float brightness = mix(0.25, 1.0, influence);
    return half4(half3(brightness * dotMask), 1.0);
}


// =============================================================================
//  STEP 5 — Repulsion
//  Goal: dots push AWAY from touch.
//
//  Key insight: we don't move dots — we shift the *sample coordinate*
//  before evaluating the SDF.
//
//  To make a dot appear to move AWAY from the touch, we shift the sample
//  point TOWARD the touch (we look at where the dot was, not where it went).
// =============================================================================
[[stitchable]]
half4 dot_step5_repulsion(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float cols = 20.0;
    float rows = cols * (size.y / size.x);

    float2 scaled = uv * float2(cols, rows);
    float2 cellIndex = floor(scaled);
    float2 dotWorld = (cellIndex + 0.5) / float2(cols, rows);

    float2 touchUV = touch / size;
    float2 awayDir = dotWorld - touchUV;
    float touchDist = length(awayDir);
    float2 dir = touchDist > 0.001 ? normalize(awayDir) : float2(0.0);
    float influenceRadius = 0.2;
    float influence = 1.0 - smoothstep(0.0, influenceRadius, touchDist);
    float maxDisplacement = 0.4;

    // Shift sample point TOWARD touch → dot appears to move AWAY
    float2 cellUV = fract(scaled) - dir * (influence * maxDisplacement);
    float radius = 0.12;
    float dist = radius - length(cellUV - 0.5);
    float dotMask = smoothstep(-0.02, 0.02, dist);

    float brightness = mix(0.25, 1.0, 1.0 - influence);
    return half4(half3(brightness * dotMask), 1.0);
}


// =============================================================================
//  STEP 6 — Attraction
//  Goal: dots pull TOWARD touch.
//
//  Identical to step 5 — one sign flip changes everything.
//  Shift sample point AWAY from touch → dot appears to move TOWARD it.
// =============================================================================
[[stitchable]]
half4 dot_step6_attraction(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float cols = 20.0;
    float rows = cols * (size.y / size.x);

    float2 scaled = uv * float2(cols, rows);
    float2 cellIndex = floor(scaled);
    float2 dotWorld = (cellIndex + 0.5) / float2(cols, rows);

    float2 touchUV = touch / size;
    float2 awayDir = dotWorld - touchUV;
    float touchDist = length(awayDir);
    float2 dir = touchDist > 0.001 ? normalize(awayDir) : float2(0.0);
    float influenceRadius = 0.2;
    float influence = 1.0 - smoothstep(0.0, influenceRadius, touchDist);
    float maxDisplacement = 0.4;

    // Shift sample point AWAY from touch → dot appears to move TOWARD it
    float2 cellUV = fract(scaled) + dir * (influence * maxDisplacement);  // ← flipped sign
    float radius = 0.12;
    float dist = radius - length(cellUV - 0.5);
    float dotMask = smoothstep(-0.02, 0.02, dist);

    float brightness = mix(0.25, 1.0, influence);
    return half4(half3(brightness * dotMask), 1.0);
}


// =============================================================================
//  STEP 7 — Toggle all three modes via the `mode` uniform
//  mode == 0 → glow
//  mode == 1 → repulsion
//  mode == 2 → attraction
// =============================================================================
[[stitchable]]
half4 dot_step7_toggle(float2 position, half4 color, float2 size, float2 touch, float mode)
{
    float2 uv = position / size;
    float cols = 20.0;
    float rows = cols * (size.y / size.x);

    float2 scaled = uv * float2(cols, rows);
    float2 cellIndex = floor(scaled);
    float2 dotWorld = (cellIndex + 0.5) / float2(cols, rows);

    float2 touchUV = touch / size;
    float2 awayDir = dotWorld - touchUV;
    float touchDist = length(awayDir);
    float2 dir = touchDist > 0.001 ? normalize(awayDir) : float2(0.0);
    float influenceRadius = 0.2;
    float influence = 1.0 - smoothstep(0.0, influenceRadius, touchDist);
    float maxDisplacement = 0.4;

    float2 cellUV = fract(scaled);
    float radius = 0.12;
    float brightness = 0.25;

    // Why < 0.5 instead of == 0?  GPU floats lack exact integer precision —
    // a value meant to be 0 might arrive as 0.0000001.  Using < 0.5 gives each
    // mode a safe range (0‑0.49, 0.5‑1.49, 1.5+) instead of relying on exact equality.
    if (mode < 0.5) {
        // Glow — dots grow and brighten near touch
        float minRadius = 0.12;
        float maxRadius = 0.22;
        radius = mix(minRadius, maxRadius, influence);
        brightness = mix(0.25, 1.0, influence);

    } else if (mode < 1.5) {
        // Repulsion — sample toward touch, dot appears to move away
        cellUV -= dir * (influence * maxDisplacement);
        brightness = mix(0.25, 1.0, 1.0 - influence);

    } else {
        // Attraction — sample away from touch, dot appears to move toward it
        cellUV += dir * (influence * maxDisplacement);
        brightness = mix(0.25, 1.0, influence);
    }

    float dist = radius - length(cellUV - 0.5);
    float dotMask = smoothstep(-0.02, 0.02, dist);

    return half4(half3(brightness * dotMask), 1.0);
}
