import SwiftUI

struct ImageFiltersView: View {

    @State private var amount: Float = 1.0
    @State private var hueAngle: Float = 0.0

    var body: some View {
        VStack(spacing: 0) {

            Image(.samplePhoto)
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 12))
                .padding()

            Spacer()
                .frame(height: 16)

            // Amount slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Amount")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(String(format: "%.2f", amount))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Slider(value: $amount, in: 0...1)
                    .tint(.cyan)
            }
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 16)

            // Hue angle slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Hue Angle")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(String(format: "%.2f", hueAngle))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Slider(value: $hueAngle, in: 0...(2 * .pi))
                    .tint(.cyan)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.black)
    }
}

#Preview {
    ImageFiltersView()
        .preferredColorScheme(.dark)
}
