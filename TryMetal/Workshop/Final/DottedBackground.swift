import SwiftUI

struct FinalDottedBackgroundView: View {

    @State private var touchPosition: CGPoint = .zero
    @State private var mode: FinalShaderMode = .glow

    var body: some View {
        VStack(spacing: 0) {

            Color.red
//                .aspectRatio(1, contentMode: .fit)
                .visualEffect { [touchPosition, mode] content, geo in
                    content.colorEffect(

//                        ShaderLibrary.dot_step0_black(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(0, 0),
//                            .float(0)
//                        )

//                        ShaderLibrary.dot_step1_circle(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(0, 0),
//                            .float(0)
//                        )

//                        ShaderLibrary.dot_step2_grid(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(0, 0),
//                            .float(0)
//                        )

                        // From step 3: touch position is live
//                        ShaderLibrary.dot_step3_touch(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(touchPosition.x, touchPosition.y),
//                            .float(0)
//                        )

                        ShaderLibrary.dot_step4_glow(
                            .float2(geo.size.width, geo.size.height),
                            .float2(touchPosition.x, touchPosition.y),
                            .float(0)
                        )

//                        ShaderLibrary.dot_step5_repulsion(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(touchPosition.x, touchPosition.y),
//                            .float(0)
//                        )

//                        ShaderLibrary.dot_step6_attraction(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(touchPosition.x, touchPosition.y),
//                            .float(0)
//                        )
                        
                        // Step 7: mode picker is now wired up
//                        ShaderLibrary.dot_step7_toggle(
//                            .float2(geo.size.width, geo.size.height),
//                            .float2(touchPosition.x, touchPosition.y),
//                            .float(Float(mode.rawValue))
//                        )

                    )
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { touchPosition = $0.location }
                )
                #if os(macOS)
                .onContinuousHover { phase in
                    if case .active(let location) = phase {
                        touchPosition = location
                    }
                }
                #endif

            // Mode picker — only relevant at step 7
            Picker("Mode", selection: $mode) {
                ForEach(FinalShaderMode.allCases) { m in
                    Text(m.label).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}

enum FinalShaderMode: Int, CaseIterable, Identifiable {
    case glow       = 0
    case repulsion  = 1
    case attraction = 2

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .glow:       return "Glow"
        case .repulsion:  return "Repulsion"
        case .attraction: return "Attraction"
        }
    }
}

#Preview {
    FinalDottedBackgroundView()
        .preferredColorScheme(.dark)
}
