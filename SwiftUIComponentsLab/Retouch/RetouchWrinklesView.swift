//
//  RetouchWrinklesView.swift
//  YouPerfect
//
//  Created by AI on 2025/11/25.
//  Copyright © 2025 PerfectCorp. All rights reserved.
//

import SwiftUI
import UIKit

enum RetouchWrinklesMode: CaseIterable {
    case auto
    case manual
    
    var tabName: String {
        switch self {
        case .auto: return NSLocalizedString("AUTO", comment: "")
        case .manual: return NSLocalizedString("MANUAL", comment: "")
        }
    }
    
}

enum WrinkleAutoType: CaseIterable {
    case all
    case forehead
    case eye
    case nasolabial
    
    var name: String {
        switch self {
        case .all: return NSLocalizedString("All", comment: "")
        case .forehead: return NSLocalizedString("Forehead lines", comment: "")
        case .eye: return NSLocalizedString("Eye wrinkles", comment: "")
        case .nasolabial: return NSLocalizedString("Nasolabial folds", comment: "")
        }
    }
    
    var iconName: String {
        switch self {
        case .all: return "btn_bottom_wrinkle"
        case .forehead: return "btn_bottom_wrinkle_forehead"
        case .eye: return "btn_bottom_wrinkle_eye"
        case .nasolabial: return "btn_bottom_wrinkle_nasolabial"
        }
    }
    
}

