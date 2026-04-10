import SwiftUI

struct DottedBackgroundView: View {

    @State private var touchPosition: CGPoint = .zero
    @State private var mode: ShaderMode = .glow

    var body: some View {
        VStack(spacing: 0) {

            Color.black
                .visualEffect { [touchPosition, mode] content, geo in
                    content.colorEffect(
                        ShaderLibrary.dot_background(
                            .float2(geo.size.width, geo.size.height),
                            .float2(touchPosition.x, touchPosition.y),
                            .float(Float(mode.rawValue))
                        )
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

            Picker("Mode", selection: $mode) {
                ForEach(ShaderMode.allCases) { m in
                    Text(m.label).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}

enum ShaderMode: Int, CaseIterable, Identifiable {
    case glow       = 0
    case repulsion  = 1
    case attraction = 2

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .glow:       "Glow"
        case .repulsion:  "Repulsion"
        case .attraction: "Attraction"
        }
    }
}

#Preview {
    DottedBackgroundView()
        .preferredColorScheme(.dark)
}
