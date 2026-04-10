import SwiftUI

struct FinalWaveDistortionView: View {

    @State private var touchPosition: CGPoint = CGPoint(x: 200, y: 300)
    @State private var touchTime: Date = .now
    @State private var amplitude: Float = 3.0
    @State private var frequency: Float = 18.0
    @State private var damping: Float = 3.0

    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.animation) { context in
                distortedImage(time: Float(context.date.timeIntervalSince(touchTime)))
            }

            Spacer()
                .frame(height: 16)

            // Controls
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Amplitude")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(String(format: "%.2f", amplitude))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Slider(value: $amplitude, in: 0...6)
                    .tint(.cyan)
            }
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 12)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Speed")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(String(format: "%.2f", frequency))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Slider(value: $frequency, in: 5...40)
                    .tint(.cyan)
            }
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 12)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Damping")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(String(format: "%.2f", damping))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Slider(value: $damping, in: 0.5...8)
                    .tint(.cyan)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.black)
    }

    private func distortedImage(time: Float) -> some View {
        Image(.samplePhoto)
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 12))
            .padding()
            .visualEffect { [touchPosition, amplitude, frequency, damping] content, geo in
                content.distortionEffect(

//                    ShaderLibrary.jelly_step0_passthrough(
//                        .float2(geo.size.width, geo.size.height),
//                        .float(time)
//                    ), maxSampleOffset: CGSize(width: 60, height: 60)

//                    ShaderLibrary.jelly_step1_static(
//                        .float2(geo.size.width, geo.size.height),
//                        .float(time),
//                        .float(amplitude),
//                        .float(frequency)
//                    ), maxSampleOffset: CGSize(width: 60, height: 60)

//                    ShaderLibrary.jelly_step2_animated(
//                        .float2(geo.size.width, geo.size.height),
//                        .float(time),
//                        .float(amplitude),
//                        .float(frequency),
//                        .float(damping)
//                    ), maxSampleOffset: CGSize(width: 60, height: 60)

//                    ShaderLibrary.jelly_step3_touch(
//                        .float2(geo.size.width, geo.size.height),
//                        .float(time),
//                        .float2(touchPosition.x, touchPosition.y),
//                        .float(amplitude),
//                        .float(frequency),
//                        .float(damping)
//                    ), maxSampleOffset: CGSize(width: 60, height: 60)

                    ShaderLibrary.jelly_step4_mode(
                        .float2(geo.size.width, geo.size.height),
                        .float(time),
                        .float2(touchPosition.x, touchPosition.y),
                        .float(amplitude),
                        .float(frequency),
                        .float(damping),
                        .float(0)  // 0 = compress, 1 = expand
                    ), maxSampleOffset: CGSize(width: 60, height: 60)

                )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchPosition = value.location
                        touchTime = .now
                    }
            )
    }
}

#Preview {
    FinalWaveDistortionView()
        .preferredColorScheme(.dark)
}