struct RetouchWrinklesView: View {
    
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 20 : 18) var modeTabViewHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var modeTabViewBottomPadding: CGFloat
    
    @ObservedObject var viewModel: RetouchWrinklesViewViewModel
    
    init(viewModel: RetouchWrinklesViewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ModeTabView(tabList: self.viewModel.tabList.map({ $0.tabName }),
                        selectedIndex: self.$viewModel.tabSelectedIndex,
                        horizontalPadding: IS_IPAD ? 24 : 14,
                        tabItemContentSpacing: IS_IPAD ? 24 : 14,
                        textSize: IS_IPAD ? 12 : 12,
                        textFont: .semibold,
                        textContentSpacing: IS_IPAD ? 4 : 2,
                        textUnderLineHeight: IS_IPAD ? 2 : 1,
                        textHorizontalPadding: IS_IPAD ? 5 : 1)
                .frame(height: self.modeTabViewHeight)
            Color.clear.frame(height: self.modeTabViewBottomPadding)
            self.ContentView()
        }
        .frame(maxWidth: .infinity)
        .task {
            //await ObjectRemovalMLModelManager.shared.preload()
        }
    }
    
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 62 : 56) var sliderAutoLeadingPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 82 : 34) var sliderAutoTrailingPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var sliderAutoBottomPadding: CGFloat

    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 12) var sliderManualHorizontalPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 51 : 24) var sliderManualLeadingPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 10 : 28) var sliderManualTrailingPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 13 : 10) var applyButtonTrailingPadding: CGFloat

    private var autoContentHeight: CGFloat {
        return self.sliderRowHeight + self.sliderAutoBottomPadding + self.autoModeCellHeight
    }
    
    @ViewBuilder
    func ContentView() -> some View {
        switch self.viewModel.tabList[self.viewModel.tabSelectedIndex] {
        case .auto:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color.clear.frame(width: self.sliderAutoLeadingPadding, height: 0)
                    self.SliderView(showLabel: false)
                    Color.clear.frame(width: self.sliderAutoTrailingPadding, height: 0)
                }
                Color.clear.frame(height: self.sliderAutoBottomPadding)
                self.AutoModeSelector()
            }
            .frame(height: self.autoContentHeight, alignment: .bottom)
            
        case .manual:
            HStack(spacing: 0) {
                Color.clear.frame(width: self.sliderManualLeadingPadding, height: 0)
                self.SliderView(range: 1...100)
                Color.clear.frame(width: self.sliderManualTrailingPadding, height: 0)
                self.applyButton(title: NSLocalizedString("Apply", comment: ""), action: self.viewModel.applyButtonAction)
                Color.clear.frame(width: self.applyButtonTrailingPadding, height: 0)
            }
            .frame(height: self.autoContentHeight, alignment: .center)
        }
    }
    
    private var highlightColor: Color { Color(red: 39/255, green: 219/255, blue: 175/255) }
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 12) var autoModeSelectorHorizontalPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 2 : 2) var autoModeSelectorDividerWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 24 : 24) var autoModeSelectorDividerHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 3 : 3) var autoModeSelectorDividerCornerRadius: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var autoModeSelectorDividerCellWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 58 : 58) var autoModeSelectorDividerCellHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var autoModeCellSpacing: CGFloat
    
    @ViewBuilder
    func AutoModeSelector() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(self.viewModel.autoModeList.enumerated()), id: \.element) { index, type in
                Button(action: {
                    self.viewModel.selectedAutoMode = type
                }) {
                    SelectorCell(type: type)
                }
                .buttonStyle(.plain)

                if index != self.viewModel.autoModeList.count - 1 {
                    Color.clear.frame(width: self.autoModeCellSpacing, height: 0)
                }
                
                if index == 0 {
                    ZStack {
                        RoundedRectangle(cornerRadius: self.autoModeSelectorDividerCornerRadius)
                            .fill(Color.white)
                            .frame(width: self.autoModeSelectorDividerWidth, height: self.autoModeSelectorDividerHeight)
                    }
                    .frame(width: self.autoModeSelectorDividerCellWidth, height: self.autoModeSelectorDividerCellHeight)
                    Color.clear.frame(width: self.autoModeCellSpacing, height: 0)
                }
            }
        }
        .padding(.horizontal, self.autoModeSelectorHorizontalPadding)        
    }
    
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 58 : 58) var autoModeCellHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 70 : 70) var autoModeCellWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 52 : 52) var autoModeAllCellWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 40 : 40) var autoModeIconSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 4 : 4) var autoModeLabelBottomPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 11 : 12) var autoModeLabelFontSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 2 : 2) var autoModeCellUnderlineHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 50 : 50) var autoModeCellUnderlineWidth: CGFloat
    
    @ViewBuilder
    func SelectorCell(type: WrinkleAutoType) -> some View {
        let isSelected = self.viewModel.selectedAutoMode == type
        let cellWidth = (type == .all) ? self.autoModeAllCellWidth : self.autoModeCellWidth
        
        VStack(spacing:0) {
            Image(type.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: self.autoModeIconSize, height: self.autoModeIconSize)
            Text(type.name)
                .font(.system(size: self.autoModeLabelFontSize, weight: .medium))
                .foregroundColor(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Color.clear.frame(height: self.autoModeLabelBottomPadding)
            Rectangle()
                .fill(isSelected ? highlightColor : Color.clear)
                .frame(width: self.autoModeCellUnderlineWidth, height: self.autoModeCellUnderlineHeight)
        }
        .frame(width: cellWidth, height: self.autoModeCellHeight)
        .contentShape(Rectangle())
    }
    
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 10) var sliderContentSpacing: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 8 : 11) var sliderLabelTextSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 8 : 11) var sliderValueTextSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 14 : 20) var sliderValueFixedWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 10 : 16) var sliderTrackThumbDiameter: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1) var sliderTrackHeight: CGFloat
    
    let sliderTextFontWeight: Font.Weight = IS_IPAD ? .light : .regular
    private var sliderRowHeight: CGFloat {
        max(self.sliderTrackThumbDiameter, max(self.sliderLabelTextSize, self.sliderValueTextSize))
    }
    
    @ViewBuilder
    func SliderView(showLabel: Bool = true, range: ClosedRange<CGFloat> = 0...100) -> some View {
        HStack(spacing: self.sliderContentSpacing) {
            if showLabel {
                Text(NSLocalizedString("Size", comment: ""))
                    .font(.system(size: self.sliderLabelTextSize, weight: self.sliderTextFontWeight))
                    .foregroundStyle(.white)
            }
            
            CustomSlider(value: self.$viewModel.sliderValue,
                         range: range,
                         trackHeight: self.sliderTrackHeight,
                         thumbDiameter: self.sliderTrackThumbDiameter,
                         onBegin: self.viewModel.sliderValueOnBegin,
                         onChanged: self.viewModel.sliderValueOnChanged,
                         onEnded: self.viewModel.sliderValueOnEnded)
            .frame(maxWidth: .infinity)
            .accessibilityLabel(NSLocalizedString("Size", comment: ""))
            
            Text(String(Int(round(self.viewModel.sliderValue))))
                .font(.system(size: self.sliderValueTextSize, weight: self.sliderTextFontWeight))
                .frame(width: self.sliderValueFixedWidth)
                .foregroundStyle(.white)
        }
    }
    
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 12) var applyButtonTextSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 4 : 4) var applyButtonTextPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 64 : 64) var applyButtonWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 22 : 22) var applyButtonHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 3 : 3) var applyButtonCornerRadius: CGFloat
    let applyButtonBackgroundColor: Color = Color(red: 1 / 255, green: 179 / 255, blue: 123 / 255)
    
    @ViewBuilder
    func applyButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .font(.system(size: self.applyButtonTextSize, weight: .bold))
                .padding(.all, self.applyButtonTextPadding)
        }
        .frame(width: self.applyButtonWidth, height: self.applyButtonHeight)
        .background(
            RoundedRectangle(cornerRadius: self.applyButtonCornerRadius)
                .fill(self.applyButtonBackgroundColor)
        )
        .opacity(self.viewModel.isApplyButtonDisabled ? 0.5 : 1)
        .disabled(self.viewModel.isApplyButtonDisabled)
    }
}

