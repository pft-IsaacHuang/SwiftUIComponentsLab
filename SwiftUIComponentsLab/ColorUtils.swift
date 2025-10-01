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

extension UIColor {
    @objc public convenience init(hex: String, isAlpha: Bool) {
        if hex == "clear" || hex == "color_picker" {
            self.init(white: 0, alpha: 0)
            return
        }
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    let a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    let r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    let g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    let b = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha:isAlpha ? a : 1)
                    return
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                scanner.scanHexInt64(&hexNumber)
                let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                let b = CGFloat(hexNumber & 0x0000ff) / 255
                
                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        } else {
            if hex.count == 8 {
                let scanner = Scanner(string: hex)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    let a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    let r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    let g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    let b = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: isAlpha ? a : 1)
                    return
                }
            } else if hex.count == 6 {
                let scanner = Scanner(string: hex)
                scanner.scanLocation = 0
                
                var rgbValue: UInt64 = 0
                
                scanner.scanHexInt64(&rgbValue)
                
                let r = (rgbValue & 0xff0000) >> 16
                let g = (rgbValue & 0xff00) >> 8
                let b = rgbValue & 0xff
                
                self.init(
                    red: CGFloat(r) / 0xff,
                    green: CGFloat(g) / 0xff,
                    blue: CGFloat(b) / 0xff, alpha: 1
                )
                return
            }
        }
        self.init(
            red: 0,
            green: 0,
            blue: 0, alpha: 1
        )
    }
    
    @objc public convenience init(hex: String) {
        self.init(hex: hex, isAlpha: true)
    }
    
    public convenience init(r: Int, g: Int, b: Int, a: Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
        return
    }

}
