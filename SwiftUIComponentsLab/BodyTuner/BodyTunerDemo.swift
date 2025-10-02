//
//  BodyTunerDemo.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/9/30.
//

import SwiftUI

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
    func onManual() { print("[DemoDelegate] Manual") }
    func onSmootherTargetChanged(channel: SmootherChannel) { print("[DemoDelegate] Smoother Target Changed: \(channel)") }
}

struct DemoContainer: View {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 175 : 174) var height: CGFloat
    @StateObject private var vm: BodyTunerBottomView.ViewModel
    private let delegate = DemoDelegate()
    
    init() {
        // Seed modes for all features
        func iconName(for feature: BodyTunerFeature) -> String {
            switch feature {
            case .Enhance: return "btn_bottom_enhancer"
            case .Waist: return "btn_bottom_waist"
            case .AutoWaist: return "btn_bottom_auto_waist"
            case .AutoLeg: return "btn_bottom_legs"
            case .AutoArm: return "btn_bottom_auto_arm"
            case .AutoWidth: return "btn_bottom_width"
            case .AutoShoulder: return "btn_bottom_shoulder"
            case .AutoNeck: return "btn_bottom_neck"
            case .AutoChest: return "btn_bottom_breast"
            case .AutoCleavage: return "btn_bottom_aichest"
            case .AutoBelly: return "btn_bottom_belly"
            case .AutoSmoother: return "btn_bottom_bodysmooth"
            case .AutoHip: return "btn_bottom_hip"
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
                    iconType: .pro,
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
        seeded.bodySwitcherVisible = false
        _vm = StateObject(wrappedValue: seeded)
    }
    
    var body: some View {
        BodyTunerBottomView(viewModel: vm)
            .frame(height:height)
            .background(Color.gray)
            .previewLayout(.sizeThatFits)
            .onAppear {
                // Simulate delayed toggle to see UI reactivity
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    vm.selectedFeatureIndex = 0
                    vm.degreeValue = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    vm.bodySwitcherVisible = true
                    vm.bodySwitcherHintVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) {
                    vm.bodySwitcherHintVisible = false
                }
            }
    }
}

struct BodyTunerDemo: View {
    var body: some View {
        DemoContainer()
    }
}   
