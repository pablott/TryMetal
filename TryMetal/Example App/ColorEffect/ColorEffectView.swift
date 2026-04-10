import SwiftUI

enum ColorFilter: String, CaseIterable, Identifiable {
    case grayscale = "Grayscale"
    case sepia = "Sepia"
    case hueShift = "Hue Shift"

    var id: String { rawValue }
}


struct ColorEffectView: View {

    @State private var filter: ColorFilter = .grayscale
    @State private var amount: Float = 1.0
    @State private var hueAngle: Float = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // Filtered image
            Image(.samplePhoto)
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 20)
                .colorEffect(shaderForCurrentFilter)

            Spacer()
                .frame(height: 32)

            // Filter picker
            Picker("Filter", selection: $filter) {
                ForEach(ColorFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 24)

            // Slider controls
            sliderControls
                .padding(.horizontal, 20)

            Spacer()
        }
        .safeAreaPadding([.top, .bottom], 16)
        .background(Color.black)
        .colorScheme(.dark)
    }

    private var shaderForCurrentFilter: Shader {
        switch filter {
        case .grayscale:
            ShaderLibrary.grayscale(.float(amount))
        case .sepia:
            ShaderLibrary.sepia(.float(amount))
        case .hueShift:
            ShaderLibrary.hueShift(.float(hueAngle))
        }
    }

    @ViewBuilder
    private var sliderControls: some View {
        switch filter {
        case .grayscale:
            LabeledSlider(label: "Intensity", value: $amount, range: 0...1)
        case .sepia:
            LabeledSlider(label: "Intensity", value: $amount, range: 0...1)
        case .hueShift:
            LabeledSlider(label: "Angle", value: $hueAngle, range: 0...(2 * .pi))
        }
    }
}

#Preview {
    ColorEffectView()
        .preferredColorScheme(.dark)
}
