#if DEBUG

import Database
import Foundation
import RealmSwift

private func makeFolder(
    id: String?,
    title: String,
    children: [BookmarkItem]
) -> BookmarkItem {
    let item = BookmarkItem()
    item.kind = .folder
    item.title = title
    item.children.append(objectsIn: children)
    return item
}

private func makeBookmark(
    id: String?,
    title: String,
    urlString: String
) -> BookmarkItem {
    let item = BookmarkItem()
    item.kind = .bookmark
    item.title = title
    item.url = URL(string: urlString)
    return item
}

enum PreviewUtilities {
    static let realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

    @MainActor static var bookmarkManager: BookmarkManager = {
        let rootState = RootState()
        let bookmarksFolder = makeFolder(id: BookmarkItemSystemID.bookmarksFolder.rawValue, title: "", children: [
            makeBookmark(id: nil, title: "Bookmark 1", urlString: "https://example.com/1"),
            makeBookmark(id: nil, title: "Bookmark 2", urlString: "https://example.com/2"),
            makeBookmark(id: nil, title: "Bookmark 3", urlString: "https://example.com/3"),
        ])

        let favoritesFolder = makeFolder(id: BookmarkItemSystemID.favoritesFolder.rawValue, title: "", children: [
            makeBookmark(id: nil, title: "Favorite 1", urlString: "https://example.com/1"),
            makeBookmark(id: nil, title: "Favorite 2", urlString: "https://example.com/2"),
            makeBookmark(id: nil, title: "Favorite 3", urlString: "https://example.com/3"),
            makeFolder(id: nil, title: "Folder 1", children: []),
        ])

        rootState.bookmarksFolder = bookmarksFolder
        rootState.favoritesFolder = favoritesFolder

        try! realm.write {
            realm.add(rootState)
        }

        return BookmarkManager(
            bookmarksFolder: bookmarksFolder,
            favoritesFolder: favoritesFolder
        )
    }()
}

#endif
