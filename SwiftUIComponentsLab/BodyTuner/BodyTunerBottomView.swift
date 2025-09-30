import SwiftUI

@objc protocol BodyTunerBottomViewDelegate: AnyObject {
    @objc func onCancel()
    @objc func onDone()
    @objc func onUndo()
    @objc func onRedo()
    @objc func onBodySwitcherTap()
    @objc func onTabSelected(index: Int)
    @objc func onDegreeBegin()
    @objc func onDegreeChange(value: Float)
    @objc func onDegreeEnd(value: Float)
    @objc func onLevelSliderChanged(value: Int)
    @objc func onSmootherTargetChanged(channel: SmootherChannel)
    func onManual()
    @objc func onBackgroundProtectToggled(isOn: Bool)
    @objc func onProtectHeadToggled(isOn: Bool)
}

struct BodyTunerBottomView: View {
    @ObservedObject var viewModel: ViewModel
    @StateObject private var cleavageSliderVM = LevelSlider.ViewModel(ticks: 4)
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1) var sliderTrackHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 11 : 16) var sliderThumbDiameter: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var middleDotSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var degreeLabelTopSpacing: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 286 : 208) var sliderWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var sliderBottomSpacing: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 9 : 28) var degreeLabelWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 12) var degreeLabelHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 10 : 10) var sliderLabelGap: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 36 : 36) var toggleButtonGroupHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 112 : 110) var smootherSwitchWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 274 : 140) var smootherSliderWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 19 : 16) var smootherSwitchSliderGap: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 10 : 10) var smootherPadding: CGFloat
    
    init(viewModel: ViewModel = ViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.clear
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                if viewModel.showSmootherBar {
                    SmootherControlBar().disabled(viewModel.interactionDisabled)
                } else if viewModel.showDegreeBar {
                    DegreeControlBar().disabled(viewModel.degreeControlBarInteractionDisabled || viewModel.interactionDisabled)
                } else if viewModel.showAutoCleavageSlider {
                    AutoCleavageSliderBar().disabled(viewModel.interactionDisabled)
                }
                Color.clear
                    .frame(height: sliderBottomSpacing)
                // Background Protect / Protect Head toggles
                if viewModel.showProtectHeadToggle || viewModel.showBackgroundProtectToggle {
                    HStack(alignment: .center) {
                        if viewModel.showProtectHeadToggle {
                            LabeledToggle(
                                title: NSLocalizedString("Protect Head", comment: ""),
                                isOn: Binding(get: { viewModel.protectHeadOn }, set: { newVal in
                                    viewModel.protectHeadOn = newVal
                                    viewModel.delegate?.onProtectHeadToggled(isOn: newVal)
                                }),
                                isDisabled: viewModel.interactionDisabled
                            )
                            .frame(maxWidth: .infinity)
                        }
                        if viewModel.showBackgroundProtectToggle {
                            LabeledToggle(
                                title: NSLocalizedString("BG Protect", comment: ""),
                                isOn: Binding(get: { viewModel.backgroundProtectOn }, set: { newVal in
                                    viewModel.backgroundProtectOn = newVal
                                    viewModel.delegate?.onBackgroundProtectToggled(isOn: newVal)
                                }),
                                isDisabled: viewModel.interactionDisabled
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: toggleButtonGroupHeight)
                }
                // Mode picker
                ModePickerScrollView(
                    items: viewModel.modes.map { mode in
                        let item = ModePickerScrollItem(
                            id: mode.id,
                            title: mode.title,
                            iconName: mode.iconName,
                            isApplied: mode.isApplied,
                            isNew: mode.isNew,
                            accessibilityId: "mode_\(mode.id)",
                            premiumBadge: viewModel.premiumBadge(for: mode.iconType)
                        )
                        return item
                    },
                    selectedIndex: Binding(get: { viewModel.selectedFeatureIndex }, set: { newVal in
                        viewModel.selectedFeatureIndex = newVal
                    }),
                    onSelect: { index in
                        viewModel.delegate?.onTabSelected(index: index)
                    },
                    config: .default
                )
                .allowsHitTesting(!viewModel.isDegreeDragging || !viewModel.interactionDisabled)
                // Button group (cancel | [undo, redo, bodySwitcher] | confirm)
                ConfirmCancelBottomBar(
                    addtionalButtonList: {
                        var list: [ConfirmCancelBottomBar.ActionType] = []
                        if viewModel.shouldShowUndoRedo{ list += [.undo, .redo] }
                        if viewModel.bodySwitcherVisible { list += [.bodySwitcher] }
                        if viewModel.manualVisible { list += [.manual] }
                        return list
                    }(),
                    isOnlyCancelButtonInteractive: viewModel.interactionDisabled,
                    isActionButtonDisabled: { type in
                        switch type {
                        case .undo: return !viewModel.undoEnabled
                        case .redo: return !viewModel.redoEnabled
                        case .confirm: return !viewModel.doneEnabled
                        default: return false
                        }
                    },
                    buttonAction: { type in
                        switch type {
                        case .cancel: viewModel.delegate?.onCancel()
                        case .confirm: viewModel.delegate?.onDone()
                        case .undo: viewModel.delegate?.onUndo()
                        case .redo: viewModel.delegate?.onRedo()
                        case .bodySwitcher: viewModel.delegate?.onBodySwitcherTap()
                        case .manual: viewModel.delegate?.onManual()
                        default: break
                        }
                    }
                )
            }
        }
        .background(Color.black.opacity(0.09))
    }
}

