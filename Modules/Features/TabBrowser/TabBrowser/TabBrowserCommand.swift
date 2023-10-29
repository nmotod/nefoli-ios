import CommandSystem
import Foundation
import UIKit

enum TabBrowserCommand: String, CaseIterable, CommandProtocol {
    static var idPrefix = "tabBrowser"

    case bookmarks
    case menuSheet
    case tabs
    case settings
    case closeActiveTab
    case restoreClosedTab

    #if DEBUG
    case debugEditBookmark
    #endif

    var definition: CommandDefinition {
        switch self {
        case .bookmarks:
            return bookmarksDefinition

        case .menuSheet:
            return showMenuSheetDefinition

        case .tabs:
            return tabsDefinition

        case .settings:
            return settingsDefinition

        case .closeActiveTab:
            return closeActiveTabDefinition

        case .restoreClosedTab:
            return restoreClosedTabDefinition

        #if DEBUG
        case .debugEditBookmark:
            return debugEditBookmarkDefinition
        #endif
        }
    }
}

private let bookmarksDefinition = CommandDefinition(
    title: NSLocalizedString("Bookmarks", comment: ""),
    image: UIImage(systemName: "book")
)

private let showMenuSheetDefinition = CommandDefinition(
    title: NSLocalizedString("Show Menu", comment: ""),
    image: UIImage(systemName: "ellipsis")
)

private let tabsDefinition = CommandDefinition(
    title: NSLocalizedString("List Tabs", comment: ""),
    image: UIImage(
        systemName: "square.on.square"
//        ,
//        withConfiguration: UIImage.SymbolConfiguration(pointSize: 15)
    )
)

private let settingsDefinition = CommandDefinition(
    title: NSLocalizedString("Settings", comment: ""),
    image: UIImage(systemName: "gear")
)

private let closeActiveTabDefinition = CommandDefinition(
    title: NSLocalizedString("Close Tab", comment: "")
)

private let restoreClosedTabDefinition = CommandDefinition(
    title: NSLocalizedString("Restore Tab", comment: "")
)

#if DEBUG
private let debugEditBookmarkDefinition = CommandDefinition(
    title: "[Debug] Edit Bookmark"
)
#endif
