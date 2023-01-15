import Foundation
import MenuSheet
import Utilities

#if canImport(SwiftUI)
import SwiftUI

private struct MenuSheet: UIViewControllerRepresentable {
    typealias UIViewControllerType = MenuSheetController

    let webpageMetadata: WebpageMetadata?
    let actionGroups: [[ExecutableAction]]

    func makeUIViewController(context _: Context) -> MenuSheetController {
        return MenuSheetController(
            webpageMetadata: webpageMetadata,
            actionGroups: actionGroups
        )
    }

    func updateUIViewController(_: MenuSheetController, context _: Context) {}
}

private struct Wrapper: View {
    @State var isPresented = false

    let webpageMetadata: WebpageMetadata?
    let actionGroups: [[ExecutableAction]] = [
        [
            ExecutableAction(
                title: "Bookmark",
                image: UIImage(systemName: "book"),
                handler: { _ in }
            ),
            ExecutableAction(
                title: "Tabs",
                image: UIImage(systemName: "square.on.square"),
                handler: { _ in }
            ),
        ],
    ]

    var body: some View {
        VStack {
            Button("Show") {
                isPresented = true
            }
        }
        .onAppear {
            var t = Transaction()
            t.disablesAnimations = true

            withTransaction(t) {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented) {
            MenuSheet(
                webpageMetadata: webpageMetadata,
                actionGroups: actionGroups
            )
        }
    }
}

struct MenuSheetPreviews: PreviewProvider {
    static var previews: some View {
        Wrapper(
            webpageMetadata: .init(
                title: "Example.com",
                url: URL(string: "https://example.com/")!
            )
        )

        Wrapper(
            webpageMetadata: .init(
                title: "",
                url: URL(string: "https://example.com/")!
            )
        )
        .previewDisplayName("MenuSheet (no title)")
    }
}

#endif
