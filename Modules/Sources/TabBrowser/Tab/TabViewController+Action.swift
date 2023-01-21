import Foundation
import UIKit
import Utilities

extension TabViewController {
    enum Action: String, ActionProtocol {
        static var category: String { "tab" }

        case goBack
        case goForward
        case share
        case openInSafari
        case addBookmark
        case editAddress

        typealias BuilderContext = TabViewController

        var definition: ActionDefinition<Action> {
            switch self {
            case .goBack:
                return buildDefinition(
                    title: NSLocalizedString("Back", comment: ""),
                    image: UIImage(systemName: "chevron.left"),
                    builder: { definition, tabVC in
                        weak var tabVC = tabVC

                        return ExecutableAction(
                            definition: definition,
                            isEnabledPublisher: tabVC?.canGoBackPublisher
                        ) { _ in
                            tabVC?.webView?.goBack()
                        }
                    }
                )

            case .goForward:
                return buildDefinition(
                    title: NSLocalizedString("Froward", comment: ""),
                    image: UIImage(systemName: "chevron.right"),
                    builder: { definition, tabVC in
                        weak var tabVC = tabVC

                        return ExecutableAction(
                            definition: definition,
                            isEnabledPublisher: tabVC?.canGoForwardPublisher
                        ) { _ in
                            tabVC?.webView?.goForward()
                        }
                    }
                )

            case .share:
                return buildDefinition(
                    title: NSLocalizedString("Share...", comment: ""),
                    image: UIImage(systemName: "square.and.arrow.up"),
                    builder: { definition, tabVC in
                        weak var tabVC = tabVC

                        return ExecutableAction(
                            definition: definition
                        ) { context in
                            tabVC?.share(context)
                        }
                    }
                )

            case .openInSafari:
                return buildDefinition(
                    title: NSLocalizedString("Open in Safari", comment: ""),
                    image: UIImage(systemName: "safari"),
                    builder: { definition, _ in
                        return ExecutableAction(definition: definition) { _ in }
                    }
                )

            case .addBookmark:
                return buildDefinition(
                    title: NSLocalizedString("Add Bookmark", comment: ""),
                    image: UIImage(systemName: "book"),
                    builder: { definition, _ in
                        return ExecutableAction(definition: definition) { _ in }
                    }
                )

            case .editAddress:
                return buildDefinition(
                    title: NSLocalizedString("Search", comment: ""),
                    image: nil,
                    builder: { definition, tabVC in
                        weak var tabVC = tabVC

                        return ExecutableAction(definition: definition) { context in
                            tabVC?.editAddress(context)
                        }
                    }
                )
            }
        }
    }
}
