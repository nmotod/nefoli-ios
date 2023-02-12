import SwiftUI

extension View {
    public func themedGroupedList() -> some View {
        return scrollContentBackground(.hidden)
            .background(Colors.backgroundDark.swiftUIColor)
            .listRowBackground(Colors.background.swiftUIColor)
    }

    public func themedGroupedListContent() -> some View {
        return listRowBackground(Colors.background.swiftUIColor)
    }

    public func themedTint() -> some View {
        return tint(Colors.tint.swiftUIColor)
    }
}
