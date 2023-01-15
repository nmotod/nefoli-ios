import Database
import Foundation

public protocol UsesBookmarkFolders {
    var bookmarksFolder: BookmarkItem { get }

    var favoritesFolder: BookmarkItem { get }
}
