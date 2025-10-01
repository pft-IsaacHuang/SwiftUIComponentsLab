//
//  TipBubble.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/10/1.
//

import SwiftUI

struct TipBubble: View {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 10 : 10) var textSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 4 : 4) var horizontalPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var verticalPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1.5 : 1.5) var borderWidth: CGFloat
    
    // Default fill color (kept to preserve existing look-and-feel)
    let defaultFillColor: UIColor = UIColor(red: 19 / 255, green: 169 / 255, blue: 122 / 255, alpha: 1)
    
    let message: String
    let multilineTextAlignment: TextAlignment
    let cornerRadius: CGFloat
    let tailOffsetX: CGFloat
    let bubbleFillColor: UIColor
    let textColor: UIColor
    let showGradientBorder: Bool
    let tailPosition: TipBubbleTailPosition
    let borderGradientStartColor: UIColor
    let borderGradientEndColor: UIColor
    let borderGradientStartPoint: UnitPoint
    let borderGradientEndPoint: UnitPoint
    let fontWeight: Font.Weight
    let tailWidth: CGFloat
    let tailHeight: CGFloat
    
    @State private var bounce = false
    @State private var shouldBounce = true
    
    init(
        message: String,
        multilineTextAlignment: TextAlignment = .center,
        cornerRadius: CGFloat = GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6).wrappedValue,
        tailOffsetX: CGFloat = 0,
        bubbleFillColor: UIColor? = nil,
        textColor: UIColor? = nil,
        showGradientBorder: Bool = false,
        tailPosition: TipBubbleTailPosition = .bottom,
        borderGradientStartColor: UIColor? = nil,
        borderGradientEndColor: UIColor? = nil,
        borderGradientStartPoint: UnitPoint = .bottomLeading,
        borderGradientEndPoint: UnitPoint = .topTrailing,
        fontWeight: Font.Weight = .medium,
        tailWidth: CGFloat = GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 12).wrappedValue,
        tailHeight: CGFloat = GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6).wrappedValue
    ) {
        self.message = message
        self.multilineTextAlignment = multilineTextAlignment
        self.cornerRadius = cornerRadius
        self.tailOffsetX = tailOffsetX
        self.bubbleFillColor = bubbleFillColor ?? defaultFillColor
        self.textColor = textColor ?? .white
        self.showGradientBorder = showGradientBorder
        self.tailPosition = tailPosition
        // Defaults replicate the previous diagonal blue → green (from 237DFE to 30F6C1)
        self.borderGradientStartColor = borderGradientStartColor ?? UIColor(hex: "#237DFE")
        self.borderGradientEndColor = borderGradientEndColor ?? UIColor(hex: "#30F6C1")
        self.borderGradientStartPoint = borderGradientStartPoint
        self.borderGradientEndPoint = borderGradientEndPoint
        self.fontWeight = fontWeight
        self.tailWidth = tailWidth
        self.tailHeight = tailHeight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.system(size: textSize, weight: fontWeight))
                .minimumScaleFactor(0.3)
                .multilineTextAlignment(multilineTextAlignment)
                .foregroundColor(Color(uiColor: textColor))
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
        }
        .padding(.bottom, tailPosition == .bottom ? tailHeight : 0)
        .padding(.top, tailPosition == .top ? tailHeight : 0)
        .background(
            BubbleWithTailOutline(
                cornerRadius: cornerRadius,
                tailWidth: tailWidth,
                tailHeight: tailHeight,
                tailOffsetX: tailOffsetX,
                tailPosition: tailPosition
            )
            .fill(Color(uiColor: bubbleFillColor))
        )
        .overlay(
            Group {
                if showGradientBorder {
                    BubbleWithTailOutline(
                        cornerRadius: cornerRadius,
                        tailWidth: tailWidth,
                        tailHeight: tailHeight,
                        tailOffsetX: tailOffsetX,
                        tailPosition: tailPosition
                    )
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(uiColor: borderGradientStartColor),
                                Color(uiColor: borderGradientEndColor)
                            ]),
                            startPoint: borderGradientStartPoint,
                            endPoint: borderGradientEndPoint
                        ),
                        style: StrokeStyle(lineWidth: borderWidth, lineJoin: .round)
                    )
                }
            }
        )
        .offset(y: shouldBounce && bounce ? -5 : 0)
        .animation(
            shouldBounce ?
            Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true) :
                    .default,
            value: bounce
        )
        .onAppear {
            bounce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                shouldBounce = false
                bounce = false
            }
        }
    }
}

