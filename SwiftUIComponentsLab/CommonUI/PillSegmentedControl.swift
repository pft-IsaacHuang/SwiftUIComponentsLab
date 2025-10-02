//
//  PillSegmentedControl.swift
//  YouPerfect
//
//  Created by Isaac Huang on 2025/9/26.
//  Copyright © 2025 PerfectCorp. All rights reserved.
//

import SwiftUI

/// A reusable two-option segmented control with a sliding pill highlight.
/// - selection: 0 selects the left option, 1 selects the right option.
struct PillSegmentedControl: View {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 16 : 20) var height: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 14 : 10) var fontSize: CGFloat

    let leftTitle: String
    let rightTitle: String
    @Binding var selection: Int

    private var accentColor: Color { Color(red: 25/255, green: 199/255, blue: 148/255) }
    private var textFont: Font { .system(size: fontSize, weight: .regular) }

    var body: some View {
        GeometryReader { geo in
            let cornerRadius = height / 2
            let segmentWidth = geo.size.width / 2
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: "#565656"))
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(accentColor)
                    .frame(width: segmentWidth, height: height)
                    .offset(x: selection == 0 ? 0 : segmentWidth)
                    .animation(.spring(response: 0.22, dampingFraction: 0.95), value: selection)
                HStack(spacing: 0) {
                    Button(action: { if selection != 0 { selection = 0 } }) {
                        Text(leftTitle)
                            .font(textFont)
                            .frame(width: segmentWidth, height: height)
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.plain)
                    Button(action: { if selection != 1 { selection = 1 } }) {
                        Text(rightTitle)
                            .font(textFont)
                            .frame(width: segmentWidth, height: height)
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: height)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
        .overlay(
            RoundedRectangle(cornerRadius: height / 2)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
