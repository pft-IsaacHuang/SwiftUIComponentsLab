//
//  ConfirmCancelBottomBar.swift
//  YouPerfect
//
//  Created by KimWu on 2025/3/31.
//  Copyright © 2025 PerfectCorp. All rights reserved.
//

import SwiftUI

enum ConfirmCancelBottomBarStyle {
    case objectRemoval
}

struct ConfirmCancelBottomBar: View {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 40 : 40) var bottomControlViewHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 5 : 5) var bottomControlViewLeadingPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 5 : 5) var bottomControlViewTrailingPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 37 : 37) var actionControlButtonWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 33 : 33) var actionControlButtonHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 32 : 15) var actionControlContentSpacing: CGFloat
    
    let addtionalButtonList: [ActionType]
    let isOnlyCancelButtonInteractive: Bool
    let isActionButtonDisabled: (ActionType) -> Bool
    let buttonAction: (ActionType) -> ()
    
    init(addtionalButtonList: [ActionType], isOnlyCancelButtonInteractive: Bool = false , isActionButtonDisabled: @escaping (ActionType) -> Bool = { _ in true }, buttonAction: @escaping (ActionType) -> Void) {
        self.addtionalButtonList = addtionalButtonList
        self.isOnlyCancelButtonInteractive = isOnlyCancelButtonInteractive
        self.isActionButtonDisabled = isActionButtonDisabled
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: self.bottomControlViewLeadingPadding)
                .background(.clear)
                .foregroundColor(.clear)
            self.buttonView(.cancel)
            Spacer()
            self.actionControlPanel()
            Spacer()
            self.buttonView(.confirm)
            Rectangle()
                .frame(width: self.bottomControlViewTrailingPadding)
                .background(.clear)
                .foregroundColor(.clear)
        }
        .frame(height: self.bottomControlViewHeight)
        .background(Color.init(red: 23 / 255, green: 23 / 255, blue: 23 / 255, opacity: 1.0))
    }
    
    @ViewBuilder
    func actionControlPanel() -> some View {
        HStack(spacing: self.actionControlContentSpacing) {
            ForEach(self.addtionalButtonList) { type in
                self.buttonView(type)
                    .frame(width: self.actionControlButtonWidth, height: self.actionControlButtonHeight)
            }
        }
    }
    
    @ViewBuilder
    func buttonView(_ type: ActionType) -> some View {
        Button {
            self.buttonAction(type)
        } label: {
            Image(type.imageName)
                .opacity(self.isActionButtonDisabled(type) ? 0.5 : 1.0)
        }
        .accessibilityIdentifier(type.accessibilityIdentifier)
        .disabled(self.isActionButtonDisabled(type))
        .allowsHitTesting(!self.isOnlyCancelButtonInteractive || type == .cancel)
    }
}

extension ConfirmCancelBottomBar {
    enum ActionType: Identifiable {
        var id: Self { self }
        
        case none
        case confirm
        case cancel
        case undo
        case redo
        case reset
        case regen
        case eraser
        case bodySwitcher
        case manual
        
        var imageName: String {
            switch self {
            case .none:
                return ""
            case .confirm:
                return "btn_bottom_effect_ok_n"
            case .cancel:
                return "btn_bottom_close_n"
            case .undo:
                return "ico_pre_n"
            case .redo:
                return "ico_next_n"
            case .reset:
                return "btn_reload_n"
            case .regen:
                return "btn_ycp_mirror_colorswap"
            case .eraser:
                return "btn_3lv_eraser_new"
            case .bodySwitcher:
                return "btn_3lv_bodytuner_swap"
            case .manual:
                return "btn_2lv_manual_shape"
            }
        }
        
        var accessibilityIdentifier: String {
            switch self {
            case .none:
                return ""
            case .confirm:
                return "ConfirmButton"
            case .cancel:
                return "CancelButton"
            case .undo:
                return "UndoButton"
            case .redo:
                return "RedoButton"
            case .reset:
                return "ResetButton"
            case .regen:
                return "RegenButton"
            case .eraser:
                return "EraserButton"
            case .bodySwitcher:
                return "BodySwitcherButton"
            case .manual:
                return "ManualButton"
            }
        }
    }
}
