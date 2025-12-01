//
//  ModeTabView.swift
//  YouPerfect
//
//  Created by KimWu on 2025/3/31.
//  Copyright © 2025 PerfectCorp. All rights reserved.
//

import SwiftUI

struct ModeTabView: View {
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 14 : 14) var horizontalPadding: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 14 : 14) var tabItemContentSpacing: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 12) var textSize: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 2 : 2) var textContentSpacing: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1) var textUnderLineHeight: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1) var textHorizontalPadding: CGFloat
    
    let textColor: Color = Color(red: 23 / 255, green: 255 / 255, blue: 193 / 255)
    let textFont: Font.Weight
    @ObservedObject var viewModel: ViewModel
    
    init(tabList: [String], selectedIndex: Binding<Int>, textFont: Font.Weight = .medium) {
        _viewModel = ObservedObject(wrappedValue: ViewModel(tabList: tabList, selectedIndex: selectedIndex))
        self.textFont = textFont
    }
    
    init(tabList: [String], selectedIndex: Binding<Int>, horizontalPadding: CGFloat, tabItemContentSpacing: CGFloat, textSize: CGFloat, textFont: Font.Weight = .medium, textContentSpacing: CGFloat, textUnderLineHeight: CGFloat, textHorizontalPadding: CGFloat) {
        _viewModel = ObservedObject(wrappedValue: ViewModel(tabList: tabList, selectedIndex: selectedIndex))
        self._horizontalPadding = GuidelinePixelValueConvertor(wrappedValue: horizontalPadding)
        self._tabItemContentSpacing = GuidelinePixelValueConvertor(wrappedValue: tabItemContentSpacing)
        self._textSize = GuidelinePixelValueConvertor(wrappedValue: textSize)
        self.textFont = textFont
        self._textContentSpacing = GuidelinePixelValueConvertor(wrappedValue: textContentSpacing)
        self._textUnderLineHeight = GuidelinePixelValueConvertor(wrappedValue: textUnderLineHeight)
        self._textHorizontalPadding = GuidelinePixelValueConvertor(wrappedValue: textHorizontalPadding)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometryProxy in
                ScrollViewReader { scrollProxy in
                    if self.viewModel.fitsScreen(textSize: self.textSize, scrollViewHorizontalPadding: self.horizontalPadding, textHorizontalPadding: self.textHorizontalPadding, scrollViewContentSpacing: self.textContentSpacing, contentWidth: geometryProxy.size.width) {
                        self.contentView()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            self.contentView()
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    scrollProxy.scrollTo(self.viewModel.selectedIndex, anchor: .center)
                                }
                            }
                        }
                        .onChange(of: self.viewModel.selectedIndex) { index in
                            withAnimation {
                                scrollProxy.scrollTo(index, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func contentView() -> some View {
        LazyHStack(spacing: self.tabItemContentSpacing) {
            ForEach(Array(zip(self.viewModel.tabList.indices, self.viewModel.tabList)), id: \.0) { index, tabText in
                VStack(spacing: self.textContentSpacing) {
                    Text(tabText)
                        .font(.system(size: self.textSize, weight: self.textFont))
                        .padding(.horizontal, self.textHorizontalPadding)
                        .foregroundStyle(self.viewModel.selectedIndex == index ? self.textColor : .white)
                    Rectangle()
                        .fill(self.viewModel.selectedIndex == index ? self.textColor : .clear)
                        .frame(height: self.textUnderLineHeight)
                }
                .onTapGesture {
                    self.viewModel.onTapTab(index: index)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(tabText.lowercased())
                .accessibilityAddTraits(self.viewModel.selectedIndex == index ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, self.horizontalPadding)
    }
}

extension ModeTabView {
    class ViewModel: ObservableObject {
        
        let tabList: [String]
        @Binding var selectedIndex: Int
        
        init(tabList: [String], selectedIndex: Binding<Int>) {
            self.tabList = tabList
            self._selectedIndex = selectedIndex
        }
        
        func fitsScreen(textSize: CGFloat, scrollViewHorizontalPadding: CGFloat, textHorizontalPadding: CGFloat, scrollViewContentSpacing: CGFloat, contentWidth: CGFloat) -> Bool {
            var totalWidth: CGFloat = 0
            for tabString in self.tabList {
                totalWidth += tabString.widthOfString(usingFont: .systemFont(ofSize: textSize, weight: .medium)) + textHorizontalPadding * 2
            }
            totalWidth += scrollViewContentSpacing * CGFloat(self.tabList.count - 1)
            totalWidth += scrollViewHorizontalPadding * 2
            return totalWidth < contentWidth
        }
        
        func onTapTab(index: Int) {
            self.selectedIndex = index
        }
    }
}

fileprivate extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

