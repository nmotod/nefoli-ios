import Foundation
import SwiftUI
import Theme

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
            if text.wrappedValue.isEmpty {
                VStack {
                    Text(titleKey)
                        .foregroundStyle(Colors.secondaryLabel.swiftUIColor)
                        .padding(.top, 6)

                    Spacer()
                }
            }

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
