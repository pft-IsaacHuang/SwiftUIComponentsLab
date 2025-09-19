//
//  CustomSlider.swift
//  YouPerfect
//
//  Created by KimWu on 2024/7/9.
//  Copyright © 2024 PerfectCorp. All rights reserved.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let trackHeight: CGFloat
    let thumbDiameter: CGFloat
    var trackAccentColor: Color = Color.init(red: 23 / 255, green: 255 / 255, blue: 193 / 255)
    var unfilledTrackColor: LinearGradient = LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
    let thumbColor: Color = .white
    var enableSnappingMiddle = false
    var snappingThresholdPercentage: CGFloat? = nil
    var onBegin: ((CGFloat)->())? = nil
    var onChanged: ((CGFloat)->())? = nil
    var onEnded: ((CGFloat)->())? = nil
    @State var isDragBegin = false
    // New optional midpoint controls (backward-compatible defaults)
    var fillFromMidpoint: Bool = false
    var midpointValue: CGFloat? = nil // defaults to range midpoint
    var showMidpointDot: Bool = false
    var midpointDotDiameter: CGFloat = 6
    var midpointDotColor: Color = .white
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(unfilledTrackColor)
                    .frame(height: trackHeight)
                
                // Filled Track
                let t = normalizedValue()
                if fillFromMidpoint {
                    let m = normalizedMidpoint()
                    let startX = min(t, m) * geometry.size.width
                    let width = abs(t - m) * geometry.size.width
                    Capsule()
                        .fill(trackAccentColor)
                        .frame(width: max(0, width), height: trackHeight)
                        .offset(x: startX)
                } else {
                    Capsule()
                        .fill(trackAccentColor)
                        .frame(width: t * geometry.size.width, height: trackHeight)
                }
                
                // Midpoint indicator (optional)
                if showMidpointDot {
                    let mid = normalizedMidpoint()
                    Circle()
                        .fill(midpointDotColor)
                        .frame(width: midpointDotDiameter, height: midpointDotDiameter)
                        .offset(x: mid * geometry.size.width - midpointDotDiameter / 2)
                }
                
                // Touch area (visual guide, interaction handled by ZStack gesture)
                Capsule()
                    .fill(Color.gray.opacity(0.0001)) // Keep a minimal fill to ensure ZStack hit testing works correctly
                    .frame(height: thumbDiameter)
                
                // Thumb
                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .offset(x: t * geometry.size.width - thumbDiameter / 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0) // Start immediately on touch
                    .onChanged { gesture in
                        self.updateValue(with: gesture.location.x, in: geometry.size.width)
                        if isDragBegin == false {
                            isDragBegin = true
                            (onBegin ?? onChanged)?(self.value)
                        } else {
                            onChanged?(self.value)
                        }
                    }
                    .onEnded { gesture in
                        isDragBegin = false
                        self.updateValue(with: gesture.location.x, in: geometry.size.width)
                        onEnded?(self.value)
                    }
            )
        }
        .frame(height: thumbDiameter)
    }
    
    private func updateValue(with locationX: CGFloat, in totalWidth: CGFloat) {
        let progress = locationX / totalWidth
        let newValue = progress * (range.upperBound - range.lowerBound) + range.lowerBound
        let midValue = midpointValue ?? (range.upperBound + range.lowerBound) / 2
        let defaultThreshold: CGFloat = 0.0075
        let midThreshold = (range.upperBound - range.lowerBound) * (snappingThresholdPercentage ?? defaultThreshold) // snapping zone
        
        if abs(newValue - midValue) < midThreshold, enableSnappingMiddle {
            self.value = midValue
        } else {
            self.value = min(max(newValue, range.lowerBound), range.upperBound)
        }
    }
    
    private func normalizedValue() -> CGFloat {
        return (self.value - self.range.lowerBound) / (self.range.upperBound - self.range.lowerBound)
    }
    
    private func normalizedMidpoint() -> CGFloat {
        let midVal = midpointValue ?? (range.upperBound + range.lowerBound) / 2
        return (midVal - self.range.lowerBound) / (self.range.upperBound - self.range.lowerBound)
    }
}
