//
//  CustomStyle.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/9/22.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 38.5 : 42.5) var width: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 18 : 20) var height: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 13 : 13) var cornerRadius: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1) var circlePadding: CGFloat
    
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
                                Text("ON")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, height * 0.28)
                                Spacer(minLength: 0)
                            } else {
                                Spacer(minLength: 0)
                                Text("OFF")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                    .padding(.trailing, height * 0.28)
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
