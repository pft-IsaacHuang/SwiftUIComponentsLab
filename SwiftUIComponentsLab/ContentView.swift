//
//  ContentView.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/8/18.
//

import SwiftUI

struct ContentView: View {
    @State private var sliderValue: Int = 0
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Quantized Snapping Slider Demo")
                .font(.title2)
            
            Text("Selected: \(sliderValue)")
                .font(.headline)
            
            LevelSlider(
                value: $sliderValue,
                ticks: 4,
                isEnabled: true,
                onCommit: { newValue in
                    print("Committed value: \(newValue)")
                }
            )
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
