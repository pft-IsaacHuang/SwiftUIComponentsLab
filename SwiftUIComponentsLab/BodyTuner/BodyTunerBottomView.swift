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
    
    init(viewModel: ViewModel = ViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.clear
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                if viewModel.showDegreeBar {
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
                    .onChange(of: viewModel.cleavageValue) { _, newVal in
                        if cleavageSliderVM.value != newVal {
                            cleavageSliderVM.value = newVal
                        }
                    }
                    .onChange(of: viewModel.cleavageEnabled) { _, newVal in
                        if cleavageSliderVM.isEnabled != newVal {
                            cleavageSliderVM.isEnabled = newVal
                        }
                    }
                Spacer()
            }
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
            var shouldShowNegative: Bool { feature == .AutoNeck }
            var shouldShowMiddleDot: Bool { feature != .AutoNeck }
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
        var showAutoCleavageSlider: Bool { currentMode?.feature == .AutoCleavage && !shouldHideCleavageSlider }
        var shouldShowUndoRedo: Bool { currentMode?.feature != .AutoCleavage }
        var showDegreeBar: Bool { currentMode?.feature != .AutoCleavage }
        var showBackgroundProtectToggle: Bool { currentMode?.feature.isAutoFeature ?? false }
        var showProtectHeadToggle: Bool { currentMode?.feature.canProtectHead ?? false }
        
        // Degree control
        @Published var degreeValue: Float = 0
        var degreeMin: Float { currentMode?.minValue ?? 0 }
        var degreeMax: Float { currentMode?.maxValue ?? 1 }
        var degreeLabel: String {
            let displayValue = shouldShowNegative ? -degreeValue : degreeValue
            return Int(displayValue * 100.0).description
        }
        var shouldShowNegative: Bool { currentMode?.shouldShowNegative ?? false }
        var showMiddleDot: Bool { currentMode?.shouldShowMiddleDot ?? true }
        
        // Cleavage slider
        @Published var cleavageValue: Int = 0
        @Published var cleavageEnabled: Bool = true
        @Published var shouldHideCleavageSlider: Bool = false
        
        // Buttons
        @Published var undoEnabled: Bool = false
        @Published var redoEnabled: Bool = false
        @Published var doneEnabled: Bool = false
        @Published var bodySwitcherVisible: Bool = false
        // Background Protect
        @Published var backgroundProtectOn: Bool = false
        // Protect Head
        @Published var protectHeadOn: Bool = false

        init() {}
        
        func premiumBadge(for type: BeautifyEditCellIconType) -> ModePickerPremiumBadge {
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


#if DEBUG
struct BodyTunerBottomView_Previews: PreviewProvider {
    static var previews: some View {
        DemoContainer()
    }
}
#endif

// MARK: - Demo Delegate + Seeded Preview Container
#if DEBUG
final class DemoDelegate: NSObject, BodyTunerBottomViewDelegate {
    func onCancel() { print("[DemoDelegate] Cancel") }
    func onDone() { print("[DemoDelegate] Done") }
    func onUndo() { print("[DemoDelegate] Undo") }
    func onRedo() { print("[DemoDelegate] Redo") }
    func onBodySwitcherTap() { print("[DemoDelegate] Body Switcher Tap") }
    func onTabSelected(index: Int) { print("[DemoDelegate] Tab Selected: \(index)") }
    func onDegreeBegin() { print("[DemoDelegate] Degree Begin") }
    func onDegreeChange(value: Float) { print(String(format: "[DemoDelegate] Degree Change: %.2f", value)) }
    func onDegreeEnd(value: Float) { print(String(format: "[DemoDelegate] Degree End: %.2f", value)) }
    func onLevelSliderChanged(value: Int) { print("[DemoDelegate] Level slider changed: \(value)") }
    func onBackgroundProtectToggled(isOn: Bool) { print("[DemoDelegate] Background Protect toggled: \(isOn)") }
    func onProtectHeadToggled(isOn: Bool) { print("[DemoDelegate] Protect Head toggled: \(isOn)") }
}

struct DemoContainer: View {
    @StateObject private var vm: BodyTunerBottomView.ViewModel
    private let delegate = DemoDelegate()
    
    init() {
        // Seed modes for all features
        func iconName(for feature: BodyTunerFeature) -> String {
            switch feature {
            case .Enhance: return "bolt.circle"
            case .Waist: return "figure.stand"
            case .AutoWaist: return "figure.stand"
            case .AutoArm: return "hand.raised"
            case .AutoShoulder: return "person"
            case .AutoNeck: return "person.crop.circle"
            case .AutoChest: return "heart.circle"
            case .AutoCleavage: return "heart.circle"
            case .AutoLeg: return "figure.walk"
            case .AutoWidth: return "arrow.left.and.right.circle"
            case .AutoHip: return "figure.stand"
            }
        }
        let modes: [BodyTunerBottomView.ViewModel.BodyTunerMode] = BodyTunerFeature.allCases.enumerated().map { (idx, feature) in
                .init(
                    id: idx,
                    title: feature.description(),
                    iconName: iconName(for: feature),
                    feature: feature,
                    minValue: -1,
                    maxValue: 1,
                    defaultValue: 0,
                    iconType: .VIP,
                    isApplied: false,
                    isNew: false
                )
        }
        let seeded = BodyTunerBottomView.ViewModel()
        seeded.delegate = delegate
        seeded.modes = modes
        seeded.selectedFeatureIndex = 0
        seeded.degreeValue = 0
        seeded.undoEnabled = true
        seeded.redoEnabled = false
        seeded.doneEnabled = true
        seeded.bodySwitcherVisible = true
        _vm = StateObject(wrappedValue: seeded)
    }
    
    var body: some View {
        BodyTunerBottomView(viewModel: vm)
            .frame(height:200)
            .background(Color.gray)
            .previewLayout(.sizeThatFits)
            .onAppear {
                // Simulate delayed toggle to see UI reactivity
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    vm.selectedFeatureIndex = 0
                    vm.degreeValue = 0.5
                }
            }
    }
}
#endif
