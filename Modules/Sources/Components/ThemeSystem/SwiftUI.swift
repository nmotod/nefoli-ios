import SwiftUI

extension View {
    public func themedGroupedList() -> some View {
        return scrollContentBackground(.hidden)
            .background(ThemeColors.backgroundDark.swiftUIColor)
            .listRowBackground(ThemeColors.background.swiftUIColor)
            .foregroundColor(ThemeColors.textNormal.swiftUIColor)
    }

    public func themedGroupedListContent() -> some View {
        return listRowBackground(ThemeColors.background.swiftUIColor)
    }

    public func themedTint() -> some View {
        return tint(ThemeColors.tint.swiftUIColor)
    }

    public func themedNavigationBar() -> some View {
        return navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(ThemeColors.background.swiftUIColor, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