extension BodyTunerBottomView {
    @ViewBuilder
    func DegreeControlBar() -> some View {
        VStack(spacing: degreeLabelTopSpacing) {
            HStack(alignment: .center, spacing: 0) {
                // Invisible balancer to keep slider centered despite right label
                Color.clear
                    .frame(width: degreeLabelWidth+sliderLabelGap, height: 1)
                CustomSlider(
                    value: Binding(get: { CGFloat(viewModel.degreeValue) }, set: { newVal in
                        viewModel.onDegreeChange(CGFloat(newVal))
                    }),
                    range: CGFloat(viewModel.degreeMin)...CGFloat(viewModel.degreeMax),
                    trackHeight: sliderTrackHeight,
                    thumbDiameter: sliderThumbDiameter,
                    unfilledTrackColor: LinearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing),
                    enableSnappingMiddle: viewModel.showMiddleDot,
                    snappingThresholdPercentage: 0.05,
                    onBegin: { _ in viewModel.onDegreeBegin() },
                    onChanged: { val in viewModel.onDegreeChange(val) },
                    onEnded: { val in viewModel.onDegreeEnd(val) },
                    fillFromMidpoint: viewModel.showMiddleDot,
                    midpointValue: (CGFloat(viewModel.degreeMin) + CGFloat(viewModel.degreeMax)) / 2,
                    showMidpointDot: viewModel.showMiddleDot,
                    midpointDotDiameter: middleDotSize,
                    midpointDotColor: .white
                )
                .frame(width: sliderWidth, height: max(sliderThumbDiameter, 24))
                Color.clear
                    .frame(width: sliderLabelGap, height: 1)
                Text(viewModel.degreeLabel)
                    .foregroundStyle(.white)
                    .font(.system(size: degreeLabelHeight, weight: .medium))
                    .frame(width: degreeLabelWidth, height: degreeLabelHeight, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
        }
    }
    @ViewBuilder
    func AutoCleavageSliderBar() -> some View {
        VStack(spacing: degreeLabelTopSpacing) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                LevelSlider(viewModel: cleavageSliderVM)
                    .onAppear {
                        cleavageSliderVM.value = viewModel.cleavageValue
                        cleavageSliderVM.isEnabled = viewModel.cleavageEnabled
                        cleavageSliderVM.onCommit = { newVal in
                            viewModel.onLevelSliderChanged(newVal)
                        }
                    }
                    .onChange(of: viewModel.cleavageValue) { newVal in
                        if cleavageSliderVM.value != newVal {
                            cleavageSliderVM.value = newVal
                        }
                    }
                    .onChange(of: viewModel.cleavageEnabled) { newVal in
                        if cleavageSliderVM.isEnabled != newVal {
                            cleavageSliderVM.isEnabled = newVal
                        }
                    }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
    @ViewBuilder
    func SmootherControlBar() -> some View {
        let premiumBadgeWidth = GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 20 : 21).wrappedValue
        let premiumBadgeHeight = GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 9 : 9).wrappedValue
        VStack(spacing: degreeLabelTopSpacing) {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    PillSegmentedControl(
                        leftTitle: NSLocalizedString("Face", comment: ""),
                        rightTitle: NSLocalizedString("Body", comment: ""),
                        selection: Binding(get: {
                            viewModel.smootherTarget == .face ? 0 : 1
                        }, set: { newVal in
                            viewModel.smootherTarget = (newVal == 0) ? .face : .body
                            viewModel.delegate?.onSmootherTargetChanged(channel: viewModel.smootherTarget)
                        })
                    )
                    PremiumBadgeView(badge: viewModel.currentPremiumBadge)
                        .frame(width: premiumBadgeWidth, height: premiumBadgeHeight)
                        .offset(x: 9, y: -2)
                }
                .frame(width: smootherSwitchWidth)
                Color.clear
                    .frame(width: smootherSwitchSliderGap, height: 1)
                CustomSlider(
                    value: Binding(get: { CGFloat(viewModel.degreeValue) }, set: { newVal in
                        viewModel.onDegreeChange(CGFloat(newVal))
                    }),
                    range: CGFloat(0)...CGFloat(1),
                    trackHeight: sliderTrackHeight,
                    thumbDiameter: sliderThumbDiameter,
                    unfilledTrackColor: LinearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing),
                    enableSnappingMiddle: false,
                    snappingThresholdPercentage: 0.0,
                    onBegin: { _ in viewModel.onDegreeBegin() },
                    onChanged: { val in viewModel.onDegreeChange(val) },
                    onEnded: { val in viewModel.onDegreeEnd(val) },
                    fillFromMidpoint: false,
                    midpointValue: 0,
                    showMidpointDot: false,
                    midpointDotDiameter: 0,
                    midpointDotColor: .clear
                )
                .frame(width: smootherSliderWidth, height: max(sliderThumbDiameter, 24))
                Color.clear
                    .frame(width: sliderLabelGap, height: 1)
                Text(viewModel.degreeLabel)
                    .foregroundStyle(.white)
                    .font(.system(size: degreeLabelHeight, weight: .medium))
                    .frame(width: degreeLabelWidth, height: degreeLabelHeight, alignment: .leading)
            }
            .padding(.horizontal, smootherPadding)
            .frame(maxWidth: .infinity)
        }
    }
    
    class ViewModel: ObservableObject {
        struct BodyTunerMode: Identifiable {
            let id: Int
            let title: String
            let iconName: String
            let feature: BodyTunerFeature
            let minValue: Float
            let maxValue: Float
            let defaultValue: Float
            let iconType: BeautifyEditCellIconType
            var isApplied: Bool
            var isNew: Bool
        }
        
        weak var delegate: BodyTunerBottomViewDelegate?
        
        // Global
        @Published var interactionDisabled: Bool = false
        @Published var degreeControlBarInteractionDisabled: Bool = false
        @Published var isDegreeDragging: Bool = false
        
        // Tabs / feature selection
        @Published var selectedFeatureIndex: Int = 0
        @Published var modes: [BodyTunerMode] = []
        // Derived UI flags are computed from current mode
        var currentMode: BodyTunerMode? {
            guard selectedFeatureIndex >= 0, selectedFeatureIndex < modes.count else { return nil }
            return modes[selectedFeatureIndex]
        }
        var currentFeature: BodyTunerFeature { currentMode?.feature ?? .Enhance }
        var showAutoCleavageSlider: Bool { currentFeature == .AutoCleavage && !shouldHideCleavageSlider }
        var shouldShowUndoRedo: Bool { currentFeature != .AutoCleavage }
        var showSmootherBar: Bool { currentFeature == .AutoSmoother }
        var showDegreeBar: Bool { currentFeature.useDegreeControlBar }
        var showBackgroundProtectToggle: Bool { currentFeature.isAutoFeature && currentFeature != .AutoSmoother }
        var showProtectHeadToggle: Bool { currentFeature.canProtectHead }
        var currentPremiumBadge: PremiumBadge {
            guard let mode = currentMode else { return .none }
            return premiumBadge(for: mode.iconType)
        }
        
        // Degree control
        @Published var degreeValue: Float = 0
        var degreeMin: Float { currentMode?.minValue ?? 0 }
        var degreeMax: Float { currentMode?.maxValue ?? 1 }
        var degreeLabel: String {
            let displayValue = shouldShowNegative ? -degreeValue : degreeValue
            return Int(displayValue * 100.0).description
        }
        // Smoother control
        @Published var smootherTarget: SmootherChannel = .body
        
        var shouldShowNegative: Bool { currentFeature.showNegativeValueOnLabel }
        var showMiddleDot: Bool { currentFeature.showMiddleDot }
        
        // Cleavage slider
        @Published var cleavageValue: Int = 0
        @Published var cleavageEnabled: Bool = true
        @Published var shouldHideCleavageSlider: Bool = false
        
        // Buttons
        @Published var undoEnabled: Bool = false
        @Published var redoEnabled: Bool = false
        @Published var doneEnabled: Bool = false
        @Published var bodySwitcherVisible: Bool = false
        @Published var manualVisible: Bool = true
        // Background Protect
        @Published var backgroundProtectOn: Bool = false
        // Protect Head
        @Published var protectHeadOn: Bool = true
        
        init() {}
        
        func premiumBadge(for type: BeautifyEditCellIconType) -> PremiumBadge {
            switch type {
            case .try:
                return .trial
            case .pro:
                return .pro
            case .VIP:
                return .vip
            default:
                return .none
            }
        }
        
        // MARK: - Degree delegate passthrough (live update)
        func onDegreeBegin() {
            isDegreeDragging = true
            delegate?.onDegreeBegin()
        }
        func onDegreeChange(_ val: CGFloat) {
            let v = Float(val)
            self.degreeValue = v
            delegate?.onDegreeChange(value: v)
        }
        func onDegreeEnd(_ val: CGFloat) {
            let v = Float(val)
            self.degreeValue = v
            if v != 0 && !doneEnabled {
                self.doneEnabled = true
            }
            isDegreeDragging = false
            delegate?.onDegreeEnd(value: v)
        }
        func onLevelSliderChanged(_ value: Int) {
            self.cleavageValue = value
            delegate?.onLevelSliderChanged(value: value)
        }
    }
}
