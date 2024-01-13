import Foundation
import SwiftUI
import ThemeSystem

struct MultilineTextField: View {
    var titleKey: LocalizedStringKey

    var text: Binding<String>

    init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>
    ) {
        self.titleKey = titleKey
        self.text = text
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // placeholder
            if text.wrappedValue.isEmpty {
                VStack {
                    Text(titleKey)
                        .foregroundStyle(ThemeColors.secondaryLabel.swiftUIColor)
                        .padding(.top, 6)

                    Spacer()
                }
            }

            // Extend ZStack size by invisible text to avoid scrolling of TextEditor
            // https://stackoverflow.com/questions/62620613/dynamic-row-hight-containing-texteditor-inside-a-list-in-swiftui/62622490#62622490
            //
            // Other methods do not work as expected on iOS 17.0.1:
            //
            // 1. .scrollDisabled(false) => height increases with each typing
            // 2. .fixedSize(horizontal: false, vertical: true) => height becomes zero
            Text(text.wrappedValue)
                .padding(.all, 8)
                .opacity(0)

            TextEditor(text: Binding(
                get: { text.wrappedValue },
                set: { newValue in
                    if newValue.contains("\n") {
                        text.wrappedValue = newValue.replacingOccurrences(of: "\n", with: "")
                    } else {
                        text.wrappedValue = newValue
                    }
                }
            ))
            .padding(.horizontal, -5)
        }
    }
}
