import Foundation
import NFLBookmark
import NFLContentBlocker
import NFLDatabase
import NFLTabBrowser
import RealmSwift

struct RootContainer: TabBrowserControllerDependency {
    var appBundleIdentifier: String
    var realm: Realm
    var rootState: RootState
    var bookmarkStore: BookmarkStore
    var screenshotManager: ScreenshotManager
    var webViewManager: WebViewManager
    var bookmarkIconManager: BookmarkIconManager
    var settings: Settings
    var contentFilterManager: ContentFilterManager
    var tabStore: TabStore
}
