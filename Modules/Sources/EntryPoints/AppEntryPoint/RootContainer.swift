import Bookmark
import ContentBlocker
import Database
import Foundation
import RealmSwift
import TabBrowser

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