extension RetouchWrinklesView {
    @MainActor
    @objc class RetouchWrinklesViewViewModel: NSObject, ObservableObject {
        // MARK: - Published UI States
        @Published var tabSelectedIndex: Int = 0 {
            didSet {
                if tabSelectedIndex < 0 || tabSelectedIndex >= tabList.count {
                    tabSelectedIndex = 0
                }
            }
        }
        @Published var tabList: [RetouchWrinklesMode] = [.auto, .manual]
        @Published var autoModeList: [WrinkleAutoType] = Array(WrinkleAutoType.allCases)
        @Published var selectedAutoMode: WrinkleAutoType = .all
        @Published var sliderValue: CGFloat = 70
        @Published var isApplyButtonDisabled: Bool = false
        
        // MARK: - Actions
        var applyButtonAction: () -> Void
        
        // MARK: - Init
        override init() {
            self.applyButtonAction = {}
            super.init()
        }
        
        init(applyButtonAction: @escaping () -> Void = {}) {
            self.applyButtonAction = applyButtonAction
            super.init()
        }
        
        // MARK: - Slider Callbacks
        func sliderValueOnBegin(value: CGFloat) {
            // No-op for UI-only usage
        }
        
        func sliderValueOnChanged(value: CGFloat) {
            self.sliderValue = value
        }
        
        func sliderValueOnEnded(value: CGFloat) {
            self.sliderValue = value
        }
    }
}

#if DEBUG
struct RetouchWrinklesView_Previews: PreviewProvider {
    private struct DemoContainer: View {
        @StateObject var viewModel = RetouchWrinklesView.RetouchWrinklesViewViewModel()
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Spacer()
                    RetouchWrinklesView(viewModel: viewModel)
                        .padding(.bottom, 12)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    static var previews: some View {
        Group {
            DemoContainer()
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
                .previewDisplayName("iPhone 15 Pro")
            
            DemoContainer()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro 12.9”")
        }
    }
}
#endif
