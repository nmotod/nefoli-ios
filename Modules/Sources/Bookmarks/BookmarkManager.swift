import Database
import Foundation

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

    enum EnumerationAction {
        case intoChildren
        case ignore
    }

    /// Enumerates all folers recursively.
    ///
    /// - Parameters:
    ///    - body: A callback called for each folder.
    ///
    ///       Receives the following arguments:
    ///       - BookmarkItem
    ///       - A depth of item starting from 0.
    func recursiveEnumerateAllFolders(_ body: (BookmarkItem, _ depth: Int) -> EnumerationAction) {
        recursiveEnumerateChildFolders(bookmarksFolder, depth: 0, body: body)
        recursiveEnumerateChildFolders(favoritesFolder, depth: 0, body: body)
    }

    private func recursiveEnumerateChildFolders(_ parent: BookmarkItem, depth: Int, body: (BookmarkItem, Int) -> EnumerationAction) {
        let action = body(parent, depth)

        switch action {
        case .ignore: ()

        case .intoChildren:
            for child in parent.children {
                if child.isFolder {
                    recursiveEnumerateChildFolders(child, depth: depth + 1, body: body)
                }
            }
        }
    }
}
