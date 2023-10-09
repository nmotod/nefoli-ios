import SwiftUI

extension View {
    public func themedGroupedList() -> some View {
        return scrollContentBackground(.hidden)
            .background(Colors.backgroundDark.swiftUIColor)
            .listRowBackground(Colors.background.swiftUIColor)
            .foregroundColor(Colors.textNormal.swiftUIColor)
    }

    public func themedGroupedListContent() -> some View {
        return listRowBackground(Colors.background.swiftUIColor)
    }

    public func themedTint() -> some View {
        return tint(Colors.tint.swiftUIColor)
    }

    public func themedNavigationBar() -> some View {
        return navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Colors.background.swiftUIColor, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
