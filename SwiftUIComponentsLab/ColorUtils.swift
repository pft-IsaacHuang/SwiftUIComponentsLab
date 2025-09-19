//
//  ColorUtils.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/8/18.
//

import Foundation
import SwiftUI

// MARK: - Color helper
public extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

public extension SwiftUI.Color {
    init(hex: String) {
        let (red, green, blue, opacity) = colorValueFromHex(hex)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}

private func colorValueFromHex(_ hex: String) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
    guard let hexRange = hex.range(of: "[0-9a-fA-F]{3,8}", options: .regularExpression, range: nil, locale: nil) else {
        return (0, 0, 0, 0)
    }
    let colorCode = String(hex[hexRange])
    switch colorCode.lengthOfBytes(using: .utf8) {
    case 3:
        // #RGB
        let red = CGFloat(Int(String(colorCode[colorCode.startIndex]), radix: 16)! * 17) / 0xFF
        let green = CGFloat(Int(String(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 1)]), radix: 16)! * 17) / 0xFF
        let blue = CGFloat(Int(String(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 2)]), radix: 16)! * 17) / 0xFF
        return (red, green, blue, 1.0)
    case 4:
        // #ARGB
        let alpha = CGFloat(Int(String(colorCode[colorCode.startIndex]), radix: 16)! * 17) / 0xFF
        let red = CGFloat(Int(String(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 1)]), radix: 16)! * 17) / 0xFF
        let green = CGFloat(Int(String(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 2)]), radix: 16)! * 17) / 0xFF
        let blue = CGFloat(Int(String(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 3)]), radix: 16)! * 17) / 0xFF
        return (red, green, blue, alpha)
    case 6:
        // #RRGGBB
        let red = CGFloat(Int(colorCode[colorCode.startIndex ... colorCode.index(colorCode.startIndex, offsetBy: 1)], radix: 16)!) / 0xFF
        let green = CGFloat(Int(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 2) ... colorCode.index(colorCode.startIndex, offsetBy: 3)], radix: 16)!) / 0xFF
        let blue = CGFloat(Int(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 4) ... colorCode.index(colorCode.startIndex, offsetBy: 5)], radix: 16)!) / 0xFF
        return (red, green, blue, 1.0)
    case 8:
        // #AARRGGBB
        let alpha = CGFloat(Int(colorCode[colorCode.startIndex ... colorCode.index(colorCode.startIndex, offsetBy: 1)], radix: 16)!) / 0xFF
        let red = CGFloat(Int(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 2) ... colorCode.index(colorCode.startIndex, offsetBy: 3)], radix: 16)!) / 0xFF
        let green = CGFloat(Int(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 4) ... colorCode.index(colorCode.startIndex, offsetBy: 5)], radix: 16)!) / 0xFF
        let blue = CGFloat(Int(colorCode[colorCode.index(colorCode.startIndex, offsetBy: 6) ... colorCode.index(colorCode.startIndex, offsetBy: 7)], radix: 16)!) / 0xFF
        return (red, green, blue, alpha)
    default:
        return (0, 0, 0, 0)
    }
}
