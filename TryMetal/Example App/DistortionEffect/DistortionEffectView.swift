import SwiftUI

enum JellyMode: Int, CaseIterable, Identifiable {
    case expand   = 0
    case compress = 1

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .compress: "Compress"
        case .expand:   "Expand"
        }
    }
}

struct DistortionEffectView: View {

    @State private var tapLocation: CGPoint = CGPoint(x: 200, y: 300)
    @State private var tapTime: Date = .now
    @State private var amplitude: Float = 4.0
    @State private var frequency: Float = 18.0
    @State private var damping: Float = 4.0
    @State private var mode: JellyMode = .expand
    @State private var transitionEnabled = false
    @State private var currentImage = 0
    private let images: [ImageResource] = [.samplePhoto, .samplePhoto2]

    private var revealDuration: Double {
        Double(3.0 / damping)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                if transitionEnabled {
                    ForEach(images.indices, id: \.self) { index in
                        if currentImage == index {
                            Image(images[index])
                                .resizable()
                                .scaledToFit()
                                .transition(.circularReveal(from: tapLocation))
                        }
                    }
                } else {
                    Image(images[0])
                        .resizable()
                        .scaledToFit()
                }
            }
            .clipShape(.rect(cornerRadius: 16))
            .modifier(JellyModifier(
                tapTime: tapTime,
                tapLocation: tapLocation,
                amplitude: amplitude,
                frequency: frequency,
                damping: damping,
                mode: mode
            ))
            .padding(.horizontal, 20)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        tapLocation = value.location
                        tapTime = .now
                        if transitionEnabled {
                            withAnimation(.easeInOut(duration: revealDuration)) {
                                currentImage = (currentImage + 1) % images.count
                            }
                        }
                    }
            )

            Spacer()
                .frame(height: 24)

            // Mode picker
            Picker("Mode", selection: $mode) {
                ForEach(JellyMode.allCases) { m in
                    Text(m.label).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 12)

            // Transition toggle
            Toggle("Circular Reveal", isOn: $transitionEnabled)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .tint(.cyan)
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 12)

            // Sliders
            VStack(spacing: 12) {
                LabeledSlider(label: "Amplitude", value: $amplitude, range: 0...8)
                LabeledSlider(label: "Speed", value: $frequency, range: 5...40)
                LabeledSlider(label: "Damping", value: $damping, range: 1...10)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .safeAreaPadding(.top, 16)
        .background(Color.black)
        .colorScheme(.dark)
    }
}

// MARK: - Circular Reveal Transition

struct CircularRevealShape: Shape {
    var center: CGPoint
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let maxRadius = sqrt(pow(rect.width, 2) + pow(rect.height, 2))
        let currentRadius = progress * maxRadius
        var path = Path()
        path.addEllipse(in: CGRect(
            x: center.x - currentRadius,
            y: center.y - currentRadius,
            width: currentRadius * 2,
            height: currentRadius * 2
        ))
        return path
    }
}

struct CircularRevealInsertion: Transition {
    var center: CGPoint

    func body(content: Content, phase: TransitionPhase) -> some View {
        let progress = 1.0 + phase.value
        content
            .clipShape(CircularRevealShape(center: center, progress: progress))
    }
}

extension AnyTransition {
    static func circularReveal(from point: CGPoint) -> AnyTransition {
        .asymmetric(
            insertion: .init(CircularRevealInsertion(center: point)),
            removal: .opacity
        )
    }
}

// MARK: - Jelly Modifier

struct JellyModifier: ViewModifier {
    let tapTime: Date
    let tapLocation: CGPoint
    let amplitude: Float
    let frequency: Float
    let damping: Float
    let mode: JellyMode

    func body(content: Content) -> some View {
        TimelineView(.animation) { context in
            let elapsed = Float(context.date.timeIntervalSince(tapTime))

            content
                .visualEffect { content, geo in
                    content.distortionEffect(
                        ShaderLibrary.jellyDistortion(
                            .float2(geo.size),
                            .float(elapsed),
                            .float2(Float(tapLocation.x), Float(tapLocation.y)),
                            .float(amplitude),
                            .float(frequency),
                            .float(damping),
                            .float(Float(mode.rawValue))
                        ),
                        maxSampleOffset: CGSize(width: 60, height: 60)
                    )
                }
        }
    }
}

#Preview {
    DistortionEffectView()
        .preferredColorScheme(.dark)
}
