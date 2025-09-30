//
//  PremiumBadge.swift
//  SwiftUIComponentsLab
//
//  Created by Isaac Huang on 2025/9/30.
//

import SwiftUI

enum PremiumBadge {
    case none
    case trial
    case pro
    case vip
}

struct PremiumBadgeView: View {
    let badge: PremiumBadge
    var body: some View {
        Group {
            switch badge {
            case .trial:
                Image("ico_try_ios", bundle: nil)
                    .resizable()
                    .scaledToFit()
            case .pro:
                Image("ico_ycp_lobby_pro", bundle: nil)
                    .resizable()
                    .scaledToFit()
            case .vip:
                Image("ico_ycp_lobby_paiduser", bundle: nil)
                    .resizable()
                    .scaledToFit()
            case .none:
                EmptyView()
            }
        }
    }
}
