import Foundation
import SnapKit
import Theme
import UIKit

private let backgroundColor = Colors.backgroundDark.color

public class MenuSheetController: UINavigationController {
    public let webpageMetadata: WebpageMetadata?

    public let actionGroups: [[UIAction]]

    // MARK: - Initializers

    public init(
        webpageMetadata: WebpageMetadata?,
        actionGroups: [[UIAction]]
    ) {
        self.webpageMetadata = webpageMetadata
        self.actionGroups = actionGroups

        let listVC = MenuSheetActionListViewController(webpageMetadata: webpageMetadata, actionGroups: actionGroups)
        super.init(rootViewController: listVC)

        isNavigationBarHidden = true

        sheetPresentationController?.detents = [
            .medium(),
            .large(),
        ]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func show(_ childViewController: UIViewController, detents: [UISheetPresentationController.Detent]? = nil, animated: Bool) {
        if let detents {
            sheetPresentationController!.animateChanges {
                sheetPresentationController!.detents = detents
            }
        }

        Task {
            setViewControllers([childViewController], animated: animated)
        }
    }
}
