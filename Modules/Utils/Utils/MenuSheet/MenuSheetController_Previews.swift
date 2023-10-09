import Foundation
import SwiftUI
import UIKit

private struct MenuSheet: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        return MenuSheetController(
            webpageMetadata: WebpageMetadata(
                title: "Example",
                url: URL(string: "https://example.com/")!
            ),
            actionGroups: [
                [
                    UIAction(
                        title: "Bookmarks",
                        image: UIImage(systemName: "book"),
                        handler: { _ in }
                    ),
                    UIAction(
                        title: "Bookmarks",
                        image: UIImage(
                            systemName: "square.on.square",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15)
                        ),
                        handler: { _ in }
                    ),
                ],
                [
                    UIAction(
                        title: "Settings",
                        image: UIImage(systemName: "gear"),
                        handler: { _ in }
                    ),
                ],
            ]
        )
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class MenuSheetController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MenuSheet()
        }
    }
}
