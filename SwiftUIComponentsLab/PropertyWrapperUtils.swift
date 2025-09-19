//
//  PropertyWrapperUtils.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/8/18.
//

import Foundation
import UIKit

// Global device idiom flag
#if os(iOS) || targetEnvironment(macCatalyst)
let IS_IPAD: Bool = UIDevice.current.userInterfaceIdiom == .pad
#else
let IS_IPAD: Bool = false
#endif

@propertyWrapper
struct GuidelinePixelValueConvertor {
    private var length: CGFloat = 0
    private let guideLineScreenWidth: CGFloat = IS_IPAD ? 480 : 320
    private let deviceWidth: CGFloat = UIScreen.main.bounds.width
    var wrappedValue: CGFloat {
        get {
            return length
        }
        set {
            length = deviceWidth * (newValue / guideLineScreenWidth)
        }
    }
    
    init(wrappedValue: CGFloat) {
        self.wrappedValue = wrappedValue
    }
}
