import SwiftUI

struct FinalImageFiltersView: View {

    @State private var amount: Float = 1.0
    @State private var hueAngle: Float = 0.0

    var body: some View {
        VStack(spacing: 0) {

            Image(.samplePhoto)
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 12))
                .padding()
                .colorEffect(

                    ShaderLibrary.color_step0_passthrough(
                        .float(amount)
                    )

//                    ShaderLibrary.color_step1_grayscale(
//                        .float(amount)
//                    )

//                    ShaderLibrary.color_step2_grayscale_amount(
//                        .float(amount)
//                    )

//                    ShaderLibrary.color_step3_sepia(
//                        .float(amount)
//                    )

//                    ShaderLibrary.color_step4_hueShift(
//                        .float(hueAngle)
//                    )

                )

            Spacer()
                .frame(height: 16)

            // Amount slider — used by steps 0–3
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

            // Hue angle slider — used by step 4
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
    FinalImageFiltersView()
        .preferredColorScheme(.dark)
}
