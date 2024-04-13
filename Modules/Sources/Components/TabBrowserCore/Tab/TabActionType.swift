import ActionSystem
import Foundation
import UIKit

public enum TabActionType: String, ActionTypeProtocol, CaseIterable {
    public static let idPrefix = "tab"

    case goBack
    case goForward
    case reload
    case share
    case openInDefaultApp
    case addBookmark
    case editAddress
    case translate
    case hatenaBookmark

    public var definition: ActionTypeDefinition {
        switch self {
        case .goBack:
            return goBackDefinition

        case .goForward:
            return goForwardDefinition

        case .reload:
            return reloadDefinition

        case .share:
            return shareDefinition

        case .openInDefaultApp:
            return openInSafariDefinition

        case .addBookmark:
            return addBookmarkDefinition

        case .editAddress:
            return editAddressDefinition

        case .translate:
            return translateDefinition

        case .hatenaBookmark:
            return hatenaBookmarkDefinition
        }
    }
}

private let goBackDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Back", comment: ""),
    image: UIImage(systemName: "chevron.left")
)

private let goForwardDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Froward", comment: ""),
    image: UIImage(systemName: "chevron.right")
)

private let reloadDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Reload", comment: ""),
    image: UIImage(systemName: "arrow.clockwise")
)

private let shareDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Share...", comment: ""),
    image: UIImage(systemName: "square.and.arrow.up")
)

private let openInSafariDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Open in Safari", comment: ""),
    image: UIImage(systemName: "safari")
)

private let addBookmarkDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Add Bookmark", comment: ""),
    image: UIImage(systemName: "book")
)

private let editAddressDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Search", comment: ""),
    image: UIImage(systemName: "magnifyingglass")
)

private let translateDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Translate", comment: ""),
    image: UIImage(systemName: "character.bubble")
)

private let hatenaBookmarkDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Hatena Bookmark", comment: ""),
    image: UIImage(systemName: "b.square.fill")
)
