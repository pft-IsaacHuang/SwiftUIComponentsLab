//
//  FigmaTestBottomView.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/9/23.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct FigmaTestBottomView: View {
    @State private var selectedFocus: OverallFocus = .overall
    @State private var bgProtectOn: Bool = true
    @State private var intensityValue: CGFloat = 0
    // Scaling helper to match 320/480 guideline
    private var isPad: Bool {
        #if canImport(UIKit)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    private var screenWidth: CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.bounds.width
        #else
        return 320
        #endif
    }
    private var guidelineWidth: CGFloat { isPad ? 480 : 320 }
    private func s(_ v: CGFloat) -> CGFloat { screenWidth * (v / guidelineWidth) }
    private var containerWidth: CGFloat { screenWidth }
    private var stackGapSmall: CGFloat { s(5) }
    private var overallHeight: CGFloat { s(18) }
    private var tinyFont: CGFloat { 10 }
    private var panelHeight: CGFloat { s(128) }
    private var toggleBarHeight: CGFloat { s(36) }
    private var pickerItemHeight: CGFloat { s(58) }
    private var pickerItemWidth: CGFloat { s(55) }
    private var underlineHeight: CGFloat { s(2) }
    private var separatorWidth: CGFloat { s(0.6) }
    private var intensityDot: CGFloat { s(16) }
    private let accent = color(0x17FFC1)
    private let darkBG = color(0x171717)
    private let grayText = color(0xC8C8C8)
    
    var body: some View {
        VStack(spacing: stackGapSmall) {
            // Overall selector
            OverallSelector(selected: $selectedFocus, height: overallHeight, separatorWidth: separatorWidth)
                .frame(width: containerWidth, height: overallHeight)
            
            // Intensity indicator (compact)
            intensityBar
                .frame(width: containerWidth, height: 18)
            
            // Toggle row
            HStack(spacing: 8) {
                Toggle("", isOn: $bgProtectOn)
                    .labelsHidden()
                    .toggleStyle(SmallToggleStyle())
                Text("BG Protect")
                    .foregroundStyle(.white)
                    .font(.system(size: 11, weight: .regular))
                Spacer(minLength: 0)
            }
            .frame(width: containerWidth, height: toggleBarHeight)
            
            // Bottom panel
            ZStack(alignment: .bottom) {
                darkBG
                    .frame(width: containerWidth, height: panelHeight)
                VStack(spacing: 8) {
                    featurePicker
                    bottomButtons
                }
                .padding(.bottom, 6)
            }
            .clipShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.09))
    }
    
    private var intensityBar: some View {
        ZStack(alignment: .center) {
            // Track & dot
            GeometryReader { geo in
                let width = geo.size.width
                let leftInset = width * (48.0/320.0) // approximate from figma
                let rightInset = width * (34.0/320.0) // space for trailing label
                let lineWidth = max(0, width - leftInset - rightInset)
                Capsule()
                    .fill(Color.white)
                    .frame(width: lineWidth, height: 1)
                    .offset(x: (leftInset - (width/2 - lineWidth/2)))
                // Dot
                Circle()
                    .fill(Color.white)
                    .frame(width: intensityDot, height: intensityDot)
                    .offset(x: -width/2 + leftInset + intensityDot/2)
            }
            .frame(height: max(18, intensityDot))
            
            HStack {
                Spacer()
                Text("\(Int(intensityValue))")
                    .foregroundStyle(.white)
                    .font(.system(size: tinyFont))
            }
        }
    }
    
    private var featurePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(featureItems) { item in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(color(0xD0D0D0))
                                .frame(width: pickerItemWidth * 0.76, height: pickerItemWidth * 0.76)
                            Image(systemName: item.systemIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: pickerItemWidth * 0.5, height: pickerItemWidth * 0.5)
                                .foregroundStyle(.white)
                        }
                        Text(item.title)
                            .font(.system(size: 9))
                            .foregroundStyle(.white)
                            .frame(width: pickerItemWidth)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(width: pickerItemWidth, height: pickerItemHeight)
                }
            }
            .frame(height: pickerItemHeight)
            .padding(.top, 6)
            .padding(.horizontal, 8)
        }
        .frame(height: pickerItemHeight)
    }
    
    private var bottomButtons: some View {
        HStack {
            // Cancel
            bottomIconButton(system: "xmark") {}
                .frame(width: 44, height: 40)
            Spacer(minLength: 0)
            HStack(spacing: 2) {
                previewButton(opacity: 1.0)
                previewButton(opacity: 0.5)
                swapButton()
                manualShapeButton()
            }
            Spacer(minLength: 0)
            // Confirm
            bottomIconButton(system: "checkmark") {}
                .frame(width: 44, height: 40)
        }
        .padding(.horizontal, 12)
    }
    
    private func bottomIconButton(system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Color.clear
                Image(systemName: system)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func previewButton(opacity: Double) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .opacity(opacity)
            RoundedRectangle(cornerRadius: 4)
                .stroke(color(0xA6A6A6), lineWidth: 1)
                .opacity(opacity)
        }
        .frame(width: 44.33, height: 39.6)
    }
    
    private func swapButton() -> some View {
        ZStack {
            Color.clear
            Image(systemName: "arrow.left.arrow.right")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 18)
                .foregroundStyle(.white)
        }
        .frame(width: 44, height: 39.31)
    }
    
    private func manualShapeButton() -> some View {
        ZStack {
            color(0xB7B7B7)
            Image(systemName: "square.on.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
        }
        .frame(width: 44, height: 39.31)
    }
    
    private var featureItems: [FeatureItem] {
        [
            .init(id: 0, title: "Enhancer", systemIcon: "sparkles"),
            .init(id: 1, title: "Slim", systemIcon: "figure.arms.open"),
            .init(id: 2, title: "Waist", systemIcon: "figure.stand"),
            .init(id: 3, title: "Arms", systemIcon: "hand.raised"),
            .init(id: 4, title: "Shoulder", systemIcon: "person"),
            .init(id: 5, title: "Neck", systemIcon: "person.crop.circle"),
            .init(id: 6, title: "Chest", systemIcon: "heart"),
            .init(id: 7, title: "Legs", systemIcon: "figure.walk"),
            .init(id: 8, title: "Width", systemIcon: "arrow.left.and.right"),
            .init(id: 9, title: "Hip", systemIcon: "figure.stand"),
            .init(id: 10, title: "Protect", systemIcon: "shield")
        ]
    }
}

