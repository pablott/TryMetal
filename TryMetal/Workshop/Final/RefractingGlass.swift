import SwiftUI

struct FinalRefractingGlassView: View {

    @State private var glassPosition: CGPoint = .init(x: 150, y: 200)
    @State private var radius: Float = 0.15
    @State private var refraction: Float = 1.0

    var body: some View {
        VStack(spacing: 0) {
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
            .visualEffect { [radius, refraction, glassPosition] content, proxy in
                let normalizedPosition = CGPoint(
                    x: glassPosition.x / proxy.size.width,
                    y: glassPosition.y / proxy.size.height
                )

                return content
                    .layerEffect(

//                        ShaderLibrary.glass_step0_passthrough(
//                            .float2(proxy.size),
//                            .float2(normalizedPosition.x,
//                                    normalizedPosition.y),
//                            .float(radius),
//                            .float(refraction)
//                        ), maxSampleOffset: .init(width: 150, height: 150)

//                        ShaderLibrary.glass_step1_circle(
//                            .float2(proxy.size),
//                            .float2(normalizedPosition.x,
//                                    normalizedPosition.y),
//                            .float(radius),
//                            .float(refraction)
//                        ), maxSampleOffset: .init(width: 150, height: 150)

//                        ShaderLibrary.glass_step2_magnify(
//                            .float2(proxy.size),
//                            .float2(normalizedPosition.x,
//                                    normalizedPosition.y),
//                            .float(radius),
//                            .float(refraction)
//                        ), maxSampleOffset: .init(width: 150, height: 150)

//                        ShaderLibrary.glass_step3_chromatic(
//                            .float2(proxy.size),
//                            .float2(normalizedPosition.x,
//                                    normalizedPosition.y),
//                            .float(radius),
//                            .float(refraction)
//                        ), maxSampleOffset: .init(width: 150, height: 150)

                        ShaderLibrary.glass_step4_fresnel(
                            .float2(proxy.size),
                            .float2(normalizedPosition.x,
                                    normalizedPosition.y),
                            .float(radius),
                            .float(refraction)
                        ), maxSampleOffset: .init(width: 150, height: 150)

                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { glassPosition = $0.location }
            )
            
            // Controls
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
            .padding()
            
            Spacer()
        }
        .background(Color.white)
    }
}

#Preview {
    FinalRefractingGlassView()
}
