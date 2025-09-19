//
//  LevelSlider.swift
//  YouPerfect
//
//  A reusable SwiftUI control: a discrete, snap-to-nearest slider with haptic feedback.
//  It supports tap-to-jump, snapping on drag end, and custom styling.
//

import SwiftUI
import UIKit

public struct LevelSliderStyle {
    
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 286 : 238) var trackWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1.48) var trackHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 2 : 2) var trackPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 16) var pointDiameter: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 2 : 1) var labelRowHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 5 : 4) var labelSpacing: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 22 : 26) var knobOuterRingDiameter: CGFloat
    public var activeColor: Color
    public var inactiveColor: Color
    public var knobOuterRingColor: Color
    public var knobOuterRingOpacity: Double
    
    public init(
        activeColor: Color = Color(hex: "#C02458"),
        inactiveColor: Color = Color(hex: "#D7D7D7"),
        knobOuterRingColor: Color = Color(hex: "#FFACC8"),
        knobOuterRingOpacity: Double = 0.4
    ) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.knobOuterRingColor = knobOuterRingColor
        self.knobOuterRingOpacity = knobOuterRingOpacity
    }
}

public struct LevelSlider: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let labels: [String]
    private let shouldShowActiveTrack: Bool
    private let style: LevelSliderStyle
    
    // Drag state
    @State private var dragLocationX: CGFloat? = nil
    @State private var isDragging: Bool = false
    
    // Haptics
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    public init(
        viewModel: ViewModel,
        labels: [String]? = nil,
        shouldShowActiveTrack: Bool = false,
        style: LevelSliderStyle = LevelSliderStyle()
    ) {
        self._viewModel = ObservedObject(initialValue: viewModel)
        let defaultLabels = (0..<viewModel.ticks).map { String($0) }
        self.labels = labels?.count == viewModel.ticks ? labels! : defaultLabels
        self.shouldShowActiveTrack = shouldShowActiveTrack
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Labels row positioned precisely at tick centers
            ZStack(alignment: .leading) {
                ForEach(0..<viewModel.ticks, id: \.self) { idx in
                    Text(labels[idx])
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .regular))
                        .position(x: tickCenterX(for: idx), y: labelRowHeight / 2)
                }
            }
            .frame(width: style.trackWidth, height: labelRowHeight, alignment: .leading)
            .padding(.bottom, style.labelSpacing)
            
            // Track + points + knob
            ZStack(alignment: .leading) {
                // Inactive track
                Rectangle()
                    .fill(style.inactiveColor)
                    .frame(width: usableTrackWidth, height: style.trackHeight)
                    .position(x: pointRadius + usableTrackWidth / 2, y: trackAreaHeight / 2)
                
                // Active track
                if shouldShowActiveTrack {
                    Rectangle()
                        .fill(style.activeColor)
                        .frame(width: max(0, knobCenterX - pointRadius), height: style.trackHeight)
                        .position(x: pointRadius + max(0, knobCenterX - pointRadius) / 2, y: trackAreaHeight / 2)
                }
                
                // Points (ticks) positioned exactly at 0, spacing, ..., trackWidth
                ZStack(alignment: .leading) {
                    ForEach(0..<viewModel.ticks, id: \.self) { idx in
                        Circle()
                            .fill(shouldShowActiveTrack && isActiveTick(idx) ? style.activeColor : style.inactiveColor)
                            .frame(width: style.pointDiameter, height: style.pointDiameter)
                            .position(x: tickCenterX(for: idx), y: trackAreaHeight / 2)
                            .contentShape(Rectangle())
                    }
                }
                .frame(width: style.trackWidth, height: trackAreaHeight, alignment: .leading)
                
                // Knob (overlay ring + knob centered at tick position while dragging)
                Group {
                    Circle()
                        .fill(style.knobOuterRingColor.opacity(style.knobOuterRingOpacity))
                        .frame(width: style.knobOuterRingDiameter, height: style.knobOuterRingDiameter)
                        .position(x: knobCenterX, y: trackAreaHeight / 2)
                        .opacity(isDragging ? 1 : 0)
                    
                    Circle()
                        .fill(style.activeColor)
                        .frame(width: style.pointDiameter, height: style.pointDiameter)
                        .position(x: knobCenterX, y: trackAreaHeight / 2)
                }
                .allowsHitTesting(false)
            }
            .frame(width: style.trackWidth, height: trackAreaHeight)
            .coordinateSpace(name: trackCoordinateSpace)
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        guard viewModel.isEnabled else { return }
                        // No location from TapGesture; attach a transparent overlay to catch taps with a DragGesture ended immediately.
                    }
            )
            .highPriorityGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named(trackCoordinateSpace))
                    .onEnded { g in
                        guard viewModel.isEnabled else { return }
                        let distance = abs(g.translation.width) + abs(g.translation.height)
                        if distance < 1 {
                            let x = clampKnobX(x: g.location.x)
                            let nearest = nearestTickIndex(forX: x)
                            snapTo(nearest, haptic: true)
                        }
                    }
            )
            .simultaneousGesture(viewModel.isEnabled ? dragGesture : nil)
            .onAppear { selectionFeedback.prepare() }
        }
        .padding(.vertical, style.trackPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Intensity")
        .accessibilityValue("\(viewModel.value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                snapTo(min(viewModel.value + 1, viewModel.ticks - 1), haptic: true)
            case .decrement:
                snapTo(max(viewModel.value - 1, 0), haptic: true)
            default:
                break
            }
        }
        //.opacity(isEnabled ? 1.0 : 0.5)
    }
    
    // MARK: - Geometry helpers
    private var pointRadius: CGFloat { style.pointDiameter / 2 }
    private var usableTrackWidth: CGFloat { max(0, style.trackWidth - style.pointDiameter) }
    private var tickSpacing: CGFloat { usableTrackWidth / CGFloat(max(1, viewModel.ticks - 1)) }
    private func tickCenterX(for index: Int) -> CGFloat { pointRadius + CGFloat(index) * tickSpacing }
    private var trackAreaHeight: CGFloat { max(style.pointDiameter, style.knobOuterRingDiameter, 24) }
    private var labelRowHeight: CGFloat { style.labelRowHeight }
    private let trackCoordinateSpace = "LevelSlider.track"
    
    private func segmentWidth(for index: Int) -> CGFloat {
        if index == 0 || index == viewModel.ticks - 1 { return tickSpacing / 2 }
        return tickSpacing
    }
    
    private func segmentAlignment(for index: Int) -> Alignment {
        if index == 0 { return .leading }
        if index == viewModel.ticks - 1 { return .trailing }
        return .center
    }
    
    private var currentKnobX: CGFloat {
        let progress = CGFloat(viewModel.value) / CGFloat(max(1, viewModel.ticks - 1))
        return pointRadius + usableTrackWidth * progress
    }
    
    private var knobCenterX: CGFloat {
        if let dragX = dragLocationX { return clampKnobX(x: dragX) }
        return currentKnobX
    }
    
    private func isActiveTick(_ index: Int) -> Bool {
        return knobCenterX >= tickCenterX(for: index)
    }
    
    private func clampKnobX(x: CGFloat) -> CGFloat {
        min(max(pointRadius, x), style.trackWidth - pointRadius)
    }
    
    
    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .named(trackCoordinateSpace))
            .onChanged { gesture in
                isDragging = true
                let x = gesture.location.x
                dragLocationX = clampKnobX(x: x)
            }
            .onEnded { gesture in
                let x = clampKnobX(x: gesture.location.x)
                dragLocationX = nil
                isDragging = false
                let nearest = nearestTickIndex(forX: x)
                snapTo(nearest, haptic: true)
            }
    }
    
    private func onTapTick(_ idx: Int) {
        guard viewModel.isEnabled else { return }
        snapTo(idx, haptic: true)
    }
    
    private func nearestTickIndex(forX x: CGFloat) -> Int {
        let raw = (x - pointRadius) / tickSpacing
        let snapped = Int((raw).rounded())
        return min(max(0, snapped), viewModel.ticks - 1)
    }
    
    private func snapTo(_ newValue: Int, haptic: Bool) {
        guard newValue != viewModel.value || haptic == true else { return }
        viewModel.value = newValue
        if haptic { selectionFeedback.selectionChanged() }
        viewModel.onCommit?(newValue)
    }
}

public extension LevelSlider {
    final class ViewModel: ObservableObject {
        @Published public var value: Int
        @Published public var isEnabled: Bool
        public let ticks: Int
        public var onCommit: ((Int) -> Void)?

        public init(ticks: Int = 4, value: Int = 0, isEnabled: Bool = true, onCommit: ((Int) -> Void)? = nil) {
            self.ticks = max(2, ticks)
            self.value = value
            self.isEnabled = isEnabled
            self.onCommit = onCommit
        }
    }
}
