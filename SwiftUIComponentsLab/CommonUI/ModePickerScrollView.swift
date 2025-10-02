import SwiftUI

struct ButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

import SwiftUI

struct ModePickerScrollItem: Identifiable {
    let id: Int
    let title: String
    let iconName: String
    let isApplied: Bool
    let isNew: Bool
    let accessibilityId: String?
    let premiumBadge: PremiumBadge
}

struct ModePickerScrollConfig {
    var contentSpacing: CGFloat
    var itemHeight: CGFloat
    var itemWidth: CGFloat
    var underlineColor: Color
    var underlineHeight: CGFloat
    var bottomSpacing: CGFloat
    var underlineCornerRadius: CGFloat
    var titleFontSize: CGFloat
    var backgroundColor: Color
    
    static var `default`: ModePickerScrollConfig {
        ModePickerScrollConfig(
            contentSpacing: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 18 : 8).wrappedValue,
            itemHeight: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 61 : 58).wrappedValue,
            itemWidth: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 60 : 55).wrappedValue,
            underlineColor: Color(red: 23/255.0, green: 255/255.0, blue: 193/255.0),
            underlineHeight: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 1 : 1).wrappedValue,
            bottomSpacing: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 9 : 7).wrappedValue,
            underlineCornerRadius: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 0.5 : 1).wrappedValue,
            titleFontSize: GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 9 : 9).wrappedValue,
            backgroundColor: Color(red: 23 / 255, green: 23 / 255, blue: 23 / 255, opacity: 1.0)
        )
    }
}

struct ModePickerScrollView: View {
    let items: [ModePickerScrollItem]
    @Binding var selectedIndex: Int
    var onSelect: (Int) -> Void
    var config: ModePickerScrollConfig = .default
    
    @State private var buttonFrames: [Int: CGRect] = [:]
    @State private var isUserTap: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center) {
                    VStack {
                        LazyHStack(spacing: config.contentSpacing) {
                            ForEach(items) { item in
                                ModePickerScrollCell(item: item, width: config.itemWidth, height: config.itemHeight, titleFontSize: config.titleFontSize)
                                    .onTapGesture {
                                        isUserTap = true
                                        withAnimation(.linear(duration: 0.15)) {
                                            selectedIndex = item.id
                                        }
                                        onSelect(item.id)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            isUserTap = false
                                        }
                                    }
                                    .id(item.id)
                                    .accessibilityIdentifier(item.accessibilityId ?? "mode_\(item.id)")
                            }
                        }
                        .coordinateSpace(name: "modePickerArea")
                        .overlay(alignment: .bottomLeading) {
                            if let frame = buttonFrames[selectedIndex] {
                                config.underlineColor
                                    .frame(width: config.itemWidth, height: config.underlineHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: config.underlineCornerRadius))
                                    .offset(x: frame.minX)
                                    .animation(.easeInOut(duration: 0.15), value: selectedIndex)
                            }
                        }
                    }
                }
                .frame(minWidth: UIScreen.main.bounds.width)
                .frame(maxWidth: .infinity)
                .background(GeometryReader { geo in
                    Color.clear
                        .onAppear { updateFrames(in: geo) }
                        .onChange(of: items.count) { _ in updateFrames(in: geo) }
                })
            }
            .frame(width: UIScreen.main.bounds.width, height: config.itemHeight + config.bottomSpacing)
            .fixedSize(horizontal: false, vertical: true)
            .background(config.backgroundColor)
            .environment(\.layoutDirection, .leftToRight)
            .onChange(of: selectedIndex) { _ in
                // programmatic change should auto-center
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.2)) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo(selectedIndex, anchor: .center)
                }
            }
        }
        .onPreferenceChange(ButtonFramePreferenceKey.self) { value in
            self.buttonFrames = value
        }
    }
    
    private func updateFrames(in geo: GeometryProxy) {
        // Recompute frames via preferences by laying out cells with geometry reader inside ModePickerCell
    }
}

private struct ModePickerScrollCell: View {

    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 16 : 11) var premiumBadgeOffsetX: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 0 : -3) var premiumBadgeOffsetY: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 6 : 6) var newBadgeOffsetX: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? -4 : -2) var newBadgeOffsetY: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 12 : 11) var newBadgeWidth: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? -1 : -2) var appliedDotOffsetY: CGFloat
    @GuidelinePixelValueConvertor(wrappedValue: IS_IPAD ? 3 : 3) var appliedDotSize: CGFloat

    let item: ModePickerScrollItem
    let width: CGFloat
    let height: CGFloat
    let titleFontSize: CGFloat
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(item.iconName, bundle: nil)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: width * 0.7, height: width * 0.7)
                if !item.isNew {
                    PremiumBadgeView(badge: item.premiumBadge)
                        .frame(width: width * 0.40, height: width * 0.20)
                        .offset(x: premiumBadgeOffsetX, y: premiumBadgeOffsetY)
                }
                if item.isNew {
                    Image("ico_new", bundle: nil)
                        .resizable()
                        .scaledToFit()
                        .frame(width: newBadgeWidth)
                        .offset(x: newBadgeOffsetX, y: newBadgeOffsetY)
                }
            }
            .overlay(alignment: .top) {
                if item.isApplied {
                    Circle()
                        .fill(Color.white)
                        .frame(width: appliedDotSize, height: appliedDotSize)
                        .padding(.top, appliedDotOffsetY)
                }
            }
            Text(item.title)
                .font(.system(size: titleFontSize))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: width)
        }
        .frame(width: width, height: height)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: ButtonFramePreferenceKey.self, value: [item.id: geo.frame(in: .named("modePickerArea"))])
            }
        )
    }
}
