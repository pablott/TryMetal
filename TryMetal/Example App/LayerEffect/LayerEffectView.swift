import SwiftUI

struct LayerEffectView: View {
    @State private var glassPosition: CGPoint = .init(x: 150, y: 200)
    
    // Customizable parameters
    @State private var radius: Float = 0.15
    @State private var refraction: Float = 1
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.black)
                    .padding()
                
                Text("Glass")
                    .font(.system(size: 82))
                    .foregroundStyle(.white)
                    .bold()
            }
            .aspectRatio(1, contentMode: .fit)
            .visualEffect{ [radius, refraction, glassPosition] content, proxy in
                let normalizedPosition = CGPoint(
                    x: glassPosition.x / proxy.size.width,
                    y: glassPosition.y / proxy.size.height
                )
                
                return content
                    .layerEffect(ShaderLibrary.glassEffect(
                        .float2(proxy.size),
                        .float2(normalizedPosition.x,
                                normalizedPosition.y),
                        .float(radius),
                        .float(refraction),
                        .float(0.01),
                        .float(0.1)
                    ), maxSampleOffset: .init(width: 150, height: 150))
            }
            
            .onTapGesture { location in
                withAnimation(.easeInOut(duration: 0.2)) {
                    glassPosition = location
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        glassPosition = value.location
                    }
            )
            ControlPanel(
                radius: $radius,
                refraction: $refraction
            )
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    LayerEffectView()
        .preferredColorScheme(.dark)
}




struct ControlPanel: View {
    @Binding var radius: Float
    @Binding var refraction: Float
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main controls
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Radius")
                        .font(.caption)
                    Slider(value: $radius, in: 0...0.5)
                }
                
                HStack {
                    Text("Refraction")
                        .font(.caption)
                    
                    Slider(value: $refraction, in: 0...2)
                }
            }
            .frame(width: 320)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding()
        }
    }
}
