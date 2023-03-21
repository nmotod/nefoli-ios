import Database
import Foundation

enum BookmarkItemSystemID: String {
    case bookmarksFolder = "bookmarks"
    case favoritesFolder = "favorites"
}

public class BookmarkManager {
    public let bookmarksFolder: BookmarkItem
    public let favoritesFolder: BookmarkItem

    public init(
        bookmarksFolder: BookmarkItem,
        favoritesFolder: BookmarkItem
    ) {
        self.bookmarksFolder = bookmarksFolder
        self.favoritesFolder = favoritesFolder
    }

    enum TraverseAction {
        case intoChildren
        case ignore
    }

    func traverseAllFolders(_ body: (BookmarkItem, Int) -> TraverseAction) {}
}
