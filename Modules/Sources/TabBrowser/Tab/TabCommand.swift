import CommandSystem
import Foundation
import UIKit

enum TabCommand: String, CommandProtocol, CaseIterable {
    static let idPrefix = "tab"

    case goBack
    case goForward
    case reload
    case share
    case openInDefaultApp
    case addBookmark
    case editAddress

    var definition: CommandDefinition {
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
        }
    }
}

private let goBackDefinition = CommandDefinition(
    title: NSLocalizedString("Back", comment: ""),
    image: UIImage(systemName: "chevron.left")
)

private let goForwardDefinition = CommandDefinition(
    title: NSLocalizedString("Froward", comment: ""),
    image: UIImage(systemName: "chevron.right")
)

private let reloadDefinition = CommandDefinition(
    title: NSLocalizedString("Reload", comment: ""),
    image: UIImage(systemName: "arrow.clockwise")
)

private let shareDefinition = CommandDefinition(
    title: NSLocalizedString("Share...", comment: ""),
    image: UIImage(systemName: "square.and.arrow.up")
)

private let openInSafariDefinition = CommandDefinition(
    title: NSLocalizedString("Open in Safari", comment: ""),
    image: UIImage(systemName: "safari")
)

private let addBookmarkDefinition = CommandDefinition(
    title: NSLocalizedString("Add Bookmark", comment: ""),
    image: UIImage(systemName: "book")
)

private let editAddressDefinition = CommandDefinition(
    title: NSLocalizedString("Search", comment: ""),
    image: UIImage(systemName: "magnifyingglass")
)