fileprivate struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

fileprivate struct BubbleWithTailOutline: Shape {
    let cornerRadius: CGFloat
    let tailWidth: CGFloat
    let tailHeight: CGFloat
    let tailOffsetX: CGFloat
    let tailPosition: TipBubbleTailPosition
    
    func path(in rect: CGRect) -> Path {
        let hasTopTail = tailPosition == .top
        let bubbleOriginY = hasTopTail ? rect.minY + tailHeight : rect.minY
        let bubbleHeight = max(0, rect.height - tailHeight)
        let bubbleRect = CGRect(x: rect.minX, y: bubbleOriginY, width: rect.width, height: bubbleHeight)
        let r = min(cornerRadius, min(bubbleRect.width, bubbleRect.height) / 2)
        
        // Tail center clamped within rounded corners
        let minCenterX = bubbleRect.minX + r + tailWidth / 2
        let maxCenterX = bubbleRect.maxX - r - tailWidth / 2
        let desiredCenterX = rect.midX + tailOffsetX
        let cx = min(max(desiredCenterX, minCenterX), maxCenterX)
        let leftBaseX = cx - tailWidth / 2
        let rightBaseX = cx + tailWidth / 2
        
        let topY = bubbleRect.minY
        let bottomY = bubbleRect.maxY
        let leftX = bubbleRect.minX
        let rightX = bubbleRect.maxX
        
        var path = Path()
        if hasTopTail {
            // Start at top-left edge after corner
            path.move(to: CGPoint(x: leftX + r, y: topY))
            // Top edge until left base of tail
            path.addLine(to: CGPoint(x: leftBaseX, y: topY))
            // Tail (pointing up)
            path.addLine(to: CGPoint(x: cx, y: topY - tailHeight))
            path.addLine(to: CGPoint(x: rightBaseX, y: topY))
            // Top edge to before top-right corner
            path.addLine(to: CGPoint(x: rightX - r, y: topY))
            // Top-right corner
            path.addArc(center: CGPoint(x: rightX - r, y: topY + r), radius: r, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            // Right edge
            path.addLine(to: CGPoint(x: rightX, y: bottomY - r))
            // Bottom-right corner
            path.addArc(center: CGPoint(x: rightX - r, y: bottomY - r), radius: r, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            // Bottom edge
            path.addLine(to: CGPoint(x: leftX + r, y: bottomY))
            // Bottom-left corner
            path.addArc(center: CGPoint(x: leftX + r, y: bottomY - r), radius: r, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            // Left edge
            path.addLine(to: CGPoint(x: leftX, y: topY + r))
            // Top-left corner
            path.addArc(center: CGPoint(x: leftX + r, y: topY + r), radius: r, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        } else {
            // Start at top-left edge after corner
            path.move(to: CGPoint(x: leftX + r, y: topY))
            // Top edge to before top-right corner
            path.addLine(to: CGPoint(x: rightX - r, y: topY))
            // Top-right corner
            path.addArc(center: CGPoint(x: rightX - r, y: topY + r), radius: r, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            // Right edge
            path.addLine(to: CGPoint(x: rightX, y: bottomY - r))
            // Bottom-right corner
            path.addArc(center: CGPoint(x: rightX - r, y: bottomY - r), radius: r, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            // Bottom edge to right base of tail
            path.addLine(to: CGPoint(x: rightBaseX, y: bottomY))
            // Tail (pointing down)
            path.addLine(to: CGPoint(x: cx, y: bottomY + tailHeight))
            path.addLine(to: CGPoint(x: leftBaseX, y: bottomY))
            // Bottom edge to before bottom-left corner
            path.addLine(to: CGPoint(x: leftX + r, y: bottomY))
            // Bottom-left corner
            path.addArc(center: CGPoint(x: leftX + r, y: bottomY - r), radius: r, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            // Left edge
            path.addLine(to: CGPoint(x: leftX, y: topY + r))
            // Top-left corner
            path.addArc(center: CGPoint(x: leftX + r, y: topY + r), radius: r, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        }
        path.closeSubpath()
        return path
    }
}

@objc enum TipBubbleTailPosition: Int {
    case top
    case bottom
}
