import SwiftUI

struct WaveDistortionView: View {

    @State private var touchPosition: CGPoint = CGPoint(x: 200, y: 300)
    @State private var touchTime: Date = .now
    @State private var amplitude: Float = 3.0
    @State private var frequency: Float = 18.0
    @State private var damping: Float = 3.0

    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.animation) { context in
                let time = Float(context.date.timeIntervalSince(touchTime))

                Image(.samplePhoto)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 12))
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                touchPosition = value.location
                                touchTime = .now
                            }
                    )
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
}

#Preview {
    WaveDistortionView()
        .preferredColorScheme(.dark)
}
