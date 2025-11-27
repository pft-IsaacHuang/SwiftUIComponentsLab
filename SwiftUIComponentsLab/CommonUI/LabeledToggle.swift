//
//  LabeledToggle.swift
//  YouPerfect
//
//  Created by Isaac Huang on 2025/9/23.
//  Copyright © 2025 PerfectCorp. All rights reserved.
//

import SwiftUI

struct LabeledToggle: View {
    let title: String
    let isOn: Binding<Bool>
    let isDisabled: Bool
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 11 : 11) var fontSize: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Toggle("", isOn: isOn)
                .toggleStyle(LabeledToggleStyle())
                .disabled(isDisabled)
            Text(title)
                .foregroundStyle(.white)
                .font(.system(size: fontSize, weight: .regular))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(.horizontal, IS_IPAD ? 6 : 6)
    }
}

struct LabeledToggleStyle: ToggleStyle {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 38.5 : 42.5) var width: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 18 : 20) var height: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 13 : 13) var cornerRadius: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1) var circlePadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 8 : 8) var fontSize: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(configuration.isOn ? Color(hex: "01B37B") : Color(hex: "797979"))
                .frame(width: width, height: height)
                .overlay(
                    ZStack {
                        // ON/OFF label positioned to avoid the thumb
                        HStack(spacing: 0) {
                            if configuration.isOn {
                                Text(verbatim: "ON")
                                    .font(.system(size: fontSize, weight: .regular))
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, height * 0.3)
                                Spacer(minLength: 0)
                            } else {
                                Spacer(minLength: 0)
                                Text(verbatim: "OFF")
                                    .font(.system(size: fontSize, weight: .regular))
                                    .foregroundStyle(Color.white)
                                    .padding(.trailing, height * 0.22)
                            }
                        }
                        // Thumb above label
                        Circle()
                            .fill(Color.white)
                            .padding(circlePadding)
                            .offset(x: configuration.isOn ? (width - height) / 2 : -((width - height) / 2))
                            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    }
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
