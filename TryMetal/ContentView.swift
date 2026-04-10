//
//  ContentView.swift
//  TryMetal
//
//  Created by Victor Baro on 3/21/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Procedural", systemImage: "circle.grid.3x3.fill") {
                ProceduralEffectView()
            }
            Tab("Color", systemImage: "paintbrush.fill") {
                ColorEffectView()
            }
            Tab("Layer", systemImage: "square.3.layers.3d") {
                LayerEffectView()
            }
            Tab("Distortion", systemImage: "drop.fill") {
                DistortionEffectView()
            }
        }
    }
}

#Preview {
    ContentView()
}
