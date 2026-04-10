import SwiftUI

struct ProceduralEffectView: View {
    @State private var touchPosition: CGPoint = .zero
    @State private var intensity: CGFloat = 0
    @State private var mode: DotMode = .glow

    var body: some View {
        ZStack {
            // Background — interactive dotted shader
            Color.black
                .visualEffect { [touchPosition, mode, intensity] content, geo in
                    content.colorEffect(
                        ShaderLibrary.dottedBackground(
                            .float2(geo.size.width, geo.size.height),
                            .float2(touchPosition.x, touchPosition.y),
                            .float(Float(mode.rawValue)),
                            .float(Float(intensity))
                        )
                    )
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged {
                            touchPosition = $0.location
                            withAnimation(.easeOut(duration: 0.15)) {
                                intensity = 1
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                intensity = 0
                            }
                        }
                )
                #if os(macOS)
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        touchPosition = location
                        intensity = 1
                    case .ended:
                        withAnimation(.easeOut(duration: 0.5)) {
                            intensity = 0
                        }
                    @unknown default:
                        break
                    }
                }
                #endif
                .ignoresSafeArea()

            // Foreground UI
            VStack(spacing: 24) {
                Spacer()

                Text("Procedural")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .textCase(.uppercase)
                    .tracking(4)
                    .foregroundStyle(.cyan)

                Text("Dotted\nBackground")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .shadow(color: .cyan.opacity(0.4), radius: 24)

                Text("A Metal shader generating a\nprocedural dot grid. Move your\nfinger to interact with the dots.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(16)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 10))

                Spacer()

                // Mode indicator
                Text(mode.label)
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                    .contentTransition(.numericText())

                Button("Change Mode", action: cycleMode)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .buttonStyle(.glass)
                    .focusable(false)
                    .padding(.bottom, 24)
            }
            .safeAreaPadding(.top)
            .preferredColorScheme(.dark)
        }
    }

    private func cycleMode() {
        withAnimation(.easeInOut(duration: 0.25)) {
            mode = mode.next
        }
    }
}

#Preview {
    ProceduralEffectView()
        #if os(macOS)
        .frame(width: 500, height: 900)
        #endif
}
