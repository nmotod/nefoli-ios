import ActionSystem
import Foundation
import UIKit

enum TabBrowserActionType: String, CaseIterable, ActionTypeProtocol {
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

    var definition: ActionTypeDefinition {
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

private let bookmarksDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Bookmarks", comment: ""),
    image: UIImage(systemName: "book")
)

private let showMenuSheetDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Show Menu", comment: ""),
    image: UIImage(systemName: "ellipsis")
)

private let tabsDefinition = ActionTypeDefinition(
    title: NSLocalizedString("List Tabs", comment: ""),
    image: UIImage(
        systemName: "square.on.square"
//        ,
//        withConfiguration: UIImage.SymbolConfiguration(pointSize: 15)
    )
)

private let settingsDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Settings", comment: ""),
    image: UIImage(systemName: "gear")
)

private let closeActiveTabDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Close Tab", comment: "")
)

private let restoreClosedTabDefinition = ActionTypeDefinition(
    title: NSLocalizedString("Restore Tab", comment: "")
)

#if DEBUG
private let debugEditBookmarkDefinition = ActionTypeDefinition(
    title: "[Debug] Edit Bookmark"
)
#endif
