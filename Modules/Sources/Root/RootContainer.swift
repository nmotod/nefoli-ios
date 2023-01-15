import Database
import Foundation
import RealmSwift
import TabBrowser

struct RootContainer: TabGroupControllerDependency {
    var appBundleIdentifier: String
    var realm: Realm
    var rootState: RootState
    var bookmarksFolder: BookmarkItem
    var favoritesFolder: BookmarkItem
    var screenshotManager: ScreenshotManager
    var webViewManager: WebViewManager
}
