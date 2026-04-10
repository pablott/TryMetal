import SwiftUI

struct LabeledSlider: View {

    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
            Slider(value: $value, in: range)
                .tint(.cyan)
        }
    }
}