#Preview {
    FigmaTestBottomView()
}

// MARK: - Subviews & Models

private enum OverallFocus: CaseIterable { case left, overall, right }

private struct OverallSelector: View {
    @Binding var selected: OverallFocus
    let height: CGFloat
    let separatorWidth: CGFloat
    private let accent = color(0x17FFC1)
    private let darkBG = color(0x171717).opacity(0.7)
    private let grayText = color(0xC8C8C8)
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(darkBG)
            HStack(spacing: 4) {
                focusText("Left", isActive: selected == .left)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { selected = .left }
                Rectangle()
                    .fill(color(0xABABAB))
                    .frame(width: separatorWidth, height: height * 0.55)
                focusText("Overall", isActive: selected == .overall)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { selected = .overall }
                Rectangle()
                    .fill(color(0xABABAB))
                    .frame(width: separatorWidth, height: height * 0.55)
                focusText("Right", isActive: selected == .right)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { selected = .right }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private func focusText(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(isActive ? accent : grayText)
    }
}

private struct FeatureItem: Identifiable {
    let id: Int
    let title: String
    let systemIcon: String
}

// Local color helper to avoid module ambiguity with init(hex:)
private func color(_ hex: UInt32, alpha: Double = 1.0) -> Color {
    let r = Double((hex >> 16) & 0xFF) / 255.0
    let g = Double((hex >> 8) & 0xFF) / 255.0
    let b = Double(hex & 0xFF) / 255.0
    return Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
}

// Minimal toggle style to match compact dimensions
private struct SmallToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPad: Bool = {
            #if canImport(UIKit)
            return UIDevice.current.userInterfaceIdiom == .pad
            #else
            return false
            #endif
        }()
        let screenW: CGFloat = {
            #if canImport(UIKit)
            return UIScreen.main.bounds.width
            #else
            return 320
            #endif
        }()
        let base: CGFloat = isPad ? 480 : 320
        let width = screenW * ((isPad ? 38.5 : 42.5) / base)
        let height = screenW * ((isPad ? 18 : 20) / base)
        let cornerRadius = screenW * ((isPad ? 13 : 13) / base)
        let circlePadding = screenW * ((isPad ? 1 : 1) / base)
        
        return HStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(configuration.isOn ? color(0x01B37B) : color(0x797979))
                .frame(width: width, height: height)
                .overlay(
                    ZStack {
                        HStack(spacing: 0) {
                            if configuration.isOn {
                                Text("ON")
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, height * 0.28)
                                Spacer(minLength: 0)
                            } else {
                                Spacer(minLength: 0)
                                Text("OFF")
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                    .padding(.trailing, height * 0.28)
                            }
                        }
                        Circle()
                            .fill(Color.white)
                            .padding(circlePadding)
                            .offset(x: configuration.isOn ? (width - height) / 2 : -((width - height) / 2))
                            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    }
                )
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
